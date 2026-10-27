import QtQuick

QtObject {
    id: root
    property bool dark: false
    // An empty input inherits the application family; Qt.font(family: "") would override it.
    property string fontFamily: ""
    readonly property string effectiveFontFamily: fontFamily || Application.font.family

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
    property color surfaceContainer: root.dynamicColors ? root.colorScheme.colors.surfaceContainer : (dark ? "#211f26" : "#f3edf7")
    property color surfaceContainerLow: root.dynamicColors ? root.colorScheme.colors.surfaceContainerLow : (dark ? "#1d1b20" : "#f7f2fa")
    property color surfaceContainerHigh: root.dynamicColors ? root.colorScheme.colors.surfaceContainerHigh : (dark ? "#2b2930" : "#ece6f0")
    property color surfaceContainerHighest: root.dynamicColors ? root.colorScheme.colors.surfaceContainerHighest : (dark ? "#36343b" : "#e6e0e9")
    property color inverseSurface: root.dynamicColors ? root.colorScheme.colors.inverseSurface : (dark ? "#e6e0e9" : "#322f35")
    property color inverseSurfaceForeground: root.dynamicColors ? root.colorScheme.colors.inverseSurfaceForeground : (dark ? "#322f35" : "#f5eff7")
    property color error: root.dynamicColors ? root.colorScheme.colors.error : (dark ? "#f2b8b5" : "#b3261e")
    property color outline: root.dynamicColors ? root.colorScheme.colors.outline : (dark ? "#938f99" : "#79747e")
    property color outlineVariant: root.dynamicColors ? root.colorScheme.colors.outlineVariant : (dark ? "#49454f" : "#cac4d0")
    property color shadow: root.dynamicColors ? root.colorScheme.colors.shadow : ("#000000")
    readonly property color transparent: Qt.rgba(0, 0, 0, 0)

    readonly property real spacingUnit: 4
    readonly property real spacingSmall: 8
    readonly property real spacingMedium: 16
    readonly property real spacingLarge: 24
    readonly property real spacingExtraLarge: 32
    readonly property real radiusExtraSmall: 4
    readonly property real radiusSmall: 8
    readonly property real radiusMedium: 12
    readonly property real radiusLarge: 16
    readonly property real radiusExtraLarge: 28
    readonly property real radiusExtraExtraLarge: 32
    readonly property real minimumTargetSize: 40
    readonly property real iconButtonInset: spacingUnit
    readonly property real iconButtonPadding: spacingSmall
    readonly property real buttonExtraSmallPadding: 16
    readonly property real buttonSmallPadding: 24
    readonly property real buttonMediumPadding: 24
    readonly property real buttonLargePadding: 32
    readonly property real buttonExtraLargePadding: 32
    readonly property real buttonLargeSpacing: 12
    readonly property real buttonExtraLargeSpacing: buttonLargeSpacing
    component InputSize: QtObject {
        required property real height
        required property real horizontalPadding
        property real verticalPadding: 0
        required property real iconSize
        required property real spacing
        required property font font
    }
    readonly property InputSize textFieldExtraSmall: InputSize {
        height: 40; horizontalPadding: 12; verticalPadding: 8
        iconSize: 18; spacing: 8; font: root.bodySmall
    }
    readonly property InputSize textFieldSmall: InputSize {
        height: 48; horizontalPadding: 12; verticalPadding: 12
        iconSize: 20; spacing: 8; font: root.bodyMedium
    }
    readonly property InputSize textFieldMedium: InputSize {
        height: 56; horizontalPadding: 16; verticalPadding: 16
        iconSize: 24; spacing: 12; font: root.bodyLarge
    }
    readonly property InputSize textFieldLarge: InputSize {
        height: 64; horizontalPadding: 20; verticalPadding: 20
        iconSize: 24; spacing: 12; font: root.bodyLarge
    }
    readonly property InputSize textFieldExtraLarge: InputSize {
        height: 72; horizontalPadding: 24; verticalPadding: 24
        iconSize: 32; spacing: 16; font: root.bodyLarge
    }
    readonly property real referenceCardWidth: 400
    readonly property real inputGalleryPadding: 12
    readonly property real inputGallerySpacing: spacingSmall
    readonly property real textFieldMinimumWidth: 64
    readonly property real textFieldHeight: 56
    readonly property real textFieldHorizontalPadding: spacingMedium
    readonly property real textFieldVerticalPadding: spacingMedium
    readonly property real textFieldFilledTopPadding: spacingLarge
    readonly property real textFieldFilledBottomPadding: spacingSmall
    readonly property real textFieldIconSize: 24
    readonly property real textFieldIconSpacing: 12
    readonly property real textFieldAffixSpacing: 2
    readonly property real textFieldSupportingTopPadding: 4
    readonly property real textFieldCornerRadius: radiusExtraSmall
    readonly property real textFieldOutlineWidth: 1
    readonly property real textFieldFocusedOutlineWidth: 2
    readonly property real textFieldLabelScale: 0.8
    readonly property real textFieldLabelTopPadding: spacingSmall
    readonly property real textFieldLabelGapPadding: spacingUnit
    readonly property int textFieldLabelDuration: 400
    readonly property list<real> textFieldLabelEasingCurve: [0.05, 0, 0.133333, 0.06, 0.166666, 0.4,
        0.208333, 0.82, 0.25, 1, 1, 1]
    readonly property color textFieldFilledContainer: surfaceContainerHighest
    readonly property color textFieldDisabledFilledContainer: Qt.alpha(surfaceForeground, 0.04)
    readonly property color textFieldIndicator: surfaceVariantForeground
    readonly property real menuMinimumWidth: 200
    readonly property real menuMinimumHeight: 48
    readonly property real menuItemHeight: 48
    readonly property real menuCornerRadius: radiusExtraSmall
    readonly property real menuVerticalPadding: spacingSmall
    readonly property real menuItemHorizontalPadding: spacingMedium
    readonly property real menuItemSpacing: spacingMedium
    readonly property real menuRippleOpacity: 0.10
    readonly property int menuEnterDuration: 300
    readonly property int menuExitDuration: 150
    readonly property real menuClosedScale: 0.8
    readonly property real menuOpenScale: 1
    readonly property list<real> menuEnterEasingCurve: [0.1, 0.7, 0.1, 1, 1, 1]
    readonly property list<real> menuExitEasingCurve: [0.3, 0, 0.8, 0.2, 1, 1]

    readonly property real fabMenuAreaHeight: 280
    readonly property real fabMenuEdgeInset: 16
    readonly property real fabMenuItemSpacing: 4
    readonly property real fabMenuTriggerSpacing: 8
    readonly property real fabMenuCloseIconSize: 20
    readonly property int fabMenuSequenceDuration: 400
    readonly property int fabMenuSpatialDuration: 200
    readonly property int fabMenuEffectDuration: 100
    readonly property real segmentedExtraSmallPadding: 8
    readonly property real segmentedSmallPadding: 12
    readonly property real segmentedMediumPadding: 16
    readonly property real segmentedLargePadding: 32
    readonly property real segmentedExtraLargePadding: 40
    readonly property real outlineWidth: 1
    readonly property real smallHeight: 40
    readonly property real smallIconSize: 18
    readonly property int iconWeight: 400
    readonly property real iconOpticalSize: 24
    readonly property int iconGrade: 0
    readonly property int iconRenderType: Text.CurveRendering
    readonly property real smallHorizontalPadding: buttonSmallPadding
    readonly property real smallVerticalPadding: 10
    readonly property real smallSpacing: 8
    readonly property real smallRadius: smallHeight / 2
    readonly property real labelLargeSize: 14
    readonly property real labelLargeTracking: 0.1
    readonly property font labelLarge: Qt.font({
        family: root.effectiveFontFamily, pixelSize: root.labelLargeSize,
        weight: Font.Medium, letterSpacing: root.labelLargeTracking
    })
    readonly property font labelMedium: Qt.font({ family: root.effectiveFontFamily,
        pixelSize: 12, weight: Font.Medium, letterSpacing: 0.5 })
    readonly property font bodyLarge: Qt.font({ family: root.effectiveFontFamily,
        pixelSize: 16, weight: Font.Normal, letterSpacing: 0.5 })
    readonly property font bodySmall: Qt.font({ family: root.effectiveFontFamily,
        pixelSize: 12, weight: Font.Normal, letterSpacing: 0.4 })
    readonly property real bodySmallLineHeight: 16
    readonly property font bodyMedium: Qt.font({ family: root.effectiveFontFamily,
        pixelSize: 14, weight: Font.Normal, letterSpacing: 0.25 })
    readonly property font titleMedium: Qt.font({ family: root.effectiveFontFamily,
        pixelSize: 16, weight: Font.Medium, letterSpacing: 0.15 })
    readonly property font titleLarge: Qt.font({ family: root.effectiveFontFamily,
        pixelSize: 22, weight: Font.Normal, letterSpacing: 0 })
    readonly property font headlineSmall: Qt.font({ family: root.effectiveFontFamily,
        pixelSize: 24, weight: Font.Normal, letterSpacing: 0 })

    readonly property real hoverOpacity: 0.08
    readonly property real interactionOpacity: 0.10
    // QCM/Skia driver timings; not MDC-Android button duration tokens.
    readonly property int rippleExpansionDuration: 450
    readonly property int rippleReleaseDuration: 350
    readonly property int rippleFadeDuration: 150
    readonly property real rippleHoldProgress: 0.4
    readonly property real rippleOpacity: 0.12
    readonly property int rippleNoiseDuration: 7000
    readonly property real rippleNoisePhase: rippleNoiseDuration / 214
    readonly property color rippleSparkleColor: Qt.rgba(1, 1, 1, 0.5)
    readonly property int shapeDuration: 150
    readonly property int pressDuration: shapeDuration
    readonly property int shapeEasing: Easing.OutCubic
    // Outside focus ring is a Qt keyboard-accessibility adaptation.
    readonly property real selectionMarkStrokeWidth: 2
    readonly property real focusRingWidth: 2
    readonly property real focusRingGap: 2
    readonly property real disabledContainerOpacity: 0.12
    readonly property real disabledLabelOpacity: 0.38
    // Pinned QCM elevation/lighting recipe; rendering has no Material policy.
    readonly property real elevationLevel0: 0
    readonly property real elevationLevel1: 1
    readonly property real elevationLevel2: 3
    readonly property real elevationLevel3: 6
    readonly property real elevationLevel4: 8
    readonly property real elevationLevel5: 12
    readonly property int elevationDuration: 250
    readonly property list<real> elevationEasingCurve: [0.3, 0, 0.8, 0.2, 1, 1]
    readonly property real elevationContainerOpacity: 1
    readonly property real shadowAmbientOpacity: 0.039
    readonly property real shadowSpotOpacity: 0.25
    readonly property vector3d shadowLightDirection: Qt.vector3d(0, -1, 1)
    readonly property real shadowLightRadius: 800
    readonly property real shadowLightHeight: 600
    readonly property real shadowLightRadiusRatio: shadowLightRadius / shadowLightHeight
    readonly property real shadowBlurSigmaFactor: 1.2
    readonly property real shadowBlurMinimumSigma: 0.5
    readonly property real shadowBlurOpacity: 0.35
    readonly property color hoveredPrimary: Qt.tint(primary,
        Qt.rgba(primaryForeground.r, primaryForeground.g, primaryForeground.b, hoverOpacity))
    readonly property color interactingPrimary: Qt.tint(primary,
        Qt.rgba(primaryForeground.r, primaryForeground.g, primaryForeground.b, interactionOpacity))
    readonly property color disabledContainer: Qt.alpha(surfaceForeground, disabledContainerOpacity)
    readonly property color disabledLabel: Qt.alpha(surfaceForeground, disabledLabelOpacity)
}
