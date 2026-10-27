import QtQuick

// StyleKit creates this factory in the native ComboBox's context.
QtObject {
    readonly property Component background: Component {
        Material3ComboBoxBackground { }
    }
    readonly property Component indicator: Component {
        Material3ComboBoxIndicator { }
    }
}
