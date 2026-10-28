// QmlMaterial 0.6.1 (1912605, MIT) geometry; native Qt owns calendar data and input.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as C
import QtQuick.Layouts
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme
import "Material3DateMath.js" as DateMath

SK.Pane {
    id: root
    enum SelectionMode { Single, Range }
    enum DisplayMode { Calendar, Input }
    enum Navigation { Days, Years, Months }
    property int navigation: Material3DatePicker.Days
    readonly property int firstYear: Math.max(1, isNaN(minimumDate.getTime()) ? 1 : minimumDate.getFullYear())
    readonly property int lastYear: Math.min(9999, isNaN(maximumDate.getTime()) ? 9999 : maximumDate.getFullYear())
    property date focusedDate: selectedDate
    readonly property date tabDate: {
        const candidate = selectionMode === Material3DatePicker.Single ? selectedDate : rangeStart;
        if (isSelectable(focusedDate) && focusedDate.getFullYear() === year && focusedDate.getMonth() === month) return focusedDate;
        if (isSelectable(candidate) && candidate.getFullYear() === year && candidate.getMonth() === month) return candidate;
        const first = makeDate(year, month, 1);
        const fallback = !isNaN(minimumDate.getTime()) && dayNumber(first) < dayNumber(minimumDate) ? minimumDate : first;
        return isSelectable(fallback) && fallback.getFullYear() === year && fallback.getMonth() === month ? fallback : new Date(NaN);
    }
    signal dateFocusRequested()
    property int selectionMode: Material3DatePicker.Single
    property int displayMode: Material3DatePicker.Calendar
    property bool showModeToggle: true
    property bool showHeader: true
    property string inputDateFormat: locale.dateFormat(Locale.ShortFormat)
    property string headlineFormat: locale.dateFormat(Locale.ShortFormat)
    property string monthTitleFormat: "MMMM yyyy"
    property string supportingText: selectionMode === Material3DatePicker.Range ? qsTr("Select date range") : qsTr("Select date")
    property date selectedDate: new Date()
    property date rangeStart: new Date(NaN)
    property date rangeEnd: new Date(NaN)
    property date minimumDate: new Date(1900, 0, 1)
    property date maximumDate: new Date(2100, 11, 31)
    property int month: isNaN(selectedDate.getTime()) ? minimumDate.getMonth() : selectedDate.getMonth()
    property int year: isNaN(selectedDate.getTime()) ? minimumDate.getFullYear() : selectedDate.getFullYear()
    readonly property bool selectionValid: selectionMode === Material3DatePicker.Single ? isSelectable(selectedDate)
        : isSelectable(rangeStart) && isSelectable(rangeEnd) && dayNumber(rangeStart) <= dayNumber(rangeEnd)
    readonly property Material3Theme tokens: (SK.StyleKit.style as Material3Style)?.tokens ?? fallbackTokens
    readonly property Material3Theme fallbackTokens: Material3Theme { }
    signal selectedDateChangeRequested(date date)
    signal rangeChangeRequested(date start, date end)
    implicitWidth: tokens.pickerWidth
    implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding
    padding: 0
    SK.StyleVariation.variations: ["datePicker"]

    onSelectedDateChanged: {
        if (!isNaN(selectedDate.getTime())) {
            month = selectedDate.getMonth(); year = selectedDate.getFullYear(); focusedDate = selectedDate;
        }
    }
    onDisplayModeChanged: {
        navigation = Material3DatePicker.Days;
        if (displayMode === Material3DatePicker.Input)
            Qt.callLater(() => {
                if (root.displayMode === Material3DatePicker.Input && root.visible && root.enabled)
                    startInput.forceActiveFocus(Qt.OtherFocusReason);
            });
    }
    onMinimumDateChanged: clampView()
    onMaximumDateChanged: clampView()
    function makeDate(year: int, month: int, day: int): date {
        const result = new Date(0);
        result.setFullYear(year, month, day);
        result.setHours(0, 0, 0, 0);
        return result;
    }
    function dayNumber(value: date): real { return DateMath.dayNumber(value); }
    function isSelectable(value: date): bool { return DateMath.isSelectable(value, minimumDate, maximumDate); }
    function monthEnabled(viewYear: int, viewMonth: int): bool {
        if (viewYear < firstYear || viewYear > lastYear || viewMonth < 0 || viewMonth > 11) return false;
        const first = dayNumber(makeDate(viewYear, viewMonth, 1));
        const last = dayNumber(makeDate(viewYear, viewMonth + 1, 0));
        return (isNaN(minimumDate.getTime()) || last >= dayNumber(minimumDate))
            && (isNaN(maximumDate.getTime()) || first <= dayNumber(maximumDate))
            && (isNaN(minimumDate.getTime()) || isNaN(maximumDate.getTime()) || dayNumber(minimumDate) <= dayNumber(maximumDate));
    }
    function clampView(): void {
        if (firstYear > lastYear) return;
        year = Math.max(firstYear, Math.min(lastYear, year));
        if (!monthEnabled(year, month)) {
            if (!isNaN(minimumDate.getTime()) && year === minimumDate.getFullYear()) month = minimumDate.getMonth();
            else if (!isNaN(maximumDate.getTime()) && year === maximumDate.getFullYear()) month = maximumDate.getMonth();
        }
    }
    function toggleNavigation(): void {
        navigation = navigation === Material3DatePicker.Days ? Material3DatePicker.Years : Material3DatePicker.Days;
    }
    function selectYear(value: int): void {
        if (value < firstYear || value > lastYear) return;
        year = value;
        navigation = Material3DatePicker.Months;
    }
    function selectMonth(value: int): void {
        if (!monthEnabled(year, value)) return;
        month = value;
        navigation = Material3DatePicker.Days;
    }
    function formatDate(value: date): string {
        return isNaN(value.getTime()) ? "—" : value.toLocaleDateString(locale, headlineFormat);
    }
    function selectDate(value: date): void {
        if (!isSelectable(value)) return;
        const date = makeDate(value.getFullYear(), value.getMonth(), value.getDate());
        if (selectionMode === Material3DatePicker.Single) selectedDateChangeRequested(date);
        else if (!isSelectable(rangeStart) || !isNaN(rangeEnd.getTime())) rangeChangeRequested(date, new Date(NaN));
        else if (dayNumber(date) < dayNumber(rangeStart)) rangeChangeRequested(date, rangeStart);
        else rangeChangeRequested(rangeStart, date);
        month = date.getMonth(); year = date.getFullYear(); focusedDate = date;
        navigation = Material3DatePicker.Days;
    }
    function shiftMonth(offset: int): void {
        const first = makeDate(year, month + offset, 1);
        if (!monthEnabled(first.getFullYear(), first.getMonth())) return;
        month = first.getMonth(); year = first.getFullYear();
    }
    function focusDate(value: date): void {
        if (!isSelectable(value)) return;
        focusedDate = value;
        month = value.getMonth(); year = value.getFullYear();
        navigation = Material3DatePicker.Days;
        Qt.callLater(() => root.dateFocusRequested());
    }
    function moveDate(value: date, days: int): void {
        focusDate(makeDate(value.getFullYear(), value.getMonth(), value.getDate() + days));
    }
    function moveFocusMonth(value: date, offset: int): void {
        const first = makeDate(value.getFullYear(), value.getMonth() + offset, 1);
        focusDate(makeDate(first.getFullYear(), first.getMonth(), Math.min(value.getDate(), makeDate(first.getFullYear(), first.getMonth() + 1, 0).getDate())));
    }
    contentItem: ColumnLayout {
        spacing: 0
        Item {
            id: header
            Layout.fillWidth: true
            implicitHeight: Math.max(root.tokens.pickerHeaderMinimumHeight,
                root.tokens.pickerHeaderVerticalPadding * 2 + supporting.implicitHeight + root.tokens.spacingSmall + headline.implicitHeight)
            visible: root.showHeader
            SK.Label {
                id: supporting
                leftPadding: 0; rightPadding: 0; topPadding: 0; bottomPadding: 0
                anchors { left: parent.left; top: parent.top; leftMargin: root.tokens.pickerHeaderPadding; topMargin: root.tokens.pickerHeaderVerticalPadding }
                text: root.supportingText
                color: root.tokens.surfaceVariantForeground
                font: root.tokens.labelMedium
            }
            SK.Label {
                id: headline
                leftPadding: 0; rightPadding: 0; topPadding: 0; bottomPadding: 0
                anchors { left: parent.left; right: toggle.left; bottom: parent.bottom; leftMargin: root.tokens.pickerHeaderPadding; rightMargin: root.tokens.spacingSmall; bottomMargin: root.tokens.pickerHeaderVerticalPadding }
                text: root.selectionMode === Material3DatePicker.Single ? root.formatDate(root.selectedDate)
                    : root.formatDate(root.rangeStart) + " – " + root.formatDate(root.rangeEnd)
                color: root.tokens.surfaceForeground
                font: root.tokens.headlineMedium
                maximumLineCount: 2
                elide: Text.ElideRight
            }
            SK.Button {
                id: toggle
                anchors { right: parent.right; bottom: parent.bottom; rightMargin: root.tokens.pickerModeButtonInset; bottomMargin: root.tokens.pickerModeButtonInset }
                visible: root.showModeToggle
                width: visible ? implicitWidth : 0
                icon.name: root.displayMode === Material3DatePicker.Calendar ? "material:edit" : "material:calendar_today"
                Accessible.name: root.displayMode === Material3DatePicker.Calendar ? qsTr("Enter date") : qsTr("Show calendar")
                SK.StyleVariation.variations: ["iconSmall", "iconStandard"]
                contentItem: Material3ButtonContent { control: toggle }
                onClicked: root.displayMode = root.displayMode === Material3DatePicker.Calendar ? Material3DatePicker.Input : Material3DatePicker.Calendar
            }
            Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: root.tokens.outlineWidth; color: root.tokens.outlineVariant }
        }
        Material3DateNavigation {
            Layout.fillWidth: true
            visible: root.displayMode === Material3DatePicker.Calendar
            picker: root
        }
        ColumnLayout {
            Layout.fillWidth: true
            Layout.leftMargin: root.tokens.pickerHeaderPadding
            Layout.rightMargin: root.tokens.pickerHeaderPadding
            Layout.topMargin: root.tokens.pickerHeaderVerticalPadding
            Layout.bottomMargin: root.tokens.pickerHeaderVerticalPadding
            spacing: root.tokens.spacingMedium
            visible: root.displayMode === Material3DatePicker.Input
            Material3DateInput {
                id: startInput
                Layout.fillWidth: true
                placeholderText: root.selectionMode === Material3DatePicker.Single ? qsTr("Date") : qsTr("Start date")
                TextFieldSupport.supportingText: root.inputDateFormat
                locale: root.locale
                selectedDate: root.selectionMode === Material3DatePicker.Single ? root.selectedDate : root.rangeStart
                minimumDate: root.minimumDate
                maximumDate: root.maximumDate
                inputDateFormat: root.inputDateFormat
                Accessible.name: root.selectionMode === Material3DatePicker.Single ? qsTr("Date") : qsTr("Start date")
                onSelectedDateChangeRequested: date => {
                    if (root.selectionMode === Material3DatePicker.Single) root.selectedDateChangeRequested(date);
                    else root.rangeChangeRequested(date, root.isSelectable(root.rangeEnd) && root.dayNumber(root.rangeEnd) >= root.dayNumber(date) ? root.rangeEnd : new Date(NaN));
                }
            }
            Material3DateInput {
                Layout.fillWidth: true
                visible: root.selectionMode === Material3DatePicker.Range
                placeholderText: qsTr("End date")
                TextFieldSupport.supportingText: root.inputDateFormat
                locale: root.locale
                selectedDate: root.rangeEnd
                minimumDate: root.isSelectable(root.rangeStart) ? root.rangeStart : root.minimumDate
                maximumDate: root.maximumDate
                inputDateFormat: root.inputDateFormat
                Accessible.name: qsTr("End date")
                onSelectedDateChangeRequested: date => {
                    if (root.isSelectable(root.rangeStart)) root.rangeChangeRequested(root.rangeStart, date);
                }
            }
        }
        ColumnLayout {
            Layout.fillWidth: true
            Layout.leftMargin: root.tokens.pickerDaySpacing * 2
            Layout.rightMargin: root.tokens.pickerDaySpacing * 2
            spacing: 0
            visible: root.displayMode === Material3DatePicker.Calendar && root.navigation === Material3DatePicker.Days
            C.DayOfWeekRow {
                Layout.fillWidth: true
                Layout.preferredHeight: root.tokens.pickerWeekdayHeight + root.tokens.pickerWeekdayPadding * 2
                leftPadding: 0
                rightPadding: 0
                topPadding: root.tokens.pickerWeekdayPadding
                bottomPadding: root.tokens.pickerWeekdayPadding
                spacing: root.tokens.pickerDaySpacing
                locale: root.locale
                delegate: SK.Label {
                    required property string narrowName
                    text: narrowName.toUpperCase()
                    font: root.tokens.bodySmall
                    color: root.tokens.surfaceVariantForeground
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                }
            }
            C.MonthGrid {
                id: grid
                Layout.fillWidth: true
                Layout.preferredHeight: root.tokens.pickerDaySize * 6 + root.tokens.pickerDaySpacing * 5
                month: root.month
                year: root.year
                locale: root.locale
                spacing: root.tokens.pickerDaySpacing
                delegate: SK.Button {
                    id: day
                    required property var model
                    readonly property real number: root.dayNumber(model.date)
                    readonly property bool endpoint: root.selectionMode === Material3DatePicker.Single
                        ? number === root.dayNumber(root.selectedDate)
                        : number === root.dayNumber(root.rangeStart) || number === root.dayNumber(root.rangeEnd)
                    readonly property bool inRange: root.selectionMode === Material3DatePicker.Range
                        && number > root.dayNumber(root.rangeStart) && number < root.dayNumber(root.rangeEnd)
                    implicitWidth: root.tokens.pickerDaySize
                    implicitHeight: root.tokens.pickerDaySize
                    text: model.day.toLocaleString(root.locale, "f", 0)
                    font: root.tokens.bodyLarge
                    activeFocusOnTab: number === root.dayNumber(root.tabDate) || activeFocus
                    contentItem: Material3ButtonContent {
                        control: day
                        opacity: day.model.month === root.month ? 1 : 0.5
                    }
                    Connections {
                        target: root
                        function onDateFocusRequested(): void {
                            if (day.number === root.dayNumber(root.focusedDate)) day.forceActiveFocus(Qt.TabFocusReason);
                        }
                    }
                    checked: endpoint
                    highlighted: inRange
                    enabled: root.isSelectable(model.date)
                    Accessible.name: model.date.toLocaleDateString(root.locale, Locale.LongFormat)
                    Accessible.selected: endpoint || inRange
                    SK.StyleVariation.variations: ["pickerDay"]
                    onClicked: root.selectDate(model.date)
                    Keys.onLeftPressed: event => root.moveDate(model.date, root.mirrored ? 1 : -1)
                    Keys.onRightPressed: event => root.moveDate(model.date, root.mirrored ? -1 : 1)
                    Keys.onUpPressed: event => root.moveDate(model.date, -7)
                    Keys.onDownPressed: event => root.moveDate(model.date, 7)
                    Keys.onReturnPressed: root.selectDate(model.date)
                    Keys.onEnterPressed: root.selectDate(model.date)
                    Keys.onPressed: event => {
                        if (event.key === Qt.Key_PageUp || event.key === Qt.Key_PageDown) {
                            root.moveFocusMonth(model.date, event.key === Qt.Key_PageUp ? -1 : 1);
                            event.accepted = true;
                        } else if (event.key === Qt.Key_Home || event.key === Qt.Key_End) {
                            root.focusDate(root.makeDate(root.year, event.key === Qt.Key_Home ? root.month : root.month + 1, event.key === Qt.Key_Home ? 1 : 0));
                            event.accepted = true;
                        }
                    }
                }
            }
        }
    }
}
