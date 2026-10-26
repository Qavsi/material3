pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK

// Ported from Merce's Material3 action recipe; this mapping owns M3 roles only.
SK.StyleVariation {
    id: root
    required property Material3Style sourceStyle
    required property color containerColor
    required property color contentColor
    property color checkedContainerColor: sourceStyle.tokens.primary
    property color checkedContentColor: sourceStyle.tokens.primaryForeground
    property bool outlined: false
    property bool elevated: false
    property bool transparentContainer: containerColor.a === 0

    control {
        text.color: root.contentColor
        background {
            color: root.containerColor
            border.width: root.outlined ? root.sourceStyle.tokens.outlineWidth : 0
            border.color: root.sourceStyle.tokens.outline
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
            text.color: root.sourceStyle.tokens.disabledLabel
            background {
                color: root.transparentContainer ? root.sourceStyle.tokens.transparent
                    : root.sourceStyle.tokens.disabledContainer
                border.color: root.sourceStyle.tokens.disabledContainer
                shadow.visible: false
            }
            checked {
                text.color: root.sourceStyle.tokens.disabledLabel
                background.color: root.sourceStyle.tokens.disabledContainer
                background.shadow.visible: false
            }
        }
    }
}
