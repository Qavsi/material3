pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Templates as T
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

Rectangle {
    id: root
    required property SK.DelegateStyle delegateStyle
    required property T.MenuItem control
    readonly property Material3MenuParameters parameters: delegateStyle.data as Material3MenuParameters
    readonly property Material3Theme tokens: parameters.tokens
    readonly property real maximumRadius: Math.min(width, height) / 2
    readonly property color stateLayerColor: tokens.surfaceForeground
    readonly property bool feedbackEnabled: control.enabled && control.visible && control.opacity > 0
        && root.visible && root.opacity > 0 && root.Window.window && root.Window.window.visible
        && root.Window.window.visibility !== Window.Minimized
    readonly property real stateOpacity: !control.enabled ? 0
        : control.hovered ? tokens.hoverOpacity
        : control.highlighted || control.visualFocus ? tokens.interactionOpacity : 0
    property alias rippleOrigin: ripple.rippleOrigin
    property alias rippleProgress: ripple.rippleProgress
    property alias rippleOpacity: ripple.rippleOpacity
    property alias stateLayerOpacity: ripple.stateLayerOpacity
    readonly property bool rippleRunning: ripple.rippleRunning
    readonly property string feedbackRenderer: ripple.feedbackRenderer
    readonly property int feedbackShaderStatus: ripple.feedbackShaderStatus

    objectName: "material3.menuitem.background"
    implicitWidth: delegateStyle.width
    implicitHeight: delegateStyle.height
    width: parent ? parent.width : 0
    height: parent ? parent.height : 0
    color: delegateStyle.color
    radius: Math.max(0, Math.min(delegateStyle.radius, maximumRadius))
    topLeftRadius: Math.max(0, Math.min(delegateStyle.topLeftRadius, maximumRadius))
    topRightRadius: Math.max(0, Math.min(delegateStyle.topRightRadius, maximumRadius))
    bottomLeftRadius: Math.max(0, Math.min(delegateStyle.bottomLeftRadius, maximumRadius))
    bottomRightRadius: Math.max(0, Math.min(delegateStyle.bottomRightRadius, maximumRadius))
    border.width: delegateStyle.border.width
    border.color: delegateStyle.border.color
    opacity: delegateStyle.opacity
    visible: delegateStyle.visible
    Accessible.ignored: true

    Material3Ripple {
        id: ripple
        anchors.fill: parent
        control: root.control
        tokens: root.tokens
        reduceMotion: root.parameters.reducedMotion
        feedbackEnabled: root.feedbackEnabled
        rippleColor: root.stateLayerColor
        cornerRadius: root.radius
        cornerRadii: Qt.vector4d(root.topLeftRadius, root.topRightRadius,
            root.bottomLeftRadius, root.bottomRightRadius)
        stateOpacity: root.stateOpacity
        pressOpacity: root.tokens.menuRippleOpacity
        restartOnPress: true
        feedbackObjectName: "material3.menuitem.feedback"
    }
}
