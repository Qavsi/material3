pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Style as M3
import Qavsi.Material3.Theme

Window {
    id: root
    required property rect previewArea
    required property string sceneKind
    readonly property bool controls: sceneKind === "controls" || sceneKind === "controls-off"
    property bool heartbeat: false
    property real beat: 0
    property real phase: 0
    property bool cycling: false
    property real startPhase: 0
    readonly property real elevation: cycling ? 6 + 2 * phase : 12 * phase
    readonly property Material3Theme tokens: Material3Theme { }
    SK.StyleKit.style: M3.Material3Style { }
    SK.StyleKit.transitionsEnabled: false
    signal animationFinished()
    function startOnce(): void { once.restart() }
    width: 1800; height: 950
    x: previewArea.x + (previewArea.width - width) / 2
    y: previewArea.y + (previewArea.height - height) / 2
    visible: false
    color: tokens.surface
    title: "Qavsi shadow study · " + sceneKind
    NumberAnimation {
        id: once; target: root; property: "phase"
        from: root.startPhase; to: 1; duration: 250; easing.type: Easing.OutCubic
        onFinished: root.animationFinished()
    }
    SequentialAnimation on phase {
        running: root.cycling
        loops: Animation.Infinite
        NumberAnimation { from: 0; to: 1; duration: 250; easing.type: Easing.OutCubic }
        NumberAnimation { from: 1; to: 0; duration: 250; easing.type: Easing.OutCubic }
    }
    NumberAnimation on beat { running: root.heartbeat; from: 0; to: 1; duration: 1000; loops: Animation.Infinite }
    Rectangle { x: 10 + 4 * root.beat; y: 10; width: 2; height: 2; color: root.tokens.surfaceForeground }
    Repeater {
        model: 50
        delegate: Item {
            id: cell
            required property int index
            objectName: "study.cell"
            x: 70 + (index % 10) * 170
            y: 70 + Math.floor(index / 10) * 170
            width: root.controls ? 100 : 80
            height: root.controls ? 40 : 56
            readonly property real variant: root.sceneKind === "blur-mixed" ? index % 5 : 0
            readonly property vector4d corners: Qt.vector4d(4 + variant, 12 + variant, 20 + variant, 8 + variant)
            Loader {
                anchors.fill: parent
                sourceComponent: root.controls ? nativeControl : card
            }
            Component {
                id: nativeControl
                SK.Button {
                    objectName: "study.control"
                    hoverEnabled: false
                    text: qsTr("Save %1").arg(cell.index)
                    SK.StyleVariation.variations: ["buttonSmall", "elevated"]
                }
            }
            Component {
                id: card
                Item {
                    Elevation {
                        anchors.fill: parent
                        tokens: root.tokens
                        reducedMotion: true
                        targetElevation: root.elevation
                        color: root.tokens.shadow
                        cornerRadii: cell.corners
                    }
                    Rectangle {
                        anchors.fill: parent
                        color: root.tokens.surfaceContainer
                        topLeftRadius: cell.corners.x
                        topRightRadius: cell.corners.y
                        bottomRightRadius: cell.corners.z
                        bottomLeftRadius: cell.corners.w
                    }
                }
            }
        }
    }
}
