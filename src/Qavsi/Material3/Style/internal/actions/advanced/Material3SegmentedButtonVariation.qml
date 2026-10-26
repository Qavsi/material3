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
        text.color: variation.sourceStyle.tokens.surfaceForeground
        background {
            color: variation.sourceStyle.tokens.transparent
            border.color: variation.sourceStyle.tokens.outline
            border.width: variation.sourceStyle.tokens.outlineWidth
        }
        hovered.background.color: variation.sourceStyle.tokens.transparent
        pressed.background.color: variation.sourceStyle.tokens.transparent
        focused.background.color: variation.sourceStyle.tokens.transparent
        checked {
            text.color: variation.sourceStyle.tokens.secondaryContainerForeground
            background.color: variation.sourceStyle.tokens.secondaryContainer
        }
        disabled {
            text.color: variation.sourceStyle.tokens.disabledLabel
            background {
                color: variation.sourceStyle.tokens.transparent
                border.color: Qt.alpha(variation.sourceStyle.tokens.surfaceForeground,
                    variation.sourceStyle.tokens.disabledContainerOpacity)
            }
            checked.background.color: variation.sourceStyle.tokens.disabledContainer
        }
    }
}
