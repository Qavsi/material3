pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

QtObject {
    id: root
    required property Material3Style sourceStyle
    property Material3Theme tokens: sourceStyle.tokens
    readonly property Material3TextFieldVariation filledTextField: Material3TextFieldVariation {
        sourceStyle: root.sourceStyle
        tokens: root.tokens
        name: "textFieldFilled"
        metrics: root.tokens.textFieldMedium
        filled: true
    }
    readonly property Material3TextFieldVariation outlinedExtraSmallTextField: Material3TextFieldVariation {
        sourceStyle: root.sourceStyle
        tokens: root.tokens
        name: "textFieldOutlinedExtraSmall"
        metrics: root.tokens.textFieldExtraSmall
        filled: false
    }
    readonly property Material3TextFieldVariation outlinedSmallTextField: Material3TextFieldVariation {
        sourceStyle: root.sourceStyle
        tokens: root.tokens
        name: "textFieldOutlinedSmall"
        metrics: root.tokens.textFieldSmall
        filled: false
    }
    readonly property Material3TextFieldVariation outlinedMediumTextField: Material3TextFieldVariation {
        sourceStyle: root.sourceStyle
        tokens: root.tokens
        name: "textFieldOutlinedMedium"
        metrics: root.tokens.textFieldMedium
        filled: false
    }
    readonly property Material3TextFieldVariation outlinedLargeTextField: Material3TextFieldVariation {
        sourceStyle: root.sourceStyle
        tokens: root.tokens
        name: "textFieldOutlinedLarge"
        metrics: root.tokens.textFieldLarge
        filled: false
    }
    readonly property Material3TextFieldVariation outlinedExtraLargeTextField: Material3TextFieldVariation {
        sourceStyle: root.sourceStyle
        tokens: root.tokens
        name: "textFieldOutlinedExtraLarge"
        metrics: root.tokens.textFieldExtraLarge
        filled: false
    }
    readonly property Material3TextFieldVariation filledExtraSmallTextField: Material3TextFieldVariation {
        sourceStyle: root.sourceStyle
        tokens: root.tokens
        name: "textFieldFilledExtraSmall"
        metrics: root.tokens.textFieldExtraSmall
        filled: true
    }
    readonly property Material3TextFieldVariation filledSmallTextField: Material3TextFieldVariation {
        sourceStyle: root.sourceStyle
        tokens: root.tokens
        name: "textFieldFilledSmall"
        metrics: root.tokens.textFieldSmall
        filled: true
    }
    readonly property Material3TextFieldVariation filledMediumTextField: Material3TextFieldVariation {
        sourceStyle: root.sourceStyle
        tokens: root.tokens
        name: "textFieldFilledMedium"
        metrics: root.tokens.textFieldMedium
        filled: true
    }
    readonly property Material3TextFieldVariation filledLargeTextField: Material3TextFieldVariation {
        sourceStyle: root.sourceStyle
        tokens: root.tokens
        name: "textFieldFilledLarge"
        metrics: root.tokens.textFieldLarge
        filled: true
    }
    readonly property Material3TextFieldVariation filledExtraLargeTextField: Material3TextFieldVariation {
        sourceStyle: root.sourceStyle
        tokens: root.tokens
        name: "textFieldFilledExtraLarge"
        metrics: root.tokens.textFieldExtraLarge
        filled: true
    }

}
