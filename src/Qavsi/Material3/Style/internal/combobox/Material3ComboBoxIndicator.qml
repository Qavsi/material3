pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Shapes
import QtQuick.Templates as T
import Qt.labs.StyleKit as SK

Item {
    id: root
    required property T.ComboBox control
    required property SK.DelegateStyle delegateStyle

    objectName: "material3.combobox.indicator"
    width: parent.width
    height: parent.height
    implicitWidth: delegateStyle.width
    implicitHeight: delegateStyle.height
    visible: delegateStyle.visible
    opacity: delegateStyle.opacity
    Accessible.ignored: true

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer
        ShapePath {
            strokeWidth: 0
            fillColor: root.delegateStyle.color
            startX: root.width * 7 / 24
            startY: root.height * 10 / 24
            PathLine { x: root.width / 2; y: root.height * 15 / 24 }
            PathLine { x: root.width * 17 / 24; y: root.height * 10 / 24 }
            PathLine { x: root.width * 7 / 24; y: root.height * 10 / 24 }
        }
    }
}
