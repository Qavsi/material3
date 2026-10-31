pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

QtObject {
    id: root
    required property Material3Style sourceStyle
    property Material3Theme tokens: sourceStyle.tokens
    default property list<QtObject> registrations: [
        SK.StyleVariation {
            name: "navigationBar"
            tabBar {
                spacing: 0
                topPadding: 0; bottomPadding: 0; leftPadding: 0; rightPadding: 0
                background {
                    height: root.tokens.navigationBarItemHeight
                    color: root.tokens.surfaceContainer
                    data: Material3NavigationParameters {
                        tokens: root.tokens
                        reducedMotion: root.sourceStyle.effectiveReducedMotion
                        role: "navigationBar"
                    }
                }
            }
        },
        SK.StyleVariation {
            name: "navigationBarItem"
            tabButton {
                topPadding: 0; bottomPadding: 0; leftPadding: 0; rightPadding: 0
                spacing: root.tokens.navigationBarLabelSpacing
                text.color: root.tokens.surfaceVariantForeground
                text.second.color: root.tokens.surfaceVariantForeground
                background {
                    width: root.tokens.navigationBarIndicatorWidth
                    height: root.tokens.navigationBarItemHeight
                    color: root.tokens.transparent
                    data: Material3NavigationParameters {
                        tokens: root.tokens
                        reducedMotion: root.sourceStyle.effectiveReducedMotion
                        role: "navigationBarItem"
                    }
                }
                hovered {
                    text.color: root.tokens.surfaceForeground
                    text.second.color: root.tokens.surfaceForeground
                }
                focused {
                    text.color: root.tokens.surfaceForeground
                    text.second.color: root.tokens.surfaceForeground
                }
                pressed {
                    text.color: root.tokens.surfaceForeground
                    text.second.color: root.tokens.surfaceForeground
                }
                checked {
                    text.color: root.tokens.secondaryContainerForeground
                    text.second.color: root.tokens.surfaceForeground
                    background.color: root.tokens.secondaryContainer
                    hovered.text.color: root.tokens.secondaryContainerForeground
                    focused.text.color: root.tokens.secondaryContainerForeground
                    pressed.text.color: root.tokens.secondaryContainerForeground
                }
                disabled {
                    text.color: root.tokens.disabledLabel
                    text.second.color: root.tokens.disabledLabel
                    background.color: root.tokens.transparent
                    checked {
                        text.color: root.tokens.disabledLabel
                        text.second.color: root.tokens.disabledLabel
                        background.color: root.tokens.disabledContainer
                    }
                }
            }
        },
        Material3NavigationRailVariation {
            name: "navigationRailCollapsed"
            sourceStyle: root.sourceStyle
            tokens: root.tokens
        },
        Material3NavigationRailVariation {
            name: "navigationRailExpanded"
            sourceStyle: root.sourceStyle
            tokens: root.tokens
            expanded: true
        },
        SK.StyleVariation { name: "tabPrimary" }
    ]
}
