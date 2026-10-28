pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

Column {
    id: root
    required property Material3Theme tokens
    readonly property real preferredWidth: tokens.referenceCardWidth

    DemoCard {
        width: parent.width
        tokens: root.tokens
        title: qsTr("Checkboxes")
        contentPadding: root.tokens.inputGalleryPadding
        SK.CheckBox {
            objectName: "comparison.checkbox.unchecked"
            text: qsTr("Unchecked")
        }
        SK.CheckBox {
            objectName: "comparison.checkbox.indeterminate"
            text: qsTr("Indeterminate")
            tristate: true
            checkState: Qt.PartiallyChecked
        }
        SK.CheckBox {
            text: qsTr("Checked")
            checked: true
        }
        SK.CheckBox {
            objectName: "comparison.checkbox.disabled"
            text: qsTr("Disabled")
            checked: true
            enabled: false
        }
    }
}
