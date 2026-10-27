pragma ComponentBehavior: Bound
import QtQuick

Rectangle {
    id: root
    required property bool horizontal
    required property real start
    required property real end
    required property real thickness
    required property real innerRadius
    required property real crossCenter
    property bool outerStart: false
    property bool outerEnd: false
    readonly property real startRadius: outerStart ? thickness / 2 : innerRadius
    readonly property real endRadius: outerEnd ? thickness / 2 : innerRadius
    x: horizontal ? start : crossCenter - width / 2
    y: horizontal ? crossCenter - height / 2 : start
    width: horizontal ? Math.max(0, end - start) : thickness
    height: horizontal ? thickness : Math.max(0, end - start)
    topLeftRadius: startRadius
    topRightRadius: horizontal ? endRadius : startRadius
    bottomLeftRadius: horizontal ? startRadius : endRadius
    bottomRightRadius: endRadius
    visible: width > 0 && height > 0
    Accessible.ignored: true
}
