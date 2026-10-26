pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import "Material3ButtonRecipe.js" as Recipe

SK.StyleVariation {
    id: root
    required property Material3Style sourceStyle
    required property real paintHeight
    required property real minimumIconSize
    required property real pressedRadius
    property real horizontalPadding: sourceStyle.tokens.smallHorizontalPadding
    property real cornerRadius: paintHeight / 2
    property real contentSpacing: sourceStyle.tokens.smallSpacing
    readonly property SmallButtonParameters parameters: SmallButtonParameters {
        tokens: root.sourceStyle.tokens
        reduceMotion: root.sourceStyle.effectiveReducedMotion
        minimumIconSize: root.minimumIconSize
        paintHeight: root.paintHeight
    }
    control {
        spacing: root.contentSpacing
        leftPadding: root.horizontalPadding
        rightPadding: root.horizontalPadding
        topPadding: 0
        bottomPadding: 0
        background {
            width: Recipe.minimumWidth
            height: Math.max(root.sourceStyle.tokens.minimumTargetSize, root.paintHeight)
            radius: root.cornerRadius
            data: root.parameters
        }
        pressed.background.radius: root.pressedRadius
    }
}
