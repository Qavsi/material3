// Adapted from QmlMaterial 0.6.1 (1912605), MIT.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Shapes
import Qavsi.Material3.Theme

Material3ColorTriangleBase {
    id: root
    required property Material3Theme tokens

    implicitWidth: tokens.colorPickerTriangleSize
    implicitHeight: tokens.colorPickerTriangleSize

    readonly property color _hueColor: Qt.hsva(hue, 1, 1, 1)

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            fillColor: root._hueColor
            strokeColor: root._hueColor
            strokeWidth: root.tokens.outlineWidth
            startX: root.hueVertex.x
            startY: root.hueVertex.y
            PathLine {
                x: root.whiteVertex.x
                y: root.whiteVertex.y
            }
            PathLine {
                x: root.blackVertex.x
                y: root.blackVertex.y
            }
            PathLine {
                x: root.hueVertex.x
                y: root.hueVertex.y
            }
        }
        ShapePath {
            strokeColor: root.tokens.transparent
            strokeWidth: 0
            startX: root.hueVertex.x
            startY: root.hueVertex.y
            fillGradient: LinearGradient {
                x1: (root.hueVertex.x + root.blackVertex.x) / 2
                y1: (root.hueVertex.y + root.blackVertex.y) / 2
                x2: root.whiteVertex.x
                y2: root.whiteVertex.y
                GradientStop {
                    position: 0.0
                    color: Qt.rgba(1, 1, 1, 0)
                }
                GradientStop {
                    position: 1.0
                    color: Qt.rgba(1, 1, 1, 1)
                }
            }
            PathLine {
                x: root.whiteVertex.x
                y: root.whiteVertex.y
            }
            PathLine {
                x: root.blackVertex.x
                y: root.blackVertex.y
            }
            PathLine {
                x: root.hueVertex.x
                y: root.hueVertex.y
            }
        }
        ShapePath {
            strokeColor: root.tokens.transparent
            strokeWidth: 0
            startX: root.hueVertex.x
            startY: root.hueVertex.y
            fillGradient: LinearGradient {
                x1: (root.hueVertex.x + root.whiteVertex.x) / 2
                y1: (root.hueVertex.y + root.whiteVertex.y) / 2
                x2: root.blackVertex.x
                y2: root.blackVertex.y
                GradientStop {
                    position: 0.0
                    color: Qt.rgba(0, 0, 0, 0)
                }
                GradientStop {
                    position: 1.0
                    color: Qt.rgba(0, 0, 0, 1)
                }
            }
            PathLine {
                x: root.whiteVertex.x
                y: root.whiteVertex.y
            }
            PathLine {
                x: root.blackVertex.x
                y: root.blackVertex.y
            }
            PathLine {
                x: root.hueVertex.x
                y: root.hueVertex.y
            }
        }
    }

    // SV handle
    Rectangle {
        x: root.handlePosition.x - width / 2
        y: root.handlePosition.y - height / 2
        width: root.tokens.colorPickerTriangleHandleSize
        height: root.tokens.colorPickerTriangleHandleSize
        radius: width / 2
        color: root.tokens.transparent
        border.color: root.tokens.pickerHandleLight
        border.width: root.tokens.colorPickerTriangleHandleBorderWidth
        Rectangle {
            anchors.fill: parent
            anchors.margins: root.tokens.colorPickerTriangleHandleBorderWidth
            radius: width / 2
            color: root.tokens.transparent
            border.color: root.tokens.pickerHandleDark
            border.width: root.tokens.outlineWidth
        }
    }

    Accessible.role: Accessible.Pane
    Accessible.name: qsTr("Saturation and brightness")
    Accessible.description: Math.round(saturation * 100) + "%, " + Math.round(value * 100) + "%"
}
