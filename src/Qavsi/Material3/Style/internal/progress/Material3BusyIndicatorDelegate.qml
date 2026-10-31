import QtQuick

// StyleKit supplies the native BusyIndicator and DelegateStyle context.
QtObject {
    readonly property Component indicator: Component { Material3BusyIndicatorIndicator { } }
}
