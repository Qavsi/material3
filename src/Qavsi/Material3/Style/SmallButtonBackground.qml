pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Templates as T
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

Rectangle {
    id: root
    required property SK.DelegateStyle delegateStyle
    required property T.Button control
    readonly property SmallButtonParameters parameters: delegateStyle.data as SmallButtonParameters
    readonly property Material3Theme tokens: parameters.tokens
    readonly property bool reduceMotion: parameters.reduceMotion

    readonly property bool focusVisible: control.enabled && control.visualFocus && control.visible && !pointerFocus
    readonly property bool rippleRunning: expansion.running || fade.running
    readonly property bool rippleVisible: rippleOpacity > 0
    readonly property string feedbackRenderer: GraphicsInfo.api === GraphicsInfo.Metal && !shaderFailed
        ? "shader" : "painter"
    readonly property int feedbackShaderStatus: shaderFailed ? ShaderEffect.Error
        : feedbackRenderer === "shader" && feedback.status === Loader.Ready
            ? (feedback.item as ShaderEffect).status : ShaderEffect.Uncompiled
    property bool shaderFailed: false
    property string feedbackShaderLog: ""
    readonly property real stateOpacity: focusVisible ? 1
        : control.hovered ? tokens.hoverOpacity / tokens.interactionOpacity : 0
    readonly property color rippleColor: Qt.alpha(tokens.primaryForeground,
        tokens.primaryForeground.a * tokens.interactionOpacity)
    readonly property real feedbackOutset: tokens.focusRingGap + tokens.focusRingWidth
    readonly property bool feedbackEnabled: control.enabled && root.visible && root.opacity > 0
        && root.Window.window && root.Window.window.visible
        && root.Window.window.visibility !== Window.Minimized
    property point rippleOrigin: Qt.point(width / 2, height / 2)
    property real rippleProgress: 0
    property real rippleOpacity: 0
    property bool pointerFocus: false

    objectName: "material3.small.background"
    anchors.fill: parent
    implicitWidth: delegateStyle.width
    implicitHeight: delegateStyle.height
    color: delegateStyle.color
    radius: Math.max(0, Math.min(delegateStyle.radius, Math.min(width, height) / 2))
    border.width: delegateStyle.border.width
    border.color: delegateStyle.border.color
    opacity: delegateStyle.opacity
    visible: delegateStyle.visible
    antialiasing: true
    Accessible.ignored: true

    function resetRipple(): void {
        expansion.stop()
        fade.stop()
        rippleProgress = 0
        rippleOpacity = 0
    }

    function beginRipple(): void {
        resetRipple()
        if (!feedbackEnabled)
            return
        rippleOrigin = pointer.active
            ? mapFromItem(pointerArea, pointer.point.pressPosition.x, pointer.point.pressPosition.y)
            : Qt.point(width / 2, height / 2)
        pointerFocus = pointer.active
        rippleOpacity = 1
        if (reduceMotion)
            rippleProgress = 1
        else
            expansion.start()
    }

    function finishRipple(): void {
        if (reduceMotion || !feedbackEnabled) {
            resetRipple()
        } else if (rippleVisible) {
            fade.restart()
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
            rippleProgress = 1
            rippleOpacity = 1
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
        function onActiveFocusChanged(): void {
            root.pointerFocus = false
        }
    }

    NumberAnimation {
        id: expansion
        target: root
        property: "rippleProgress"
        to: 1
        duration: root.tokens.rippleExpansionDuration
        easing.type: Easing.OutCubic
    }
    NumberAnimation {
        id: fade
        target: root
        property: "rippleOpacity"
        to: 0
        duration: root.tokens.rippleFadeDuration
        onFinished: {
            expansion.stop()
            root.rippleProgress = 0
        }
    }

    Loader {
        id: feedback
        anchors.fill: parent
        visible: root.feedbackEnabled
        sourceComponent: root.feedbackRenderer === "shader" ? shaderFeedback : painterFeedback
    }

    Component {
        id: shaderFeedback
        ShaderEffect {
            objectName: "material3.small.feedback"
            property size size: Qt.size(width, height)
            property real cornerRadius: root.radius
            property point rippleOrigin: root.rippleOrigin
            property real rippleProgress: root.rippleProgress
            property real rippleOpacity: root.rippleOpacity
            property real stateOpacity: root.stateOpacity
            property color rippleColor: root.rippleColor
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
            rippleOrigin: root.rippleOrigin
            rippleProgress: root.rippleProgress
            rippleOpacity: root.rippleOpacity
            stateOpacity: root.stateOpacity
            rippleColor: root.rippleColor
            Accessible.ignored: true
        }
    }

    Rectangle {
        x: -root.feedbackOutset
        y: -root.feedbackOutset
        width: root.width + 2 * root.feedbackOutset
        height: root.height + 2 * root.feedbackOutset
        radius: root.radius + root.feedbackOutset
        color: "transparent"
        border.color: root.tokens.primary
        border.width: root.tokens.focusRingWidth
        visible: root.feedbackEnabled && root.focusVisible
        antialiasing: true
        Accessible.ignored: true
    }
}
