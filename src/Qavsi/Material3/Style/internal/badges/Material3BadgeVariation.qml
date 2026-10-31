pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

SK.StyleVariation {
    id: root
    required property var sourceStyle
    property Material3Theme tokens: sourceStyle.tokens
    property string intent: "error"
    readonly property Material3BadgeDelegate factory: Material3BadgeDelegate { }
    readonly property Material3BadgeParameters parameters: Material3BadgeParameters {
        tokens: root.tokens
        intent: root.intent
    }
    label {
        leftPadding: root.parameters.tokens.badgeHorizontalPadding
        rightPadding: root.parameters.tokens.badgeHorizontalPadding
        topPadding: 0
        bottomPadding: 0
        text.color: root.parameters.foreground
        background {
            visible: true
            width: 0
            height: 0
            margins: 0
            color: root.parameters.container
            gradient: null
            border.width: 0
            shadow.visible: false
            data: root.parameters
            delegate: root.factory.background
        }
        disabled {
            text.color: root.parameters.tokens.disabledLabel
            background.color: root.parameters.tokens.disabledContainer
        }
    }
}
