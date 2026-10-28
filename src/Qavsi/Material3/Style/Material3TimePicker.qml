// QmlMaterial 0.6.1 time input/period recipe (1912605, MIT), composed from native Qt controls.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Qt.labs.StyleKit as SK

Material3PickerDialog {
    id: root
    property int selectedHour: 0
    property int selectedMinute: 0
    property bool use24Hour: locale.timeFormat(Locale.ShortFormat).toLowerCase().indexOf("ap") < 0
    property int currentHour: selectedHour
    property int currentMinute: selectedMinute
    readonly property bool selectionValid: currentHour >= 0 && currentHour < 24 && currentMinute >= 0 && currentMinute < 60
    signal acceptedTime(int hour, int minute)
    title: qsTr("Select time")
    implicitWidth: root.tokens.pickerWidth

    function selectTime(hour: int, minute: int): void {
        if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60) {
            currentHour = hour;
            currentMinute = minute;
        }
    }
    readonly property var hourLabels: {
        const labels = [];
        for (let hour = 0; hour < (use24Hour ? 24 : 12); ++hour)
            labels.push(new Date(2000, 0, 1, use24Hour ? hour : hour + 1).toLocaleTimeString(locale, "hh"));
        return labels;
    }
    readonly property var minuteLabels: {
        const labels = [];
        for (let minute = 0; minute < 60; ++minute)
            labels.push(new Date(2000, 0, 1, 0, minute).toLocaleTimeString(locale, "mm"));
        return labels;
    }
    onAboutToShow: { currentHour = selectedHour; currentMinute = selectedMinute; }
    onAccepted: {
        if (selectionValid)
            acceptedTime(currentHour, currentMinute);
    }
    footer: SK.DialogButtonBox {
        standardButtons: root.standardButtons
        delegate: SK.Button {
            flat: true
            enabled: SK.DialogButtonBox.buttonRole !== SK.DialogButtonBox.AcceptRole || root.selectionValid
        }
    }
    contentItem: ColumnLayout {
        spacing: root.tokens.spacingMedium
        SK.Label {
            Layout.fillWidth: true
            text: root.selectionValid ? new Date(2000, 0, 1, root.currentHour, root.currentMinute).toLocaleTimeString(root.locale,
                root.use24Hour ? "HH:mm" : "h:mm AP") : qsTr("Select a valid time")
            color: root.tokens.surfaceForeground
            font: root.tokens.titleLarge
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: root.tokens.spacingSmall
            SK.ComboBox {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                model: root.hourLabels
                currentIndex: root.use24Hour ? root.currentHour : (root.currentHour + 11) % 12
                Accessible.name: qsTr("Hour")
                onActivated: index => root.selectTime(root.use24Hour ? index : (index + 1) % 12 + (root.currentHour >= 12 ? 12 : 0), root.currentMinute)
            }
            SK.Label { text: ":"; color: root.tokens.surfaceForeground; font: root.tokens.titleLarge }
            SK.ComboBox {
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                model: root.minuteLabels
                currentIndex: root.currentMinute
                Accessible.name: qsTr("Minute")
                onActivated: index => root.selectTime(root.currentHour, index)
            }
            SK.ComboBox {
                visible: !root.use24Hour
                Layout.fillWidth: true
                Layout.minimumWidth: 0
                model: [root.locale.amText, root.locale.pmText]
                currentIndex: root.currentHour >= 12 ? 1 : 0
                Accessible.name: qsTr("Period")
                onActivated: index => root.selectTime(root.currentHour % 12 + index * 12, root.currentMinute)
            }
        }
    }
}
