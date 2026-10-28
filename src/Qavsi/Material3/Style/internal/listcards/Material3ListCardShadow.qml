pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Templates as T
import Qt.labs.StyleKit as SK

Material3Elevation {
    id: root
    required property SK.DelegateStyle delegateStyle
    required property T.Control control
    readonly property Material3ListCardParameters parameters: delegateStyle.data as Material3ListCardParameters
    readonly property T.AbstractButton button: control as T.AbstractButton
    tokens: parameters.tokens
    reducedMotion: parameters.reducedMotion
    targetElevation: !control.enabled ? tokens.elevationLevel0
        : button && button.down ? parameters.elevated ? tokens.elevationLevel1 : tokens.elevationLevel0
        : button && button.hovered ? parameters.elevated ? tokens.elevationLevel2 : tokens.elevationLevel1
        : parameters.elevated ? tokens.elevationLevel1 : tokens.elevationLevel0
    width: parent ? parent.width : 0
    height: parent ? parent.height : 0
    color: delegateStyle.shadow.color
    opacity: delegateStyle.opacity * delegateStyle.shadow.opacity
    visible: control.visible && control.enabled && delegateStyle.shadow.visible && hardware
        && Window.window && Window.window.visible && Window.window.visibility !== Window.Minimized
    cornerRadii: Qt.vector4d(delegateStyle.radius, delegateStyle.radius, delegateStyle.radius, delegateStyle.radius)
}
