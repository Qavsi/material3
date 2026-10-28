pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK

QtObject {
    id: root
    required property Material3Style sourceStyle
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
        containerColor: root.sourceStyle.tokens.transparent
        contentColor: root.sourceStyle.tokens.carouselImageForeground
        checkedContainerColor: containerColor
        checkedContentColor: contentColor
        button {
            padding: 0
            background { width: 0; height: 0; margins: 0; radius: root.sourceStyle.tokens.carouselItemCorner }
            hovered.background.radius: root.sourceStyle.tokens.carouselItemCorner
            pressed.background.radius: root.sourceStyle.tokens.carouselItemCorner
            checked.background.radius: root.sourceStyle.tokens.carouselItemCorner
        }
    }
}
