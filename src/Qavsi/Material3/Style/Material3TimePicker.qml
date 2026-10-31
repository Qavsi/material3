// Adapted from QmlMaterial 229bc3e6 TimePicker.qml (MIT).
pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

SK.Pane {
    id: root
    enum DisplayMode { Clock, Input }
    enum Selection { Hours, Minutes }
    property int selectedHour: 0
    property int selectedMinute: 0
    property bool use24Hour: locale.timeFormat(Locale.ShortFormat).toLowerCase().indexOf("ap") < 0
    property alias displayMode: timeState.displayMode
    property alias selection: timeState.selection
    property bool showModeToggle: true
    property string supportingText: qsTr("Select time")
    readonly property bool selectedTimeValid: selectedHour >= 0 && selectedHour < 24 && selectedMinute >= 0 && selectedMinute < 60
    readonly property bool selectionValid: selectedTimeValid && timeState.acceptableInput
    readonly property alias hourField: input.hourField
    readonly property alias minuteField: input.minuteField
    readonly property Material3Style sourceStyle: SK.StyleKit.style as Material3Style
    readonly property Material3Theme tokens: sourceStyle?.tokens ?? fallbackTokens
    readonly property Material3Theme fallbackTokens: Material3Theme {}
    readonly property bool canAnimate: visible && Window.window?.visible === true
        && !((sourceStyle?.effectiveReducedMotion) ?? true) && SK.StyleKit.transitionsEnabled
    signal selectedTimeChangeRequested(int hour, int minute)
    SK.StyleVariation.variations: ["timePicker"]
    implicitWidth: Math.max(input.implicitWidth, tokens.timeDialSize) + leftPadding + rightPadding
    implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding

    function selectTime(hour: int, minute: int): void {
        if (hour >= 0 && hour < 24 && minute >= 0 && minute < 60)
            selectedTimeChangeRequested(hour, minute)
    }
    function commitInput(): bool { return selectedTimeValid && timeState.commitInput() }
    function discardInput(): void { timeState.discardInput() }
    function focusSelection(): void {
        if (displayMode === Material3TimePicker.Input) input.focusSelection()
        else dial.forceActiveFocus(Qt.TabFocusReason)
    }
    readonly property int effectiveDisplayMode: displayMode
    onEffectiveDisplayModeChanged: Qt.callLater(() => {
        if (root.visible && root.enabled && root.Window.window?.visible) root.focusSelection()
    })
    onCanAnimateChanged: if (!canAnimate) handMotion.complete()
    MaterialTimeState {
        id: timeState
        value: root.selectedTimeValid ? root.selectedHour * 60 + root.selectedMinute : 0
        locale: root.locale
        hourFormat: root.use24Hour ? MaterialTimeState.Hour24 : MaterialTimeState.Hour12
        onModified: value => {
            const callerValue = root.selectedTimeValid ? root.selectedHour * 60 + root.selectedMinute : 0
            if (acceptableInput || value !== callerValue) root.selectedTimeChangeRequested(Math.floor(value / 60), value % 60)
            // Keep the caller's binding authoritative; same-value acknowledgement preserves raw input.
            setValue(root.selectedTimeValid ? root.selectedHour * 60 + root.selectedMinute : 0)
        }
    }
    contentItem: Item {
        implicitHeight: toggle.y + (toggle.visible ? toggle.height : 0)
        SK.Label {
            SK.StyleVariation.variations: ["timePickerLabel"]
            id: heading
            width: parent.width
            text: root.supportingText
            lineHeight: root.tokens.labelMediumLineHeight
            lineHeightMode: Text.FixedHeight
            font: root.tokens.labelMedium; color: root.tokens.surfaceVariantForeground
        }
        Material3TimeInput {
            id: input
            y: heading.height + root.tokens.timeHeadingGap
            width: parent.width; height: implicitHeight
            time: timeState; tokens: root.tokens; mirrored: root.mirrored
        }
        MaterialTimeDial {
            id: dial
            readonly property var labelData: visible ? labels : []
            objectName: "material3.time.dial"
            visible: root.displayMode === Material3TimePicker.Clock
            time: timeState
            dialPadding: root.tokens.timeDialPadding
            innerRadiusRatio: root.tokens.timeDialInnerRadiusRatio
            selectorSize: root.tokens.timeSelectorSize
            centerSize: root.tokens.timeCenterSize
            width: Math.min(parent.width, root.tokens.timeDialSize); height: width
            x: (parent.width - width) / 2
            y: input.y + input.height + root.tokens.timeDialGap
            opacity: enabled ? 1 : root.tokens.disabledLabelOpacity
            Accessible.role: Accessible.Pane
            Accessible.name: timeState.selection === MaterialTimeState.Hours ? qsTr("Select hour") : qsTr("Select minute")
            Accessible.description: timeState.displayText
            Accessible.onIncreaseAction: if (dial.enabled && dial.visible) timeState.step(1)
            Accessible.onDecreaseAction: if (dial.enabled && dial.visible) timeState.step(-1)
            onPressedChanged: if (pressed) handMotion.complete()
            Rectangle {
                anchors.fill: parent
                radius: width / 2; color: root.tokens.surfaceContainerHighest
            }
            Item {
                x: dial.width / 2; y: dial.height / 2
                rotation: dial.handAngle
                Behavior on rotation {
                    enabled: root.canAnimate && dial.visible && !dial.pressed
                    RotationAnimation {
                        id: handMotion
                        direction: RotationAnimation.Shortest
                        duration: root.tokens.timeHandDuration
                        easing.type: root.tokens.timeHandEasing
                    }
                }
                Rectangle {
                    x: -width / 2; y: -height
                    width: root.tokens.timeHandWidth; height: dial.handLength
                    color: root.tokens.primary
                }
                Rectangle {
                    x: -width / 2; y: -dial.handLength - height / 2
                    width: root.tokens.timeSelectorSize; height: width
                    radius: width / 2; color: root.tokens.primary
                }
            }
            Rectangle {
                anchors.centerIn: parent
                width: root.tokens.timeCenterSize; height: width
                radius: width / 2; color: root.tokens.primary
            }
            // Numeric model identity preserves native label readers while time changes.
            Repeater {
                model: dial.labelData.length
                delegate: SK.Label {
                    required property int index
                    readonly property var labelInfo: dial.labelData[index]
                    SK.StyleVariation.variations: ["timePickerLabel"]
                    x: (labelInfo?.x ?? 0) - width / 2; y: (labelInfo?.y ?? 0) - height / 2
                    width: root.tokens.timeSelectorSize; height: root.tokens.timeSelectorSize
                    lineHeight: root.tokens.bodyLargeLineHeight
                    lineHeightMode: Text.FixedHeight
                    text: labelInfo?.text ?? ""; font: root.tokens.bodyLarge
                    color: labelInfo?.selected ? root.tokens.primaryForeground : root.tokens.surfaceForeground
                    horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter
                    Accessible.ignored: true
                }
            }
            Rectangle {
                anchors.fill: parent; anchors.margins: -root.tokens.focusRingGap
                radius: width / 2; color: root.tokens.transparent
                border.width: dial.activeFocus ? root.tokens.focusRingWidth : 0
                border.color: root.tokens.primary
                Accessible.ignored: true
            }
        }
        SK.Button {
            id: toggle
            objectName: "material3.time.modeToggle"
            y: dial.visible ? dial.y + dial.height + root.tokens.timePeriodGap
                : input.y + input.height + root.tokens.timePeriodGap
            visible: root.showModeToggle; enabled: root.selectionValid
            SK.StyleVariation.variations: ["iconStandard"]
            contentItem: Material3ButtonContent { control: toggle }
            icon.name: root.displayMode === Material3TimePicker.Clock ? "material:keyboard" : "material:schedule"
            Accessible.name: root.displayMode === Material3TimePicker.Clock ? qsTr("Enter time") : qsTr("Select time")
            onClicked: root.displayMode = root.displayMode === Material3TimePicker.Clock ? Material3TimePicker.Input : Material3TimePicker.Clock
            SK.ToolTip.text: Accessible.name
            SK.ToolTip.visible: hovered
        }
    }
}
