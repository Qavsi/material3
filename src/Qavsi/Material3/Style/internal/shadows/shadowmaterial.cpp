// Adapted from QmlMaterial (MIT), copyright (c) 2024-2025 hypengw.
// Skia-derived shadow math (BSD-3-Clause); see third_party/shadow-reference.
#include "shadowmaterial.h"

#include <QImage>
#include <QMatrix4x4>
#include <QQuickWindow>
#include <algorithm>
#include <cmath>
#include <cstring>
#include <mutex>
#include <unordered_map>

namespace qavsi::shadow {

std::shared_ptr<ShadowTexture> acquireShadowTexture(QQuickWindow *window)
{
    static std::mutex mutex;
    static std::unordered_map<QQuickWindow *, std::weak_ptr<ShadowTexture>> cache;
    std::lock_guard guard(mutex);
    for (auto it = cache.begin(); it != cache.end();) {
        if (it->second.expired())
            it = cache.erase(it);
        else
            ++it;
    }
    if (auto it = cache.find(window); it != cache.end()) {
        if (auto texture = it->second.lock())
            return texture;
    }

    constexpr int profileSize = 128;
    QImage image(profileSize, 1, QImage::Format_Grayscale8);
    auto *row = image.scanLine(0);
    for (int i = 0; i < profileSize; ++i) {
        const float d = 1.0f - i / float(profileSize - 1);
        row[i] = std::clamp(int(std::floor((std::exp(-4.0f * d * d) - 0.018f) * 255.0f + 0.5f)),
                             0, 255);
    }
    auto result = std::make_shared<ShadowTexture>();
    result->texture.reset(window->createTextureFromImage(image));
    if (!result->texture)
        return {};
    // Only render-thread scene graph materials own textures; window keys are weak bookkeeping.
    cache.insert_or_assign(window, result);
    return result;
}

ShadowMaterial::ShadowMaterial(std::shared_ptr<ShadowTexture> texture)
    : m_texture(std::move(texture))
{
    setFlag(QSGMaterial::Blending, true);
}

QSGMaterialType *ShadowMaterial::type() const
{
    static QSGMaterialType type;
    return &type;
}

QSGMaterialShader *ShadowMaterial::createShader(QSGRendererInterface::RenderMode) const
{
    return new ShadowShader;
}

int ShadowMaterial::compare(const QSGMaterial *other) const
{
    const auto otherKey = static_cast<const ShadowMaterial *>(other)->texture()->comparisonKey();
    const auto key = texture()->comparisonKey();
    return key < otherKey ? -1 : key > otherKey ? 1 : 0;
}

QSGTexture *ShadowMaterial::texture() const
{
    return m_texture->texture.get();
}

ShadowShader::ShadowShader()
{
    setShaderFileName(VertexStage,
        QStringLiteral(":/Qavsi/Material3/Style/shaders/shadow.vert.qsb"));
    setShaderFileName(FragmentStage,
        QStringLiteral(":/Qavsi/Material3/Style/shaders/shadow.frag.qsb"));
}

bool ShadowShader::updateUniformData(RenderState &state, QSGMaterial *, QSGMaterial *)
{
    bool changed = false;
    auto *buffer = state.uniformData();
    Q_ASSERT(buffer->size() >= 68);
    if (state.isMatrixDirty()) {
        const auto matrix = state.combinedMatrix();
        std::memcpy(buffer->data(), matrix.constData(), 64);
        changed = true;
    }
    if (state.isOpacityDirty()) {
        const float opacity = state.opacity();
        std::memcpy(buffer->data() + 64, &opacity, 4);
        changed = true;
    }
    return changed;
}

void ShadowShader::updateSampledImage(RenderState &state, int binding, QSGTexture **texture,
                                      QSGMaterial *newMaterial, QSGMaterial *)
{
    if (binding == 1) {
        *texture = static_cast<ShadowMaterial *>(newMaterial)->texture();
        (*texture)->commitTextureOperations(state.rhi(), state.resourceUpdateBatch());
    }
}

} // namespace qavsi::shadow
