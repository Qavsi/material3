import QtQuick
import Qavsi.Material3.Theme

QtObject {
    id: root
    required property Material3Theme tokens
    required property bool reduceMotion
    // Metadata for the opt-in content helper; native SK.Button keeps its own content.
    property real minimumIconSize: tokens.smallIconSize
    property real paintWidth: 0
    property real paintHeight: 0
    property bool fillIconWhenChecked: false
    readonly property QtObject iconAppearance: QtObject {
        readonly property int weight: root.tokens.iconWeight
        readonly property real opticalSize: root.tokens.iconOpticalSize
        readonly property int grade: root.tokens.iconGrade
        readonly property int renderType: root.tokens.iconRenderType
    }
    property string contentRole: "standard"
    property real contentOffset: 0
    property bool expanded: false
}
