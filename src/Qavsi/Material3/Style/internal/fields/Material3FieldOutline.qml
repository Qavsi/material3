pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Shapes

Shape {
    id: root
    required property real strokeWidth
    required property color strokeColor
    required property color fillColor
    required property real radius
    property real gapWidth: 0
    property real gapCenter: 0
    readonly property real halfStroke: strokeWidth / 2
    readonly property real corner: Math.max(0, Math.min(radius, width / 2, height / 2) - halfStroke)
    readonly property real gapStart: Math.max(halfStroke + corner,
        Math.min(width - halfStroke - corner, gapCenter - gapWidth / 2))
    readonly property real gapEnd: Math.max(gapStart,
        Math.min(width - halfStroke - corner, gapCenter + gapWidth / 2))

    objectName: "material3.field.outline"
    Accessible.ignored: true
    preferredRendererType: Shape.CurveRenderer
    ShapePath {
        strokeColor: root.strokeColor
        strokeWidth: root.strokeWidth
        fillColor: root.fillColor
        capStyle: ShapePath.FlatCap
        joinStyle: ShapePath.RoundJoin
        startX: root.gapEnd
        startY: root.halfStroke
        PathLine { x: root.width - root.halfStroke - root.corner; y: root.halfStroke }
        PathArc { x: root.width - root.halfStroke; y: root.halfStroke + root.corner; radiusX: root.corner; radiusY: root.corner }
        PathLine { x: root.width - root.halfStroke; y: root.height - root.halfStroke - root.corner }
        PathArc { x: root.width - root.halfStroke - root.corner; y: root.height - root.halfStroke; radiusX: root.corner; radiusY: root.corner }
        PathLine { x: root.halfStroke + root.corner; y: root.height - root.halfStroke }
        PathArc { x: root.halfStroke; y: root.height - root.halfStroke - root.corner; radiusX: root.corner; radiusY: root.corner }
        PathLine { x: root.halfStroke; y: root.halfStroke + root.corner }
        PathArc { x: root.halfStroke + root.corner; y: root.halfStroke; radiusX: root.corner; radiusY: root.corner }
        PathLine { x: root.gapStart; y: root.halfStroke }
    }
}
