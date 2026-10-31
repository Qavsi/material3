pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

SK.StyleVariation {
    id: root
    required property Material3Style sourceStyle
    property Material3Theme tokens: sourceStyle.tokens
    property bool expanded: false

    control {
        topPadding: 0; bottomPadding: 0; leftPadding: 0; rightPadding: 0
        spacing: 0
        text.color: root.tokens.surfaceVariantForeground
        background {
            width: root.expanded ? root.tokens.navigationRailExpandedWidth
                : root.tokens.navigationRailCollapsedWidth
            height: root.expanded ? root.tokens.navigationRailExpandedIndicatorSize
                : root.tokens.navigationRailIndicatorHeight
            radius: 0
            margins: 0
            color: root.tokens.transparent
            gradient: null
            border.width: 0
            shadow.visible: false
            delegate: root.sourceStyle.navigationDelegate.itemBackground
            data: Material3NavigationParameters {
                tokens: root.tokens
                reducedMotion: root.sourceStyle.effectiveReducedMotion
                role: root.expanded ? "navigationRailExpanded" : "navigationRailCollapsed"
            }
        }
        hovered { text.color: root.tokens.surfaceForeground; background.color: root.tokens.transparent }
        focused { text.color: root.tokens.surfaceForeground; background.color: root.tokens.transparent }
        pressed { text.color: root.tokens.surfaceForeground; background.color: root.tokens.transparent; background.radius: 0 }
        checked {
            text.color: root.tokens.secondaryContainerForeground
            background.color: root.tokens.secondaryContainer
            hovered.background.color: root.tokens.secondaryContainer
            focused.background.color: root.tokens.secondaryContainer
            pressed.background.color: root.tokens.secondaryContainer
            hovered.text.color: root.tokens.secondaryContainerForeground
            focused.text.color: root.tokens.secondaryContainerForeground
            pressed.text.color: root.tokens.secondaryContainerForeground
        }
        disabled {
            text.color: root.tokens.disabledLabel
            background.color: root.tokens.transparent
            checked {
                text.color: root.tokens.disabledLabel
                background.color: root.tokens.disabledContainer
            }
        }
    }
}
