pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

SK.Theme {
    id: root
    required property Material3Theme tokens

    applicationWindow.background.color: tokens.surface
    button {
        leftPadding: root.tokens.smallHorizontalPadding
        rightPadding: root.tokens.smallHorizontalPadding
        topPadding: root.tokens.smallVerticalPadding
        bottomPadding: root.tokens.smallVerticalPadding
        spacing: root.tokens.smallSpacing
        text {
            color: root.tokens.primaryForeground
            alignment: Qt.AlignCenter
            padding: 0
        }
        background {
            width: 0
            height: root.tokens.smallHeight
            radius: root.tokens.smallRadius
            margins: 0
            border.width: 0
            color: root.tokens.primary
            gradient: null
        }
        hovered.background.color: root.tokens.primary
        focused.background.color: root.tokens.primary
        pressed.background.color: root.tokens.primary
        checked.background.color: root.tokens.primary
        disabled {
            background.color: root.tokens.disabledContainer
            text.color: root.tokens.disabledLabel
        }
    }
}
