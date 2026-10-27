pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Style

DemoCard {
    id: root
    title: qsTr("Native ComboBox API")
    Column {
        width: parent.width
        spacing: root.tokens.spacingLarge
        SK.ComboBox {
            objectName: "comparison.combo.basic"
            width: parent.width
            property int selectedChoice: 0
            currentIndex: selectedChoice
            model: [qsTr("First"), qsTr("Second"), qsTr("Third")]
            ComboBoxSupport.label: qsTr("Workspace")
        }
        SK.ComboBox {
            objectName: "comparison.combo.roles"
            width: parent.width
            property int selectedWorkspace: 10
            currentValue: selectedWorkspace
            textRole: "title"
            valueRole: "key"
            model: ListModel {
                ListElement { title: qsTr("Personal workspace"); key: 10 }
                ListElement { title: qsTr("Team workspace"); key: 20 }
                ListElement { title: qsTr("Production workspace"); key: 30 }
            }
            ComboBoxSupport.label: qsTr("Account")
        }
        SK.ComboBox {
            id: editableControl
            property string pendingDraft: qsTr("Pending draft")
            objectName: "comparison.combo.editable"
            width: parent.width
            editable: true
            currentIndex: -1
            model: [qsTr("Small"), qsTr("Medium"), qsTr("Large")]
            ComboBoxSupport.label: qsTr("Editable size")
            Component.onCompleted: editText = Qt.binding(() => editableControl.pendingDraft)
        }
        SK.ComboBox {
            objectName: "comparison.combo.disabled"
            width: parent.width
            enabled: false
            model: [qsTr("Disabled")]
            ComboBoxSupport.label: qsTr("Unavailable")
        }
        // Only the consumer check activates this after initial StyleKit setup.
        Loader {
            objectName: "comparison.combo.popupLifecycleLoader"
            active: false
            visible: false
            sourceComponent: Component {
                SK.ComboBox {
                    id: lifecycleControl
                    property QtObject stockPopup: null
                    property bool useReplacementPopup: false
                    objectName: "comparison.combo.popupLifecycle"
                    model: [qsTr("First"), qsTr("Second")]
                    Component.onCompleted: stockPopup = popup
                    Loader {
                        active: lifecycleControl.useReplacementPopup
                        sourceComponent: Component {
                            SK.Popup { parent: lifecycleControl }
                        }
                        onLoaded: lifecycleControl.popup = item as SK.Popup
                    }
                }
            }
        }
        SK.ComboBox {
            id: custom
            objectName: "comparison.combo.custom"
            width: parent.width
            model: [qsTr("Custom first"), qsTr("Custom second")]
            ComboBoxSupport.label: qsTr("Caller factories")
            delegate: callerDelegate
            readonly property Component callerDelegate: Component {
                SK.ItemDelegate {
                    required property int index
                    text: custom.textAt(index)
                    width: ListView.view.width
                }
            }
            popup: SK.Popup {
                objectName: "comparison.combo.custom.popup"
                parent: custom
                y: custom.height
                width: custom.width
                contentItem: ListView {
                    implicitHeight: contentHeight
                    model: custom.delegateModel
                }
            }
        }
    }
}
