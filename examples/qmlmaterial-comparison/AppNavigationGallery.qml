pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Style
import Qavsi.Material3.Theme

Column {
    id: root
    objectName: "comparison.appNavigation"
    required property Material3Theme tokens
    required property rect previewArea
    property int selection: 0
    readonly property ComparisonMetrics metrics: ComparisonMetrics { }
    readonly property real previewWidth: [metrics.appNavigationCompactWidth,
        metrics.appNavigationNarrowWidth, metrics.appNavigationExpandedWidth][Math.max(0, previewSize.currentIndex)]
    spacing: tokens.spacingMedium

    Text {
        width: parent.width
        text: qsTr("Application navigation")
        font: root.tokens.titleLarge
        color: root.tokens.surfaceForeground
        horizontalAlignment: Text.AlignHCenter
    }
    Text {
        width: parent.width
        text: qsTr("Choose a width and open the resizable preview to try the drawer, narrow rail or expanded rail.")
        font: root.tokens.bodyMedium
        color: root.tokens.surfaceVariantForeground
        wrapMode: Text.WordWrap
    }
    SK.ComboBox {
        id: previewSize
        objectName: "comparison.appNavigation.size"
        width: parent.width
        model: [qsTr("Compact drawer"), qsTr("Narrow rail"), qsTr("Expanded rail")]
    }
    DemoCard {
        width: parent.width
        tokens: root.tokens
        title: qsTr("Responsive shell")
        Text {
            width: parent.width
            text: qsTr("Navigation and Details use the preview window's bounds. Search and selection stay live when its width changes.")
            font: root.tokens.bodyMedium
            color: root.tokens.surfaceVariantForeground
            wrapMode: Text.WordWrap
        }
        SK.Button {
            id: openPreview
            objectName: "comparison.appNavigation.open"
            anchors.horizontalCenter: parent.horizontalCenter
            text: qsTr("Open navigation preview")
            contentItem: Material3ButtonContent { control: openPreview }
            onClicked: {
                previewWindow.show()
                previewWindow.requestActivate()
            }
        }
    }
    // Keep StyleKit contexts alive when the native preview window is closed/reopened.
    SK.ApplicationWindow {
        id: previewWindow
        objectName: "comparison.appNavigation.preview"
        transientParent: root.Window.window
        title: qsTr("Application navigation · Qavsi Material3")
        visible: false
        width: Math.min(root.previewWidth, root.previewArea.width)
        height: Math.min(root.tokens.appNavigationMinimumHeight, root.previewArea.height)
        minimumWidth: Math.min(root.metrics.appNavigationCompactWidth, root.previewArea.width)
        minimumHeight: Math.min(root.tokens.appNavigationMinimumHeight, root.previewArea.height)
        x: root.previewArea.x + Math.max(0, (root.previewArea.width - width) / 2)
        y: root.previewArea.y + Math.max(0, (root.previewArea.height - height) / 2)
        SK.StyleKit.style: root.SK.StyleKit.style
        SK.StyleKit.transitionsEnabled: root.SK.StyleKit.transitionsEnabled

        Material3AppNavigation {
            id: shell
            objectName: "comparison.appNavigation.shell"
            anchors.fill: parent
            title: qsTr("Library")
            currentIndex: root.selection
            onActivated: index => root.selection = index
            searchPlaceholderText: qsTr("Search library")
            model: [
                { text: qsTr("Explore"), iconName: "material:explore" },
                { text: qsTr("Favorites"), iconName: "material:favorite" },
                { text: qsTr("Settings"), iconName: "material:settings" }
            ]
            sideSheetContent: Component {
                Text {
                    text: qsTr("Details stay modeless. Continue editing search or selecting a destination.")
                    font: root.tokens.bodyLarge
                    color: root.tokens.surfaceForeground
                    wrapMode: Text.WordWrap
                }
            }
            ColumnLayout {
                anchors.fill: parent
                anchors.margins: root.tokens.spacingMedium
                Text {
                    Layout.fillWidth: true
                    text: shell.model[shell.currentIndex]?.text ?? ""
                    font: root.tokens.headlineSmall
                    color: root.tokens.surfaceForeground
                }
                Text {
                    Layout.fillWidth: true
                    text: shell.searchText.length > 0 ? qsTr("Results for “%1”").arg(shell.searchText)
                        : qsTr("Choose a destination or search the library.")
                    font: root.tokens.bodyLarge
                    color: root.tokens.surfaceVariantForeground
                    wrapMode: Text.WordWrap
                }
                Item { Layout.fillHeight: true }
            }
        }
    }
}
