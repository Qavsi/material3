pragma ComponentBehavior: Bound
import QtQuick

Window {
    id: root
    required property string rendererMode
    required property int itemCount
    required property real elevationLevel
    required property bool animateElevation
    required property rect previewArea
    property bool animationsStarted: false
    property real phase: 0
    property real heartbeatPhase: 0
    readonly property real elevation: elevationLevel + (animateElevation ? 2 * phase : 0)
    property int columnCount: 40
    property real cellStepX: 43
    property real cellStepY: 34
    property real casterWidth: 28
    property real casterHeight: 28
    property real casterRadius: 6
    readonly property color backgroundColor: "#faf9fd"
    readonly property color casterColor: "#e6e0e9"
    readonly property color shadowColor: "#000000"
    width: 1800
    height: 950
    x: previewArea.x + (previewArea.width - width) / 2
    y: previewArea.y + (previewArea.height - height) / 2
    color: backgroundColor
    visible: false
    title: qsTr("Qavsi shadow benchmark · %1 · %2 · %3")
        .arg(rendererMode).arg(itemCount).arg(animateElevation ? qsTr("animated") : qsTr("static"))

    SequentialAnimation on phase {
        objectName: "shadowElevationAnimation"
        running: root.animationsStarted && root.animateElevation && root.visible
        loops: Animation.Infinite
        NumberAnimation { from: 0; to: 1; duration: 250; easing.type: Easing.OutCubic }
        NumberAnimation { from: 1; to: 0; duration: 250; easing.type: Easing.OutCubic }
    }

    NumberAnimation on heartbeatPhase {
        objectName: "shadowHeartbeatAnimation"
        running: root.animationsStarted && root.visible
        from: 0
        to: 1
        duration: 1000
        loops: Animation.Infinite
    }

    Rectangle {
        x: 10 + 8 * root.heartbeatPhase
        y: 10
        width: 2
        height: 2
        color: root.casterColor
        Accessible.ignored: true
    }

    Repeater {
        model: root.itemCount
        ShadowCell {
            required property int index
            x: 40 + (index % root.columnCount) * root.cellStepX
            y: 50 + Math.floor(index / root.columnCount) * root.cellStepY
            width: root.casterWidth
            height: root.casterHeight
            rendererMode: root.rendererMode
            elevation: root.elevation
            cornerRadius: root.casterRadius
            casterColor: root.casterColor
            shadowColor: root.shadowColor
        }
    }
}
