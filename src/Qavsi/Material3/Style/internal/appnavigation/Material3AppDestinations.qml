pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK

Flickable {
    id: destinations
    required property Material3AppNavigation shell
    property bool collapsed: false
    function focusDestination(index: int) {
        const slot = buttons.itemAt(index) as Destination
        const button = slot?.activeButton as Item
        if (button)
            button.forceActiveFocus(Qt.OtherFocusReason)
    }
    component Destination: Item { property Item activeButton }
    contentWidth: width
    contentHeight: rows.implicitHeight + destinations.shell.tokens.spacingMedium * 2
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    SK.ScrollBar.vertical: SK.ScrollBar { }
    Column {
        id: rows
        x: destinations.shell.tokens.spacingSmall
        y: destinations.shell.tokens.spacingMedium
        width: Math.max(0, destinations.width - destinations.shell.tokens.spacingSmall * 2)
        spacing: destinations.shell.tokens.spacingMedium
        Repeater {
            id: buttons
            model: destinations.shell.model
            delegate: Destination {
                id: destination
                required property int index
                required property var modelData
                width: rows.width
                activeButton: destinations.collapsed ? narrow : wide
                height: activeButton.implicitHeight
                SK.Button {
                    id: narrow
                    width: destination.width
                    visible: destinations.collapsed
                    text: destination.modelData.text
                    icon.name: destination.modelData.iconName ?? ""
                    enabled: destination.modelData.enabled ?? true
                    readonly property int navigationIndex: destination.index
                    Accessible.selected: checked
                    checked: destinations.shell.currentIndex === destination.index
                    display: SK.Button.IconOnly
                    SK.StyleVariation.variations: ["navigationRailCollapsed"]
                    contentItem: Material3NavigationContent { control: narrow }
                    SK.ToolTip.text: text
                    SK.ToolTip.visible: hovered && !pressed
                    onClicked: destinations.shell.select(destination.index)
                }
                SK.Button {
                    id: wide
                    width: destination.width
                    visible: !destinations.collapsed
                    text: destination.modelData.text
                    icon.name: destination.modelData.iconName ?? ""
                    icon.width: destinations.shell.tokens.navigationIconSize
                    icon.height: destinations.shell.tokens.navigationIconSize
                    enabled: destination.modelData.enabled ?? true
                    readonly property int navigationIndex: destination.index
                    Accessible.selected: checked
                    checked: destinations.shell.currentIndex === destination.index
                    SK.StyleVariation.variations: ["navigationDestination"]
                    contentItem: Material3ButtonContent { control: wide }
                    onClicked: destinations.shell.select(destination.index)
                }
            }
        }
    }
}
