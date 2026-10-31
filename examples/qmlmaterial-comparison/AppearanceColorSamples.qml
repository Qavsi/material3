// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

ColumnLayout {
    id: root
    required property Material3Theme tokens
    required property var colors
    required property var foregrounds
    required property string title
    required property string previewPrefix
    spacing: root.tokens.spacingSmall

    SK.Label {
        Layout.fillWidth: true
        text: root.title
        font: root.tokens.labelLarge
        color: root.tokens.surfaceForeground
    }
    RowLayout {
        Layout.fillWidth: true
        spacing: root.tokens.spacingSmall
        Repeater {
            model: [
                { key: "primary", label: qsTr("Primary") },
                { key: "secondary", label: qsTr("Secondary") },
                { key: "tertiary", label: qsTr("Tertiary") }
            ]
            delegate: Rectangle {
                id: sample
                required property var modelData
                readonly property color ink: root.foregrounds[modelData.key]
                readonly property string hexCode: color.toString().toUpperCase()
                objectName: root.previewPrefix + "." + modelData.key
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                implicitHeight: labels.implicitHeight + root.tokens.spacingSmall * 2
                radius: root.tokens.radiusSmall
                color: root.colors[modelData.key]
                Accessible.role: Accessible.StaticText
                Accessible.name: qsTr("%1 %2, %3").arg(root.title).arg(modelData.label).arg(hexCode)
                ColumnLayout {
                    id: labels
                    anchors.fill: parent
                    anchors.margins: root.tokens.spacingSmall
                    spacing: root.tokens.spacingUnit
                    SK.Label {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        text: sample.modelData.label
                        font: root.tokens.labelMedium
                        color: sample.ink
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        Accessible.ignored: true
                    }
                    SK.Label {
                        Layout.fillWidth: true
                        Layout.minimumWidth: 0
                        text: sample.hexCode
                        font: root.tokens.bodySmall
                        color: sample.ink
                        horizontalAlignment: Text.AlignHCenter
                        elide: Text.ElideRight
                        Accessible.ignored: true
                    }
                }
            }
        }
    }
}
