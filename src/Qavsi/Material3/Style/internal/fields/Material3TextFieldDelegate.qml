import QtQuick

// StyleKit creates this factory in the native TextField's context.
QtObject {
    readonly property Component background: Component {
        Material3TextFieldBackground { }
    }
}
