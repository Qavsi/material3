pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Effects
import Qcm.Material as MD
import Qavsi.Material3.Style as M3

Item {
    id: cell
    objectName: "shadowBenchmarkCell"
    required property string rendererMode
    required property real elevation
    required property real cornerRadius
    required property color casterColor
    required property color shadowColor
    readonly property real ambientInset: elevation * 0.5
    readonly property real ambientBlur: ambientInset * (1 + elevation / 128)
    readonly property real spotBlur: elevation * (800 / 600)
    Accessible.ignored: true

    Loader {
        anchors.fill: parent
        active: cell.rendererMode !== "none"
        sourceComponent: cell.rendererMode === "qcm" ? qcmShadow
            : cell.rendererMode === "ported" ? portedShadow
            : cell.rendererMode === "rectangular2" ? twoShadows : oneShadow
    }

    Rectangle {
        anchors.fill: parent
        radius: cell.cornerRadius
        color: cell.casterColor
        antialiasing: true
        Accessible.ignored: true
    }

    Component {
        id: qcmShadow
        MD.Elevation {
            objectName: "qcmElevation"
            elevation: cell.elevation
            color: cell.shadowColor
            corners: MD.Util.corners(cell.cornerRadius)
        }
    }

    Component {
        id: portedShadow
        M3.RoundedRectShadow {
            objectName: "portedShadow"
            elevation: cell.elevation
            cornerRadii: Qt.vector4d(cell.cornerRadius, cell.cornerRadius,
                                     cell.cornerRadius, cell.cornerRadius)
            color: cell.shadowColor
            ambientOpacity: 0.039
            spotOpacity: 0.25
            lightDirection: Qt.vector3d(0, -1, 1)
            lightRadius: 800 / 600
            Accessible.ignored: true
        }
    }

    Component {
        id: oneShadow
        RectangularShadow {
            objectName: "rectangularShadow"
            radius: cell.cornerRadius
            topLeftRadius: cell.cornerRadius
            topRightRadius: cell.cornerRadius
            bottomLeftRadius: cell.cornerRadius
            bottomRightRadius: cell.cornerRadius
            color: cell.shadowColor
            opacity: 0.30
            blur: 3
            offset: Qt.vector2d(0, 1)
            cached: false
            Accessible.ignored: true
        }
    }

    Component {
        id: twoShadows
        Item {
            // QCM light extents/alphas with Qt falloff; this is not pixel-identical Skia shading.
            RectangularShadow {
                objectName: "rectangularAmbient"
                anchors.fill: parent
                radius: cell.cornerRadius
                color: cell.shadowColor
                opacity: 0.039
                spread: cell.ambientInset - cell.ambientBlur
                blur: cell.ambientBlur
                cached: false
                Accessible.ignored: true
            }
            RectangularShadow {
                objectName: "rectangularSpot"
                anchors.fill: parent
                radius: cell.cornerRadius
                color: cell.shadowColor
                opacity: 0.25
                spread: -cell.spotBlur
                blur: 2 * cell.spotBlur
                offset: Qt.vector2d(0, cell.elevation)
                cached: false
                Accessible.ignored: true
            }
        }
    }
}
