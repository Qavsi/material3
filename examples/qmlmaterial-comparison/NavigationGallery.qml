pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Style
import Qavsi.Material3.Theme

Column {
    id: root
    required property Material3Theme tokens
    spacing: tokens.spacingLarge
    Text {
        width: parent.width
        text: qsTr("Navigation")
        font: root.tokens.titleLarge
        color: root.tokens.surfaceForeground
        horizontalAlignment: Text.AlignHCenter
        textFormat: Text.PlainText
    }
    DemoCard {
        width: parent.width
        tokens: root.tokens
        title: qsTr("Navigation Bar")
        contentPadding: root.tokens.inputGalleryPadding
        minimumContentWidth: root.tokens.navigationBarIndicatorWidth * 3
        SK.TabBar {
            id: navigationBar
            objectName: "comparison.navigation.bar"
            width: parent.width
            SK.StyleVariation.variations: ["navigationBar"]
            SK.TabButton {
                id: explore
                objectName: "comparison.navigation.explore"
                text: qsTr("explore")
                icon.name: "material:explore"
                font: root.tokens.labelMedium
                display: SK.TabButton.TextUnderIcon
                SK.StyleVariation.variations: ["navigationBarItem"]
                contentItem: Material3NavigationContent { control: explore }
            }
            SK.TabButton {
                id: pets
                objectName: "comparison.navigation.pets"
                text: qsTr("pets")
                icon.name: "material:pets"
                font: root.tokens.labelMedium
                display: SK.TabButton.TextUnderIcon
                SK.StyleVariation.variations: ["navigationBarItem"]
                contentItem: Material3NavigationContent { control: pets }
            }
            SK.TabButton {
                id: account
                objectName: "comparison.navigation.account"
                text: qsTr("account")
                icon.name: "material:person"
                font: root.tokens.labelMedium
                display: SK.TabButton.TextUnderIcon
                SK.StyleVariation.variations: ["navigationBarItem"]
                contentItem: Material3NavigationContent { control: account }
            }
        }
    }
    DemoCard {
        width: parent.width
        tokens: root.tokens
        title: qsTr("Icon-only Navigation Rail Items")
        contentPadding: root.tokens.inputGalleryPadding
        minimumContentWidth: railExamples.implicitWidth
        RowLayout {
            id: railExamples
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: root.tokens.spacingLarge
            Column {
                Layout.alignment: Qt.AlignTop
                spacing: root.tokens.spacingSmall
                Text {
                    width: collapsedRail.width
                    text: qsTr("Collapsed")
                    font: root.tokens.labelLarge
                    color: root.tokens.surfaceForeground
                    horizontalAlignment: Text.AlignHCenter
                }
                SK.Button {
                    id: collapsedRail
                    objectName: "comparison.rail.collapsed"
                    text: qsTr("Settings")
                    icon.name: "material:settings"
                    display: SK.Button.IconOnly
                    checkable: true
                    checked: true
                    SK.StyleVariation.variations: ["navigationRailCollapsed"]
                    contentItem: Material3NavigationContent { control: collapsedRail }
                    SK.ToolTip.text: qsTr("Configure application")
                    SK.ToolTip.visible: hovered && !pressed
                }
            }
            Column {
                Layout.alignment: Qt.AlignTop
                spacing: root.tokens.spacingSmall
                Text {
                    width: expandedRail.width
                    text: qsTr("Expanded")
                    font: root.tokens.labelLarge
                    color: root.tokens.surfaceForeground
                    horizontalAlignment: Text.AlignHCenter
                }
                SK.Button {
                    id: expandedRail
                    objectName: "comparison.rail.expanded"
                    text: qsTr("Search")
                    icon.name: "material:search"
                    display: SK.Button.IconOnly
                    checkable: true
                    checked: true
                    SK.StyleVariation.variations: ["navigationRailExpanded"]
                    contentItem: Material3NavigationContent { control: expandedRail }
                    SK.ToolTip.text: qsTr("Search library")
                    SK.ToolTip.visible: hovered && !pressed
                }
            }
        }
    }
    DemoCard {
        width: parent.width
        tokens: root.tokens
        title: qsTr("Tabs")
        contentPadding: root.tokens.inputGalleryPadding
        minimumContentWidth: root.tokens.tabMinimumWidth * 3
        SK.TabBar {
            objectName: "comparison.tabs.bar"
            width: parent.width
            SK.StyleVariation.variations: ["tabPrimary"]
            SK.TabButton { objectName: "comparison.tabs.video"; text: qsTr("Video") }
            SK.TabButton { objectName: "comparison.tabs.photos"; text: qsTr("Photos") }
            SK.TabButton { objectName: "comparison.tabs.audio"; text: qsTr("Audio") }
        }
    }
}
