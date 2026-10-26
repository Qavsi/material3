// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT

pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK

SK.StyleVariation {
    id: variation
    required property var sourceStyle
    property bool leading: false
    property bool trailing: false
    property bool fillIconWhenChecked: false
    property bool split: false
    property bool segmented: false
    property var splitMetrics: null
    property real paintHeight: sourceStyle.tokens.smallHeight
    property real minimumIconSize: sourceStyle.tokens.smallIconSize
    property real horizontalPadding: sourceStyle.tokens.smallHorizontalPadding
    property real minimumWidth: sourceStyle.tokens.minimumTargetSize
    readonly property Material3JoinedButtonDelegate backgroundFactory: Material3JoinedButtonDelegate { }
    readonly property Material3AdvancedButtonParameters parameters: Material3AdvancedButtonParameters {
        tokens: variation.sourceStyle.tokens
        reduceMotion: variation.sourceStyle.effectiveReducedMotion
        leading: variation.leading
        trailing: variation.trailing
        fillIconWhenChecked: variation.fillIconWhenChecked
        split: variation.split
        segmented: variation.segmented
        splitMetrics: variation.splitMetrics
        paintHeight: variation.paintHeight
        minimumIconSize: variation.minimumIconSize
        contentRole: variation.segmented ? "segmented" : variation.split
            ? variation.trailing ? "splitTrailing" : "splitLeading" : "connected"
    }

    button {
        leftPadding: variation.horizontalPadding
        rightPadding: variation.horizontalPadding
        topPadding: 0
        bottomPadding: 0
        background {
            margins: 0
            data: variation.parameters
            delegate: variation.backgroundFactory.background
            width: Math.max(variation.sourceStyle.tokens.minimumTargetSize, variation.minimumWidth)
            height: Math.max(variation.sourceStyle.tokens.minimumTargetSize, variation.paintHeight)
            shadow.visible: false
        }
    }
}
