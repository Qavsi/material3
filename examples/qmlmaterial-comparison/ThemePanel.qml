pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Style
import Qavsi.Material3.Theme

Material3Drawer {
    id: root
    objectName: "comparison.appearance"
    required property AppearanceOptions choices
    required property color seedColor
    required property int colorScheme
    required property bool darkMode
    readonly property ComparisonMetrics metrics: ComparisonMetrics { }
    readonly property var tone50Samples: {
        const source = root.tokens.colorScheme
        // Snapshot inputs too: invokable calls do not expose C++ dependencies.
        return {
            seedColor: source.seedColor,
            scheme: source.scheme,
            colors: {
                primary: source.schemeTone(MaterialColorScheme.PrimaryPalette, root.metrics.palettePreviewTone),
                secondary: source.schemeTone(MaterialColorScheme.SecondaryPalette, root.metrics.palettePreviewTone),
                tertiary: source.schemeTone(MaterialColorScheme.TertiaryPalette, root.metrics.palettePreviewTone)
            },
            foregrounds: {
                primary: source.schemeTone(MaterialColorScheme.PrimaryPalette, root.metrics.palettePreviewInkTone),
                secondary: source.schemeTone(MaterialColorScheme.SecondaryPalette, root.metrics.palettePreviewInkTone),
                tertiary: source.schemeTone(MaterialColorScheme.TertiaryPalette, root.metrics.palettePreviewInkTone)
            }
        }
    }
    signal seedColorChangeRequested(color value)
    signal colorSchemeChangeRequested(int value)
    signal darkModeChangeRequested(bool value)
    edge: mirrored ? Qt.RightEdge : Qt.LeftEdge
    contentItem: Flickable {
        contentWidth: width
        contentHeight: content.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds
        SK.ScrollBar.vertical: SK.ScrollBar { }
        ColumnLayout {
            id: content
            width: parent.width
            spacing: root.tokens.spacingMedium
            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: qsTr("Appearance")
                    font: root.tokens.titleLarge
                    color: root.tokens.surfaceForeground
                }
                SK.Button {
                    id: closeButton
                    objectName: "comparison.appearance.close"
                    text: qsTr("Close appearance")
                    display: SK.Button.IconOnly
                    icon.name: "material:close"
                    SK.StyleVariation.variations: ["iconExtraSmall", "iconStandard"]
                    contentItem: Material3ButtonContent { control: closeButton }
                    onClicked: root.close()
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Text {
                    Layout.fillWidth: true
                    text: qsTr("Brightness")
                    font: root.tokens.labelLarge
                    color: root.tokens.surfaceForeground
                }
                SK.Switch {
                    objectName: "comparison.appearance.brightness"
                    checked: !root.darkMode
                    Accessible.name: qsTr("Light theme")
                    // Qt 6.12 must finish the Switch reader update before rebuilding its Theme.
                    onToggled: Qt.callLater(root.darkModeChangeRequested, !checked)
                }
            }
            Flow {
                Layout.fillWidth: true
                spacing: root.tokens.spacingSmall
                Repeater {
                    model: root.choices.schemes
                    delegate: SK.Button {
                        id: schemeChip
                        required property var modelData
                        readonly property int schemeValue: modelData.value
                        objectName: "comparison.appearance.scheme." + modelData.key
                        text: modelData.label
                        checkable: true
                        autoExclusive: true
                        checked: root.colorScheme === schemeValue
                        SK.StyleVariation.variations: ["chipInput"]
                        contentItem: Material3ChipContent { control: schemeChip }
                        onClicked: root.colorSchemeChangeRequested(schemeValue)
                    }
                }
            }
            AppearanceColorSamples {
                Layout.fillWidth: true
                tokens: root.tokens
                title: qsTr("Semantic colors")
                previewPrefix: "comparison.appearance.preview"
                colors: ({ primary: root.tokens.primary, secondary: root.tokens.secondary, tertiary: root.tokens.tertiary })
                foregrounds: ({ primary: root.tokens.primaryForeground, secondary: root.tokens.secondaryForeground,
                    tertiary: root.tokens.tertiaryForeground })
            }
            AppearanceColorSamples {
                Layout.fillWidth: true
                tokens: root.tokens
                title: qsTr("Tone %1").arg(root.metrics.palettePreviewTone)
                previewPrefix: "comparison.appearance.tone50"
                colors: root.tone50Samples.colors
                foregrounds: root.tone50Samples.foregrounds
            }
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: root.tokens.textFieldOutlineWidth
                color: root.tokens.outlineVariant
                Accessible.ignored: true
            }
            Grid {
                Layout.alignment: Qt.AlignHCenter
                columns: 3
                spacing: root.tokens.spacingUnit
                Repeater {
                    model: root.choices.seeds
                    delegate: SK.RadioButton {
                        required property var modelData
                        objectName: "comparison.appearance.seed." + modelData.key
                        palette.button: modelData.color
                        checked: Qt.colorEqual(root.seedColor, palette.button)
                        Accessible.name: modelData.label
                        SK.StyleVariation.variations: ["colorChoice"]
                        onClicked: root.seedColorChangeRequested(palette.button)
                    }
                }
            }
        }
    }
}
