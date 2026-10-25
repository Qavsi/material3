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
        }
    }
    light: SmallButtonTheme { tokens: root.lightTokens }
    dark: SmallButtonTheme { tokens: root.darkTokens }
}
