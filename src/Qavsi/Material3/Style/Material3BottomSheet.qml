// QCM 229bc3e6 BottomSheet geometry/roles, adapted to native Qt Drawer behavior (MIT).
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as Basic
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

Material3Drawer {
    id: root
    default property alias content: body.data
    property bool showDragHandle: true
    readonly property Material3Style sourceStyle: parent?.SK.StyleKit.style as Material3Style
    readonly property Material3Theme fallbackTokens: Material3Theme {}
    readonly property int sheetMotionDuration: motionDuration > 0 ? tokens.bottomSheetMotionDuration : 0
    tokens: sourceStyle?.tokens ?? fallbackTokens
    reducedMotion: sourceStyle?.effectiveReducedMotion ?? true
    parent: Basic.Overlay.overlay
    edge: Qt.BottomEdge
    width: parent ? (parent.width >= tokens.bottomSheetMaximumWidth + tokens.bottomSheetWideMargin * 2
        ? tokens.bottomSheetMaximumWidth : parent.width) : 0
    x: parent ? (parent.width - width) / 2 : 0
    height: Math.min(implicitHeight, Math.max(0, (parent?.height ?? 0) - tokens.bottomSheetTopMargin))
    implicitHeight: implicitContentHeight + topPadding + bottomPadding
    padding: 0
    topPadding: (showDragHandle ? tokens.bottomSheetHandleTarget : 0) + SafeArea.margins.top
    focus: modal
    closePolicy: modal ? Basic.Popup.CloseOnEscape | Basic.Popup.CloseOnPressOutside : Basic.Popup.NoAutoClose
    onAboutToShow: {
        viewport.cancelFlick()
        viewport.contentY = 0
    }
    onAboutToHide: viewport.cancelFlick()
    onSheetMotionDurationChanged: {
        if (sheetMotionDuration === 0) {
            handleWidthMotion.complete()
            handleHeightMotion.complete()
        }
    }
    enter: Transition {
        NumberAnimation {
            property: "position"
            duration: root.sheetMotionDuration
            easing.type: Easing.BezierSpline
            easing.bezierCurve: root.tokens.bottomSheetEnterEasingCurve
        }
    }
    exit: Transition {
        NumberAnimation {
            property: "position"
            duration: root.sheetMotionDuration
            easing.type: Easing.BezierSpline
            easing.bezierCurve: root.tokens.bottomSheetExitEasingCurve
        }
    }
    Basic.Overlay.modal: Rectangle {
        anchors.fill: parent
        color: Qt.alpha(root.tokens.scrim, root.tokens.appNavigationScrimOpacity)
    }
    contentItem: Flickable {
        id: viewport
        implicitHeight: body.implicitHeight
        contentWidth: width
        contentHeight: body.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        flickableDirection: Flickable.VerticalFlick
        interactive: root.opened && contentHeight > height
        SK.ScrollBar.vertical: SK.ScrollBar {}
        Item {
            id: body
            width: parent.width
            implicitHeight: Math.max(0, childrenRect.y + childrenRect.height)
            height: implicitHeight
        }
    }
    background: SK.Pane {
        id: surface
        readonly property bool dragging: sheetPointer.active && root.position > 0 && root.position < 1
        SK.StyleVariation.variations: ["bottomSheetSurface"]
        Accessible.ignored: true
        Material3Elevation {
            z: -1
            anchors.fill: parent
            tokens: root.tokens
            reducedMotion: root.effectiveReducedMotion
            color: root.tokens.shadow
            cornerRadii: Qt.vector4d(root.tokens.radiusExtraLarge, root.tokens.radiusExtraLarge, 0, 0)
            targetElevation: root.visible ? root.tokens.elevationLevel1 : root.tokens.elevationLevel0
        }
        PointHandler {
            id: sheetPointer
            enabled: root.interactive && root.showDragHandle
        }
        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            height: root.tokens.bottomSheetHandleTarget
            visible: root.showDragHandle
            Accessible.ignored: true
            HoverHandler {
                id: handleHover
                enabled: root.interactive
                cursorShape: surface.dragging ? Qt.ClosedHandCursor : Qt.OpenHandCursor
            }
            Rectangle {
                anchors.centerIn: parent
                width: surface.dragging ? root.tokens.bottomSheetHandlePressedWidth : root.tokens.bottomSheetHandleWidth
                height: surface.dragging ? root.tokens.bottomSheetHandlePressedHeight : root.tokens.bottomSheetHandleHeight
                radius: height / 2
                color: surface.dragging ? root.tokens.surfaceForeground : root.tokens.outline
                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: Qt.alpha(root.tokens.inverseSurfaceForeground,
                        handleHover.hovered && !surface.dragging ? root.tokens.hoverOpacity : 0)
                }
                Behavior on width {
                    enabled: root.sheetMotionDuration > 0
                    NumberAnimation {
                        id: handleWidthMotion
                        duration: root.tokens.bottomSheetHandleMotionDuration
                        easing.type: Easing.Linear
                    }
                }
                Behavior on height {
                    enabled: root.sheetMotionDuration > 0
                    NumberAnimation {
                        id: handleHeightMotion
                        duration: root.tokens.bottomSheetHandleMotionDuration
                        easing.type: Easing.Linear
                    }
                }
            }
        }
    }
}
