pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK

SK.StyleVariation {
    id: root
    required property Material3Style sourceStyle
    required property var metrics
    property real containerWidth: metrics.defaultWidth
    property real pressedRadius: sourceStyle.tokens.radiusSmall
    property real checkedRadius: sourceStyle.tokens.radiusMedium
    // QmlMaterial's XS zero dimensions mean content-size plus an optical inset.
    readonly property real opticalWidth: Math.max(containerWidth,
        metrics.iconSize + sourceStyle.tokens.spacingUnit * 2)
    readonly property real opticalHeight: Math.max(metrics.containerHeight,
        metrics.iconSize + sourceStyle.tokens.spacingUnit * 2)
    readonly property real horizontalInset: Math.max(sourceStyle.tokens.iconButtonInset,
        (sourceStyle.tokens.minimumTargetSize - opticalWidth) / 2)
    readonly property real verticalInset: Math.max(sourceStyle.tokens.iconButtonInset,
        (sourceStyle.tokens.minimumTargetSize - opticalHeight) / 2)
    readonly property SmallButtonParameters parameters: SmallButtonParameters {
        tokens: root.sourceStyle.tokens
        reduceMotion: root.sourceStyle.effectiveReducedMotion
        minimumIconSize: root.metrics.iconSize
        fillIconWhenChecked: true
    }
    control {
        padding: root.sourceStyle.tokens.iconButtonPadding
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
