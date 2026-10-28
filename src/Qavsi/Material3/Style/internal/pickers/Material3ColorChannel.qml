// QmlMaterial 0.6.1 channel recipe (1912605, MIT), native input and software-safe paint.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme
import Qavsi.Icons

RowLayout {
    id: root
    required property Material3Theme tokens
    required property int channel
    required property string label
    required property string shortLabel
    required property real maximum
    required property real value
    required property color contextColor
    required property real hue
    property int from: 0
    property int to: maximum
    property int step: 1
    signal changeRequested(real value)
    spacing: tokens.spacingSmall
    readonly property color startColor: channel === 1 ? Qt.hsva(hue, 0, contextColor.hsvValue, 1)
        : channel === 2 ? Qt.hsva(hue, contextColor.hsvSaturation, 0, 1)
        : channel === 3 ? Qt.rgba(0, contextColor.g, contextColor.b, 1)
        : channel === 4 ? Qt.rgba(contextColor.r, 0, contextColor.b, 1)
        : channel === 5 ? Qt.rgba(contextColor.r, contextColor.g, 0, 1)
        : Qt.rgba(contextColor.r, contextColor.g, contextColor.b, 0)
    readonly property color endColor: channel === 1 ? Qt.hsva(hue, 1, contextColor.hsvValue, 1)
        : channel === 2 ? Qt.hsva(hue, contextColor.hsvSaturation, 1, 1)
        : channel === 3 ? Qt.rgba(1, contextColor.g, contextColor.b, 1)
        : channel === 4 ? Qt.rgba(contextColor.r, 1, contextColor.b, 1)
        : channel === 5 ? Qt.rgba(contextColor.r, contextColor.g, 1, 1)
        : Qt.rgba(contextColor.r, contextColor.g, contextColor.b, 1)
    SK.Label {
        Layout.preferredWidth: root.tokens.colorPickerChannelLabelWidth
        text: root.shortLabel
        color: root.tokens.surfaceVariantForeground
        font: root.tokens.labelSmall
        horizontalAlignment: Text.AlignHCenter
        Accessible.ignored: true
    }
    SK.Slider {
        id: slider
        Layout.fillWidth: true
        Layout.preferredWidth: root.tokens.colorPickerChannelTrackWidth
        Layout.preferredHeight: root.tokens.colorPickerChannelTrackHeight
        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        bottomPadding: 0
        from: root.from
        to: root.to
        stepSize: root.step
        snapMode: SK.Slider.SnapAlways
        value: root.value
        Accessible.name: root.label
        onMoved: root.changeRequested(value)
        background: Item {
            id: track
            x: slider.leftPadding
            y: slider.topPadding + (slider.availableHeight - height) / 2
            width: slider.availableWidth
            height: root.tokens.colorPickerChannelTrackHeight
            Repeater {
                model: root.channel === 6 ? Math.ceil(track.width / root.tokens.colorPickerCheckerSize)
                    * Math.ceil(track.height / root.tokens.colorPickerCheckerSize) : 0
                delegate: Rectangle {
                    required property int index
                    readonly property int columns: Math.ceil(track.width / root.tokens.colorPickerCheckerSize)
                    x: index % columns * root.tokens.colorPickerCheckerSize
                    y: Math.floor(index / columns) * root.tokens.colorPickerCheckerSize
                    width: Math.min(root.tokens.colorPickerCheckerSize, slider.availableWidth - x)
                    height: Math.min(root.tokens.colorPickerCheckerSize, track.height - y)
                    color: (index % columns + Math.floor(index / columns)) % 2 ? root.tokens.colorPickerCheckerLight : root.tokens.colorPickerCheckerDark
                    Accessible.ignored: true
                }
            }
            Rectangle {
                anchors.fill: parent
                visible: root.channel !== 0
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0; color: root.startColor }
                    GradientStop { position: 1; color: root.endColor }
                }
                Accessible.ignored: true
            }
            Rectangle {
                anchors.fill: parent
                visible: root.channel === 0
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0; color: Qt.hsva(0, 1, 1, 1) }
                    GradientStop { position: 1/6; color: Qt.hsva(1/6, 1, 1, 1) }
                    GradientStop { position: 2/6; color: Qt.hsva(2/6, 1, 1, 1) }
                    GradientStop { position: 3/6; color: Qt.hsva(3/6, 1, 1, 1) }
                    GradientStop { position: 4/6; color: Qt.hsva(4/6, 1, 1, 1) }
                    GradientStop { position: 5/6; color: Qt.hsva(5/6, 1, 1, 1) }
                    GradientStop { position: 1; color: Qt.hsva(1, 1, 1, 1) }
                }
                Accessible.ignored: true
            }
        }
        handle: Rectangle {
            x: slider.leftPadding + slider.visualPosition * slider.availableWidth - width / 2
            y: slider.topPadding + (slider.availableHeight - height) / 2
            implicitWidth: root.tokens.colorPickerChannelIndicatorWidth
            implicitHeight: root.tokens.colorPickerChannelIndicatorHeight
            color: root.channel === 0 ? Qt.hsva(slider.position, 1, 1, 1)
                : root.channel === 6 ? Qt.rgba(root.contextColor.r, root.contextColor.g, root.contextColor.b, slider.position)
                : root.endColor
            border.width: root.tokens.colorPickerChannelIndicatorBorderWidth
            border.color: root.tokens.colorPickerChannelIndicatorBorder
            Rectangle {
                anchors.fill: parent
                color: root.tokens.transparent
                border.width: root.tokens.outlineWidth
                border.color: root.tokens.colorPickerChannelIndicatorOutline
            }
            Accessible.ignored: true
        }
    }
    SK.SpinBox {
        id: number
        Layout.preferredWidth: root.tokens.colorPickerChannelValueWidth
        Layout.preferredHeight: root.tokens.colorPickerChannelValueHeight
        from: root.from
        to: root.to
        stepSize: root.step
        value: Math.round(root.value)
        wrap: root.channel === 0
        editable: true
        leftPadding: root.tokens.colorPickerStepperTextInset
        rightPadding: root.tokens.colorPickerStepperWidth + root.tokens.colorPickerStepperInset * 2
        topPadding: 0
        bottomPadding: 0
        leftInset: 0
        rightInset: 0
        topInset: 0
        bottomInset: 0
        font: root.tokens.labelSmall
        Accessible.name: qsTr("%1 value").arg(root.label)
        onValueModified: root.changeRequested(value)
        contentItem: TextInput {
            text: number.displayText
            font: number.font
            color: root.tokens.surfaceForeground
            selectionColor: number.palette.highlight
            selectedTextColor: number.palette.highlightedText
            horizontalAlignment: TextInput.AlignRight
            verticalAlignment: TextInput.AlignVCenter
            readOnly: !number.editable
            validator: number.validator
            inputMethodHints: Qt.ImhDigitsOnly
            selectByMouse: true
            clip: true
        }
        background: Rectangle {
            color: root.tokens.surfaceContainerHighest
            radius: root.tokens.radiusExtraSmall
        }
        up.indicator: Rectangle {
            x: number.width - width - root.tokens.colorPickerStepperInset
            y: root.tokens.colorPickerStepperInset
            width: root.tokens.colorPickerStepperWidth
            height: (number.height - root.tokens.colorPickerStepperInset * 2) / 2
            color: Qt.rgba(root.tokens.surfaceForeground.r, root.tokens.surfaceForeground.g, root.tokens.surfaceForeground.b, number.up.pressed ? root.tokens.rippleOpacity : number.up.hovered ? root.tokens.hoverOpacity : 0)
            radius: root.tokens.radiusExtraSmall
            AppIcon {
                anchors.centerIn: parent
                name: "material:arrow_drop_up"
                size: root.tokens.colorPickerStepperIconSize
                color: root.tokens.surfaceVariantForeground
            }
        }
        down.indicator: Rectangle {
            x: number.width - width - root.tokens.colorPickerStepperInset
            y: number.height / 2
            width: root.tokens.colorPickerStepperWidth
            height: (number.height - root.tokens.colorPickerStepperInset * 2) / 2
            color: Qt.rgba(root.tokens.surfaceForeground.r, root.tokens.surfaceForeground.g, root.tokens.surfaceForeground.b, number.down.pressed ? root.tokens.rippleOpacity : number.down.hovered ? root.tokens.hoverOpacity : 0)
            radius: root.tokens.radiusExtraSmall
            AppIcon {
                anchors.centerIn: parent
                name: "material:arrow_drop_down"
                size: root.tokens.colorPickerStepperIconSize
                color: root.tokens.surfaceVariantForeground
            }
        }
    }
}
