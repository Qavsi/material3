// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT

pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme
import "Material3FabRecipe.js" as Recipe

SK.StyleVariation {
    id: variation
    required property var sourceStyle
    property Material3Theme tokens: sourceStyle.tokens
    property bool expanded: false
    property bool elevated: true
    property real minimumHeight: Recipe.height
    property real minimumIconSize: Recipe.iconSize
    property real cornerRadius: tokens.radiusLarge
    readonly property Material3AdvancedButtonParameters parameters: Material3AdvancedButtonParameters {
        tokens: variation.tokens
        reduceMotion: variation.sourceStyle.effectiveReducedMotion
        paintHeight: variation.minimumHeight
        minimumIconSize: variation.minimumIconSize
        contentRole: "fab"
        expanded: variation.expanded
        minimumExpandedWidth: Recipe.minimumExpandedWidth
        leadingInset: Recipe.leadingInset
        trailingInset: Recipe.trailingInset
    }

    button {
        padding: 0
        spacing: Recipe.spacing
        text {
            color: variation.tokens.primaryContainerForeground
            padding: 0
        }
        background {
            data: variation.parameters
            delegate: variation.sourceStyle.buttonDelegate.background
            width: Math.max(variation.tokens.minimumTargetSize, variation.minimumHeight)
            height: Math.max(variation.tokens.minimumTargetSize, variation.minimumHeight)
            radius: variation.cornerRadius
            color: variation.tokens.primaryContainer
            border.width: 0
            shadow.visible: variation.elevated
        }
        hovered.background.color: variation.tokens.primaryContainer
        pressed {
            background {
                color: variation.tokens.primaryContainer
                radius: variation.cornerRadius
            }
        }
        focused.background.color: variation.tokens.primaryContainer
        checked.background.color: variation.tokens.primaryContainer
        disabled {
            text.color: variation.tokens.disabledLabel
            background {
                color: variation.tokens.disabledContainer
                shadow.visible: false
            }
        }
    }
}
