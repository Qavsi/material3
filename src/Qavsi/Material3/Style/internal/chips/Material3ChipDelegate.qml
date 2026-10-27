import QtQuick

// StyleKit creates this factory in each native Button's context.
QtObject {
    readonly property Component background: Component {
        Material3ChipBackground { }
    }
}
