// QCM229bc3e6 TimePickerDialog flow; native Qt owns the dialog lifecycle.
pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK

Material3PickerDialog {
    id: root
    property int selectedHour: 0
    property int selectedMinute: 0
    property bool use24Hour: locale.timeFormat(Locale.ShortFormat).toLowerCase().indexOf("ap") < 0
    property int currentHour: selectedHour
    property int currentMinute: selectedMinute
    property alias displayMode: timeEditor.displayMode
    readonly property alias picker: timeEditor
    readonly property bool selectionValid: timeEditor.selectionValid
    signal acceptedTime(int hour, int minute)
    title: qsTr("Select time")
    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0
    spacing: 0
    implicitWidth: timeEditor.implicitWidth
    height: Math.min(implicitHeight, parent ? Math.max(0, parent.height - tokens.spacingExtraLarge) : implicitHeight)
    function selectTime(hour: int, minute: int): void {
        if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
            currentHour = hour
            currentMinute = minute
            timeEditor.discardInput()
        }
    }
    enter: Material3DialogEnterTransition { control: root }
    exit: Material3DialogExitTransition { control: root }
    SK.Overlay.modal: Material3DialogOverlay { control: root }
    header: null
    footer: Material3DialogButtonBox {
        standardButtons: root.standardButtons
        spacing: root.tokens.spacingSmall
        leftPadding: root.tokens.timePadding
        rightPadding: root.tokens.timePadding
        topPadding: 0
        bottomPadding: root.tokens.timePadding
        delegate: SK.Button {
            flat: true
            enabled: SK.DialogButtonBox.buttonRole !== SK.DialogButtonBox.AcceptRole || root.selectionValid
        }
    }
    contentItem: Flickable {
        implicitWidth: timeEditor.implicitWidth
        implicitHeight: timeEditor.implicitHeight
        contentWidth: width
        contentHeight: timeEditor.implicitHeight
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        Material3TimePicker {
            id: timeEditor
            width: parent.width
            locale: root.locale
            use24Hour: root.use24Hour
            selectedHour: root.currentHour
            selectedMinute: root.currentMinute
            supportingText: root.title
            onSelectedTimeChangeRequested: (hour, minute) => {
                root.currentHour = hour
                root.currentMinute = minute
            }
        }
    }
    onAboutToShow: {
        currentHour = selectedHour
        currentMinute = selectedMinute
        timeEditor.discardInput()
        timeEditor.selection = Material3TimePicker.Hours
    }
    onOpened: timeEditor.focusSelection()
    onAccepted: if (timeEditor.commitInput()) acceptedTime(currentHour, currentMinute)
}
