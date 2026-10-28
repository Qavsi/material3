pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK

Material3ProgressVisual {
    id: root
    readonly property Material3Style materialStyle: control.SK.StyleKit.style as Material3Style
    tokens: materialStyle.tokens
    reducedMotion: materialStyle.effectiveReducedMotion
    // shortcut: Qt 6.12.0 retains default-content Connections; remove after an upstream mode-switch fix.
    property real firstProgress: 0
    property real secondProgress: 0
    readonly property QtObject indeterminateAnim: QtObject {
        function restart(): void { }
        function stop(): void { }
    }
}
