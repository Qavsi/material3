import QtQuick

// StyleKit creates these factories in the native control's context.
QtObject {
    readonly property Component background: Component { Material3SliderBackground { } }
    readonly property Component handle: Component { Material3SliderHandle { } }
    readonly property Component firstHandle: Component { Material3SliderHandle { handleIndex: 0 } }
    readonly property Component secondHandle: Component { Material3SliderHandle { handleIndex: 1 } }
}
