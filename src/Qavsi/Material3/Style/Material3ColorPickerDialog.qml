// QCM0.6.1 ColorPickerDialog layout, native Qt popup ownership.
pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK

Material3PickerDialog {
    id: root
    property color selectedColor: tokens.primary
    property color currentColor: selectedColor
    property alias showAlpha: picker.showAlpha
    signal acceptedColor(color color)
    title: qsTr("Pick color")
    // The color wheel uses the regular M3 dialog surface, not the compact form host.
    SK.StyleVariation.variations: []
    leftPadding: tokens.dialogPadding
    rightPadding: tokens.dialogPadding
    topPadding: tokens.dialogVerticalPadding
    bottomPadding: tokens.dialogVerticalPadding
    spacing: 0
    implicitWidth: picker.implicitWidth + leftPadding + rightPadding
    height: Math.min(implicitHeight, parent ? Math.max(0, parent.height - tokens.spacingExtraLarge) : implicitHeight)
    function selectColor(value: color): void { currentColor = value; }
    onAboutToShow: currentColor = selectedColor
    onAccepted: acceptedColor(currentColor)
    enter: Material3DialogEnterTransition { control: root }
    exit: Material3DialogExitTransition { control: root }
    SK.Overlay.modal: Material3DialogOverlay { control: root }
    header: SK.Label {
        text: root.title
        font: root.tokens.headlineSmall
        color: root.tokens.surfaceForeground
        horizontalAlignment: Text.AlignHCenter
        leftPadding: root.tokens.dialogPadding
        rightPadding: root.tokens.dialogPadding
        topPadding: root.tokens.dialogPadding
        bottomPadding: 0
    }
    footer: Material3DialogButtonBox {
        standardButtons: root.standardButtons
        spacing: root.tokens.spacingSmall
        leftPadding: root.tokens.dialogVerticalPadding
        rightPadding: root.tokens.dialogVerticalPadding
        topPadding: 0
        bottomPadding: root.tokens.dialogVerticalPadding
    }
    contentItem: Flickable {
        implicitWidth: picker.implicitWidth
        implicitHeight: picker.implicitHeight
        contentWidth: width
        contentHeight: picker.implicitHeight
        flickableDirection: Flickable.VerticalFlick
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        Material3ColorPicker {
            id: picker
            width: parent.width
            color: root.currentColor
            onColorChangeRequested: value => root.currentColor = value
        }
    }
}
