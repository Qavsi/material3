pragma ComponentBehavior: Bound
import QtQuick
import Qavsi.Material3.Style
import Qavsi.Material3.Theme

Window {
    id: root
    required property rect previewArea
    required property bool usePainter
    required property int itemCount
    readonly property Material3Theme tokens: Material3Theme {}
    property real phase: 0
    readonly property int cycleDuration: tokens.rippleExpansionDuration + tokens.rippleFadeDuration
    readonly property real progress: 1 - Math.pow(1 - Math.min(1, phase * cycleDuration / tokens.rippleExpansionDuration), 3)
    readonly property real pulse: Math.min(1, (1 - phase) * cycleDuration / tokens.rippleFadeDuration)
    width: 1640
    height: 1000
    x: previewArea.x + (previewArea.width - width) / 2
    y: previewArea.y + (previewArea.height - height) / 2
    color: tokens.surface
    title: qsTr("Qavsi · Ripple ölçümü")
    visible: true

    NumberAnimation on phase {
        objectName: "benchmarkPulse"
        from: 0
        to: 1
        duration: root.cycleDuration
        loops: Animation.Infinite
        running: root.visible
    }

    Repeater {
        model: root.itemCount
        Rectangle {
            id: cell
            objectName: "benchmarkCell"
            required property int index
            x: 20 + (index % 20) * 80
            y: 20 + Math.floor(index / 20) * 48
            width: 72
            height: root.tokens.smallHeight
            radius: root.tokens.smallRadius
            color: root.tokens.primary
            antialiasing: true
            readonly property color ink: Qt.alpha(root.tokens.primaryForeground,
                root.tokens.primaryForeground.a * root.tokens.interactionOpacity)
            Loader {
                anchors.fill: parent
                sourceComponent: root.usePainter ? painter : shader
            }
            Component {
                id: painter
                MaterialButtonFeedback {
                    objectName: "benchmarkPainter"
                    cornerRadius: cell.radius
                    rippleOrigin: Qt.point(12, height / 2)
                    rippleProgress: root.progress
                    rippleOpacity: root.pulse
                    stateOpacity: root.tokens.hoverOpacity / root.tokens.interactionOpacity
                    rippleColor: cell.ink
                }
            }
            Component {
                id: shader
                ShaderEffect {
                    objectName: "benchmarkShader"
                    property size size: Qt.size(width, height)
                    property real cornerRadius: cell.radius
                    property point rippleOrigin: Qt.point(12, height / 2)
                    property real rippleProgress: root.progress
                    property real rippleOpacity: root.pulse
                    property real stateOpacity: root.tokens.hoverOpacity / root.tokens.interactionOpacity
                    property color rippleColor: cell.ink
                    fragmentShader: "qrc:/Qavsi/Material3/Style/shaders/smallbuttonfeedback.frag.qsb"
                }
            }
        }
    }
}
