import QtQuick

// StyleKit creates this factory in the native CheckBox's context.
QtObject {
    readonly property Component indicator: Component {
        Material3CheckBoxIndicator { }
    }
}
