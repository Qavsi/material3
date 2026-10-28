import QtQuick
import Qavsi.Material3.Theme

QtObject {
    required property Material3Theme tokens
    required property bool reducedMotion
    property bool circular: false
    property bool busy: false
    property bool wavy: false
    property int motionType: circular && wavy ? 1 : 0
}
