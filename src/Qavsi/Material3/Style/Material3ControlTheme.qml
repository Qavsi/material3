pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme
import "Material3ButtonRecipe.js" as Recipe

SK.Theme {
    id: root
    required property Material3Theme tokens
    required property Material3Style sourceStyle
    readonly property Material3TextFieldVariations textFieldVariations: Material3TextFieldVariations { sourceStyle: root.sourceStyle }
    readonly property Material3ComboBoxVariations comboVariations: Material3ComboBoxVariations { sourceStyle: root.sourceStyle }
    readonly property Material3BadgeVariations badgeVariations: Material3BadgeVariations {
        sourceStyle: root.sourceStyle
    }
    readonly property Material3ListCardVariations listCardVariations: Material3ListCardVariations {
        sourceStyle: root.sourceStyle
    }
    readonly property Material3ChipVariations chipVariations: Material3ChipVariations {
        sourceStyle: root.sourceStyle
    }
    readonly property Material3DestinationVariation destinationVariation: Material3DestinationVariation { sourceStyle: root.sourceStyle }
    readonly property Material3AppNavigationVariations appNavigationVariations: Material3AppNavigationVariations { sourceStyle: root.sourceStyle }
    readonly property Material3NavigationVariations navigationVariations: Material3NavigationVariations {
        sourceStyle: root.sourceStyle
    }
    // Theme-local variations outrank the direct Theme button mapping in Qt 6.12.
    readonly property QtObject buttonVariations: ButtonVariations { sourceStyle: root.sourceStyle }
    readonly property QtObject advancedButtonVariations: Material3AdvancedButtonVariations { sourceStyle: root.sourceStyle }

    readonly property QtObject pickerVariations: Material3PickerVariations { sourceStyle: root.sourceStyle }

    readonly property ButtonVariation snackbarAction: ButtonVariation {
        name: "snackbarAction"
        sourceStyle: root.sourceStyle
        containerColor: root.tokens.transparent
        contentColor: root.tokens.inverseSurfaceForeground
    }
    readonly property Material3CarouselVariations carouselRecipes: Material3CarouselVariations { sourceStyle: root.sourceStyle }
    pageIndicator {
        padding: root.tokens.carouselPagePadding
        spacing: root.tokens.carouselPageSpacing
        background { width: 0; height: 0; visible: false; margins: 0 }
        indicator {
            visible: true
            opacity: 1
            fillWidth: false
            fillHeight: false
            gradient: null
            width: root.tokens.carouselPageSize
            height: root.tokens.carouselPageSize
            radius: root.tokens.carouselPageSize / 2
            margins: 0
            color: Qt.alpha(root.tokens.surfaceForeground, root.tokens.carouselPageOpacity)
            foreground.visible: false
            border.width: 0
            shadow.visible: false
        }
        checked.indicator.color: Qt.alpha(root.tokens.surfaceForeground, root.tokens.carouselPageSelectedOpacity)
        hovered.indicator.color: Qt.alpha(root.tokens.surfaceForeground, root.tokens.carouselPageHoverOpacity)
    }
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
    textField {
        leftPadding: root.tokens.textFieldHorizontalPadding
        rightPadding: root.tokens.textFieldHorizontalPadding
        topPadding: root.tokens.textFieldVerticalPadding
        bottomPadding: root.tokens.textFieldVerticalPadding
        text {
            color: root.tokens.surfaceForeground
            alignment: Qt.AlignLeft | Qt.AlignVCenter
        }
        background {
            width: root.tokens.textFieldMinimumWidth
            height: root.tokens.textFieldHeight
            radius: root.tokens.textFieldCornerRadius
            color: root.tokens.transparent
            gradient: null
            margins: 0
            border.width: root.tokens.textFieldOutlineWidth
            border.color: root.tokens.outline
            shadow.visible: false
        }
        hovered.background.border.color: root.tokens.surfaceForeground
        focused {
            background.border.width: root.tokens.textFieldFocusedOutlineWidth
            background.border.color: root.tokens.primary
        }
        disabled {
            text.color: root.tokens.disabledLabel
            background.border.color: root.tokens.disabledContainer
        }
    }
}
