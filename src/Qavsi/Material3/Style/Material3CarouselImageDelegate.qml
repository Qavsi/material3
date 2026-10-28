// QCM 0.6.1 (1912605) image, title and mask composition; native Image supports software.
pragma ComponentBehavior: Bound
import QtQuick

Material3CarouselItem {
    id: root
    required property var model
    property string imageUrl: ""
    property string source: ""
    property string url: ""
    property string title: ""
    readonly property string imageSource: imageUrl || url || source
        || (typeof model === "string" ? model : model?.imageUrl || model?.url || model?.source || "")
    readonly property string itemTitle: title || (typeof model === "string" ? "" : model?.title || "")
    readonly property real itemAspectRatio: typeof model === "object" && model?.aspectRatio > 0 ? model.aspectRatio
        : image.sourceSize.height > 0 ? image.sourceSize.width / image.sourceSize.height : 1
    readonly property real titleOpacity: Math.min(Math.max(0, 1 - maskStart * width / tokens.carouselTitleFadeSpan),
                                                 Math.max(0, 1 - maskEnd * width / tokens.carouselTitleFadeSpan))
    accessibilityTitle: itemTitle
    Item {
        anchors.fill: parent
        clip: true
        x: -root.parallaxShift
        Image {
            id: image
            anchors.fill: parent
            source: root.imageSource
            sourceSize.width: Math.ceil(root.tokens.carouselWidth * Screen.devicePixelRatio)
            fillMode: Image.PreserveAspectCrop
            asynchronous: true
            cache: false
            Accessible.ignored: true
        }
        Text {
            anchors { left: parent.left; right: parent.right; bottom: parent.bottom; margins: root.tokens.spacingMedium }
            text: root.itemTitle
            visible: text.length > 0
            color: root.tokens.carouselImageForeground
            font: root.tokens.titleSmall
            opacity: root.titleOpacity
            maximumLineCount: 2
            wrapMode: Text.WordWrap
            elide: Text.ElideRight
            Accessible.ignored: true
        }
    }
}
