// QmlMaterial 0.6.1 chip content recipe (MIT), adapted to native StyleKit buttons.
pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme
import Qavsi.Icons

Item {
    id: root
    required property T.Button control
    property bool elevated: false
    property Item leadingItem: null
    property bool edit: false
    property Component editDelegate: null
    property T.Action trailingAction: null
    property string trailingIconName: ""
    readonly property Material3ChipParameters parameters: reader.background.data as Material3ChipParameters
    readonly property Material3Theme tokens: parameters?.tokens ?? (control.SK.StyleKit.style as Material3Style)?.tokens
    readonly property string kind: parameters?.kind ?? "assist"
    readonly property bool filter: kind === "filter"
    readonly property bool selected: control.checked && (filter || kind === "input" || kind === "embed")
    readonly property bool hasIcon: control.display !== T.AbstractButton.TextOnly
        && (control.icon.name.length > 0 || control.icon.source.toString().length > 0)
    readonly property bool showText: control.display !== T.AbstractButton.IconOnly && control.text.length > 0
    readonly property bool editing: edit && editDelegate !== null
    readonly property bool customLeading: leadingItem !== null
    readonly property real leadingWidth: customLeading ? Math.max(leadingItem.width, leadingItem.implicitWidth) : iconWidth
    readonly property real leadingHeight: customLeading ? Math.max(leadingItem.height, leadingItem.implicitHeight) : iconHeight
    readonly property bool leadingVisible: customLeading || (filter ? selectionProgress > 0 : hasIcon)
    readonly property bool nativeTrailing: filter && hasIcon
    readonly property bool actionTrailing: trailingAction !== null
    readonly property bool trailingVisible: actionTrailing || nativeTrailing || trailingIconName.length > 0
    readonly property real gap: kind === "embed" ? tokens.chipEmbedSpacing : control.spacing
    property real iconWidth: tokens.chipIconSize
    property real iconHeight: tokens.chipIconSize
    readonly property color color: reader.text.color
    readonly property color defaultIconColor: !control.enabled ? tokens.disabledLabel
        : selected ? color : kind === "assist" || kind === "suggestion" ? tokens.chipIconInk : color
    readonly property color iconColor: control.icon.color === color ? defaultIconColor : control.icon.color
    readonly property real leadingCorrection: kind === "dismiss" ? 0
        : (tokens.chipIconPadding - tokens.chipPadding) * (customLeading ? 1 : filter ? paddingProgress : hasIcon ? 1 : 0)
    readonly property real trailingCorrection: trailingVisible ? tokens.chipIconPadding - tokens.chipPadding : 0
    readonly property real leftCorrection: control.leftPadding !== tokens.chipPadding ? 0
        : control.mirrored ? trailingCorrection : leadingCorrection
    readonly property real rightCorrection: control.rightPadding !== tokens.chipPadding ? 0
        : control.mirrored ? leadingCorrection : trailingCorrection
    readonly property bool canAnimate: ready && !editing && !parameters?.reducedMotion && visible && control.visible
        && opacity > 0 && control.opacity > 0
        && control.SK.StyleKit.transitionsEnabled && Window.window && Window.window.visible
        && Window.window.visibility !== Window.Minimized
    property real selectionProgress: filter && control.checked ? 1 : 0
    property real paddingProgress: filter && control.checked ? 1 : 0
    property bool ready: false
    implicitWidth: editing ? editor.implicitWidth : Math.max(0, row.implicitWidth + leftCorrection + rightCorrection)
    implicitHeight: editing ? editor.implicitHeight : row.implicitHeight
    Accessible.ignored: true
    LayoutMirroring.enabled: false
    LayoutMirroring.childrenInherit: false

    function focusEditor(): void {
        if (!root.control.enabled || editor.status !== Loader.Ready)
            return
        const editorItem = editor.item as Item
        if (editorItem)
            editorItem.forceActiveFocus(Qt.OtherFocusReason)
    }

    Component.onCompleted: ready = true
    onCanAnimateChanged: if (!canAnimate) { selectionAnimation.complete(); paddingAnimation.complete() }
    Behavior on selectionProgress {
        enabled: root.canAnimate
        NumberAnimation { id: selectionAnimation; duration: root.tokens.chipSelectionDuration; easing.type: root.tokens.chipSelectionEasing }
    }
    Behavior on paddingProgress {
        enabled: root.canAnimate
        NumberAnimation { id: paddingAnimation; duration: root.tokens.chipPaddingDuration; easing.type: root.tokens.chipPaddingEasing }
    }
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
    Loader {
        id: editor
        anchors.fill: parent
        active: root.editing
        sourceComponent: root.editDelegate
        onLoaded: root.focusEditor()
    }
    Connections {
        target: root.control
        function onFocusChanged(): void {
            if (root.control.focus)
                root.focusEditor()
        }
    }
    RowLayout {
        id: row
        visible: !root.editing
        x: (root.width - (width + root.leftCorrection + root.rightCorrection)) / 2 + root.leftCorrection
        y: (root.height - height) / 2
        width: Math.max(0, root.width - root.leftCorrection - root.rightCorrection)
        height: implicitHeight
        spacing: 0
        layoutDirection: root.control.mirrored ? Qt.RightToLeft : Qt.LeftToRight
        Item {
            visible: root.leadingVisible
            Layout.preferredWidth: (root.leadingWidth + (root.showText || root.trailingVisible ? root.gap : 0))
                * (root.filter && !root.customLeading ? root.selectionProgress : 1)
            Layout.preferredHeight: root.leadingHeight
            clip: root.filter && !root.customLeading
            opacity: root.filter && !root.customLeading ? root.selectionProgress : 1
            Item {
                visible: root.customLeading
                x: root.control.mirrored ? parent.width - width : 0
                width: root.leadingWidth
                height: root.leadingHeight
                opacity: root.control.enabled ? 1 : root.tokens.disabledLabelOpacity
                data: root.leadingItem ? [root.leadingItem] : []
            }
            AppIcon {
                visible: !root.customLeading
                x: root.control.mirrored ? parent.width - width : 0
                width: root.iconWidth; height: root.iconHeight
                name: root.filter ? "material:check" : root.control.icon.name
                source: root.filter ? "" : root.control.icon.source
                size: Math.min(width, height)
                color: root.filter ? root.color : root.iconColor
                appearance: root.parameters?.iconAppearance ?? null
                Accessible.ignored: true
            }
        }
        Text {
            visible: root.showText
            Layout.fillWidth: true
            Layout.preferredWidth: Math.ceil(implicitWidth)
            text: root.control.text
            font: root.control.font
            color: root.color
            textFormat: Text.PlainText
            elide: Text.ElideRight
            horizontalAlignment: root.control.mirrored ? Text.AlignRight : Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
            Accessible.ignored: true
        }
        Item {
            visible: root.trailingVisible
            Layout.preferredWidth: root.iconWidth + (root.showText || root.leadingVisible ? root.gap : 0)
            Layout.preferredHeight: root.iconHeight
            Item {
                x: root.control.mirrored ? 0 : parent.width - width
                width: root.iconWidth; height: root.iconHeight
                AppIcon {
                    anchors.fill: parent
                    visible: !root.actionTrailing
                    name: root.nativeTrailing ? root.control.icon.name : root.trailingIconName
                    source: root.nativeTrailing ? root.control.icon.source : ""
                    size: Math.min(width, height)
                    color: root.nativeTrailing ? root.iconColor : root.color
                    appearance: root.parameters?.iconAppearance ?? null
                    Accessible.ignored: true
                }
                Loader {
                    anchors.centerIn: parent
                    width: root.tokens.chipTrailingTarget; height: width
                    active: root.actionTrailing
                    sourceComponent: SK.Button {
                        id: dismissButton
                        action: root.trailingAction
                        display: T.AbstractButton.IconOnly
                        SK.StyleVariation.variations: ["chipDismiss"]
                        contentItem: AppIcon {
                            name: dismissButton.icon.name
                            source: dismissButton.icon.source
                            size: Math.min(root.iconWidth, root.iconHeight)
                            color: dismissButton.enabled ? root.color : root.tokens.disabledLabel
                            appearance: root.parameters?.iconAppearance ?? null
                            Accessible.ignored: true
                        }
                    }
                }
            }
        }
    }
}
