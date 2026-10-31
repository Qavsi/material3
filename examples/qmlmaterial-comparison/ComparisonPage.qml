pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme
import Qavsi.Material3.Style

ColumnLayout {
    id: root
    required property Material3Theme tokens
    readonly property ComparisonMetrics metrics: ComparisonMetrics { }
    signal appearanceRequested()
    spacing: tokens.spacingMedium
    RowLayout {
        Layout.fillWidth: true
        Layout.minimumWidth: 0
        Layout.margins: root.tokens.spacingMedium
        spacing: root.tokens.spacingSmall
        Text {
            Layout.fillWidth: true
            Layout.minimumWidth: 0
            elide: Text.ElideRight
            text: qsTr("Qavsi / Material3")
            font: root.tokens.titleLarge
            color: root.tokens.surfaceForeground
        }
        SK.Button {
            id: appearanceButton
            objectName: "comparison.appearance.open"
            text: qsTr("Appearance")
            icon.name: "material:palette"
            display: SK.Button.IconOnly
            SK.StyleVariation.variations: ["iconExtraSmall", "iconStandard"]
            contentItem: Material3ButtonContent { control: appearanceButton }
            onClicked: root.appearanceRequested()
        }
    }
    Flickable {
        id: viewport
        objectName: "comparison.viewport"
        Layout.fillWidth: true
        Layout.fillHeight: true
        Layout.minimumWidth: 0
        contentWidth: width
        contentHeight: gallery.height + root.tokens.spacingMedium * 2
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        SK.ScrollBar.vertical: SK.ScrollBar { objectName: "comparison.scrollbar.vertical" }
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
            Loader {
                id: navigationExamples
                width: Math.min(parent.width, root.tokens.referenceCardWidth)
                anchors.horizontalCenter: parent.horizontalCenter
                active: false
                sourceComponent: NavigationGallery { tokens: root.tokens }
                // Qt 6.12 must finish Style completion before creating these readers.
                Component.onCompleted: Qt.callLater(() => navigationExamples.active = true)
            }
            Loader {
                id: appNavigationExamples
                width: parent.width
                active: false
                sourceComponent: AppNavigationGallery { tokens: root.tokens }
                Component.onCompleted: Qt.callLater(() => appNavigationExamples.active = true)
            }
            SwitchesGallery { width: Math.min(parent.width, root.tokens.referenceCardWidth); anchors.horizontalCenter: parent.horizontalCenter; tokens: root.tokens }
            ChipsGallery { width: Math.min(parent.width, preferredWidth); anchors.horizontalCenter: parent.horizontalCenter; tokens: root.tokens }
            ListCardsGallery { width: Math.min(parent.width, preferredWidth); anchors.horizontalCenter: parent.horizontalCenter; tokens: root.tokens }
            CheckBoxesGallery { width: Math.min(parent.width, preferredWidth); anchors.horizontalCenter: parent.horizontalCenter; tokens: root.tokens }
            BadgesGallery { width: Math.min(parent.width, preferredWidth); anchors.horizontalCenter: parent.horizontalCenter; tokens: root.tokens }
            RadioButtonsGallery { width: Math.min(parent.width, preferredWidth); anchors.horizontalCenter: parent.horizontalCenter; tokens: root.tokens }
            SlidersGallery { width: Math.min(parent.width, root.metrics.sliderCardWidth); anchors.horizontalCenter: parent.horizontalCenter; tokens: root.tokens }
            ProgressGallery { width: Math.min(parent.width, preferredWidth); anchors.horizontalCenter: parent.horizontalCenter; tokens: root.tokens }
            ButtonIndicatorsGallery { width: Math.min(parent.width, preferredWidth); anchors.horizontalCenter: parent.horizontalCenter; tokens: root.tokens }
            PickersCarouselGallery { width: parent.width; tokens: root.tokens }
            DialogFeedbackGallery { width: Math.min(parent.width, root.tokens.referenceCardWidth); anchors.horizontalCenter: parent.horizontalCenter; tokens: root.tokens }
            ActionsGallery { width: parent.width; tokens: root.tokens }
        }
    }
}
