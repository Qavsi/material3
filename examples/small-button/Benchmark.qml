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
    readonly property int cycleDuration: tokens.rippleExpansionDuration
        + Math.max(tokens.rippleReleaseDuration, tokens.rippleFadeDuration * 2)
    readonly property real elapsed: phase * cycleDuration
    readonly property real releaseElapsed: Math.max(0, elapsed - tokens.rippleExpansionDuration)
    readonly property real progress: elapsed <= tokens.rippleExpansionDuration
        ? tokens.rippleHoldProgress * (1 - Math.pow(1 - elapsed / tokens.rippleExpansionDuration, 3))
        : tokens.rippleHoldProgress + (1 - tokens.rippleHoldProgress)
            * (1 - Math.pow(1 - Math.min(1, releaseElapsed / tokens.rippleReleaseDuration), 3))
    readonly property real pulse: phase === 0 ? 0 : releaseElapsed <= tokens.rippleFadeDuration
        ? tokens.rippleOpacity
        : tokens.rippleOpacity * (1 - Math.min(1,
            (releaseElapsed - tokens.rippleFadeDuration) / tokens.rippleFadeDuration))
    readonly property real stateLayerOpacity: phase === 0 ? 0
        : tokens.rippleOpacity + (tokens.hoverOpacity - tokens.rippleOpacity)
            * Math.min(1, releaseElapsed / tokens.rippleFadeDuration)
    readonly property real noisePhase: usePainter ? 0 : elapsed / tokens.rippleNoiseDuration * tokens.rippleNoisePhase
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
            readonly property color ink: root.tokens.primaryForeground
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
                    ripplePhase: root.noisePhase
                    sparkleColor: root.tokens.rippleSparkleColor
                    rippleOpacity: root.pulse
                    stateOpacity: root.stateLayerOpacity
                    rippleColor: cell.ink
                }
            }
            Component {
                id: shader
                ShaderEffect {
                    objectName: "benchmarkShader"
                    property size size: Qt.size(width, height)
                    property real cornerRadius: cell.radius
                    property vector4d cornerRadii: Qt.vector4d(cell.radius, cell.radius, cell.radius, cell.radius)
                    property point rippleOrigin: Qt.point(12, height / 2)
                    property real rippleProgress: root.progress
                    property real ripplePhase: root.noisePhase
                    property color sparkleColor: root.tokens.rippleSparkleColor
                    property real rippleOpacity: root.pulse
                    property real stateOpacity: root.stateLayerOpacity
                    property color rippleColor: cell.ink
                    fragmentShader: "qrc:/Qavsi/Material3/Style/shaders/smallbuttonfeedback.frag.qsb"
                }
            }
        }
    }
}
