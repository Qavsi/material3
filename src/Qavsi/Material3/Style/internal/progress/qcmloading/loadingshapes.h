// Copyright (c) 2024-2025 hypengw (hypengwip@gmail.com)
// SPDX-License-Identifier: MIT
// QmlMaterial 0.6.1, 191260585a829ee4ae2c99e6232b7145b5c34474.
#pragma once

#include "rounded_polygon.hpp"
#include <cstddef>

namespace qavsi::material3::loading {
// The seven radial shapes and adjacent morph pairs are shared by all indicators.
// The phase index must be in [0, 6].
const Morph &loadingMorph(std::size_t phaseIndex);
} // namespace qavsi::material3::loading
