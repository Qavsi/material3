// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT

pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import "Material3FabRecipe.js" as Recipe

SK.StyleVariation {
    id: variation
    required property var sourceStyle
    property bool expanded: false
    property bool elevated: true
    property real minimumHeight: Recipe.height
    property real minimumIconSize: Recipe.iconSize
    property real cornerRadius: sourceStyle.tokens.radiusLarge
    readonly property Material3AdvancedButtonParameters parameters: Material3AdvancedButtonParameters {
        tokens: variation.sourceStyle.tokens
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
            color: variation.sourceStyle.tokens.primaryContainerForeground
            padding: 0
        }
        background {
            data: variation.parameters
            delegate: variation.sourceStyle.buttonDelegate.background
            width: Math.max(variation.sourceStyle.tokens.minimumTargetSize, variation.minimumHeight)
            height: Math.max(variation.sourceStyle.tokens.minimumTargetSize, variation.minimumHeight)
            radius: variation.cornerRadius
            color: variation.sourceStyle.tokens.primaryContainer
            border.width: 0
            shadow.visible: variation.elevated
        }
        hovered.background.color: variation.sourceStyle.tokens.primaryContainer
        pressed {
            background {
                color: variation.sourceStyle.tokens.primaryContainer
                radius: variation.cornerRadius
            }
        }
        focused.background.color: variation.sourceStyle.tokens.primaryContainer
        checked.background.color: variation.sourceStyle.tokens.primaryContainer
        disabled {
            text.color: variation.sourceStyle.tokens.disabledLabel
            background {
                color: variation.sourceStyle.tokens.disabledContainer
                shadow.visible: false
            }
        }
    }
}
