import QtQuick

// StyleKit creates this factory in the native control's context.
QtObject {
    readonly property Component indicator: Component { Material3ProgressIndicator { } }
}
