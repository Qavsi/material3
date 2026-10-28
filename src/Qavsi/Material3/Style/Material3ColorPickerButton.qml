// QCM 0.6.1 ColorPickerButton.qml (MIT), adapted to native StyleKit button/dialog ownership.
pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme
import Qavsi.Icons

SK.Button {
    id: root
    property color color: tokens.primary
    property bool showAlpha: true
    readonly property alias dialog: colorDialog
    readonly property Material3Style sourceStyle: SK.StyleKit.style as Material3Style
    readonly property Material3Theme tokens: sourceStyle?.tokens ?? fallbackTokens
    readonly property Material3Theme fallbackTokens: Material3Theme { }
    readonly property var hostWindow: Window.window
    readonly property bool reduceMotion: sourceStyle?.effectiveReducedMotion ?? true
    readonly property color trailingColor: tokens.colorScheme.paletteTone(color, tokens.colorPickerButtonTrailingTone)
    readonly property color trailingInk: tokens.colorScheme.paletteTone(color, tokens.colorPickerButtonIconTone)
    readonly property color swatchInk: tokens.colorScheme.paletteTone(color, tokens.colorScheme.toneOf(color) > 50 ? 0 : 100)
    readonly property SmallButtonParameters parameters: SmallButtonParameters { tokens: root.tokens; reduceMotion: root.reduceMotion }
    signal accepted(color color)
    implicitWidth: tokens.colorPickerButtonWidth
    implicitHeight: tokens.colorPickerButtonHeight
    leftPadding: 0; rightPadding: 0; topPadding: 0; bottomPadding: 0
    leftInset: 0; rightInset: 0; topInset: 0; bottomInset: 0
    hoverEnabled: enabled
    Accessible.name: qsTr("Select color")
    onClicked: colorDialog.open()
    onVisibleChanged: { if (!visible && colorDialog) colorDialog.close(); }
    onEnabledChanged: { if (!enabled && colorDialog) colorDialog.close(); }
    onHostWindowChanged: { if (colorDialog) colorDialog.close(); }
    onColorChanged: { if (colorDialog?.visible) colorDialog.selectColor(color); }
    contentItem: Item { }
    background: Item {
        Rectangle {
            id: swatch
            anchors { left: parent.left; right: trailing.left; top: parent.top; bottom: parent.bottom; rightMargin: root.tokens.colorPickerButtonGap }
            color: root.color
            topLeftRadius: root.tokens.radiusSmall
            bottomLeftRadius: root.tokens.radiusSmall
            topRightRadius: 0; bottomRightRadius: 0
            Material3Ripple {
                anchors.fill: parent
                control: root
                tokens: root.tokens
                reduceMotion: root.reduceMotion
                rippleColor: root.swatchInk
                cornerRadius: root.tokens.radiusSmall
                cornerRadii: Qt.vector4d(root.tokens.radiusSmall, 0, root.tokens.radiusSmall, 0)
                stateOpacity: root.visualFocus ? root.tokens.interactionOpacity : root.hovered ? root.tokens.hoverOpacity : 0
                pressOpacity: root.tokens.interactionOpacity
                restartOnPress: true
                feedbackEnabled: root.enabled && root.visible && root.Window.window?.visible === true
            }
        }
        Rectangle {
            id: trailing
            anchors { right: parent.right; top: parent.top; bottom: parent.bottom }
            width: height + root.tokens.colorPickerButtonTrailingExtraWidth
            color: root.trailingColor
            topLeftRadius: 0; bottomLeftRadius: 0
            topRightRadius: root.tokens.radiusSmall
            bottomRightRadius: root.tokens.radiusSmall
            Material3Ripple {
                anchors.fill: parent
                control: root
                tokens: root.tokens
                reduceMotion: root.reduceMotion
                rippleColor: root.trailingInk
                cornerRadius: root.tokens.radiusSmall
                cornerRadii: Qt.vector4d(0, root.tokens.radiusSmall, 0, root.tokens.radiusSmall)
                stateOpacity: root.visualFocus ? root.tokens.interactionOpacity : root.hovered ? root.tokens.hoverOpacity : 0
                pressOpacity: root.tokens.interactionOpacity
                restartOnPress: true
                feedbackEnabled: root.enabled && root.visible && root.Window.window?.visible === true
            }
            AppIcon {
                anchors.centerIn: parent
                name: "material:colorize"
                size: root.tokens.colorPickerButtonIconSize
                color: root.trailingInk
                appearance: root.parameters.iconAppearance
                Accessible.ignored: true
            }
        }
        Rectangle {
            anchors { fill: parent; margins: -root.tokens.focusRingGap - root.tokens.focusRingWidth }
            color: root.tokens.transparent
            radius: root.tokens.radiusSmall + root.tokens.focusRingGap
            border { color: root.tokens.primary; width: root.tokens.focusRingWidth }
            visible: root.enabled && root.visualFocus
        }
    }
    Material3ColorPickerDialog {
        id: colorDialog
        selectedColor: root.color
        showAlpha: root.showAlpha
        onAcceptedColor: value => root.accepted(value)
    }
}
