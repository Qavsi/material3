// Calendar/header geometry references QmlMaterial 0.6.1 (1912605, MIT); Qt owns the calendar model.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as C
import QtQuick.Layouts
import Qt.labs.StyleKit as SK

Material3PickerDialog {
    id: root
    property date selectedDate: new Date()
    property date minimumDate: new Date(1900, 0, 1)
    property date maximumDate: new Date(2100, 11, 31)
    property date currentDate: selectedDate
    property int month: currentDate.getMonth()
    property int year: currentDate.getFullYear()
    readonly property bool selectionValid: isSelectable(currentDate)
    signal acceptedDate(date date)
    title: qsTr("Select date")
    implicitWidth: root.tokens.pickerWidth

    function dayNumber(value: date): real {
        return Date.UTC(value.getFullYear(), value.getMonth(), value.getDate());
    }
    function isSelectable(value: date): bool {
        const day = dayNumber(value);
        return !isNaN(day) && day >= dayNumber(minimumDate) && day <= dayNumber(maximumDate);
    }
    function selectDate(value: date): void {
        if (isSelectable(value)) {
            currentDate = new Date(value.getFullYear(), value.getMonth(), value.getDate());
            month = currentDate.getMonth();
            year = currentDate.getFullYear();
        }
    }
    function shiftMonth(offset: int): void {
        const first = new Date(year, month + offset, 1);
        month = first.getMonth();
        year = first.getFullYear();
    }
    onAboutToShow: {
        const day = dayNumber(selectedDate);
        const value = isNaN(day) ? minimumDate : day < dayNumber(minimumDate) ? minimumDate
            : day > dayNumber(maximumDate) ? maximumDate : selectedDate;
        currentDate = value;
        month = value.getMonth();
        year = value.getFullYear();
    }
    onAccepted: {
        if (selectionValid)
            acceptedDate(currentDate);
    }
    footer: SK.DialogButtonBox {
        standardButtons: root.standardButtons
        delegate: SK.Button {
            flat: true
            enabled: SK.DialogButtonBox.buttonRole !== SK.DialogButtonBox.AcceptRole || root.selectionValid
        }
    }
    contentItem: ColumnLayout {
        spacing: root.tokens.spacingSmall
        SK.Label {
            Layout.fillWidth: true
            text: root.selectionValid ? root.currentDate.toLocaleDateString(root.locale, Locale.LongFormat) : qsTr("No date available")
            color: root.tokens.surfaceForeground
            font: root.tokens.titleLarge
            wrapMode: Text.Wrap
        }
        RowLayout {
            Layout.fillWidth: true
            SK.Button {
                text: "‹"
                Accessible.name: qsTr("Previous month")
                enabled: root.dayNumber(new Date(root.year, root.month, 0)) >= root.dayNumber(root.minimumDate)
                onClicked: root.shiftMonth(-1)
            }
            SK.Label {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: new Date(root.year, root.month, 1).toLocaleDateString(root.locale, "MMMM yyyy")
                color: root.tokens.surfaceForeground
                font: root.tokens.titleMedium
            }
            SK.Button {
                text: "›"
                Accessible.name: qsTr("Next month")
                enabled: root.dayNumber(new Date(root.year, root.month + 1, 1)) <= root.dayNumber(root.maximumDate)
                onClicked: root.shiftMonth(1)
            }
        }
        C.DayOfWeekRow {
            Layout.fillWidth: true
            Layout.preferredHeight: root.tokens.pickerDaySize
            locale: root.locale
            font: root.tokens.labelLarge
            delegate: SK.Label {
                required property string shortName
                text: shortName
                color: root.tokens.surfaceVariantForeground
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }
        }
        C.MonthGrid {
            Layout.fillWidth: true
            Layout.preferredHeight: root.tokens.pickerDaySize * 6
            month: root.month
            year: root.year
            locale: root.locale
            spacing: 0
            delegate: SK.Button {
                required property var model
                text: model.day.toLocaleString(root.locale, "f", 0)
                checked: root.dayNumber(model.date) === root.dayNumber(root.currentDate)
                enabled: model.month === root.month && root.isSelectable(model.date)
                opacity: model.month === root.month ? 1 : 0
                Accessible.name: model.date.toLocaleDateString(root.locale, Locale.LongFormat)
                SK.StyleVariation.variations: ["pickerDay"]
                onClicked: root.selectDate(model.date)
            }
        }
    }
}
