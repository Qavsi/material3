import QtQuick

// StyleKit creates this factory in the native Switch's context.
QtObject {
    readonly property Component indicator: Component {
        Material3SwitchIndicator { }
    }
}
