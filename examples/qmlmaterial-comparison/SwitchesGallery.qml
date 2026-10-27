pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

Column {
    id: root
    required property Material3Theme tokens
    spacing: tokens.spacingLarge
    readonly property real preferredWidth: tokens.referenceCardWidth

    DemoCard {
        width: parent.width
        tokens: root.tokens
        title: qsTr("Switches")
        contentPadding: root.tokens.inputGalleryPadding
        SK.Switch {
            spacing: 0
            objectName: "comparison.switch.unchecked"
            anchors.horizontalCenter: parent.horizontalCenter
            Accessible.name: qsTr("Switch")
        }
        SK.Switch {
            spacing: 0
            objectName: "comparison.switch.disabled"
            anchors.horizontalCenter: parent.horizontalCenter
            enabled: false
            Accessible.name: qsTr("Disabled switch")
        }
        SK.Switch {
            spacing: 0
            objectName: "comparison.switch.checkedIcon"
            anchors.horizontalCenter: parent.horizontalCenter
            checked: true
            icon.name: checked ? "material:check" : ""
            icon.width: root.tokens.switchIconSize
            icon.height: root.tokens.switchIconSize
            icon.color: checked ? root.tokens.switchCheckedIcon : root.tokens.switchIcon
            Accessible.name: qsTr("Switch with checked icon")
        }
        SK.Switch {
            spacing: 0
            objectName: "comparison.switch.closeIcon"
            anchors.horizontalCenter: parent.horizontalCenter
            icon.name: checked ? "material:check" : "material:close"
            icon.width: root.tokens.switchIconSize
            icon.height: root.tokens.switchIconSize
            icon.color: checked ? root.tokens.switchCheckedIcon : root.tokens.switchIcon
            Accessible.name: qsTr("Switch with state icon")
        }
    }
}
