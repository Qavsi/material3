// Opt-in QCM list content; native ItemDelegate owns text, input and accessibility.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme
import Qavsi.Icons

Item {
    id: root
    required property T.ItemDelegate control
    property string overline: ""
    property string supportingText: ""
    property string trailingText: ""
    property string trailingIconName: ""
    property int supportingMaximumLineCount: 1
    readonly property Material3Theme tokens: (control.SK.StyleKit.style as Material3Style).tokens
    property real iconWidth: tokens.listCardIconSize
    property real iconHeight: tokens.listCardIconSize
    readonly property bool hasIcon: control.display !== T.AbstractButton.TextOnly
        && (control.icon.name.length > 0 || control.icon.source.toString().length > 0)
    readonly property color color: reader.text.color
    implicitWidth: row.implicitWidth
    implicitHeight: row.implicitHeight
    Accessible.ignored: true
    LayoutMirroring.enabled: false
    LayoutMirroring.childrenInherit: false

    SK.StyleReader {
        id: reader
        controlType: Number(SK.StyleReader.ItemDelegate)
        enabled: root.control.enabled
        focused: root.control.visualFocus
        checked: root.control.checked
        hovered: root.control.hovered
        pressed: root.control.pressed
        highlighted: root.control.highlighted
        palette: root.control.palette
    }
    RowLayout {
        id: row
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        spacing: root.control.spacing
        layoutDirection: root.control.mirrored ? Qt.RightToLeft : Qt.LeftToRight
        AppIcon {
            visible: root.hasIcon
            Layout.preferredWidth: root.iconWidth
            Layout.preferredHeight: root.iconHeight
            name: root.control.icon.name
            source: root.control.icon.source
            size: Math.min(root.iconWidth, root.iconHeight)
            color: root.control.icon.color
            Accessible.ignored: true
        }
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 0
            Text {
                visible: root.overline.length > 0
                Layout.fillWidth: true
                text: root.overline
                font: root.tokens.labelMedium
                color: root.control.enabled ? root.tokens.surfaceVariantForeground : root.tokens.disabledLabel
                elide: Text.ElideRight
                textFormat: Text.PlainText
            }
            Text {
                Layout.fillWidth: true
                visible: root.control.display !== T.AbstractButton.IconOnly
                text: root.control.text
                font: root.control.font
                color: root.color
                elide: Text.ElideRight
                textFormat: Text.PlainText
            }
            Text {
                visible: root.supportingText.length > 0
                Layout.fillWidth: true
                text: root.supportingText
                font: root.tokens.bodyMedium
                color: root.control.enabled ? root.tokens.surfaceVariantForeground : root.tokens.disabledLabel
                wrapMode: Text.WordWrap
                maximumLineCount: root.supportingMaximumLineCount
                elide: Text.ElideRight
                textFormat: Text.PlainText
            }
        }
        Text {
            visible: root.trailingText.length > 0
            text: root.trailingText
            font: root.tokens.bodySmall
            color: root.control.enabled ? root.tokens.surfaceVariantForeground : root.tokens.disabledLabel
            textFormat: Text.PlainText
        }
        AppIcon {
            visible: root.trailingIconName.length > 0
            Layout.preferredWidth: root.tokens.listCardIconSize
            Layout.preferredHeight: root.tokens.listCardIconSize
            name: root.trailingIconName
            size: root.tokens.listCardIconSize
            color: root.color
            Accessible.ignored: true
        }
    }
}
