pragma ComponentBehavior: Bound
import QtQuick
import Qavsi.Material3.Theme

QtObject {
    id: root
    required property Material3Style sourceStyle
    property Material3Theme tokens: sourceStyle.tokens
    default property list<QtObject> registrations: [
        Material3ComboBoxVariation { name: "comboBoxExtraSmall"; sourceStyle: root.sourceStyle; tokens: root.tokens; metrics: tokens.comboBoxExtraSmall },
        Material3ComboBoxVariation { name: "comboBoxSmall"; sourceStyle: root.sourceStyle; tokens: root.tokens; metrics: tokens.comboBoxSmall },
        Material3ComboBoxVariation { name: "comboBoxMedium"; sourceStyle: root.sourceStyle; tokens: root.tokens; metrics: tokens.comboBoxMedium },
        Material3ComboBoxVariation { name: "comboBoxLarge"; sourceStyle: root.sourceStyle; tokens: root.tokens; metrics: tokens.comboBoxLarge },
        Material3ComboBoxVariation { name: "comboBoxExtraLarge"; sourceStyle: root.sourceStyle; tokens: root.tokens; metrics: tokens.comboBoxExtraLarge }
    ]
}
