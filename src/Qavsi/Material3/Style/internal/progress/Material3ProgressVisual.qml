pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Templates as T
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

Item {
    id: root
    required property T.Control control
    required property Material3Theme tokens
    property bool reducedMotion: false
    property bool circular: false
    property bool wavy: false
    property bool busy: false
    property bool running: true
    property int motionType: circular && wavy ? 1 : 0
    property color trackColor: circular ? tokens.progressCircularTrack : tokens.progressTrack
    readonly property T.ProgressBar progressControl: control as T.ProgressBar
    readonly property T.BusyIndicator busyControl: control as T.BusyIndicator
    readonly property bool indeterminate: busy || (progressControl && progressControl.indeterminate)
    readonly property bool working: !busy || (busyControl && busyControl.running)
    readonly property bool active: working && control.enabled && control.visible && control.opacity > 0
        && visible && opacity > 0 && Window.window && Window.window.visible
        && Window.window.visibility !== Window.Minimized
    implicitWidth: circular ? (wavy ? tokens.progressWavyCircularSize : tokens.progressCircularSize)
        : wavy ? tokens.progressWavyLinearMinimumWidth : tokens.progressLinearMinimumWidth
    implicitHeight: circular ? implicitWidth
        : tokens.progressThickness + (wavy ? tokens.progressLinearWaveAmplitude * 2 : 0)
    Accessible.ignored: true

    MaterialProgressPaint {
        id: paint
        anchors.fill: parent
        visible: root.working
        circular: root.circular
        wavy: root.wavy
        running: root.running && root.working
        animationsEnabled: root.active && !root.reducedMotion && root.SK.StyleKit.transitionsEnabled
        indeterminate: root.indeterminate
        mirrored: root.control.mirrored
        position: root.progressControl ? root.progressControl.position : 0
        motionType: root.motionType
        waveLength: root.circular ? root.tokens.progressCircularWaveLength
            : root.indeterminate ? root.tokens.progressIndeterminateWaveLength : root.tokens.progressDeterminateWaveLength
        waveAmplitude: root.circular ? root.tokens.progressCircularWaveAmplitude : root.tokens.progressLinearWaveAmplitude
        waveCycleDuration: root.tokens.progressWaveCycleDuration
        valueDuration: root.tokens.progressValueDuration
        amplitudeDuration: root.tokens.progressAmplitudeDuration
        opacityDuration: root.tokens.progressOpacityDuration
        cycleDuration: root.circular ? (root.motionType === 0 ? root.tokens.progressCircularCycleDuration : root.tokens.progressRetreatCycleDuration)
            : root.motionType === 0 ? root.tokens.progressLinearCycleDuration : root.tokens.progressContiguousCycleDuration
        thickness: root.tokens.progressThickness
        gap: root.tokens.progressGap
        gapAngle: root.tokens.progressCircularGapAngle
        stopDiameter: root.tokens.progressStopDiameter
        color: root.control.enabled ? root.tokens.progressIndicator : root.tokens.progressDisabledIndicator
        trackColor: root.control.enabled ? root.trackColor : root.tokens.progressDisabledTrack
    }
    FrameAnimation {
        id: animation
        running: root.active && paint.animating
        onTriggered: paint.advanceAnimations(animation.frameTime * 1000)
    }
}
