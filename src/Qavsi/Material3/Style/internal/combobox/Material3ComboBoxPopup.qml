pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Templates as T
import Qt.labs.StyleKit as SK

SK.Popup {
    id: root
    required property T.ComboBox control
    required property Material3ComboBoxParameters parameters
    property bool active: false
    property real preferredWidth: parameters.tokens.menuMinimumWidth
    readonly property real widthLimit: parameters.tokens.comboBoxPopupMaximumWidth
    readonly property real heightLimit: Math.max(0, control.Window.height - topMargin - bottomMargin)
    parent: control
    x: control.mirrored ? control.width - width : 0
    y: control.height + parameters.tokens.comboBoxPopupGap
    width: Math.min(preferredWidth, widthLimit, Math.max(0, control.Window.width - leftMargin - rightMargin))
    height: Math.min(implicitHeight, heightLimit)
    leftMargin: parameters.tokens.comboBoxPopupMargin
    rightMargin: parameters.tokens.comboBoxPopupMargin
    topMargin: parameters.tokens.comboBoxPopupMargin
    bottomMargin: parameters.tokens.comboBoxPopupMargin
    modal: false
    focus: false
    dim: false
    transformOrigin: control.mirrored ? Item.TopRight : Item.TopLeft
    SK.StyleKit.style: control.SK.StyleKit.style
    SK.StyleKit.transitionsEnabled: control.SK.StyleKit.transitionsEnabled
    enter: Material3MenuEnterTransition { control: root }
    exit: Material3MenuExitTransition { control: root }
    FontMetrics { id: metrics; font: root.parameters.tokens.labelLarge }
    function updateWidth(): void {
        // shortcut: scan short option lists on open; cache widths if large models profile as slow.
        let measured = root.parameters.tokens.menuMinimumWidth
        for (let index = 0; index < root.control.count && measured < root.widthLimit; ++index)
            measured = Math.max(measured, metrics.advanceWidth(root.control.textAt(index))
                + root.parameters.tokens.menuItemHorizontalPadding * 2)
        root.preferredWidth = measured
    }
    onAboutToShow: {
        updateWidth()
        view.forceLayout()
    }
    onOpened: view.positionViewAtIndex(root.control.highlightedIndex, ListView.Contain)
    Connections {
        target: root.control
        function onHighlightedIndexChanged() {
            if (root.visible && root.control.highlightedIndex >= 0)
                view.positionViewAtIndex(root.control.highlightedIndex, ListView.Contain)
        }
    }
    contentItem: ListView {
        id: view
        clip: true
        implicitHeight: contentHeight
        model: root.active ? root.control.delegateModel : null
        currentIndex: root.control.highlightedIndex
        highlightMoveDuration: 0
        keyNavigationEnabled: false
        interactive: contentHeight > height
        boundsBehavior: Flickable.StopAtBounds
        T.ScrollIndicator.vertical: SK.ScrollIndicator { }
    }
    function releaseModel(): void { view.model = null }
}
