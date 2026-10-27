pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

ColumnLayout {
    id: root
    required property Material3Theme tokens
    required property bool darkMode
    required property bool reducedMotion
    signal toggleTheme()
    signal toggleMotion()
    spacing: tokens.spacingMedium
    RowLayout {
        Layout.fillWidth: true
        Layout.margins: root.tokens.spacingMedium
        spacing: root.tokens.spacingSmall
        Text {
            Layout.fillWidth: true
            text: qsTr("Qavsi / Material3")
            font: root.tokens.titleLarge
            color: root.tokens.surfaceForeground
        }
        SK.Button {
            objectName: "comparison.theme"
            text: root.darkMode ? qsTr("Light") : qsTr("Dark")
            onClicked: root.toggleTheme()
        }
        SK.Button {
            objectName: "comparison.motion"
            text: root.reducedMotion ? qsTr("Motion: reduced") : qsTr("Motion: full")
            onClicked: root.toggleMotion()
        }
    }
    Flickable {
        id: viewport
        objectName: "comparison.viewport"
        Layout.fillWidth: true
        Layout.fillHeight: true
        contentWidth: width
        contentHeight: gallery.height + root.tokens.spacingMedium * 2
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        SK.ScrollBar.vertical: SK.ScrollBar { }
        Column {
            id: gallery
            x: root.tokens.spacingMedium
            y: root.tokens.spacingMedium
            width: Math.max(0, viewport.width - root.tokens.spacingMedium * 2)
            spacing: root.tokens.spacingLarge
            ComboBoxGallery { width: Math.min(parent.width, preferredWidth); anchors.horizontalCenter: parent.horizontalCenter; tokens: root.tokens }
            FieldsGallery { width: Math.min(parent.width, root.tokens.referenceCardWidth); anchors.horizontalCenter: parent.horizontalCenter; tokens: root.tokens }
            Loader {
                id: apiExamples
                width: Math.min(parent.width, root.tokens.referenceCardWidth)
                anchors.horizontalCenter: parent.horizontalCenter
                active: false
                sourceComponent: ComboBoxApiExamples { tokens: root.tokens }
                // shortcut: keep caller popup creation outside Qt 6.12's initial reader-reset iteration.
                Component.onCompleted: Qt.callLater(() => apiExamples.active = true)
            }
            ActionsGallery { width: parent.width; tokens: root.tokens }
        }
    }
}
