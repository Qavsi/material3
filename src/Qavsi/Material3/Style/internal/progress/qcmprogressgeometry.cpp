// Copyright (c) 2024-2025 hypengw
// Copyright (C) 2020 The Android Open Source Project
// SPDX-License-Identifier: MIT AND Apache-2.0
// Adapted from QmlMaterial 0.6.1 (1912605). See THIRD_PARTY_NOTICES.md.
#include "qcmprogressgeometry.h"
#include <QLineF>
#include <algorithm>
#include <cmath>
#include <functional>
#include <numbers>
namespace qavsi::material3::progress {
namespace { QPointF lerp(QPointF a, QPointF b, qreal t) { return a + (b - a) * t; } }
QPointF Cubic::point(qreal t) const {
    const auto u = 1 - t;
    return anchor0 * (u * u * u) + control0 * (3 * t * u * u) + control1 * (3 * t * t * u) +
           anchor1 * (t * t * t);
}
std::pair<Cubic, Cubic> Cubic::split(qreal t) const {
    const auto a = lerp(anchor0, control0, t), b = lerp(control0, control1, t),
               c = lerp(control1, anchor1, t);
    const auto d = lerp(a, b, t), e = lerp(b, c, t), p = lerp(d, e, t);
    return { { anchor0, a, d, p }, { p, e, c, anchor1 } };
}
}
namespace qavsi::material3::progress
{
namespace
{
qreal distance(QPointF a, QPointF b) { return QLineF(a, b).length(); }
bool  finite(QPointF p) { return std::isfinite(p.x()) && std::isfinite(p.y()); }
} // namespace

MeasuredPath::MeasuredPath(std::vector<Cubic> curves, qreal tolerance) {
    tolerance = std::isfinite(tolerance) ? std::max(0.00001, tolerance) : 0.001;
    for (const auto& curve : curves) {
        if (! finite(curve.anchor0) || ! finite(curve.control0) || ! finite(curve.control1) ||
            ! finite(curve.anchor1))
            continue;
        Entry entry { curve, m_length, 0, { { 0, 0 } } };
        std::function<void(const Cubic&, qreal, qreal, int)> measure;
        measure = [&](const Cubic& c, qreal a, qreal b, int depth) {
            const auto chord   = distance(c.anchor0, c.anchor1);
            const auto polygon = distance(c.anchor0, c.control0) +
                                 distance(c.control0, c.control1) + distance(c.control1, c.anchor1);
            // Also bound the inverse parameter lookup for collinear, nonuniform cubics.
            const auto midpointError =
                std::max(distance(c.control0, (2 * c.anchor0 + c.anchor1) / 3),
                         distance(c.control1, (c.anchor0 + 2 * c.anchor1) / 3));
            if (depth < 20 &&
                (polygon - chord > tolerance * (b - a) || midpointError > tolerance)) {
                const auto halves = c.split(0.5);
                measure(halves.first, a, (a + b) / 2, depth + 1);
                measure(halves.second, (a + b) / 2, b, depth + 1);
            } else {
                entry.length += (chord + polygon) / 2;
                entry.samples.push_back({ b, entry.length });
            }
        };
        measure(curve, 0, 1, 0);
        if (entry.length > 0) {
            m_length += entry.length;
            m_entries.push_back(std::move(entry));
        }
    }
}

qreal MeasuredPath::parameter(const Entry& entry, qreal d) const {
    d       = std::clamp(d, qreal(0), entry.length);
    auto it = std::lower_bound(
        entry.samples.begin(), entry.samples.end(), d, [](const Sample& s, qreal value) {
            return s.distance < value;
        });
    if (it == entry.samples.begin()) return 0;
    if (it == entry.samples.end()) return 1;
    const auto& prev = *(it - 1);
    const auto  span = it->distance - prev.distance;
    return span > 0 ? std::lerp(prev.t, it->t, (d - prev.distance) / span) : it->t;
}

MeasuredPath::Location MeasuredPath::location(qreal d) const {
    if (m_entries.empty() || ! std::isfinite(d)) return {};
    d = std::clamp(d, qreal(0), m_length);
    auto it =
        std::lower_bound(m_entries.begin(), m_entries.end(), d, [](const Entry& e, qreal value) {
            return e.start + e.length < value;
        });
    if (it == m_entries.end()) it = m_entries.end() - 1;
    const auto  t = parameter(*it, d - it->start);
    const auto& c = it->curve;
    auto        tangent =
        3 * ((1 - t) * (1 - t) * (c.control0 - c.anchor0) +
             2 * (1 - t) * t * (c.control1 - c.control0) + t * t * (c.anchor1 - c.control1));
    auto norm = std::hypot(tangent.x(), tangent.y());
    if (norm < 1e-12) {
        tangent = c.point(std::min(1.0, t + 0.0001)) - c.point(std::max(0.0, t - 0.0001));
        norm    = std::hypot(tangent.x(), tangent.y());
    }
    return { c.point(t), norm > 0 ? tangent / norm : QPointF {} };
}

QPainterPath MeasuredPath::segment(qreal start, qreal end) const {
    QPainterPath path;
    if (! std::isfinite(start) || ! std::isfinite(end)) return path;
    start = std::clamp(start, qreal(0), m_length);
    end   = std::clamp(end, qreal(0), m_length);
    if (end <= start) return path;
    auto first = std::lower_bound(
        m_entries.begin(), m_entries.end(), start, [](const Entry& entry, qreal value) {
            return entry.start + entry.length <= value;
        });
    for (auto it = first; it != m_entries.end(); ++it) {
        const auto& entry = *it;
        if (entry.start >= end) break;
        const auto a = parameter(entry, start - entry.start);
        const auto b = parameter(entry, end - entry.start);
        if (b <= a) continue;
        auto curve = entry.curve;
        if (b < 1) curve = curve.split(b).first;
        if (a > 0) curve = curve.split(a / b).second;
        if (path.isEmpty()) path.moveTo(curve.anchor0);
        path.cubicTo(curve.control0, curve.control1, curve.anchor1);
    }
    return path;
}

QPainterPath MeasuredPath::cyclicSegment(qreal start, qreal extent) const {
    if (m_length <= 0 || ! std::isfinite(start) || ! std::isfinite(extent) || extent <= 0)
        return {};
    start = std::fmod(start, m_length);
    if (start < 0) start += m_length;
    extent    = std::min(extent, m_length);
    auto path = segment(start, std::min(m_length, start + extent));
    if (start + extent > m_length) path.connectPath(segment(0, start + extent - m_length));
    return path;
}
} // namespace qavsi::material3::progress
namespace qavsi::material3::progress
{
namespace
{
constexpr qreal    tau = 2 * std::numbers::pi;
std::vector<Cubic> circle(qreal radius) {
    constexpr qreal    k = 0.5522847498307936;
    std::vector<Cubic> curves;
    for (int i = 0; i < 8; ++i) {
        const auto a = i * tau / 4;
        const auto b = (i + 1) * tau / 4;
        QPointF    p(std::cos(a) * radius, std::sin(a) * radius);
        QPointF    q(std::cos(b) * radius, std::sin(b) * radius);
        QPointF    t(-std::sin(a) * radius * k, std::cos(a) * radius * k);
        QPointF    u(-std::sin(b) * radius * k, std::cos(b) * radius * k);
        curves.push_back({ p, p + t, q - u, q });
    }
    return curves;
}
qreal ramp(qreal p) { return std::clamp(p / 0.01, 0.0, 1.0); }
qreal unit(qreal p) { return std::isfinite(p) ? std::clamp(p, 0.0, 1.0) : 0; }
} // namespace

void ProgressIndicatorGeometry::rebuild(const ProgressIndicatorState& s, QSizeF size) {
    const auto amplitude =
        s.circular ? s.wavy ? std::max(0.0, s.waveAmplitude * s.amplitudeFraction) : 0.0 : 1.0;
    if (m_size == size && m_circular == s.circular && m_wavy == s.wavy &&
        m_stroke == s.strokeWidth && m_wavelength == s.waveLength && m_amplitude == amplitude &&
        m_legacyRadius == s.legacyRadius)
        return;
    const auto oldCircular = m_circular;
    const auto oldRadius   = m_radius;
    m_size                 = size;
    m_circular             = s.circular;
    m_wavy                 = s.wavy;
    m_legacyRadius         = s.legacyRadius;
    m_stroke               = s.strokeWidth;
    m_wavelength           = s.waveLength;
    m_amplitude            = amplitude;
    m_radius = std::max(0.0,
                        (std::min(size.width(), size.height()) -
                         (s.legacyRadius ? 0 : s.strokeWidth)) /
                            2);
    if (s.circular && (! oldCircular || oldRadius != m_radius))
        m_circle = MeasuredPath(circle(m_radius));
    else if (! s.circular)
        m_circle = MeasuredPath {};
    const auto length = s.circular ? m_circle.length() / 2 : size.width();
    // Cap pathological configuration costs while preserving ordinary token sizes.
    m_cycles           = s.wavy && s.waveLength > 0
                             ? std::clamp(int(std::min(4096.0, std::floor(length / s.waveLength))),
                                          s.circular ? 3 : 1,
                                          4096)
                             : 0;
    m_actualWavelength = m_cycles ? length / m_cycles : 0;
    std::vector<Cubic> curves;
    if (m_cycles && length > 0) {
        if (! s.circular) {
            const auto half = m_actualWavelength / 2;
            for (int i = 0; i < 2 * (m_cycles + 1); ++i) {
                const auto x = i * half;
                const auto y = i % 2 ? -1.0 : 1.0;
                curves.push_back({ { x, y },
                                   { x + half * 0.48, y },
                                   { x + half * 0.52, -y },
                                   { x + half, -y } });
            }
        } else {
            const auto halfLength = m_circle.length() / (4 * m_cycles);
            for (int i = 0; i < 4 * m_cycles; ++i) {
                auto       a      = m_circle.location(i * halfLength);
                auto       b      = m_circle.location((i + 1) * halfLength);
                const auto inward = [amplitude](QPointF p) {
                    const auto norm = std::hypot(p.x(), p.y());
                    return norm > 0 ? p * std::max(0.0, 1 - 2 * amplitude / norm) : p;
                };
                if (i % 2)
                    a.point = inward(a.point);
                else
                    b.point = inward(b.point);
                const auto control = m_actualWavelength * 0.24;
                curves.push_back({ a.point,
                                   a.point + a.tangent * control,
                                   b.point - b.tangent * control,
                                   b.point });
            }
        }
    }
    m_wave = MeasuredPath(std::move(curves));
}

const std::vector<ProgressDrawPath>&
ProgressIndicatorGeometry::render(const ProgressIndicatorState& s, QSizeF size) {
    auto& result = m_result;
    result.clear();
    if (! std::isfinite(size.width()) || ! std::isfinite(size.height()) || size.width() <= 0 ||
        size.height() <= 0 || ! std::isfinite(s.strokeWidth) || s.strokeWidth <= 0 ||
        ! std::isfinite(s.waveLength) || ! std::isfinite(s.waveAmplitude) ||
        ! std::isfinite(s.phase) || ! std::isfinite(s.amplitudeFraction) || s.waveLength < 0 ||
        s.waveAmplitude < 0 || ! std::isfinite(s.startAngle) || ! std::isfinite(s.rotation) ||
        ! std::isfinite(s.gapSize) || ! std::isfinite(s.gapAngle) ||
        ! std::isfinite(s.stopDiameter) || s.stopDiameter < 0)
        return result;
    rebuild(s, size);
    const auto stroke = s.strokeWidth;
    const bool wave   = s.wavy && s.waveLength > 0 && s.waveAmplitude > 0 &&
                        s.amplitudeFraction > 0 && m_wave.length() > 0;
    QTransform mirror;
    if (s.mirrored) {
        mirror.translate(size.width(), 0);
        mirror.scale(-1, 1);
    }
    auto append = [&](QPainterPath p, QColor color, qreal width) {
        if (! p.isEmpty()) result.push_back({ mirror.map(p), color, width });
    };
    if (! s.circular) {
        const auto w    = size.width();
        const auto y    = size.height() / 2;
        auto       line = [&](qreal a, qreal b, QColor color) {
            if (b <= a) return;
            if (b - a < stroke) {
                QPainterPath p;
                const auto   diameter = b - a;
                p.addEllipse(QPointF((a + b) / 2, y), diameter / 2, diameter / 2);
                append(p, color, 0);
                return;
            }
            QPainterPath p;
            p.moveTo(a + stroke / 2, y);
            p.lineTo(b - stroke / 2, y);
            append(p, color, stroke);
        };
        auto segments = s.segments;
        std::erase_if(segments, [](const auto& segment) {
            return ! std::isfinite(segment.start) || ! std::isfinite(segment.end);
        });
        std::sort(segments.begin(), segments.end(), [](const auto& a, const auto& b) {
            return a.start < b.start;
        });
        qreal previous    = 0;
        qreal previousGap = 0;
        for (const auto& segment : segments) {
            const auto a        = unit(segment.start);
            const auto b        = unit(segment.end);
            const auto gap = std::max(0.0, s.gapSize);
            line(previous * w + (previous > 0 ? previousGap * ramp(1 - previous) : 0),
                 a * w - gap * ramp(a),
                 s.trackColor);
            previous    = std::max(previous, b);
            previousGap = gap;
            if (b <= a) continue;
            const auto activeGap = std::max(0.0, segment.gapSize);
            const auto activeStart = a * w + activeGap * ramp(a);
            const auto activeEnd = b * w - activeGap * ramp(1 - b);
            const auto x0 = activeStart + stroke / 2;
            const auto x1 = activeEnd - stroke / 2;
            if (! wave || x1 <= x0) {
                if (wave && activeEnd > activeStart && activeEnd - activeStart < stroke) {
                    const auto phase    = s.phase - std::floor(s.phase);
                    const auto fraction = ((activeStart + activeEnd) / 2 / w + phase / m_cycles) *
                                          qreal(m_cycles) / (m_cycles + 1);
                    auto       center   = m_wave.location(fraction * m_wave.length()).point;
                    center.setX(center.x() - phase * m_actualWavelength);
                    center.setY(y + center.y() * s.waveAmplitude * s.amplitudeFraction);
                    QPainterPath p;
                    const auto   diameter = activeEnd - activeStart;
                    p.addEllipse(center, diameter / 2, diameter / 2);
                    append(p, segment.color, 0);
                } else
                    line(activeStart, activeEnd, segment.color);
                continue;
            }
            const auto phase  = s.phase - std::floor(s.phase);
            const auto offset = phase / m_cycles;
            const auto ratio  = qreal(m_cycles) / (m_cycles + 1);
            auto       path   = m_wave.segment((x0 / w + offset) * ratio * m_wave.length(),
                                               (x1 / w + offset) * ratio * m_wave.length());
            QTransform transform;
            transform.translate(-phase * m_actualWavelength, y);
            transform.scale(1, s.waveAmplitude * s.amplitudeFraction);
            append(transform.map(path), segment.color, stroke);
        }
        line(previous * w + (previous > 0 ? previousGap * ramp(1 - previous) : 0),
             w,
             s.trackColor);
        if (! s.indeterminate && s.position < 1) {
            const auto   d = std::min(s.stopDiameter, w);
            QPainterPath p;
            p.addEllipse(QPointF(w - d / 2, y), d / 2, d / 2);
            append(p, s.stopColor, 0);
        }
    } else {
        if (m_radius <= 0) return result;
        QTransform transform;
        transform.translate(size.width() / 2, size.height() / 2);
        transform.rotate(s.startAngle + s.rotation);
        const auto circumference = m_circle.length() / 2;
        auto       arc           = [&](qreal start, qreal extent, QColor color, bool active) {
            extent = std::clamp(extent, 0.0, 1.0);
            if (extent <= 0) return;
            const bool full = extent >= 1 - 1e-9;
            const auto cap  = full ? 0 : stroke / (tau * m_radius) / 2;
            if (extent <= 2 * cap) {
                const auto mid = start + extent / 2;
                auto center    = m_circle.location((mid - std::floor(mid)) * circumference).point;
                if (active && wave) {
                    const auto phase    = (s.phase - std::floor(s.phase)) / m_cycles;
                    const auto fraction = mid + phase - std::floor(mid + phase);
                    center              = m_wave.location(fraction * m_wave.length() / 2).point;
                    QTransform reverse;
                    reverse.rotate(-phase * 360);
                    center = reverse.map(center);
                }
                QPainterPath p;
                const auto   d = extent * tau * m_radius;
                p.addEllipse(center, d / 2, d / 2);
                append(transform.map(p), color, 0);
                return;
            }
            auto path = m_circle.cyclicSegment((start + cap) * circumference,
                                               (extent - 2 * cap) * circumference);
            if (active && wave) {
                const auto phase      = (s.phase - std::floor(s.phase)) / m_cycles;
                const auto waveCircle = m_wave.length() / 2;
                path                  = m_wave.cyclicSegment((start + cap + phase) * waveCircle,
                                                             (extent - 2 * cap) * waveCircle);
                QTransform reverse;
                reverse.rotate(-phase * 360);
                path = reverse.map(path);
            }
            if (full) path.closeSubpath();
            append(transform.map(path), color, stroke);
        };
        auto segments = s.segments;
        const bool legacyGap =
            ! s.indeterminate && s.gapAngle >= 0 && s.position < 1;
        if (legacyGap && ! segments.empty()) {
            segments.front().end = std::max(0.0, s.position - 2 * s.gapAngle / 360);
            arc(segments.front().end + s.gapAngle / 360,
                (1 - s.position),
                s.trackColor,
                false);
        } else if (! s.segments.empty()) {
            const auto& segment = s.segments.front();
            const auto  extent  = unit(segment.end - segment.start);
            const auto  gap =
                s.gapAngle >= 0 ? s.gapAngle / 360 : std::max(0.0, s.gapSize) / (tau * m_radius);
            const auto adjusted = gap * ramp(extent) * ramp(1 - extent);
            arc(segment.end + adjusted,
                std::max(0.0, 1 - extent - 2 * adjusted),
                s.trackColor,
                false);
        } else
            arc(0, 1, s.trackColor, false);
        for (const auto& segment : segments)
            arc(segment.start, unit(segment.end - segment.start), segment.color, true);
    }
    return result;
}
} // namespace qavsi::material3::progress
