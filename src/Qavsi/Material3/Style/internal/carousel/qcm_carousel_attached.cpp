// Copyright (c) 2024-2025 hypengw
// SPDX-License-Identifier: MIT
// Adapted from QmlMaterial 0.6.1 (1912605); see THIRD_PARTY_NOTICES.md.
#include "qcm_carousel_attached.hpp"

namespace qavsi::material3::carousel
{

Material3CarouselAttached::Material3CarouselAttached(QObject* parent): QObject(parent) {}

qreal Material3CarouselAttached::itemWidth() const { return m_width; }
qreal Material3CarouselAttached::itemHeight() const { return m_height; }
qreal Material3CarouselAttached::maskStart() const { return m_mask_start; }
qreal Material3CarouselAttached::maskEnd() const { return m_mask_end; }
qreal Material3CarouselAttached::parallaxShift() const { return m_parallax_shift; }
qreal Material3CarouselAttached::visibleFraction() const {
    return qMax(0.0, 1.0 - m_mask_start - m_mask_end);
}
int  Material3CarouselAttached::sizeClass() const { return m_size_class; }
int  Material3CarouselAttached::index() const { return m_index; }
int  Material3CarouselAttached::carouselCount() const { return m_carousel_count; }
int  Material3CarouselAttached::carouselOrientation() const { return m_orientation; }
int  Material3CarouselAttached::carouselCurrentIndex() const { return m_current_index; }
bool Material3CarouselAttached::isActive() const { return m_is_active; }

void Material3CarouselAttached::setContext(int count, int orientation, int currentIndex) {
    const bool count_changed = m_carousel_count != count || m_orientation != orientation ||
                               m_current_index != currentIndex;
    m_carousel_count         = count;
    m_orientation            = orientation;
    m_current_index          = currentIndex;
    if (count_changed) {
        Q_EMIT contextChanged();
    }
}

void Material3CarouselAttached::setGeometry(qreal width, qreal height, qreal maskStart, qreal maskEnd,
                                   qreal parallaxShift, int sizeClass, int index, bool isActive) {
    bool changed = ! qFuzzyCompare(m_width, width) || ! qFuzzyCompare(m_height, height) ||
                   ! qFuzzyCompare(m_mask_start, maskStart) ||
                   ! qFuzzyCompare(m_mask_end, maskEnd) ||
                   ! qFuzzyCompare(m_parallax_shift, parallaxShift) || m_size_class != sizeClass ||
                   m_index != index || m_is_active != isActive;
    m_width      = width;
    m_height     = height;
    m_mask_start = maskStart;
    m_mask_end   = maskEnd;
    m_parallax_shift = parallaxShift;
    m_size_class     = sizeClass;
    m_index          = index;
    m_is_active      = isActive;
    if (changed) {
        Q_EMIT geometryChanged();
    }
}

} // namespace qavsi::material3::carousel
