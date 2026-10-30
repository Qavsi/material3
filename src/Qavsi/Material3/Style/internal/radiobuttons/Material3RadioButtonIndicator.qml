// Geometry and state recipe: QmlMaterial 0.6.1, 191260585a829ee4ae2c99e6232b7145b5c34474 (MIT).
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Templates as T
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

Item {
    id: root
    required property T.RadioButton control
    required property SK.DelegateStyle delegateStyle
    readonly property Material3RadioButtonParameters parameters: delegateStyle.data as Material3RadioButtonParameters
    readonly property Material3Theme tokens: parameters.tokens
    readonly property bool active: control.hovered || control.pressed || control.visualFocus
    readonly property color ink: parameters.colorChoice ? control.palette.button
        : !control.enabled ? tokens.radioDisabledIndicator
        : control.checked ? tokens.radioCheckedIndicator : active ? tokens.radioActiveIndicator : tokens.radioIndicator
    readonly property color stateLayerColor: control.pressed
        ? control.checked ? tokens.radioCheckedPressedStateLayer : tokens.radioPressedStateLayer
        : control.checked ? tokens.radioCheckedStateLayer : tokens.radioStateLayer
    readonly property bool feedbackEnabled: control.enabled && control.visible && control.opacity > 0
        && visible && opacity > 0 && Window.window && Window.window.visible
        && Window.window.visibility !== Window.Minimized
    readonly property bool canAnimate: ready && feedbackEnabled && control.SK.StyleKit.transitionsEnabled
        && !parameters.reducedMotion
    property real selectionProgress: control.checked ? 1 : 0
    property bool ready: false

    objectName: "material3.radio.indicator"
    width: parent.width
    height: parent.height
    implicitWidth: delegateStyle.width
    implicitHeight: delegateStyle.height
    visible: delegateStyle.visible
    opacity: delegateStyle.opacity
    Accessible.ignored: true

    Binding {
        target: root.control.Accessible
        property: "readOnly"
        value: true
        when: root.control.RadioButtonSupport.readOnly
    }
    // Keep action handlers installed: unloading them does not restore Qt 6.12's default action.
    Connections {
        target: root.control.Accessible
        function onPressAction(): void { root.activateAccessible() }
        function onToggleAction(): void { root.activateAccessible() }
    }
    function activateAccessible(): void {
        if (root.control.enabled && !root.control.RadioButtonSupport.readOnly)
            root.control.click()
    }
    Component.onCompleted: ready = true
    onCanAnimateChanged: if (!canAnimate) selectionAnimation.complete()
    Behavior on selectionProgress {
        enabled: root.canAnimate
        NumberAnimation {
            id: selectionAnimation
            duration: root.tokens.radioSelectionDuration
            easing.type: root.tokens.radioSelectionEasing
        }
    }
    Rectangle {
        anchors.fill: parent
        radius: width / 2
        color: root.parameters.colorChoice ? root.ink : root.tokens.transparent
        border.width: root.parameters.colorChoice ? 0 : root.tokens.radioOutlineWidth
        border.color: root.ink
        antialiasing: true
    }
    Rectangle {
        anchors.centerIn: parent
        width: (root.parameters.colorChoice ? root.tokens.radioColorChoiceSelectedDiameter
            : root.tokens.radioDotDiameter) * root.selectionProgress
        height: width
        radius: width / 2
        color: root.ink
        border.width: root.parameters.colorChoice
            ? root.tokens.radioColorChoiceSelectionRingWidth * root.selectionProgress : 0
        border.color: root.tokens.surface
        antialiasing: true
    }
    Rectangle {
        anchors.centerIn: parent
        width: root.tokens.radioFocusIndicatorDiameter
        height: width
        radius: width / 2
        color: root.tokens.transparent
        border.width: root.tokens.radioFocusIndicatorWidth
        border.color: root.ink
        visible: !root.parameters.colorChoice && root.feedbackEnabled && root.control.visualFocus
        antialiasing: true
    }
    Material3Ripple {
        id: feedback
        anchors.centerIn: parent
        width: root.tokens.radioStateLayerDiameter
        height: width
        control: root.control
        tokens: root.tokens
        reduceMotion: root.parameters.reducedMotion || !root.control.SK.StyleKit.transitionsEnabled
        rippleColor: root.stateLayerColor
        cornerRadius: width / 2
        cornerRadii: Qt.vector4d(cornerRadius, cornerRadius, cornerRadius, cornerRadius)
        feedbackEnabled: root.feedbackEnabled
        stateOpacity: root.control.visualFocus ? root.tokens.interactionOpacity
            : root.control.hovered ? root.tokens.hoverOpacity : 0
        pressOpacity: root.tokens.interactionOpacity
        restartOnPress: true
        feedbackObjectName: "material3.radio.feedback"
    }
    Rectangle {
        anchors.centerIn: parent
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
