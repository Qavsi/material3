pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Templates as T
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

Item {
    id: root
    required property SK.DelegateStyle delegateStyle
    required property T.AbstractButton control
    readonly property Material3NavigationParameters parameters: delegateStyle.data as Material3NavigationParameters
    readonly property Material3Theme tokens: parameters.tokens
    readonly property bool navigationItem: parameters.barItem || parameters.railItem
    readonly property real indicatorWidth: parameters.barItem ? tokens.navigationBarIndicatorWidth
        : parameters.expandedRail ? tokens.navigationRailExpandedIndicatorSize : tokens.navigationRailIndicatorWidth
    readonly property real indicatorHeight: parameters.barItem ? tokens.navigationBarIndicatorHeight
        : parameters.expandedRail ? tokens.navigationRailExpandedIndicatorSize : tokens.navigationRailIndicatorHeight
    readonly property bool feedbackEnabled: control.enabled && control.visible && control.opacity > 0
        && visible && opacity > 0 && Window.window && Window.window.visible
        && Window.window.visibility !== Window.Minimized
    readonly property bool canAnimate: ready && feedbackEnabled && !parameters.reducedMotion
        && control.SK.StyleKit.transitionsEnabled
    readonly property real stateOpacity: control.visualFocus && !ripple.pointerFocus ? tokens.interactionOpacity
        : control.hovered ? tokens.hoverOpacity : 0
    readonly property bool focusVisible: feedbackEnabled && control.visualFocus && !ripple.pointerFocus
    property bool ready: false
    readonly property real focusOutset: tokens.focusRingGap + tokens.focusRingWidth
    property alias rippleProgress: ripple.rippleProgress
    property alias rippleOpacity: ripple.rippleOpacity
    property alias stateLayerOpacity: ripple.stateLayerOpacity
    readonly property bool rippleRunning: ripple.rippleRunning
    readonly property string feedbackRenderer: ripple.feedbackRenderer

    objectName: "material3.navigation.itemBackground"
    width: parent ? parent.width : 0
    height: parent ? parent.height : 0
    implicitWidth: delegateStyle.width
    implicitHeight: delegateStyle.height
    visible: delegateStyle.visible
    opacity: delegateStyle.opacity
    Accessible.ignored: true
    Component.onCompleted: ready = true
    onCanAnimateChanged: { if (!canAnimate) selectionAnimation.complete() }

    Item {
        id: plate
        x: root.navigationItem ? (root.width - width) / 2 : 0
        y: 0
        width: root.navigationItem ? Math.min(root.width, root.indicatorWidth) : root.width
        height: root.navigationItem ? Math.min(root.height, root.indicatorHeight) : root.height
        readonly property real cornerRadius: root.navigationItem ? height / 2 : 0
        Rectangle {
            id: selection
            anchors.horizontalCenter: parent.horizontalCenter
            height: parent.height
            width: root.parameters.barItem
                ? Math.min(parent.width, root.control.checked ? root.tokens.navigationBarIndicatorWidth
                    : root.tokens.navigationBarIndicatorStartWidth)
                : parent.width * (root.control.checked ? 1 : 0)
            radius: plate.cornerRadius
            color: root.delegateStyle.color
            antialiasing: true
            Behavior on width {
                enabled: root.canAnimate
                NumberAnimation {
                    id: selectionAnimation
                    duration: root.parameters.barItem ? root.tokens.navigationBarSelectionDuration
                        : root.tokens.navigationRailSelectionDuration
                    easing.type: root.parameters.barItem ? root.tokens.navigationBarSelectionEasing
                        : root.tokens.navigationRailSelectionEasing
                }
            }
        }
        Material3Ripple {
            id: ripple
            anchors.fill: parent
            control: root.control
            tokens: root.tokens
            reduceMotion: root.parameters.reducedMotion || !root.control.SK.StyleKit.transitionsEnabled
            feedbackEnabled: root.feedbackEnabled
            rippleColor: root.navigationItem ? root.tokens.surfaceForeground : root.tokens.primary
            cornerRadius: plate.cornerRadius
            cornerRadii: Qt.vector4d(cornerRadius, cornerRadius, cornerRadius, cornerRadius)
            stateOpacity: root.stateOpacity
            pressOpacity: root.tokens.navigationRippleOpacity
            restartOnPress: true
            feedbackObjectName: "material3.navigation.feedback"
        }
        Rectangle {
            x: -root.focusOutset
            y: -root.focusOutset
            width: parent.width + root.focusOutset * 2
            height: parent.height + root.focusOutset * 2
            radius: plate.cornerRadius + root.focusOutset
            color: root.tokens.transparent
            border.color: root.tokens.primary
            border.width: root.tokens.focusRingWidth
            visible: root.focusVisible
            antialiasing: true
        }
    }
}
