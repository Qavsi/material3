// State and geometry recipe: QmlMaterial 0.6.1, 191260585a829ee4ae2c99e6232b7145b5c34474 (MIT).
pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

SK.StyleVariation {
    id: variation
    required property var sourceStyle
    required property string kind
    property Material3Theme tokens: sourceStyle.tokens
    readonly property bool selectable: kind === "filter" || kind === "input" || kind === "embed"
    readonly property bool dismiss: kind === "dismiss"
    readonly property bool outlined: kind !== "embed" && !dismiss
    readonly property real cornerRadius: dismiss ? tokens.chipTrailingTarget / 2 : tokens.chipRadius
    readonly property real outlineWidth: outlined ? tokens.outlineWidth : 0
    readonly property color ink: kind === "assist" ? tokens.chipAssistInk : tokens.chipInk
    readonly property color selectedInk: selectable ? tokens.chipSelectedInk : ink
    readonly property color selectedContainer: selectable ? tokens.secondaryContainer : tokens.transparent
    readonly property color disabledContainer: kind === "filter" ? tokens.disabledContainer : tokens.transparent
    readonly property color disabledSelectedContainer: kind === "filter" ? tokens.disabledContainer
        : selectable ? Qt.alpha(tokens.secondaryContainer, tokens.secondaryContainer.a * tokens.disabledContainerOpacity) : tokens.transparent
    readonly property Material3ChipDelegate backgroundFactory: Material3ChipDelegate { }
    readonly property Material3ChipParameters parameters: Material3ChipParameters {
        tokens: variation.tokens
        reducedMotion: variation.sourceStyle.effectiveReducedMotion
        kind: variation.kind
    }

    button {
        leftPadding: variation.dismiss ? 0 : variation.tokens.chipPadding
        rightPadding: variation.dismiss ? 0 : variation.tokens.chipPadding
        topPadding: 0
        bottomPadding: 0
        spacing: variation.dismiss ? 0 : variation.tokens.chipSpacing
        text {
            color: variation.ink
            alignment: Qt.AlignCenter
            padding: 0
        }
        background {
            width: variation.dismiss ? variation.tokens.chipTrailingTarget : variation.tokens.chipMinimumWidth
            height: variation.dismiss ? variation.tokens.chipTrailingTarget : variation.tokens.chipHeight
            radius: variation.cornerRadius
            margins: 0
            color: variation.tokens.transparent
            gradient: null
            border.width: variation.outlineWidth
            border.color: variation.tokens.outlineVariant
            shadow.visible: false
            delegate: variation.backgroundFactory.background
            data: variation.parameters
        }
        hovered.background.color: variation.tokens.transparent
        focused.background.color: variation.tokens.transparent
        pressed {
            background {
                color: variation.tokens.transparent
                radius: variation.cornerRadius
            }
        }
        checked {
            text.color: variation.selectedInk
            background {
                color: variation.selectedContainer
                radius: variation.cornerRadius
                border.width: variation.selectable ? 0 : variation.outlineWidth
                shadow.visible: false
            }
            hovered.background.color: variation.selectedContainer
            focused.background.color: variation.selectedContainer
            pressed {
                background {
                    color: variation.selectedContainer
                    radius: variation.cornerRadius
                }
            }
        }
        disabled {
            text.color: variation.tokens.disabledLabel
            background {
                color: variation.disabledContainer
                radius: variation.cornerRadius
                border.width: variation.outlineWidth
                border.color: variation.tokens.chipDisabledOutline
                shadow.visible: false
            }
            checked {
                text.color: variation.tokens.disabledLabel
                background {
                    color: variation.disabledSelectedContainer
                    radius: variation.cornerRadius
                    border.width: variation.selectable ? 0 : variation.outlineWidth
                    border.color: variation.tokens.chipDisabledOutline
                    shadow.visible: false
                }
            }
        }
    }
}
