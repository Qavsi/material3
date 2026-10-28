pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK

QtObject {
    id: root
    required property var sourceStyle
    readonly property SK.StyleVariation dialogRecipe: SK.StyleVariation {
        name: "pickerDialog"
        dialog {
            padding: root.sourceStyle.tokens.pickerPadding
            spacing: root.sourceStyle.tokens.spacingMedium
            text.color: root.sourceStyle.tokens.surfaceForeground
            background {
                width: root.sourceStyle.tokens.pickerWidth
                height: 0
                color: root.sourceStyle.tokens.surfaceContainerHigh
                radius: root.sourceStyle.tokens.radiusExtraLarge
                border.width: 0
                margins: 0
                shadow.visible: false
            }
        }
    }
    readonly property SK.StyleVariation dayRecipe: SK.StyleVariation {
        name: "pickerDay"
        button {
            padding: 0
            spacing: 0
            text.color: root.sourceStyle.tokens.surfaceForeground
            background {
                width: root.sourceStyle.tokens.pickerDaySize
                height: root.sourceStyle.tokens.pickerDaySize
                radius: root.sourceStyle.tokens.pickerDaySize / 2
                margins: 0
                color: root.sourceStyle.tokens.transparent
                border.width: 0
                shadow.visible: false
            }
            checked {
                text.color: root.sourceStyle.tokens.primaryForeground
                background.color: root.sourceStyle.tokens.primary
            }
            pressed.background.radius: root.sourceStyle.tokens.pickerDaySize / 2
            disabled {
                text.color: root.sourceStyle.tokens.disabledLabel
                background.color: root.sourceStyle.tokens.transparent
            }
        }
    }
}
