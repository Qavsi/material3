pragma ComponentBehavior: Bound
import QtQuick

QtObject {
    id: root
    required property Material3Style sourceStyle
    default property list<QtObject> registrations: [
        Material3ComboBoxVariation { name: "comboBoxExtraSmall"; sourceStyle: root.sourceStyle; metrics: sourceStyle.tokens.comboBoxExtraSmall },
        Material3ComboBoxVariation { name: "comboBoxSmall"; sourceStyle: root.sourceStyle; metrics: sourceStyle.tokens.comboBoxSmall },
        Material3ComboBoxVariation { name: "comboBoxMedium"; sourceStyle: root.sourceStyle; metrics: sourceStyle.tokens.comboBoxMedium },
        Material3ComboBoxVariation { name: "comboBoxLarge"; sourceStyle: root.sourceStyle; metrics: sourceStyle.tokens.comboBoxLarge },
        Material3ComboBoxVariation { name: "comboBoxExtraLarge"; sourceStyle: root.sourceStyle; metrics: sourceStyle.tokens.comboBoxExtraLarge }
    ]
}
