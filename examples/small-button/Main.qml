pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Style

SK.ApplicationWindow {
    id: root
    objectName: "smallButtonWindow"
    required property rect previewArea
    width: 620
    height: 440
    x: previewArea.x + (previewArea.width - width) / 2
    y: previewArea.y + (previewArea.height - height) / 2
    title: qsTr("Qavsi · Material3 Small Button")
    visible: true
    property bool darkMode: false
    property bool reducedMotion: false
    readonly property Material3Style materialStyle: Material3Style {
        themeName: root.darkMode ? "Dark" : "Light"
        reducedMotion: root.reducedMotion
    }
    SK.StyleKit.style: materialStyle
    SK.StyleKit.transitionsEnabled: false
    SmallButtonPage {
        anchors.fill: parent
        tokens: root.materialStyle.tokens
        darkMode: root.darkMode
        reducedMotion: root.materialStyle.effectiveReducedMotion
        onToggleTheme: root.darkMode = !root.darkMode
        onToggleMotion: root.reducedMotion = !root.reducedMotion
    }
}
