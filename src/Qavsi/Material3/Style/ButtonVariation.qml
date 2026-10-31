pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

// Ported from Merce's Material3 action recipe; this mapping owns M3 roles only.
SK.StyleVariation {
    id: root
    required property Material3Style sourceStyle
    property Material3Theme tokens: sourceStyle.tokens
    required property color containerColor
    required property color contentColor
    property color checkedContainerColor: tokens.primary
    property color checkedContentColor: tokens.primaryForeground
    property bool outlined: false
    property bool elevated: false
    property bool transparentContainer: containerColor.a === 0

    control {
        text.color: root.contentColor
        background {
            color: root.containerColor
            border.width: root.outlined ? root.tokens.outlineWidth : 0
            border.color: root.tokens.outline
            shadow.visible: root.elevated
        }
        hovered.background.color: root.containerColor
        focused.background.color: root.containerColor
        pressed.background.color: root.containerColor
        checked {
            text.color: root.checkedContentColor
            background.color: root.checkedContainerColor
            background.border.width: 0
            hovered.background.color: root.checkedContainerColor
            focused.background.color: root.checkedContainerColor
            pressed.background.color: root.checkedContainerColor
        }
        disabled {
            text.color: root.tokens.disabledLabel
            background {
                color: root.transparentContainer ? root.tokens.transparent
                    : root.tokens.disabledContainer
                border.color: root.tokens.disabledContainer
                shadow.visible: false
            }
            checked {
                text.color: root.tokens.disabledLabel
                background.color: root.tokens.disabledContainer
                background.shadow.visible: false
            }
        }
    }
}
