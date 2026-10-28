pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

Material3DateInput {
    id: root
    readonly property Material3Theme tokens: (SK.StyleKit.style as Material3Style)?.tokens ?? fallbackTokens
    readonly property Material3Theme fallbackTokens: Material3Theme { }
    readonly property alias dialog: dateDialog
    readonly property bool editAllowed: enabled && visible && !readOnly
    readonly property var hostWindow: Window.window
    onEditAllowedChanged: { if (!editAllowed && dateDialog) dateDialog.close(); }
    onHostWindowChanged: { if (dateDialog) dateDialog.close(); }
    rightPadding: tokens.textFieldHorizontalPadding + tokens.minimumTargetSize + tokens.spacingSmall
    SK.Button {
        id: calendarButton
        anchors { right: parent.right; verticalCenter: parent.verticalCenter; rightMargin: root.tokens.spacingSmall }
        width: root.tokens.minimumTargetSize
        height: width
        enabled: root.editAllowed
        display: SK.Button.IconOnly
        icon.name: "material:calendar_today"
        Accessible.name: qsTr("Open calendar")
        SK.StyleVariation.variations: ["iconExtraSmall", "iconStandard"]
        contentItem: Material3ButtonContent { control: calendarButton }
        onClicked: dateDialog.open()
    }
    Material3DatePickerDialog {
        id: dateDialog
        selectedDate: root.selectedDate
        minimumDate: root.minimumDate
        maximumDate: root.maximumDate
        locale: root.locale
        onAcceptedDate: value => {
            if (root.editAllowed) root.selectedDateChangeRequested(value);
        }
    }
}
