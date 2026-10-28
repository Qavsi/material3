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
    property date selectedDate: new Date(2026, 1, 15)
    property color selectedColor: tokens.primary
    property list<url> selectedFiles
    property bool use24Hour: true
    property int selectedHour: 9
    property int selectedMinute: 30
    spacing: tokens.spacingMedium
    SK.Label { text: qsTr("Date, time, color and files"); color: root.tokens.surfaceForeground; font: root.tokens.titleLarge }
    SK.Label { text: root.selectedDate.toLocaleDateString() + " · " + root.selectedHour + ":" + root.selectedMinute + " · " + root.selectedColor; color: root.tokens.surfaceForeground }
    SK.Button { text: qsTr("Choose color"); onClicked: colorPicker.open() }
    SK.Button { text: qsTr("Choose files"); onClicked: filePicker.open() }
    SK.Label { text: root.selectedFiles.join("\n"); color: root.tokens.surfaceForeground; Layout.fillWidth: true; wrapMode: Text.WrapAnywhere }
    Dialogs.FileDialog {
        id: filePicker
        title: qsTr("Choose files")
        fileMode: Dialogs.FileDialog.OpenFiles
        onAccepted: root.selectedFiles = selectedFiles
    }
    Material3ColorPicker {
        id: colorPicker
        objectName: "comparison.pickers.color"
        selectedColor: root.selectedColor
        onAcceptedColor: color => root.selectedColor = color
    }
    Material3Carousel {
        id: carousel
        objectName: "comparison.pickers.carousel"
        Layout.fillWidth: true
        model: [qsTr("First"), qsTr("Second"), qsTr("Third"), qsTr("Fourth")]
        delegate: SK.Button {
            required property int index
            required property string modelData
            width: root.tokens.carouselItemWidth
            height: carousel.height
            text: modelData
            checked: carousel.currentIndex === index
            onClicked: { carousel.currentIndex = index; carousel.forceActiveFocus(); }
        }
    }
    RowLayout {
        SK.Button { text: qsTr("Previous"); enabled: carousel.currentIndex > 0; onClicked: carousel.previous() }
        SK.Label { text: (carousel.currentIndex + 1) + " / " + carousel.count; color: root.tokens.surfaceForeground }
        SK.Button { text: qsTr("Next"); enabled: carousel.currentIndex < carousel.count - 1; onClicked: carousel.next() }
    }
    SK.Button {
        text: qsTr("Choose date")
        onClicked: datePicker.open()
    }
    SK.Button { text: qsTr("Choose time"); onClicked: timePicker.open() }
    Material3TimePicker {
        id: timePicker
        objectName: "comparison.pickers.time"
        use24Hour: root.use24Hour
        selectedHour: root.selectedHour
        selectedMinute: root.selectedMinute
        onAcceptedTime: (hour, minute) => { root.selectedHour = hour; root.selectedMinute = minute; }
    }
    Material3DatePicker {
        id: datePicker
        objectName: "comparison.pickers.date"
        selectedDate: root.selectedDate
        minimumDate: new Date(2026, 1, 10)
        maximumDate: new Date(2026, 1, 20)
        onAcceptedDate: date => root.selectedDate = date
    }
}
