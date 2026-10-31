pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme
import Qavsi.Material3.Style

Column {
    id: root
    required property Material3Theme tokens
    readonly property real preferredWidth: tokens.referenceCardWidth
    readonly property ComparisonMetrics metrics: ComparisonMetrics { }
    spacing: tokens.spacingLarge

    DemoCard {
        width: parent.width
        tokens: root.tokens
        title: qsTr("Progress indicators")
        sampleSpacing: root.tokens.spacingMedium
        RowLayout {
            width: parent.width
            spacing: root.tokens.spacingSmall
            SK.Slider {
                Layout.fillWidth: true
                from: 0; to: 1
                value: download.completed / download.total
                Accessible.name: qsTr("Progress")
                onMoved: download.completed = value * download.total
            }
            SK.Label {
                Layout.preferredWidth: root.metrics.progressValueWidth
                text: Math.round(download.position * 100) + "%"
                color: root.tokens.surfaceForeground
                font: root.tokens.bodyMedium
                leftPadding: 0; rightPadding: 0; topPadding: 0; bottomPadding: 0
                horizontalAlignment: Text.AlignRight
            }
        }
        SK.ProgressBar {
            id: download
            objectName: "comparison.progress.linear"
            property real completed: 50
            property real total: 100
            property bool unknown: false
            width: parent.width
            from: 0; to: download.total; value: download.completed
            indeterminate: download.unknown
            Accessible.name: qsTr("Download progress")
            contentItem: Material3ProgressContent { control: download }
        }
        SK.ProgressBar {
            objectName: "comparison.progress.wavy"
            width: parent.width
            value: download.position
            SK.StyleVariation.variations: ["progressWavy"]
            Accessible.name: qsTr("Wavy progress")
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: root.tokens.spacingLarge
            SK.ProgressBar {
                id: circle
                objectName: "comparison.progress.circular"
                value: download.position
                SK.StyleVariation.variations: ["progressCircular"]
                Accessible.name: qsTr("Installation progress")
                contentItem: Material3ProgressContent {
                    control: circle
                    circular: true
                    trackColor: root.tokens.progressTrack
                }
            }
            SK.ProgressBar {
                id: waveCircle
                objectName: "comparison.progress.circularWavy"
                value: download.position
                SK.StyleVariation.variations: ["progressCircularWavy"]
                Accessible.name: qsTr("Wavy circular progress")
                contentItem: Material3ProgressContent {
                    control: waveCircle
                    circular: true
                    wavy: true
                    trackColor: root.tokens.progressTrack
                }
            }
        }
        SK.Button {
            id: play
            objectName: "comparison.progress.play"
            anchors.horizontalCenter: parent.horizontalCenter
            checkable: true
            icon.name: checked ? "material:pause" : "material:play_arrow"
            Accessible.name: checked ? qsTr("Pause progress") : qsTr("Play progress")
            SK.StyleVariation.variations: ["iconSmall", "iconStandard"]
            contentItem: Material3ButtonContent { control: play }
        }
        SK.ProgressBar {
            id: linearUnknown
            objectName: "comparison.progress.indeterminate"
            width: parent.width
            indeterminate: true
            Accessible.name: qsTr("Connecting")
            contentItem: Material3ProgressContent { control: linearUnknown; running: play.checked }
        }
        SK.ProgressBar {
            id: unknownWave
            width: parent.width
            indeterminate: true
            Accessible.name: qsTr("Wavy connecting")
            contentItem: Material3ProgressContent { control: unknownWave; running: play.checked; wavy: true }
        }
        SK.ProgressBar {
            id: contiguous
            width: parent.width
            indeterminate: true
            SK.StyleVariation.variations: ["progressContiguous"]
            Accessible.name: qsTr("Contiguous progress")
            contentItem: Material3ProgressContent { control: contiguous; running: play.checked; motionType: Material3ProgressContent.Contiguous }
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: root.tokens.spacingLarge
            SK.ProgressBar {
                id: circularUnknown
                objectName: "comparison.progress.circularUnknown"
                indeterminate: true
                Accessible.name: qsTr("Checking for updates")
                contentItem: Material3ProgressContent { control: circularUnknown; circular: true; running: play.checked }
            }
            SK.ProgressBar {
                id: circularUnknownWave
                indeterminate: true
                Accessible.name: qsTr("Wavy checking for updates")
                contentItem: Material3ProgressContent { control: circularUnknownWave; circular: true; wavy: true; running: play.checked }
            }
            SK.ProgressBar {
                id: retreat
                indeterminate: true
                Accessible.name: qsTr("Retreat progress")
                contentItem: Material3ProgressContent { control: retreat; circular: true; motionType: Material3ProgressContent.Retreat; running: play.checked }
            }
        }
    }
    DemoCard {
        width: parent.width
        tokens: root.tokens
        title: qsTr("Busy indicator")
        RowLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: root.tokens.spacingLarge
            Column {
                spacing: root.tokens.spacingSmall
                SK.Label {
                    text: qsTr("Immediate")
                    font: root.tokens.labelMedium
                    color: root.tokens.surfaceForeground
                }
                SK.BusyIndicator {
                    objectName: "comparison.progress.busy"
                    property bool working: true
                    anchors.horizontalCenter: parent.horizontalCenter
                    running: working
                    Accessible.name: qsTr("Loading")
                }
            }
            Column {
                spacing: root.tokens.spacingSmall
                SK.Label {
                    text: qsTr("Delayed")
                    font: root.tokens.labelMedium
                    color: root.tokens.surfaceForeground
                }
                SK.BusyIndicator {
                    id: delayedBusy
                    objectName: "comparison.progress.busy.delayed"
                    readonly property bool working: task.running
                    property bool shown: true
                    anchors.horizontalCenter: parent.horizontalCenter
                    running: working
                    visible: shown
                    Accessible.name: qsTr("Loading with a display delay")
                    contentItem: Material3BusyIndicatorContent {
                        control: delayedBusy
                        showDelay: root.metrics.busyShowDelay
                        minHideDelay: root.metrics.busyMinimumVisibleDuration
                    }
                }
            }
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: root.tokens.spacingSmall
            SK.Button {
                id: quickTask
                objectName: "comparison.progress.busy.quickTask"
                text: qsTr("Quick task")
                SK.StyleVariation.variations: ["ghost"]
                contentItem: Material3ButtonContent { control: quickTask }
                onClicked: {
                    task.interval = root.metrics.busyQuickTaskDuration
                    task.restart()
                }
            }
            SK.Button {
                id: normalTask
                objectName: "comparison.progress.busy.normalTask"
                text: qsTr("Normal task")
                SK.StyleVariation.variations: ["filledTonal"]
                contentItem: Material3ButtonContent { control: normalTask }
                onClicked: {
                    task.interval = root.metrics.busyTaskDuration
                    task.restart()
                }
            }
        }
        Timer { id: task }
    }
}
