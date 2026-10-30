pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls as C
import QtQuick.Templates as T
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Style

DemoCard {
    id: root
    required property bool styleScopeReady
    readonly property Material3Style materialStyle: SK.StyleKit.style as Material3Style
    readonly property bool reduceMotion: (materialStyle?.effectiveReducedMotion ?? true)
        || !SK.StyleKit.transitionsEnabled
    readonly property SK.StyleReader buttonGroupStyle: SK.StyleReader {
        controlType: Number(SK.StyleReader.ToolBar)
        SK.StyleVariation.variations: ["buttonGroup"]
    }
    readonly property SK.StyleReader standardGroupStyle: SK.StyleReader {
        controlType: Number(SK.StyleReader.ToolBar)
        SK.StyleVariation.variations: ["standardButtonGroup", "buttonGroup"]
    }
    width: parent.width
    title: qsTr("Button groups")
    minimumContentWidth: Math.max(standardIcons.implicitWidth, standardMixed.implicitWidth,
        standardChoices.implicitWidth, filesGroup.implicitWidth, starsGroup.implicitWidth,
        multipleGroup.implicitWidth, weightedGroup.implicitWidth)
    gapNote: qsTr("Press a group action to expand it within the same total width. Exclusive and multiple selection remain independent.")
    Text { font: root.tokens.titleMedium; color: root.tokens.surfaceForeground; text: qsTr("Standard") }
    Material3ButtonGroup {
        tokens: root.tokens
        reduceMotion: root.reduceMotion
        id: standardIcons
        objectName: "comparison.standard.icons"
        width: Math.min(implicitWidth, parent.width)
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: root.styleScopeReady ? root.standardGroupStyle.spacing : 0
        Repeater {
            model: [{ icon: "bluetooth", label: qsTr("Bluetooth") }, { icon: "alarm", label: qsTr("Alarm") }, { icon: "link", label: qsTr("Link") }, { icon: "wifi", label: qsTr("Wi-Fi") }]
            delegate: SK.Button { Material3ButtonGroup.managed: true; width: Material3ButtonGroup.layoutWidth; contentItem: Material3ButtonContent { control: parent as T.Button }
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
    Material3ButtonGroup {
        tokens: root.tokens
        reduceMotion: root.reduceMotion
        id: standardMixed
        objectName: "comparison.standard.mixed"
        width: Math.min(implicitWidth, parent.width)
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: root.styleScopeReady ? root.standardGroupStyle.spacing : 0
        SK.Button { Material3ButtonGroup.managed: true; width: Material3ButtonGroup.layoutWidth; contentItem: Material3ButtonContent { control: parent as T.Button } objectName: "comparison.standard.mixed.0"; text: qsTr("Label"); SK.StyleVariation.variations: ["buttonSmall", "filledTonal"] }
        SK.Button { Material3ButtonGroup.managed: true; width: Material3ButtonGroup.layoutWidth; contentItem: Material3ButtonContent { control: parent as T.Button } objectName: "comparison.standard.mixed.1"; text: qsTr("Edit"); icon.name: "material:edit"; SK.StyleVariation.variations: ["buttonSmallRectangular", "buttonSmall"] }
        SK.Button { Material3ButtonGroup.managed: true; width: Material3ButtonGroup.layoutWidth; contentItem: Material3ButtonContent { control: parent as T.Button } objectName: "comparison.standard.mixed.2"; icon.name: "material:delete"; display: SK.Button.IconOnly; SK.StyleVariation.variations: ["iconSmall", "iconTonal", "filledTonal"]; Accessible.name: qsTr("Delete") }
    }
    Material3ButtonGroup {
        tokens: root.tokens
        reduceMotion: root.reduceMotion
        id: standardChoices
        objectName: "comparison.standard.choices"
        width: Math.min(implicitWidth, parent.width)
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: root.styleScopeReady ? root.standardGroupStyle.spacing : 0
        SK.Button { Material3ButtonGroup.managed: true; width: Material3ButtonGroup.layoutWidth; contentItem: Material3ButtonContent { control: parent as T.Button } objectName: "comparison.standard.choice.0"; icon.name: "material:star"; display: SK.Button.IconOnly; SK.StyleVariation.variations: ["iconSmall", "iconFilled"]; checkable: true; Accessible.name: qsTr("Star") }
        SK.Button { Material3ButtonGroup.managed: true; width: Material3ButtonGroup.layoutWidth; contentItem: Material3ButtonContent { control: parent as T.Button } objectName: "comparison.standard.choice.1"; text: qsTr("Label"); icon.name: "material:star"; SK.StyleVariation.variations: ["buttonSmall"]; checkable: true; checked: true }
        SK.Button { Material3ButtonGroup.managed: true; width: Material3ButtonGroup.layoutWidth; contentItem: Material3ButtonContent { control: parent as T.Button } objectName: "comparison.standard.choice.2"; icon.name: "material:star"; display: SK.Button.IconOnly; SK.StyleVariation.variations: ["iconSmall", "iconFilled"]; checkable: true; Accessible.name: qsTr("Star") }
    }
    Text { font: root.tokens.titleMedium; color: root.tokens.surfaceForeground; text: qsTr("Connected") }
    C.ButtonGroup { id: fileSelection }
    Material3ButtonGroup {
        tokens: root.tokens
        reduceMotion: root.reduceMotion
        id: filesGroup
        width: parent.width
        spacing: root.styleScopeReady ? root.buttonGroupStyle.spacing : 0
        Repeater {
            id: fileChoices
            model: [qsTr("My files"), qsTr("Shared"), qsTr("Computers")]
            delegate: SK.Button { Material3ButtonGroup.managed: true; width: Material3ButtonGroup.layoutWidth; contentItem: Material3ButtonContent { control: parent as T.Button }
                required property string modelData
                required property int index
                objectName: "comparison.connected.files." + index
                SK.StyleVariation.variations: [index === 0 ? "connectedLeading" : index === 2 ? "connectedTrailing" : "connectedMiddle", "filledTonal"]
                Material3ButtonGroup.weight: 1
                text: modelData
                checkable: true
                checked: index === 0
                C.ButtonGroup.group: fileSelection
            }
        }
    }
    C.ButtonGroup { id: starSelection }
    Material3ButtonGroup {
        tokens: root.tokens
        reduceMotion: root.reduceMotion
        id: starsGroup
        width: Math.min(implicitWidth, parent.width)
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: root.styleScopeReady ? root.buttonGroupStyle.spacing : 0
        Repeater {
            id: starChoices
            model: 5
            delegate: SK.Button { Material3ButtonGroup.managed: true; width: Material3ButtonGroup.layoutWidth; contentItem: Material3ButtonContent { control: parent as T.Button }
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
    Material3ButtonGroup {
        tokens: root.tokens
        reduceMotion: root.reduceMotion
        id: multipleGroup
        width: Math.min(implicitWidth, parent.width)
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: root.styleScopeReady ? root.buttonGroupStyle.spacing : 0
        Repeater {
            id: multipleChoices
            model: [qsTr("One"), qsTr("Two"), qsTr("Three")]
            delegate: SK.Button { Material3ButtonGroup.managed: true; width: Material3ButtonGroup.layoutWidth; contentItem: Material3ButtonContent { control: parent as T.Button }
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
    Material3ButtonGroup {
        tokens: root.tokens
        reduceMotion: root.reduceMotion
        id: weightedGroup
        width: parent.width
        spacing: root.styleScopeReady ? root.buttonGroupStyle.spacing : 0
        SK.Button { Material3ButtonGroup.managed: true; width: Material3ButtonGroup.layoutWidth; contentItem: Material3ButtonContent { control: parent as T.Button } id: weightedLeading; SK.StyleVariation.variations: ["connectedIconLeading", "connectedLeading"]; Material3ButtonGroup.weight: 1; icon.name: "material:star"; display: SK.Button.IconOnly; checkable: true; Accessible.name: qsTr("Star") }
        SK.Button { Material3ButtonGroup.managed: true; width: Material3ButtonGroup.layoutWidth; contentItem: Material3ButtonContent { control: parent as T.Button } SK.StyleVariation.variations: ["connectedMiddle"]; Material3ButtonGroup.weight: 1; text: qsTr("Label"); icon.name: "material:star"; checkable: true; checked: true }
        SK.Button { Material3ButtonGroup.managed: true; width: Material3ButtonGroup.layoutWidth; contentItem: Material3ButtonContent { control: parent as T.Button } SK.StyleVariation.variations: ["connectedIconTrailing", "connectedTrailing"]; Material3ButtonGroup.weight: 1; icon.name: "material:star"; display: SK.Button.IconOnly; checkable: true; Accessible.name: qsTr("Star") }
    }
}
