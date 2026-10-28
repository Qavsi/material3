pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme
import Qavsi.Material3.Style

Column {
    id: root
    required property Material3Theme tokens
    readonly property real preferredWidth: tokens.referenceCardWidth

    DemoCard {
        width: parent.width
        tokens: root.tokens
        title: qsTr("Progress")
        Text { text: qsTr("Linear · determinate"); font: root.tokens.bodyMedium; color: root.tokens.surfaceForeground }
        SK.ProgressBar {
            id: download
            objectName: "comparison.progress.linear"
            property real completed: 35
            property real total: 100
            property bool unknown: false
            width: parent.width
            from: 0
            to: total
            value: completed
            indeterminate: unknown
            Accessible.name: qsTr("Download progress")
            contentItem: Material3ProgressContent {
                control: download
            }
        }
        Text { text: qsTr("Linear · indeterminate"); font: root.tokens.bodyMedium; color: root.tokens.surfaceForeground }
        SK.ProgressBar {
            objectName: "comparison.progress.indeterminate"
            width: parent.width
            indeterminate: true
            Accessible.name: qsTr("Connecting")
        }
        Row {
            spacing: root.tokens.spacingLarge
            Column {
                spacing: root.tokens.spacingSmall
                Text { text: qsTr("Circular"); font: root.tokens.bodyMedium; color: root.tokens.surfaceForeground }
                SK.ProgressBar {
                    objectName: "comparison.progress.circular"
                    SK.StyleVariation.variations: ["progressCircular"]
                    value: 0.6
                    Accessible.name: qsTr("Installation progress")
                }
            }
            Column {
                spacing: root.tokens.spacingSmall
                Text { text: qsTr("Unknown"); font: root.tokens.bodyMedium; color: root.tokens.surfaceForeground }
                SK.ProgressBar {
                    id: circularUnknown
                    objectName: "comparison.progress.circularUnknown"
                    indeterminate: true
                    Accessible.name: qsTr("Checking for updates")
                    contentItem: Material3ProgressContent {
                        control: circularUnknown
                        circular: true
                    }
                }
            }
            Column {
                spacing: root.tokens.spacingSmall
                Text { text: qsTr("Busy"); font: root.tokens.bodyMedium; color: root.tokens.surfaceForeground }
                SK.BusyIndicator {
                    objectName: "comparison.progress.busy"
                    property bool working: true
                    running: working
                    Accessible.name: qsTr("Loading")
                }
            }
        }
    }
}
