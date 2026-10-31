pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

Rectangle {
    id: root
    required property Material3TimeField control
    required property SK.DelegateStyle delegateStyle
    readonly property Material3Theme tokens: delegateStyle.data as Material3Theme
    implicitWidth: delegateStyle.width
    implicitHeight: delegateStyle.height
    radius: tokens.radiusSmall
    color: control.selected ? tokens.primaryContainer : tokens.surfaceContainerHighest
    border.width: !control.acceptable || (control.editable && control.activeFocus) ? tokens.focusRingWidth : 0
    border.color: !control.acceptable ? tokens.error : tokens.primary
    visible: delegateStyle.visible
    opacity: delegateStyle.opacity
    antialiasing: true
    Accessible.ignored: true
}
