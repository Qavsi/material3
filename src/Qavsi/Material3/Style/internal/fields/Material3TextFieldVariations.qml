pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK

QtObject {
    id: root
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

}
