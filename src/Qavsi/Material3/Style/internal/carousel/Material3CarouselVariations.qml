pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

QtObject {
    id: root
    required property Material3Style sourceStyle
    property Material3Theme tokens: sourceStyle.tokens
    readonly property SK.StyleVariation carousel: SK.StyleVariation {
        name: "carousel"
        pane {
            padding: 0
            background { width: 0; height: 0; visible: false; margins: 0 }
        }
    }
    readonly property ButtonVariation item: ButtonVariation {
        name: "carouselItem"
        sourceStyle: root.sourceStyle
        tokens: root.tokens
        containerColor: root.tokens.transparent
        contentColor: root.tokens.carouselImageForeground
        checkedContainerColor: containerColor
        checkedContentColor: contentColor
        button {
            padding: 0
            background { width: 0; height: 0; margins: 0; radius: root.tokens.carouselItemCorner }
            hovered.background.radius: root.tokens.carouselItemCorner
            pressed.background.radius: root.tokens.carouselItemCorner
            checked.background.radius: root.tokens.carouselItemCorner
        }
    }
}
