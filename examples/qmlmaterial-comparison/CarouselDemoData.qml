pragma ComponentBehavior: Bound
import QtQml

QtObject {
    readonly property var photos: [
        { imageUrl: Qt.resolvedUrl("assets/carousel/abstract-coral-landscape.jpg"), title: qsTr("Coral"), aspectRatio: 960 / 640 },
        { imageUrl: Qt.resolvedUrl("assets/carousel/abstract-mint-square.jpg"), title: qsTr("Mint"), aspectRatio: 800 / 800 },
        { imageUrl: Qt.resolvedUrl("assets/carousel/abstract-violet-portrait.jpg"), title: qsTr("Violet"), aspectRatio: 640 / 960 },
        { imageUrl: Qt.resolvedUrl("assets/carousel/abstract-sun-ultrawide.jpg"), title: qsTr("Sun"), aspectRatio: 1050 / 450 },
        { imageUrl: Qt.resolvedUrl("assets/carousel/abstract-teal-tall.jpg"), title: qsTr("Teal"), aspectRatio: 540 / 960 },
        { imageUrl: Qt.resolvedUrl("assets/carousel/abstract-amber-wide.jpg"), title: qsTr("Amber"), aspectRatio: 1200 / 675 },
        { imageUrl: Qt.resolvedUrl("assets/carousel/abstract-rose-medium.jpg"), title: qsTr("Rose"), aspectRatio: 720 / 720 },
        { imageUrl: Qt.resolvedUrl("assets/carousel/abstract-sky-small.jpg"), title: qsTr("Sky"), aspectRatio: 480 / 320 },
        { imageUrl: Qt.resolvedUrl("assets/carousel/abstract-lime-diagonal.jpg"), title: qsTr("Lime"), aspectRatio: 900 / 600 },
        { imageUrl: Qt.resolvedUrl("assets/carousel/abstract-indigo-portrait.jpg"), title: qsTr("Indigo"), aspectRatio: 750 / 1000 }
    ]
}
