pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Style
import Qavsi.Material3.Theme

SK.ApplicationWindow {
    id: root
    objectName: "comparison.window"
    required property rect previewArea
    width: Math.min(900, previewArea.width / 2 - 16)
    height: Math.min(940, previewArea.height - 32)
    x: previewArea.x + 8
    y: previewArea.y + 16
    title: qsTr("Qavsi Material3 · QmlMaterial comparison")
    visible: true
    property bool darkMode: false
    property bool reducedMotion: false
    property color seedColor: appearanceOptions.defaultSeedColor
    property int colorScheme: MaterialColorScheme.Neutral
    readonly property AppearanceOptions appearanceOptions: AppearanceOptions { }
    readonly property Material3Style materialStyle: Material3Style {
        themeName: root.darkMode ? "Dark" : "Light"
        reducedMotion: root.reducedMotion
        lightTokens: Material3Theme {
            dynamicColors: true
            seedColor: root.seedColor
            scheme: root.colorScheme
        }
        darkTokens: Material3Theme {
            dark: true
            dynamicColors: true
            seedColor: root.seedColor
            scheme: root.colorScheme
        }
    }
    SK.StyleKit.style: materialStyle
    SK.StyleKit.transitionsEnabled: !materialStyle.effectiveReducedMotion
    // Qt 6.12: keep variation readers alive before the first Theme reset.
    ThemePanel {
        id: appearancePanel
        parent: root.contentItem
        width: Math.min(root.width, root.materialStyle.tokens.appNavigationSheetWidth)
        height: root.height
        tokens: root.materialStyle.tokens
        reducedMotion: root.materialStyle.effectiveReducedMotion
        choices: root.appearanceOptions
        seedColor: root.seedColor
        colorScheme: root.colorScheme
        darkMode: root.darkMode
        onSeedColorChangeRequested: value => root.seedColor = value
        onColorSchemeChangeRequested: value => root.colorScheme = value
        onDarkModeChangeRequested: value => root.darkMode = value
    }
    ComparisonPage {
        anchors.fill: parent
        tokens: root.materialStyle.tokens
        onAppearanceRequested: appearancePanel.open()
    }
}
