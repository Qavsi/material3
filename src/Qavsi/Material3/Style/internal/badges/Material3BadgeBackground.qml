pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Templates as T
import Qt.labs.StyleKit as SK

Rectangle {
    id: root
    required property T.Label control
    required property SK.DelegateStyle delegateStyle
    readonly property Material3BadgeParameters parameters: delegateStyle.data as Material3BadgeParameters
    readonly property bool dotMode: control.text.length === 0
    implicitWidth: parameters ? (dotMode ? parameters.tokens.badgeDotDiameter : parameters.tokens.badgeLabelMinimumWidth) : 0
    implicitHeight: parameters ? (dotMode ? parameters.tokens.badgeDotDiameter : parameters.tokens.badgeLabelHeight) : 0
    width: control.width
    height: control.height
    visible: parameters !== null
    color: delegateStyle.color
    radius: Math.min(width, height) / 2
    antialiasing: true
}
