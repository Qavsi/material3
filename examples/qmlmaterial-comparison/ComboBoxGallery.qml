pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Style
import Qavsi.Material3.Theme

Column {
    id: root
    required property Material3Theme tokens
    spacing: tokens.spacingLarge
    readonly property real preferredWidth: Math.max(tokens.referenceCardWidth, sizes.implicitWidth
        + (tokens.inputGalleryPadding + tokens.spacingUnit + tokens.focusRingWidth) * 2)
    DemoCard {
        width: parent.width
        tokens: root.tokens
        title: qsTr("Menus")
        minimumContentWidth: sizes.implicitWidth
        contentPadding: root.tokens.inputGalleryPadding
        SK.Button {
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
                        parent: actionMenuLoader.parent
                        y: (parent as SK.Button).height
                        SK.MenuItem { text: qsTr("First action") }
                        SK.MenuItem { text: qsTr("Second action") }
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
