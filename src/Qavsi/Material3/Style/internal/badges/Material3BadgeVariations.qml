pragma ComponentBehavior: Bound
import QtQuick

QtObject {
    id: root
    required property var sourceStyle
    property list<QtObject> entries: [
        Material3BadgeVariation { name: "badge"; sourceStyle: root.sourceStyle },
        Material3BadgeVariation { name: "badgePrimary"; sourceStyle: root.sourceStyle; intent: "primary" },
        Material3BadgeVariation { name: "badgeSecondary"; sourceStyle: root.sourceStyle; intent: "secondary" },
        Material3BadgeVariation { name: "badgeContrast"; sourceStyle: root.sourceStyle; intent: "contrast" }
    ]
}
