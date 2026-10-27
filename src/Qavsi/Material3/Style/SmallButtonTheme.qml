pragma ComponentBehavior: Bound
import QtQuick
import "Material3ButtonRecipe.js" as Recipe

Material3TextFieldTheme {
    id: root
    readonly property Material3ChipVariations chipVariations: Material3ChipVariations {
        sourceStyle: root.sourceStyle
    }
    readonly property Material3NavigationVariations navigationVariations: Material3NavigationVariations {
        sourceStyle: root.sourceStyle
    }
    // Theme-local variations outrank the direct Theme button mapping in Qt 6.12.
    readonly property QtObject buttonVariations: ButtonVariations { sourceStyle: root.sourceStyle }
    readonly property QtObject advancedButtonVariations: Material3AdvancedButtonVariations { sourceStyle: root.sourceStyle }

    applicationWindow.background.color: tokens.surface
    button {
        leftPadding: root.tokens.smallHorizontalPadding
        rightPadding: root.tokens.smallHorizontalPadding
        topPadding: root.tokens.smallVerticalPadding
        bottomPadding: root.tokens.smallVerticalPadding
        spacing: root.tokens.smallSpacing
        text {
            color: root.tokens.primaryForeground
            alignment: Qt.AlignCenter
            padding: 0
        }
        background {
            width: Recipe.minimumWidth
            height: root.tokens.smallHeight
            radius: root.tokens.smallRadius
            margins: 0
            border.width: 0
            color: root.tokens.primary
            gradient: null
            shadow {
                visible: false
                color: root.tokens.shadow
                opacity: root.tokens.elevationContainerOpacity
            }
        }
        hovered.background.color: root.tokens.primary
        focused.background.color: root.tokens.primary
        pressed.background.color: root.tokens.primary
        pressed.background.radius: root.tokens.radiusSmall
        checked.background.color: root.tokens.primary
        disabled {
            background.color: root.tokens.disabledContainer
            text.color: root.tokens.disabledLabel
            background.shadow.visible: false
        }
    }
    flatButton {
        text.color: root.tokens.primary
        background {
            color: root.tokens.transparent
            radius: root.tokens.smallRadius
            border.width: 0
            shadow.visible: false
        }
        hovered {
            background.color: root.tokens.transparent
            background.border.width: 0
            background.shadow.visible: false
        }
        focused {
            background.color: root.tokens.transparent
            background.border.width: 0
        }
        pressed {
            background.color: root.tokens.transparent
            background.border.width: 0
            background.radius: root.tokens.radiusSmall
        }
        disabled {
            background.color: root.tokens.transparent
            background.border.width: 0
        }
    }
}
