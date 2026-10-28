pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Templates as T
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

Transition {
    id: root
    required property T.Popup control
    readonly property Material3Style sourceStyle: root.control.SK.StyleKit.style as Material3Style
    readonly property Material3Theme tokens: root.sourceStyle.tokens
    readonly property bool motionEnabled: !root.sourceStyle.effectiveReducedMotion
        && root.control.SK.StyleKit.transitionsEnabled
    NumberAnimation {
        property: "scale"
        from: root.tokens.dialogClosedScale
        to: 1
        duration: root.motionEnabled ? root.tokens.dialogEnterDuration : 0
        easing.type: Easing.BezierSpline
        easing.bezierCurve: root.tokens.menuEnterEasingCurve
    }
    NumberAnimation {
        property: "opacity"
        from: 0
        to: 1
        duration: root.motionEnabled ? root.tokens.dialogFadeDuration : 0
    }
}
