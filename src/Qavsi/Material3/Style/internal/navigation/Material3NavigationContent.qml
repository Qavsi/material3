pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.impl
import Qt.labs.StyleKit as SK
import Qavsi.Icons

Item {
    id: root
    required property T.AbstractButton control
    readonly property Material3NavigationParameters parameters: reader.background.data as Material3NavigationParameters
    readonly property bool barItem: parameters?.barItem ?? false
    readonly property bool packagedIcon: control.icon.name.indexOf(":") > 0
    readonly property bool showIcon: control.display !== T.AbstractButton.TextOnly
        && (control.icon.name.length > 0 || control.icon.source.toString().length > 0)
    readonly property bool showText: control.display !== T.AbstractButton.IconOnly && control.text.length > 0
    readonly property real iconSize: parameters?.tokens.navigationIconSize ?? control.icon.width
    readonly property real iconSlotWidth: barItem ? parameters.tokens.navigationBarIndicatorWidth : iconSize
    readonly property real iconSlotHeight: barItem ? parameters.tokens.navigationBarIndicatorHeight : iconSize
    readonly property real labelSpacing: barItem && showIcon && showText ? control.spacing : 0
    readonly property color color: barItem ? reader.text.second.color : reader.text.color

    implicitWidth: Math.max(showIcon ? iconSlotWidth : 0, showText ? Math.ceil(label.implicitWidth) : 0)
    implicitHeight: (showIcon ? iconSlotHeight : 0) + labelSpacing + (showText ? label.implicitHeight : 0)
    Accessible.ignored: true
    LayoutMirroring.enabled: false
    LayoutMirroring.childrenInherit: false

    SK.StyleReader {
        id: reader
        controlType: Number((root.control as T.TabButton) ? SK.StyleReader.TabButton
            : (root.control as T.Button)?.flat ? SK.StyleReader.FlatButton : SK.StyleReader.Button)
        enabled: root.control.enabled
        focused: root.control.visualFocus
        checked: root.control.checked
        hovered: root.control.hovered || root.control.pressed
        pressed: root.control.pressed
        palette: root.control.palette
    }
    Loader {
        id: iconLoader
        x: (root.width - width) / 2
        y: root.barItem ? 0 : (root.height - height) / 2
        width: root.iconSlotWidth
        height: root.iconSlotHeight
        active: root.showIcon
        sourceComponent: root.packagedIcon ? packagedIconDelegate : nativeIcon
    }
    Component {
        id: packagedIconDelegate
        Item {
            AppIcon {
                objectName: "material3.navigation.icon"
                anchors.centerIn: parent
                name: root.control.icon.name
                source: root.control.icon.source
                size: root.iconSize
                color: root.control.icon.color
                filled: root.control.checked
                appearance: root.parameters?.iconAppearance ?? null
                Accessible.ignored: true
            }
        }
    }
    Component {
        id: nativeIcon
        IconLabel {
            icon: root.control.icon
            display: T.AbstractButton.IconOnly
            font: root.control.font
            color: root.control.icon.color
            mirrored: root.control.mirrored
            Accessible.ignored: true
        }
    }
    Text {
        id: label
        objectName: "material3.navigation.label"
        x: (root.width - width) / 2
        y: root.showIcon ? root.iconSlotHeight + root.labelSpacing : (root.height - height) / 2
        width: Math.min(implicitWidth, root.width)
        visible: root.showText
        text: root.control.text
        color: root.color
        font: root.control.font
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        textFormat: Text.PlainText
        Accessible.ignored: true
    }
}
