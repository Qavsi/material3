pragma ComponentBehavior: Bound
import QtQuick
import "Material3IconButtonRecipe.js" as Recipe

ButtonVariation {
    id: root
    readonly property SmallButtonParameters iconParameters: SmallButtonParameters {
        tokens: root.sourceStyle.tokens
        reduceMotion: root.sourceStyle.effectiveReducedMotion
        minimumIconSize: Recipe.small.iconSize
        fillIconWhenChecked: true
    }
    control {
        padding: root.sourceStyle.tokens.iconButtonPadding
        spacing: 0
        background {
            data: root.iconParameters
            width: Recipe.small.defaultWidth
            height: Recipe.small.containerHeight
            radius: Recipe.small.containerHeight / 2
            margins: root.sourceStyle.tokens.iconButtonInset
        }
        pressed.background.radius: root.sourceStyle.tokens.radiusSmall
        checked.background.radius: root.sourceStyle.tokens.radiusMedium
        checked.pressed.background.radius: root.sourceStyle.tokens.radiusSmall
        checked.background.border.width: root.outlined ? root.sourceStyle.tokens.outlineWidth : 0
        disabled.checked.background.color: root.transparentContainer
            ? root.sourceStyle.tokens.transparent : root.sourceStyle.tokens.disabledContainer
    }
}
