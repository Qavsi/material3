pragma ComponentBehavior: Bound
import QtQuick

Material3CarouselView {
    id: root
    flickable: nativeView
    Flickable {
        id: nativeView
        anchors.fill: parent
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: root.orientation === Qt.Horizontal ? Flickable.HorizontalFlick : Flickable.VerticalFlick
    }
}
