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

    function contentOffsetFor(control): real {
        if (contentRole !== "connected" || !control.background)
            return contentOffset
        const background = control.background
        const height = Math.min(background.height, Math.max(paintHeight,
            control.implicitContentHeight + control.topPadding + control.bottomPadding))
        const outer = Math.min(background.width, height) / 2
        const innerOnRight = leading && !control.mirrored || trailing && control.mirrored
        const inner = innerOnRight ? background.topRightRadius : background.topLeftRadius
        const direction = (leading ? 1 : trailing ? -1 : 0) * (control.mirrored ? -1 : 1)
        return direction * (outer - inner) * 2 * JoinedRecipe.opticalBias
    }
}
