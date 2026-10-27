pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

SK.Theme {
    id: root
    required property Material3Theme tokens
    required property Material3Style sourceStyle
    readonly property Material3TextFieldVariation filledTextField: Material3TextFieldVariation {
        sourceStyle: root.sourceStyle
        name: "textFieldFilled"
        metrics: root.sourceStyle.tokens.textFieldMedium
        filled: true
    }
    readonly property Material3TextFieldVariation outlinedExtraSmallTextField: Material3TextFieldVariation {
        sourceStyle: root.sourceStyle
        name: "textFieldOutlinedExtraSmall"
        metrics: root.sourceStyle.tokens.textFieldExtraSmall
        filled: false
    }
    readonly property Material3TextFieldVariation outlinedSmallTextField: Material3TextFieldVariation {
        sourceStyle: root.sourceStyle
        name: "textFieldOutlinedSmall"
        metrics: root.sourceStyle.tokens.textFieldSmall
        filled: false
    }
    readonly property Material3TextFieldVariation outlinedMediumTextField: Material3TextFieldVariation {
        sourceStyle: root.sourceStyle
        name: "textFieldOutlinedMedium"
        metrics: root.sourceStyle.tokens.textFieldMedium
        filled: false
    }
    readonly property Material3TextFieldVariation outlinedLargeTextField: Material3TextFieldVariation {
        sourceStyle: root.sourceStyle
        name: "textFieldOutlinedLarge"
        metrics: root.sourceStyle.tokens.textFieldLarge
        filled: false
    }
    readonly property Material3TextFieldVariation outlinedExtraLargeTextField: Material3TextFieldVariation {
        sourceStyle: root.sourceStyle
        name: "textFieldOutlinedExtraLarge"
        metrics: root.sourceStyle.tokens.textFieldExtraLarge
        filled: false
    }
    readonly property Material3TextFieldVariation filledExtraSmallTextField: Material3TextFieldVariation {
        sourceStyle: root.sourceStyle
        name: "textFieldFilledExtraSmall"
        metrics: root.sourceStyle.tokens.textFieldExtraSmall
        filled: true
    }
    readonly property Material3TextFieldVariation filledSmallTextField: Material3TextFieldVariation {
        sourceStyle: root.sourceStyle
        name: "textFieldFilledSmall"
        metrics: root.sourceStyle.tokens.textFieldSmall
        filled: true
    }
    readonly property Material3TextFieldVariation filledMediumTextField: Material3TextFieldVariation {
        sourceStyle: root.sourceStyle
        name: "textFieldFilledMedium"
        metrics: root.sourceStyle.tokens.textFieldMedium
        filled: true
    }
    readonly property Material3TextFieldVariation filledLargeTextField: Material3TextFieldVariation {
        sourceStyle: root.sourceStyle
        name: "textFieldFilledLarge"
        metrics: root.sourceStyle.tokens.textFieldLarge
        filled: true
    }
    readonly property Material3TextFieldVariation filledExtraLargeTextField: Material3TextFieldVariation {
        sourceStyle: root.sourceStyle
        name: "textFieldFilledExtraLarge"
        metrics: root.sourceStyle.tokens.textFieldExtraLarge
        filled: true
    }

    textField {
        leftPadding: root.tokens.textFieldHorizontalPadding
        rightPadding: root.tokens.textFieldHorizontalPadding
        topPadding: root.tokens.textFieldVerticalPadding
        bottomPadding: root.tokens.textFieldVerticalPadding
        text {
            color: root.tokens.surfaceForeground
            alignment: Qt.AlignLeft | Qt.AlignVCenter
        }
        background {
            width: root.tokens.textFieldMinimumWidth
            height: root.tokens.textFieldHeight
            radius: root.tokens.textFieldCornerRadius
            color: root.tokens.transparent
            gradient: null
            margins: 0
            border.width: root.tokens.textFieldOutlineWidth
            border.color: root.tokens.outline
            shadow.visible: false
        }
        hovered.background.border.color: root.tokens.surfaceForeground
        focused {
            background.border.width: root.tokens.textFieldFocusedOutlineWidth
            background.border.color: root.tokens.primary
        }
        disabled {
            text.color: root.tokens.disabledLabel
            background.border.color: root.tokens.disabledContainer
        }
    }
}
