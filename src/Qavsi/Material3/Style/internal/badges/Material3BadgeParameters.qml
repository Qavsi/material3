import QtQuick
import Qavsi.Material3.Theme

QtObject {
    required property Material3Theme tokens
    property string intent: "error"
    readonly property color container: intent === "primary" ? tokens.primary
        : intent === "secondary" ? tokens.secondary
        : intent === "contrast" ? tokens.inverseSurface : tokens.badgeContainer
    readonly property color foreground: intent === "primary" ? tokens.primaryForeground
        : intent === "secondary" ? tokens.secondaryForeground
        : intent === "contrast" ? tokens.inverseSurfaceForeground : tokens.badgeForeground
}
