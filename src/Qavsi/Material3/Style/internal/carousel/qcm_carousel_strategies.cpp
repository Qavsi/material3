// Copyright (c) 2024-2025 hypengw
// SPDX-License-Identifier: MIT
// Adapted from QmlMaterial 0.6.1 (1912605); see THIRD_PARTY_NOTICES.md.
#include "qcm_carousel_strategy.hpp"

#include "qcm_carousel_keylines.hpp"

namespace qavsi::material3::carousel
{

auto CarouselStrategy::compute(const CarouselLayoutInput& input) -> CarouselLayoutOutput {
    if (input.count <= 0 || input.viewport_size <= 0) {
        return {};
    }
    const KeylineList keylines = CarouselKeylines::buildList(input);
    return CarouselKeylines::layoutItems(input, keylines);
}

} // namespace qavsi::material3::carousel
