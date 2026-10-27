pragma ComponentBehavior: Bound
import QtQuick

QtObject {
    id: registrations
    required property var sourceStyle
    default property list<QtObject> variations: [
        Material3ChipVariation { name: "chipAssist"; kind: "assist"; sourceStyle: registrations.sourceStyle },
        Material3ChipVariation { name: "chipFilter"; kind: "filter"; sourceStyle: registrations.sourceStyle },
        Material3ChipVariation { name: "chipInput"; kind: "input"; sourceStyle: registrations.sourceStyle },
        Material3ChipVariation { name: "chipSuggestion"; kind: "suggestion"; sourceStyle: registrations.sourceStyle },
        Material3ChipVariation { name: "chipEmbed"; kind: "embed"; sourceStyle: registrations.sourceStyle },
        Material3ChipVariation { name: "chipDismiss"; kind: "dismiss"; sourceStyle: registrations.sourceStyle }
    ]
}
