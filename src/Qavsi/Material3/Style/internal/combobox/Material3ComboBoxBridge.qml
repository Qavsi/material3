pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Templates as T
import Qt.labs.StyleKit as SK

Item {
    id: root
    required property T.ComboBox control
    required property Material3ComboBoxParameters parameters
    property Component originalDelegate: null
    property T.Popup originalPopup: null
    property Item originalPopupParent: null
    property Item originalPopupSurface: null
    property bool originalPopupIgnored: false
    property TextInput originalEditor: null
    property bool ready: false
    property bool managesDelegate: false
    readonly property Material3ComboBoxPopup materialPopup: popupLoader.item as Material3ComboBoxPopup
    Loader {
        id: popupLoader
        active: false
        sourceComponent: Component {
            Material3ComboBoxPopup {
                control: root.control
                parameters: root.parameters
                active: popupBinding.when && root.control.popup === root.materialPopup
            }
        }
        onLoaded: popupBinding.when = true
    }
    readonly property Component materialDelegate: Component {
        SK.MenuItem {
            required property int index
            required property var model
            width: ListView.view ? ListView.view.width : implicitWidth
            text: model[root.control.textRole || "modelData"]
            checked: root.control.currentIndex === index
            highlighted: root.control.highlightedIndex === index
            checkable: false
            indicator: null
            focusPolicy: Qt.NoFocus
            hoverEnabled: root.control.hoverEnabled
            Accessible.selectable: true
            Accessible.selected: root.control.currentIndex === index
        }
    }
    function restorePopupParent(): void {
        if (root.originalPopup && root.control.popup === root.originalPopup) {
            root.originalPopup.parent = root.originalPopupParent
            if (root.originalPopupSurface)
                root.originalPopupSurface.Accessible.ignored = root.originalPopupIgnored
        }
    }
    function install(): void {
        root.originalDelegate = root.control.delegate
        root.originalPopup = root.control.popup
        root.originalEditor = root.control.contentItem as TextInput
        const support = root.control.ComboBoxSupport
        const defaultPopup = support.isStyleKitDefault(root.originalPopup)
        const wasOpen = defaultPopup && root.originalPopup.visible
        if (defaultPopup) {
            root.originalPopupParent = root.originalPopup.parent
            root.originalPopupSurface = root.originalPopup.contentItem.parent
            root.originalPopupIgnored = root.originalPopupSurface.Accessible.ignored
            // The native delegateModel must have only one active view.
            originalModelBinding.when = true
        }
        if (support.isStyleKitDefault(root.originalDelegate)) {
            support.applyDelegate(root.materialDelegate)
            root.managesDelegate = true
        }
        if (defaultPopup)
            popupLoader.active = true
        root.ready = true
        if (wasOpen && root.materialPopup)
            root.materialPopup.open()
    }
    Component.onCompleted: Qt.callLater(root.install)
    Component.onDestruction: {
        root.ready = false
        if (root.materialPopup)
            root.materialPopup.releaseModel()
        const restoreOriginal = root.control.popup === root.materialPopup
        if (!restoreOriginal && root.control.popup !== root.originalPopup)
            originalModelBinding.restoreMode = Binding.RestoreNone
        popupBinding.when = false
        if (root.managesDelegate && root.control.delegate === root.materialDelegate)
            root.control.ComboBoxSupport.applyDelegate(root.originalDelegate)
        originalModelBinding.when = false
        root.restorePopupParent()
    }
    Binding {
        id: originalModelBinding
        target: root.originalPopup ? root.originalPopup.contentItem : null
        property: "model"
        value: null
        when: false
    }
    Binding {
        id: popupBinding
        target: root.control
        property: "popup"
        value: root.materialPopup
        when: false
    }
    Connections {
        target: root.control
        function onDelegateChanged() {
            if (root.ready && root.managesDelegate && root.control.delegate !== root.materialDelegate) {
                root.managesDelegate = false
            }
        }
        function onPopupChanged() {
            if (!root.ready)
                return
            if (popupBinding.when && root.control.popup !== root.materialPopup) {
                popupBinding.restoreMode = Binding.RestoreNone
                popupBinding.when = false
            }
            if (root.control.popup === root.originalPopup) {
                originalModelBinding.when = false
                root.restorePopupParent()
            }
        }
    }
    Loader {
        active: root.ready && root.originalEditor !== null && root.control.contentItem === root.originalEditor
            && root.control.ComboBoxSupport.isStyleKitDefault(root.originalEditor)
        sourceComponent: Component {
            Material3ComboBoxDisplay {
                control: root.control
                editor: root.originalEditor
                parameters: root.parameters
            }
        }
    }
    Material3TextFieldBinding {
        target: root.control.Accessible; property: "name"
        defaultValue: ""
        requested: root.control.ComboBoxSupport.label.length > 0
        value: root.control.ComboBoxSupport.label
    }
}
