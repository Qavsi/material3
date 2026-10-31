pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK

SK.Button {
    id: root
    required property MaterialTimeState time
    required property int period
    property bool horizontal: false
    SK.StyleVariation.variations: ["timePickerPeriod"]
    text: period === 0 ? time.amText : time.pmText
    checkable: true
    autoExclusive: true
    checked: time.period === period
    onClicked: time.period = period
}
