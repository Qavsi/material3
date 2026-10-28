pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

SK.Button {
    id: root
    required property int index
    readonly property Material3Theme tokens: (SK.StyleKit.style as Material3Style)?.tokens ?? fallbackTokens
    readonly property Material3Theme fallbackTokens: Material3Theme { }
    property string accessibilityTitle: ""
    property real maskStart: Material3CarouselView.maskStart
    property real maskEnd: Material3CarouselView.maskEnd
    property real parallaxShift: Material3CarouselView.parallaxShift
    property real cornerRadius: tokens.carouselItemCorner
    readonly property real visibleWidth: Math.max(0, width * (1 - maskStart - maskEnd))
    readonly property real effectiveCornerRadius: Math.min(cornerRadius, visibleWidth / 2, height / 2)
    readonly property int carouselCount: Material3CarouselView.carouselCount
    readonly property int carouselCurrentIndex: Material3CarouselView.carouselCurrentIndex
    default property alias content: media.data
    SK.StyleVariation.variations: ["carouselItem"]
    implicitWidth: Material3CarouselView.itemWidth
    implicitHeight: Material3CarouselView.itemHeight
    leftPadding: width * maskStart
    rightPadding: width * maskEnd
    topPadding: 0; bottomPadding: 0
    leftInset: leftPadding
    rightInset: rightPadding
    topInset: 0; bottomInset: 0
    activeFocusOnTab: activeFocus || (visible && index === carouselCurrentIndex)
    containmentMask: media
    background.z: 1
    Accessible.name: qsTr("%1, %2 of %3").arg(accessibilityTitle).arg(index + 1).arg(Math.max(1, carouselCount))
    contentItem: Item { id: media; clip: true }
}
