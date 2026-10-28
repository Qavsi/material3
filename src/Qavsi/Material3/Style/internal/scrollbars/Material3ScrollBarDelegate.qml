import QtQuick

// StyleKit instantiates these factories in the native ScrollBar context.
QtObject {
    readonly property Component indicator: Component { Material3ScrollBarVisual { } }
    readonly property Component background: Component { Material3ScrollBarVisual { track: true } }
}
