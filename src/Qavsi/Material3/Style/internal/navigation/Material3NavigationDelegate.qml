import QtQuick

// StyleKit creates the factories in each native control's context.
QtObject {
    readonly property Component itemBackground: Component {
        Material3NavigationItemBackground { }
    }
    readonly property Component barBackground: Component {
        Material3TabBarBackground { }
    }
}
