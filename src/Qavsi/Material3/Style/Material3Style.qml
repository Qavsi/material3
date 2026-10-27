pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

SK.Style {
    id: root
    property Material3Theme lightTokens: Material3Theme { }
    property Material3Theme darkTokens: Material3Theme { dark: true }
    property bool reducedMotion: false
    readonly property bool effectiveReducedMotion: reducedMotion
        || Application.styleHints.accessibility.motionPreference === Qt.MotionPreference.ReducedMotion
    readonly property Material3Theme tokens: themeName === "Dark" ? darkTokens : lightTokens
    readonly property SmallButtonDelegate buttonDelegate: SmallButtonDelegate { }
    readonly property Material3MenuDelegate menuDelegate: Material3MenuDelegate { }
    readonly property Material3TextFieldDelegate textFieldDelegate: Material3TextFieldDelegate { }


    themeName: "Light"
    fonts.system: root.tokens.labelLarge
    fonts.button: root.tokens.labelLarge
    fonts.textField: root.tokens.bodyLarge
    textField {
        background {
            delegate: root.textFieldDelegate.background
            data: Material3TextFieldParameters {
                tokens: root.tokens
                reducedMotion: root.effectiveReducedMotion
            }
        }
    }
    button {
        background {
            data: SmallButtonParameters {
                tokens: root.tokens
                reduceMotion: root.effectiveReducedMotion
            }
            delegate: root.buttonDelegate.background
            shadow.delegate: root.buttonDelegate.shadow
        }
    }
    flatButton.background.delegate: root.buttonDelegate.background
    flatButton.background.shadow.delegate: root.buttonDelegate.shadow
    flatButton.background.data: root.button.background.data
    roundButton.background.delegate: root.buttonDelegate.background
    roundButton.background.shadow.delegate: root.buttonDelegate.shadow
    roundButton.background.data: root.button.background.data
    delayButton.background.delegate: root.buttonDelegate.background
    delayButton.background.shadow.delegate: root.buttonDelegate.shadow
    delayButton.background.data: root.button.background.data
    toolButton.background.delegate: root.buttonDelegate.background
    toolButton.background.shadow.delegate: root.buttonDelegate.shadow
    toolButton.background.data: root.button.background.data
    menu {
        leftPadding: 0
        rightPadding: 0
        topPadding: root.tokens.menuVerticalPadding
        bottomPadding: root.tokens.menuVerticalPadding
        spacing: 0
        background {
            width: root.tokens.menuMinimumWidth
            height: root.tokens.menuMinimumHeight
            radius: root.tokens.menuCornerRadius
            color: root.tokens.surfaceContainer
            gradient: null
            border.width: 0
            margins: 0
            data: Material3MenuParameters {
                tokens: root.tokens
                reducedMotion: root.effectiveReducedMotion
            }
            shadow {
                visible: true
                color: root.tokens.shadow
                opacity: root.tokens.elevationContainerOpacity
                delegate: root.menuDelegate.shadow
            }
        }
        focused {
            background {
                color: root.tokens.surfaceContainer
                border.width: 0
            }
        }
    }
    menuItem {
        leftPadding: root.tokens.menuItemHorizontalPadding
        rightPadding: root.tokens.menuItemHorizontalPadding
        topPadding: 0
        bottomPadding: 0
        spacing: root.tokens.menuItemSpacing
        text.color: root.tokens.surfaceForeground
        background {
            width: root.tokens.menuMinimumWidth
            height: root.tokens.menuItemHeight
            radius: 0
            color: root.tokens.transparent
            gradient: null
            border.width: 0
            margins: 0
            shadow.visible: false
            data: root.menu.background.data
            delegate: root.menuDelegate.itemBackground
        }
        hovered.background.color: root.tokens.transparent
        highlighted.background.color: root.tokens.transparent
        focused.background.color: root.tokens.transparent
        pressed.background.color: root.tokens.transparent
        checked {
            background.color: root.tokens.secondaryContainer
            hovered.background.color: root.tokens.secondaryContainer
            highlighted.background.color: root.tokens.secondaryContainer
            focused.background.color: root.tokens.secondaryContainer
            pressed.background.color: root.tokens.secondaryContainer
        }
        disabled {
            text.color: root.tokens.disabledLabel
            background.color: root.tokens.transparent
            checked.background.color: root.tokens.secondaryContainer
        }
    }
    light: SmallButtonTheme { tokens: root.lightTokens; sourceStyle: root }
    dark: SmallButtonTheme { tokens: root.darkTokens; sourceStyle: root }
}
