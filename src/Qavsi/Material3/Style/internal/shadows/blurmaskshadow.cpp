// Adapted from QmlMaterial 229bc3e6 (MIT), copyright (c) 2024-2025 hypengw.
// Skia-derived Gaussian model (BSD-3-Clause); see third_party/shadow-reference.
#include "blurmaskshadow.h"
#include "blurmaskmaterial.h"

#include <QQuickWindow>
#include <QSGGeometryNode>
#include <QSGRendererInterface>
#include <algorithm>
#include <cmath>
#include <memory>

namespace {

struct Vertex {
    float x, y, r, g, b, a;
};

template<class V>
void quad(V *out, const V &topLeft, const V &topRight, const V &bottomLeft, const V &bottomRight)
{
    out[0] = topLeft;
    out[1] = topRight;
    out[2] = bottomLeft;
    out[3] = bottomLeft;
    out[4] = bottomRight;
    out[5] = topRight;
}

void updateGeometry(Vertex *vertices, QVector2D rectSize, float sigma, QColor color, QVector4D radii)
{
    const float margin = 3 * std::max(sigma, 0.0f);
    const QVector2D outerSize(rectSize.x() + 2 * margin, rectSize.y() + 2 * margin);
    const float cornerSize = std::max({radii.x(), radii.y(), radii.z(), radii.w(), margin});
    const QVector2D cornerOrigins[] = {{0, 0}, {outerSize.x() - cornerSize, 0},
        {0, outerSize.y() - cornerSize}, {outerSize.x() - cornerSize, outerSize.y() - cornerSize}};
    const QRgb rgba = color.rgba();
    const float alpha = qAlpha(rgba) / 255.0f;
    const float red = qRed(rgba) / 255.0f * alpha;
    const float green = qGreen(rgba) / 255.0f * alpha;
    const float blue = qBlue(rgba) / 255.0f * alpha;
    for (int corner = 0; corner < 4; ++corner) {
        const auto origin = cornerOrigins[corner];
        auto *v = vertices + corner * 6;
        const auto vertex = [&](float x, float y) {
            return Vertex{x - margin, y - margin, red, green, blue, alpha};
        };
        v[0] = vertex(origin.x(), origin.y());
        v[1] = vertex(origin.x() + cornerSize, origin.y());
        v[2] = vertex(origin.x(), origin.y() + cornerSize);
        v[3] = v[2];
        v[4] = vertex(origin.x() + cornerSize, origin.y() + cornerSize);
        v[5] = v[1];
    }
    // Keep the reference's corner/edge/center stitch order and item-local halo coordinates.
    quad(vertices + 24, vertices[5], vertices[6], vertices[4], vertices[8]);
    quad(vertices + 30, vertices[13], vertices[18], vertices[16], vertices[20]);
    quad(vertices + 36, vertices[3], vertices[4], vertices[12], vertices[13]);
    quad(vertices + 42, vertices[8], vertices[10], vertices[18], vertices[19]);
    quad(vertices + 48, vertices[4], vertices[8], vertices[13], vertices[18]);
}

class Node final : public QSGGeometryNode {
public:
    Node(QQuickWindow *window, std::shared_ptr<qavsi::shadow::blur::TextureCache> cache)
        : owner(window)
    {
        static const QSGGeometry::Attribute attributes[] = {
            QSGGeometry::Attribute::createWithAttributeType(
                0, 2, QSGGeometry::FloatType, QSGGeometry::PositionAttribute),
            QSGGeometry::Attribute::createWithAttributeType(
                1, 4, QSGGeometry::FloatType, QSGGeometry::UnknownAttribute)
        };
        static const QSGGeometry::AttributeSet attributeSet = {2, sizeof(Vertex), attributes};
        setGeometry(new QSGGeometry(attributeSet, 54));
        geometry()->setDrawingMode(QSGGeometry::DrawTriangles);
        setMaterial(new qavsi::shadow::blur::Material(std::move(cache)));
        setFlags(OwnsGeometry | OwnsMaterial);
    }
    QQuickWindow *owner;
    QColor color;
    bool initialized = false;
};

bool finite(qreal value)
{
    return std::isfinite(value) && std::isfinite(float(value));
}

} // namespace

BlurMaskShadow::BlurMaskShadow(QQuickItem *parent) : QQuickItem(parent)
{
    setFlag(ItemHasContents, true);
    connect(this, &BlurMaskShadow::appearanceChanged, this, &BlurMaskShadow::update);
}

void BlurMaskShadow::geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry)
{
    QQuickItem::geometryChange(newGeometry, oldGeometry);
    if (newGeometry.size() != oldGeometry.size())
        update();
}

QSGNode *BlurMaskShadow::updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *)
{
    auto *node = static_cast<Node *>(oldNode);
    const auto discard = [&]() -> QSGNode * { delete node; return nullptr; };
    auto *window = this->window();
    if (!window || window->rendererInterface()->graphicsApi() == QSGRendererInterface::Software
        || !finite(width()) || !finite(height()) || width() <= 0 || height() <= 0
        || !finite(m_sigma) || m_sigma < 0 || !m_color.isValid() || m_color.alpha() == 0)
        return discard();
    const float sigma = float(m_sigma);
    const float margin = 3 * sigma;
    const QVector2D size(width(), height());
    if (!finite(size.x() + 2 * margin) || !finite(size.y() + 2 * margin))
        return discard();
    auto radii = m_cornerRadii;
    const float maximumRadius = std::min(size.x(), size.y()) / 2;
    for (int i = 0; i < 4; ++i) {
        if (!finite(radii[i]))
            return discard();
        radii[i] = std::clamp(radii[i], 0.0f, maximumRadius);
        if (!qavsi::shadow::blur::safeCutout(sigma, radii[i]))
            return discard();
    }
    if (node && node->owner != window) {
        delete node;
        node = nullptr;
    }
    if (!node) {
        auto cache = qavsi::shadow::blur::acquireTextureCache(window);
        if (!cache)
            return nullptr;
        node = new Node(window, std::move(cache));
    }
    auto *material = static_cast<qavsi::shadow::blur::Material *>(node->material());
    const bool materialChanged = !node->initialized || material->sigma != sigma
        || material->rectSize != size || material->radii != radii;
    if (materialChanged && !material->setAppearance(sigma, size, radii))
        return discard();
    if (materialChanged || node->color != m_color) {
        auto *vertices = static_cast<Vertex *>(node->geometry()->vertexData());
        updateGeometry(vertices, size, sigma, m_color, radii);
        for (int i = 0; i < 54; ++i) {
            if (!finite(vertices[i].x) || !finite(vertices[i].y))
                return discard();
        }
        node->color = m_color;
        node->markDirty(QSGNode::DirtyGeometry);
    }
    if (materialChanged)
        node->markDirty(QSGNode::DirtyMaterial);
    node->initialized = true;
    return node;
}
