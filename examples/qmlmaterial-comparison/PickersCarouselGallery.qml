pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Dialogs as Dialogs
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme
import Qavsi.Material3.Style

ColumnLayout {
    id: root
    objectName: "comparison.pickers.gallery"
    required property Material3Theme tokens
    property alias selectedDate: dateExamples.selectedDate
    property alias selectedColor: colorExamples.selectedColor
    property list<url> selectedFiles
    property bool use24Hour: true
    property int selectedHour: 9
    property int selectedMinute: 30
    spacing: tokens.spacingLarge
    CarouselGallery { Layout.fillWidth: true; tokens: root.tokens }
    DatePickersGallery {
        id: dateExamples
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: root.tokens.pickerWidth
        Layout.maximumWidth: Math.min(root.width, root.tokens.pickerWidth)
        tokens: root.tokens
    }
    ColorPickersGallery {
        id: colorExamples
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: root.tokens.pickerWidth
        Layout.maximumWidth: Math.min(root.width, root.tokens.pickerWidth)
        tokens: root.tokens
    }
    SK.Label { text: qsTr("Time picker"); color: root.tokens.surfaceForeground; font: root.tokens.titleLarge }
    SK.Button { text: qsTr("Choose time"); onClicked: timePicker.open() }
    Material3TimePicker {
        id: timePicker
        objectName: "comparison.pickers.time"
        use24Hour: root.use24Hour
        selectedHour: root.selectedHour
        selectedMinute: root.selectedMinute
        onAcceptedTime: (hour, minute) => { root.selectedHour = hour; root.selectedMinute = minute; }
    }
    SK.Label { text: qsTr("File pickers"); color: root.tokens.surfaceForeground; font: root.tokens.titleLarge }
    SK.Button { text: qsTr("Choose files"); onClicked: filePicker.open() }
    SK.Label { text: root.selectedFiles.join("\n"); color: root.tokens.surfaceForeground; Layout.fillWidth: true; wrapMode: Text.WrapAnywhere }
    Dialogs.FileDialog {
        id: filePicker
        title: qsTr("Choose files")
        fileMode: Dialogs.FileDialog.OpenFiles
        onAccepted: root.selectedFiles = selectedFiles
    }
}
