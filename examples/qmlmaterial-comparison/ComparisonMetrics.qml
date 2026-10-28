// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT

import QtQml

QtObject {
    readonly property real appNavigationCompactWidth: 440
    readonly property real appNavigationNarrowWidth: 800
    readonly property real appNavigationExpandedWidth: 1280
    readonly property real commonSizeSpacing: 12
    readonly property real iconAppearanceSpacing: 36

    readonly property real chipCardWidth: 560
    readonly property real chipGallerySpacing: 12
    readonly property real chipLongWidth: 180

    readonly property real radioReadOnlySpacing: 5

    readonly property real sliderGalleryMinimumWidth: 520
    readonly property real sliderGalleryVerticalLength: 160
    readonly property real sliderGalleryInsetVerticalLength: 240
    readonly property real sliderCardWidth: sliderGalleryMinimumWidth + 40
}
