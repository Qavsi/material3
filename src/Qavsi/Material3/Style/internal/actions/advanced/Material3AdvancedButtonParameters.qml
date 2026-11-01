// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT

pragma ComponentBehavior: Bound
import QtQuick
import "Material3JoinedRecipe.js" as JoinedRecipe

SmallButtonParameters {
    property bool leading: false
    property bool trailing: false
    property bool segmented: false
    property bool split: false
    property var splitMetrics: null
    property real minimumExpandedWidth: 0
    property real leadingInset: 0
    property real trailingInset: 0

    function innerRadiusFor(control, outerRadius): real {
        if (segmented)
            return 0
        if (!control.down && ((!split && control.checked)
            || (split && trailing && control.highlighted)))
            return outerRadius
        const requested = control.down
            ? split ? splitMetrics.pressedRadius : tokens.radiusSmall
            : split && leading && control.hovered ? splitMetrics.hoverRadius
                : split ? splitMetrics.idleRadius : tokens.radiusMedium
        return Math.min(outerRadius, requested)
    }

    function contentOffsetFor(control): real {
        if (contentRole !== "connected" || !control.background)
            return contentOffset
        const background = control.background
        const height = Math.min(background.height, Math.max(paintHeight,
            control.implicitContentHeight + control.topPadding + control.bottomPadding))
        const outer = Math.min(background.width, height) / 2
        const inner = innerRadiusFor(control, outer)
        const direction = (leading ? 1 : trailing ? -1 : 0) * (control.mirrored ? -1 : 1)
        return direction * (outer - inner) * 2 * JoinedRecipe.opticalBias
    }
}
