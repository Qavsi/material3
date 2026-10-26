pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as C
import Qt.labs.StyleKit as SK
import QtQuick.Templates as T
import Qavsi.Material3.Style
import Qavsi.Material3.Theme

Column {
    id: root
    required property Material3Theme tokens
    readonly property ComparisonMetrics metrics: ComparisonMetrics { }
    objectName: "comparison.actions"
    spacing: root.tokens.spacingLarge
    // shortcut: Qt 6.12 caches early variation lookups; remove the guard when initialization is fixed.
    property bool styleScopeReady: false
    Component.onCompleted: root.styleScopeReady = true
    readonly property SK.StyleReader buttonGroupStyle: SK.StyleReader {
        controlType: Number(SK.StyleReader.ToolBar)
        SK.StyleVariation.variations: ["buttonGroup"]
    }
    readonly property SK.StyleReader standardGroupStyle: SK.StyleReader {
        controlType: Number(SK.StyleReader.ToolBar)
        SK.StyleVariation.variations: ["standardButtonGroup", "buttonGroup"]
    }
    readonly property SK.StyleReader segmentedGroupStyle: SK.StyleReader {
        controlType: Number(SK.StyleReader.ToolBar)
        SK.StyleVariation.variations: ["segmentedGroup", "buttonGroup"]
    }

    Text {
        width: parent.width
        font: root.tokens.headlineSmall; color: root.tokens.surfaceForeground
        text: qsTr("Actions")
        horizontalAlignment: Text.AlignHCenter
    }
    DemoCard {
        width: parent.width
        tokens: root.tokens
        title: qsTr("Common buttons")
        gapNote: qsTr("Reference examples use XS, S and M. Additional supported sizes are verified outside the gallery.")
        minimumContentWidth: {
            let minimum = root.styleScopeReady ? buttonSizes.implicitWidth : 0
            if (root.styleScopeReady) {
                for (let index = 0; index < commonRows.count; ++index)
                    minimum = Math.max(minimum, commonRows.itemAt(index)?.implicitWidth ?? 0)
            }
            return minimum
        }
        Repeater {
            id: commonRows
            model: [
                { key: "elevated", label: qsTr("Elevated"), variations: ["elevated"] },
                { key: "filled", label: qsTr("Filled"), variations: [] },
                { key: "filledTonal", label: qsTr("FilledTonal"), variations: ["filledTonal"] },
                { key: "outlined", label: qsTr("Outlined"), variations: ["outline"] },
                { key: "text", label: qsTr("Text"), variations: ["ghost"] }
            ]
            delegate: RowLayout {
                id: commonRow
                required property var modelData
                width: Math.min(implicitWidth, parent.width)
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: root.tokens.spacingSmall
                SK.Button { contentItem: Material3ButtonContent { control: parent as T.Button } objectName: "comparison.button." + commonRow.modelData.key; text: commonRow.modelData.label; SK.StyleVariation.variations: commonRow.modelData.variations }
                SK.Button { contentItem: Material3ButtonContent { control: parent as T.Button } objectName: "comparison.button." + commonRow.modelData.key + ".icon"; text: qsTr("Icon"); icon.name: "material:add"; SK.StyleVariation.variations: commonRow.modelData.variations }
                SK.Button { contentItem: Material3ButtonContent { control: parent as T.Button } objectName: "comparison.button." + commonRow.modelData.key + ".disabled"; text: commonRow.modelData.label; SK.StyleVariation.variations: commonRow.modelData.variations; enabled: false }
            }
        }
        Text { width: parent.width; font: root.tokens.titleMedium; color: root.tokens.surfaceForeground; text: qsTr("Sizes"); horizontalAlignment: Text.AlignHCenter }
        RowLayout {
            id: buttonSizes
            objectName: "comparison.common.sizes"
            width: Math.min(implicitWidth, parent.width)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: root.metrics.commonSizeSpacing
            SK.Button { contentItem: Material3ButtonContent { control: parent as T.Button } objectName: "comparison.button.size.XS"; text: qsTr("XS"); SK.StyleVariation.variations: ["buttonExtraSmall"] }
            SK.Button { contentItem: Material3ButtonContent { control: parent as T.Button } objectName: "comparison.button.size.S"; text: qsTr("S"); SK.StyleVariation.variations: ["buttonSmall"] }
            SK.Button { contentItem: Material3ButtonContent { control: parent as T.Button } objectName: "comparison.button.size.M"; text: qsTr("M"); SK.StyleVariation.variations: ["buttonMedium"] }
        }
    }
    DemoCard {
        width: parent.width
        tokens: root.tokens
        title: qsTr("Button groups")
        minimumContentWidth: Math.max(standardIcons.implicitWidth, standardMixed.implicitWidth,
            standardChoices.implicitWidth, filesGroup.implicitWidth, starsGroup.implicitWidth,
            multipleGroup.implicitWidth, weightedGroup.implicitWidth)
        gapNote: qsTr("Shared size roles preserve Standard icon width modes and Connected geometry. Standard-group press-driven neighbor width redistribution remains missing.")
        Text { font: root.tokens.titleMedium; color: root.tokens.surfaceForeground; text: qsTr("Standard") }
        RowLayout {
            id: standardIcons
            objectName: "comparison.standard.icons"
            width: Math.min(implicitWidth, parent.width)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: root.styleScopeReady ? root.standardGroupStyle.spacing : 0
            Repeater {
                model: [{ icon: "bluetooth", label: qsTr("Bluetooth") }, { icon: "alarm", label: qsTr("Alarm") }, { icon: "link", label: qsTr("Link") }, { icon: "wifi", label: qsTr("Wi-Fi") }]
                delegate: SK.Button { contentItem: Material3ButtonContent { control: parent as T.Button }
                    required property var modelData
                    required property int index
                    objectName: "comparison.standard.icon." + index
                    SK.StyleVariation.variations: [index === 0 ? "iconSmallNarrow" : index === 3 ? "iconSmallWide" : "iconSmall", "iconFilled"]
                    icon.name: "material:" + modelData.icon
                    display: SK.Button.IconOnly
                    Accessible.name: modelData.label
                }
            }
        }
        RowLayout {
            id: standardMixed
            objectName: "comparison.standard.mixed"
            width: Math.min(implicitWidth, parent.width)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: root.styleScopeReady ? root.standardGroupStyle.spacing : 0
            SK.Button { contentItem: Material3ButtonContent { control: parent as T.Button } objectName: "comparison.standard.mixed.0"; text: qsTr("Label"); SK.StyleVariation.variations: ["buttonSmall", "filledTonal"] }
            SK.Button { contentItem: Material3ButtonContent { control: parent as T.Button } objectName: "comparison.standard.mixed.1"; text: qsTr("Edit"); icon.name: "material:edit"; SK.StyleVariation.variations: ["buttonSmallRectangular", "buttonSmall"] }
            SK.Button { contentItem: Material3ButtonContent { control: parent as T.Button } objectName: "comparison.standard.mixed.2"; icon.name: "material:delete"; display: SK.Button.IconOnly; SK.StyleVariation.variations: ["iconSmall", "iconTonal", "filledTonal"]; Accessible.name: qsTr("Delete") }
        }
        RowLayout {
            id: standardChoices
            objectName: "comparison.standard.choices"
            width: Math.min(implicitWidth, parent.width)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: root.styleScopeReady ? root.standardGroupStyle.spacing : 0
            SK.Button { contentItem: Material3ButtonContent { control: parent as T.Button } objectName: "comparison.standard.choice.0"; icon.name: "material:star"; display: SK.Button.IconOnly; SK.StyleVariation.variations: ["iconSmall", "iconFilled"]; checkable: true; Accessible.name: qsTr("Star") }
            SK.Button { contentItem: Material3ButtonContent { control: parent as T.Button } objectName: "comparison.standard.choice.1"; text: qsTr("Label"); icon.name: "material:star"; SK.StyleVariation.variations: ["buttonSmall"]; checkable: true; checked: true }
            SK.Button { contentItem: Material3ButtonContent { control: parent as T.Button } objectName: "comparison.standard.choice.2"; icon.name: "material:star"; display: SK.Button.IconOnly; SK.StyleVariation.variations: ["iconSmall", "iconFilled"]; checkable: true; Accessible.name: qsTr("Star") }
        }
        Text { font: root.tokens.titleMedium; color: root.tokens.surfaceForeground; text: qsTr("Connected") }
        C.ButtonGroup { id: fileSelection }
        RowLayout {
            id: filesGroup
            width: parent.width
            spacing: root.styleScopeReady ? root.buttonGroupStyle.spacing : 0
            Repeater {
                id: fileChoices
                model: [qsTr("My files"), qsTr("Shared"), qsTr("Computers")]
                delegate: SK.Button { contentItem: Material3ButtonContent { control: parent as T.Button }
                    required property string modelData
                    required property int index
                    objectName: "comparison.connected.files." + index
                    Layout.preferredWidth: 0
                    Layout.minimumWidth: implicitWidth
                    SK.StyleVariation.variations: [index === 0 ? "connectedLeading" : index === 2 ? "connectedTrailing" : "connectedMiddle", "filledTonal"]
                    Layout.fillWidth: true
                    text: modelData
                    checkable: true
                    checked: index === 0
                    C.ButtonGroup.group: fileSelection
                }
            }
        }
        C.ButtonGroup { id: starSelection }
        Row {
            id: starsGroup
            width: Math.min(implicitWidth, parent.width)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: root.styleScopeReady ? root.buttonGroupStyle.spacing : 0
            Repeater {
                id: starChoices
                model: 5
                delegate: SK.Button { contentItem: Material3ButtonContent { control: parent as T.Button }
                    required property int index
                    objectName: "comparison.connected.star." + index
                    SK.StyleVariation.variations: [index === 0 ? "connectedIconLeading" : index === 4 ? "connectedIconTrailing" : "connectedIconMiddle",
                        index === 0 ? "connectedLeading" : index === 4 ? "connectedTrailing" : "connectedMiddle"]
                    icon.name: "material:star"
                    display: SK.Button.IconOnly
                    checkable: true
                    checked: index === 1
                    C.ButtonGroup.group: starSelection
                    Accessible.name: qsTr("Star %1").arg(index + 1)
                }
            }
        }
        Row {
            id: multipleGroup
            width: Math.min(implicitWidth, parent.width)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: root.styleScopeReady ? root.buttonGroupStyle.spacing : 0
            Repeater {
                id: multipleChoices
                model: [qsTr("One"), qsTr("Two"), qsTr("Three")]
                delegate: SK.Button { contentItem: Material3ButtonContent { control: parent as T.Button }
                    required property string modelData
                    required property int index
                    objectName: "comparison.connected.multi." + index
                    SK.StyleVariation.variations: [index === 0 ? "connectedLeading" : index === 2 ? "connectedTrailing" : "connectedMiddle", "filledTonal"]
                    text: modelData
                    icon.name: index < 2 ? "material:star" : ""
                    checkable: true
                    checked: index === 1
                }
            }
        }
        RowLayout {
            id: weightedGroup
            width: parent.width
            spacing: root.styleScopeReady ? root.buttonGroupStyle.spacing : 0
            SK.Button { contentItem: Material3ButtonContent { control: parent as T.Button } id: weightedLeading; SK.StyleVariation.variations: ["connectedIconLeading", "connectedLeading"]; Layout.fillWidth: true; Layout.preferredWidth: 0; Layout.minimumWidth: implicitHeight; icon.name: "material:star"; display: SK.Button.IconOnly; checkable: true; Accessible.name: qsTr("Star") }
            SK.Button { contentItem: Material3ButtonContent { control: parent as T.Button } SK.StyleVariation.variations: ["connectedMiddle"]; Layout.fillWidth: true; Layout.preferredWidth: 0; Layout.minimumWidth: implicitWidth; text: qsTr("Label"); icon.name: "material:star"; checkable: true; checked: true }
            SK.Button { contentItem: Material3ButtonContent { control: parent as T.Button } SK.StyleVariation.variations: ["connectedIconTrailing", "connectedTrailing"]; Layout.fillWidth: true; Layout.preferredWidth: 0; Layout.minimumWidth: implicitHeight; icon.name: "material:star"; display: SK.Button.IconOnly; checkable: true; Accessible.name: qsTr("Star") }
        }
    }
    DemoCard {
        width: parent.width
        tokens: root.tokens
        title: qsTr("Segmented buttons")
        minimumContentWidth: Math.max(periodRow.implicitWidth, optionsRow.implicitWidth)
        gapNote: qsTr("Shared style roles own connected outlines and selection marks. Optical sizes follow shared roles; typography and desktop targets follow the independent kit.")
        C.ButtonGroup { id: periodSelection }
        RowLayout {
            id: periodRow
            objectName: "comparison.segmented.period"
            width: Math.min(implicitWidth, parent.width)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: root.styleScopeReady ? root.segmentedGroupStyle.spacing : 0
            Repeater {
                model: [qsTr("Day"), qsTr("Week"), qsTr("Month"), qsTr("Year")]
                delegate: SK.Button { contentItem: Material3ButtonContent { control: parent as T.Button }
                    required property string modelData
                    required property int index
                    Layout.fillWidth: true
                    objectName: "comparison.segmented.period." + index
                    text: modelData
                    SK.StyleVariation.variations: [index === 0 ? "segmentedLeading" : index === 3 ? "segmentedTrailing" : "segmentedMiddle", "outline"]
                    z: checked ? 1 : 0
                    checkable: true
                    checked: index === 1
                    C.ButtonGroup.group: periodSelection
                }
            }
        }
        RowLayout {
            id: optionsRow
            objectName: "comparison.segmented.options"
            width: Math.min(implicitWidth, parent.width)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: root.styleScopeReady ? root.segmentedGroupStyle.spacing : 0
            Repeater {
                model: [qsTr("Option 1"), qsTr("Option 2"), qsTr("Option 3")]
                SK.Button { contentItem: Material3ButtonContent { control: parent as T.Button }
                    required property int index
                    required property string modelData
                    objectName: "comparison.segmented.options." + index
                    Layout.fillWidth: true
                    text: modelData
                    icon.name: index === 0 ? "material:check" : ""
                    SK.StyleVariation.variations: [index === 0 ? "segmentedLeading" : index === 2 ? "segmentedTrailing" : "segmentedMiddle", "outline"]
                    z: checked ? 1 : 0
                    checkable: true
                }
            }
        }
        Text { width: parent.width; font: root.tokens.titleMedium; color: root.tokens.surfaceForeground; text: qsTr("Sizes"); horizontalAlignment: Text.AlignHCenter }
        Repeater {
            model: [{ label: qsTr("XS"), role: "segmentedExtraSmall" }, { label: qsTr("S"), role: "segmentedSmall" }, { label: qsTr("M"), role: "segmentedMedium" }]
            delegate: RowLayout {
                id: sizeRow
                required property var modelData
                objectName: "comparison.segmented.size." + sizeRow.modelData.label
                width: Math.min(implicitWidth, parent.width)
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: root.styleScopeReady ? root.segmentedGroupStyle.spacing : 0
                C.ButtonGroup { id: sizeSelection }
                Repeater {
                    model: 3
                    delegate: SK.Button { contentItem: Material3ButtonContent { control: parent as T.Button }
                        required property int index
                        Layout.fillWidth: true
                        text: sizeRow.modelData.label
                        objectName: "comparison.segmented.size." + sizeRow.modelData.label + "." + index
                        SK.StyleVariation.variations: [sizeRow.modelData.role + (index === 0 ? "Leading" : index === 2 ? "Trailing" : "Middle"),
                            index === 0 ? "segmentedLeading" : index === 2 ? "segmentedTrailing" : "segmentedMiddle", "outline"]
                        z: checked ? 1 : 0
                        checkable: true
                        checked: index === 1
                        C.ButtonGroup.group: sizeSelection
                    }
                }
            }
        }
    }
    DemoCard {
        width: parent.width
        objectName: "comparison.splitCard"
        tokens: root.tokens
        title: qsTr("Split buttons")
        gapNote: qsTr("Main action and menu have separate targets. Shared style roles own optical sizes, joined corners and the menu indicator. The kit owns typography and geometry.")
        Flow {
            width: parent.width
            spacing: root.tokens.spacingSmall
            Repeater {
                model: [
                    { key: "filled", text: qsTr("Filled"), variations: [], enabled: true, actions: [qsTr("Action 1"), qsTr("Action 2")] },
                    { key: "tonal", text: qsTr("Tonal"), variations: ["filledTonal"], enabled: true, actions: [qsTr("Action A"), qsTr("Action B")] },
                    { key: "disabled", text: qsTr("Disabled"), variations: [], enabled: false, actions: [qsTr("Action 1"), qsTr("Action 2")] }
                ]
                delegate: RowLayout {
                    id: splitRow
                    required property var modelData
                    objectName: "comparison.split." + modelData.key
                    enabled: splitRow.modelData.enabled
                    spacing: root.styleScopeReady ? root.buttonGroupStyle.spacing : 0
                    SK.Button { contentItem: Material3ButtonContent { control: parent as T.Button }
                        id: mainButton
                        objectName: splitRow.objectName + ".main"
                        text: splitRow.modelData.text
                        SK.StyleVariation.variations: ["splitLeading"].concat(splitRow.modelData.variations)
                    }
                    SK.Button { contentItem: Material3ButtonContent { control: parent as T.Button }
                        objectName: splitRow.objectName + ".menuButton"
                        icon.name: "material:expand_more"
                        display: SK.Button.IconOnly
                        SK.StyleVariation.variations: ["splitTrailing"].concat(splitRow.modelData.variations)
                        highlighted: menu.visible
                        Accessible.name: qsTr("More %1 actions").arg(splitRow.modelData.text)
                        Accessible.role: Accessible.ButtonMenu
                        Accessible.expandable: true
                        Accessible.expanded: menu.visible
                        onClicked: menu.visible ? menu.close() : menu.open()
                        SK.Menu {
                            id: menu
                            // Compare against QmlMaterial's in-scene menu rather than platform tracking.
                            popupType: SK.Popup.Item
                            modal: true
                            dim: false
                            focus: true
                            objectName: splitRow.objectName + ".menu"
                            parent: splitRow
                            closePolicy: SK.Popup.CloseOnEscape | SK.Popup.CloseOnPressOutside
                            x: menu.mirrored ? splitRow.width - menu.width : 0
                            y: splitRow.height + root.tokens.spacingUnit
                            Repeater {
                                model: splitRow.modelData.actions
                                SK.MenuItem {
                                    required property string modelData
                                    text: modelData
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    DemoCard {
        width: parent.width
        objectName: "comparison.fabCard"
        tokens: root.tokens
        title: qsTr("Floating action buttons")
        gapNote: qsTr("FAB sizes, corners and extended-button expansion follow the pinned reference. The two action stacks use native buttons and a scrolling viewport; press the plus button to open or close the menu.")
        Flow {
            width: parent.width
            spacing: root.tokens.spacingLarge
            SK.Button { contentItem: Material3ButtonContent { control: parent as T.Button } objectName: "comparison.fab.small"; SK.StyleVariation.variations: ["fabSmall"]; icon.name: "material:add"; display: SK.Button.IconOnly; Accessible.name: qsTr("Add small") }
            SK.Button { contentItem: Material3ButtonContent { control: parent as T.Button } objectName: "comparison.fab.normal"; SK.StyleVariation.variations: ["fab"]; icon.name: "material:add"; display: SK.Button.IconOnly; Accessible.name: qsTr("Add") }
            SK.Button { contentItem: Material3ButtonContent { control: parent as T.Button } objectName: "comparison.fab.large"; SK.StyleVariation.variations: ["fabLarge"]; icon.name: "material:add"; display: SK.Button.IconOnly; Accessible.name: qsTr("Add large") }
        }
        SK.Button {
            id: createFab
            property bool expanded: true
            objectName: "comparison.fab.extended"
            SK.StyleVariation.variations: ["fabExtended"]
            text: qsTr("Create")
            icon.name: "material:add"
            display: createFab.expanded ? SK.Button.TextBesideIcon : SK.Button.IconOnly
            Accessible.name: createFab.text
            Accessible.expandable: true
            Accessible.expanded: createFab.expanded
            contentItem: Material3ButtonContent { control: createFab }
            onClicked: createFab.expanded = !createFab.expanded
        }
        SK.Button { contentItem: Material3ButtonContent { control: parent as T.Button } objectName: "comparison.fab.text"; SK.StyleVariation.variations: ["fabExtended"]; text: qsTr("Compose") }
        FabMenuExamples {
            width: parent.width
            tokens: root.tokens
            styleScopeReady: root.styleScopeReady
        }
    }
    DemoCard {
        width: parent.width
        tokens: root.tokens
        title: qsTr("Icon buttons")
        objectName: "comparison.icon.card"
        minimumContentWidth: {
            let minimum = root.styleScopeReady ? Math.max(iconSizes.implicitWidth, iconWidths.implicitWidth) : 0
            if (root.styleScopeReady) {
                for (let index = 0; index < iconAppearanceRows.count; ++index)
                    minimum = Math.max(minimum, iconAppearanceRows.itemAt(index)?.implicitWidth ?? 0)
            }
            return minimum
        }
        gapNote: qsTr("Reference examples: four appearances, XS/S/M/L, and three Small width modes. Badges are a separate family and have not been ported yet.")
        Repeater {
            id: iconAppearanceRows
            model: [true, false]
            delegate: RowLayout {
                id: iconRow
                required property bool modelData
                objectName: "comparison.icon.appearances." + (modelData ? "enabled" : "disabled")
                width: Math.min(implicitWidth, parent.width)
                anchors.horizontalCenter: parent.horizontalCenter
                spacing: root.metrics.iconAppearanceSpacing
                Repeater {
                    model: [{ variations: ["iconStandard"] }, { variations: ["iconFilledCheckable"] }, { variations: ["iconTonalCheckable"] }, { variations: ["iconOutlined"] }]
                    delegate: SK.Button { contentItem: Material3ButtonContent { control: parent as T.Button }
                        required property var modelData
                        required property int index
                        objectName: "comparison.iconButton." + index + (iconRow.modelData ? ".enabled" : ".disabled")
                        text: qsTr("Settings")
                        icon.name: "material:settings"
                        display: SK.Button.IconOnly
                        SK.StyleVariation.variations: modelData.variations
                        checkable: true
                        enabled: iconRow.modelData
                        Accessible.name: qsTr("Settings")
                    }
                }
            }
        }
        Text { width: parent.width; horizontalAlignment: Text.AlignHCenter; font: root.tokens.titleMedium; color: root.tokens.surfaceForeground; text: qsTr("Sizes & Width Modes") }
        RowLayout {
            id: iconSizes
            objectName: "comparison.icon.sizes"
            width: Math.min(implicitWidth, parent.width)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: root.tokens.spacingLarge
            Repeater {
                model: [{ label: "XS", role: "iconExtraSmall" }, { label: "S", role: "iconSmall" }, { label: "M", role: "iconMedium" }, { label: "L", role: "iconLarge" }]
                delegate: SK.Button { contentItem: Material3ButtonContent { control: parent as T.Button }
                    required property var modelData
                    objectName: "comparison.iconSize." + modelData.label
                    icon.name: "material:settings"
                    display: SK.Button.IconOnly
                    SK.StyleVariation.variations: [modelData.role, "iconStandard"]
                    Accessible.name: qsTr("Settings")
                    Accessible.description: qsTr("Size %1").arg(modelData.label)
                }
            }
        }
        RowLayout {
            id: iconWidths
            objectName: "comparison.icon.widths"
            width: Math.min(implicitWidth, parent.width)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: root.tokens.spacingLarge
            Repeater {
                model: [{ key: "Narrow", role: "iconSmallNarrow", label: qsTr("Narrow") }, { key: "Default", role: "iconSmall", label: qsTr("Default") }, { key: "Wide", role: "iconSmallWide", label: qsTr("Wide") }]
                delegate: SK.Button { contentItem: Material3ButtonContent { control: parent as T.Button }
                    required property var modelData
                    objectName: "comparison.iconWidth." + modelData.key
                    icon.name: "material:settings"
                    display: SK.Button.IconOnly
                    SK.StyleVariation.variations: [modelData.role, "iconStandard"]
                    Accessible.name: qsTr("Settings")
                    Accessible.description: qsTr("%1 width").arg(modelData.label)
                }
            }
        }
    }
}
