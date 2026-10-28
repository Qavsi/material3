pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Templates as T
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

Item {
    id: root
    required property T.Dialog control
    readonly property Material3Theme tokens: (control.SK.StyleKit.style as Material3Style).tokens
    implicitWidth: label.implicitWidth + 2 * root.tokens.dialogPadding
    implicitHeight: metrics.height + root.tokens.dialogPadding + root.tokens.dialogVerticalPadding
    visible: control.title.length > 0
    FontMetrics { id: metrics; font: root.tokens.headlineSmall }
    Text {
        id: label
        x: root.tokens.dialogPadding
        y: root.tokens.dialogPadding
        width: Math.max(0, root.width - 2 * root.tokens.dialogPadding)
        height: metrics.height
        text: root.control.title
        font: root.tokens.headlineSmall
        color: root.tokens.surfaceForeground
        horizontalAlignment: Text.AlignHCenter
        elide: Text.ElideRight
    }
}
