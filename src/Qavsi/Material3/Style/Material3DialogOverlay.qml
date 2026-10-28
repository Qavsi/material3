pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Templates as T
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

Rectangle {
    id: root
    required property T.Dialog control
    readonly property Material3Theme tokens: (root.control.SK.StyleKit.style as Material3Style).tokens
    color: Qt.alpha(root.tokens.shadow, root.tokens.dialogScrimOpacity)
    Accessible.ignored: true
}
