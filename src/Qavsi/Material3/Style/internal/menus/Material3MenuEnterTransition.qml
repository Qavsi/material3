pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Templates as T
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

Transition {
    id: root
    objectName: "material3.menu.enter"
    required property T.Menu control
    readonly property Material3Style sourceStyle: root.control ? root.control.SK.StyleKit.style as Material3Style : null
    readonly property Material3Theme tokens: root.sourceStyle ? root.sourceStyle.tokens : null
    readonly property bool motionEnabled: root.sourceStyle !== null
        && !root.sourceStyle.effectiveReducedMotion && root.control.SK.StyleKit.transitionsEnabled
    readonly property int effectiveDuration: root.motionEnabled ? root.tokens.menuEnterDuration : 0

    // Native Transition owns its jobs; duration changes apply to the next preparation.
    NumberAnimation {
        objectName: "material3.menu.enter.opacity"
        property: "opacity"
        from: 0
        to: 1
        duration: root.effectiveDuration
        easing.type: root.tokens ? Easing.BezierSpline : Easing.Linear
        easing.bezierCurve: root.tokens ? root.tokens.menuEnterEasingCurve : []
    }
    NumberAnimation {
        objectName: "material3.menu.enter.scale"
        property: "scale"
        from: root.tokens ? root.tokens.menuClosedScale : 1
        to: root.tokens ? root.tokens.menuOpenScale : 1
        duration: root.effectiveDuration
        easing.type: root.tokens ? Easing.BezierSpline : Easing.Linear
        easing.bezierCurve: root.tokens ? root.tokens.menuEnterEasingCurve : []
    }
}
