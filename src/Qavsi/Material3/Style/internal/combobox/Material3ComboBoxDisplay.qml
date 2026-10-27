pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Templates as T
import Qt.labs.StyleKit as SK

Item {
    id: root
    required property T.ComboBox control
    required property TextInput editor
    required property Material3ComboBoxParameters parameters
    SK.StyleReader {
        id: reader
        controlType: Number(SK.StyleReader.ComboBox)
        palette: root.control.palette
        enabled: root.control.enabled
        focused: root.control.activeFocus
        hovered: root.control.hovered || root.control.pressed
        pressed: root.control.down
        highlighted: root.control.highlighted
    }
    Material3TextFieldBinding {
        target: root.editor; property: "clip"
        defaultValue: false
        value: true
    }
    Material3TextFieldBinding {
        id: colorBinding
        target: root.editor; property: "color"
        defaultValue: reader.text.color
        requested: !root.control.editable
        value: root.parameters.tokens.transparent
    }
    Text {
        parent: root.editor
        anchors.fill: parent
        text: root.control.displayText
        font: root.control.font
        color: reader.text.color
        visible: !root.control.editable && colorBinding.when
        elide: Text.ElideRight
        maximumLineCount: 1
        verticalAlignment: Text.AlignVCenter
        horizontalAlignment: root.control.mirrored ? Text.AlignRight : Text.AlignLeft
        renderType: root.editor.renderType
        textFormat: Text.PlainText
        Accessible.ignored: true
        LayoutMirroring.enabled: false
    }
}
