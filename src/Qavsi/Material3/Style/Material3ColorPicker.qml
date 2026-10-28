// Adapted from QmlMaterial 0.6.1 (1912605, MIT); controlled native Qt inputs.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

SK.Control {
    id: root
    enum Mode { Hsv, Rgb }
    property color color: tokens.primary
    property bool showAlpha: true
    property bool showHeader: true
    property int mode: Material3ColorPicker.Hsv
    readonly property Material3Theme tokens: (SK.StyleKit.style as Material3Style)?.tokens ?? fallbackTokens
    readonly property Material3Theme fallbackTokens: Material3Theme { }
    property real _hue: 0
    readonly property real hue: color.hsvHue >= 0 ? color.hsvHue : _hue
    readonly property string hexText: "#" + byteHex(color.r) + byteHex(color.g) + byteHex(color.b) + (showAlpha ? byteHex(color.a) : "")
    signal colorChangeRequested(color value)
    implicitWidth: contentItem.implicitWidth + leftPadding + rightPadding
    implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding
    leftPadding: tokens.colorPickerPadding
    rightPadding: tokens.colorPickerPadding
    topPadding: 0
    bottomPadding: 0
    background: null
    onColorChanged: { if (color.hsvHue >= 0) _hue = color.hsvHue; }
    Component.onCompleted: { if (color.hsvHue >= 0) _hue = color.hsvHue; }
    function byteHex(value: real): string { return Math.round(value * 255).toString(16).padStart(2, "0").toUpperCase(); }
    function bounded(value: real): real { return Math.max(0, Math.min(1, value)); }
    function setColor(value: color): void { colorChangeRequested(value); }
    function setHue(value: real): void {
        if (!isFinite(value)) return;
        _hue = bounded(value);
        colorChangeRequested(Qt.hsva(_hue, color.hsvSaturation, color.hsvValue, color.a));
    }
    function setSaturation(value: real): void {
        if (isFinite(value)) colorChangeRequested(Qt.hsva(hue, bounded(value), color.hsvValue, color.a));
    }
    function setValue(value: real): void {
        if (isFinite(value)) colorChangeRequested(Qt.hsva(hue, color.hsvSaturation, bounded(value), color.a));
    }
    function setSV(saturation: real, value: real): void {
        if (isFinite(saturation) && isFinite(value))
            colorChangeRequested(Qt.hsva(hue, bounded(saturation), bounded(value), color.a));
    }
    function setAlpha(value: real): void {
        if (isFinite(value)) colorChangeRequested(Qt.rgba(color.r, color.g, color.b, bounded(value)));
    }
    function setR(value: real): void {
        if (isFinite(value)) colorChangeRequested(Qt.rgba(bounded(value), color.g, color.b, color.a));
    }
    function setG(value: real): void {
        if (isFinite(value)) colorChangeRequested(Qt.rgba(color.r, bounded(value), color.b, color.a));
    }
    function setB(value: real): void {
        if (isFinite(value)) colorChangeRequested(Qt.rgba(color.r, color.g, bounded(value), color.a));
    }
    function setHex(value: string): bool {
        if (!/^#[0-9a-fA-F]{6}([0-9a-fA-F]{2})?$/.test(value)) return false;
        const alpha = value.length === 9 ? parseInt(value.slice(7, 9), 16) / 255 : color.a;
        colorChangeRequested(Qt.rgba(parseInt(value.slice(1, 3), 16) / 255,
            parseInt(value.slice(3, 5), 16) / 255, parseInt(value.slice(5, 7), 16) / 255, alpha));
        return true;
    }
    contentItem: ColumnLayout {
        spacing: root.tokens.colorPickerSpacing
        Material3ColorWheel {
            Layout.alignment: Qt.AlignHCenter
            visible: root.showHeader
            tokens: root.tokens
            hue: root.hue
            saturation: root.color.hsvSaturation
            value: root.color.hsvValue
            onHueChangeRequested: value => root.setHue(value)
            onSvChangeRequested: (saturation, value) => root.setSV(saturation, value)
        }
        RowLayout {
            Layout.fillWidth: true
            spacing: root.tokens.spacingSmall
            SK.Button {
                id: hexChip
                text: root.hexText
                Accessible.name: qsTr("Hex color %1").arg(root.hexText)
                leftPadding: root.tokens.chipPadding + root.tokens.colorPickerSwatchSize + root.tokens.chipSpacing
                SK.StyleVariation.variations: ["chipInput"]
                contentItem: Material3ChipContent { control: hexChip }
                Rectangle {
                    x: root.tokens.chipPadding
                    y: (parent.height - height) / 2
                    width: root.tokens.colorPickerSwatchSize
                    height: width
                    radius: root.tokens.radiusExtraSmall
                    color: root.color
                    border.color: root.tokens.colorPickerSwatchOutline
                    border.width: root.tokens.outlineWidth
                    Accessible.ignored: true
                }
            }
            Item { Layout.fillWidth: true }
            RowLayout {
                spacing: 0
                SK.Button {
                    id: hsvButton
                    contentItem: Material3ButtonContent { control: hsvButton }
                    text: qsTr("HSV")
                    checked: root.mode === Material3ColorPicker.Hsv
                    SK.StyleVariation.variations: ["segmentedExtraSmallLeading", "outline"]
                    onClicked: root.mode = Material3ColorPicker.Hsv
                }
                SK.Button {
                    id: rgbButton
                    contentItem: Material3ButtonContent { control: rgbButton }
                    text: qsTr("RGB")
                    checked: root.mode === Material3ColorPicker.Rgb
                    SK.StyleVariation.variations: ["segmentedExtraSmallTrailing", "outline"]
                    onClicked: root.mode = Material3ColorPicker.Rgb
                }
            }
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: root.tokens.colorPickerChannelRowSpacing
            Repeater {
                model: root.mode === Material3ColorPicker.Hsv
                    ? [{label: qsTr("Hue"), shortLabel: "H", channel: 0, maximum: 360},
                       {label: qsTr("Saturation"), shortLabel: "S", channel: 1, maximum: 100},
                       {label: qsTr("Value"), shortLabel: "V", channel: 2, maximum: 100}]
                    : [{label: qsTr("Red"), shortLabel: "R", channel: 3, maximum: 255},
                       {label: qsTr("Green"), shortLabel: "G", channel: 4, maximum: 255},
                       {label: qsTr("Blue"), shortLabel: "B", channel: 5, maximum: 255}]
                delegate: Material3ColorChannel {
                    required property var modelData
                    Layout.fillWidth: true
                    tokens: root.tokens
                    channel: modelData.channel
                    label: modelData.label
                    shortLabel: modelData.shortLabel
                    maximum: modelData.maximum
                    value: Math.round([root.hue * 360, root.color.hsvSaturation * 100, root.color.hsvValue * 100,
                        root.color.r * 255, root.color.g * 255, root.color.b * 255][channel])
                    contextColor: root.color
                    hue: root.hue
                    onChangeRequested: value => {
                        if (channel === 0) root.setHue(value / maximum);
                        else if (channel === 1) root.setSaturation(value / maximum);
                        else if (channel === 2) root.setValue(value / maximum);
                        else if (channel === 3) root.setR(value / maximum);
                        else if (channel === 4) root.setG(value / maximum);
                        else root.setB(value / maximum);
                    }
                }
            }
            Material3ColorChannel {
                Layout.fillWidth: true
                visible: root.showAlpha
                tokens: root.tokens
                channel: 6
                label: qsTr("Alpha")
                shortLabel: "A"
                maximum: 255
                value: Math.round(root.color.a * 255)
                contextColor: root.color
                hue: root.hue
                onChangeRequested: value => root.setAlpha(value / maximum)
            }
        }
    }
}
