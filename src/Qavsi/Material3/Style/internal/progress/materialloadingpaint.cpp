// Copyright (c) 2026 Enes Alp
// Copyright (c) 2024-2025 hypengw (hypengwip@gmail.com)
// SPDX-License-Identifier: MIT
// QCM 0.6.1 loading motion, 191260585a829ee4ae2c99e6232b7145b5c34474.
#include "materialloadingpaint.h"
#include "qcmloading/loadingshapes.h"

#include <QPainter>
#include <algorithm>
#include <cmath>

namespace {
qreal springValue(qreal phaseFraction) {
    // QCM's analytic spring: stiffness 200, damping ratio 0.6, 650 ms per shape.
    constexpr qreal naturalFrequency = 14.142135623730951;
    constexpr qreal dampingRatio = .6;
    constexpr qreal dampedFrequency = 11.313708498984761;
    constexpr qreal secondsPerShape = .65;
    const qreal seconds = phaseFraction * secondsPerShape;
    return 1 - std::exp(-dampingRatio * naturalFrequency * seconds)
        * (std::cos(dampedFrequency * seconds)
           + dampingRatio * naturalFrequency / dampedFrequency * std::sin(dampedFrequency * seconds));
}
} // namespace

MaterialLoadingPaint::MaterialLoadingPaint(QQuickItem *parent)
    : QQuickPaintedItem(parent) {
    setAntialiasing(true);
    setFillColor(Qt::transparent);
}

void MaterialLoadingPaint::setPhase(qreal phase) {
    if (!std::isfinite(phase) || phase < 0 || m_phase == phase)
        return;
    m_phase = phase;
    update();
    emit phaseChanged();
}

void MaterialLoadingPaint::setColor(const QColor &color) {
    if (m_color == color)
        return;
    m_color = color;
    update();
    emit colorChanged();
}

void MaterialLoadingPaint::setShapeSize(qreal size) {
    if (!std::isfinite(size) || size < 0 || m_shapeSize == size)
        return;
    m_shapeSize = size;
    update();
    emit shapeSizeChanged();
}

void MaterialLoadingPaint::paint(QPainter *painter) {
    const qreal side = (std::min)({width(), height(), m_shapeSize});
    if (side <= 0 || !std::isfinite(side) || !m_color.isValid() || m_color.alpha() == 0)
        return;

    const qreal base = std::floor(m_phase);
    const auto index = static_cast<std::size_t>(std::fmod(base, 7));
    // Preserve spring overshoot, but finish exactly at the next shape at each boundary.
    const qreal shapeProgress = springValue(m_phase - base) / springValue(1);
    // Rotation has a longer period than the seven-shape sequence; do not wrap phase at seven.
    const qreal rotation = std::fmod(
        50 * std::fmod(m_phase, 36) + 90 * (std::fmod(base, 4) + shapeProgress), 360);
    const QPainterPath path = qavsi::material3::loading::loadingMorph(index).path(shapeProgress);

    painter->save();
    painter->setRenderHint(QPainter::Antialiasing, true);
    painter->setPen(Qt::NoPen);
    painter->setBrush(m_color);
    painter->translate(width() / 2, height() / 2);
    painter->rotate(rotation);
    painter->scale(side, side);
    painter->translate(-.5, -.5);
    painter->drawPath(path);
    painter->restore();
}
