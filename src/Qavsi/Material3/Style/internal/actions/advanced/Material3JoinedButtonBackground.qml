// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT

pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Templates as T

SmallButtonBackground {
    id: root
    readonly property T.Button nativeButton: control as T.Button
    readonly property Material3AdvancedButtonParameters joined: parameters as Material3AdvancedButtonParameters
    readonly property real outerRadius: Math.min(width, height) / 2
    readonly property real innerRadius: {
        if (!joined || joined.segmented)
            return 0
        if (!control.down && ((!joined.split && control.checked)
            || (joined.split && joined.trailing && nativeButton?.highlighted)))
            return outerRadius
        const metrics = joined.splitMetrics
        const requested = control.down
            ? joined.split ? metrics.pressedRadius : tokens.radiusSmall
            : joined.split && joined.leading && control.hovered ? metrics.hoverRadius
                : joined.split ? metrics.idleRadius : tokens.radiusMedium
        return Math.min(outerRadius, requested)
    }
    readonly property bool leadingOnLeft: joined && (joined.leading && !control.mirrored
        || joined.trailing && control.mirrored)
    readonly property bool trailingOnRight: joined && (joined.trailing && !control.mirrored
        || joined.leading && control.mirrored)
    cornerRadii: Qt.vector4d(leadingOnLeft ? outerRadius : innerRadius,
        trailingOnRight ? outerRadius : innerRadius,
        leadingOnLeft ? outerRadius : innerRadius,
        trailingOnRight ? outerRadius : innerRadius)
    objectName: "material3.joinedButtonBackground"
}
