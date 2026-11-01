// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT

pragma ComponentBehavior: Bound
import QtQuick

SmallButtonBackground {
    id: root
    readonly property Material3AdvancedButtonParameters joined: parameters as Material3AdvancedButtonParameters
    readonly property real outerRadius: Math.min(width, height) / 2
    readonly property real innerRadius: joined ? joined.innerRadiusFor(control, outerRadius) : 0
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
