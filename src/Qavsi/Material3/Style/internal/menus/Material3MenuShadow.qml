import QtQuick
import QtQuick.Templates as T
import Qt.labs.StyleKit as SK

Material3Elevation {
    id: root
    required property SK.DelegateStyle delegateStyle
    required property T.Popup control
    readonly property Material3MenuParameters parameters: root.delegateStyle.data as Material3MenuParameters
    readonly property real maximumRadius: Math.min(root.width, root.height) / 2
    readonly property bool feedbackEnabled: Math.floor(root.width * Screen.devicePixelRatio) > 0
        && Math.floor(root.height * Screen.devicePixelRatio) > 0
        && root.control.enabled && root.control.visible && root.control.opacity > 0
        && root.delegateStyle.visible && root.delegateStyle.opacity > 0
        && root.delegateStyle.shadow.visible && root.delegateStyle.shadow.opacity > 0
        && root.Window.window && root.Window.window.visible
        && root.Window.window.visibility !== Window.Minimized

    tokens: root.parameters.tokens
    reducedMotion: root.parameters.reducedMotion
    targetElevation: root.feedbackEnabled ? root.tokens.elevationLevel2 : root.tokens.elevationLevel0
    color: root.delegateStyle.shadow.color
    opacity: root.delegateStyle.opacity * root.delegateStyle.shadow.opacity
    visible: root.feedbackEnabled && root.hardware
    width: parent ? parent.width : 0
    height: parent ? parent.height : 0
    cornerRadii: Qt.vector4d(Math.max(0, Math.min(root.delegateStyle.topLeftRadius, root.maximumRadius)),
        Math.max(0, Math.min(root.delegateStyle.topRightRadius, root.maximumRadius)),
        Math.max(0, Math.min(root.delegateStyle.bottomLeftRadius, root.maximumRadius)),
        Math.max(0, Math.min(root.delegateStyle.bottomRightRadius, root.maximumRadius)))
}
