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


    themeName: "Light"
    fonts.button: tokens.labelLarge
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
    light: SmallButtonTheme { tokens: root.lightTokens; sourceStyle: root }
    dark: SmallButtonTheme { tokens: root.darkTokens; sourceStyle: root }
}
