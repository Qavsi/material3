import QtQuick

QtObject {
    readonly property Component background: Component { Material3SpinBoxBackground {} }
    readonly property Component up: Component { Material3SpinBoxIndicator { increasing: true } }
    readonly property Component down: Component { Material3SpinBoxIndicator { increasing: false } }
}
