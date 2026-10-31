pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

QtObject {
    id: root
    required property var sourceStyle
    property Material3Theme tokens: sourceStyle.tokens
    readonly property SK.StyleVariation dialogRecipe: SK.StyleVariation {
        name: "pickerDialog"
        dialog {
            padding: root.tokens.pickerPadding
            spacing: root.tokens.spacingMedium
            text.color: root.tokens.surfaceForeground
            background {
                width: root.tokens.pickerWidth
                height: 0
                color: root.tokens.surfaceContainerHigh
                radius: root.tokens.radiusExtraLarge
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
                width: root.tokens.pickerWidth
                height: 0
                color: root.tokens.surfaceContainerHigh
                radius: root.tokens.radiusExtraLarge
                margins: 0
                border.width: 0
                shadow.visible: false
            }
        }
    }
    readonly property ButtonVariation navigationItemRecipe: ButtonVariation {
        name: "pickerNavigationItem"
        sourceStyle: root.sourceStyle
        tokens: root.tokens
        containerColor: tokens.transparent
        contentColor: tokens.primary
        checkedContainerColor: tokens.secondaryContainer
        checkedContentColor: tokens.secondaryContainerForeground
        button {
            background.radius: Math.max(root.tokens.pickerYearCellHeight, root.tokens.pickerMonthCellHeight) / 2
            checked.background.radius: Math.max(root.tokens.pickerYearCellHeight, root.tokens.pickerMonthCellHeight) / 2
            pressed.background.radius: root.tokens.radiusSmall
            checked.pressed.background.radius: root.tokens.radiusSmall
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
            text.color: root.tokens.surfaceForeground
            background {
                width: root.tokens.pickerDayIndicatorSize
                height: root.tokens.pickerDayIndicatorSize
                radius: root.tokens.pickerDayIndicatorSize / 2
                margins: (root.tokens.pickerDaySize - root.tokens.pickerDayIndicatorSize) / 2
                color: root.tokens.transparent
                border.width: 0
                shadow.visible: false
            }
            highlighted {
                text.color: root.tokens.surfaceForeground
                background.color: root.tokens.secondaryContainer
            }
            checked {
                text.color: root.tokens.primaryForeground
                background.color: root.tokens.primary
            }
            pressed.background.radius: root.tokens.pickerDayIndicatorSize / 2
            disabled {
                text.color: root.tokens.disabledLabel
                background.color: root.tokens.transparent
            }
        }
    }
}
