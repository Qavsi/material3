// Adapted from QmlMaterial 0.6.1 (1912605), MIT.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Shapes
import Qavsi.Material3.Theme

Material3ColorWheelBase {
    id: root
    required property Material3Theme tokens

    readonly property real _cx: width / 2
    readonly property real _cy: height / 2

    implicitWidth: tokens.colorPickerWheelSize
    implicitHeight: tokens.colorPickerWheelSize

    thickness: tokens.colorPickerWheelThickness

    // Hue ring as an annulus filled with conical gradient.
    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: root.tokens.transparent
            strokeWidth: 0
            fillRule: ShapePath.OddEvenFill
            startX: root._cx + root.outerRadius
            startY: root._cy

            PathAngleArc {
                centerX: root._cx
                centerY: root._cy
                radiusX: root.outerRadius
                radiusY: root.outerRadius
                startAngle: 0
                sweepAngle: 360
            }
            PathMove {
                x: root._cx + root.innerRadius
                y: root._cy
            }
            PathAngleArc {
                centerX: root._cx
                centerY: root._cy
                radiusX: root.innerRadius
                radiusY: root.innerRadius
                startAngle: 0
                sweepAngle: 360
            }

            fillGradient: ConicalGradient {
                centerX: root._cx
                centerY: root._cy
                angle: 0
                GradientStop {
                    position: 0.0000
                    color: Qt.hsva(0, 1, 1, 1)
                }
                GradientStop {
                    position: 0.1667
                    color: Qt.hsva(1/6, 1, 1, 1)
                }
                GradientStop {
                    position: 0.3333
                    color: Qt.hsva(2/6, 1, 1, 1)
                }
                GradientStop {
                    position: 0.5000
                    color: Qt.hsva(3/6, 1, 1, 1)
                }
                GradientStop {
                    position: 0.6667
                    color: Qt.hsva(4/6, 1, 1, 1)
                }
                GradientStop {
                    position: 0.8333
                    color: Qt.hsva(5/6, 1, 1, 1)
                }
                GradientStop {
                    position: 1.0000
                    color: Qt.hsva(1, 1, 1, 1)
                }
            }
        }
    }

    // Hue indicator: radial line across the ring (not a circle).
    Item {
        x: root.handlePosition.x - width / 2
        y: root.handlePosition.y - height / 2
        width: root.thickness + root.tokens.colorPickerWheelHandleExtension
        height: root.tokens.colorPickerWheelHandleHeight
        rotation: -root.hue * 360

        Rectangle {
            anchors.fill: parent
            radius: root.tokens.colorPickerWheelHandleRadius
            color: root.tokens.pickerHandleLight
            border.color: root.tokens.pickerHandleDark
            border.width: root.tokens.outlineWidth
        }
    }

    // Inscribed SV triangle — vertices touch the inner edge of the ring.
    Material3ColorTriangle {
        id: m_tri
        tokens: root.tokens
        anchors.centerIn: parent
        width: 2 * root.innerRadius
        height: 2 * root.innerRadius
        hue: root.hue
        saturation: root.saturation
        value: root.value
    }

    triangle: m_tri
    // The inherited value is brightness; avoid exposing it as a hue slider value.
    Accessible.role: Accessible.Pane
    Accessible.name: qsTr("Hue")
    Accessible.description: qsTr("%1 degrees").arg(Math.round(root.hue * 360))
    Accessible.onIncreaseAction: root.requestHue((root.hue + 1 / 360) % 1)
    Accessible.onDecreaseAction: root.requestHue((root.hue - 1 / 360 + 1) % 1)
}
