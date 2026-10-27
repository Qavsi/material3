pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Templates as T
import Qavsi.Material3.Theme
import Qavsi.Icons

Item {
    id: root
    required property T.TextField control
    required property Material3Theme tokens
    required property var metrics
    required property bool filled
    required property QtObject iconAppearance
    required property point surfaceOrigin
    required property real placeholderWidth
    readonly property TextFieldSupport support: control.TextFieldSupport
    readonly property bool mirrored: control.LayoutMirroring.enabled
    readonly property bool floated: control.activeFocus || control.length > 0 || control.preeditText.length > 0
    readonly property bool showPrefix: support.prefix.length > 0 && (control.placeholderText.length === 0 || floated)
    readonly property bool showSuffix: support.suffix.length > 0 && (control.placeholderText.length === 0 || floated)
    readonly property bool hasLeading: support.leadingIcon.length > 0
    readonly property bool hasTrailing: support.trailingIcon.length > 0
    readonly property bool hasAdornments: hasLeading || hasTrailing || support.prefix.length > 0 || support.suffix.length > 0
    readonly property real leadingExtent: hasLeading ? metrics.iconSize + metrics.spacing : 0
    readonly property real trailingExtent: hasTrailing ? metrics.iconSize + metrics.spacing : 0
    readonly property real affixAvailableWidth: Math.max(0, width - root.metrics.horizontalPadding - root.metrics.horizontalPadding
        - leadingExtent - trailingExtent - ((showPrefix ? 1 : 0) + (showSuffix ? 1 : 0)) * tokens.textFieldAffixSpacing)
    readonly property real prefixExtent: showPrefix ? prefixLabel.width + tokens.textFieldAffixSpacing : 0
    readonly property real suffixExtent: showSuffix ? suffixLabel.width + tokens.textFieldAffixSpacing : 0
    readonly property real leftAffixExtent: mirrored ? suffixExtent : prefixExtent
    readonly property real rightAffixExtent: mirrored ? prefixExtent : suffixExtent
    readonly property real minimumWidth: Math.max(root.tokens.textFieldMinimumWidth,
        root.metrics.horizontalPadding + root.metrics.horizontalPadding + leadingExtent + trailingExtent
        + Math.max(placeholderWidth, control.contentWidth
            + (showPrefix ? prefixLabel.implicitWidth + tokens.textFieldAffixSpacing : 0)
            + (showSuffix ? suffixLabel.implicitWidth + tokens.textFieldAffixSpacing : 0)))
    readonly property string supportingText: support.error && support.errorText.length > 0 ? support.errorText : support.supportingText
    readonly property real inputBottomPadding: filled ? metrics.verticalPadding / 2 : metrics.verticalPadding
    readonly property real supportingHeight: supportingText.length > 0 ? supportLabel.implicitHeight + tokens.textFieldSupportingTopPadding : 0
    readonly property string accessibleDescription: ((support.prefix.length > 0 ? support.prefix + " " : "")
        + (support.suffix.length > 0 ? support.suffix + " " : "") + supportingText).trim()
    // TextInput's baseline excludes its vertical alignment offset; its cursor rectangle includes it.
    readonly property real inputBaseline: control.baselineOffset + control.cursorRectangle.y - control.topPadding
    readonly property color affixColor: control.enabled ? tokens.surfaceVariantForeground : tokens.disabledLabel
    Accessible.ignored: true
    LayoutMirroring.enabled: false
    LayoutMirroring.childrenInherit: false

    Material3TextFieldBinding {
        target: root.control; property: "leftPadding"
        defaultValue: root.metrics.horizontalPadding
        requested: (root.mirrored ? root.trailingExtent : root.leadingExtent) + root.leftAffixExtent > 0
        value: root.metrics.horizontalPadding + (root.mirrored ? root.trailingExtent : root.leadingExtent) + root.leftAffixExtent
    }
    Material3TextFieldBinding {
        target: root.control; property: "rightPadding"
        defaultValue: root.metrics.horizontalPadding
        requested: (root.mirrored ? root.leadingExtent : root.trailingExtent) + root.rightAffixExtent > 0
        value: root.metrics.horizontalPadding + (root.mirrored ? root.leadingExtent : root.trailingExtent) + root.rightAffixExtent
    }
    Material3TextFieldBinding {
        target: root.control; property: "bottomPadding"
        defaultValue: root.inputBottomPadding
        requested: root.supportingHeight > 0
        value: root.inputBottomPadding + root.supportingHeight
    }
    Material3TextFieldBinding {
        target: root.control; property: "bottomInset"
        defaultValue: 0
        requested: root.supportingHeight > 0
        value: root.supportingHeight
    }
    Material3TextFieldBinding {
        target: root.control.background; property: "implicitWidth"
        defaultValue: root.tokens.textFieldMinimumWidth
        requested: root.hasAdornments
        value: root.minimumWidth
    }
    Material3TextFieldBinding {
        target: root.control.Accessible; property: "name"
        defaultValue: ""
        requested: root.control.placeholderText.length > 0
        value: root.control.placeholderText
    }
    Material3TextFieldBinding {
        id: descriptionBinding
        target: root.control.Accessible; property: "description"
        defaultValue: ""
        // Native TextField supplies the placeholder when accessibility is active.
        atDefault: descriptionBinding.currentValue === descriptionBinding.defaultValue
            || descriptionBinding.currentValue === root.control.placeholderText
        requested: root.accessibleDescription.length > 0
        value: root.accessibleDescription
    }
    AppIcon {
        name: root.support.leadingIcon
        size: root.metrics.iconSize
        color: root.affixColor
        appearance: root.iconAppearance
        visible: root.hasLeading
        x: (root.mirrored ? root.control.width - root.metrics.horizontalPadding - width : root.metrics.horizontalPadding) - root.surfaceOrigin.x
        y: (root.height - height) / 2
    }
    AppIcon {
        name: root.support.trailingIcon
        size: root.metrics.iconSize
        color: !root.control.enabled ? root.tokens.disabledLabel : root.support.error ? root.tokens.error : root.affixColor
        appearance: root.iconAppearance
        visible: root.hasTrailing
        x: (root.mirrored ? root.metrics.horizontalPadding : root.control.width - root.metrics.horizontalPadding - width) - root.surfaceOrigin.x
        y: (root.height - height) / 2
    }
    Text {
        id: prefixLabel
        text: root.support.prefix
        textFormat: Text.PlainText
        font: root.control.font
        renderType: root.control.renderType
        color: root.affixColor
        visible: root.showPrefix
        width: Math.min(implicitWidth, root.affixAvailableWidth)
        elide: Text.ElideRight
        x: (root.mirrored ? root.control.width - root.control.rightPadding + root.tokens.textFieldAffixSpacing
            : root.control.leftPadding - width - root.tokens.textFieldAffixSpacing) - root.surfaceOrigin.x
        y: root.inputBaseline - root.surfaceOrigin.y - baselineOffset
        Accessible.ignored: true
    }
    Text {
        id: suffixLabel
        text: root.support.suffix
        textFormat: Text.PlainText
        font: root.control.font
        renderType: root.control.renderType
        color: root.affixColor
        visible: root.showSuffix
        width: Math.min(implicitWidth, Math.max(0, root.affixAvailableWidth - (root.showPrefix ? prefixLabel.width : 0)))
        elide: Text.ElideRight
        x: (root.mirrored ? root.control.leftPadding - width - root.tokens.textFieldAffixSpacing
            : root.control.width - root.control.rightPadding + root.tokens.textFieldAffixSpacing) - root.surfaceOrigin.x
        y: root.inputBaseline - root.surfaceOrigin.y - baselineOffset
        Accessible.ignored: true
    }
    Text {
        id: supportLabel
        text: root.supportingText
        textFormat: Text.PlainText
        font: root.tokens.bodySmall
        renderType: root.control.renderType
        lineHeightMode: Text.FixedHeight
        lineHeight: root.tokens.bodySmallLineHeight
        color: !root.control.enabled ? root.tokens.disabledLabel
            : root.support.error ? root.tokens.error : root.tokens.surfaceVariantForeground
        visible: text.length > 0
        x: root.metrics.horizontalPadding - root.surfaceOrigin.x
        y: root.height + root.tokens.textFieldSupportingTopPadding
        width: Math.max(0, root.control.width - root.metrics.horizontalPadding - root.metrics.horizontalPadding)
        horizontalAlignment: root.mirrored ? Text.AlignRight : Text.AlignLeft
        wrapMode: Text.Wrap
        Accessible.ignored: true
    }
}
