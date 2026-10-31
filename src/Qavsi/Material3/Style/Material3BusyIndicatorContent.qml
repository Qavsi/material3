pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK

// Optional native content override when an operation needs its own timing policy.
Material3BusyIndicatorVisual {
    readonly property Material3Style materialStyle: control.SK.StyleKit.style as Material3Style
    tokens: materialStyle.tokens
    reducedMotion: materialStyle.effectiveReducedMotion
}
