// QCM 0.6.1 (1912605) composition; native StyleKit controls and Qt Flickable.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

SK.Pane {
    id: root
    enum LayoutMode { Uncontained, MultiBrowse, Hero, HeroCenter, FullScreen, UncontainedMultiAspect }
    readonly property Material3Style materialStyle: SK.StyleKit.style as Material3Style
    readonly property Material3Theme tokens: materialStyle?.tokens ?? fallbackTokens
    readonly property Material3Theme fallbackTokens: Material3Theme { }
    property alias model: view.model
    property alias delegate: view.delegate
    property alias currentIndex: view.currentIndex
    readonly property int count: view.count
    property alias layout: view.layout
    property alias orientation: view.orientation
    property alias initialItem: view.initialItem
    property alias itemSnapping: view.itemSnapping
    property alias itemExtent: view.itemExtent
    property alias itemSpacing: view.spacing
    property alias interactive: view.interactive
    property alias wheelNavigationEnabled: view.wheelNavigationEnabled
    property bool showPageIndicator: false
    property bool showNavigationButtons: false
    property bool reduceMotion: materialStyle?.effectiveReducedMotion ?? true
    property real contentPadding: tokens.spacingMedium
    property real contentPaddingVertical: tokens.carouselCrossPadding
    property real minimumViewportHeight: tokens.carouselHeight
    property bool clipContainer: layout === Material3Carousel.MultiBrowse || layout === Material3Carousel.FullScreen
    property string header: qsTr("Carousel")
    readonly property bool hasChrome: showPageIndicator || showNavigationButtons
    readonly property real chromeHeight: Math.max(tokens.carouselChromeHeight, navigation.implicitHeight)
    readonly property real viewportHeight: orientation === Qt.Vertical
        ? Math.max(0, height - (hasChrome ? chromeHeight + tokens.carouselChromeSpacing : 0))
        : Math.max(layout === Material3Carousel.FullScreen ? itemExtent : minimumViewportHeight,
                   height - (hasChrome ? chromeHeight + tokens.carouselChromeSpacing : 0))
    signal clicked(int index)
    implicitWidth: orientation === Qt.Horizontal ? tokens.carouselWidth : tokens.carouselVerticalHeight
    implicitHeight: orientation === Qt.Vertical ? tokens.carouselVerticalHeight
        : (layout === Material3Carousel.FullScreen ? itemExtent : minimumViewportHeight)
          + (hasChrome ? chromeHeight + tokens.carouselChromeSpacing : 0)
    SK.StyleVariation.variations: ["carousel"]
    Accessible.role: Accessible.List
    Accessible.name: header
    function previous(): void { view.decrementCurrentIndex(); }
    function next(): void { view.incrementCurrentIndex(); }
    function incrementCurrentIndex(): void { next(); }
    function decrementCurrentIndex(): void { previous(); }
    Keys.onLeftPressed: event => {
        if (root.orientation === Qt.Horizontal) root.mirrored ? view.incrementCurrentIndexFromKeyboard() : view.decrementCurrentIndexFromKeyboard();
        else event.accepted = false;
    }
    Keys.onRightPressed: event => {
        if (root.orientation === Qt.Horizontal) root.mirrored ? view.decrementCurrentIndexFromKeyboard() : view.incrementCurrentIndexFromKeyboard();
        else event.accepted = false;
    }
    Keys.onUpPressed: event => { if (root.orientation === Qt.Vertical) view.decrementCurrentIndexFromKeyboard(); else event.accepted = false; }
    Keys.onDownPressed: event => { if (root.orientation === Qt.Vertical) view.incrementCurrentIndexFromKeyboard(); else event.accepted = false; }
    contentItem: ColumnLayout {
        spacing: root.tokens.carouselChromeSpacing
        Material3CarouselViewport {
            id: view
            Layout.fillWidth: true
            Layout.fillHeight: root.orientation === Qt.Vertical
            Layout.preferredHeight: root.viewportHeight
            itemExtent: root.tokens.carouselItemWidth
            minSmallItemWidth: root.tokens.carouselMinimumSmallWidth
            maxSmallItemWidth: root.tokens.carouselMaximumSmallWidth
            spacing: root.tokens.spacingSmall
            contentPaddingStart: root.layout === Material3Carousel.FullScreen ? 0 : root.contentPadding
            contentPaddingEnd: root.layout === Material3Carousel.Uncontained || root.layout === Material3Carousel.UncontainedMultiAspect || root.layout === Material3Carousel.FullScreen ? 0 : root.contentPadding
            contentPaddingCross: root.layout === Material3Carousel.FullScreen ? 0 : root.contentPaddingVertical
            itemCornerRadius: root.tokens.carouselItemCorner
            snapDuration: root.tokens.carouselSnapDuration
            reduceMotion: root.reduceMotion
            clipContainer: root.clipContainer
            mirrored: root.mirrored
            interactive: root.enabled
            wheelNavigationEnabled: true
            wheelRequiresShift: root.layout !== Material3Carousel.FullScreen
            delegate: Material3CarouselImageDelegate { }
            onClicked: index => root.clicked(index)
        }
        RowLayout {
            id: navigation
            visible: root.hasChrome
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignHCenter
            layoutDirection: root.mirrored ? Qt.RightToLeft : Qt.LeftToRight
            spacing: root.tokens.carouselChromeSpacing
            SK.Button {
                id: previousButton
                visible: root.showNavigationButtons && root.count > 1
                enabled: root.currentIndex > 0
                icon.name: root.orientation === Qt.Vertical ? "material:expand_less" : root.mirrored ? "material:chevron_right" : "material:chevron_left"
                Accessible.name: qsTr("Previous item")
                SK.StyleVariation.variations: ["iconSmall", "iconStandard"]
                contentItem: Material3ButtonContent { control: previousButton }
                onClicked: root.previous()
            }
            SK.PageIndicator {
                Layout.fillWidth: root.showNavigationButtons
                visible: root.showPageIndicator && root.count > 1
                // Qt 6.12 PageIndicator cells do not provide an implicit height.
                Layout.preferredHeight: root.tokens.carouselPageSize + root.tokens.carouselPagePadding * 2
                count: root.count
                currentIndex: root.currentIndex
                Accessible.name: qsTr("Carousel pages")
            }
            SK.Button {
                id: nextButton
                visible: root.showNavigationButtons && root.count > 1
                enabled: root.currentIndex < root.count - 1
                icon.name: root.orientation === Qt.Vertical ? "material:expand_more" : root.mirrored ? "material:chevron_left" : "material:chevron_right"
                Accessible.name: qsTr("Next item")
                SK.StyleVariation.variations: ["iconSmall", "iconStandard"]
                contentItem: Material3ButtonContent { control: nextButton }
                onClicked: root.next()
            }
        }
    }
}
