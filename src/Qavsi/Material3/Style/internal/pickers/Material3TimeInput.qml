// Adapted from QmlMaterial 229bc3e6 TimeInput.qml (MIT).
pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

Item {
    id: root
    required property MaterialTimeState time
    required property Material3Theme tokens
    property bool editable: time.displayMode === MaterialTimeState.Input
    property bool mirrored: false
    readonly property alias hourField: hour
    readonly property alias minuteField: minute
    readonly property real periodWidth: Math.max(tokens.timePeriodWidth,
        am.implicitContentWidth + 2 * tokens.spacingUnit, pm.implicitContentWidth + 2 * tokens.spacingUnit)
    readonly property real fieldsWidth: 2 * tokens.timeFieldWidth + tokens.timeSeparatorWidth
    readonly property real totalWidth: fieldsWidth + (time.is24Hour ? 0 : tokens.timePeriodGap + periodWidth)
    readonly property bool stackPeriod: !time.is24Hour && width < totalWidth
    readonly property real supportHeight: editable ? tokens.timeSupportingHeight : 0
    readonly property real fieldsX: (width - (stackPeriod ? fieldsWidth : totalWidth)) / 2
        + (!stackPeriod && mirrored && !time.is24Hour ? tokens.timePeriodGap + periodWidth : 0)
    implicitWidth: totalWidth
    implicitHeight: tokens.timeFieldHeight + supportHeight
        + (stackPeriod ? tokens.timePeriodGap + tokens.timeFieldHeight / 2 : 0)
    opacity: enabled ? 1 : tokens.disabledLabelOpacity

    function focusSelection(): void {
        const field = time.selection === MaterialTimeState.Hours ? hour : minute
        field.forceActiveFocus(Qt.TabFocusReason)
        if (editable) field.selectAll()
    }
    Material3TimeField {
        id: hour
        x: root.fieldsX
        width: root.tokens.timeFieldWidth; height: root.tokens.timeFieldHeight
        tokens: root.tokens; time: root.time; hourField: true; editable: root.editable
        onAdvanceRequested: {
            root.time.selection = MaterialTimeState.Minutes
            minute.forceActiveFocus(Qt.TabFocusReason)
            minute.selectAll()
        }
    }
    SK.Label {
        SK.StyleVariation.variations: ["timePickerLabel"]
        x: hour.x + hour.width; y: 0
        width: root.tokens.timeSeparatorWidth; height: root.tokens.timeFieldHeight
        lineHeight: root.tokens.displayLargeLineHeight
        lineHeightMode: Text.FixedHeight
        text: ":"; font: root.tokens.displayLarge; color: root.tokens.surfaceForeground
        horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
        Accessible.ignored: true
    }
    Material3TimeField {
        id: minute
        x: hour.x + hour.width + root.tokens.timeSeparatorWidth
        width: root.tokens.timeFieldWidth; height: root.tokens.timeFieldHeight
        tokens: root.tokens; time: root.time; hourField: false; editable: root.editable
        onBackRequested: {
            root.time.selection = MaterialTimeState.Hours
            hour.forceActiveFocus(Qt.TabFocusReason)
            hour.selectAll()
        }
    }
    SK.Label {
        SK.StyleVariation.variations: ["timePickerLabel"]
        x: hour.x; y: hour.height + root.tokens.spacingUnit; width: hour.width
        visible: root.editable
        lineHeight: root.tokens.bodySmallLineHeight
        lineHeightMode: Text.FixedHeight
        text: qsTr("Hour"); font: root.tokens.bodySmall; color: root.tokens.surfaceVariantForeground
        horizontalAlignment: Text.AlignHCenter; Accessible.ignored: true
    }
    SK.Label {
        SK.StyleVariation.variations: ["timePickerLabel"]
        x: minute.x; y: minute.height + root.tokens.spacingUnit; width: minute.width
        visible: root.editable
        lineHeight: root.tokens.bodySmallLineHeight
        lineHeightMode: Text.FixedHeight
        text: qsTr("Minute"); font: root.tokens.bodySmall; color: root.tokens.surfaceVariantForeground
        horizontalAlignment: Text.AlignHCenter; Accessible.ignored: true
    }
    Item {
        id: periods
        visible: !root.time.is24Hour
        width: root.stackPeriod ? 2 * root.periodWidth : root.periodWidth
        height: root.stackPeriod ? root.tokens.timeFieldHeight / 2 : root.tokens.timeFieldHeight
        x: root.stackPeriod ? (root.width - width) / 2 : root.mirrored
            ? root.fieldsX - root.tokens.timePeriodGap - width : minute.x + minute.width + root.tokens.timePeriodGap
        y: root.stackPeriod ? root.tokens.timeFieldHeight + root.supportHeight + root.tokens.timePeriodGap : 0
        LayoutMirroring.enabled: root.mirrored
        LayoutMirroring.childrenInherit: true
        Material3TimePeriodButton {
            id: am
            x: root.stackPeriod && root.mirrored ? width : 0
            time: root.time; period: 0; horizontal: root.stackPeriod
            width: root.periodWidth; height: root.tokens.timeFieldHeight / 2
        }
        Material3TimePeriodButton {
            id: pm
            time: root.time; period: 1; horizontal: root.stackPeriod
            x: root.stackPeriod && !root.mirrored ? width : 0
            y: root.stackPeriod ? 0 : height
            width: root.periodWidth; height: root.tokens.timeFieldHeight / 2
        }
    }
}
