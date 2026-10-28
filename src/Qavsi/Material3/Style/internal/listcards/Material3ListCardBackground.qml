// QmlMaterial 0.6.1 ListItem/Card feedback (MIT); native controls own all input.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Templates as T
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

Rectangle {
    id: root
    required property SK.DelegateStyle delegateStyle
    required property T.AbstractButton control
    readonly property Material3ListCardParameters parameters: delegateStyle.data as Material3ListCardParameters
    readonly property Material3Theme tokens: parameters.tokens
    readonly property bool feedbackEnabled: control.enabled && control.visible && control.opacity > 0
        && visible && opacity > 0 && Window.window && Window.window.visible
        && Window.window.visibility !== Window.Minimized
    readonly property real maximumRadius: Math.min(width, height) / 2
    implicitWidth: delegateStyle.width
    implicitHeight: delegateStyle.height
    width: parent ? parent.width : 0
    height: parent ? parent.height : 0
    color: delegateStyle.color
    radius: Math.min(delegateStyle.radius, maximumRadius)
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
        rippleColor: root.tokens.surfaceForeground
        cornerRadius: root.radius
        cornerRadii: Qt.vector4d(root.radius, root.radius, root.radius, root.radius)
        stateOpacity: root.control.visualFocus ? root.tokens.interactionOpacity
            : root.control.hovered ? root.tokens.hoverOpacity : 0
    }
    Rectangle {
        anchors.fill: parent
        anchors.margins: -root.tokens.focusRingGap - root.tokens.focusRingWidth
        radius: root.radius + root.tokens.focusRingGap + root.tokens.focusRingWidth
        color: root.tokens.transparent
        border.width: root.tokens.focusRingWidth
        border.color: root.tokens.primary
        visible: root.feedbackEnabled && root.control.visualFocus && !ripple.pointerFocus
        Accessible.ignored: true
    }
}
