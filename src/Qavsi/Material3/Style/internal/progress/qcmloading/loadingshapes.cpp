// Copyright (c) 2024-2025 hypengw (hypengwip@gmail.com)
// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT
// Adapted from QmlMaterial 0.6.1, 191260585a829ee4ae2c99e6232b7145b5c34474.
// Only the loading sequence is retained; unrelated Material shapes are not built.
#include "loadingshapes.h"

#include <array>
#include <cmath>
#include <numbers>

namespace qavsi::material3::loading {
namespace {
using Vertex = RoundedPolygon::Vertex;
constexpr auto pi = std::numbers::pi;

QPointF polar(qreal radius, qreal angle) {
    return {radius * std::cos(angle), radius * std::sin(angle)};
}

RoundedPolygon regular(int n, qreal radius, CornerRounding rounding, qreal innerRadius = -1) {
    std::vector<Vertex> vertices;
    for (int i = 0; i < n; ++i)
        vertices.push_back(
            {polar(innerRadius > 0 && i % 2 ? innerRadius : radius, 2 * pi * i / n), rounding});
    return RoundedPolygon(vertices);
}

RoundedPolygon circle(int n = 8) {
    return regular(n, 1 / std::cos(pi / n), {1, 0});
}

RoundedPolygon rotated(const RoundedPolygon &polygon, qreal angle) {
    return polygon.transformed(QTransform().rotate(angle));
}

RoundedPolygon custom(std::initializer_list<Vertex> points, int repeat, bool mirror = false) {
    const std::vector<Vertex> input(points);
    const QPointF center(.5, .5);
    const auto repeats = repeat * (mirror ? 2 : 1);
    const auto span = 2 * pi / repeats;
    const auto start = input.front().position - center;
    const auto startAngle = std::atan2(start.y(), start.x());
    std::vector<Vertex> vertices;
    for (int i = 0; i < repeats; ++i) {
        const bool reverse = mirror && i % 2;
        for (size_t j = 0; j < input.size(); ++j) {
            const auto index = reverse ? input.size() - j - 1 : j;
            if (reverse && index == 0)
                continue;
            const auto p = input[index].position - center;
            const auto angle = std::atan2(p.y(), p.x());
            vertices.push_back(
                {center + polar(std::hypot(p.x(), p.y()),
                                span * i + (reverse ? span - angle + 2 * startAngle : angle)),
                 input[index].rounding});
        }
    }
    return RoundedPolygon(vertices, center);
}

struct LoadingSequence {
    // Same factories and radial normalization as QCM MaterialShapes::loadingSequence().
    const std::array<RoundedPolygon, 7> shapes = {
        // SoftBurst
        custom({{{.193, .277}, {.053}}, {{.176, .055}, {.053}}}, 10).normalized(true),
        // Cookie9Sided
        rotated(regular(18, 1, {.5}, .8), -90).normalized(true),
        // Pentagon
        custom({{{.500, -.009}, {.172}}, {{1.030, .365}, {.164}}, {{.828, .970}, {.169}}},
               1, true).normalized(true),
        // Pill
        custom({{{.961, .039}, {.426}}, {{1.001, .428}, {}}, {{1, .609}, {1}}},
               2, true).normalized(true),
        // Sunny
        regular(16, 1, {.15}, .8).normalized(true),
        // Cookie4Sided
        custom({{{1.237, 1.236}, {.258}}, {{.500, .918}, {.233}}}, 4).normalized(true),
        // Oval
        rotated(circle().transformed(QTransform().scale(1, .64)), -45).normalized(true)
    };
    const std::array<Morph, 7> morphs = {
        Morph(shapes[0], shapes[1]), Morph(shapes[1], shapes[2]),
        Morph(shapes[2], shapes[3]), Morph(shapes[3], shapes[4]),
        Morph(shapes[4], shapes[5]), Morph(shapes[5], shapes[6]),
        Morph(shapes[6], shapes[0])
    };
};
} // namespace

const Morph &loadingMorph(std::size_t phaseIndex) {
    static const LoadingSequence sequence;
    return sequence.morphs.at(phaseIndex);
}
} // namespace qavsi::material3::loading
