pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Style
import Qavsi.Material3.Theme

Column {
    id: root
    required property Material3Theme tokens
    readonly property real preferredWidth: tokens.referenceCardWidth
    DemoCard {
        width: parent.width
        tokens: root.tokens
        title: qsTr("Badges")
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: root.tokens.spacingLarge
            SK.Button {
                id: dotButton
                SK.StyleVariation.variations: ["iconStandard"]
                icon.name: "material:notifications"
                Accessible.name: qsTr("Notifications")
                contentItem: Material3ButtonContent { control: dotButton }
                Material3Badge {
                    objectName: "comparison.badge.dot"
                    dot: true
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.rightMargin: -root.tokens.badgeOffsetX
                    anchors.topMargin: root.tokens.badgeOffsetY
                }
            }
            SK.Button {
                id: countButton
                SK.StyleVariation.variations: ["iconFilled"]
                icon.name: "material:notifications"
                Accessible.name: qsTr("Notifications")
                contentItem: Material3ButtonContent { control: countButton }
                Material3Badge {
                    objectName: "comparison.badge.count"
                    count: 8
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.rightMargin: -root.tokens.badgeOffsetX
                    anchors.topMargin: root.tokens.badgeOffsetY
                }
            }
            SK.Button {
                id: cappedButton
                SK.StyleVariation.variations: ["iconOutlined"]
                icon.name: "material:notifications"
                Accessible.name: qsTr("Notifications")
                contentItem: Material3ButtonContent { control: cappedButton }
                Material3Badge {
                    count: 128
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.rightMargin: -root.tokens.badgeOffsetX
                    anchors.topMargin: root.tokens.badgeOffsetY
                }
            }
            SK.Button {
                id: textButton
                SK.StyleVariation.variations: ["iconStandard"]
                icon.name: "material:notifications"
                Accessible.name: qsTr("Alarm")
                contentItem: Material3ButtonContent { control: textButton }
                Material3Badge {
                    objectName: "comparison.badge.text"
                    property string callerText: qsTr("alarm")
                    text: callerText
                    anchors.right: parent.right
                    anchors.top: parent.top
                    anchors.rightMargin: -root.tokens.badgeOffsetX
                    anchors.topMargin: root.tokens.badgeOffsetY
                }
            }
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: root.tokens.spacingSmall
            Material3Badge { text: qsTr("Primary"); SK.StyleVariation.variations: ["badgePrimary"] }
            Material3Badge { text: qsTr("Secondary"); SK.StyleVariation.variations: ["badgeSecondary"] }
            Material3Badge { text: qsTr("Contrast"); SK.StyleVariation.variations: ["badgeContrast"] }
            Material3Badge { text: qsTr("Disabled"); enabled: false }
        }
    }
}
