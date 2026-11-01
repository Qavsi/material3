pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

QtObject {
    id: root
    required property Material3Theme tokens
    default property list<QtObject> registrations: [
        SK.StyleVariation {
            name: "bottomSheetSurface"
            pane {
                padding: 0
                background {
                    color: root.tokens.surfaceContainerLow
                    topLeftRadius: root.tokens.radiusExtraLarge; topRightRadius: root.tokens.radiusExtraLarge
                    bottomLeftRadius: 0; bottomRightRadius: 0
                    border.width: 0; gradient: null; margins: 0; shadow.visible: false
                }
            }
        }
    ]
}
