import QtQuick

QtObject {
    id: root
    property bool dark: false
    // Empty family lets QFont resolve the platform font; callers may supply Roboto.
    property string fontFamily: ""

    property bool dynamicColors: false
    property alias seedColor: generatedScheme.seedColor
    property alias scheme: generatedScheme.scheme
    property alias contrastLevel: generatedScheme.contrastLevel
    readonly property MaterialColorScheme colorScheme: MaterialColorScheme {
        id: generatedScheme
        dark: root.dark
    }

    // Preserve the MDC-Android default palette and caller role bindings when generation is off.
    property color primary: root.dynamicColors ? root.colorScheme.colors.primary : (dark ? "#d0bcff" : "#6750a4")
    property color primaryForeground: root.dynamicColors ? root.colorScheme.colors.primaryForeground : (dark ? "#381e72" : "#ffffff")
    property color primaryContainer: root.dynamicColors ? root.colorScheme.colors.primaryContainer : (dark ? "#4f378b" : "#eaddff")
    property color primaryContainerForeground: root.dynamicColors ? root.colorScheme.colors.primaryContainerForeground : (dark ? "#eaddff" : "#21005d")
    property color secondary: root.dynamicColors ? root.colorScheme.colors.secondary : (dark ? "#ccc2dc" : "#625b71")
    property color secondaryForeground: root.dynamicColors ? root.colorScheme.colors.secondaryForeground : (dark ? "#332d41" : "#ffffff")
    property color secondaryContainer: root.dynamicColors ? root.colorScheme.colors.secondaryContainer : (dark ? "#4a4458" : "#e8def8")
    property color secondaryContainerForeground: root.dynamicColors ? root.colorScheme.colors.secondaryContainerForeground : (dark ? "#e8def8" : "#1d192b")
    property color surface: root.dynamicColors ? root.colorScheme.colors.surface : (dark ? "#141218" : "#fef7ff")
    property color surfaceForeground: root.dynamicColors ? root.colorScheme.colors.surfaceForeground : (dark ? "#e6e0e9" : "#1d1b20")
    property color surfaceVariant: root.dynamicColors ? root.colorScheme.colors.surfaceVariant : (dark ? "#49454f" : "#e7e0ec")
    property color surfaceVariantForeground: root.dynamicColors ? root.colorScheme.colors.surfaceVariantForeground : (dark ? "#cac4d0" : "#49454f")
    property color surfaceContainerLow: root.dynamicColors ? root.colorScheme.colors.surfaceContainerLow : (dark ? "#1d1b20" : "#f7f2fa")
    property color surfaceContainerHigh: root.dynamicColors ? root.colorScheme.colors.surfaceContainerHigh : (dark ? "#2b2930" : "#ece6f0")
    property color surfaceContainerHighest: root.dynamicColors ? root.colorScheme.colors.surfaceContainerHighest : (dark ? "#36343b" : "#e6e0e9")
    property color inverseSurface: root.dynamicColors ? root.colorScheme.colors.inverseSurface : (dark ? "#e6e0e9" : "#322f35")
    property color inverseSurfaceForeground: root.dynamicColors ? root.colorScheme.colors.inverseSurfaceForeground : (dark ? "#322f35" : "#f5eff7")
    property color outline: root.dynamicColors ? root.colorScheme.colors.outline : (dark ? "#938f99" : "#79747e")
    property color outlineVariant: root.dynamicColors ? root.colorScheme.colors.outlineVariant : (dark ? "#49454f" : "#cac4d0")
    property color shadow: root.dynamicColors ? root.colorScheme.colors.shadow : ("#000000")
    readonly property color transparent: Qt.rgba(0, 0, 0, 0)

    readonly property real smallHeight: 40
    readonly property real smallHorizontalPadding: 16
    readonly property real smallVerticalPadding: 10
    readonly property real smallSpacing: 8
    readonly property real smallRadius: smallHeight / 2
    readonly property real labelLargeSize: 14
    readonly property real labelLargeTracking: 0.1
    readonly property font labelLarge: Qt.font({
        family: root.fontFamily, pixelSize: root.labelLargeSize,
        weight: Font.Medium, letterSpacing: root.labelLargeTracking
    })

    readonly property real hoverOpacity: 0.08
    readonly property real interactionOpacity: 0.10
    // Qt adaptation timings; these are not MDC-Android duration tokens.
    readonly property int rippleExpansionDuration: 300
    readonly property int rippleFadeDuration: 180
    // Outside focus ring is a Qt keyboard-accessibility adaptation.
    readonly property real focusRingWidth: 2
    readonly property real focusRingGap: 2
    readonly property real disabledContainerOpacity: 0.12
    readonly property real disabledLabelOpacity: 0.38
    readonly property color hoveredPrimary: Qt.tint(primary,
        Qt.rgba(primaryForeground.r, primaryForeground.g, primaryForeground.b, hoverOpacity))
    readonly property color interactingPrimary: Qt.tint(primary,
        Qt.rgba(primaryForeground.r, primaryForeground.g, primaryForeground.b, interactionOpacity))
    readonly property color disabledContainer: Qt.rgba(surfaceForeground.r,
        surfaceForeground.g, surfaceForeground.b, disabledContainerOpacity)
    readonly property color disabledLabel: Qt.rgba(surfaceForeground.r,
        surfaceForeground.g, surfaceForeground.b, disabledLabelOpacity)
}
