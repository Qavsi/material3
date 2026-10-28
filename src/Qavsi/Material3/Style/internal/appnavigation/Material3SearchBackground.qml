pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Templates as T
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

Item {
    id: root
    required property T.TextField control
    required property SK.DelegateStyle delegateStyle
    readonly property Material3TextFieldParameters parameters: delegateStyle.data as Material3TextFieldParameters
    readonly property Material3Theme tokens: parameters.tokens
    width: parent.width
    height: parent.height
    implicitWidth: delegateStyle.width
    implicitHeight: delegateStyle.height
    visible: delegateStyle.visible
    opacity: delegateStyle.opacity
    Accessible.ignored: true
    // Native TextField reads its palette instead of the StyleKit field colors.
    Material3TextFieldBinding {
        target: root.control
        property: "placeholderTextColor"
        defaultValue: root.control.palette.placeholderText
        value: root.control.enabled ? root.tokens.surfaceVariantForeground : root.tokens.disabledLabel
    }
    Rectangle {
        anchors.fill: parent
        radius: root.tokens.searchHeight / 2
        color: root.delegateStyle.color
        antialiasing: true
    }
    Rectangle {
        anchors.fill: parent
        radius: root.tokens.searchHeight / 2
        color: root.tokens.surfaceForeground
        opacity: !root.control.enabled ? 0 : root.control.activeFocus ? root.tokens.interactionOpacity
            : root.control.hovered ? root.tokens.hoverOpacity : 0
        antialiasing: true
    }
    Rectangle {
        anchors.fill: parent
        anchors.margins: -root.tokens.focusRingGap - root.tokens.focusRingWidth
        radius: height / 2
        color: root.tokens.transparent
        border.color: root.tokens.primary
        border.width: root.tokens.focusRingWidth
        visible: root.control.activeFocus && root.control.focusReason === Qt.TabFocusReason
        antialiasing: true
    }
    Material3TextFieldDecorations {
        anchors.fill: parent
        control: root.control
        tokens: root.tokens
        metrics: root.parameters.metrics
        filled: false
        iconAppearance: root.parameters.iconAppearance
        surfaceOrigin: Qt.point(root.control.background.x + root.parent.x + root.x,
            root.control.background.y + root.parent.y + root.y)
        placeholderWidth: 0
    }
}
