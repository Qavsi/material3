pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Templates as T
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme
import QtQuick.Shapes

Rectangle {
    id: root
    required property T.SpinBox control
    required property SK.DelegateStyle delegateStyle
    required property bool increasing
    readonly property Material3Theme tokens: delegateStyle.data as Material3Theme
    readonly property bool canStep: control.enabled && control.from !== control.to
        && (control.wrap || control.value !== (increasing ? control.to : control.from))
    implicitWidth: delegateStyle.width
    implicitHeight: delegateStyle.height
    width: parent.width
    height: parent.height
    color: canStep ? delegateStyle.color : tokens.transparent
    radius: tokens.radiusExtraSmall
    Accessible.ignored: true
    // shortcut: Qt 6.12 keeps indicator margins physical, remove when stacked indicators mirror natively.
    Binding {
        id: mirroredColumn
        target: root.control.down.indicator
        property: "x"
        value: root.control.up.indicator.x
        when: !root.increasing && root.control.mirrored
    }
    Component.onDestruction: mirroredColumn.when = false
    Shape {
        id: arrow
        anchors.centerIn: parent
        width: root.tokens.spinBoxGlyphWidth
        height: root.tokens.spinBoxGlyphHeight
        rotation: root.increasing ? 0 : 180
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            strokeWidth: 0; strokeColor: root.tokens.transparent
            fillColor: root.canStep ? root.tokens.surfaceVariantForeground : root.tokens.disabledLabel
            startX: 0; startY: arrow.height
            PathLine { x: arrow.width / 2; y: 0 }
            PathLine { x: arrow.width; y: arrow.height }
            PathLine { x: 0; y: arrow.height }
        }
    }
}
