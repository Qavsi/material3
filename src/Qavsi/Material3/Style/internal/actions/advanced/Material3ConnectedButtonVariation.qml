// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT

pragma ComponentBehavior: Bound
import QtQuick

Material3JoinedButtonVariation {
    id: variation
    required property var metrics
    property bool iconGeometry: false
    fillIconWhenChecked: iconGeometry
    readonly property real iconExtent: Math.max(minimumIconSize, tokens.smallIconSize)
        + tokens.spacingUnit * 2
    paintHeight: iconGeometry ? Math.max(metrics.iconHeight, iconExtent) : metrics.buttonHeight
    minimumIconSize: iconGeometry ? metrics.iconSize : metrics.buttonIconSize
    minimumWidth: iconGeometry ? Math.max(metrics.iconWidth, iconExtent) : metrics.buttonMinimumWidth
    horizontalPadding: iconGeometry ? 0 : tokens.smallHorizontalPadding
}
