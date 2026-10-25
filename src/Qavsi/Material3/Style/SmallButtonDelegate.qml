import QtQuick

// Qt 6.12 StyleKit creates this component in the control's context.
QtObject {
    readonly property Component background: Component {
        SmallButtonBackground { }
    }
}
