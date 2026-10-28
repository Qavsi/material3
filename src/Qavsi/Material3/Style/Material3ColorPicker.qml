// QmlMaterial 0.6.1 RGB channel recipe (1912605, MIT), using native sliders.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Qt.labs.StyleKit as SK

Material3PickerDialog {
    id: root
    property color selectedColor: tokens.primary
    property color currentColor: selectedColor
    signal acceptedColor(color color)
    title: qsTr("Select color")
    implicitWidth: root.tokens.pickerWidth
    function selectColor(value: color): void { currentColor = value; }
    onAboutToShow: currentColor = selectedColor
    onAccepted: acceptedColor(currentColor)
    contentItem: ColumnLayout {
        spacing: root.tokens.spacingSmall
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: root.tokens.pickerDaySize
            radius: root.tokens.radiusSmall
            color: root.currentColor
            border.color: root.tokens.surfaceVariantForeground
            Accessible.ignored: true
        }
        Repeater {
            model: [qsTr("Red"), qsTr("Green"), qsTr("Blue"), qsTr("Alpha")]
            delegate: RowLayout {
                id: channel
                required property int index
                required property string modelData
                Layout.fillWidth: true
                SK.Label { text: channel.modelData; color: root.tokens.surfaceForeground }
                SK.Slider {
                    Layout.fillWidth: true
                    from: 0
                    to: 255
                    stepSize: 1
                    value: [root.currentColor.r, root.currentColor.g, root.currentColor.b, root.currentColor.a][channel.index] * 255
                    Accessible.name: channel.modelData
                    onMoved: {
                        const values = [root.currentColor.r, root.currentColor.g, root.currentColor.b, root.currentColor.a];
                        values[channel.index] = value / 255;
                        root.selectColor(Qt.rgba(values[0], values[1], values[2], values[3]));
                    }
                }
            }
        }
        SK.TextField {
            Layout.fillWidth: true
            text: root.currentColor.toString()
            Accessible.name: qsTr("Hex color, #RRGGBB or #AARRGGBB")
            validator: RegularExpressionValidator { regularExpression: /#[0-9a-fA-F]{6}([0-9a-fA-F]{2})?/ }
            onEditingFinished: {
                if (acceptableInput)
                    root.selectColor(text);
                text = Qt.binding(() => root.currentColor.toString());
            }
        }
    }
}
