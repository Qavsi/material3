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
    readonly property Material3Style materialStyle: Material3Style {
        themeName: root.darkMode ? "Dark" : "Light"
        reducedMotion: root.reducedMotion
        lightTokens: Material3Theme {
            dynamicColors: true
            seedColor: "#bee7fd"
            scheme: MaterialColorScheme.Neutral
        }
        darkTokens: Material3Theme {
            dark: true
            dynamicColors: true
            seedColor: "#bee7fd"
            scheme: MaterialColorScheme.Neutral
        }
    }
    SK.StyleKit.style: materialStyle
    SK.StyleKit.transitionsEnabled: !materialStyle.effectiveReducedMotion
    ComparisonPage {
        anchors.fill: parent
        tokens: root.materialStyle.tokens
        darkMode: root.darkMode
        reducedMotion: root.materialStyle.effectiveReducedMotion
        onToggleTheme: root.darkMode = !root.darkMode
        onToggleMotion: root.reducedMotion = !root.reducedMotion
    }
}
