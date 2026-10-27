import QtQuick
import Qavsi.Material3.Theme

QtObject {
    id: root
    required property Material3Theme tokens
    required property bool reducedMotion
    readonly property QtObject iconAppearance: QtObject {
        readonly property int weight: root.tokens.iconWeight
        readonly property real opticalSize: root.tokens.iconOpticalSize
        readonly property int grade: root.tokens.iconGrade
        readonly property int renderType: root.tokens.iconRenderType
    }
    property string role: "tabPrimary"
    readonly property bool barItem: role === "navigationBarItem"
    readonly property bool railItem: role === "navigationRailCollapsed" || role === "navigationRailExpanded"
    readonly property bool expandedRail: role === "navigationRailExpanded"
}
