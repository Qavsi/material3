pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Templates as T
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

Item {
    id: root
    required property T.ComboBox control
    required property SK.DelegateStyle delegateStyle
    readonly property Material3ComboBoxParameters parameters: delegateStyle.data as Material3ComboBoxParameters
    readonly property Material3Theme tokens: parameters.tokens
    readonly property TextInput nativeInput: control.contentItem as TextInput
    readonly property bool invalid: control.enabled && !control.acceptableInput
    readonly property bool labelEnabled: control.ComboBoxSupport.label.length > 0
    readonly property bool floating: labelEnabled && (control.activeFocus || (control.editable ? control.editText : control.displayText).length > 0)
    readonly property bool canAnimate: ready && visible && root.Window.window
        && root.Window.window.visible && root.Window.window.visibility !== Window.Minimized
        && root.SK.StyleKit.transitionsEnabled && !parameters.reducedMotion
    readonly property point surfaceOrigin: Qt.point(control.background.x + parent.x + x,
        control.background.y + parent.y + y)
    readonly property real contentWidth: Math.max(0, control.width - control.leftPadding - control.rightPadding)
    readonly property real contentHeight: Math.max(0, control.height - control.topPadding - control.bottomPadding)
    readonly property int horizontalAlignment: nativeInput?.effectiveHorizontalAlignment
        ?? (control.mirrored ? TextInput.AlignRight : TextInput.AlignLeft)
    readonly property int verticalAlignment: nativeInput?.verticalAlignment ?? TextInput.AlignVCenter
    property real floatProgress: floating ? 1 : 0
    property bool ready: false

    objectName: "material3.combobox.background"
    width: parent.width
    height: parent.height
    implicitWidth: delegateStyle.width
    implicitHeight: delegateStyle.height
    visible: delegateStyle.visible
    opacity: delegateStyle.opacity
    Accessible.ignored: true

    Component.onCompleted: ready = true
    onCanAnimateChanged: if (!canAnimate) labelAnimation.complete()

    Behavior on floatProgress {
        enabled: root.canAnimate
        NumberAnimation {
            id: labelAnimation
            duration: root.tokens.textFieldLabelDuration
            easing.type: Easing.BezierSpline
            easing.bezierCurve: root.tokens.textFieldLabelEasingCurve
        }
    }
    Material3TextFieldBinding {
        target: root.control
        property: "font"
        defaultValue: root.tokens.bodyLarge
        requested: root.parameters.metrics !== root.tokens.comboBoxMedium
        value: root.parameters.metrics.font
    }
    Material3ComboBoxBridge {
        control: root.control
        parameters: root.parameters
    }
    Material3FieldOutline {
        id: outline
        anchors.fill: parent
        strokeColor: root.invalid ? root.tokens.error : root.delegateStyle.border.color
        strokeWidth: root.delegateStyle.border.width
        fillColor: root.tokens.transparent
        radius: root.delegateStyle.radius
        gapWidth: root.labelEnabled
            ? (caption.width * caption.scale + 2 * root.tokens.textFieldLabelGapPadding) * root.floatProgress : 0
        gapCenter: caption.x + caption.width * caption.scale / 2
    }
    Text {
        id: caption
        readonly property real visualWidth: width * scale
        readonly property real leadingX: root.control.leftPadding - root.surfaceOrigin.x
        readonly property real restX: leadingX
            + (root.horizontalAlignment === TextInput.AlignRight ? root.contentWidth - visualWidth
               : root.horizontalAlignment === TextInput.AlignHCenter ? (root.contentWidth - visualWidth) / 2 : 0)
        readonly property real restY: root.control.topPadding - root.surfaceOrigin.y
            + (root.verticalAlignment === TextInput.AlignBottom ? root.contentHeight - height * scale
               : root.verticalAlignment === TextInput.AlignVCenter ? (root.contentHeight - height * scale) / 2 : 0)
        readonly property real floatX: leadingX + (root.control.mirrored ? root.contentWidth - visualWidth : 0)

        objectName: "material3.combobox.caption"
        text: root.control.ComboBoxSupport.label
        textFormat: Text.PlainText
        font: root.control.font
        color: !root.control.enabled ? root.tokens.disabledLabel
            : root.invalid ? root.tokens.error
            : root.control.activeFocus ? root.tokens.primary
            : root.control.hovered ? root.tokens.surfaceForeground : root.tokens.surfaceVariantForeground
        width: Math.min(implicitWidth, root.contentWidth / scale)
        x: restX + (floatX - restX) * root.floatProgress
        y: restY + (outline.halfStroke - height * scale / 2 - restY) * root.floatProgress
        scale: 1 + (root.tokens.textFieldLabelScale - 1) * root.floatProgress
        transformOrigin: Item.TopLeft
        visible: root.labelEnabled
        elide: Text.ElideRight
        renderType: root.nativeInput?.renderType ?? Text.QtRendering
        LayoutMirroring.enabled: false
        Accessible.ignored: true
    }
}
