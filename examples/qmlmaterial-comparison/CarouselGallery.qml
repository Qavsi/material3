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
    spacing: tokens.spacingMedium
    CarouselDemoData { id: demoData }
    SK.Label { color: root.tokens.surfaceForeground; text: qsTr("Carousel"); font: root.tokens.titleLarge; Layout.alignment: Qt.AlignHCenter }
    DemoCard {
        tokens: root.tokens; title: qsTr("Uncontained")
        Layout.fillWidth: true
        SK.Label { color: root.tokens.surfaceForeground; text: qsTr("Fixed width"); anchors.horizontalCenter: parent.horizontalCenter }
        Material3Carousel {
            objectName: "comparison.pickers.carousel"
            width: Math.min(parent.width, root.tokens.carouselWidth)
            anchors.horizontalCenter: parent.horizontalCenter
            model: demoData.photos
        }
        SK.Label { color: root.tokens.surfaceForeground; text: qsTr("Multi-aspect"); anchors.horizontalCenter: parent.horizontalCenter }
        Material3Carousel {
            width: Math.min(parent.width, root.tokens.carouselWidth)
            anchors.horizontalCenter: parent.horizontalCenter
            layout: Material3Carousel.UncontainedMultiAspect
            model: demoData.photos
        }
    }
    DemoCard {
        tokens: root.tokens; title: qsTr("Multi-browse")
        Layout.fillWidth: true
        Material3Carousel {
            objectName: "comparison.carousel.multiBrowse"
            width: Math.min(parent.width, root.tokens.carouselWidth)
            anchors.horizontalCenter: parent.horizontalCenter
            layout: Material3Carousel.MultiBrowse
            model: demoData.photos
            showPageIndicator: true
            showNavigationButtons: true
        }
    }
    DemoCard {
        tokens: root.tokens; title: qsTr("Hero")
        Layout.fillWidth: true
        SK.Label { color: root.tokens.surfaceForeground; text: qsTr("Start-aligned"); anchors.horizontalCenter: parent.horizontalCenter }
        Material3Carousel {
            width: Math.min(parent.width, root.tokens.carouselWidth)
            height: root.metrics.carouselHeroHeight
            anchors.horizontalCenter: parent.horizontalCenter
            layout: Material3Carousel.Hero
            model: demoData.photos
            showNavigationButtons: true
        }
        SK.Label { color: root.tokens.surfaceForeground; text: qsTr("Center-aligned"); anchors.horizontalCenter: parent.horizontalCenter }
        Material3Carousel {
            width: Math.min(parent.width, root.tokens.carouselWidth)
            height: root.metrics.carouselHeroHeight
            anchors.horizontalCenter: parent.horizontalCenter
            layout: Material3Carousel.HeroCenter
            model: demoData.photos
            showNavigationButtons: true
        }
    }
    DemoCard {
        tokens: root.tokens; title: qsTr("Full-screen (vertical)")
        Layout.fillWidth: true
        Material3Carousel {
            objectName: "comparison.carousel.vertical"
            width: Math.min(parent.width, root.tokens.carouselWidth)
            height: root.metrics.carouselVerticalHeight
            anchors.horizontalCenter: parent.horizontalCenter
            layout: Material3Carousel.FullScreen
            orientation: Qt.Vertical
            model: demoData.photos
            showNavigationButtons: true
        }
    }
}
