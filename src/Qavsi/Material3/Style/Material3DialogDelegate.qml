import QtQuick

// StyleKit injects the native popup and resolved delegate data in this context.
QtObject {
    readonly property Component shadow: Component { Material3DialogShadow { } }
}
