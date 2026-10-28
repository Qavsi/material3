import QtQuick

QtObject {
    readonly property Component background: Component { Material3ListCardBackground { } }
    readonly property Component shadow: Component { Material3ListCardShadow { } }
}
