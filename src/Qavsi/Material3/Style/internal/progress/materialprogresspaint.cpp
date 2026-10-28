// Copyright (c) 2026 Enes Alp
// Copyright (c) 2024-2025 hypengw (hypengwip@gmail.com)
// Copyright (C) 2020 The Android Open Source Project
// SPDX-License-Identifier: MIT AND Apache-2.0
// Motion/geometry adapted from QmlMaterial 0.6.1 (1912605), MIT, and AOSP, Apache-2.0.
// See THIRD_PARTY_NOTICES.md. No QCM runtime is linked.
#include "materialprogresspaint.h"

#include <QEasingCurve>
#include <QPainter>
#include <QPainterPath>
#include <algorithm>
#include <array>
#include <cmath>
#include <numbers>

namespace {
QEasingCurve curve(QPointF first, QPointF second)
{
    QEasingCurve result(QEasingCurve::BezierSpline);
    result.addCubicBezierSegment(first, second, {1, 1});
    return result;
}
qreal fraction(qreal time, qreal start, qreal duration)
{
    return std::clamp((time - start) / duration, 0.0, 1.0);
}
qreal ramp(qreal value) { return std::clamp(value / 0.01, 0.0, 1.0); }
}

MaterialProgressPaint::MaterialProgressPaint(QQuickItem *parent) : QQuickPaintedItem(parent)
{
    setAntialiasing(true);
    connect(this, &MaterialProgressPaint::appearanceChanged, this, [this] { update(); });
}

void MaterialProgressPaint::paint(QPainter *painter)
{
    if (width() <= 0 || height() <= 0 || !std::isfinite(m_position) || !std::isfinite(m_phase)
        || !std::isfinite(m_thickness) || m_thickness <= 0 || !std::isfinite(m_gap)
        || m_gap < 0 || !std::isfinite(m_gapAngle) || m_gapAngle < 0
        || !std::isfinite(m_stopDiameter) || m_stopDiameter < 0)
        return;
    painter->setRenderHint(QPainter::Antialiasing);
    if (m_mirrored) {
        painter->translate(width(), 0);
        painter->scale(-1, 1);
    }
    const qreal position = std::clamp(m_position, 0.0, 1.0);
    const qreal phase = m_phase - std::floor(m_phase);
    const qreal stroke = std::min(m_thickness, height());
    if (!m_circular) {
        const auto line = [&](qreal start, qreal end, const QColor &color) {
            if (end <= start || color.alpha() == 0)
                return;
            painter->setBrush(color);
            painter->setPen(Qt::NoPen);
            const qreal diameter = std::min(stroke, end - start);
            painter->drawRoundedRect(QRectF(start, (height() - diameter) / 2, end - start, diameter),
                                     diameter / 2, diameter / 2);
        };
        std::array<QPointF, 2> segments = {{{0, position}, {0, 0}}};
        if (m_indeterminate) {
            static const std::array<QEasingCurve, 4> curves = {
                curve({0.2, 0}, {0.8, 1}), curve({0.4, 0}, {1, 1}),
                curve({0, 0}, {0.65, 1}), curve({0.1, 0}, {0.45, 1})};
            constexpr std::array<int, 4> delays = {1267, 1000, 333, 0};
            constexpr std::array<int, 4> durations = {533, 567, 850, 750};
            for (int i = 0; i < 2; ++i)
                segments[i] = {curves[i * 2].valueForProgress(fraction(phase * 1800, delays[i * 2], durations[i * 2])),
                               curves[i * 2 + 1].valueForProgress(fraction(phase * 1800, delays[i * 2 + 1], durations[i * 2 + 1]))};
        }
        std::sort(segments.begin(), segments.end(), [](QPointF a, QPointF b) { return a.x() < b.x(); });
        qreal previous = 0;
        for (const QPointF segment : segments) {
            if (segment.y() <= segment.x())
                continue;
            line(previous * width() + (previous > 0 ? m_gap * ramp(1 - previous) : 0),
                 segment.x() * width() - m_gap * ramp(segment.x()), m_trackColor);
            line(segment.x() * width(), segment.y() * width(), m_color);
            previous = segment.y();
        }
        line(previous * width() + (previous > 0 ? m_gap * ramp(1 - previous) : 0), width(), m_trackColor);
        if (!m_indeterminate && position < 1) {
            const qreal diameter = std::min({m_stopDiameter, width(), height()});
            painter->setPen(Qt::NoPen);
            painter->setBrush(m_color);
            painter->drawEllipse(QRectF(width() - diameter, (height() - diameter) / 2, diameter, diameter));
        }
        return;
    }
    const qreal radius = std::max(0.0, std::min(width(), height()) / 2 - stroke);
    if (radius <= 0)
        return;
    const QRectF bounds(width() / 2 - radius, height() / 2 - radius, radius * 2, radius * 2);
    const auto arc = [&](qreal start, qreal extent, const QColor &color) {
        extent = std::clamp(extent, 0.0, 1.0);
        if (extent <= 0 || color.alpha() == 0)
            return;
        const qreal cap = extent >= 1 ? 0 : stroke / (2 * std::numbers::pi * radius) / 2;
        if (extent <= 2 * cap) {
            const qreal angle = (-90 + (start + extent / 2) * 360) * std::numbers::pi / 180;
            const QPointF center(width() / 2 + std::cos(angle) * radius, height() / 2 + std::sin(angle) * radius);
            const qreal diameter = extent * 2 * std::numbers::pi * radius;
            painter->setPen(Qt::NoPen);
            painter->setBrush(color);
            painter->drawEllipse(center, diameter / 2, diameter / 2);
            return;
        }
        QPainterPath path;
        const qreal angle = 90 - (start + cap) * 360;
        path.arcMoveTo(bounds, angle);
        path.arcTo(bounds, angle, -(extent - 2 * cap) * 360);
        if (extent >= 1)
            path.closeSubpath();
        painter->setBrush(Qt::NoBrush);
        painter->setPen(QPen(color, stroke, Qt::SolidLine, Qt::RoundCap, Qt::RoundJoin));
        painter->drawPath(path);
    };
    qreal start = 0;
    qreal end = position < 1 ? std::max(0.0, position - 2 * m_gapAngle / 360) : 1;
    if (m_indeterminate) {
        static const auto easing = curve({0.4, 0}, {0.2, 1});
        const qreal time = phase * 5400;
        start = phase * 1520 - 20;
        end = phase * 1520;
        for (int i = 0; i < 4; ++i) {
            end += 250 * easing.valueForProgress(fraction(time, i * 1350, 667));
            start += 250 * easing.valueForProgress(fraction(time, i * 1350 + 667, 667));
        }
        start /= 360;
        end /= 360;
        const qreal gap = m_gapAngle / 360 * ramp(end - start) * ramp(1 - (end - start));
        arc(end + gap, std::max(0.0, 1 - (end - start) - 2 * gap), m_trackColor);
    } else if (position < 1) {
        arc(end + m_gapAngle / 360, 1 - position, m_trackColor);
    }
    arc(start, end - start, m_color);
}
