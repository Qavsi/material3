import QtQuick

// StyleKit creates this factory in the native RadioButton's context.
QtObject {
    readonly property Component indicator: Component {
        Material3RadioButtonIndicator { }
    }
}
