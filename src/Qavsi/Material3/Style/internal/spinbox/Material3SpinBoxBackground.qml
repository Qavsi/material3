pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Templates as T
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

Rectangle {
    id: root
    required property T.SpinBox control
    required property SK.DelegateStyle delegateStyle
    readonly property Material3Theme tokens: delegateStyle.data as Material3Theme
    readonly property TextInput editor: control.contentItem as TextInput
    width: parent.width; height: parent.height
    implicitWidth: delegateStyle.width; implicitHeight: delegateStyle.height
    color: delegateStyle.color; radius: delegateStyle.radius
    border.width: delegateStyle.border.width; border.color: delegateStyle.border.color
    Material3TextFieldBinding {
        target: root.editor; property: "selectionColor"
        defaultValue: root.control.palette.highlight
        value: root.tokens.primary
        requested: root.editor !== null
    }
    Material3TextFieldBinding {
        target: root.editor; property: "selectedTextColor"
        defaultValue: root.control.palette.highlightedText
        value: root.tokens.primaryForeground
        requested: root.editor !== null
    }
}
