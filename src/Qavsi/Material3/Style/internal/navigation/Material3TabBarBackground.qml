pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Templates as T
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

Rectangle {
    id: root
    required property SK.DelegateStyle delegateStyle
    required property T.TabBar control
    readonly property Material3NavigationParameters parameters: delegateStyle.data as Material3NavigationParameters
    readonly property Material3Theme tokens: parameters.tokens
    readonly property bool navigationBar: parameters.role === "navigationBar"
    readonly property Item selectedItem: control.currentItem
    readonly property T.Control selectedControl: selectedItem as T.Control
    readonly property real selectedWidth: selectedItem ? Math.min(selectedItem.width,
        Math.max(tokens.tabIndicatorMinimumWidth,
            selectedControl ? selectedControl.implicitContentWidth : selectedItem.implicitWidth)) : 0
    readonly property real contentOffset: (control.contentItem as ListView)?.contentX ?? 0
    readonly property real selectedX: selectedItem ? control.leftPadding - control.leftInset
        + selectedItem.x - contentOffset + (selectedItem.width - selectedWidth) / 2 : 0
    readonly property bool canAnimate: ready && !parameters.reducedMotion && visible && control.visible
        && control.SK.StyleKit.transitionsEnabled && !((control.contentItem as ListView)?.moving ?? false)
        && Window.window && Window.window.visible
        && Window.window.visibility !== Window.Minimized
    property bool ready: false

    objectName: "material3.navigation.barBackground"
    width: parent ? parent.width : 0
    height: parent ? parent.height : 0
    implicitWidth: delegateStyle.width
    implicitHeight: delegateStyle.height
    color: delegateStyle.color
    visible: delegateStyle.visible
    opacity: delegateStyle.opacity
    Accessible.ignored: true
    Component.onCompleted: ready = true
    onCanAnimateChanged: {
        if (!canAnimate) {
            indicatorPosition.complete()
            indicatorSize.complete()
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        height: root.tokens.tabDividerHeight
        color: root.tokens.outlineVariant
        visible: !root.navigationBar
    }
    Rectangle {
        objectName: "material3.tabs.indicator"
        x: root.selectedX
        y: root.control.position === T.TabBar.Footer ? 0 : root.height - height
        width: root.selectedWidth
        height: root.tokens.tabIndicatorHeight
        topLeftRadius: root.control.position === T.TabBar.Footer ? 0 : root.tokens.tabIndicatorRadius
        topRightRadius: topLeftRadius
        bottomLeftRadius: root.control.position === T.TabBar.Footer ? root.tokens.tabIndicatorRadius : 0
        bottomRightRadius: bottomLeftRadius
        color: root.control.enabled ? root.tokens.primary : root.tokens.disabledLabel
        visible: !root.navigationBar && root.selectedItem !== null
        Behavior on x {
            enabled: root.canAnimate
            NumberAnimation {
                id: indicatorPosition
                duration: root.tokens.tabIndicatorDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: root.tokens.tabIndicatorEasingCurve
            }
        }
        Behavior on width {
            enabled: root.canAnimate
            NumberAnimation {
                id: indicatorSize
                duration: root.tokens.tabIndicatorDuration
                easing.type: Easing.BezierSpline
                easing.bezierCurve: root.tokens.tabIndicatorEasingCurve
            }
        }
    }
}
