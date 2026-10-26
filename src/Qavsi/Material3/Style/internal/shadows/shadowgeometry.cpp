// Adapted from QmlMaterial (MIT), copyright (c) 2024-2025 hypengw.
// Skia-derived shadow math (BSD-3-Clause); see third_party/shadow-reference.
#include "shadowgeometry.h"
#include "shadowmesh.h"

#include <algorithm>
#include <array>
#include <cmath>
#include <optional>

namespace qavsi::shadow {

std::unique_ptr<QSGGeometry> createShadowGeometry()
{
    static const QSGGeometry::Attribute attributes[] = {
        QSGGeometry::Attribute::createWithAttributeType(
            0, 2, QSGGeometry::FloatType, QSGGeometry::PositionAttribute),
        QSGGeometry::Attribute::createWithAttributeType(
            1, 4, QSGGeometry::FloatType, QSGGeometry::UnknownAttribute),
        QSGGeometry::Attribute::createWithAttributeType(
            2, 3, QSGGeometry::FloatType, QSGGeometry::UnknownAttribute)
    };
    static const QSGGeometry::AttributeSet attributeSet = {3, sizeof(ShadowVertex), attributes};
    auto geometry = std::make_unique<QSGGeometry>(attributeSet, 0);
    geometry->setDrawingMode(QSGGeometry::DrawTriangles);
    return geometry;
}

bool updateShadowGeometry(QSGGeometry *geometry, const ShadowParameters &parameters,
                          const QRectF &rect)
{
    const auto maximumRadius = std::min<float>(rect.width(), rect.height()) / 2;
    const bool circle = qFuzzyCompare(float(rect.width()), float(rect.height()))
        && qFuzzyCompare(parameters.radii.x(), maximumRadius)
        && qFuzzyCompare(parameters.radii.y(), maximumRadius)
        && qFuzzyCompare(parameters.radii.z(), maximumRadius)
        && qFuzzyCompare(parameters.radii.w(), maximumRadius);
    std::array<std::optional<mesh::ShadowCircularRRectOp>, 2> operations;

    auto shadowColor = parameters.color;
    shadowColor.setAlphaF(parameters.ambientOpacity * parameters.color.alphaF());
    if (shadowColor.alpha() > 0) {
        const float inset = std::min(parameters.elevation * 0.5f, 150.0f);
        const float blur = inset * (1 + parameters.elevation / 128.0f);
        const QRectF bounds = rect.adjusted(-inset, -inset, inset, inset);
        QVector4D radii = parameters.radii + QVector4D(inset, inset, inset, inset);
        for (int i = 0; i < 4; ++i)
            radii[i] = std::min(radii[i], maximumRadius + inset);
        if (blur > 0 && std::isfinite(blur))
            operations[0].emplace(shadowColor.rgba(), bounds, radii, circle, blur, inset);
    }

    shadowColor.setAlphaF(parameters.spotOpacity * parameters.color.alphaF());
    if (shadowColor.alpha() > 0) {
        const float blur = parameters.lightRadius * parameters.elevation;
        const float ratio = std::clamp(parameters.elevation / parameters.lightDirection.z(),
                                       0.0f, 64.0f * (1 << 12));
        const QVector2D offset(-ratio * parameters.lightDirection.x(),
                               -ratio * parameters.lightDirection.y());
        const QRectF translated = rect.translated(offset.x(), offset.y());
        const QVector2D upperLeft(translated.left() - rect.left(),
                                  translated.top() - rect.top());
        const QVector2D lowerRight(translated.right() - rect.right(),
                                   translated.bottom() - rect.bottom());
        const float inset = blur + std::max(blur,
            std::sqrt(std::max(upperLeft.lengthSquared(), lowerRight.lengthSquared())));
        const QRectF bounds = translated.adjusted(-blur, -blur, blur, blur);
        const QVector4D radii = parameters.radii + QVector4D(blur, blur, blur, blur);
        if (blur > 0 && std::isfinite(blur) && std::isfinite(inset))
            operations[1].emplace(shadowColor.rgba(), bounds, radii, circle, 2 * blur, inset);
    }

    int vertexCount = 0;
    int indexCount = 0;
    for (const auto &operation : operations) {
        if (operation) {
            vertexCount += operation->fVertCount;
            indexCount += operation->fIndexCount;
        }
    }
    geometry->allocate(vertexCount, indexCount);
    auto *vertex = static_cast<ShadowVertex *>(geometry->vertexData());
    auto *index = static_cast<std::uint16_t *>(geometry->indexData());
    int vertexOffset = 0;
    for (const auto &operation : operations) {
        if (!operation)
            continue;
        if (operation->fGeoData.is_circle)
            operation->fillInCircleVerts(operation->fGeoData.type
                == mesh::ShadowCircularRRectOp::kStroke_RRectType, &vertex);
        else
            operation->fillInRRectVerts(&vertex);
        for (int i = 0; i < operation->fIndexCount; ++i)
            index[i] = operation->fIndexPtr[i] + vertexOffset;
        index += operation->fIndexCount;
        vertexOffset += operation->fVertCount;
    }
    const auto *vertices = static_cast<const ShadowVertex *>(geometry->vertexData());
    for (int i = 0; i < vertexCount; ++i) {
        const auto &v = vertices[i];
        if (!std::isfinite(v.x) || !std::isfinite(v.y)
            || !std::isfinite(v.offset_x) || !std::isfinite(v.offset_y)
            || !std::isfinite(v.distance_correction)) {
            geometry->allocate(0, 0);
            return false;
        }
    }
    return vertexCount > 0;
}

} // namespace qavsi::shadow
