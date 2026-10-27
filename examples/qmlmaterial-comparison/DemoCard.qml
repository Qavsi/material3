pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

Column {
    id: root
    required property Material3Theme tokens
    required property string title
    property string gapNote: ""
    property real contentPadding: tokens.spacingMedium
    property real minimumContentWidth: 0
    default property alias samples: samplesColumn.data
    spacing: root.tokens.spacingSmall
    Text {
        width: parent.width
        font: root.tokens.titleMedium; color: root.tokens.surfaceForeground
        text: root.title
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
    }
    Rectangle {
        width: parent.width
        height: samplesViewport.implicitHeight + root.contentPadding * 2
        radius: root.tokens.radiusMedium
        color: root.tokens.surfaceContainer
        Flickable {
            anchors.fill: parent
            anchors.margins: root.contentPadding
            id: samplesViewport
            objectName: "comparison.card.samplesViewport"
            readonly property real focusMargin: root.minimumContentWidth > 0
                ? root.tokens.spacingUnit + root.tokens.focusRingWidth : 0
            readonly property bool overflowing: contentWidth > width
            implicitWidth: root.minimumContentWidth + focusMargin * 2
            implicitHeight: samplesColumn.implicitHeight + focusMargin * 2
                + (overflowing ? sampleScrollBar.implicitHeight + root.tokens.spacingUnit : 0)
            contentWidth: Math.max(width, root.minimumContentWidth + focusMargin * 2)
            contentHeight: height
            interactive: overflowing
            flickableDirection: Flickable.HorizontalFlick
            boundsBehavior: Flickable.StopAtBounds
            clip: overflowing

            function revealFocus() {
                samplesViewport.contentX = Math.max(0, Math.min(samplesViewport.contentWidth - samplesViewport.width,
                    samplesViewport.contentX))
                const focused = samplesViewport.Window.window?.activeFocusItem
                if (!samplesViewport.overflowing || !focused)
                    return
                let ancestor = focused
                while (ancestor && ancestor !== samplesColumn)
                    ancestor = ancestor.parent
                if (!ancestor)
                    return
                const left = focused.mapToItem(samplesViewport.contentItem, 0, 0).x - samplesViewport.focusMargin
                const right = left + focused.width + samplesViewport.focusMargin * 2
                let next = samplesViewport.contentX
                if (left < next)
                    next = left
                else if (right > next + samplesViewport.width)
                    next = right - samplesViewport.width
                samplesViewport.contentX = Math.max(0, Math.min(samplesViewport.contentWidth - samplesViewport.width, next))
            }
            onWidthChanged: Qt.callLater(samplesViewport.revealFocus)
            onContentWidthChanged: Qt.callLater(samplesViewport.revealFocus)
            Connections {
                target: samplesViewport.Window.window
                enabled: samplesViewport.overflowing
                function onActiveFocusItemChanged() { Qt.callLater(samplesViewport.revealFocus) }
            }
            Column {
                id: samplesColumn
                x: samplesViewport.focusMargin
                y: samplesViewport.focusMargin
                width: samplesViewport.contentWidth - samplesViewport.focusMargin * 2
                spacing: root.tokens.spacingSmall
            }
            SK.ScrollBar.horizontal: SK.ScrollBar {
                id: sampleScrollBar
                objectName: "comparison.card.sampleScrollBar"
                policy: SK.ScrollBar.AsNeeded
                // StyleKit does not fade a full-size scrollbar thumb like the Basic style.
                visible: samplesViewport.overflowing
            }
        }
    }
    Text {
        width: parent.width
        visible: root.gapNote.length > 0
        font: root.tokens.bodyMedium; color: root.tokens.surfaceVariantForeground
        text: root.gapNote
        textFormat: Text.PlainText
        wrapMode: Text.WordWrap
    }
}
