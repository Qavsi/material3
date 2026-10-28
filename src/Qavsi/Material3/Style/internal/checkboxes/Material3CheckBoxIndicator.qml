// Shape paths adapted from QmlMaterial 0.6.1, 191260585a829ee4ae2c99e6232b7145b5c34474 (MIT).
// The source's 7..25 path coordinates are translated to an 18px origin; see THIRD_PARTY_NOTICES.md.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Shapes
import QtQuick.Templates as T
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

Item {
    id: root
    required property T.CheckBox control
    required property SK.DelegateStyle delegateStyle
    readonly property Material3CheckBoxParameters parameters: delegateStyle.data as Material3CheckBoxParameters
    readonly property Material3Theme tokens: parameters.tokens
    readonly property bool selected: control.checkState !== Qt.Unchecked
    readonly property bool active: control.hovered || control.pressed || control.visualFocus
    readonly property color outline: !control.enabled ? tokens.checkBoxDisabledIndicator
        : active ? tokens.checkBoxActiveOutline : tokens.checkBoxOutline
    readonly property color container: control.enabled ? tokens.checkBoxSelectedIndicator : tokens.checkBoxDisabledIndicator
    readonly property color glyph: control.enabled ? tokens.checkBoxSelectedGlyph : tokens.checkBoxDisabledGlyph
    readonly property color stateLayerColor: selected ? tokens.checkBoxSelectedStateLayer : tokens.checkBoxStateLayer
    readonly property bool feedbackEnabled: control.enabled && control.visible && control.opacity > 0
        && visible && opacity > 0 && Window.window && Window.window.visible
        && Window.window.visibility !== Window.Minimized

    width: parent.width
    height: parent.height
    implicitWidth: delegateStyle.width
    implicitHeight: delegateStyle.height
    visible: delegateStyle.visible
    opacity: delegateStyle.opacity
    Accessible.ignored: true

    // Qt 6.12's native StyleKit CheckBox does not publish its mixed state.
    Binding {
        target: root.control.Accessible
        property: "checkStateMixed"
        value: root.control.checkState === Qt.PartiallyChecked
    }
    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        fillMode: Shape.Stretch
        ShapePath {
            strokeColor: root.tokens.transparent
            strokeWidth: 0
            fillColor: root.selected ? root.container : root.tokens.transparent
            pathHints: ShapePath.PathQuadratic | ShapePath.PathNonIntersecting | ShapePath.PathNonOverlappingControlPointTriangles
            PathSvg {
                path: "M16 0 L2 0 Q1.175 0 .5875 .5875 Q0 1.175 0 2 L0 16 Q0 16.825 .5875 17.4125 Q1.175 18 2 18 L16 18 Q16.825 18 17.4125 17.4125 Q18 16.825 18 16 L18 2 Q18 1.175 17.4125 .5875 Q16.825 0 16 0"
            }
        }
        ShapePath {
            strokeColor: root.tokens.transparent
            strokeWidth: 0
            fillColor: root.selected ? root.tokens.transparent : root.outline
            fillRule: ShapePath.WindingFill
            pathHints: ShapePath.PathQuadratic | ShapePath.PathNonIntersecting | ShapePath.PathNonOverlappingControlPointTriangles
            PathSvg {
                path: "M16 0 L2 0 Q1.175 0 .5875 .5875 Q0 1.175 0 2 L0 16 Q0 16.825 .5875 17.4125 Q1.175 18 2 18 L16 18 Q16.825 18 17.4125 17.4125 Q18 16.825 18 16 L18 2 Q18 1.175 17.4125 .5875 Q16.825 0 16 0 M16 16 L2 16 L2 2 L16 2 L16 16"
            }
        }
        ShapePath {
            strokeColor: root.tokens.transparent
            strokeWidth: 0
            fillColor: root.control.checkState === Qt.Checked ? root.glyph : root.tokens.transparent
            PathSvg { path: "M7 11.2 L4.4 8.6 L3 10 L7 14 L15 6 L13.6 4.6 L7 11.2" }
        }
        ShapePath {
            strokeColor: root.tokens.transparent
            strokeWidth: 0
            fillColor: root.control.checkState === Qt.PartiallyChecked ? root.glyph : root.tokens.transparent
            PathSvg { path: "M6.4 8 L4 8 L4 10 L6.4 10 L14 10 L14 8 L6.4 8" }
        }
    }
    Material3Ripple {
        id: feedback
        anchors.centerIn: parent
        width: root.tokens.checkBoxStateLayerDiameter
        height: width
        control: root.control
        tokens: root.tokens
        reduceMotion: root.parameters.reducedMotion || !root.control.SK.StyleKit.transitionsEnabled
        rippleColor: root.stateLayerColor
        cornerRadius: width / 2
        cornerRadii: Qt.vector4d(cornerRadius, cornerRadius, cornerRadius, cornerRadius)
        feedbackEnabled: root.feedbackEnabled
        stateOpacity: root.control.visualFocus ? root.tokens.interactionOpacity
            : root.control.hovered ? root.tokens.hoverOpacity : 0
        pressOpacity: root.tokens.interactionOpacity
        restartOnPress: true
    }
    Rectangle {
        anchors.centerIn: parent
        width: feedback.width + (root.tokens.focusRingGap + root.tokens.focusRingWidth) * 2
        height: width
        radius: width / 2
        color: root.tokens.transparent
        border.width: root.tokens.focusRingWidth
        border.color: root.tokens.primary
        visible: root.feedbackEnabled && root.control.visualFocus
        antialiasing: true
    }
}
