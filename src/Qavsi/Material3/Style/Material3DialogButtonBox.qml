import QtQuick
import Qt.labs.StyleKit as SK

SK.DialogButtonBox {
    visible: count > 0
    alignment: Qt.AlignRight
    delegate: SK.Button { flat: true }
}
