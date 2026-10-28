// Copyright (c) 2024-2025 hypengw
// SPDX-License-Identifier: MIT AND Apache-2.0
// Adapted from QmlMaterial 0.6.1 (1912605). See THIRD_PARTY_NOTICES.md.
#pragma once
#include <QColor>
#include <QPainterPath>
#include <QSizeF>
#include <QTransform>
#include <utility>
#include <vector>
namespace qavsi::material3::progress {
struct Cubic {
    QPointF anchor0, control0, control1, anchor1;
    QPointF point(qreal t) const;
    std::pair<Cubic, Cubic> split(qreal t) const;
};


class MeasuredPath {
public:
    struct Location {
        QPointF point;
        QPointF tangent;
    };
    explicit MeasuredPath(std::vector<Cubic> curves = {}, qreal tolerance = 0.001);
    qreal        length() const { return m_length; }
    Location     location(qreal distance) const;
    QPainterPath segment(qreal start, qreal end) const;
    // Input is a continuous closed contour; extent is limited to one lap.
    QPainterPath cyclicSegment(qreal start, qreal extent) const;

private:
    struct Sample {
        qreal t;
        qreal distance;
    };
    struct Entry {
        Cubic               curve;
        qreal               start;
        qreal               length;
        std::vector<Sample> samples;
    };
    qreal              parameter(const Entry& entry, qreal distance) const;
    std::vector<Entry> m_entries;
    qreal              m_length = 0;
};


struct ProgressSegment {
    qreal  start = 0;
    qreal  end   = 0;
    QColor color;
    qreal  gapSize      = 0;
};

struct ProgressIndicatorState {
    bool                         circular          = false;
    bool                         indeterminate     = false;
    bool                         wavy              = false;
    bool                         mirrored          = false;
    bool                         legacyRadius      = false;
    qreal                        position          = 0;
    qreal                        phase             = 0;
    qreal                        amplitudeFraction = 1;
    qreal                        rotation          = 0;
    qreal                        startAngle        = -90;
    qreal                        strokeWidth       = 4;
    qreal                        waveLength        = 40;
    qreal                        waveAmplitude     = 3;
    qreal                        gapSize           = 4;
    qreal                        gapAngle          = -1;
    QColor                       trackColor;
    QColor                       stopColor;
    qreal                        stopDiameter = 4;
    std::vector<ProgressSegment> segments;
};

struct ProgressDrawPath {
    QPainterPath path;
    QColor       color;
    qreal        strokeWidth = 0;
};

class ProgressIndicatorGeometry {
public:
    // The result is retained until the next render on this instance.
    const std::vector<ProgressDrawPath>& render(const ProgressIndicatorState& state, QSizeF size);

private:
    void                          rebuild(const ProgressIndicatorState& state, QSizeF size);
    QSizeF                        m_size;
    bool                          m_circular         = false;
    bool                          m_wavy             = false;
    bool                          m_legacyRadius     = false;
    qreal                         m_stroke           = -1;
    qreal                         m_wavelength       = -1;
    qreal                         m_amplitude        = -1;
    qreal                         m_radius           = 0;
    qreal                         m_actualWavelength = 0;
    int                           m_cycles           = 0;
    MeasuredPath                  m_wave;
    MeasuredPath                  m_circle;
    std::vector<ProgressDrawPath> m_result;
};
}
