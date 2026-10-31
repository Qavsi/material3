pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

SK.StyleVariation {
    id: root
    required property Material3Style sourceStyle
    property Material3Theme tokens: sourceStyle.tokens
    required property var metrics
    property real containerWidth: metrics.defaultWidth
    property real pressedRadius: tokens.radiusSmall
    property real checkedRadius: tokens.radiusMedium
    // QmlMaterial's XS zero dimensions mean content-size plus an optical inset.
    readonly property real opticalWidth: Math.max(containerWidth,
        metrics.iconSize + tokens.spacingUnit * 2)
    readonly property real opticalHeight: Math.max(metrics.containerHeight,
        metrics.iconSize + tokens.spacingUnit * 2)
    readonly property real horizontalInset: Math.max(tokens.iconButtonInset,
        (tokens.minimumTargetSize - opticalWidth) / 2)
    readonly property real verticalInset: Math.max(tokens.iconButtonInset,
        (tokens.minimumTargetSize - opticalHeight) / 2)
    readonly property SmallButtonParameters parameters: SmallButtonParameters {
        tokens: root.tokens
        reduceMotion: root.sourceStyle.effectiveReducedMotion
        minimumIconSize: root.metrics.iconSize
        fillIconWhenChecked: true
    }
    control {
        padding: root.tokens.iconButtonPadding
        spacing: 0
        background {
            width: root.opticalWidth
            height: root.opticalHeight
            leftMargin: root.horizontalInset
            rightMargin: root.horizontalInset
            topMargin: root.verticalInset
            bottomMargin: root.verticalInset
            radius: root.opticalHeight / 2
            data: root.parameters
        }
        pressed.background.radius: root.pressedRadius
        checked.background.radius: root.checkedRadius
        checked.pressed.background.radius: root.pressedRadius
    }
}
