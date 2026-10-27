import QtQuick
import Qavsi.Material3.Theme

QtObject {
    id: root
    required property Material3Theme tokens
    required property bool reducedMotion
    property bool filled: false
    property var metrics: tokens.textFieldMedium
    readonly property QtObject iconAppearance: QtObject {
        readonly property int weight: root.tokens.iconWeight
        readonly property real opticalSize: root.tokens.iconOpticalSize
        readonly property int grade: root.tokens.iconGrade
        readonly property int renderType: root.tokens.iconRenderType
    }
}
