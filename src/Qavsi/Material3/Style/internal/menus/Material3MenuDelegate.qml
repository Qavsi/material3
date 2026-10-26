import QtQuick

// StyleKit creates this factory in each native menu's context.
QtObject {
    readonly property Component shadow: Component {
        Material3MenuShadow { }
    }
}
