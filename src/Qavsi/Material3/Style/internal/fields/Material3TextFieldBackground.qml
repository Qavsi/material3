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
    readonly property bool filled: parameters.filled
    readonly property bool invalid: control.enabled && control.TextFieldSupport.error
    readonly property Material3TextFieldDecorations decorations: accessories.item as Material3TextFieldDecorations
    readonly property bool labelEnabled: managesPlaceholder && control.placeholderText.length > 0
    readonly property bool floating: labelEnabled
        && (control.activeFocus || control.length > 0 || control.preeditText.length > 0)
    readonly property bool canAnimate: ready && visible && root.Window.window
        && root.Window.window.visible && root.Window.window.visibility !== Window.Minimized
        && root.SK.StyleKit.transitionsEnabled && !parameters.reducedMotion
    readonly property point surfaceOrigin: Qt.point(control.background.x + parent.x + x,
        control.background.y + parent.y + y)
    readonly property real contentWidth: Math.max(0, control.width - control.leftPadding - control.rightPadding
        + (decorations?.leftAffixExtent ?? 0) + (decorations?.rightAffixExtent ?? 0))
    readonly property real contentHeight: Math.max(0, control.height - control.topPadding - control.bottomPadding)
    readonly property real halfStroke: outline.halfStroke
    readonly property color strokeColor: invalid ? tokens.error : delegateStyle.border.color
    readonly property real gapWidth: labelEnabled
        ? (caption.width * caption.scale + 2 * tokens.textFieldLabelGapPadding) * floatProgress : 0
    readonly property real gapCenter: caption.x + caption.width * caption.scale / 2
    property real floatProgress: floating ? 1 : 0
    property bool managesPlaceholder: false
    property bool ready: false

    width: parent.width
    height: parent.height
    implicitWidth: delegateStyle.width
    implicitHeight: delegateStyle.height
    visible: delegateStyle.visible
    opacity: delegateStyle.opacity
    Accessible.ignored: true

    Component.onCompleted: {
        managesPlaceholder = control.placeholderTextColor === control.palette.placeholderText
        ready = true
    }
    // Restore the stock binding before StyleKit releases the control's context.
    Component.onDestruction: placeholderBinding.when = false
    onCanAnimateChanged: if (!canAnimate) labelAnimation.complete()

    // Qt 6.12's TextField reads its native palette instead of StyleKit's field palette.
    Binding {
        id: placeholderBinding
        target: root.control
        property: "placeholderTextColor"
        value: root.tokens.transparent
        when: root.managesPlaceholder && root.control.placeholderText.length > 0
    }
    Connections {
        target: root.control
        function onPlaceholderTextColorChanged() {
            if (!root.ready || !placeholderBinding.when || root.control.placeholderTextColor.a === 0)
                return
            // A later caller color binding opts out without restoring over that binding.
            placeholderBinding.restoreMode = Binding.RestoreNone
            root.managesPlaceholder = false
        }
    }
    Material3TextFieldBinding {
        target: root.control; property: "font"
        defaultValue: root.tokens.bodyLarge
        value: root.parameters.metrics.font
        requested: root.parameters.metrics !== root.tokens.textFieldMedium
    }
    Behavior on floatProgress {
        enabled: root.canAnimate
        NumberAnimation {
            id: labelAnimation
            duration: root.tokens.textFieldLabelDuration
            easing.type: Easing.BezierSpline
            easing.bezierCurve: root.tokens.textFieldLabelEasingCurve
        }
    }

    Loader {
        id: accessories
        z: 1
        anchors.fill: parent
        active: root.control.TextFieldSupport.prefix.length > 0 || root.control.TextFieldSupport.suffix.length > 0
            || root.control.TextFieldSupport.leadingIcon.length > 0 || root.control.TextFieldSupport.trailingIcon.length > 0
            || root.control.TextFieldSupport.supportingText.length > 0 || root.control.TextFieldSupport.errorText.length > 0
        sourceComponent: Component {
            Material3TextFieldDecorations {
                control: root.control
                tokens: root.tokens
                metrics: root.parameters.metrics
                filled: root.filled
                iconAppearance: root.parameters.iconAppearance
                surfaceOrigin: root.surfaceOrigin
                placeholderWidth: caption.implicitWidth
            }
        }
    }
    Rectangle {
        anchors.fill: parent
        visible: root.filled
        color: root.delegateStyle.color
        topLeftRadius: root.delegateStyle.topLeftRadius
        topRightRadius: root.delegateStyle.topRightRadius
        bottomLeftRadius: 0
        bottomRightRadius: 0
    }
    Material3FieldOutline {
        id: outline
        anchors.fill: parent
        visible: !root.filled
        strokeColor: root.strokeColor
        strokeWidth: root.delegateStyle.border.width
        fillColor: root.tokens.transparent
        radius: root.delegateStyle.radius
        gapWidth: root.gapWidth
        gapCenter: root.gapCenter
    }
    Rectangle {
        width: root.width
        height: root.delegateStyle.border.width
        y: root.height - height
        color: root.strokeColor
        visible: root.filled
    }
    Text {
        id: caption
        readonly property real visualWidth: width * scale
        readonly property real leadingX: root.control.leftPadding - (root.decorations?.leftAffixExtent ?? 0) - root.surfaceOrigin.x
        readonly property real restX: leadingX
            + (root.control.effectiveHorizontalAlignment === TextInput.AlignRight ? root.contentWidth - visualWidth
               : root.control.effectiveHorizontalAlignment === TextInput.AlignHCenter ? (root.contentWidth - visualWidth) / 2 : 0)
        readonly property real restY: root.filled ? (root.height - height * scale) / 2
            : root.control.topPadding - root.surfaceOrigin.y
              + (root.control.verticalAlignment === TextInput.AlignBottom ? root.contentHeight - height * scale
                 : root.control.verticalAlignment === TextInput.AlignVCenter ? (root.contentHeight - height * scale) / 2 : 0)
        readonly property real floatX: leadingX
            + (root.control.effectiveHorizontalAlignment === TextInput.AlignRight ? root.contentWidth - visualWidth : 0)
        text: root.control.placeholderText
        textFormat: Text.PlainText
        font: root.control.font
        color: !root.control.enabled ? root.tokens.disabledLabel
            : root.invalid ? root.tokens.error
            : root.control.activeFocus ? root.tokens.primary
            : root.control.hovered ? root.tokens.surfaceForeground : root.tokens.surfaceVariantForeground
        width: Math.min(implicitWidth, root.contentWidth / scale)
        x: restX + (floatX - restX) * root.floatProgress
        y: restY + ((root.filled ? root.parameters.metrics.verticalPadding / 2
            : root.halfStroke - height * scale / 2) - restY) * root.floatProgress
        scale: 1 + (root.tokens.textFieldLabelScale - 1) * root.floatProgress
        transformOrigin: Item.TopLeft
        visible: root.labelEnabled
        elide: Text.ElideRight
        renderType: root.control.renderType
        LayoutMirroring.enabled: false
        Accessible.ignored: true
    }
}
