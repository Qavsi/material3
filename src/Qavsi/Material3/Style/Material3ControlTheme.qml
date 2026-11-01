pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme
import "Material3ButtonRecipe.js" as Recipe

SK.Theme {
    id: root
    required property Material3Theme tokens
    required property Material3Style sourceStyle
    readonly property Material3TextFieldVariations textFieldVariations: Material3TextFieldVariations { sourceStyle: root.sourceStyle; tokens: root.tokens }
    readonly property Material3ComboBoxVariations comboVariations: Material3ComboBoxVariations { sourceStyle: root.sourceStyle; tokens: root.tokens }
    readonly property Material3BadgeVariations badgeVariations: Material3BadgeVariations {
        sourceStyle: root.sourceStyle; tokens: root.tokens
    }
    readonly property Material3ListCardVariations listCardVariations: Material3ListCardVariations {
        sourceStyle: root.sourceStyle; tokens: root.tokens
    }
    readonly property Material3ColorChoiceVariation colorChoice: Material3ColorChoiceVariation { sourceStyle: root.sourceStyle; tokens: root.tokens }
    readonly property Material3ChipVariations chipVariations: Material3ChipVariations {
        sourceStyle: root.sourceStyle
        tokens: root.tokens
    }
    readonly property Material3DestinationVariation destinationVariation: Material3DestinationVariation { sourceStyle: root.sourceStyle; tokens: root.tokens }
    readonly property Material3SheetVariations sheetVariations: Material3SheetVariations { tokens: root.tokens }
    readonly property Material3AppNavigationVariations appNavigationVariations: Material3AppNavigationVariations { sourceStyle: root.sourceStyle; tokens: root.tokens }
    readonly property Material3NavigationVariations navigationVariations: Material3NavigationVariations {
        sourceStyle: root.sourceStyle; tokens: root.tokens
    }
    // Theme-local variations outrank the direct Theme button mapping in Qt 6.12.
    readonly property QtObject buttonVariations: ButtonVariations { sourceStyle: root.sourceStyle; tokens: root.tokens }
    readonly property QtObject advancedButtonVariations: Material3AdvancedButtonVariations { sourceStyle: root.sourceStyle; tokens: root.tokens }

    readonly property QtObject pickerVariations: Material3PickerVariations { sourceStyle: root.sourceStyle; tokens: root.tokens }

    readonly property ButtonVariation snackbarAction: ButtonVariation {
        name: "snackbarAction"
        sourceStyle: root.sourceStyle; tokens: root.tokens
        containerColor: root.tokens.transparent
        contentColor: root.tokens.inverseSurfaceForeground
    }
    readonly property Material3CarouselVariations carouselRecipes: Material3CarouselVariations { sourceStyle: root.sourceStyle; tokens: root.tokens }
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
    label { text.color: root.tokens.surfaceForeground; disabled.text.color: root.tokens.disabledLabel }
    textArea {
        leftPadding: root.tokens.textFieldHorizontalPadding
        rightPadding: root.tokens.textFieldHorizontalPadding
        topPadding: root.tokens.textFieldVerticalPadding
        bottomPadding: root.tokens.textFieldVerticalPadding
        text {
            color: root.tokens.surfaceForeground
            alignment: Qt.AlignLeft | Qt.AlignTop
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
            data: Material3TextFieldParameters { tokens: root.tokens; reducedMotion: root.sourceStyle.effectiveReducedMotion }
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
    spinBox {
        leftPadding: root.tokens.spinBoxTextInset
        rightPadding: root.tokens.spinBoxIndicatorInset
        topPadding: 0; bottomPadding: 0
        spacing: 0
        text { color: root.tokens.surfaceForeground; alignment: Qt.AlignRight | Qt.AlignVCenter; padding: 0 }
        background {
            width: root.tokens.spinBoxMinimumWidth; height: root.tokens.spinBoxHeight
            color: root.tokens.surfaceContainerHighest
            radius: root.tokens.radiusExtraSmall
            margins: 0; border.width: 0; gradient: null; shadow.visible: false
            data: root.tokens
        }
        indicator {
            first {
                width: root.tokens.spinBoxIndicatorWidth
                height: (root.tokens.spinBoxHeight - root.tokens.spinBoxIndicatorInset * 2) / 2
                alignment: Qt.AlignRight | Qt.AlignTop
                margins: root.tokens.spinBoxIndicatorInset
                leftMargin: 0
                fillWidth: false; fillHeight: false
                color: root.tokens.transparent
                data: root.tokens
            }
            second {
                width: root.tokens.spinBoxIndicatorWidth
                height: (root.tokens.spinBoxHeight - root.tokens.spinBoxIndicatorInset * 2) / 2
                alignment: Qt.AlignRight | Qt.AlignBottom
                margins: root.tokens.spinBoxIndicatorInset
                leftMargin: 0
                // Share one native stepper column instead of reserving two horizontal slots.
                rightMargin: -root.tokens.spinBoxIndicatorWidth
                fillWidth: false; fillHeight: false
                color: root.tokens.transparent
                data: root.tokens
            }
        }
        hovered {
            indicator.first.color: Qt.alpha(root.tokens.surfaceForeground, root.tokens.hoverOpacity)
            indicator.second.color: Qt.alpha(root.tokens.surfaceForeground, root.tokens.hoverOpacity)
        }
        pressed {
            indicator.first.color: Qt.alpha(root.tokens.surfaceForeground, root.tokens.rippleOpacity)
            indicator.second.color: Qt.alpha(root.tokens.surfaceForeground, root.tokens.rippleOpacity)
        }
        focused { background.border.width: root.tokens.focusRingWidth; background.border.color: root.tokens.primary }
        disabled { text.color: root.tokens.disabledLabel; background.color: root.tokens.disabledContainer }
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
