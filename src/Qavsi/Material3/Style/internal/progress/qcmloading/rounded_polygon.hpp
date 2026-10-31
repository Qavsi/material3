// Copyright (c) 2024-2025 hypengw (hypengwip@gmail.com)
// SPDX-License-Identifier: MIT
// Ported from QmlMaterial 0.6.1, 191260585a829ee4ae2c99e6232b7145b5c34474.
// Adaptation: private namespace/local includes; no QmlMaterial export dependency.
#pragma once

#include <QtGui/QPainterPath>
#include <QtGui/QTransform>
#include <vector>
#include <utility>

namespace qavsi::material3::loading
{

struct CornerRounding {
    qreal radius    = 0;
    qreal smoothing = 0;
};

struct Cubic {
    QPointF                 anchor0, control0, control1, anchor1;
    QPointF                 point(qreal t) const;
    std::pair<Cubic, Cubic> split(qreal t) const;
    Cubic                   reversed() const;
    Cubic                   transformed(const QTransform& transform) const;
    static Cubic            line(QPointF from, QPointF to);
    static Cubic            arc(QPointF center, QPointF from, QPointF to);
};

/** @ingroup qml_material
 * Closed cubic geometry with corner features retained for morph matching.
 */
class RoundedPolygon {
public:
    struct Vertex {
        QPointF        position;
        CornerRounding rounding;
    };
    struct Feature {
        std::vector<Cubic> cubics;
        bool               corner = false;
        bool               convex = false;
    };

    RoundedPolygon() = default;
    explicit RoundedPolygon(const std::vector<Vertex>& vertices, QPointF center = {});
    const std::vector<Feature>& features() const { return m_features; }
    std::vector<Cubic>          cubics() const;
    QPointF                     center() const { return m_center; }
    QPainterPath                path() const;
    RoundedPolygon              transformed(const QTransform& transform) const;
    RoundedPolygon              normalized(bool radial = false) const;

private:
    std::vector<Feature> m_features;
    QPointF              m_center;
};

class Morph {
public:
    Morph(const RoundedPolygon& from, const RoundedPolygon& to);
    QPainterPath       path(qreal progress) const;
    std::vector<Cubic> cubics(qreal progress) const;
    qsizetype          curveCount() const { return qsizetype(m_match.size()); }

private:
    std::vector<std::pair<Cubic, Cubic>> m_match;
};

} // namespace qavsi::material3::loading
