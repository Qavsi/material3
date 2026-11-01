pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme
import Qavsi.Material3.Style

Column {
    id: root
    objectName: "comparison.otherControls"
    required property Material3Theme tokens
    property int quantity: 3
    property string notes: ""
    spacing: tokens.spacingLarge
    DemoCard {
        width: parent.width
        title: qsTr("Number stepper")
        tokens: root.tokens
        RowLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: root.tokens.spacingMedium
            SK.Label { objectName: "comparison.spinBox.label"; text: qsTr("Quantity"); font: root.tokens.bodyLarge }
            SK.SpinBox {
                id: quantity
                objectName: "comparison.spinBox"
                from: 0; to: 9
                wrap: true
                editable: true
                value: root.quantity
                onValueModified: root.quantity = value
                Accessible.name: qsTr("Quantity")
            }
            SK.SpinBox { value: 3; enabled: false; Accessible.name: qsTr("Disabled quantity") }
        }
    }
    DemoCard {
        width: parent.width
        title: qsTr("Text areas")
        tokens: root.tokens
        Column {
            width: parent.width
            spacing: root.tokens.spacingMedium
            SK.TextArea {
                objectName: "comparison.textArea"
                width: parent.width
                height: Math.max(implicitHeight, root.tokens.textFieldHeight + root.tokens.bodyLargeLineHeight * 2)
                placeholderText: qsTr("Notes")
                wrapMode: TextEdit.Wrap
                selectByMouse: true
                text: root.notes
                onTextChanged: root.notes = text
                Accessible.name: qsTr("Notes")
            }
            SK.TextArea {
                objectName: "comparison.textArea.filled"
                width: parent.width
                placeholderText: qsTr("Filled notes")
                text: qsTr("Multiple lines\nNative text editing")
                wrapMode: TextEdit.Wrap
                selectByMouse: true
                SK.StyleVariation.variations: ["textAreaFilled"]
                Accessible.name: qsTr("Filled notes")
            }
        }
    }
    DemoCard {
        width: parent.width
        title: qsTr("Bottom sheets")
        tokens: root.tokens
        RowLayout {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: root.tokens.spacingSmall
            SK.Button {
                objectName: "comparison.bottomSheet.modal.open"
                text: qsTr("Modal")
                onClicked: { standardSheet.close(); sheet.open() }
            }
            SK.Button {
                objectName: "comparison.bottomSheet.standard.open"
                text: qsTr("Standard")
                SK.StyleVariation.variations: ["filledTonal"]
                onClicked: { sheet.close(); standardSheet.open() }
            }
        }
    }
    component SheetContents: Column {
        id: sheetContents
        required property Material3BottomSheet host
        width: host.availableWidth
        padding: root.tokens.spacingLarge
        spacing: root.tokens.spacingLarge
        SK.Label { objectName: sheetContents.host.objectName + ".heading"; text: sheetContents.host.modal ? qsTr("Share your notes") : qsTr("Standard bottom sheet"); font: root.tokens.titleLarge }
        SK.Label {
            width: parent.width - parent.leftPadding - parent.rightPadding
            wrapMode: Text.Wrap
            text: qsTr("Native Drawer gestures, dismissal and focus; Material3 surface and motion.")
            font: root.tokens.bodyLarge
        }
        SK.Button {
            objectName: sheetContents.host.objectName + ".close"
            SK.StyleVariation.variations: ["ghost"]
            text: qsTr("Close")
            onClicked: sheetContents.host.close()
        }
    }
    Material3BottomSheet {
        id: sheet
        objectName: "comparison.bottomSheet"
        modal: true
        SheetContents { host: sheet }
    }
    Material3BottomSheet {
        id: standardSheet
        objectName: "comparison.bottomSheet.standard"
        modal: false
        SheetContents { host: standardSheet }
    }
}
