// Adapted from QmlMaterial (MIT), copyright (c) 2024-2025 hypengw.
// Skia-derived shadow math (BSD-3-Clause); see third_party/shadow-reference.
#pragma once

#include <QColor>
#include <QRectF>
#include <QSGGeometry>
#include <QVector2D>
#include <QVector3D>
#include <QVector4D>
#include <cstdint>
#include <memory>

namespace qavsi::shadow {

struct ShadowVertex {
    float x, y;
    float r, g, b, a;
    float offset_x, offset_y, distance_correction;

    void set_point(float px, float py) noexcept { x = px; y = py; }
    void set_point(QVector2D point) noexcept { set_point(point.x(), point.y()); }
    void set_color(QRgb color) noexcept
    {
        // Qt scene graph blending expects premultiplied vertex colors.
        a = qAlpha(color) / 255.0f;
        r = qRed(color) / 255.0f * a;
        g = qGreen(color) / 255.0f * a;
        b = qBlue(color) / 255.0f * a;
    }
    void set_offset(QVector2D offset) noexcept { offset_x = offset.x(); offset_y = offset.y(); }
};

struct ShadowParameters {
    float elevation = 0;
    QVector4D radii;
    QColor color;
    float ambientOpacity = 0;
    float spotOpacity = 0;
    QVector3D lightDirection;
    float lightRadius = 0;
    bool operator==(const ShadowParameters &) const = default;
};

std::unique_ptr<QSGGeometry> createShadowGeometry();
bool updateShadowGeometry(QSGGeometry *geometry, const ShadowParameters &parameters,
                          const QRectF &rect);

} // namespace qavsi::shadow
