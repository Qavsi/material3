pragma ComponentBehavior: Bound
import QtQuick
import Qcm.Material as MD
import Qavsi.Material3.Style as M3

Window {
    id: root
    required property rect previewArea
    property bool unequal: false
    property real elevation: 6
    property vector4d radii: Qt.vector4d(16, 16, 16, 16)
    property color shadowColor: "black"
    property real sampleOpacity: 1
    property real casterWidth: 160
    property real casterHeight: 96
    property color surface: "#faf9fd"
    readonly property real sigma: Math.max(elevation * 1.2, 0.5)
    readonly property color blurColor: Qt.rgba(shadowColor.r, shadowColor.g,
        shadowColor.b, shadowColor.a * 0.35)
    width: 1000
    height: 440
    x: previewArea.x + (previewArea.width - width) / 2
    y: previewArea.y + (previewArea.height - height) / 2
    visible: false
    color: surface
    title: qsTr("QCM / Qavsi shadow parity")

    Item {
        id: reference
        objectName: "referenceCaster"
        x: 120
        y: 160
        width: root.casterWidth
        height: root.casterHeight
        Loader {
            anchors.fill: parent
            sourceComponent: root.unequal ? referenceBlur : referenceAnalytic
        }
        Rectangle {
            anchors.fill: parent
            color: "#e6e0e9"
            topLeftRadius: root.radii.x
            topRightRadius: root.radii.y
            bottomLeftRadius: root.radii.z
            bottomRightRadius: root.radii.w
            antialiasing: true
        }
    }
    Item {
        id: ported
        objectName: "portedCaster"
        x: 640
        y: 160
        width: root.casterWidth
        height: root.casterHeight
        Loader {
            anchors.fill: parent
            sourceComponent: root.unequal ? portedBlur : portedAnalytic
        }
        Rectangle {
            anchors.fill: parent
            color: "#e6e0e9"
            topLeftRadius: root.radii.x
            topRightRadius: root.radii.y
            bottomLeftRadius: root.radii.z
            bottomRightRadius: root.radii.w
            antialiasing: true
        }
    }
    Component {
        id: referenceAnalytic
        MD.RRectShadowImpl {
            objectName: "referenceShadow"
            elevation: root.elevation
            corners: MD.Util.corners(root.radii.x, root.radii.y, root.radii.z, root.radii.w)
            color: root.shadowColor
            opacity: root.sampleOpacity
        }
    }
    Component {
        id: referenceBlur
        MD.BlurMaskImpl {
            objectName: "referenceShadow"
            sigma: root.sigma
            corners: MD.Util.corners(root.radii.x, root.radii.y, root.radii.z, root.radii.w)
            color: root.blurColor
            style: MD.BlurMaskImpl.Outer
            opacity: root.sampleOpacity
        }
    }
    Component {
        id: portedAnalytic
        M3.RoundedRectShadow {
            objectName: "portedShadow"
            elevation: root.elevation
            cornerRadii: root.radii
            color: root.shadowColor
            ambientOpacity: 0.039
            spotOpacity: 0.25
            lightDirection: Qt.vector3d(0, -1, 1)
            lightRadius: 800 / 600
            opacity: root.sampleOpacity
        }
    }
    Component {
        id: portedBlur
        M3.BlurMaskShadow {
            objectName: "portedShadow"
            sigma: root.sigma
            cornerRadii: root.radii
            color: root.blurColor
            opacity: root.sampleOpacity
        }
    }
}
