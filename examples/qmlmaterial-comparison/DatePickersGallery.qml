pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme
import Qavsi.Material3.Style

ColumnLayout {
    id: root
    objectName: "comparison.pickers.date.gallery"
    required property Material3Theme tokens
    property date selectedDate: new Date()
    property date minimumDate: new Date(1900, 0, 1)
    property date maximumDate: new Date(2100, 11, 31)
    property date rangeStart: new Date(NaN)
    property date rangeEnd: new Date(NaN)
    spacing: root.tokens.spacingMedium
    SK.Label { text: qsTr("Date picker"); color: root.tokens.surfaceForeground; font: root.tokens.titleLarge }
    Material3DateTextField {
        objectName: "comparison.pickers.date.field"
        visible: inlinePicker.selectionMode === Material3DatePicker.Single
        Layout.alignment: Qt.AlignHCenter
        Layout.preferredWidth: root.tokens.pickerDateInputWidth
        selectedDate: root.selectedDate
        minimumDate: inlinePicker.minimumDate
        maximumDate: inlinePicker.maximumDate
        dialog.objectName: "comparison.pickers.date"
        Accessible.name: qsTr("Date")
        onSelectedDateChangeRequested: date => root.selectedDate = date
    }
    RowLayout {
        Layout.alignment: Qt.AlignHCenter
        spacing: 0
        SK.Button {
            id: singleButton
            text: qsTr("Single")
            checked: inlinePicker.selectionMode === Material3DatePicker.Single
            SK.StyleVariation.variations: ["segmentedExtraSmallLeading", "outline"]
            contentItem: Material3ButtonContent { control: singleButton }
            onClicked: inlinePicker.selectionMode = Material3DatePicker.Single
        }
        SK.Button {
            id: rangeButton
            text: qsTr("Range")
            checked: inlinePicker.selectionMode === Material3DatePicker.Range
            SK.StyleVariation.variations: ["segmentedExtraSmallTrailing", "outline"]
            contentItem: Material3ButtonContent { control: rangeButton }
            onClicked: inlinePicker.selectionMode = Material3DatePicker.Range
        }
    }
    Material3DatePicker {
        id: inlinePicker
        objectName: "comparison.pickers.date.inline"
        Layout.preferredWidth: root.tokens.pickerWidth
        selectedDate: root.selectedDate
        rangeStart: root.rangeStart
        rangeEnd: root.rangeEnd
        minimumDate: root.minimumDate
        maximumDate: root.maximumDate
        onSelectedDateChangeRequested: date => root.selectedDate = date
        onRangeChangeRequested: (start, end) => { root.rangeStart = start; root.rangeEnd = end; }
    }
}
