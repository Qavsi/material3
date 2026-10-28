pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls.Basic as Basic
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

Basic.ToolTip {
    id: root
    readonly property Material3Theme tokens: (root.SK.StyleKit.style as Material3Style).tokens
    property string subhead: ""
    property Component actionItem: null
    readonly property bool rich: subhead.length > 0 || actionItem !== null
    width: Math.min(implicitWidth, root.tokens.tooltipMaximumWidth)
    padding: rich ? root.tokens.spacingMedium : root.tokens.spacingUnit
    leftPadding: rich ? root.tokens.spacingMedium : root.tokens.spacingSmall
    rightPadding: leftPadding
    delay: rich ? 0 : root.tokens.tooltipDelay
    timeout: rich ? -1 : 5000
    focus: rich
    closePolicy: rich ? Basic.Popup.CloseOnEscape | Basic.Popup.CloseOnPressOutside
        : Basic.Popup.CloseOnEscape | Basic.Popup.CloseOnPressOutsideParent | Basic.Popup.CloseOnReleaseOutsideParent
    font: rich ? root.tokens.bodyMedium : root.tokens.bodySmall
    contentItem: Item {
        implicitHeight: column.implicitHeight
        implicitWidth: Math.max(subheading.implicitWidth, description.implicitWidth, actionLoader.implicitWidth)
        Column {
            id: column
            width: parent.width
            spacing: root.tokens.spacingUnit
            Text {
                id: subheading
                width: parent.width
                visible: root.subhead.length > 0
                text: root.subhead
                font: root.tokens.titleSmall
                color: root.tokens.surfaceForeground
                wrapMode: Text.WordWrap
            }
            Text {
                id: description
                width: parent.width
                text: root.text
                font: root.font
                color: root.rich ? root.tokens.surfaceVariantForeground : root.tokens.inverseSurfaceForeground
                wrapMode: Text.WordWrap
            }
            Loader { id: actionLoader; width: parent.width; active: root.actionItem !== null; sourceComponent: root.actionItem }
        }
    }
    background: Rectangle {
        implicitWidth: root.rich ? 200 : 24
        implicitHeight: 24
        radius: root.rich ? root.tokens.radiusMedium : root.tokens.feedbackCornerRadius
        color: root.rich ? root.tokens.surfaceContainer : root.tokens.inverseSurface
    }
}
