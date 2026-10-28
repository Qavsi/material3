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
    property int selection: 0
    readonly property ComparisonMetrics metrics: ComparisonMetrics { }
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
        text: qsTr("Choose a width to try the drawer, narrow rail or expanded rail. Search and caller selection stay live.")
        font: root.tokens.bodyMedium
        color: root.tokens.surfaceVariantForeground
        wrapMode: Text.WordWrap
    }
    SK.ComboBox {
        id: previewSize
        width: parent.width
        model: [qsTr("Compact drawer"), qsTr("Narrow rail"), qsTr("Expanded rail")]
    }
    DemoCard {
        width: parent.width
        tokens: root.tokens
        title: qsTr("Responsive shell")
        minimumContentWidth: [root.metrics.appNavigationCompactWidth,
            root.metrics.appNavigationNarrowWidth, root.metrics.appNavigationExpandedWidth][previewSize.currentIndex]
        Material3AppNavigation {
            id: shell
            objectName: "comparison.appNavigation.shell"
            width: [root.metrics.appNavigationCompactWidth,
                root.metrics.appNavigationNarrowWidth, root.metrics.appNavigationExpandedWidth][previewSize.currentIndex]
            height: root.tokens.appNavigationMinimumHeight
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
                    text: shell.searchText.length > 0 ? qsTr("Results for “%1”").arg(shell.searchText) : qsTr("Choose a destination or search the library.")
                    font: root.tokens.bodyLarge
                    color: root.tokens.surfaceVariantForeground
                    wrapMode: Text.WordWrap
                }
                Item { Layout.fillHeight: true }
        }
        }
    }
}
