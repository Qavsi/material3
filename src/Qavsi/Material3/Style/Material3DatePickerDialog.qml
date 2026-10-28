pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK

Material3PickerDialog {
    id: root
    property date selectedDate: new Date()
    property date minimumDate: new Date(1900, 0, 1)
    property date maximumDate: new Date(2100, 11, 31)
    property date currentDate: selectedDate
    property alias month: picker.month
    property alias year: picker.year
    readonly property bool selectionValid: picker.isSelectable(currentDate)
    signal acceptedDate(date date)
    title: qsTr("Select date")
    header: null
    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0
    implicitWidth: root.tokens.pickerWidth
    function selectDate(value: date): void { picker.selectDate(value); }
    function dayNumber(value: date): real { return picker.dayNumber(value); }
    function isSelectable(value: date): bool { return picker.isSelectable(value); }
    function shiftMonth(offset: int): void { picker.shiftMonth(offset); }
    onAboutToShow: {
        const day = dayNumber(selectedDate);
        currentDate = isNaN(day) || day < dayNumber(minimumDate) ? minimumDate
            : day > dayNumber(maximumDate) ? maximumDate : selectedDate;
        picker.month = currentDate.getMonth();
        picker.year = currentDate.getFullYear();
    }
    onAccepted: { if (selectionValid) acceptedDate(currentDate); }
    contentItem: Material3DatePicker {
        id: picker
        locale: root.locale
        supportingText: root.title
        selectedDate: root.currentDate
        minimumDate: root.minimumDate
        maximumDate: root.maximumDate
        onSelectedDateChangeRequested: value => root.currentDate = value
    }
    footer: SK.DialogButtonBox {
        standardButtons: root.standardButtons
        delegate: SK.Button {
            flat: true
            enabled: SK.DialogButtonBox.buttonRole !== SK.DialogButtonBox.AcceptRole || root.selectionValid
        }
    }
}
