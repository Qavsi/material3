import QtQuick
import Qavsi.Material3.Theme

QtObject {
    required property Material3Theme tokens
    required property bool reducedMotion
    property var metrics: tokens.comboBoxMedium
}
