pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Templates as T
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

Transition {
    id: root
    objectName: "material3.menu.exit"
    required property T.Popup control
    readonly property Material3Style sourceStyle: root.control ? root.control.SK.StyleKit.style as Material3Style : null
    readonly property Material3Theme tokens: root.sourceStyle ? root.sourceStyle.tokens : null
    readonly property bool motionEnabled: root.sourceStyle !== null
        && !root.sourceStyle.effectiveReducedMotion && root.control.SK.StyleKit.transitionsEnabled
    readonly property int effectiveDuration: root.motionEnabled ? root.tokens.menuExitDuration : 0

    // Leave from unset so interrupted entry continues from the current popup values.
    NumberAnimation {
        objectName: "material3.menu.exit.opacity"
        property: "opacity"
        to: 0
        duration: root.effectiveDuration
        easing.type: root.tokens ? Easing.BezierSpline : Easing.Linear
        easing.bezierCurve: root.tokens ? root.tokens.menuExitEasingCurve : []
    }
    NumberAnimation {
        objectName: "material3.menu.exit.scale"
        property: "scale"
        to: root.tokens ? root.tokens.menuClosedScale : 1
        duration: root.effectiveDuration
        easing.type: root.tokens ? Easing.BezierSpline : Easing.Linear
        easing.bezierCurve: root.tokens ? root.tokens.menuExitEasingCurve : []
    }
}
