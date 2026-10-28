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
    readonly property SK.StyleVariation surfaceRecipe: SK.StyleVariation {
        name: "datePicker"
        pane {
            padding: 0
            background {
                fillWidth: true
                fillHeight: true
                width: root.sourceStyle.tokens.pickerWidth
                height: 0
                color: root.sourceStyle.tokens.surfaceContainerHigh
                radius: root.sourceStyle.tokens.radiusExtraLarge
                margins: 0
                border.width: 0
                shadow.visible: false
            }
        }
    }
    readonly property ButtonVariation navigationItemRecipe: ButtonVariation {
        name: "pickerNavigationItem"
        sourceStyle: root.sourceStyle
        containerColor: sourceStyle.tokens.transparent
        contentColor: sourceStyle.tokens.primary
        checkedContainerColor: sourceStyle.tokens.secondaryContainer
        checkedContentColor: sourceStyle.tokens.secondaryContainerForeground
        button {
            background.radius: Math.max(root.sourceStyle.tokens.pickerYearCellHeight, root.sourceStyle.tokens.pickerMonthCellHeight) / 2
            checked.background.radius: Math.max(root.sourceStyle.tokens.pickerYearCellHeight, root.sourceStyle.tokens.pickerMonthCellHeight) / 2
            pressed.background.radius: root.sourceStyle.tokens.radiusSmall
            checked.pressed.background.radius: root.sourceStyle.tokens.radiusSmall
        }
    }
    readonly property SK.StyleVariation dayRecipe: SK.StyleVariation {
        name: "pickerDay"
        control {
            leftPadding: 0
            rightPadding: 0
            topPadding: 0
            bottomPadding: 0
            spacing: 0
            background.gradient: null
            text.color: root.sourceStyle.tokens.surfaceForeground
            background {
                width: root.sourceStyle.tokens.pickerDayIndicatorSize
                height: root.sourceStyle.tokens.pickerDayIndicatorSize
                radius: root.sourceStyle.tokens.pickerDayIndicatorSize / 2
                margins: (root.sourceStyle.tokens.pickerDaySize - root.sourceStyle.tokens.pickerDayIndicatorSize) / 2
                color: root.sourceStyle.tokens.transparent
                border.width: 0
                shadow.visible: false
            }
            highlighted {
                text.color: root.sourceStyle.tokens.surfaceForeground
                background.color: root.sourceStyle.tokens.secondaryContainer
            }
            checked {
                text.color: root.sourceStyle.tokens.primaryForeground
                background.color: root.sourceStyle.tokens.primary
            }
            pressed.background.radius: root.sourceStyle.tokens.pickerDayIndicatorSize / 2
            disabled {
                text.color: root.sourceStyle.tokens.disabledLabel
                background.color: root.sourceStyle.tokens.transparent
            }
        }
    }
}
