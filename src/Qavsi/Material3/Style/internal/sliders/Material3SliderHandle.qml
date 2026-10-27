pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Templates as T
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

Item {
    id: root
    objectName: "material3.sliderHandle"
    required property T.Control control
    required property SK.DelegateStyle delegateStyle
    property int handleIndex: -1
    readonly property T.Slider slider: control as T.Slider
    readonly property T.RangeSlider range: control as T.RangeSlider
    readonly property var node: slider ?? (handleIndex === 0 ? range.first : range.second)
    readonly property bool horizontal: slider ? slider.horizontal : range.horizontal
    readonly property Material3SliderParameters parameters: delegateStyle.data as Material3SliderParameters
    readonly property Material3Theme tokens: parameters.tokens
    readonly property bool focused: control.visualFocus && (slider !== null || node.handle.activeFocus)
    readonly property bool active: node.pressed || focused
    readonly property bool labelActive: control.enabled && control.SliderSupport.labelBehavior !== SliderSupport.LabelGone
        && (control.SliderSupport.labelBehavior === SliderSupport.LabelVisible || active || node.hovered)
    readonly property bool canAnimate: ready && visible && control.visible && root.Window.window
        && root.Window.window.visible && root.Window.window.visibility !== Window.Minimized
        && root.SK.StyleKit.transitionsEnabled && !parameters.reducedMotion
    readonly property color ink: control.enabled ? tokens.primary : tokens.surfaceForeground
    property real lineWidth: active ? tokens.sliderActiveHandleWidth : tokens.sliderHandleWidth
    property real labelProgress: labelActive ? 1 : 0
    property real labelOpacity: labelActive ? 1 : 0
    property bool ready: false

    width: parent.width
    height: parent.height
    implicitWidth: delegateStyle.width
    implicitHeight: delegateStyle.height
    opacity: control.enabled ? 1 : tokens.disabledLabelOpacity
    Accessible.ignored: true
    Component.onCompleted: ready = true
    onCanAnimateChanged: if (!canAnimate) { lineAnimation.complete(); labelAnimation.complete(); opacityAnimation.complete() }
    Behavior on lineWidth {
        enabled: root.canAnimate
        NumberAnimation { id: lineAnimation; duration: root.tokens.sliderMotionDuration; easing.type: Easing.Linear }
    }
    Behavior on labelOpacity {
        enabled: root.canAnimate
        NumberAnimation { id: opacityAnimation; duration: root.tokens.sliderMotionDuration; easing.type: Easing.Linear }
    }
    Behavior on labelProgress {
        enabled: root.canAnimate
        NumberAnimation {
            id: labelAnimation
            duration: root.tokens.sliderMotionDuration
            easing.type: Easing.BezierSpline
            easing.bezierCurve: root.tokens.sliderLabelEasingCurve
        }
    }
    Rectangle {
        anchors.centerIn: parent
        width: root.horizontal ? root.lineWidth : root.tokens.sliderHandleLength
        height: root.horizontal ? root.tokens.sliderHandleLength : root.lineWidth
        radius: root.tokens.sliderTrackInnerRadius
        color: root.ink
    }
    Rectangle {
        anchors.centerIn: parent
        width: (root.horizontal ? root.lineWidth : root.tokens.sliderHandleLength) + root.tokens.sliderFocusExpansion
        height: (root.horizontal ? root.tokens.sliderHandleLength : root.lineWidth) + root.tokens.sliderFocusExpansion
        radius: (root.lineWidth + root.tokens.sliderFocusExpansion) / 2
        color: root.tokens.transparent
        border.color: root.ink
        border.width: root.tokens.sliderFocusWidth
        visible: root.focused && root.control.enabled
    }
    Item {
        id: bubble
        objectName: "material3.sliderValueIndicator"
        width: Math.max(root.tokens.sliderValueMinimum, valueLabel.implicitWidth)
        height: Math.max(root.tokens.sliderValueMinimum, valueLabel.implicitHeight)
        x: root.horizontal ? (root.width - width) / 2 : -width - root.tokens.sliderValueGap
        y: root.horizontal ? -height - root.tokens.sliderValueGap : (root.height - height) / 2
        visible: root.labelProgress > 0 || root.labelOpacity > 0
        opacity: root.labelOpacity
        scale: root.labelProgress
        Material3Elevation {
            anchors.fill: parent
            tokens: root.tokens
            reducedMotion: root.parameters.reducedMotion
            color: root.tokens.shadow
            cornerRadii: Qt.vector4d(bubble.height / 2, bubble.height / 2, bubble.height / 2, bubble.height / 2)
            targetElevation: root.tokens.sliderValueElevation
        }
        Rectangle { anchors.fill: parent; radius: height / 2; color: root.tokens.inverseSurface }
        Text {
            id: valueLabel
            anchors.centerIn: parent
            text: Math.round(root.slider ? root.slider.valueAt(root.slider.position) : root.range.valueAt(root.node.position))
            textFormat: Text.PlainText
            font: root.tokens.labelMedium
            color: root.tokens.inverseSurfaceForeground
            Accessible.ignored: true
        }
    }
}
