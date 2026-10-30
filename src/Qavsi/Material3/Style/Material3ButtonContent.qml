// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT

pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import QtQuick.Controls.impl
import Qt.labs.StyleKit as SK
import Qavsi.Icons

Item {
    id: root
    required property T.Button control
    readonly property SmallButtonParameters parameters: reader.background.data as SmallButtonParameters
    readonly property Material3AdvancedButtonParameters advanced: parameters as Material3AdvancedButtonParameters
    readonly property color color: reader.text.color
    readonly property bool fab: parameters?.contentRole === "fab"
    readonly property bool selectedMark: advanced?.segmented === true && control.checked
    readonly property bool splitTrailing: parameters?.contentRole === "splitTrailing"
    readonly property bool stacked: control.display === T.AbstractButton.TextUnderIcon
    readonly property bool packagedIcon: control.icon.name.indexOf(":") > 0
    readonly property bool iconFilled: parameters?.fillIconWhenChecked === true && control.checked
    readonly property bool materialIconFill: parameters?.fillIconWhenChecked === true
        && control.icon.name.indexOf("material:") === 0
    readonly property bool hasIcon: control.icon.name.length > 0 || control.icon.source.toString().length > 0
    readonly property bool showIcon: selectedMark || control.display !== T.AbstractButton.TextOnly && hasIcon
    readonly property bool showText: control.display !== T.AbstractButton.IconOnly && control.text.length > 0
    property real iconWidth: parameters?.minimumIconSize ?? control.icon.width
    property real iconHeight: parameters?.minimumIconSize ?? control.icon.height
    readonly property bool expanded: fab && showText && (!showIcon || parameters.expanded)
    readonly property bool reduceMotion: parameters?.reduceMotion ?? true
    property bool ready: false
    readonly property bool canAnimate: ready && !reduceMotion && visible && control.visible
        && control.SK.StyleKit.transitionsEnabled && Window.window && Window.window.visible
        && Window.window.visibility !== Window.Minimized
    readonly property bool canAnimateIconFill: canAnimate && materialIconFill && showIcon && !selectedMark
    property real iconFillProgress: iconFilled ? 1 : 0
    // QCM rounds toward the target in quarter-axis steps in both directions.
    readonly property real iconFillValue: Math.max(0, Math.min(1,
        (iconFilled ? Math.ceil(iconFillProgress * 4) : Math.floor(iconFillProgress * 4)) / 4))
    readonly property QtObject filledIconAppearance: QtObject {
        id: fillAppearance
        readonly property var sourceAppearance: root.parameters?.iconAppearance
        readonly property var weight: fillAppearance.sourceAppearance?.weight
        readonly property var opticalSize: fillAppearance.sourceAppearance?.opticalSize
        readonly property var grade: fillAppearance.sourceAppearance?.grade
        readonly property var renderType: fillAppearance.sourceAppearance?.renderType
        readonly property var axes: ({ "FILL": root.iconFillValue })
    }
    property real expansionProgress: expanded ? 1 : 0
    property real iconRotation: splitTrailing && control.highlighted ? 180 : 0
    property real iconOffset: splitTrailing && control.highlighted ? advanced?.splitMetrics?.opticalOffset ?? 0 : 0
    property real contentOffset: advanced ? advanced.contentOffsetFor(control) : parameters?.contentOffset ?? 0
    readonly property real collapsedExtent: Math.max(parameters?.paintHeight ?? 0, iconWidth, iconHeight)
    readonly property real expandedExtent: Math.max(collapsedExtent, advanced?.minimumExpandedWidth ?? 0,
        Math.ceil(label.implicitWidth) + (showIcon ? iconWidth + control.spacing : 0)
            + (showIcon ? advanced?.leadingInset ?? 0 : advanced?.trailingInset ?? 0)
            + (advanced?.trailingInset ?? 0))
    implicitWidth: fab ? Math.max(0, collapsedExtent + (expandedExtent - collapsedExtent) * expansionProgress
        - control.leftPadding - control.rightPadding) : grid.implicitWidth
    implicitHeight: grid.implicitHeight
    clip: fab
    Accessible.ignored: true
    LayoutMirroring.enabled: false
    LayoutMirroring.childrenInherit: false

    function finishAnimations(): void {
        expansionAnimation.complete()
        rotationAnimation.complete()
        iconOffsetAnimation.complete()
        offsetAnimation.complete()
    }
    onCanAnimateChanged: { if (!canAnimate) finishAnimations() }
    onCanAnimateIconFillChanged: { if (!canAnimateIconFill) iconFillAnimation.complete() }
    Component.onCompleted: ready = true

    SK.StyleReader {
        id: reader
        controlType: Number(root.control.flat ? SK.StyleReader.FlatButton : SK.StyleReader.Button)
        palette: root.control.palette
        enabled: root.control.enabled
        focused: root.control.visualFocus
        checked: root.control.checked
        hovered: root.control.hovered || root.control.pressed
        pressed: root.control.down
        highlighted: root.control.highlighted
    }
    Behavior on iconFillProgress {
        enabled: root.canAnimateIconFill
        NumberAnimation {
            id: iconFillAnimation
            duration: root.parameters?.tokens.iconFillMotionDuration ?? 0
            easing.type: Easing.Linear
        }
    }
    Behavior on expansionProgress {
        enabled: root.canAnimate
        NumberAnimation { id: expansionAnimation; duration: root.parameters?.tokens.shapeDuration ?? 0 }
    }
    Behavior on iconRotation {
        enabled: root.canAnimate
        NumberAnimation { id: rotationAnimation; duration: root.parameters?.tokens.shapeDuration ?? 0 }
    }
    Behavior on iconOffset {
        enabled: root.canAnimate
        NumberAnimation { id: iconOffsetAnimation; duration: root.parameters?.tokens.shapeDuration ?? 0 }
    }
    Behavior on contentOffset {
        enabled: root.canAnimate && root.parameters?.contentRole !== "connected"
        NumberAnimation { id: offsetAnimation; duration: root.parameters?.tokens.shapeDuration ?? 0 }
    }

    GridLayout {
        id: grid
        x: (root.width - width) / 2 + root.contentOffset
            + (root.fab && root.showIcon ? ((root.advanced?.leadingInset ?? 0)
                - (root.advanced?.trailingInset ?? 0)) / 2 * root.expansionProgress
                * (root.control.mirrored ? -1 : 1) : 0)
        y: (root.height - height) / 2
        width: Math.min(implicitWidth, root.width)
        height: Math.min(implicitHeight, root.height)
        columns: root.stacked ? 1 : 2
        rows: root.stacked ? 2 : 1
        rowSpacing: root.control.spacing
        columnSpacing: root.control.spacing * (root.fab ? root.expansionProgress : 1)
        layoutDirection: root.control.mirrored ? Qt.RightToLeft : Qt.LeftToRight

        Item {
            visible: root.showIcon
            Layout.alignment: Qt.AlignCenter
            Layout.preferredWidth: root.iconWidth
            Layout.preferredHeight: root.iconHeight
            Loader {
                anchors.fill: parent
                active: !root.selectedMark && root.showIcon
                sourceComponent: root.packagedIcon ? packageIcon : nativeIcon
                rotation: root.iconRotation
                transform: Translate {
                    x: (root.control.mirrored ? 1 : -1) * root.iconOffset
                }
            }
            Component {
                id: packageIcon
                AppIcon {
                    objectName: "material3.button.icon"
                    name: root.control.icon.name
                    source: root.control.icon.source
                    size: Math.min(root.iconWidth, root.iconHeight)
                    color: root.control.icon.color
                    filled: root.iconFilled
                    appearance: root.materialIconFill ? root.filledIconAppearance
                        : root.parameters?.iconAppearance ?? null
                }
            }
            Component {
                id: nativeIcon
                // Keep Qt's native name/source handling for unpackaged QIcon consumers.
                IconLabel {
                    icon {
                        name: root.control.icon.name
                        source: root.control.icon.source
                        color: root.control.icon.color
                        cache: root.control.icon.cache
                        width: root.iconWidth
                        height: root.iconHeight
                    }
                    display: T.AbstractButton.IconOnly
                    mirrored: root.control.mirrored
                    font: root.control.font
                    color: root.color
                    Accessible.ignored: true
                }
            }
            Item {
                anchors.fill: parent
                visible: root.selectedMark
                // Normalized checkmark geometry; stroke comes from its semantic token.
                Rectangle {
                    x: parent.width * 0.19
                    y: parent.height * 0.48
                    width: parent.width * 0.29
                    height: root.parameters?.tokens.selectionMarkStrokeWidth ?? 0
                    rotation: 45
                    transformOrigin: Item.Left
                    color: root.color
                    antialiasing: true
                }
                Rectangle {
                    x: parent.width * 0.39
                    y: parent.height * 0.68
                    width: parent.width * 0.54
                    height: root.parameters?.tokens.selectionMarkStrokeWidth ?? 0
                    rotation: -45
                    transformOrigin: Item.Left
                    color: root.color
                    antialiasing: true
                }
            }
        }
        Text {
            id: label
            objectName: "material3.button.label"
            visible: root.fab ? root.control.text.length > 0 && root.expansionProgress > 0 : root.showText
            Layout.alignment: Qt.AlignCenter
            Layout.fillWidth: true
            // GridLayout rounds allocated pixels; reserve the ceiling to keep fractional glyph advances visible.
            Layout.preferredWidth: Math.ceil(label.implicitWidth * (root.fab ? root.expansionProgress : 1))
            Layout.maximumWidth: root.fab ? Math.ceil(label.implicitWidth * root.expansionProgress) : Number.POSITIVE_INFINITY
            text: root.control.text
            font: root.control.font
            color: root.color
            textFormat: Text.PlainText
            elide: root.parameters?.contentRole === "fabMenuAction" ? Text.ElideNone : Text.ElideRight
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            opacity: root.fab ? root.expansionProgress : 1
            Accessible.ignored: true
        }
    }
}
