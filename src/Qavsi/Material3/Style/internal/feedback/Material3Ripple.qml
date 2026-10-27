// Adapted from QmlMaterial 229bc3e6 (MIT) and AOSP realistic ripple (Apache-2.0).
// Copyright (C) 2021 The Android Open Source Project.
// Driver constants: Copyright 2023 Google LLC (BSD). See third_party/ripple-reference.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Templates as T
import Qavsi.Material3.Theme

Item {
    id: root
    required property T.AbstractButton control
    required property Material3Theme tokens
    required property bool reduceMotion
    required property color rippleColor
    required property vector4d cornerRadii
    required property bool feedbackEnabled
    required property real stateOpacity
    property real cornerRadius: 0
    property real pressOpacity: tokens.rippleOpacity
    property bool restartOnPress: false
    property string feedbackObjectName: "material3.small.feedback"
    readonly property bool hasPaintArea: Math.floor(width * Screen.devicePixelRatio) > 0
        && Math.floor(height * Screen.devicePixelRatio) > 0
    readonly property bool rippleRunning: expansion.running || release.running || fade.running || noise.running
    readonly property bool rippleVisible: rippleOpacity > 0 || (feedbackEnabled && control.pressed)
    readonly property string feedbackRenderer: GraphicsInfo.api === GraphicsInfo.Metal && !shaderFailed
        ? "shader" : "painter"
    readonly property int feedbackShaderStatus: shaderFailed ? ShaderEffect.Error
        : feedbackRenderer === "shader" && feedback.status === Loader.Ready
            ? (feedback.item as ShaderEffect)?.status ?? ShaderEffect.Uncompiled : ShaderEffect.Uncompiled
    property bool shaderFailed: false
    property string feedbackShaderLog: ""
    property point rippleOrigin: Qt.point(width / 2, height / 2)
    property real rippleProgress: 0
    property real rippleOpacity: 0
    property real ripplePhase: 0
    property real stateLayerOpacity: stateOpacity
    property bool pointerFocus: false
    Accessible.ignored: true

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
        stateLayerOpacity = pressOpacity
        if (reduceMotion) {
            rippleProgress = 0
            rippleOpacity = 0
        } else {
            // Buttons retain tail progress; MenuItem opts into the newer QCM restart policy.
            if (restartOnPress) {
                rippleProgress = 0
                ripplePhase = 0
            }
            rippleOpacity = pressOpacity
            if (restartOnPress && feedbackRenderer === "shader" && rippleOpacity > 0)
                noise.restart()
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
            stateLayerOpacity = pressOpacity
        }
    }
    Component.onCompleted: {
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
            objectName: root.feedbackObjectName
            property size size: Qt.size(width, height)
            property real cornerRadius: root.cornerRadius
            property vector4d cornerRadii: root.cornerRadii
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
                    console.warn("Material3 ripple shader failed; using painter:", log)
                }
            }
            Accessible.ignored: true
        }
    }

    Component {
        id: painterFeedback
        MaterialButtonFeedback {
            objectName: root.feedbackObjectName
            cornerRadius: root.cornerRadius
            cornerRadii: root.cornerRadii
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

}
