pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme
import Qavsi.Material3.Style

Column {
    id: root
    required property Material3Theme tokens
    readonly property real preferredWidth: tokens.referenceCardWidth
    spacing: tokens.spacingLarge
    DemoCard {
        width: parent.width
        tokens: root.tokens
        title: qsTr("List items")
        SK.ItemDelegate {
            id: oneLine
            width: parent.width
            text: qsTr("One-line item")
            icon.name: "material:star"
            SK.StyleVariation.variations: ["listOneLine"]
            contentItem: Material3ListItemContent { control: oneLine; trailingIconName: "material:chevron_right" }
        }
        SK.ItemDelegate {
            id: selectable
            objectName: "comparison.list.selectable"
            width: parent.width
            text: qsTr("Selectable item")
            checkable: true
            checked: true
            icon.name: "material:folder"
            SK.StyleVariation.variations: ["listTwoLine"]
            Accessible.description: qsTr("Supporting text")
            contentItem: Material3ListItemContent {
                control: selectable
                supportingText: selectable.Accessible.description
                trailingText: qsTr("100+")
            }
        }
        SK.ItemDelegate {
            id: threeLine
            width: parent.width
            text: qsTr("Three-line item")
            icon.name: "material:notifications"
            SK.StyleVariation.variations: ["listThreeLine"]
            Accessible.description: qsTr("A longer supporting message wraps naturally within the available row width.")
            contentItem: Material3ListItemContent {
                control: threeLine
                overline: qsTr("Overline")
                supportingText: threeLine.Accessible.description
                supportingMaximumLineCount: 2
            }
        }
        SK.ItemDelegate {
            id: disabled
            objectName: "comparison.list.disabled"
            width: parent.width
            text: qsTr("Disabled selected item")
            checkable: true
            checked: true
            enabled: false
            SK.StyleVariation.variations: ["listOneLine"]
            contentItem: Material3ListItemContent { control: disabled }
        }
    }
    DemoCard {
        width: parent.width
        tokens: root.tokens
        title: qsTr("Cards")
        SK.Pane {
            objectName: "comparison.card.passive"
            width: parent.width
            SK.StyleVariation.variations: ["cardFilled"]
            contentItem: Text { text: qsTr("Filled card"); font: root.tokens.bodyLarge; color: root.tokens.surfaceForeground }
        }
        SK.Button {
            objectName: "comparison.card.interactive"
            width: parent.width
            text: qsTr("Elevated interactive card")
            SK.StyleVariation.variations: ["cardElevated"]
        }
        SK.Pane {
            width: parent.width
            SK.StyleVariation.variations: ["cardOutlined"]
            contentItem: Text { text: qsTr("Outlined card"); font: root.tokens.bodyLarge; color: root.tokens.surfaceForeground }
        }
        SK.Button {
            width: parent.width
            text: qsTr("Disabled card")
            enabled: false
            SK.StyleVariation.variations: ["cardOutlined"]
        }
    }
}
