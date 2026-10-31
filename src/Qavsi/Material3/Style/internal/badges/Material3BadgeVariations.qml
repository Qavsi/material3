pragma ComponentBehavior: Bound
import QtQuick
import Qavsi.Material3.Theme

QtObject {
    id: root
    required property var sourceStyle
    property Material3Theme tokens: sourceStyle.tokens
    property list<QtObject> entries: [
        Material3BadgeVariation { name: "badge"; sourceStyle: root.sourceStyle; tokens: root.tokens },
        Material3BadgeVariation { name: "badgePrimary"; sourceStyle: root.sourceStyle; tokens: root.tokens; intent: "primary" },
        Material3BadgeVariation { name: "badgeSecondary"; sourceStyle: root.sourceStyle; tokens: root.tokens; intent: "secondary" },
        Material3BadgeVariation { name: "badgeContrast"; sourceStyle: root.sourceStyle; tokens: root.tokens; intent: "contrast" }
    ]
}
