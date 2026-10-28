// Copyright (c) 2026 Enes Alp
// Copyright (c) 2024-2025 hypengw
// Copyright (C) 2020 The Android Open Source Project
// SPDX-License-Identifier: MIT AND Apache-2.0
// QCM 0.6.1 (1912605) motion and lifecycle, adapted to a native StyleKit delegate.
#include "materialprogresspaint.h"
#include "qcmprogressgeometry.h"
#include <QEasingCurve>
#include <QPainter>
#include <algorithm>
#include <array>
#include <cmath>

namespace {
QEasingCurve curve(QPointF first, QPointF second) {
    QEasingCurve result(QEasingCurve::BezierSpline);
    result.addCubicBezierSegment(first, second, {1, 1});
    return result;
}
qreal fraction(qreal time, qreal start, qreal duration) {
    return std::clamp((time - start) / duration, 0.0, 1.0);
}
struct Transition {
    qreal value = 0, from = 0, target = 0, elapsed = 0, duration = 0;
    QEasingCurve easing = curve({0.2, 0}, {0, 1});
    bool active() const { return elapsed < duration; }
    void set(qreal next, qreal ms, QEasingCurve nextCurve = curve({0.2, 0}, {0, 1})) {
        if (target == next && ms > 0) return;
        from = value; target = next; elapsed = 0; duration = ms; easing = nextCurve;
        if (ms <= 0) value = next;
    }
    void advance(qreal ms) {
        if (!active()) return;
        elapsed = std::min(duration, elapsed + ms);
        value = std::lerp(from, target, easing.valueForProgress(elapsed / duration));
    }
};
}
struct MaterialProgressPaint::Motion {
    enum State { Stopped, Running, Completing } state = Stopped;
    bool initialized = false;
    int type = -1;
    Transition display, amplitude, opacity;
    qreal elapsed = 0, endElapsed = 0, endDuration = 0, endFrom = 0, wavePhase = 0;
    qavsi::material3::progress::ProgressIndicatorGeometry geometry;
};
MaterialProgressPaint::MaterialProgressPaint(QQuickItem *parent)
    : QQuickPaintedItem(parent), d(std::make_unique<Motion>()) {
    setAntialiasing(true);
    connect(this, &MaterialProgressPaint::appearanceChanged, this, &MaterialProgressPaint::synchronize);
}
MaterialProgressPaint::~MaterialProgressPaint() = default;
void MaterialProgressPaint::componentComplete() {
    QQuickPaintedItem::componentComplete();
    synchronize();
    d->initialized = true;
}
void MaterialProgressPaint::synchronize() {
    const bool animate = d->initialized && m_animationsEnabled;
    const qreal position = std::isfinite(m_position) ? std::clamp(m_position, 0.0, 1.0) : 0;
    d->display.set(position, animate ? m_valueDuration : 0);
    const qreal amplitude = m_wavy && m_waveLength > 0 && m_waveAmplitude > 0
        && (m_indeterminate || (position >= 0.1 && position <= 0.9)) ? 1 : 0;
    d->amplitude.set(amplitude, animate ? m_amplitudeDuration : 0,
        amplitude > d->amplitude.value ? curve({0.2, 0}, {0, 1}) : curve({0.3, 0}, {0.8, 0.2}));
    if (d->type != m_motionType) {
        d->type = m_motionType;
        d->elapsed = d->endElapsed = 0;
        if (d->state == Motion::Completing) d->state = Motion::Stopped;
    }
    if (!m_indeterminate) {
        d->state = Motion::Stopped;
        d->endElapsed = 0;
    } else if (m_running) {
        if (d->state != Motion::Running) d->elapsed = d->endElapsed = 0;
        d->state = Motion::Running;
    } else if (d->state == Motion::Running && animate) {
        d->state = Motion::Completing;
        d->endElapsed = 0;
        d->endFrom = d->elapsed / std::max(1, m_cycleDuration);
        // QCM finishes linear segments at the cycle boundary and collapses circular arcs.
        d->endDuration = m_circular ? (m_motionType == 0 ? 333 : 500)
            : m_cycleDuration * (1 - d->endFrom);
    } else if (!animate) d->state = Motion::Stopped;
    if (!m_animationsEnabled && m_indeterminate && m_running)
        d->elapsed = (m_circular ? m_motionType == 0 ? 0.125 : 0.25 : 0.75) * m_cycleDuration;
    d->opacity.set(m_indeterminate && d->state == Motion::Stopped ? 0 : 1,
                   animate ? m_opacityDuration : 0, QEasingCurve(QEasingCurve::Linear));
    update();
    emit frameChanged();
}
bool MaterialProgressPaint::animating() const {
    if (!m_animationsEnabled) return false;
    const bool wave = m_wavy && m_waveLength > 0 && m_waveAmplitude > 0 && m_waveCycleDuration > 0
        && (m_indeterminate ? d->state != Motion::Stopped : d->display.value > 0 && d->display.value < 1)
        && (d->amplitude.value > 0 || d->amplitude.target > 0);
    return d->display.active() || d->amplitude.active() || d->opacity.active()
        || (m_indeterminate && d->state != Motion::Stopped) || wave;
}
void MaterialProgressPaint::advanceAnimations(qreal ms) {
    if (!m_animationsEnabled || !std::isfinite(ms) || ms < 0) return;
    d->display.advance(ms); d->amplitude.advance(ms); d->opacity.advance(ms);
    const int duration = std::max(1, m_cycleDuration);
    if (m_indeterminate && d->state == Motion::Running)
        d->elapsed = std::fmod(d->elapsed + std::fmod(ms, duration), duration);
    else if (m_indeterminate && d->state == Motion::Completing) {
        const qreal consumed = std::min(ms, std::max(0.0, d->endDuration - d->endElapsed));
        d->endElapsed = std::min(d->endDuration, d->endElapsed + ms);
        const qreal progress = d->endDuration > 0 ? d->endElapsed / d->endDuration : 1;
        if (m_circular) d->elapsed += consumed;
        else d->elapsed = std::lerp(d->endFrom, 1.0, progress) * duration;
        if (progress >= 1) {
            d->state = Motion::Stopped;
            d->opacity.set(0, m_opacityDuration, QEasingCurve(QEasingCurve::Linear));
            d->opacity.advance(ms - consumed);
        }
    }
    if (m_wavy && m_waveLength > 0 && m_waveAmplitude > 0 && d->amplitude.value > 0
        && m_waveCycleDuration > 0
        && (m_indeterminate ? d->state != Motion::Stopped : d->display.value > 0 && d->display.value < 1))
        d->wavePhase = std::fmod(d->wavePhase + ms / m_waveCycleDuration, 1.0);
    update();
    emit frameChanged();
}
void MaterialProgressPaint::paint(QPainter *painter) {
    if (!std::isfinite(m_position) || !std::isfinite(m_thickness) || m_thickness <= 0
        || !std::isfinite(m_gap) || m_gap < 0
        || !std::isfinite(m_gapAngle) || m_gapAngle < 0) return;
    using namespace qavsi::material3::progress;
    ProgressIndicatorState state;
    state.circular = m_circular;
    state.legacyRadius = m_circular && !m_wavy;
    state.indeterminate = m_indeterminate;
    state.wavy = m_wavy;
    state.mirrored = m_mirrored;
    state.position = d->display.value;
    state.phase = d->wavePhase;
    state.amplitudeFraction = d->amplitude.value;
    state.strokeWidth = m_thickness;
    state.waveLength = m_waveLength;
    state.waveAmplitude = m_waveAmplitude;
    state.gapSize = m_gap;
    state.gapAngle = m_circular && !m_wavy ? m_gapAngle : -1;
    state.startAngle = m_circular ? -90 : 0;
    state.trackColor = m_trackColor;
    state.stopColor = m_color;
    state.stopDiameter = m_stopDiameter;
    if (!m_indeterminate) state.segments.push_back({0, d->display.value, m_color});
    else if (m_circular) {
        static const auto easing = curve({0.4, 0}, {0.2, 1});
        const qreal phase = std::fmod(d->elapsed, std::max(1, m_cycleDuration)) / std::max(1, m_cycleDuration);
        qreal start = 0, end = 0;
        if (m_motionType == 0) {
            const qreal time = phase * 5400;
            start = phase * 1520 - 20; end = phase * 1520;
            for (int i = 0; i < 4; ++i) {
                end += 250 * easing.valueForProgress(fraction(time, i * 1350, 667));
                start += 250 * easing.valueForProgress(fraction(time, i * 1350 + 667, 667));
            }
            start /= 360; end /= 360;
        } else {
            const qreal time = phase * 6000;
            state.rotation = phase * 1080;
            for (int delay : {0, 1500, 3000, 4500})
                state.rotation += 90 * easing.valueForProgress(fraction(time, delay, 500));
            end = std::lerp(0.10, 0.87,
                easing.valueForProgress(fraction(time, 0, 3000))
                - easing.valueForProgress(fraction(time, 3000, 3000)));
        }
        if (d->state == Motion::Completing || d->state == Motion::Stopped) {
            const qreal complete = d->endDuration > 0 ? d->endElapsed / d->endDuration : 0;
            if (m_motionType == 0) start += (end - start) * complete;
            else end *= 1 - complete;
        }
        state.segments.push_back({start, end, m_color});
    } else {
        const qreal phase = d->elapsed / std::max(1, m_cycleDuration);
        if (m_motionType == 1) {
            static const auto easing = curve({0.4, 0}, {0.2, 1});
            const qreal time = phase * 333;
            const qreal a = easing.valueForProgress(fraction(time, 0, 667));
            const qreal b = easing.valueForProgress(fraction(time, 0, 667) + 333.0 / 667);
            state.segments = {{0, a, m_color, m_gap / 2}, {a, b, m_color, m_gap / 2}, {b, 1, m_color, m_gap / 2}};
        } else {
            static const std::array<QEasingCurve, 4> curves = {
                curve({0.2, 0}, {0.8, 1}), curve({0.4, 0}, {1, 1}),
                curve({0, 0}, {0.65, 1}), curve({0.1, 0}, {0.45, 1})};
            constexpr std::array<int, 4> delays = {1267, 1000, 333, 0};
            constexpr std::array<int, 4> durations = {533, 567, 850, 750};
            for (int i = 0; i < 2; ++i)
                state.segments.push_back({curves[i * 2].valueForProgress(fraction(phase * 1800, delays[i * 2], durations[i * 2])),
                    curves[i * 2 + 1].valueForProgress(fraction(phase * 1800, delays[i * 2 + 1], durations[i * 2 + 1])), m_color});
        }
    }
    const qreal padding = m_circular && !m_wavy ? m_thickness : 0;
    const auto &paths = d->geometry.render(state, {width() - padding * 2, height() - padding * 2});
    painter->setRenderHint(QPainter::Antialiasing);
    painter->setOpacity(d->opacity.value);
    painter->translate(padding, padding);
    for (const auto &draw : paths) {
        painter->setBrush(draw.strokeWidth > 0 ? Qt::NoBrush : QBrush(draw.color));
        painter->setPen(draw.strokeWidth > 0 ? QPen(draw.color, draw.strokeWidth, Qt::SolidLine, Qt::RoundCap, Qt::RoundJoin) : Qt::NoPen);
        painter->drawPath(draw.path);
    }
}
