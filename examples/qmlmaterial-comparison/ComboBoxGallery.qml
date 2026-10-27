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
    spacing: tokens.spacingLarge
    readonly property real preferredWidth: Math.max(tokens.referenceCardWidth, sizes.implicitWidth
        + (tokens.inputGalleryPadding + tokens.spacingUnit + tokens.focusRingWidth) * 2)
    C.Action {
        id: firstAction
        objectName: "comparison.menu.action.first"
        text: qsTr("First action")
        icon.name: "material:add"
    }
    C.Action {
        id: secondAction
        text: qsTr("Second action")
    }
    C.Action {
        id: longAction
        text: qsTr("long long long long long long long long long")
        icon.name: "material:description"
    }
    DemoCard {
        width: parent.width
        tokens: root.tokens
        title: qsTr("Menus")
        minimumContentWidth: sizes.implicitWidth
        contentPadding: root.tokens.inputGalleryPadding
        SK.Button {
            objectName: "comparison.menu.open"
            text: qsTr("Open menu")
            flat: true
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: referenceMenuLoader.active ? (referenceMenuLoader.item as SK.Menu).open() : referenceMenuLoader.active = true
            Loader {
                id: referenceMenuLoader
                active: false
                onLoaded: (item as SK.Menu).open()
                sourceComponent: Component {
                    SK.Menu {
                        parent: referenceMenuLoader.parent
                        y: (parent as SK.Button).height
                        SK.MenuItem { text: qsTr("First") }
                        SK.MenuItem { text: qsTr("Second") }
                        SK.MenuItem { text: qsTr("Third") }
                    }
                }
            }
        }
        SK.Button {
            objectName: "comparison.menu.action.open"
            text: qsTr("Open action menu")
            flat: true
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: actionMenuLoader.active ? (actionMenuLoader.item as SK.Menu).open() : actionMenuLoader.active = true
            Loader {
                id: actionMenuLoader
                active: false
                onLoaded: (item as SK.Menu).open()
                sourceComponent: Component {
                    SK.Menu {
                        objectName: "comparison.menu.actions"
                        parent: actionMenuLoader.parent
                        y: (parent as SK.Button).height
                        onVisibleChanged: {
                            if (visible && count === 0) {
                                addAction(firstAction)
                                addAction(secondAction)
                                addAction(longAction)
                            }
                        }
                        delegate: SK.MenuItem {
                            icon.color: (contentItem as Material3MenuItemContent).color
                            contentItem: Material3MenuItemContent { control: parent as T.MenuItem }
                        }
                    }
                }
            }
        }
        Row {
            id: sizes
            spacing: root.tokens.spacingSmall
            anchors.horizontalCenter: parent.horizontalCenter
            Repeater {
                model: [
                    { size: "XS", variation: "comboBoxExtraSmall" },
                    { size: "S", variation: "comboBoxSmall" },
                    { size: "M", variation: "comboBoxMedium" },
                    { size: "L", variation: "comboBoxLarge" },
                    { size: "XL", variation: "comboBoxExtraLarge" }
                ]
                SK.ComboBox {
                    required property var modelData
                    objectName: "comparison.combo.size." + modelData.size
                    model: [modelData.size]
                    SK.StyleVariation.variations: [modelData.variation]
                }
            }
        }
        SK.ComboBox {
            objectName: "comparison.combo.reference"
            width: root.tokens.menuMinimumWidth
            anchors.horizontalCenter: parent.horizontalCenter
            editable: true
            model: [qsTr("Small"), qsTr("Medium"), qsTr("Large")]
            ComboBoxSupport.label: qsTr("Size")
        }
    }
}
