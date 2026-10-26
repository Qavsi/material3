// Adapted from QmlMaterial 229bc3e6 (MIT) and AOSP realistic ripple (Apache-2.0).
// Copyright (C) 2021 The Android Open Source Project.
// Driver constants: Copyright 2023 Google LLC (BSD). See third_party/ripple-reference.
#include "materialbuttonfeedback.h"

#include <QPainter>
#include <QPainterPath>
#include <QRadialGradient>
#include <algorithm>
#include <cmath>

namespace {
qreal unit(qreal value)
{
    return std::isfinite(value) ? std::clamp(value, qreal(0), qreal(1)) : 0;
}
qreal subProgress(qreal start, qreal end, qreal progress)
{
    return std::clamp((progress - start) / (end - start), qreal(0), qreal(1));
}
}

MaterialButtonFeedback::MaterialButtonFeedback(QQuickItem *parent)
    : QQuickPaintedItem(parent)
{
    setAntialiasing(true);
    setRenderTarget(QQuickPaintedItem::Image);
    setAcceptedMouseButtons(Qt::NoButton);
    connect(this, &MaterialButtonFeedback::appearanceChanged, this, [this] { update(); });
}

void MaterialButtonFeedback::paint(QPainter *painter)
{
    const QRectF container = boundingRect();
    if (container.isEmpty() || !std::isfinite(container.width())
        || !std::isfinite(container.height()) || !m_rippleColor.isValid()
        || m_rippleColor.alphaF() <= 0)
        return;
    const auto radius = [this, &container](float value) {
        const qreal candidate = value >= 0 ? qreal(value) : m_cornerRadius;
        return std::isfinite(candidate)
            ? std::clamp(candidate, qreal(0), std::min(container.width(), container.height()) / 2) : 0;
    };
    const qreal topLeft = radius(m_cornerRadii.x());
    const qreal topRight = radius(m_cornerRadii.y());
    const qreal bottomLeft = radius(m_cornerRadii.z());
    const qreal bottomRight = radius(m_cornerRadii.w());
    const qreal right = container.right();
    const qreal bottom = container.bottom();
    QPainterPath mask;
    mask.moveTo(topLeft, 0);
    mask.lineTo(right - topRight, 0);
    mask.arcTo(right - 2 * topRight, 0, 2 * topRight, 2 * topRight, 90, -90);
    mask.lineTo(right, bottom - bottomRight);
    mask.arcTo(right - 2 * bottomRight, bottom - 2 * bottomRight,
               2 * bottomRight, 2 * bottomRight, 0, -90);
    mask.lineTo(bottomLeft, bottom);
    mask.arcTo(0, bottom - 2 * bottomLeft, 2 * bottomLeft, 2 * bottomLeft, 270, -90);
    mask.lineTo(0, topLeft);
    mask.arcTo(0, 0, 2 * topLeft, 2 * topLeft, 180, -90);
    mask.closeSubpath();

    const qreal baseAlpha = m_rippleColor.alphaF() * unit(m_stateOpacity);
    if (baseAlpha > 0) {
        QColor stateColor = m_rippleColor;
        stateColor.setAlphaF(baseAlpha);
        painter->fillPath(mask, stateColor);
    }

    const qreal progress = unit(m_rippleProgress);
    const qreal fade = std::min(subProgress(0, 0.13, progress),
                               1 - subProgress(0.4, 1, progress));
    const qreal waveAlpha = m_rippleColor.alphaF() * unit(m_rippleOpacity) * fade;
    if (waveAlpha <= 0 || progress <= 0)
        return;
    const auto position = [](qreal value, qreal extent) {
        return std::isfinite(value) ? std::clamp(value, qreal(0), extent) : extent / 2;
    };
    const QPointF touch(position(m_rippleOrigin.x(), container.width()),
                        position(m_rippleOrigin.y(), container.height()));
    const qreal coverage = std::hypot(std::max(touch.x(), container.width() - touch.x()),
                                      std::max(touch.y(), container.height() - touch.y()));
    const qreal waveRadius = coverage * progress;
    if (waveRadius <= 0)
        return;
    const qreal centerProgress = std::min(progress * 2, qreal(1));
    const QPointF center = touch + (container.center() - touch) * centerProgress;
    QRadialGradient wave(center, waveRadius * 1.5);
    QColor ink = m_rippleColor;
    ink.setAlphaF(waveAlpha);
    wave.setColorAt(0, ink);
    // Sample QCM softCircle's cubic edge (0.5R..1.5R), not a hard ellipse.
    // Software deliberately omits the shader's noisy sparkle grids.
    constexpr int edgeSteps = 8;
    for (int i = 0; i <= edgeSteps; ++i) {
        const qreal t = qreal(i) / edgeSteps;
        QColor edgeColor = ink;
        edgeColor.setAlphaF(waveAlpha * (1 - t * t * (3 - 2 * t)));
        wave.setColorAt((0.5 + t) / 1.5, edgeColor);
    }
    painter->save();
    painter->setClipPath(mask);
    painter->fillRect(container, wave);
    painter->restore();
}
