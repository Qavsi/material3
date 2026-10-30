pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as Basic
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

Basic.Drawer {
    id: root
    required property Material3Theme tokens
    property bool reducedMotion: false
    readonly property bool effectiveReducedMotion: reducedMotion
        || Application.styleHints.accessibility.motionPreference === Qt.MotionPreference.ReducedMotion
        || !(parent?.SK.StyleKit.transitionsEnabled ?? false)
    readonly property int motionDuration: effectiveReducedMotion || !visible || !parent?.Window.window?.visible
        || parent.Window.window.visibility === Window.Minimized ? 0 : tokens.appNavigationMotionDuration
    implicitWidth: tokens.appNavigationSheetWidth
    padding: tokens.spacingMedium
    leftPadding: padding + SafeArea.margins.left
    rightPadding: padding + SafeArea.margins.right
    topPadding: padding + SafeArea.margins.top
    bottomPadding: padding + SafeArea.margins.bottom
    modal: true
    dim: modal
    focus: true
    closePolicy: Basic.Popup.CloseOnEscape | Basic.Popup.CloseOnPressOutside
    enter: Transition {
        NumberAnimation { property: "position"; duration: root.motionDuration; easing.type: root.tokens.appNavigationMotionEasing }
    }
    exit: Transition {
        NumberAnimation { property: "position"; duration: root.motionDuration; easing.type: root.tokens.appNavigationMotionEasing }
    }
    background: Rectangle {
        color: root.tokens.surfaceContainer
        topLeftRadius: root.edge === Qt.RightEdge ? root.tokens.radiusLarge : 0
        bottomLeftRadius: topLeftRadius
        topRightRadius: root.edge === Qt.LeftEdge ? root.tokens.radiusLarge : 0
        bottomRightRadius: topRightRadius
    }
    Basic.Overlay.modal: Rectangle { color: Qt.alpha(root.tokens.scrim, root.tokens.appNavigationScrimOpacity) }
    Basic.Overlay.modeless: Item { }
}
