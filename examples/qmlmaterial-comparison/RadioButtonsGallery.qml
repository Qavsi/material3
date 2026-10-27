pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Style
import Qavsi.Material3.Theme

Column {
    id: root
    required property Material3Theme tokens
    readonly property ComparisonMetrics metrics: ComparisonMetrics { }
    spacing: tokens.spacingLarge
    readonly property real preferredWidth: tokens.referenceCardWidth

    DemoCard {
        width: parent.width
        tokens: root.tokens
        title: qsTr("Radio buttons")
        contentPadding: root.tokens.inputGalleryPadding
        Row {
            spacing: root.metrics.radioReadOnlySpacing
            SK.Switch {
                id: readOnlySwitch
                objectName: "comparison.radio.readOnly"
                spacing: 0
                Accessible.name: qsTr("Read only")
            }
            Text {
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Read only")
                font: root.tokens.labelMedium
                color: root.tokens.surfaceForeground
                textFormat: Text.PlainText
                Accessible.ignored: true
            }
        }
        SK.RadioButton {
            objectName: "comparison.radio.option1"
            text: qsTr("option 1")
            checked: true
            RadioButtonSupport.readOnly: readOnlySwitch.checked
        }
        SK.RadioButton {
            objectName: "comparison.radio.option2"
            text: qsTr("option 2")
            RadioButtonSupport.readOnly: readOnlySwitch.checked
        }
        SK.RadioButton {
            objectName: "comparison.radio.option3"
            text: qsTr("option 3")
            RadioButtonSupport.readOnly: readOnlySwitch.checked
        }
    }
}
