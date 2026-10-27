// Adapted from QmlMaterial 229bc3e6 (MIT) and AOSP realistic ripple (Apache-2.0).
// Copyright (C) 2021 The Android Open Source Project.
// Driver constants: Copyright 2023 Google LLC (BSD). See third_party/ripple-reference.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Templates as T
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

Rectangle {
    id: root
    required property SK.DelegateStyle delegateStyle
    required property T.AbstractButton control
    readonly property SmallButtonParameters parameters: delegateStyle.data as SmallButtonParameters
    readonly property Material3Theme tokens: parameters.tokens
    readonly property bool reduceMotion: parameters.reduceMotion
    property real plateWidth: parameters.paintWidth
    property real plateHeight: parameters.paintHeight
    property vector4d cornerRadii: Qt.vector4d(delegateStyle.topLeftRadius,
        delegateStyle.topRightRadius, delegateStyle.bottomLeftRadius, delegateStyle.bottomRightRadius)
    readonly property Material3ButtonContent styledContent: control.contentItem as Material3ButtonContent
    property bool foregroundReady: false
    readonly property color contentColor: styledContent ? styledContent.color
        : foregroundReader.status === Loader.Ready
            ? (foregroundReader.item as SK.StyleReader).text.color : tokens.primaryForeground

    readonly property bool focusVisible: control.enabled && control.visualFocus && control.visible && !pointerFocus
    readonly property bool rippleRunning: ripple.rippleRunning
    readonly property bool rippleVisible: ripple.rippleVisible
    readonly property string feedbackRenderer: ripple.feedbackRenderer
    readonly property int feedbackShaderStatus: ripple.feedbackShaderStatus
    property alias shaderFailed: ripple.shaderFailed
    property alias feedbackShaderLog: ripple.feedbackShaderLog
    readonly property real stateOpacity: focusVisible ? tokens.interactionOpacity
        : control.hovered ? tokens.hoverOpacity : 0
    readonly property color rippleColor: contentColor
    readonly property real feedbackOutset: tokens.focusRingGap + tokens.focusRingWidth
    readonly property bool hasPaintArea: ripple.hasPaintArea
    readonly property bool feedbackEnabled: hasPaintArea && control.enabled && control.visible
        && control.opacity > 0 && root.visible && root.opacity > 0
        && root.Window.window && root.Window.window.visible
        && root.Window.window.visibility !== Window.Minimized
    property alias rippleOrigin: ripple.rippleOrigin
    property alias rippleProgress: ripple.rippleProgress
    property alias rippleOpacity: ripple.rippleOpacity
    property alias ripplePhase: ripple.ripplePhase
    property alias stateLayerOpacity: ripple.stateLayerOpacity
    property alias pointerFocus: ripple.pointerFocus

    objectName: "material3.small.background"
    width: plateWidth > 0 ? Math.min(parent.width,
        Math.max(plateWidth, control.implicitContentWidth + control.leftPadding + control.rightPadding)) : parent.width
    x: (parent.width - width) / 2
    height: plateHeight > 0 ? Math.min(parent.height,
        Math.max(plateHeight, control.implicitContentHeight + control.topPadding + control.bottomPadding)) : parent.height
    y: (parent.height - height) / 2
    implicitWidth: delegateStyle.width
    implicitHeight: delegateStyle.height
    color: delegateStyle.color
    radius: Math.max(0, Math.min(delegateStyle.radius, Math.min(width, height) / 2))
    topLeftRadius: Math.max(0, Math.min(cornerRadii.x, Math.min(width, height) / 2))
    topRightRadius: Math.max(0, Math.min(cornerRadii.y, Math.min(width, height) / 2))
    bottomLeftRadius: Math.max(0, Math.min(cornerRadii.z, Math.min(width, height) / 2))
    bottomRightRadius: Math.max(0, Math.min(cornerRadii.w, Math.min(width, height) / 2))
    border.width: delegateStyle.border.width
    border.color: delegateStyle.border.color
    opacity: delegateStyle.opacity
    visible: delegateStyle.visible
    antialiasing: true
    Accessible.ignored: true

    // Qt 6.12 resets readers during Style completion; create this reader afterwards.
    Loader {
        id: foregroundReader
        active: root.foregroundReady && !root.styledContent
        sourceComponent: SK.StyleReader {
            controlType: Number((root.control as T.Button)?.flat ? SK.StyleReader.FlatButton : SK.StyleReader.Button)
            enabled: root.control.enabled
            focused: root.control.activeFocus
            checked: root.control.checked
            hovered: root.control.hovered || root.control.pressed
            pressed: root.control.pressed
            palette: root.control.palette
        }
    }

    function resetRipple(): void { ripple.resetRipple() }
    function beginRipple(): void { ripple.beginRipple() }
    function finishRipple(): void { ripple.finishRipple() }
    function finishForeground() { foregroundReady = true }
    Component.onCompleted: Qt.callLater(finishForeground)

    Material3Ripple {
        id: ripple
        anchors.fill: parent
        control: root.control
        tokens: root.tokens
        reduceMotion: root.reduceMotion
        rippleColor: root.rippleColor
        cornerRadius: root.radius
        cornerRadii: Qt.vector4d(root.topLeftRadius, root.topRightRadius,
            root.bottomLeftRadius, root.bottomRightRadius)
        feedbackEnabled: root.feedbackEnabled
        stateOpacity: root.stateOpacity
    }

    Rectangle {
        x: -root.feedbackOutset
        y: -root.feedbackOutset
        width: root.width + 2 * root.feedbackOutset
        height: root.height + 2 * root.feedbackOutset
        radius: root.radius + root.feedbackOutset
        topLeftRadius: root.topLeftRadius + root.feedbackOutset
        topRightRadius: root.topRightRadius + root.feedbackOutset
        bottomLeftRadius: root.bottomLeftRadius + root.feedbackOutset
        bottomRightRadius: root.bottomRightRadius + root.feedbackOutset
        color: "transparent"
        border.color: root.tokens.primary
        border.width: root.tokens.focusRingWidth
        visible: root.feedbackEnabled && root.focusVisible
        antialiasing: true
        Accessible.ignored: true
    }
}
