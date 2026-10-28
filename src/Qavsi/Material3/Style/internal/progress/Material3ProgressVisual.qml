pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Templates as T
import Qavsi.Material3.Theme

Item {
    id: root
    required property T.Control control
    required property Material3Theme tokens
    property bool reducedMotion: false
    property bool circular: false
    property bool busy: false
    readonly property T.ProgressBar progressControl: control as T.ProgressBar
    readonly property T.BusyIndicator busyControl: control as T.BusyIndicator
    readonly property bool indeterminate: busy || (progressControl && progressControl.indeterminate)
    readonly property bool working: !busy || (busyControl && busyControl.running)
    readonly property bool active: working && control.enabled && control.visible && control.opacity > 0
        && visible && opacity > 0 && Window.window && Window.window.visible
        && Window.window.visibility !== Window.Minimized
    property real displayedPosition: progressControl ? progressControl.position : 0
    implicitWidth: circular ? tokens.progressCircularSize : tokens.progressLinearMinimumWidth
    implicitHeight: circular ? tokens.progressCircularSize : tokens.progressThickness
    Accessible.ignored: true

    Behavior on displayedPosition {
        enabled: !root.reducedMotion && root.active && !root.indeterminate
        NumberAnimation {
            duration: root.tokens.progressValueDuration
            easing.type: Easing.BezierSpline
            easing.bezierCurve: [0.2, 0, 0, 1, 1, 1]
        }
    }
    MaterialProgressPaint {
        id: paint
        anchors.fill: parent
        visible: root.working
        circular: root.circular
        indeterminate: root.indeterminate
        mirrored: root.control.mirrored
        position: root.displayedPosition
        phase: animation.running ? (animation.elapsedTime * 1000 / (root.circular
            ? root.tokens.progressCircularCycleDuration : root.tokens.progressLinearCycleDuration)) % 1
            : root.circular ? 0.125 : 0.75
        thickness: root.tokens.progressThickness
        gap: root.tokens.progressGap
        gapAngle: root.tokens.progressCircularGapAngle
        stopDiameter: root.tokens.progressStopDiameter
        color: root.control.enabled ? root.tokens.progressIndicator : root.tokens.progressDisabledIndicator
        trackColor: root.circular ? root.tokens.progressCircularTrack
            : root.control.enabled ? root.tokens.progressTrack : root.tokens.progressDisabledTrack
    }
    FrameAnimation {
        id: animation
        running: root.active && root.indeterminate && !root.reducedMotion
    }
}
