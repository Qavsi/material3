pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Templates as T
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

Item {
    id: root
    required property T.BusyIndicator control
    required property Material3Theme tokens
    property bool reducedMotion: false
    property int showDelay: tokens.busyShowDelay
    property int minHideDelay: tokens.busyMinimumHideDelay
    property real indicatorSize: tokens.busyShapeSize
    property color color: control.enabled ? tokens.busyIndicator : tokens.busyDisabledIndicator
    readonly property bool working: control.running
    readonly property bool active: working && revealed && control.enabled && control.visible && control.opacity > 0
        && visible && opacity > 0 && Window.window && Window.window.visible
        && Window.window.visibility !== Window.Minimized
    // Timing belongs to the content; never assign control.visible or control.running.
    property bool revealed: false
    implicitWidth: tokens.busyContainerSize
    implicitHeight: tokens.busyContainerSize
    Accessible.ignored: true

    function showIndicator(): void {
        revealed = true
        minimumVisible.stop()
        if (minHideDelay > 0)
            minimumVisible.restart()
    }
    function synchronizeRunning(): void {
        showTimer.stop()
        if (working) {
            minimumVisible.stop()
            revealed = false
            if (showDelay > 0)
                showTimer.restart()
            else
                showIndicator()
        } else if (!revealed || !minimumVisible.running) {
            minimumVisible.stop()
            revealed = false
        }
    }
    onWorkingChanged: synchronizeRunning()
    onReducedMotionChanged: if (reducedMotion) paint.phase = 0
    Component.onCompleted: synchronizeRunning()

    Timer {
        id: showTimer
        interval: Math.max(0, root.showDelay)
        onTriggered: if (root.working) root.showIndicator()
    }
    // Qt's monotonic timer starts at the actual reveal, including with reduced motion.
    Timer {
        id: minimumVisible
        interval: Math.max(0, Math.min(root.minHideDelay, root.tokens.busyMaximumHideDelay))
        onTriggered: if (!root.working) root.revealed = false
    }
    MaterialLoadingPaint {
        id: paint
        anchors.fill: parent
        visible: root.revealed
        shapeSize: root.indicatorSize
        color: root.color
    }
    FrameAnimation {
        id: animation
        running: root.active && !root.reducedMotion && root.SK.StyleKit.transitionsEnabled
        onRunningChanged: if (running) paint.phase = 0
        // elapsedTime is monotonic and refresh-rate independent; easing lives in the QCM geometry.
        onTriggered: paint.phase = animation.elapsedTime * 1000 / root.tokens.busyShapeDuration
    }
}
