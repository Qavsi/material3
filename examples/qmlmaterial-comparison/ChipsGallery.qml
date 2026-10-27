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
