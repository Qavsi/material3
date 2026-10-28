pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK

SK.StyleVariation {
    id: root
    required property Material3Style sourceStyle
    property bool expanded: false

    control {
        topPadding: 0; bottomPadding: 0; leftPadding: 0; rightPadding: 0
        spacing: 0
        text.color: root.sourceStyle.tokens.surfaceVariantForeground
        background {
            width: root.expanded ? root.sourceStyle.tokens.navigationRailExpandedWidth
                : root.sourceStyle.tokens.navigationRailCollapsedWidth
            height: root.expanded ? root.sourceStyle.tokens.navigationRailExpandedIndicatorSize
                : root.sourceStyle.tokens.navigationRailIndicatorHeight
            radius: 0
            margins: 0
            color: root.sourceStyle.tokens.transparent
            gradient: null
            border.width: 0
            shadow.visible: false
            delegate: root.sourceStyle.navigationDelegate.itemBackground
            data: Material3NavigationParameters {
                tokens: root.sourceStyle.tokens
                reducedMotion: root.sourceStyle.effectiveReducedMotion
                role: root.expanded ? "navigationRailExpanded" : "navigationRailCollapsed"
            }
        }
        hovered { text.color: root.sourceStyle.tokens.surfaceForeground; background.color: root.sourceStyle.tokens.transparent }
        focused { text.color: root.sourceStyle.tokens.surfaceForeground; background.color: root.sourceStyle.tokens.transparent }
        pressed { text.color: root.sourceStyle.tokens.surfaceForeground; background.color: root.sourceStyle.tokens.transparent; background.radius: 0 }
        checked {
            text.color: root.sourceStyle.tokens.secondaryContainerForeground
            background.color: root.sourceStyle.tokens.secondaryContainer
            hovered.background.color: root.sourceStyle.tokens.secondaryContainer
            focused.background.color: root.sourceStyle.tokens.secondaryContainer
            pressed.background.color: root.sourceStyle.tokens.secondaryContainer
            hovered.text.color: root.sourceStyle.tokens.secondaryContainerForeground
            focused.text.color: root.sourceStyle.tokens.secondaryContainerForeground
            pressed.text.color: root.sourceStyle.tokens.secondaryContainerForeground
        }
        disabled {
            text.color: root.sourceStyle.tokens.disabledLabel
            background.color: root.sourceStyle.tokens.transparent
            checked {
                text.color: root.sourceStyle.tokens.disabledLabel
                background.color: root.sourceStyle.tokens.disabledContainer
            }
        }
    }
}
