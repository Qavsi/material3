// QmlMaterial 0.6.1 uncontained recipe (1912605, MIT); native ListView owns scrolling.
pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

ListView {
    id: root
    readonly property Material3Theme tokens: (SK.StyleKit.style as Material3Style)?.tokens ?? fallbackTokens
    readonly property Material3Theme fallbackTokens: Material3Theme { }
    implicitWidth: tokens.carouselWidth
    implicitHeight: tokens.carouselHeight
    orientation: ListView.Horizontal
    spacing: tokens.spacingSmall
    clip: true
    activeFocusOnTab: true
    keyNavigationEnabled: true
    keyNavigationWraps: false
    snapMode: ListView.SnapOneItem
    highlightRangeMode: ListView.StrictlyEnforceRange
    preferredHighlightBegin: 0
    preferredHighlightEnd: 0
    highlightMoveDuration: 0
    boundsBehavior: Flickable.StopAtBounds
    Accessible.role: Accessible.List
    Accessible.name: qsTr("Carousel")
    function previous(): void { if (currentIndex > 0) decrementCurrentIndex(); }
    function next(): void { if (currentIndex < count - 1) incrementCurrentIndex(); }
}
