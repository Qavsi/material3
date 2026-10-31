pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

SK.StyleVariation {
    id: root
    required property Material3Style sourceStyle
    property Material3Theme tokens: sourceStyle.tokens
    name: "navigationDestination"
    control {
        leftPadding: root.tokens.navigationDestinationLeadingPadding
        rightPadding: root.tokens.navigationDestinationTrailingPadding
        topPadding: 0; bottomPadding: 0
        spacing: root.tokens.navigationDestinationSpacing
        text { color: root.tokens.surfaceVariantForeground; alignment: Qt.AlignLeft | Qt.AlignVCenter }
        background {
            width: root.tokens.appNavigationExpandedWidth
            height: root.tokens.navigationDestinationHeight
            color: root.tokens.transparent
            radius: root.tokens.navigationDestinationHeight / 2
            border.width: 0
            shadow.visible: false
        }
        hovered.background.color: root.tokens.transparent
        focused.background.color: root.tokens.transparent
        pressed { background.color: root.tokens.transparent; background.radius: root.tokens.navigationDestinationHeight / 2 }
        checked {
            text.color: root.tokens.secondaryContainerForeground
            background.color: root.tokens.secondaryContainer
            hovered.background.color: root.tokens.secondaryContainer
            focused.background.color: root.tokens.secondaryContainer
            pressed.background.color: root.tokens.secondaryContainer
        }
        disabled { text.color: root.tokens.disabledLabel; background.color: root.tokens.transparent }
    }
}
