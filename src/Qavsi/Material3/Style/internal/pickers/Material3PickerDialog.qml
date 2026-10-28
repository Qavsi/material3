pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls as C
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

SK.Dialog {
    id: root
    readonly property Material3Theme tokens: (SK.StyleKit.style as Material3Style)?.tokens ?? fallbackTokens
    readonly property Material3Theme fallbackTokens: Material3Theme { }
    parent: C.Overlay.overlay
    x: parent ? Math.max(0, (parent.width - width) / 2) : 0
    y: parent ? Math.max(0, (parent.height - height) / 2) : 0
    width: Math.min(implicitWidth, parent ? Math.max(0, parent.width - tokens.spacingExtraLarge) : implicitWidth)
    modal: true
    focus: true
    standardButtons: SK.Dialog.Ok | SK.Dialog.Cancel
    header: SK.Label {
        visible: root.title.length > 0
        text: root.title
        color: root.tokens.surfaceForeground
        font: root.tokens.headlineSmall
        leftPadding: root.tokens.pickerPadding
        rightPadding: root.tokens.pickerPadding
        topPadding: root.tokens.pickerPadding
        bottomPadding: root.tokens.spacingMedium
        wrapMode: Text.Wrap
    }
    footer: SK.DialogButtonBox {
        standardButtons: root.standardButtons
        delegate: SK.Button { flat: true }
    }
    SK.StyleVariation.variations: ["pickerDialog"]
}
