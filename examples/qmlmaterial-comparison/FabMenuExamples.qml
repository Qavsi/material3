// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT

pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Style
import Qavsi.Material3.Theme

Row {
    id: root
    required property Material3Theme tokens
    required property bool styleScopeReady
    objectName: "comparison.fabmenus"
    spacing: root.tokens.spacingMedium

    Repeater {
        model: [
            { key: "short", expanded: true, icon: "material:stars", actions: [qsTr("First"), qsTr("Second")] },
            { key: "long", expanded: false, icon: "material:star",
                actions: [qsTr("Reply"), qsTr("Reply all"), qsTr("Forward"), qsTr("Snooze"), qsTr("Archive"), qsTr("Label")] }
        ]
        delegate: FocusScope {
            id: cell
            required property var modelData
            readonly property bool expanded: toggle.checked
            readonly property string namePrefix: "comparison.fabmenu." + modelData.key
            readonly property bool canAnimate: root.styleScopeReady && visible && !toggleContent.reduceMotion
                && toggle.SK.StyleKit.transitionsEnabled && Window.window && Window.window.visible
                && Window.window.visibility !== Window.Minimized
            property real revealCount: expanded ? actionItems.count : 0
            property string lastAction: ""
            readonly property real naturalMenuWidth: {
                let widest = toggle.implicitWidth
                if (root.styleScopeReady) {
                    for (let index = 0; index < actionItems.count; ++index)
                        widest = Math.max(widest, actionItems.itemAt(index)?.implicitWidth ?? 0)
                }
                return widest + root.tokens.fabMenuEdgeInset * 2
            }
            objectName: cell.namePrefix
            width: Math.max(0, (root.width - root.spacing) / 2)
            height: root.tokens.fabMenuAreaHeight

            function closeMenu(): void { toggle.checked = false }
            function restoreTriggerFocus(): void {
                let focused = cell.Window.window?.activeFocusItem
                while (focused && focused !== cell) {
                    if (focused === viewport) {
                        toggle.forceActiveFocus(Qt.OtherFocusReason)
                        return
                    }
                    focused = focused.parent
                }
            }
            function navigate(event, index): void {
                if (!cell.expanded)
                    return
                if (event.key === Qt.Key_Escape) {
                    cell.closeMenu()
                    event.accepted = true
                    return
                }
                const backward = event.key === Qt.Key_Up || event.key === Qt.Key_Backtab
                    || event.key === Qt.Key_Tab && (event.modifiers & Qt.ShiftModifier)
                const forward = event.key === Qt.Key_Down || event.key === Qt.Key_Tab && !backward
                let nextIndex = -2
                if (backward && index >= 0) {
                    nextIndex = index - 1
                    while (nextIndex >= 0 && !actionItems.itemAt(nextIndex)?.activeFocusOnTab)
                        --nextIndex
                } else if (forward) {
                    nextIndex = index + 1
                    while (nextIndex < actionItems.count && !actionItems.itemAt(nextIndex)?.activeFocusOnTab)
                        ++nextIndex
                    if (nextIndex >= actionItems.count)
                        nextIndex = -2
                }
                const next = nextIndex === -1 ? toggle : nextIndex >= 0 ? actionItems.itemAt(nextIndex) : null
                if (!next || nextIndex < -1)
                    return
                next.forceActiveFocus(backward ? Qt.BacktabFocusReason : Qt.TabFocusReason)
                if (nextIndex >= 0)
                    viewport.contentY = Math.min(next.y, Math.max(0, viewport.contentHeight - viewport.height))
                event.accepted = true
            }
            onExpandedChanged: { if (!expanded) restoreTriggerFocus() }
            onCanAnimateChanged: { if (!canAnimate) sequence.complete() }
            Behavior on revealCount {
                enabled: cell.canAnimate
                NumberAnimation {
                    id: sequence
                    duration: root.tokens.fabMenuSequenceDuration
                    easing.type: root.tokens.shapeEasing
                }
            }

            Item {
                id: menu
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                width: Math.min(cell.naturalMenuWidth, cell.width)
                height: cell.height
                Flickable {
                    id: viewport
                    objectName: cell.namePrefix + ".viewport"
                    x: root.tokens.fabMenuEdgeInset
                    y: toggle.y - root.tokens.fabMenuTriggerSpacing - height
                    width: Math.max(0, menu.width - root.tokens.fabMenuEdgeInset * 2)
                    height: Math.min(contentHeight, Math.max(0, toggle.y - root.tokens.fabMenuTriggerSpacing))
                    contentWidth: width
                    contentHeight: entries.implicitHeight
                    interactive: cell.expanded && contentHeight > height
                    flickableDirection: Flickable.VerticalFlick
                    boundsBehavior: Flickable.StopAtBounds
                    clip: true
                    Item {
                        id: entries
                        width: viewport.width
                        implicitHeight: actionItems.count * toggle.implicitHeight
                            + Math.max(0, actionItems.count - 1) * root.tokens.fabMenuItemSpacing
                        height: implicitHeight
                        Repeater {
                            id: actionItems
                            model: cell.modelData.actions
                            delegate: SK.Button {
                                id: entry
                                required property string modelData
                                required property int index
                                readonly property bool revealed: index >= actionItems.count - Math.round(cell.revealCount)
                                readonly property bool inputEnabled: cell.expanded && revealed && alphaProgress > 0
                                readonly property bool canAnimate: cell.canAnimate
                                onCanAnimateChanged: { if (!canAnimate) finishAnimations() }
                                property real widthProgress: revealed ? 1 : 0
                                property real alphaProgress: revealed ? 1 : 0
                                objectName: cell.namePrefix + ".action." + index
                                SK.StyleVariation.variations: ["fabMenuAction"]
                                text: entry.modelData
                                font: root.tokens.titleMedium
                                icon.name: cell.modelData.icon
                                x: entries.width - width
                                y: entry.index * (entry.implicitHeight + root.tokens.fabMenuItemSpacing)
                                width: Math.min(implicitWidth, entries.width) * widthProgress
                                height: implicitHeight
                                opacity: alphaProgress
                                clip: widthProgress < 1
                                focusPolicy: inputEnabled ? Qt.StrongFocus : Qt.NoFocus
                                hoverEnabled: inputEnabled
                                Accessible.ignored: !inputEnabled
                                contentItem: Material3ButtonContent { control: entry }
                                containmentMask: QtObject {
                                    function contains(point: point): bool {
                                        return entry.inputEnabled && point.x >= 0 && point.x < entry.width
                                            && point.y >= 0 && point.y < entry.height
                                    }
                                }
                                function finishAnimations(): void {
                                    widthAnimation.complete()
                                    alphaAnimation.complete()
                                }
                                Behavior on widthProgress {
                                    enabled: cell.canAnimate
                                    NumberAnimation {
                                        id: widthAnimation
                                        duration: root.tokens.fabMenuSpatialDuration
                                        easing.type: root.tokens.shapeEasing
                                    }
                                }
                                Behavior on alphaProgress {
                                    enabled: cell.canAnimate
                                    NumberAnimation {
                                        id: alphaAnimation
                                        duration: root.tokens.fabMenuEffectDuration
                                    }
                                }
                                Keys.priority: Keys.BeforeItem
                                Keys.onPressed: event => cell.navigate(event, entry.index)
                                onClicked: {
                                    if (inputEnabled) {
                                        cell.lastAction = text
                                        cell.closeMenu()
                                    }
                                }
                            }
                        }
                    }
                }
                SK.Button {
                    id: toggle
                    objectName: cell.namePrefix + ".trigger"
                    x: Math.max(0, menu.width - root.tokens.fabMenuEdgeInset - width)
                    y: menu.height - root.tokens.fabMenuEdgeInset - height
                    checkable: true
                    checked: cell.modelData.expanded
                    SK.StyleVariation.variations: ["fabMenuToggle"]
                    icon.name: checked ? "material:close" : "material:add"
                    display: SK.Button.IconOnly
                    Accessible.name: checked ? qsTr("Close actions") : qsTr("Open actions")
                    Accessible.expandable: true
                    Accessible.expanded: cell.expanded
                    contentItem: Material3ButtonContent {
                        id: toggleContent
                        control: toggle
                        iconWidth: toggle.checked ? root.tokens.fabMenuCloseIconSize : toggleContent.parameters?.minimumIconSize ?? 0
                        iconHeight: iconWidth
                    }
                    Keys.priority: Keys.BeforeItem
                    Keys.onPressed: event => cell.navigate(event, -1)
                }
            }
        }
    }
}
