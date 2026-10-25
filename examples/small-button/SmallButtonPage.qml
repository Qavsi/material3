pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

Item {
    id: root
    required property Material3Theme tokens
    required property bool darkMode
    required property bool reducedMotion
    signal toggleTheme()
    signal toggleMotion()
    property int activationCount: 0
    // Example layout values belong to this consumer, not the kit's control recipe.
    readonly property real pagePadding: tokens.smallHorizontalPadding * 2
    readonly property real sectionGap: tokens.smallSpacing * 3
    Column {
        anchors.fill: parent
        anchors.margins: root.pagePadding
        spacing: root.sectionGap
        Text {
            text: qsTr("Material3 / Small Filled")
            color: root.tokens.surfaceForeground
            font: Qt.font({ family: root.tokens.fontFamily,
                pixelSize: root.tokens.labelLargeSize * 2, weight: Font.Medium })
        }
        Text {
            text: qsTr("Bağımsız Material3 · Qt 6.12")
            color: root.tokens.surfaceForeground
            font: root.tokens.labelLarge
        }
        Row {
            spacing: root.tokens.smallSpacing
            SK.Button {
                id: target
                objectName: "smallButton"
                text: qsTr("Kaydet")
                hoverEnabled: true
                onClicked: root.activationCount++
                Accessible.name: text
            }
            SK.Button {
                objectName: "disabledButton"
                text: qsTr("Kullanılamıyor")
                enabled: false
            }
        }
        Text {
            text: qsTr("%1 tema · %2 tıklama").arg(root.darkMode ? "Koyu" : "Açık").arg(root.activationCount)
            color: root.tokens.surfaceForeground
            font: root.tokens.labelLarge
        }
        Row {
            spacing: root.tokens.smallSpacing
            SK.Button {
                objectName: "themeButton"
                text: root.darkMode ? qsTr("Açık temaya geç") : qsTr("Koyu temaya geç")
                onClicked: root.toggleTheme()
            }
            SK.Button {
                objectName: "motionButton"
                text: root.reducedMotion ? qsTr("Azaltılmış hareket: Açık") : qsTr("Azaltılmış hareket: Kapalı")
                onClicked: root.toggleMotion()
                Accessible.description: qsTr("Sistemde azaltılmış hareket açıksa korunur.")
            }
        }
        Text {
            text: qsTr("Tab ile odaklan, Space ile etkinleştir.\nAzaltılmış harekette yayılma yerine sabit basma vurgusu gösterilir.")
            color: root.tokens.surfaceForeground
            font: root.tokens.labelLarge
        }
    }
    SK.Button {
        objectName: "callerOverrides"
        visible: false
        property int requestedFontSize: 19
        property real requestedWidth: 180
        property real requestedPadding: 0
        width: requestedWidth
        height: 52
        padding: requestedPadding
        leftPadding: requestedPadding
        rightPadding: requestedPadding
        topPadding: requestedPadding
        bottomPadding: requestedPadding
        spacing: 0
        font.pixelSize: requestedFontSize
        font.letterSpacing: 0
        text: "Caller"
    }
}
