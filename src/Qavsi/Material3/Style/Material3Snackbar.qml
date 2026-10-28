pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

SK.Popup {
    id: root
    readonly property Material3Theme tokens: (root.SK.StyleKit.style as Material3Style).tokens
    property string text: ""
    property T.Action action: null
    readonly property alias actionControl: actionButton
    property bool showClose: false
    property int timeout: root.tokens.snackbarTimeout
    padding: root.tokens.spacingSmall
    leftPadding: root.tokens.spacingMedium
    rightPadding: root.tokens.spacingMedium
    closePolicy: T.Popup.NoAutoClose
    focus: false
    onOpened: message.Accessible.announce(text, Accessible.Polite)
    Timer {
        interval: Math.max(1, root.timeout)
        running: root.visible && root.timeout > 0
        onTriggered: root.close()
    }
    contentItem: RowLayout {
        spacing: root.tokens.spacingSmall
        Text {
            id: message
            Layout.fillWidth: true
            text: root.text
            font: root.tokens.bodyMedium
            color: root.tokens.inverseSurfaceForeground
            wrapMode: Text.WordWrap
            Accessible.role: Accessible.StaticText
            Accessible.name: text
        }
        SK.Button {
            id: actionButton
            visible: root.action !== null
            action: root.action
            flat: true
            SK.StyleVariation.variations: ["snackbarAction"]
            onClicked: root.close()
        }
        SK.Button {
            visible: root.showClose
            text: qsTr("Close")
            flat: true
            SK.StyleVariation.variations: ["snackbarAction"]
            onClicked: root.close()
        }
    }
    background: Rectangle {
        implicitHeight: root.tokens.snackbarMinimumHeight
        radius: root.tokens.feedbackCornerRadius
        color: root.tokens.inverseSurface
    }
}
