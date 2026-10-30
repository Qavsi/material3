// Copyright (c) 2024-2026 hypengw, Enes Alp
// SPDX-License-Identifier: MIT
// Adapted from QmlMaterial 0.6.1 (1912605); see THIRD_PARTY_NOTICES.md.
#include "material3spring.h"
#include <QAbstractAnimation>
#include <QPointer>
#include <algorithm>
#include <cmath>
#include <limits>

namespace {
struct SpringSample { qreal value, velocity; };
SpringSample sampleSpring(qreal stiffness, qreal damping, qreal from, qreal to,
                          qreal velocity, qreal seconds)
{
    if (seconds <= 0) return {from, velocity};
    const qreal w = std::sqrt(stiffness), z = damping;
    const qreal x = from - to, t = std::max(qreal(0), seconds), r = -z * w;
    if (std::abs(z - 1) < 1e-7) {
        const qreal b = velocity + w * x, e = std::exp(-w * t);
        return {to + (x + b * t) * e, (b - w * (x + b * t)) * e};
    }
    if (z < 1) {
        const qreal d = w * std::sqrt(1 - z * z), b = (velocity - r * x) / d;
        const qreal c = std::cos(d * t), s = std::sin(d * t), e = std::exp(r * t);
        const qreal p = e * (x * c + b * s);
        return {to + p, r * p + e * d * (b * c - x * s)};
    }
    const qreal d = std::sqrt(z * z - 1);
    const qreal slow = -w / (z + d), fast = -w * (z + d);
    const qreal a = (velocity - fast * x) / (slow - fast), b = x - a;
    const qreal p = a * std::exp(slow * t), q = b * std::exp(fast * t);
    return {to + p + q, slow * p + fast * q};
}
int springDuration(qreal stiffness, qreal damping, qreal from, qreal to,
                   qreal velocity, qreal threshold)
{
    if (from == to && velocity == 0) return 0;
    const qreal w = std::sqrt(stiffness), z = damping, x = from - to;
    qreal seconds = 0;
    if (z < 1 - 1e-7) {
        const qreal d = w * std::sqrt(1 - z * z);
        const qreal amplitude = std::hypot(x, (velocity + z * w * x) / d);
        seconds = std::max(qreal(0), std::log(amplitude / threshold) / (z * w));
    } else {
        qreal extremum = 0;
        if (std::abs(z - 1) < 1e-7) {
            const qreal b = velocity + w * x;
            if (b != 0) extremum = velocity / (w * b);
        } else {
            const qreal d = std::sqrt(z * z - 1), slow = -w / (z + d), fast = -w * (z + d);
            const qreal a = (velocity - fast * x) / (slow - fast), b = x - a;
            const qreal ratio = -b * fast / (a * slow);
            if (ratio > 0) extremum = std::log(ratio) / (slow - fast);
        }
        qreal low = std::max(qreal(0), extremum);
        const auto displacement = [&](qreal t) {
            return std::abs(sampleSpring(stiffness, damping, from, to, velocity, t).value - to);
        };
        if (displacement(low) <= threshold) low = 0;
        if (displacement(low) > threshold) {
            qreal high = std::max(low + .001, .01);
            while (displacement(high) > threshold && high < 2e6) high *= 2;
            for (int i = 0; i < 64; ++i) {
                const qreal middle = (low + high) / 2;
                if (displacement(middle) > threshold) low = middle;
                else high = middle;
            }
            seconds = high;
        }
    }
    return int(std::clamp(std::ceil(seconds * 1000), qreal(0),
                          qreal(std::numeric_limits<int>::max() - 1)));
}
bool validSpec(qreal stiffness, qreal damping)
{
    return std::isfinite(stiffness) && stiffness > 0 && std::isfinite(damping) && damping > 0
        && std::isfinite(damping * damping) && std::isfinite(2 * damping * std::sqrt(stiffness));
}
} // namespace

class Material3SpringClock : public QAbstractAnimation
{
public:
    explicit Material3SpringClock(Material3SpringBase *owner) : QAbstractAnimation(owner), m_owner(owner) { }
    int duration() const override { return length; }
    void retire()
    {
        m_owner.clear();
        setParent(nullptr);
        stop();
        deleteLater();
    }
    int length = 0;
private:
    void updateCurrentTime(int time) override { if (m_owner) m_owner->tick(time); }
    QPointer<Material3SpringBase> m_owner;
};

Material3SpringBase::Material3SpringBase(int dimensions, QObject *parent)
    : QObject(parent), m_dimensions(dimensions), m_clock(std::make_unique<Material3SpringClock>(this)) { }
Material3SpringBase::~Material3SpringBase()
{
    // Qt still accesses the clock after a synchronous valueChanged deletes its owner.
    m_clock.release()->retire();
}
void Material3SpringBase::classBegin() { m_complete = false; }
void Material3SpringBase::componentComplete() { m_complete = true; }
qreal Material3SpringBase::target(int i) const { return m_tracks[i].target; }
qreal Material3SpringBase::value(int i) const { return m_tracks[i].current.value; }
qreal Material3SpringBase::velocity(int i) const { return m_tracks[i].current.velocity; }
int Material3SpringBase::elapsed() const { return m_clock->currentTime(); }
qreal Material3SpringBase::displacementThreshold(int) const { return m_threshold; }

