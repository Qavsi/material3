pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Style
import Qavsi.Material3.Theme

Column {
    id: root
    required property Material3Theme tokens
    spacing: tokens.spacingLarge
    DemoCard {
        width: parent.width
        tokens: root.tokens
        title: qsTr("Text Inputs")
        contentPadding: root.tokens.inputGalleryPadding
        Column {
            width: parent.width
            spacing: root.tokens.inputGallerySpacing
            SK.TextField {
                width: parent.width
                placeholderText: qsTr("Filled")
                SK.StyleVariation.variations: ["textFieldFilled"]
            }
            SK.TextField {
                objectName: "comparison.field.filled"
                width: parent.width
                placeholderText: qsTr("Filled")
                property bool serverError: false
                property bool showSupportingText: false
                TextFieldSupport.leadingIcon: "material:search"
                TextFieldSupport.trailingIcon: "material:info"
                TextFieldSupport.supportingText: showSupportingText ? qsTr("Only used for notifications.") : ""
                TextFieldSupport.errorText: qsTr("Please use a different email address. The server could not accept this address.")
                TextFieldSupport.error: serverError
                SK.StyleVariation.variations: ["textFieldFilled"]
            }
            SK.TextField {
                objectName: "comparison.field.outlined"
                width: parent.width
                placeholderText: qsTr("Outlined")
                property bool showSupportingText: false
                TextFieldSupport.supportingText: showSupportingText ? qsTr("Supporting text") : ""
            }
            SK.TextField {
                objectName: "comparison.field.amount"
                width: parent.width
                placeholderText: qsTr("Amount")
                property bool showAffixes: true
                property real extraInputPadding: 0
                rightPadding: root.tokens.textFieldHorizontalPadding + extraInputPadding
                text: "25"
                validator: DoubleValidator { bottom: 0; decimals: 2 }
                TextFieldSupport.prefix: showAffixes ? "$" : ""
                TextFieldSupport.suffix: showAffixes ? "USD" : ""
                TextFieldSupport.supportingText: qsTr("Enter the amount before tax.")
                SK.StyleVariation.variations: ["textFieldFilled"]
            }
            SK.TextField {
                objectName: "comparison.field.invalid"
                width: parent.width
                placeholderText: qsTr("Username")
                text: qsTr("A long username")
                validator: RegularExpressionValidator { regularExpression: /.{0,10}/ }
                TextFieldSupport.supportingText: qsTr("Use at most 10 characters.")
                TextFieldSupport.errorText: qsTr("The username is too long.")
            }
            Text {
                width: parent.width
                text: qsTr("Sizes")
                font: root.tokens.titleMedium
                color: root.tokens.surfaceForeground
                horizontalAlignment: Text.AlignHCenter
            }
            Repeater {
                model: [
                    { size: "XS", filled: true, variation: "textFieldFilledExtraSmall" },
                    { size: "S", filled: false, variation: "textFieldOutlinedSmall" },
                    { size: "M", filled: true, variation: "textFieldFilledMedium" },
                    { size: "L", filled: false, variation: "textFieldOutlinedLarge" },
                    { size: "XL", filled: true, variation: "textFieldFilledExtraLarge" }
                ]
                SK.TextField {
                    required property var modelData
                    width: parent.width
                    objectName: "comparison.field.size." + modelData.size
                    placeholderText: qsTr("%1 · %2").arg(modelData.filled ? qsTr("Filled") : qsTr("Outlined")).arg(modelData.size)
                    SK.StyleVariation.variations: [modelData.variation]
                }
            }
        }
    }
    DemoCard {
        width: parent.width
        tokens: root.tokens
        title: qsTr("Native editing states")
        SK.TextField {
            objectName: "comparison.field.disabled"
            width: parent.width
            placeholderText: qsTr("Disabled")
            enabled: false
        }
        SK.TextField {
            objectName: "comparison.field.readOnly"
            width: parent.width
            placeholderText: qsTr("Read only")
            text: qsTr("Qavsi")
            readOnly: true
            SK.StyleVariation.variations: ["textFieldFilled"]
        }
    }
}
