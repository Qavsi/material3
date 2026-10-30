pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls as C
import QtQuick.Templates as T
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Style
import Qavsi.Material3.Theme

Column {
    id: root
    required property Material3Theme tokens
    readonly property ComparisonMetrics metrics: ComparisonMetrics { }
    readonly property real preferredWidth: metrics.chipCardWidth
    DemoCard {
        width: parent.width
        title: qsTr("Chips")
        tokens: root.tokens
        contentPadding: root.tokens.inputGalleryPadding
        gapNote: qsTr("Double-click the avatar chip or choose Edit. Enter saves; Escape cancels. Drag the chip below to move it.")
        Flow {
            width: parent.width
            spacing: root.metrics.chipGallerySpacing
            SK.Button {
                objectName: "comparison.chip.assist"
                text: qsTr("Assist")
                icon.name: "material:event"
                SK.StyleVariation.variations: ["chipAssist"]
                contentItem: Material3ChipContent { control: parent as T.Button }
            }
            SK.Button {
                id: filterChip
                objectName: "comparison.chip.filter"
                text: qsTr("Filter")
                checkable: true
                SK.StyleVariation.variations: ["chipFilter"]
                contentItem: Material3ChipContent { control: parent as T.Button }
            }
            SK.Button {
                id: inputChip
                objectName: "comparison.chip.input"
                text: qsTr("Input")
                checkable: true
                SK.StyleVariation.variations: ["chipInput"]
                contentItem: Material3ChipContent {
                    control: parent as T.Button
                    trailingAction: C.Action {
                        objectName: "comparison.chip.input.action"
                        text: qsTr("Remove Input")
                        icon.name: "material:close"
                        onTriggered: inputChip.checked = false
                    }
                }
            }
            SK.Button {
                objectName: "comparison.chip.suggestion"
                text: qsTr("Suggestion")
                SK.StyleVariation.variations: ["chipSuggestion"]
                contentItem: Material3ChipContent { control: parent as T.Button }
            }
            SK.Button {
                text: qsTr("Embed")
                icon.name: "material:description"
                SK.StyleVariation.variations: ["chipEmbed"]
                contentItem: Material3ChipContent { control: parent as T.Button; trailingIconName: "material:close" }
            }
        }
        Flow {
            width: parent.width
            spacing: root.metrics.chipGallerySpacing
            SK.Button {
                text: qsTr("Assist"); enabled: false; icon.name: "material:event"
                SK.StyleVariation.variations: ["chipAssist"]
                contentItem: Material3ChipContent { control: parent as T.Button }
            }
            SK.Button {
                objectName: "comparison.chip.disabled"
                text: qsTr("Filter"); enabled: false; checkable: true
                checked: filterChip.checked
                SK.StyleVariation.variations: ["chipFilter"]
                contentItem: Material3ChipContent { control: parent as T.Button }
            }
            SK.Button {
                objectName: "comparison.chip.input.disabled"
                text: qsTr("Input"); enabled: false; checkable: true
                checked: inputChip.checked
                SK.StyleVariation.variations: ["chipInput"]
                contentItem: Material3ChipContent { control: parent as T.Button }
            }
            SK.Button {
                text: qsTr("Suggestion"); enabled: false
                SK.StyleVariation.variations: ["chipSuggestion"]
                contentItem: Material3ChipContent { control: parent as T.Button }
            }
            SK.Button {
                text: qsTr("Embed"); enabled: false; icon.name: "material:description"
                SK.StyleVariation.variations: ["chipEmbed"]
                contentItem: Material3ChipContent { control: parent as T.Button; trailingIconName: "material:close" }
            }
        }
        Flow {
            width: parent.width
            spacing: root.metrics.chipGallerySpacing
            SK.Button {
                text: qsTr("Elevated Assist")
                icon.name: "material:event"
                SK.StyleVariation.variations: ["chipAssist"]
                contentItem: Material3ChipContent { control: parent as T.Button; elevated: true }
            }
            SK.Button {
                text: qsTr("Elevated Filter")
                checkable: true
                checked: true
                SK.StyleVariation.variations: ["chipFilter"]
                contentItem: Material3ChipContent { control: parent as T.Button; elevated: true }
            }
            SK.Button {
                text: qsTr("Elevated Suggestion")
                SK.StyleVariation.variations: ["chipSuggestion"]
                contentItem: Material3ChipContent { control: parent as T.Button; elevated: true }
            }
            SK.Button {
                text: qsTr("Elevated Input")
                checkable: true
                SK.StyleVariation.variations: ["chipInput"]
                contentItem: Material3ChipContent { control: parent as T.Button; elevated: true }
            }
            SK.Button {
                text: qsTr("Elevated Embed")
                icon.name: "material:description"
                SK.StyleVariation.variations: ["chipEmbed"]
                contentItem: Material3ChipContent { control: parent as T.Button; elevated: true }
            }
            SK.Button {
                text: qsTr("Disabled elevated")
                enabled: false
                SK.StyleVariation.variations: ["chipSuggestion"]
                contentItem: Material3ChipContent { control: parent as T.Button; elevated: true }
            }
        }
        Flow {
            width: parent.width
            spacing: root.metrics.chipGallerySpacing
            SK.Button {
                id: editableChip
                objectName: "comparison.chip.avatar"
                property string label: qsTr("Enes Alp")
                property bool editing: false
                text: label
                checkable: true
                checked: true
                onDoubleClicked: editing = true
                SK.StyleVariation.variations: ["chipInput"]
                contentItem: Material3ChipContent {
                    control: editableChip
                    edit: editableChip.editing
                    leadingItem: Rectangle {
                        implicitWidth: root.tokens.chipAvatarSize
                        implicitHeight: implicitWidth
                        radius: implicitWidth / 2
                        color: root.tokens.primaryContainer
                        Text {
                            anchors.centerIn: parent
                            text: qsTr("EA")
                            font: root.tokens.labelSmall
                            color: root.tokens.primaryContainerForeground
                            Accessible.ignored: true
                        }
                        Accessible.ignored: true
                    }
                    trailingAction: C.Action {
                        text: qsTr("Clear avatar selection")
                        icon.name: "material:close"
                        onTriggered: editableChip.checked = false
                    }
                    editDelegate: SK.TextField {
                        objectName: "comparison.chip.editor"
                        implicitWidth: root.metrics.chipLongWidth
                        text: editableChip.text
                        font: editableChip.font
                        Accessible.name: qsTr("Chip label")
                        SK.StyleVariation.variations: ["textFieldOutlinedExtraSmall"]
                        onAccepted: {
                            editableChip.label = text
                            editableChip.editing = false
                            editableChip.forceActiveFocus(Qt.OtherFocusReason)
                        }
                        Keys.onEscapePressed: event => {
                            editableChip.editing = false
                            editableChip.forceActiveFocus(Qt.OtherFocusReason)
                            event.accepted = true
                        }
                    }
                }
            }
            SK.Button {
                objectName: "comparison.chip.edit"
                text: qsTr("Edit")
                icon.name: "material:edit"
                enabled: editableChip.enabled && !editableChip.editing
                onClicked: editableChip.editing = true
                SK.StyleVariation.variations: ["chipAssist"]
                contentItem: Material3ChipContent { control: parent as T.Button }
            }
        }
        Item {
            width: parent.width
            implicitHeight: root.tokens.chipHeight + root.tokens.spacingMedium * 2
            SK.Button {
                id: draggableChip
                objectName: "comparison.chip.drag"
                x: root.tokens.spacingMedium
                y: root.tokens.spacingMedium
                text: qsTr("Drag Filter")
                checkable: true
                SK.StyleVariation.variations: ["chipFilter"]
                contentItem: Material3ChipContent { control: parent as T.Button; elevated: true }
                Drag.active: chipDrag.active
                Drag.hotSpot.x: width / 2
                Drag.hotSpot.y: height / 2
                DragHandler {
                    id: chipDrag
                    target: draggableChip
                    acceptedButtons: Qt.LeftButton
                    xAxis.minimum: 0
                    xAxis.maximum: Math.max(0, draggableChip.parent.width - draggableChip.width)
                    yAxis.enabled: false
                    cursorShape: active ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                }
            }
        }
        SK.Button {
            objectName: "comparison.chip.long"
            anchors.horizontalCenter: parent.horizontalCenter
            width: root.metrics.chipLongWidth
            text: qsTr("A long chip label constrained by its parent")
            icon.name: "material:event"
            SK.StyleVariation.variations: ["chipAssist"]
            contentItem: Material3ChipContent { control: parent as T.Button }
        }
    }
}
