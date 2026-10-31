pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK

Material3BusyIndicatorVisual {
    id: root
    required property SK.DelegateStyle delegateStyle
    readonly property Material3BusyIndicatorParameters parameters: delegateStyle.data as Material3BusyIndicatorParameters
    tokens: parameters.tokens
    reducedMotion: parameters.reducedMotion
    width: parent.width
    height: parent.height
    implicitWidth: delegateStyle.width
    implicitHeight: delegateStyle.height
    visible: delegateStyle.visible
    opacity: delegateStyle.opacity
}
