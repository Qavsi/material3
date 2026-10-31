// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT
pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Style

DemoCard {
    id: root
    objectName: "comparison.buttonIndicators"
    readonly property real preferredWidth: tokens.referenceCardWidth
    readonly property ComparisonMetrics metrics: ComparisonMetrics { }
    property int iconBusy: Material3ButtonContent.Idle
    property real iconProgress: 0
    title: qsTr("Button indicators")

    Row {
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: root.tokens.spacingSmall
        SK.Button {
            id: iconButton
            objectName: "comparison.buttonIndicator.icon"
            text: qsTr("Add")
            icon.name: "material:add"
            display: SK.Button.IconOnly
            Accessible.name: text
            SK.StyleVariation.variations: ["iconStandard"]
            contentItem: Material3ButtonContent {
                control: iconButton
                busy: root.iconBusy
                progress: root.iconProgress
            }
            onClicked: {
                if (root.iconBusy !== Material3ButtonContent.Idle)
                    return
                root.iconProgress = 0
                root.iconBusy = Material3ButtonContent.Busy
                iconBusyDelay.restart()
            }
        }
        SK.Button {
            id: addButton
            objectName: "comparison.buttonIndicator.button"
            anchors.verticalCenter: parent.verticalCenter
            text: qsTr("Add")
            icon.name: "material:add"
            contentItem: Material3ButtonContent {
                control: addButton
                busy: buttonBusyDelay.running ? Material3ButtonContent.Busy : Material3ButtonContent.Idle
            }
            onClicked: {
                if (!buttonBusyDelay.running)
                    buttonBusyDelay.restart()
            }
        }
    }
    Timer {
        id: buttonBusyDelay
        interval: root.metrics.busyButtonDelay
    }
    Timer {
        id: iconBusyDelay
        interval: root.metrics.busyButtonDelay
        onTriggered: {
            root.iconBusy = Material3ButtonContent.Progress
            iconProgressTimer.restart()
        }
    }
    Timer {
        id: iconProgressTimer
        interval: root.metrics.busyButtonProgressInterval
        repeat: true
        onTriggered: {
            root.iconProgress = Math.min(1, root.iconProgress + root.metrics.busyButtonProgressStep)
            if (root.iconProgress >= 1) {
                root.iconBusy = Material3ButtonContent.Idle
                stop()
            }
        }
    }
}
