// Geometry and state recipe: QmlMaterial 0.6.1, 191260585a829ee4ae2c99e6232b7145b5c34474 (MIT).
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Templates as T
import Qt.labs.StyleKit as SK
import Qavsi.Icons
import Qavsi.Material3.Theme

Rectangle {
    id: root
    required property T.Switch control
    required property SK.DelegateStyle delegateStyle
    readonly property Material3SwitchParameters parameters: delegateStyle.data as Material3SwitchParameters
    readonly property Material3Theme tokens: parameters.tokens
    readonly property bool hasIcon: control.icon.name.length > 0 || control.icon.source.toString().length > 0
    readonly property bool active: control.enabled && (control.pressed || control.hovered)
    readonly property bool feedbackEnabled: control.enabled && control.visible && control.opacity > 0
        && visible && opacity > 0 && Window.window && Window.window.visible
        && Window.window.visibility !== Window.Minimized
    readonly property bool canAnimate: ready && feedbackEnabled && control.SK.StyleKit.transitionsEnabled
        && !parameters.reducedMotion
    readonly property bool animateGeometry: canAnimate && !control.pressed
    property bool ready: false
    property real thumbSize: control.pressed && control.enabled ? tokens.switchThumbPressedDiameter
        : control.checked || hasIcon ? tokens.switchThumbCheckedDiameter : tokens.switchThumbUncheckedDiameter
    property real thumbPosition: control.visualPosition

    objectName: "material3.switch.indicator"
    width: parent.width
    height: parent.height
    implicitWidth: delegateStyle.width
    implicitHeight: delegateStyle.height
    color: delegateStyle.color
    radius: height / 2
    border.width: delegateStyle.border.width
    border.color: delegateStyle.border.color
    visible: delegateStyle.visible
    opacity: delegateStyle.opacity
    antialiasing: true
    Accessible.ignored: true
    LayoutMirroring.enabled: false
    LayoutMirroring.childrenInherit: false

    Component.onCompleted: ready = true
    onCanAnimateChanged: if (!canAnimate) {
        trackColorAnimation.complete()
        borderColorAnimation.complete()
        thumbColorAnimation.complete()
    }
    onAnimateGeometryChanged: if (!animateGeometry) {
        sizeAnimation.complete()
        positionAnimation.complete()
    }
    Behavior on color {
        enabled: root.canAnimate
        ColorAnimation { id: trackColorAnimation; duration: root.tokens.switchColorDuration }
    }
    Behavior on border.color {
        enabled: root.canAnimate
        ColorAnimation { id: borderColorAnimation; duration: root.tokens.switchColorDuration }
    }
    Behavior on thumbSize {
        enabled: root.animateGeometry
        NumberAnimation {
            id: sizeAnimation
            duration: root.tokens.switchMotionDuration
            easing.type: root.tokens.switchMotionEasing
        }
    }
    Behavior on thumbPosition {
        enabled: root.animateGeometry
        NumberAnimation {
            id: positionAnimation
            duration: root.tokens.switchMotionDuration
            easing.type: root.tokens.switchMotionEasing
        }
    }

    Rectangle {
        id: thumb
        objectName: "material3.switch.thumb"
        x: root.height / 2 + root.thumbPosition * Math.max(0, root.width - root.height) - width / 2
        y: (root.height - height) / 2
        width: Math.max(0, root.thumbSize)
        height: width
        radius: width / 2
        color: root.control.checked
            ? root.active ? root.tokens.switchCheckedActiveThumb : root.tokens.switchCheckedThumb
            : root.active ? root.tokens.switchActiveThumb : root.tokens.switchThumb
        opacity: root.control.enabled ? 1 : root.tokens.switchDisabledThumbOpacity
        antialiasing: true
        Behavior on color {
            enabled: root.canAnimate
            ColorAnimation { id: thumbColorAnimation; duration: root.tokens.switchColorDuration }
        }
        AppIcon {
            objectName: "material3.switch.icon"
            anchors.centerIn: parent
            visible: root.hasIcon
            name: root.control.icon.name
            source: root.control.icon.source
            width: Math.max(0, root.control.icon.width)
            height: Math.max(0, root.control.icon.height)
            size: Math.min(width, height)
            color: root.control.icon.color
            appearance: root.parameters.iconAppearance
        }
    }
    Material3Ripple {
        id: feedback
        x: thumb.x + thumb.width / 2 - width / 2
        y: (root.height - height) / 2
        width: root.tokens.switchStateLayerDiameter
        height: width
        control: root.control
        tokens: root.tokens
        reduceMotion: root.parameters.reducedMotion || !root.control.SK.StyleKit.transitionsEnabled
        rippleColor: root.control.checked ? root.tokens.switchCheckedStateLayer : root.tokens.switchStateLayer
        cornerRadius: width / 2
        cornerRadii: Qt.vector4d(cornerRadius, cornerRadius, cornerRadius, cornerRadius)
        feedbackEnabled: root.feedbackEnabled
        stateOpacity: root.control.hovered ? root.tokens.hoverOpacity : 0
        pressOpacity: root.tokens.interactionOpacity
        restartOnPress: true
        feedbackObjectName: "material3.switch.feedback"
    }
    Rectangle {
        x: feedback.x - root.tokens.focusRingGap - root.tokens.focusRingWidth
        y: feedback.y - root.tokens.focusRingGap - root.tokens.focusRingWidth
        width: feedback.width + (root.tokens.focusRingGap + root.tokens.focusRingWidth) * 2
        height: width
        radius: width / 2
        color: root.tokens.transparent
        border.width: root.tokens.focusRingWidth
        border.color: root.tokens.primary
        visible: root.feedbackEnabled && root.control.visualFocus
        antialiasing: true
    }
}
