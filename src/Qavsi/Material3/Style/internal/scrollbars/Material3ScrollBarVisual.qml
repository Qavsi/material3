pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Templates as T
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

Item {
    id: root
    required property T.ScrollBar control
    required property SK.DelegateStyle delegateStyle
    property bool track: false
    readonly property Material3ScrollBarParameters parameters: delegateStyle.data as Material3ScrollBarParameters
    readonly property Material3Theme tokens: parameters.tokens
    readonly property bool expanded: control.interactive && (control.hovered || control.pressed)
    readonly property bool showing: control.policy !== T.ScrollBar.AlwaysOff
        && (control.policy === T.ScrollBar.AlwaysOn || ((control.active || control.hovered || control.pressed) && control.size < 1))
    readonly property bool animate: !parameters.reducedMotion && control.SK.StyleKit.transitionsEnabled
        && control.visible && visible && Window.window && Window.window.visible && Window.window.visibility !== Window.Minimized
    property bool retained: false
    readonly property real visibilityOpacity: showing || retained ? 1 : 0
    width: parent.width
    height: parent.height
    implicitWidth: delegateStyle.width
    implicitHeight: delegateStyle.height
    Accessible.ignored: true
    onShowingChanged: {
        retention.stop();
        if (showing)
            retained = true;
        else if (animate)
            retention.restart();
        else
            retained = false;
    }
    onAnimateChanged: {
        if (!animate) {
            retention.stop();
            retained = false;
        }
    }
    Timer {
        id: retention
        interval: root.tokens.scrollBarRetentionDuration
        onTriggered: root.retained = false
    }
    Rectangle {
        anchors.centerIn: parent
        readonly property real thickness: root.track ? root.tokens.scrollBarExtent
            : root.expanded ? root.tokens.scrollBarExpandedThumbWidth : root.tokens.scrollBarThumbWidth
        width: root.control.horizontal ? parent.width : thickness
        height: root.control.horizontal ? thickness : parent.height
        radius: thickness / 2
        color: Qt.alpha(root.tokens.surfaceForeground, root.track ? root.tokens.scrollBarTrackOpacity
            : root.control.pressed ? root.tokens.scrollBarPressedOpacity : root.tokens.scrollBarThumbOpacity)
        opacity: root.visibilityOpacity * (root.track && !root.expanded ? 0 : root.delegateStyle.opacity)
        Behavior on opacity { NumberAnimation { duration: root.animate ? root.tokens.scrollBarFadeDuration : 0 } }
    }
}
