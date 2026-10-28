pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK

Material3ProgressVisual {
    id: root
    required property SK.DelegateStyle delegateStyle
    readonly property Material3ProgressParameters parameters: delegateStyle.data as Material3ProgressParameters
    tokens: parameters.tokens
    reducedMotion: parameters.reducedMotion
    circular: parameters.circular
    wavy: parameters.wavy
    motionType: parameters.motionType
    busy: parameters.busy
    width: parent.width
    height: parent.height
    implicitWidth: delegateStyle.width
    implicitHeight: delegateStyle.height
    visible: delegateStyle.visible
    opacity: delegateStyle.opacity
}
