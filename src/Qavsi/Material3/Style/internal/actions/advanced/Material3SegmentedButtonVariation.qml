// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT

pragma ComponentBehavior: Bound
import QtQuick

Material3JoinedButtonVariation {
    id: variation
    required property var metrics
    segmented: true
    paintHeight: metrics.containerHeight
    minimumIconSize: metrics.iconSize

    button {
        text.color: variation.tokens.surfaceForeground
        background {
            color: variation.tokens.transparent
            border.color: variation.tokens.outline
            border.width: variation.tokens.outlineWidth
        }
        hovered.background.color: variation.tokens.transparent
        pressed.background.color: variation.tokens.transparent
        focused.background.color: variation.tokens.transparent
        checked {
            text.color: variation.tokens.secondaryContainerForeground
            background.color: variation.tokens.secondaryContainer
        }
        disabled {
            text.color: variation.tokens.disabledLabel
            background {
                color: variation.tokens.transparent
                border.color: Qt.alpha(variation.tokens.surfaceForeground,
                    variation.tokens.disabledContainerOpacity)
            }
            checked.background.color: variation.tokens.disabledContainer
        }
    }
}
