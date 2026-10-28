pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme
import Qavsi.Material3.Style

ColumnLayout {
    id: root
    readonly property ComparisonMetrics metrics: ComparisonMetrics { }
    required property Material3Theme tokens
    property color selectedColor: tokens.primary
    spacing: tokens.spacingMedium
    SK.Label { text: qsTr("Color picker"); color: root.tokens.surfaceForeground; font: root.tokens.titleLarge }
    Material3ColorPickerButton {
        id: colorButton
        objectName: "comparison.pickers.color.button"
        Layout.preferredWidth: root.metrics.colorPickerButtonWidth
        Layout.fillWidth: false
        color: root.selectedColor
        dialog.objectName: "comparison.pickers.color"
        onAccepted: value => root.selectedColor = value
    }
    Material3ColorPicker {
        objectName: "comparison.pickers.color.inline"
        showHeader: false
        Layout.fillWidth: true
        color: root.selectedColor
        onColorChangeRequested: value => root.selectedColor = value
    }
}
