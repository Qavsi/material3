pragma ComponentBehavior: Bound
import QtQuick
import Qavsi.Material3.Theme

QtObject {
    id: registrations
    required property var sourceStyle
    required property Material3Theme tokens
    default property list<QtObject> variations: [
        Material3ChipVariation { name: "chipAssist"; kind: "assist"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens },
        Material3ChipVariation { name: "chipFilter"; kind: "filter"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens },
        Material3ChipVariation { name: "chipInput"; kind: "input"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens },
        Material3ChipVariation { name: "chipSuggestion"; kind: "suggestion"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens },
        Material3ChipVariation { name: "chipEmbed"; kind: "embed"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens },
        Material3ChipVariation { name: "chipDismiss"; kind: "dismiss"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens }
    ]
}
