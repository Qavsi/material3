pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

SK.StyleVariation {
    id: root
    required property var sourceStyle
    required property int lines
    property Material3Theme tokens: sourceStyle.tokens
    readonly property Material3ListCardDelegate factory: Material3ListCardDelegate { }
    readonly property Material3ListCardParameters parameters: Material3ListCardParameters {
        tokens: root.tokens
        reducedMotion: root.sourceStyle.effectiveReducedMotion
    }
    itemDelegate {
        leftPadding: root.tokens.listCardLeadingPadding
        rightPadding: root.tokens.listCardTrailingPadding
        topPadding: root.tokens.listCardVerticalPadding
        bottomPadding: root.tokens.listCardVerticalPadding
        spacing: root.tokens.listCardSpacing
        text { color: root.tokens.surfaceForeground; alignment: Qt.AlignLeft | Qt.AlignVCenter; padding: 0 }
        background {
            width: root.tokens.listCardMinimumWidth
            height: root.lines === 3 ? root.tokens.listCardThreeLineHeight
                : root.lines === 2 ? root.tokens.listCardTwoLineHeight : root.tokens.listCardOneLineHeight
            color: root.tokens.surface
            radius: 0
            margins: 0
            gradient: null
            border.width: 0
            shadow.visible: false
            delegate: root.factory.background
            data: root.parameters
        }
        hovered.background.color: root.tokens.surface
        focused.background.color: root.tokens.surface
        pressed.background.color: root.tokens.surface
        checked {
            background.color: root.tokens.secondaryContainer
            hovered.background.color: root.tokens.secondaryContainer
            focused.background.color: root.tokens.secondaryContainer
            pressed.background.color: root.tokens.secondaryContainer
        }
        disabled {
            text.color: root.tokens.disabledLabel
            background.color: root.tokens.disabledLabel
            checked.background.color: root.tokens.disabledLabel
        }
    }
}
