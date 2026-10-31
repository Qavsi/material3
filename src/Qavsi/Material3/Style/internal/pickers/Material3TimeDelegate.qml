import QtQuick

// StyleKit constructs these delegates in each native control's context.
QtObject {
    readonly property Component field: Component { Material3TimeFieldBackground {} }
    readonly property Component period: Component { Material3TimePeriodBackground {} }
}
