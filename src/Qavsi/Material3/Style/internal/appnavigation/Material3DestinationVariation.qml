pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK

SK.StyleVariation {
    id: root
    required property Material3Style sourceStyle
    name: "navigationDestination"
    control {
        leftPadding: root.sourceStyle.tokens.navigationDestinationLeadingPadding
        rightPadding: root.sourceStyle.tokens.navigationDestinationTrailingPadding
        topPadding: 0; bottomPadding: 0
        spacing: root.sourceStyle.tokens.navigationDestinationSpacing
        text { color: root.sourceStyle.tokens.surfaceVariantForeground; alignment: Qt.AlignLeft | Qt.AlignVCenter }
        background {
            width: root.sourceStyle.tokens.appNavigationExpandedWidth
            height: root.sourceStyle.tokens.navigationDestinationHeight
            color: root.sourceStyle.tokens.transparent
            radius: root.sourceStyle.tokens.navigationDestinationHeight / 2
            border.width: 0
            shadow.visible: false
        }
        hovered.background.color: root.sourceStyle.tokens.transparent
        focused.background.color: root.sourceStyle.tokens.transparent
        pressed { background.color: root.sourceStyle.tokens.transparent; background.radius: root.sourceStyle.tokens.navigationDestinationHeight / 2 }
        checked {
            text.color: root.sourceStyle.tokens.secondaryContainerForeground
            background.color: root.sourceStyle.tokens.secondaryContainer
            hovered.background.color: root.sourceStyle.tokens.secondaryContainer
            focused.background.color: root.sourceStyle.tokens.secondaryContainer
            pressed.background.color: root.sourceStyle.tokens.secondaryContainer
        }
        disabled { text.color: root.sourceStyle.tokens.disabledLabel; background.color: root.sourceStyle.tokens.transparent }
    }
}
