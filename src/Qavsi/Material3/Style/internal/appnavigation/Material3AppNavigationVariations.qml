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
            name: "appNavigationSurface"
            pane {
                padding: 0
                background {
                    color: root.tokens.surface
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
                leftPadding: root.tokens.searchMetrics.horizontalPadding
                rightPadding: root.tokens.searchMetrics.horizontalPadding
                topPadding: 0; bottomPadding: 0
                text { color: root.tokens.surfaceForeground; alignment: Qt.AlignLeft | Qt.AlignVCenter }
                background {
                    width: root.tokens.searchMinimumWidth
                    height: root.tokens.searchHeight
                    color: root.tokens.surfaceContainerHighest
                    radius: root.tokens.searchHeight / 2
                    border.width: 0
                    margins: 0
                    shadow.visible: false
                    delegate: root.sourceStyle.appNavigationFactory.searchBackground
                    data: Material3TextFieldParameters {
                        tokens: root.tokens
                        reducedMotion: root.sourceStyle.effectiveReducedMotion
                        metrics: root.tokens.searchMetrics
                    }
                }
                hovered.background.border.width: 0
                focused.background.border.width: 0
                disabled {
                    text.color: root.tokens.disabledLabel
                    background.color: root.tokens.disabledContainer
                }
            }
        }
    ]
}
