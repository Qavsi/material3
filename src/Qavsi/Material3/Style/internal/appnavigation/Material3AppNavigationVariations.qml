pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK

QtObject {
    id: root
    required property Material3Style sourceStyle
    default property list<QtObject> registrations: [
        SK.StyleVariation {
            name: "appNavigationSurface"
            pane {
                padding: 0
                background {
                    color: root.sourceStyle.tokens.surface
                    radius: 0
                    gradient: null
                    border.width: 0
                    shadow.visible: false
                }
            }
        },
        SK.StyleVariation {
            name: "searchField"
            textField {
                leftPadding: root.sourceStyle.tokens.searchMetrics.horizontalPadding
                rightPadding: root.sourceStyle.tokens.searchMetrics.horizontalPadding
                topPadding: 0; bottomPadding: 0
                text { color: root.sourceStyle.tokens.surfaceForeground; alignment: Qt.AlignLeft | Qt.AlignVCenter }
                background {
                    width: root.sourceStyle.tokens.searchMinimumWidth
                    height: root.sourceStyle.tokens.searchHeight
                    color: root.sourceStyle.tokens.surfaceContainerHighest
                    radius: root.sourceStyle.tokens.searchHeight / 2
                    border.width: 0
                    margins: 0
                    shadow.visible: false
                    delegate: root.sourceStyle.appNavigationFactory.searchBackground
                    data: Material3TextFieldParameters {
                        tokens: root.sourceStyle.tokens
                        reducedMotion: root.sourceStyle.effectiveReducedMotion
                        metrics: root.sourceStyle.tokens.searchMetrics
                    }
                }
                hovered.background.border.width: 0
                focused.background.border.width: 0
                disabled {
                    text.color: root.sourceStyle.tokens.disabledLabel
                    background.color: root.sourceStyle.tokens.disabledContainer
                }
            }
        }
    ]
}
