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
    readonly property bool rippleRunning: expansion.running || release.running || fade.running || noise.running
    readonly property bool rippleVisible: rippleOpacity > 0 || (feedbackEnabled && control.pressed)
    readonly property string feedbackRenderer: GraphicsInfo.api === GraphicsInfo.Metal && !shaderFailed
        ? "shader" : "painter"
    readonly property int feedbackShaderStatus: shaderFailed ? ShaderEffect.Error
        : feedbackRenderer === "shader" && feedback.status === Loader.Ready
            ? (feedback.item as ShaderEffect)?.status ?? ShaderEffect.Uncompiled : ShaderEffect.Uncompiled
    property bool shaderFailed: false
    property string feedbackShaderLog: ""
    readonly property real stateOpacity: focusVisible ? tokens.interactionOpacity
        : control.hovered ? tokens.hoverOpacity : 0
    readonly property color rippleColor: contentColor
    readonly property real feedbackOutset: tokens.focusRingGap + tokens.focusRingWidth
    readonly property bool hasPaintArea: Math.floor(width * Screen.devicePixelRatio) > 0
        && Math.floor(height * Screen.devicePixelRatio) > 0
    readonly property bool feedbackEnabled: hasPaintArea && control.enabled && control.visible
        && control.opacity > 0 && root.visible && root.opacity > 0
        && root.Window.window && root.Window.window.visible
        && root.Window.window.visibility !== Window.Minimized
    property point rippleOrigin: Qt.point(width / 2, height / 2)
    property real rippleProgress: 0
    property real rippleOpacity: 0
    property real ripplePhase: 0
    property real stateLayerOpacity: stateOpacity
    property bool pointerFocus: false

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

    function resetRipple(): void {
        expansion.stop()
        release.stop()
        fade.stop()
        rippleProgress = 0
        rippleOpacity = 0
        ripplePhase = 0
        stateLayerOpacity = Qt.binding(() => root.stateOpacity)
    }

    function beginRipple(): void {
        if (!feedbackEnabled)
            return
        expansion.stop()
        release.stop()
        fade.stop()
        rippleOrigin = pointer.active
            ? mapFromItem(pointerArea, pointer.point.pressPosition.x, pointer.point.pressPosition.y)
            : Qt.point(width / 2, height / 2)
        pointerFocus = pointer.active
        stateLayerOpacity = tokens.rippleOpacity
        if (reduceMotion) {
            rippleProgress = 0
            rippleOpacity = 0
        } else {
            // Repress continues from the current expansion, as QCM does.
            rippleOpacity = tokens.rippleOpacity
            expansion.start()
        }
    }

    function finishRipple(): void {
        if (reduceMotion || !feedbackEnabled) {
            resetRipple()
        } else if (rippleOpacity > 0) {
            expansion.stop()
            release.restart()
            fade.restart()
        } else {
            resetRipple()
        }
    }

    onFeedbackEnabledChanged: {
        if (!feedbackEnabled)
            resetRipple()
        else if (control.pressed)
            beginRipple()
    }
    onReduceMotionChanged: {
        resetRipple()
        if (feedbackEnabled && control.pressed) {
            stateLayerOpacity = tokens.rippleOpacity
        }
    }
    function finishForeground() { foregroundReady = true }
    Component.onCompleted: {
        Qt.callLater(finishForeground)
        if (control.pressed)
            beginRipple()
    }

    Item {
        id: pointerArea
        // Visual parent follows input; QObject ownership stays with the delegate.
        parent: root.control
        width: root.control.width
        height: root.control.height
        Accessible.ignored: true
        PointHandler {
            id: pointer
            target: null
            acceptedButtons: Qt.LeftButton
            onPointChanged: {
                if (active)
                    root.rippleOrigin = root.mapFromItem(pointerArea, point.position.x, point.position.y)
            }
            onActiveChanged: {
                if (active) {
                    root.pointerFocus = true
                    root.rippleOrigin = root.mapFromItem(pointerArea,
                        point.pressPosition.x, point.pressPosition.y)
                }
            }
        }
    }

    Connections {
        target: root.control
        function onPressedChanged(): void {
            if (root.control.pressed)
                root.beginRipple()
            else
                root.finishRipple()
        }
        function onCanceled(): void {
            root.resetRipple()
        }
        function onActiveFocusChanged(): void {
            root.pointerFocus = false
        }
    }

    NumberAnimation {
        id: expansion
        target: root
        property: "rippleProgress"
        to: root.tokens.rippleHoldProgress
        duration: root.tokens.rippleExpansionDuration
        easing.type: Easing.OutCubic
    }
    NumberAnimation {
        id: release
        target: root
        property: "rippleProgress"
        to: 1
        duration: root.tokens.rippleReleaseDuration
        easing.type: Easing.OutCubic
        onFinished: {
            root.rippleProgress = 0
            root.ripplePhase = 0
        }
    }
    SequentialAnimation {
        id: fade
        onStopped: root.stateLayerOpacity = Qt.binding(() => root.stateOpacity)
        NumberAnimation {
            target: root
            property: "stateLayerOpacity"
            to: root.stateOpacity
            duration: root.tokens.rippleFadeDuration
        }
        NumberAnimation {
            target: root
            property: "rippleOpacity"
            to: 0
            duration: root.tokens.rippleFadeDuration
        }
    }
    NumberAnimation {
        id: noise
        target: root
        property: "ripplePhase"
        from: 0
        to: root.tokens.rippleNoisePhase
        duration: root.tokens.rippleNoiseDuration
        loops: Animation.Infinite
        running: root.feedbackRenderer === "shader" && root.feedbackEnabled
            && !root.reduceMotion && root.rippleOpacity > 0
    }

    Loader {
        id: feedback
        anchors.fill: parent
        active: root.hasPaintArea
        visible: root.feedbackEnabled
        sourceComponent: root.feedbackRenderer === "shader" ? shaderFeedback : painterFeedback
    }

    Component {
        id: shaderFeedback
        ShaderEffect {
            objectName: "material3.small.feedback"
            property size size: Qt.size(width, height)
            property real cornerRadius: root.radius
            property vector4d cornerRadii: Qt.vector4d(root.topLeftRadius, root.topRightRadius,
                root.bottomLeftRadius, root.bottomRightRadius)
            property point rippleOrigin: root.rippleOrigin
            property real rippleProgress: root.rippleProgress
            property real rippleOpacity: root.rippleOpacity
            property real stateOpacity: root.stateLayerOpacity
            property real ripplePhase: root.ripplePhase
            property color rippleColor: root.rippleColor
            property color sparkleColor: root.tokens.rippleSparkleColor
            fragmentShader: "qrc:/Qavsi/Material3/Style/shaders/smallbuttonfeedback.frag.qsb"
            onStatusChanged: {
                if (status === ShaderEffect.Error) {
                    root.feedbackShaderLog = log
                    root.shaderFailed = true
                    console.warn("Material3 Small Button shader failed; using painter:", log)
                }
            }
            Accessible.ignored: true
        }
    }

    Component {
        id: painterFeedback
        MaterialButtonFeedback {
            objectName: "material3.small.feedback"
            cornerRadius: root.radius
            cornerRadii: Qt.vector4d(root.topLeftRadius, root.topRightRadius,
                root.bottomLeftRadius, root.bottomRightRadius)
            rippleOrigin: root.rippleOrigin
            rippleProgress: root.rippleProgress
            rippleOpacity: root.rippleOpacity
            stateOpacity: root.stateLayerOpacity
            ripplePhase: root.ripplePhase
            rippleColor: root.rippleColor
            sparkleColor: root.tokens.rippleSparkleColor
            Accessible.ignored: true
        }
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
