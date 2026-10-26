// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT
#include "roundedrectshadow.h"
#include "shadowgeometry.h"
#include "shadowmaterial.h"

#include <QQuickWindow>
#include <QSGGeometryNode>
#include <QSGRendererInterface>
#include <algorithm>
#include <cmath>

namespace {

class ShadowNode final : public QSGGeometryNode {
public:
    ShadowNode(QQuickWindow *owner, std::shared_ptr<qavsi::shadow::ShadowTexture> texture)
        : window(owner)
    {
        setGeometry(qavsi::shadow::createShadowGeometry().release());
        setMaterial(new qavsi::shadow::ShadowMaterial(std::move(texture)));
        setFlags(OwnsGeometry | OwnsMaterial);
    }

    QQuickWindow *window;
    QRectF rect;
    qavsi::shadow::ShadowParameters parameters;
    bool initialized = false;
};

bool finite(qreal value)
{
    return std::isfinite(value) && std::isfinite(float(value));
}

} // namespace

RoundedRectShadow::RoundedRectShadow(QQuickItem *parent) : QQuickItem(parent)
{
    setFlag(ItemHasContents, true);
    connect(this, &RoundedRectShadow::appearanceChanged, this, &RoundedRectShadow::update);
}

void RoundedRectShadow::geometryChange(const QRectF &newGeometry, const QRectF &oldGeometry)
{
    QQuickItem::geometryChange(newGeometry, oldGeometry);
    if (newGeometry.size() != oldGeometry.size())
        update();
}

QSGNode *RoundedRectShadow::updatePaintNode(QSGNode *oldNode, UpdatePaintNodeData *)
{
    auto *node = static_cast<ShadowNode *>(oldNode);
    const auto discard = [&]() -> QSGNode * { delete node; return nullptr; };
    auto *owner = window();
    if (!owner || owner->rendererInterface()->graphicsApi() == QSGRendererInterface::Software
        || !finite(width()) || !finite(height()) || width() <= 0 || height() <= 0
        || !finite(m_elevation) || m_elevation <= 0 || !m_color.isValid() || m_color.alpha() == 0
        || !finite(m_ambientOpacity) || !finite(m_spotOpacity) || !finite(m_lightRadius)
        || m_lightRadius < 0 || !finite(m_lightDirection.x()) || !finite(m_lightDirection.y())
        || !finite(m_lightDirection.z()) || m_lightDirection.z() <= 0)
        return discard();
    const float maximumRadius = std::min(width(), height()) / 2;
    auto radii = m_cornerRadii;
    for (int i = 0; i < 4; ++i) {
        if (!finite(radii[i]))
            return discard();
        radii[i] = std::clamp(radii[i], 0.0f, maximumRadius);
    }
    const qavsi::shadow::ShadowParameters parameters{
        float(m_elevation), radii, m_color,
        float(std::clamp(m_ambientOpacity, qreal(0), qreal(1))),
        float(std::clamp(m_spotOpacity, qreal(0), qreal(1))),
        m_lightDirection, float(m_lightRadius)
    };
    if (parameters.ambientOpacity <= 0 && parameters.spotOpacity <= 0)
        return discard();
    if (node && node->window != owner) {
        delete node;
        node = nullptr;
    }
    if (!node) {
        auto texture = qavsi::shadow::acquireShadowTexture(owner);
        if (!texture)
            return nullptr;
        node = new ShadowNode(owner, std::move(texture));
    }
    const auto rect = boundingRect();
    if (!node->initialized || node->parameters != parameters || node->rect != rect) {
        if (!qavsi::shadow::updateShadowGeometry(node->geometry(), parameters, rect))
            return discard();
        node->parameters = parameters;
        node->rect = rect;
        node->initialized = true;
        node->markDirty(QSGNode::DirtyGeometry);
    }
    return node;
}
