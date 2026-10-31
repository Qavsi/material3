// Adapted from QmlMaterial 229bc3e6 TimeInput.qml (MIT).
pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

SK.TextField {
    id: root
    required property MaterialTimeState time
    required property Material3Theme tokens
    required property bool hourField
    property bool editable: time.displayMode === MaterialTimeState.Input
    readonly property bool selected: time.selection === (hourField ? MaterialTimeState.Hours : MaterialTimeState.Minutes)
    readonly property bool acceptable: hourField ? time.hourAcceptable : time.minuteAcceptable
    signal advanceRequested()
    signal backRequested()
    SK.StyleVariation.variations: ["timePickerField"]
    text: hourField ? time.hourText : time.minuteText
    font: tokens.displayLarge
    color: !acceptable ? tokens.error : selected ? tokens.primary : tokens.surfaceForeground
    selectedTextColor: tokens.primaryForeground
    selectionColor: tokens.primary
    readOnly: !editable
    selectByMouse: editable
    // Qt 6.12 keeps the active item in the tab chain until focus moves.
    activeFocusOnTab: editable || activeFocus
    maximumLength: 2
    inputMethodHints: Qt.ImhDigitsOnly | Qt.ImhNoPredictiveText
    horizontalAlignment: TextInput.AlignHCenter
    verticalAlignment: TextInput.AlignVCenter
    Accessible.name: hourField ? qsTr("Hour") : qsTr("Minute")
    Accessible.description: acceptable ? "" : hourField ? qsTr("Enter a valid hour") : qsTr("Enter a minute from 0 to 59")
    onTextEdited: {
        if (hourField) time.editHour(text)
        else time.editMinute(text)
        if (hourField && text.length === 2 && time.hourAcceptable)
            advanceRequested()
    }
    onActiveFocusChanged: {
        if (activeFocus) {
            time.selection = hourField ? MaterialTimeState.Hours : MaterialTimeState.Minutes
            if (editable) selectAll()
        }
    }
    Keys.onReturnPressed: {
        if (hourField) advanceRequested()
        else time.commitInput()
    }
    Keys.onEnterPressed: {
        if (hourField) advanceRequested()
        else time.commitInput()
    }
    Keys.onEscapePressed: event => {
        root.time.discardInput()
        event.accepted = false
    }
    Keys.onPressed: event => {
        if (!hourField && event.key === Qt.Key_Backspace && text.length === 0) {
            backRequested()
            event.accepted = true
        }
    }
    TapHandler {
        enabled: !root.editable
        onTapped: {
            root.time.selection = root.hourField ? MaterialTimeState.Hours : MaterialTimeState.Minutes
            root.forceActiveFocus(Qt.MouseFocusReason)
        }
        onDoubleTapped: root.time.displayMode = MaterialTimeState.Input
    }
}
