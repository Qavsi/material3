pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK

QtObject {
    id: root
    required property Material3Style sourceStyle
    default property list<QtObject> registrations: [
        SK.StyleVariation {
            name: "navigationBar"
            tabBar {
                spacing: 0
                topPadding: 0; bottomPadding: 0; leftPadding: 0; rightPadding: 0
                background {
                    height: root.sourceStyle.tokens.navigationBarItemHeight
                    color: root.sourceStyle.tokens.surfaceContainer
                    data: Material3NavigationParameters {
                        tokens: root.sourceStyle.tokens
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
                spacing: root.sourceStyle.tokens.navigationBarLabelSpacing
                text.color: root.sourceStyle.tokens.surfaceVariantForeground
                text.second.color: root.sourceStyle.tokens.surfaceVariantForeground
                background {
                    width: root.sourceStyle.tokens.navigationBarIndicatorWidth
                    height: root.sourceStyle.tokens.navigationBarItemHeight
                    color: root.sourceStyle.tokens.transparent
                    data: Material3NavigationParameters {
                        tokens: root.sourceStyle.tokens
                        reducedMotion: root.sourceStyle.effectiveReducedMotion
                        role: "navigationBarItem"
                    }
                }
                hovered {
                    text.color: root.sourceStyle.tokens.surfaceForeground
                    text.second.color: root.sourceStyle.tokens.surfaceForeground
                }
                focused {
                    text.color: root.sourceStyle.tokens.surfaceForeground
                    text.second.color: root.sourceStyle.tokens.surfaceForeground
                }
                pressed {
                    text.color: root.sourceStyle.tokens.surfaceForeground
                    text.second.color: root.sourceStyle.tokens.surfaceForeground
                }
                checked {
                    text.color: root.sourceStyle.tokens.secondaryContainerForeground
                    text.second.color: root.sourceStyle.tokens.surfaceForeground
                    background.color: root.sourceStyle.tokens.secondaryContainer
                    hovered.text.color: root.sourceStyle.tokens.secondaryContainerForeground
                    focused.text.color: root.sourceStyle.tokens.secondaryContainerForeground
                    pressed.text.color: root.sourceStyle.tokens.secondaryContainerForeground
                }
                disabled {
                    text.color: root.sourceStyle.tokens.disabledLabel
                    text.second.color: root.sourceStyle.tokens.disabledLabel
                    background.color: root.sourceStyle.tokens.transparent
                    checked {
                        text.color: root.sourceStyle.tokens.disabledLabel
                        text.second.color: root.sourceStyle.tokens.disabledLabel
                        background.color: root.sourceStyle.tokens.disabledContainer
                    }
                }
            }
        },
        Material3NavigationRailVariation {
            name: "navigationRailCollapsed"
            sourceStyle: root.sourceStyle
        },
        Material3NavigationRailVariation {
            name: "navigationRailExpanded"
            sourceStyle: root.sourceStyle
            expanded: true
        },
        SK.StyleVariation { name: "tabPrimary" }
    ]
}
