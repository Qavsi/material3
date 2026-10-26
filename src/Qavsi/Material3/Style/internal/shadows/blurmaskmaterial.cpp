// Adapted from QmlMaterial 229bc3e6 (MIT), copyright (c) 2024-2025 hypengw.
// Skia-derived Gaussian model (BSD-3-Clause); see third_party/shadow-reference.
#include "blurmaskmaterial.h"
#include "blurmaskmath.h"

#include <QImage>
#include <QMatrix4x4>
#include <QQuickWindow>
#include <algorithm>
#include <cmath>
#include <cstring>
#include <functional>
#include <mutex>
#include <span>
#include <vector>

namespace qavsi::shadow::blur {

namespace {
constexpr int maximumExtent = 2048;
constexpr std::size_t maximumConvolutionWork = 64 * 1024 * 1024;
constexpr std::size_t cacheBudget = 16 * 1024 * 1024;

int compareTexture(const QSGTexture *a, const QSGTexture *b)
{
    return a == b ? 0 : std::less<const QSGTexture *>{}(a, b) ? -1 : 1;
}
} // namespace

bool safeCutout(float sigma, float radius)
{
    if (!std::isfinite(sigma) || !std::isfinite(radius) || sigma < 0 || radius < 0)
        return false;
    if (sigma < .5f || radius < .5f)
        return true;
    // Check before integer conversion/allocation; ordinary kit sigma/radii are far below these bounds.
    const double quantizedSigma = std::round(double(sigma) * 2) * .5;
    const double quantizedRadius = std::round(double(radius) * 2) * .5;
    const double margin = std::ceil(3 * quantizedSigma);
    const double extent = std::ceil(quantizedRadius) + 2 * margin;
    return extent <= maximumExtent
        && extent * extent * (2 * margin + 1) <= maximumConvolutionWork;
}

TextureCache::TextureCache(QQuickWindow *window) : m_window(window) {}

bool TextureCache::initialize()
{
    constexpr int profileSize = 128;
    QImage image(profileSize, 1, QImage::Format_Grayscale8);
    if (image.isNull())
        return false;
    fill_unit_cdf_profile(std::span<std::uint8_t>(image.scanLine(0), profileSize));
    m_profile.reset(m_window->createTextureFromImage(image));
    if (m_profile)
        m_profile->setFiltering(QSGTexture::Linear);
    return bool(m_profile);
}

std::shared_ptr<CornerTexture> TextureCache::corner(float sigma, float radius)
{
    if (sigma < .5f || radius < .5f || !safeCutout(sigma, radius))
        return {};
    const auto sigmaKey = quint32(std::round(sigma * 2));
    const auto radiusKey = quint32(std::round(radius * 2));
    const quint64 key = (quint64(sigmaKey) << 32) | radiusKey;
    if (auto it = m_corners.find(key); it != m_corners.end()) {
        m_recency.splice(m_recency.begin(), m_recency, it->second.recency);
        return it->second.texture;
    }
    sigma = sigmaKey * .5f;
    radius = radiusKey * .5f;
    const int extent = rrect_corner_cutout_size(sigma, radius);
    QImage image(extent, extent, QImage::Format_Grayscale8);
    if (image.isNull())
        return {};
    std::vector<std::uint8_t> pixels(std::size_t(extent) * extent);
    fill_rrect_corner_cutout(pixels, sigma, radius);
    for (int y = 0; y < extent; ++y)
        std::memcpy(image.scanLine(y), pixels.data() + std::size_t(y) * extent, extent);
    auto result = std::make_shared<CornerTexture>();
    result->texture.reset(m_window->createTextureFromImage(image));
    if (!result->texture)
        return {};
    result->texture->setFiltering(QSGTexture::Linear);
    result->margin = gaussian_kernel_radius(sigma);
    result->extent = extent;
    result->sigma = sigma;
    const std::size_t bytes = std::size_t(extent) * extent;
    while (!m_recency.empty() && m_cachedBytes + bytes > cacheBudget) {
        const auto oldest = m_recency.back();
        auto it = m_corners.find(oldest);
        m_cachedBytes -= it->second.bytes;
        m_corners.erase(it);
        m_recency.pop_back();
    }
    m_recency.push_front(key);
    m_corners.emplace(key, Entry{result, m_recency.begin(), bytes});
    m_cachedBytes += bytes;
    return result;
}

std::shared_ptr<TextureCache> acquireTextureCache(QQuickWindow *window)
{
    static std::mutex mutex;
    static std::unordered_map<QQuickWindow *, std::weak_ptr<TextureCache>> caches;
    std::lock_guard guard(mutex);
    for (auto it = caches.begin(); it != caches.end();) {
        if (it->second.expired())
            it = caches.erase(it);
        else
            ++it;
    }
    if (auto it = caches.find(window); it != caches.end()) {
        if (auto cache = it->second.lock())
            return cache;
    }
    auto cache = std::make_shared<TextureCache>(window);
    if (!cache->initialize())
        return {};
    // Scene graph materials own the cache and destroy every GPU texture on their render thread.
    caches.insert_or_assign(window, cache);
    return cache;
}

Material::Material(std::shared_ptr<TextureCache> cache) : m_cache(std::move(cache))
{
    setFlag(QSGMaterial::Blending, true);
    // Coverage uses item-local positions, so the batch renderer must preserve the full transform.
    setFlag(QSGMaterial::RequiresFullMatrix, true);
}

QSGMaterialType *Material::type() const
{
    static QSGMaterialType type;
    return &type;
}

QSGMaterialShader *Material::createShader(QSGRendererInterface::RenderMode) const
{
    return new Shader;
}

int Material::compare(const QSGMaterial *other) const
{
    const auto *material = static_cast<const Material *>(other);
    if (const int result = compareTexture(profileTexture(), material->profileTexture()))
        return result;
    for (int i = 0; i < 4; ++i) {
        const auto *a = cornerTexture(i);
        const auto *b = material->cornerTexture(i);
        if (const int result = compareTexture(a ? a->texture.get() : nullptr,
                                              b ? b->texture.get() : nullptr))
            return result;
    }
    if (sigma != material->sigma)
        return sigma < material->sigma ? -1 : 1;
    if (rectSize.x() != material->rectSize.x())
        return rectSize.x() < material->rectSize.x() ? -1 : 1;
    if (rectSize.y() != material->rectSize.y())
        return rectSize.y() < material->rectSize.y() ? -1 : 1;
    for (int i = 0; i < 4; ++i) {
        if (radii[i] != material->radii[i])
            return radii[i] < material->radii[i] ? -1 : 1;
    }
    return 0;
}

bool Material::setAppearance(float newSigma, QVector2D newSize, QVector4D newRadii)
{
    std::array<std::shared_ptr<CornerTexture>, 4> corners;
    for (int i = 0; i < 4; ++i) {
        corners[i] = m_cache->corner(newSigma, newRadii[i]);
        if (newSigma >= .5f && newRadii[i] >= .5f && !corners[i])
            return false;
    }
    sigma = newSigma;
    rectSize = newSize;
    radii = newRadii;
    m_corners = std::move(corners);
    return true;
}

Shader::Shader()
{
    setShaderFileName(VertexStage, QStringLiteral(":/Qavsi/Material3/Style/shaders/blur_mask.vert.qsb"));
    setShaderFileName(FragmentStage, QStringLiteral(":/Qavsi/Material3/Style/shaders/blur_mask.frag.qsb"));
}

bool Shader::updateUniformData(RenderState &state, QSGMaterial *newMaterial, QSGMaterial *)
{
    const auto *material = static_cast<Material *>(newMaterial);
    auto *buffer = state.uniformData();
    Q_ASSERT(buffer->size() >= 176);
    if (state.isMatrixDirty()) {
        const auto matrix = state.combinedMatrix();
        std::memcpy(buffer->data(), matrix.constData(), 64);
    }
    if (state.isOpacityDirty()) {
        const float opacity = state.opacity();
        std::memcpy(buffer->data() + 64, &opacity, 4);
    }
    float sigma = material->sigma;
    for (int i = 0; i < 4; ++i) {
        if (const auto *corner = material->cornerTexture(i)) {
            sigma = corner->sigma;
            break;
        }
    }
    std::memcpy(buffer->data() + 68, &sigma, 4);
    const float width = material->rectSize.x();
    const float height = material->rectSize.y();
    std::memcpy(buffer->data() + 72, &width, 4);
    std::memcpy(buffer->data() + 76, &height, 4);
    const int outerStyle = 2;
    std::memcpy(buffer->data() + 80, &outerStyle, 4);
    const float radius = std::max({material->radii.x(), material->radii.y(),
                                   material->radii.z(), material->radii.w()});
    std::memcpy(buffer->data() + 84, &radius, 4);
    for (int i = 0; i < 4; ++i) {
        const float r = material->radii[i];
        std::memcpy(buffer->data() + 88 + i * 4, &r, 4);
        const auto *corner = material->cornerTexture(i);
        const float mapping[] = {corner ? corner->margin : 0, corner ? corner->extent : 0, 0, 0};
        std::memcpy(buffer->data() + 112 + i * 16, mapping, sizeof(mapping));
    }
    return true;
}

void Shader::updateSampledImage(RenderState &state, int binding, QSGTexture **texture,
                               QSGMaterial *newMaterial, QSGMaterial *)
{
    auto *material = static_cast<Material *>(newMaterial);
    QSGTexture *image = nullptr;
    if (binding == 1)
        image = material->profileTexture();
    else if (binding >= 2 && binding <= 5) {
        const auto *corner = material->cornerTexture(binding - 2);
        image = corner ? corner->texture.get() : material->profileTexture();
    }
    if (image) {
        *texture = image;
        image->commitTextureOperations(state.rhi(), state.resourceUpdateBatch());
    }
}

} // namespace qavsi::shadow::blur
