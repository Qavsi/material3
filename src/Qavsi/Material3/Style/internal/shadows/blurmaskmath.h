// Adapted from QmlMaterial 229bc3e6 (MIT), copyright (c) 2024-2025 hypengw.
// Skia-derived Gaussian model (BSD-3-Clause); see third_party/shadow-reference.
#pragma once
#include <cstdint>
#include <span>

namespace qavsi::shadow::blur {
float gaussian_cdf(float x);
void fill_unit_cdf_profile(std::span<std::uint8_t> out);
int gaussian_kernel_radius(float sigma);
void fill_gaussian_kernel_1d(std::span<float> out, float sigma);
int rrect_corner_cutout_size(float sigma, float radius);
void fill_rrect_corner_cutout(std::span<std::uint8_t> out, float sigma, float radius);
} // namespace qavsi::shadow::blur
