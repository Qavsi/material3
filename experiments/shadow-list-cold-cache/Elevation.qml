pragma ComponentBehavior: Bound
import QtQuick
import Qavsi.Material3.Theme
import Qavsi.Material3.Style

Item {
    id: root
    objectName: "material3.elevation"
    required property Material3Theme tokens
    required property bool reducedMotion
    required property color color
    required property vector4d cornerRadii
    property real targetElevation: 0
    property real elevation: Math.max(0, targetElevation)
    property bool ready: false
    readonly property bool uniformCorners: cornerRadii.x === cornerRadii.y
        && cornerRadii.x === cornerRadii.z && cornerRadii.x === cornerRadii.w
    readonly property bool hardware: GraphicsInfo.api !== GraphicsInfo.Software
        && GraphicsInfo.api !== GraphicsInfo.Unknown
        && (GraphicsInfo.api !== GraphicsInfo.OpenGL || GraphicsInfo.majorVersion >= 3)
    readonly property bool animationRunning: elevationMotion.running
    readonly property string rendererName: !hardware || !visible || elevation <= 0
        ? "none" : uniformCorners ? "analytic" : "blur"
    Accessible.ignored: true

    Behavior on elevation {
        enabled: root.ready && !root.reducedMotion && root.visible
        NumberAnimation {
            id: elevationMotion
            duration: root.tokens.elevationDuration
            easing.type: Easing.BezierSpline
            easing.bezierCurve: root.tokens.elevationEasingCurve
        }
    }
    onReducedMotionChanged: {
        if (reducedMotion)
            elevationMotion.complete()
    }
    onVisibleChanged: {
        if (!visible)
            elevationMotion.complete()
    }
    Component.onCompleted: ready = true

    Loader {
        anchors.fill: parent
        active: root.rendererName !== "none"
        sourceComponent: root.uniformCorners ? analytic : blurred
    }
    Component {
        id: analytic
        RoundedRectShadow {
            objectName: "material3.shadow"
            elevation: root.elevation
            cornerRadii: root.cornerRadii
            color: root.color
            ambientOpacity: root.tokens.shadowAmbientOpacity
            spotOpacity: root.tokens.shadowSpotOpacity
            lightDirection: root.tokens.shadowLightDirection
            lightRadius: root.tokens.shadowLightRadiusRatio
            Accessible.ignored: true
        }
    }
    Component {
        id: blurred
        BlurMaskShadow {
            objectName: "material3.shadow.blur"
            sigma: Math.max(root.elevation * root.tokens.shadowBlurSigmaFactor,
                root.tokens.shadowBlurMinimumSigma)
            color: Qt.alpha(root.color, root.color.a * root.tokens.shadowBlurOpacity)
            cornerRadii: root.cornerRadii
            Accessible.ignored: true
        }
    }
}
