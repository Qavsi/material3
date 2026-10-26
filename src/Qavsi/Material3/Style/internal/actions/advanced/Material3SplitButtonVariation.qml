// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT

pragma ComponentBehavior: Bound
import QtQuick

Material3JoinedButtonVariation {
    id: variation
    required property var metrics
    split: true
    splitMetrics: metrics
    paintHeight: metrics.containerHeight
    minimumIconSize: trailing ? metrics.trailingIconSize : metrics.leadingIconSize
    horizontalPadding: trailing ? metrics.trailingIconPadding : metrics.leadingPadding
    minimumWidth: trailing ? metrics.trailingIconSize + metrics.trailingIconPadding * 2 : 0
    button.rightPadding: variation.trailing ? variation.metrics.trailingIconPadding : variation.metrics.trailingPadding
}
