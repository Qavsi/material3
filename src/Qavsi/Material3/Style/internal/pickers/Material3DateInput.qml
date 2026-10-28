pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import "Material3DateMath.js" as DateMath

SK.TextField {
    id: root
    property var locale: Qt.locale()
    property date selectedDate: new Date(NaN)
    property date minimumDate: new Date(1900, 0, 1)
    property date maximumDate: new Date(2100, 11, 31)
    property string inputDateFormat: root.locale.dateFormat(Locale.ShortFormat)
    readonly property date parsedDate: Date.fromLocaleDateString(root.locale, root.text, root.inputDateFormat)
    readonly property bool dateValid: DateMath.isSelectable(parsedDate, minimumDate, maximumDate)
    signal selectedDateChangeRequested(date date)
    text: isNaN(selectedDate.getTime()) ? "" : selectedDate.toLocaleDateString(root.locale, root.inputDateFormat)
    placeholderText: inputDateFormat
    inputMethodHints: Qt.ImhDate
    selectByMouse: true
    Accessible.description: text.length > 0 && !dateValid ? qsTr("Enter a valid date") : inputDateFormat
    onEditingFinished: {
        if (dateValid)
            selectedDateChangeRequested(parsedDate);
    }
}
