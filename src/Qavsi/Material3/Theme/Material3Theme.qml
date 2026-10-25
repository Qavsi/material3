import QtQuick

QtObject {
    id: root
    property bool dark: false
    // Empty family lets QFont resolve the platform font; callers may supply Roboto.
    property string fontFamily: ""

    // MDC-Android 1.13.0, non-dynamic scheme; see DESIGN.md for provenance.
    property color primary: dark ? "#d0bcff" : "#6750a4"
    property color primaryForeground: dark ? "#381e72" : "#ffffff"
    property color surface: dark ? "#141218" : "#fef7ff"
    property color surfaceForeground: dark ? "#e6e0e9" : "#1d1b20"
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
