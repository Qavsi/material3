// Copyright (c) 2024-2025 hypengw
// SPDX-License-Identifier: MIT
// Adapted from QmlMaterial 0.6.1 (1912605); see THIRD_PARTY_NOTICES.md.
#pragma once

#include "qcm_carousel_strategy.hpp"

namespace qavsi::material3::carousel
{

struct Keyline {
    qreal offset            = 0; // center position in viewport (main axis)
    qreal size              = 0;
    int   size_class        = 2;
    qreal unadjusted_offset = 0;
};

struct KeylineList {
    QVector<Keyline> keylines;
    qreal            scroll_step = 0;
    qreal            large_size  = 0;
    qreal            medium_size = 0;
    qreal            small_size  = 0;
};

class CarouselKeylines {
public:
    static auto buildList(const CarouselLayoutInput& input) -> KeylineList;
    static auto layoutItems(const CarouselLayoutInput& input, const KeylineList& keylines)
        -> CarouselLayoutOutput;
};

/// @brief Внутренние билдеры hero keylines (carousel engine).
namespace CarouselHeroKeylines
{

enum class HeroPhase
{
    Leading,
    Middle,
    Trailing,
};

struct HeroMetrics {
    bool  single_item         = false;
    qreal small_leading       = 0;
    qreal small_center        = 0;
    qreal large_leading       = 0;
    qreal large_center        = 0;
    qreal medium_leading      = 0;
    qreal medium_center       = 0;
    qreal scroll_step_leading = 0;
    qreal scroll_step_center  = 0;
};

auto computeMetrics(const CarouselLayoutInput& in) -> HeroMetrics;
auto phaseKeylines(const CarouselLayoutInput& in, HeroPhase phase, bool keep_leading_peek)
    -> KeylineList;
auto keepLeadingPeek(const CarouselLayoutInput& in) -> bool;

} // namespace CarouselHeroKeylines

} // namespace qavsi::material3::carousel
