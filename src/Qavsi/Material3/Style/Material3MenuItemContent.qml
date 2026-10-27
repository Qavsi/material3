pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.impl
import Qt.labs.StyleKit as SK
import Qavsi.Icons

Item {
    id: root
    required property T.MenuItem control
    readonly property SK.StyleReader reader: readerLoader.status === Loader.Ready ? readerLoader.item as SK.StyleReader : null
    readonly property Material3MenuParameters parameters: reader?.background.data as Material3MenuParameters
    readonly property color color: reader?.text.color ?? control.palette.buttonText
    property bool readerReady: false
    readonly property bool packaged: control.icon.name.indexOf(":") > 0
    readonly property bool showPackage: packaged && control.display !== T.AbstractButton.TextOnly
    readonly property bool showText: control.text.length > 0 && control.display !== T.AbstractButton.IconOnly
    readonly property bool stacked: control.display === T.AbstractButton.TextUnderIcon
    readonly property real iconSlot: showPackage && !stacked ? control.icon.width + (showText ? control.spacing : 0) : 0
    readonly property real stackedSlot: showPackage && stacked ? control.icon.height + (showText ? control.spacing : 0) : 0
    implicitWidth: stacked ? Math.max(label.implicitWidth, showPackage ? control.icon.width : 0)
        : label.implicitWidth + iconSlot
    implicitHeight: stacked ? label.implicitHeight + stackedSlot
        : Math.max(label.implicitHeight, showPackage ? control.icon.height : 0)
    Component.onCompleted: Qt.callLater(() => root.readerReady = true)
    Accessible.ignored: true
    LayoutMirroring.enabled: false
    LayoutMirroring.childrenInherit: false

    // Qt 6.12 resets readers while a native menu item completes; bind after that reset.
    Loader {
        id: readerLoader
        active: root.readerReady
        sourceComponent: SK.StyleReader {
            controlType: root.control.SK.StyleVariation.controlType
            palette: root.control.palette
            enabled: root.control.enabled
            focused: root.control.activeFocus
            checked: root.control.checked
            hovered: root.control.hovered
            pressed: root.control.down
            highlighted: root.control.highlighted
        }
    }
    // Keep Qt's mnemonic, shortcut and native icon layout; replace only packaged glyph drawing.
    MenuItemIconLabel {
        id: label
        x: root.control.mirrored ? 0 : root.iconSlot
        y: root.stackedSlot
        width: Math.max(0, root.width - root.iconSlot)
        height: Math.max(0, root.height - root.stackedSlot)
        menuItem: root.control
        spacing: root.control.spacing
        mirrored: root.control.mirrored
        display: root.control.display
        text: root.control.text
        font: root.control.font
        color: root.color
        alignment: root.reader?.text.alignment ?? (Qt.AlignLeft | Qt.AlignVCenter)
        topPadding: root.reader?.text.topPadding ?? 0
        bottomPadding: root.reader?.text.bottomPadding ?? 0
        leftPadding: root.reader?.text.leftPadding ?? 0
        rightPadding: root.reader?.text.rightPadding ?? 0
        icon {
            name: root.packaged ? "" : root.control.icon.name
            source: root.packaged ? "" : root.control.icon.source
            color: root.control.icon.color
            width: root.control.icon.width
            height: root.control.icon.height
            cache: root.control.icon.cache
        }
        Accessible.ignored: true
    }
    AppIcon {
        visible: root.showPackage
        width: root.control.icon.width
        height: root.control.icon.height
        x: root.stacked || !root.showText ? (root.width - width) / 2
            : root.control.mirrored ? root.width - width : 0
        y: root.stacked ? 0 : (root.height - height) / 2
        name: root.control.icon.name
        source: root.control.icon.source
        size: Math.min(width, height)
        color: root.control.icon.color
        appearance: root.parameters?.iconAppearance ?? null
        Accessible.ignored: true
    }
}
