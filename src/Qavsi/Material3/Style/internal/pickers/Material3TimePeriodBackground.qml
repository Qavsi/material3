pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

Rectangle {
    id: root
    required property Material3TimePeriodButton control
    required property SK.DelegateStyle delegateStyle
    readonly property Material3Theme tokens: delegateStyle.data as Material3Theme
    readonly property Material3Style sourceStyle: control.SK.StyleKit.style as Material3Style
    readonly property bool first: control.period === 0
    readonly property bool physicalFirst: control.horizontal && control.mirrored ? !first : first
    readonly property vector4d corners: Qt.vector4d(topLeftRadius, topRightRadius, bottomLeftRadius, bottomRightRadius)
    implicitWidth: delegateStyle.width
    implicitHeight: delegateStyle.height
    visible: delegateStyle.visible
    opacity: delegateStyle.opacity
    color: control.checked ? tokens.tertiaryContainer : tokens.transparent
    radius: tokens.radiusSmall
    topLeftRadius: physicalFirst ? radius : 0
    topRightRadius: control.horizontal ? (physicalFirst ? 0 : radius) : (physicalFirst ? radius : 0)
    bottomLeftRadius: control.horizontal ? (physicalFirst ? radius : 0) : (physicalFirst ? 0 : radius)
    bottomRightRadius: physicalFirst ? 0 : radius
    border.width: tokens.textFieldOutlineWidth
    border.color: tokens.outline
    antialiasing: true
    Accessible.ignored: true
    Material3Ripple {
        anchors.fill: parent
        control: root.control
        tokens: root.tokens
        reduceMotion: (root.sourceStyle?.effectiveReducedMotion ?? true) || !root.control.SK.StyleKit.transitionsEnabled
        rippleColor: root.control.checked ? root.tokens.tertiaryContainerForeground : root.tokens.surfaceVariantForeground
        cornerRadii: root.corners
        cornerRadius: root.radius
        feedbackEnabled: root.control.enabled && root.control.visible && root.Window.window?.visible === true
        stateOpacity: root.control.visualFocus ? root.tokens.interactionOpacity : root.control.hovered ? root.tokens.hoverOpacity : 0
    }
}