void Material3SpringBase::setTargets(const std::array<qreal, 4> &targets, bool snap, bool preserveVelocity)
{
    bool changed = false;
    for (int i = 0; i < m_dimensions; ++i) {
        if (!std::isfinite(targets[i])) return;
        changed |= targets[i] != m_tracks[i].target;
    }
    if (!changed && !snap) return;
    const auto revision = ++m_revision;
    for (int i = 0; i < m_dimensions; ++i) {
        m_tracks[i].target = targets[i];
        if (!preserveVelocity) m_tracks[i].current.velocity = 0;
    }
    QPointer<Material3SpringBase> guard(this);
    if (snap || !m_enabled || !m_complete) settle();
    else restart();
    if (guard && revision == m_revision && changed) Q_EMIT targetChanged();
}
void Material3SpringBase::setStiffness(qreal value)
{
    if (!validSpec(value, m_dampingRatio) || value == m_stiffness) return;
    m_stiffness = value;
    const auto revision = ++m_revision;
    QPointer<Material3SpringBase> guard(this);
    if (m_running) restart();
    if (guard && revision == m_revision) Q_EMIT specChanged();
}
void Material3SpringBase::setDampingRatio(qreal value)
{
    if (!validSpec(m_stiffness, value) || value == m_dampingRatio) return;
    m_dampingRatio = value;
    const auto revision = ++m_revision;
    QPointer<Material3SpringBase> guard(this);
    if (m_running) restart();
    if (guard && revision == m_revision) Q_EMIT specChanged();
}
void Material3SpringBase::setVisibilityThreshold(qreal value)
{
    if (!std::isfinite(value) || value <= 0 || value == m_threshold) return;
    m_threshold = value;
    const auto revision = ++m_revision;
    QPointer<Material3SpringBase> guard(this);
    if (m_running) restart();
    if (guard && revision == m_revision) Q_EMIT visibilityThresholdChanged();
}
void Material3SpringBase::setEnabled(bool value)
{
    if (value == m_enabled) return;
    m_enabled = value;
    const auto revision = ++m_revision;
    QPointer<Material3SpringBase> guard(this);
    if (!value) settle();
    if (guard && revision == m_revision) Q_EMIT enabledChanged();
}
void Material3SpringBase::restart()
{
    m_clock->stop();
    int duration = 0;
    for (int i = 0; i < m_dimensions; ++i) {
        auto &track = m_tracks[i];
        track.from = track.current.value;
        track.initialVelocity = track.current.velocity;
        track.duration = springDuration(m_stiffness, m_dampingRatio, track.from,
            track.target, track.initialVelocity, displacementThreshold(i));
        duration = std::max(duration, track.duration);
    }
    if (duration == 0) { settle(); return; }
    const bool wasRunning = m_running;
    m_running = true;
    m_clock->length = duration;
    const auto revision = m_revision;
    QPointer<Material3SpringBase> guard(this);
    m_clock->start();
    if (guard && revision == m_revision && !wasRunning) Q_EMIT runningChanged();
}
void Material3SpringBase::tick(int time)
{
    if (!m_running || time == 0) return;
    if (time >= m_clock->length) { settle(); return; }
    bool changed = false;
    for (int i = 0; i < m_dimensions; ++i) {
        auto &track = m_tracks[i];
        const auto next = time >= track.duration ? SpringSample{track.target, 0}
            : sampleSpring(m_stiffness, m_dampingRatio, track.from, track.target,
                           track.initialVelocity, time / 1000.0);
        changed |= next.value != track.current.value || next.velocity != track.current.velocity;
        track.current = {next.value, next.velocity};
    }
    if (changed) Q_EMIT valueChanged();
}
void Material3SpringBase::settle()
{
    const bool wasRunning = m_running;
    m_running = false;
    m_clock->stop();
    bool changed = false;
    for (int i = 0; i < m_dimensions; ++i) {
        auto &track = m_tracks[i];
        changed |= track.current.value != track.target || track.current.velocity != 0;
        track.current = {track.target, 0};
    }
    const auto revision = m_revision;
    QPointer<Material3SpringBase> guard(this);
    if (changed) Q_EMIT valueChanged();
    if (guard && revision == m_revision && wasRunning) Q_EMIT runningChanged();
}
void Material3SpringBase::complete() { ++m_revision; settle(); }

Material3Spring::Material3Spring(QObject *parent) : Material3SpringBase(1, parent) { }
Material3CornerSpring::Material3CornerSpring(QObject *parent) : Material3SpringBase(4, parent) { }
qreal Material3CornerSpring::displacementThreshold(int i) const
{
    return std::max(qreal(1e-9), std::abs(target(i) - m_start[i]) * visibilityThreshold());
}
QVector4D Material3CornerSpring::targetCorners() const
{
    return QVector4D(target(0), target(1), target(2), target(3));
}
QVector4D Material3CornerSpring::corners() const
{
    return QVector4D(std::max(qreal(0), value(0)), std::max(qreal(0), value(1)),
                     std::max(qreal(0), value(2)), std::max(qreal(0), value(3)));
}
void Material3CornerSpring::setTargetCorners(const QVector4D &value)
{
    for (int i = 0; i < 4; ++i) if (!std::isfinite(value[i])) return;
    if (value == targetCorners()) return;
    const bool reversing = value == m_start;
    m_start = reversing ? targetCorners() : corners();
    setTargets({value[0], value[1], value[2], value[3]}, false, reversing);
}
