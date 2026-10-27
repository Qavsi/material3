// State recipe: QmlMaterial 0.6.1, 191260585a829ee4ae2c99e6232b7145b5c34474 (MIT).
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Templates as T
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

Item {
    id: root
    required property T.AbstractButton control
    required property SK.DelegateStyle delegateStyle
    readonly property Material3ChipParameters parameters: delegateStyle.data as Material3ChipParameters
    readonly property Material3Theme tokens: parameters.tokens
    readonly property bool selected: control.checked
        && (parameters.kind === "filter" || parameters.kind === "input" || parameters.kind === "embed")
    readonly property color ink: !control.enabled ? tokens.disabledLabel
        : selected ? tokens.chipSelectedInk : parameters.kind === "assist" ? tokens.chipAssistInk : tokens.chipInk
    readonly property real cornerRadius: Math.max(0, Math.min(delegateStyle.radius, Math.min(width, height) / 2))
    readonly property vector4d cornerRadii: Qt.vector4d(cornerRadius, cornerRadius, cornerRadius, cornerRadius)
    readonly property bool feedbackEnabled: control.enabled && control.visible && control.opacity > 0
        && visible && opacity > 0 && Window.window && Window.window.visible
        && Window.window.visibility !== Window.Minimized
    readonly property bool canAnimate: feedbackEnabled && !parameters.reducedMotion
        && control.SK.StyleKit.transitionsEnabled
    readonly property bool focusVisible: feedbackEnabled && control.visualFocus && !ripple.pointerFocus
    readonly property real focusOutset: tokens.focusRingGap + tokens.focusRingWidth

    objectName: "material3.chip.background"
    width: parent.width
    height: parent.height
    implicitWidth: delegateStyle.width
    implicitHeight: delegateStyle.height
    visible: delegateStyle.visible
    opacity: delegateStyle.opacity
    Accessible.ignored: true

    Material3Elevation {
        anchors.fill: parent
        tokens: root.tokens
        reducedMotion: !root.canAnimate
        color: root.tokens.shadow
        cornerRadii: root.cornerRadii
        targetElevation: root.feedbackEnabled && root.selected && root.control.hovered
            && !root.control.pressed && !root.control.visualFocus
                ? root.tokens.elevationLevel1 : root.tokens.elevationLevel0
    }
    Rectangle {
        anchors.fill: parent
        radius: root.cornerRadius
        color: root.delegateStyle.color
        border.width: root.delegateStyle.border.width
        border.color: root.focusVisible && !root.selected ? root.ink : root.delegateStyle.border.color
        antialiasing: true
    }
    Material3Ripple {
        id: ripple
        anchors.fill: parent
        control: root.control
        tokens: root.tokens
        reduceMotion: root.parameters.reducedMotion || !root.control.SK.StyleKit.transitionsEnabled
        rippleColor: root.ink
        cornerRadius: root.cornerRadius
        cornerRadii: root.cornerRadii
        feedbackEnabled: root.feedbackEnabled
        stateOpacity: root.focusVisible ? root.tokens.interactionOpacity
            : root.control.hovered ? root.tokens.hoverOpacity : 0
        pressOpacity: root.tokens.interactionOpacity
        restartOnPress: true
        feedbackObjectName: "material3.chip.feedback"
    }
    Rectangle {
        x: -root.focusOutset
        y: -root.focusOutset
        width: parent.width + root.focusOutset * 2
        height: parent.height + root.focusOutset * 2
        radius: root.cornerRadius + root.focusOutset
        color: root.tokens.transparent
        border.width: root.tokens.focusRingWidth
        border.color: root.tokens.primary
        visible: root.focusVisible
        antialiasing: true
    }
}
