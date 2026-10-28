pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Style

DemoCard {
    id: root
    title: qsTr("Dialogs and feedback")
    SK.Button {
        id: openDialog
        objectName: "comparison.dialog.open"
        text: qsTr("Reset settings")
        onClicked: dialog.open()
    }
    SK.Dialog {
        id: dialog
        objectName: "comparison.dialog"
        parent: SK.Overlay.overlay
        x: (parent.width - width) / 2
        y: (parent.height - height) / 2
        width: Math.min(root.tokens.dialogMaximumWidth, parent.width - root.tokens.spacingExtraLarge)
        title: qsTr("Reset settings?")
        font: root.tokens.bodyMedium
        modal: true
        focus: true
        standardButtons: SK.Dialog.Reset | SK.Dialog.Cancel
        enter: Material3DialogEnterTransition { control: dialog }
        exit: Material3DialogExitTransition { control: dialog }
        SK.Overlay.modal: Material3DialogOverlay { control: dialog }
        header: Material3DialogHeader { control: dialog }
        footer: Material3DialogButtonBox { }
        contentItem: Text {
            text: qsTr("Your device settings will return to their defaults. This action can be cancelled.")
            font: root.tokens.bodyMedium
            color: root.tokens.surfaceVariantForeground
            wrapMode: Text.WordWrap
        }
    }
    SK.Button {
        text: qsTr("Show message")
        objectName: "comparison.snackbar.open"
        onClicked: snackbar.open()
    }
    Material3Snackbar {
        id: snackbar
        objectName: "comparison.snackbar"
        parent: SK.Overlay.overlay
        x: (parent.width - width) / 2
        y: parent.height - height - root.tokens.spacingMedium
        width: Math.min(root.tokens.dialogMaximumWidth, parent.width - root.tokens.spacingExtraLarge)
        text: qsTr("Settings saved")
        showClose: true
        action: SK.Action { text: qsTr("Undo"); objectName: "comparison.snackbar.action" }
    }
    SK.Button {
        id: tipTrigger
        text: qsTr("Help")
        hoverEnabled: true
        Material3ToolTip {
            parent: tipTrigger
            visible: tipTrigger.hovered
            text: qsTr("Changes apply to this device only.")
        }
    }
    SK.Button {
        id: richTrigger
        objectName: "comparison.tooltip.open"
        text: qsTr("More about reset")
        onClicked: richTip.open()
        Material3ToolTip {
            id: richTip
            objectName: "comparison.tooltip"
            parent: richTrigger
            subhead: qsTr("Device settings")
            text: qsTr("Reset restores local preferences. Saved documents are kept.")
            actionItem: Component {
                SK.Button { text: qsTr("Reset settings"); flat: true; onClicked: { richTip.close(); dialog.open() } }
            }
        }
    }
}
