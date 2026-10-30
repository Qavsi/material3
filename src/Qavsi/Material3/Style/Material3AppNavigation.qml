pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls.Basic as Basic
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

SK.Pane {
    id: root
    readonly property Material3Style sourceStyle: SK.StyleKit.style as Material3Style
    property Material3Theme tokens: sourceStyle.tokens
    property bool reducedMotion: false
    property var model: []
    property int currentIndex: 0
    property string title: ""
    property string searchPlaceholderText: qsTr("Search")
    property Component sideSheetContent
    property alias searchText: searchInput.text
    readonly property alias searchField: searchInput
    readonly property alias navigationDrawer: drawerPopup
    readonly property alias sideSheet: detailsPopup
    default property alias pageData: page.data
    readonly property string navigationMode: width < tokens.appNavigationCompactBreakpoint ? "drawer"
        : width < tokens.appNavigationExpandedBreakpoint ? "collapsed" : "expanded"
    readonly property bool effectiveReducedMotion: reducedMotion || (sourceStyle?.effectiveReducedMotion ?? false)
        || !SK.StyleKit.transitionsEnabled
        || Application.styleHints.accessibility.motionPreference === Qt.MotionPreference.ReducedMotion
    readonly property int motionDuration: effectiveReducedMotion || !visible || !Window.window?.visible
        || Window.window?.visibility === Window.Minimized ? 0 : tokens.appNavigationMotionDuration
    signal activated(int index)
    signal searchAccepted(string text)
    SK.StyleVariation.variations: ["appNavigationSurface"]
    padding: 0
    implicitWidth: tokens.appNavigationCompactBreakpoint
    implicitHeight: tokens.appNavigationMinimumHeight

    function openNavigation() {
        if (navigationMode === "drawer")
            drawer.open()
    }
    function openSideSheet() {
        if (sideSheetContent)
            details.open()
    }
    function select(index: int) {
        drawer.close()
        activated(index)
    }
    property int focusedDestinationIndex: -1
    function focusIndex(item: var): int {
        while (item && item !== root) {
            if ("navigationIndex" in item)
                return item.navigationIndex
            item = item.parent
        }
        return -1
    }
    onNavigationModeChanged: {
        const index = focusedDestinationIndex
        drawer.close()
        if (index >= 0)
            focusedDestinationIndex = index
        if (index >= 0)
            Qt.callLater(() => {
                if (root.focusedDestinationIndex !== index)
                    return
                if (root.navigationMode === "drawer")
                    menuButton.forceActiveFocus(Qt.OtherFocusReason)
                else {
                    const destinations = rail as Material3AppDestinations
                    if (destinations)
                        destinations.focusDestination(index)
                }
            })
    }
    readonly property Connections focusObserver: Connections {
        target: root.Window.window
        function onActiveFocusItemChanged() {
            const item = root.Window.window?.activeFocusItem
            // Preserve the index while the old native item is being destroyed.
            if (item && item !== root.Window.window.contentItem)
                root.focusedDestinationIndex = root.focusIndex(item)
        }
    }

    component Sheet: Material3Drawer {
        parent: root
        width: Math.min(root.tokens.appNavigationSheetWidth, root.width)
        height: root.height
        tokens: root.tokens
        reducedMotion: root.effectiveReducedMotion
        interactive: modal ? root.navigationMode === "drawer" : root.sideSheetContent !== null
    }
    readonly property Basic.Drawer drawer: Sheet {
        id: drawerPopup
        modal: true
        dim: true
        edge: root.mirrored ? Qt.RightEdge : Qt.LeftEdge
        contentItem: Material3AppDestinations { shell: root }
    }
    readonly property Basic.Drawer details: Sheet {
        id: detailsPopup
        modal: false
        dim: false
        edge: root.mirrored ? Qt.LeftEdge : Qt.RightEdge
        contentItem: ColumnLayout {
            spacing: root.tokens.spacingMedium
            SK.Button {
                text: qsTr("Close details")
                flat: true
                onClicked: root.details.close()
            }
            Loader {
                Layout.fillWidth: true
                Layout.fillHeight: true
                active: root.details.visible
                sourceComponent: root.sideSheetContent
            }
        }
    }
    contentItem: ColumnLayout {
        spacing: 0
        SK.ToolBar {
            Layout.fillWidth: true
            RowLayout {
                anchors.fill: parent
                spacing: root.tokens.spacingSmall
                SK.Button {
                    id: menuButton
                    visible: root.navigationMode === "drawer"
                    text: qsTr("Open navigation")
                    icon.name: "material:menu"
                    display: SK.Button.IconOnly
                    SK.StyleVariation.variations: ["iconStandard"]
                    contentItem: Material3ButtonContent { control: menuButton }
                    onClicked: root.openNavigation()
                }
                Text {
                    visible: root.navigationMode !== "drawer" && root.title.length > 0
                    text: root.title
                    font: root.tokens.titleMedium
                    color: root.tokens.surfaceForeground
                    elide: Text.ElideRight
                    Layout.maximumWidth: root.tokens.appNavigationExpandedWidth
                    Accessible.ignored: true
                }
                SK.TextField {
                    id: searchInput
                    Layout.fillWidth: true
                    Layout.minimumWidth: 0
                    placeholderText: root.searchPlaceholderText
                    TextFieldSupport.leadingIcon: "material:search"
                    SK.StyleVariation.variations: ["searchField"]
                    EnterKey.type: Qt.EnterKeySearch
                    onAccepted: root.searchAccepted(text)
                }
                SK.Button {
                    visible: root.sideSheetContent !== null
                    text: qsTr("Details")
                    flat: true
                    onClicked: root.openSideSheet()
                }
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0
            Material3AppDestinations {
                id: rail
                shell: root
                Layout.fillHeight: true
                Layout.preferredWidth: root.navigationMode === "expanded"
                    ? root.tokens.appNavigationExpandedWidth : root.tokens.navigationRailCollapsedWidth
                visible: root.navigationMode !== "drawer"
                // Keep native StyleKit contexts alive across responsive presentation changes.
                collapsed: root.navigationMode === "collapsed"
            }
            Item {
                id: page
                Layout.fillWidth: true
                Layout.fillHeight: true
            }
        }
    }
}
