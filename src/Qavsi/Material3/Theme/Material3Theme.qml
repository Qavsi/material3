import QtQuick
import "Material3ButtonRecipe.js" as ButtonRecipe
import "Material3CarouselRecipe.js" as CarouselRecipe
import "Material3PickerRecipe.js" as PickerRecipe
import "Material3ScrollBarRecipe.js" as ScrollBarRecipe
import "Material3SliderRecipe.js" as SliderRecipe
import "Material3SwitchRecipe.js" as SwitchRecipe
import "Material3ProgressRecipe.js" as ProgressRecipe
import "Material3CheckBoxRecipe.js" as CheckBoxRecipe
import "Material3RadioButtonRecipe.js" as RadioRecipe
import "Material3ChipRecipe.js" as ChipRecipe
import "Material3ListCardRecipe.js" as ListCardRecipe
import "Material3NavigationRecipe.js" as NavigationRecipe
import "Material3TabRecipe.js" as TabRecipe
import "Material3BadgeRecipe.js" as BadgeRecipe

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
    property color tertiary: root.dynamicColors ? root.colorScheme.colors.tertiary : (root.dark ? "#efb8c8" : "#7d5260")
    property color tertiaryForeground: root.dynamicColors ? root.colorScheme.colors.tertiaryForeground : (root.dark ? "#492532" : "#ffffff")
    property color tertiaryContainer: root.dynamicColors ? root.colorScheme.colors.tertiaryContainer : (root.dark ? "#633b48" : "#ffd8e4")
    property color tertiaryContainerForeground: root.dynamicColors ? root.colorScheme.colors.tertiaryContainerForeground : (root.dark ? "#ffd8e4" : "#31111d")
    property color errorContainer: root.dynamicColors ? root.colorScheme.colors.errorContainer : (root.dark ? "#8c1d18" : "#f9dedc")
    property color errorContainerForeground: root.dynamicColors ? root.colorScheme.colors.errorContainerForeground : (root.dark ? "#f9dedc" : "#410e0b")
    property color surfaceDim: root.dynamicColors ? root.colorScheme.colors.surfaceDim : (root.dark ? "#141218" : "#ded8e1")
    property color surfaceBright: root.dynamicColors ? root.colorScheme.colors.surfaceBright : (root.dark ? "#3b383e" : "#fef7ff")
    property color surfaceContainerLowest: root.dynamicColors ? root.colorScheme.colors.surfaceContainerLowest : (root.dark ? "#0f0d13" : "#ffffff")
    property color inversePrimary: root.dynamicColors ? root.colorScheme.colors.inversePrimary : (root.dark ? "#6750a4" : "#d0bcff")
    property color scrim: root.dynamicColors ? root.colorScheme.colors.scrim : (root.dark ? "#000000" : "#000000")
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
    property color errorForeground: root.dynamicColors ? root.colorScheme.colors.errorForeground : (dark ? "#601410" : "#ffffff")
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
    // QCM 0.6.1 calendar/header recipe; native Qt layout and date model.
    readonly property real carouselWidth: CarouselRecipe.width
    readonly property real carouselHeight: CarouselRecipe.height
    readonly property real carouselItemWidth: CarouselRecipe.itemWidth
    readonly property real carouselVerticalHeight: CarouselRecipe.verticalHeight
    readonly property real carouselCrossPadding: CarouselRecipe.crossPadding
    readonly property real carouselMinimumSmallWidth: CarouselRecipe.minimumSmallWidth
    readonly property real carouselMaximumSmallWidth: CarouselRecipe.maximumSmallWidth
    readonly property real carouselItemCorner: radiusExtraLarge
    readonly property real carouselTitleFadeSpan: CarouselRecipe.titleFadeSpan
    readonly property real carouselChromeHeight: CarouselRecipe.chromeHeight
    readonly property real carouselChromeSpacing: CarouselRecipe.chromeSpacing
    readonly property real carouselPagePadding: CarouselRecipe.pagePadding
    readonly property real carouselPageSpacing: CarouselRecipe.pageSpacing
    readonly property real carouselPageSize: CarouselRecipe.pageSize
    readonly property real carouselPageOpacity: 0.45
    readonly property real carouselPageHoverOpacity: 0.7
    readonly property real carouselPageSelectedOpacity: 0.95
    readonly property int carouselSnapDuration: 400
    readonly property color carouselImageForeground: "#ffffff"
    readonly property real pickerDateInputWidth: PickerRecipe.dateInputWidth
    readonly property real pickerHeaderMinimumHeight: PickerRecipe.headerMinimumHeight
    readonly property real pickerModeButtonInset: PickerRecipe.modeButtonInset
    readonly property real pickerNavigationHeight: PickerRecipe.navigationHeight
    readonly property real pickerNavigationPadding: PickerRecipe.navigationPadding
    readonly property real pickerNavigationGap: PickerRecipe.navigationGap
    readonly property int pickerNavigationColumns: 3
    readonly property real pickerYearGridHeight: PickerRecipe.yearGridHeight
    readonly property real pickerYearCellHeight: PickerRecipe.yearCellHeight
    readonly property real pickerMonthCellHeight: PickerRecipe.monthCellHeight
    readonly property real pickerWeekdayHeight: PickerRecipe.weekdayHeight
    readonly property real pickerWeekdayPadding: PickerRecipe.weekdayPadding
    readonly property real colorPickerButtonWidth: PickerRecipe.colorButtonWidth
    readonly property real colorPickerButtonHeight: PickerRecipe.colorButtonHeight
    readonly property real colorPickerButtonGap: PickerRecipe.colorButtonGap
    readonly property real colorPickerButtonTrailingExtraWidth: PickerRecipe.colorButtonTrailingExtraWidth
    readonly property real colorPickerButtonIconSize: PickerRecipe.colorButtonIconSize
    readonly property real colorPickerButtonTrailingTone: dark ? 30 : 90
    readonly property real colorPickerButtonIconTone: dark ? 80 : 30
    readonly property real colorPickerPadding: PickerRecipe.colorPadding
    readonly property real colorPickerSpacing: PickerRecipe.colorSpacing
    readonly property real colorPickerChannelRowSpacing: PickerRecipe.colorChannelRowSpacing
    readonly property real colorPickerWheelSize: PickerRecipe.colorWheelSize
    readonly property real colorPickerTriangleSize: PickerRecipe.colorTriangleSize
    readonly property real colorPickerWheelThickness: PickerRecipe.colorWheelThickness
    readonly property real colorPickerWheelHandleExtension: PickerRecipe.colorWheelHandleExtension
    readonly property real colorPickerWheelHandleHeight: PickerRecipe.colorWheelHandleHeight
    readonly property real colorPickerWheelHandleRadius: PickerRecipe.colorWheelHandleRadius
    readonly property real colorPickerTriangleHandleSize: PickerRecipe.colorTriangleHandleSize
    readonly property real colorPickerTriangleHandleBorderWidth: PickerRecipe.colorTriangleHandleBorderWidth
    readonly property color pickerHandleLight: "#ffffff"
    readonly property color pickerHandleDark: "#000000"
    readonly property real colorPickerChannelTrackWidth: PickerRecipe.colorChannelTrackWidth
    readonly property real colorPickerChannelValueHeight: PickerRecipe.colorChannelValueHeight
    readonly property real colorPickerChannelIndicatorWidth: PickerRecipe.colorChannelIndicatorWidth
    readonly property real colorPickerChannelIndicatorHeight: PickerRecipe.colorChannelIndicatorHeight
    readonly property real colorPickerChannelIndicatorBorderWidth: PickerRecipe.colorChannelIndicatorBorderWidth
    readonly property real colorPickerStepperWidth: PickerRecipe.colorStepperWidth
    readonly property real colorPickerStepperIconSize: PickerRecipe.colorStepperIconSize
    readonly property real colorPickerStepperInset: PickerRecipe.colorStepperInset
    readonly property real colorPickerStepperTextInset: PickerRecipe.colorStepperTextInset
    readonly property color colorPickerCheckerLight: "#ffffff"
    readonly property color colorPickerCheckerDark: "#cccccc"
    readonly property color colorPickerChannelIndicatorBorder: pickerHandleLight
    readonly property color colorPickerChannelIndicatorOutline: Qt.alpha(pickerHandleDark, 0.4)
    readonly property color colorPickerSwatchOutline: Qt.alpha(surfaceForeground, 0.2)
    readonly property real colorPickerSwatchSize: PickerRecipe.colorSwatchSize
    readonly property real pickerWidth: PickerRecipe.width
    readonly property real pickerPadding: PickerRecipe.padding
    readonly property real pickerDaySize: PickerRecipe.daySize
    readonly property real pickerDaySpacing: PickerRecipe.daySpacing
    readonly property real pickerDayIndicatorSize: PickerRecipe.dayIndicatorSize
    readonly property real pickerHeaderPadding: PickerRecipe.headerPadding
    readonly property real pickerHeaderVerticalPadding: PickerRecipe.headerVerticalPadding
    readonly property real colorPickerChannelTrackHeight: PickerRecipe.colorChannelTrackHeight
    readonly property real colorPickerChannelValueWidth: PickerRecipe.colorChannelValueWidth
    readonly property real colorPickerChannelLabelWidth: PickerRecipe.colorChannelLabelWidth
    readonly property real colorPickerCheckerSize: PickerRecipe.colorCheckerSize
    // QCM0.6.1 ScrollBar geometry and medium1/retention timing.
    readonly property real scrollBarExtent: ScrollBarRecipe.extent
    readonly property real scrollBarPadding: ScrollBarRecipe.padding
    readonly property real scrollBarThumbWidth: ScrollBarRecipe.thumbWidth
    readonly property real scrollBarExpandedThumbWidth: ScrollBarRecipe.expandedThumbWidth
    readonly property real scrollBarThumbOpacity: 0.38
    readonly property real scrollBarPressedOpacity: 0.8
    readonly property real scrollBarTrackOpacity: 0.12
    readonly property int scrollBarFadeDuration: 250
    readonly property int scrollBarRetentionDuration: 2450
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
    readonly property InputSize comboBoxExtraSmall: InputSize {
        height: 32; horizontalPadding: 8; verticalPadding: 0
        iconSize: 18; spacing: 0; font: root.bodySmall
    }
    readonly property InputSize comboBoxSmall: InputSize {
        height: 40; horizontalPadding: 10; verticalPadding: 0
        iconSize: 20; spacing: 0; font: root.bodyMedium
    }
    readonly property InputSize comboBoxMedium: InputSize {
        height: 48; horizontalPadding: 12; verticalPadding: 0
        iconSize: 24; spacing: 0; font: root.bodyLarge
    }
    readonly property InputSize comboBoxLarge: InputSize {
        height: 56; horizontalPadding: 16; verticalPadding: 0
        iconSize: 24; spacing: 0; font: root.bodyLarge
    }
    readonly property InputSize comboBoxExtraLarge: InputSize {
        height: 72; horizontalPadding: 24; verticalPadding: 0
        iconSize: 32; spacing: 0; font: root.bodyLarge
    }
    readonly property real listCardOneLineHeight: ListCardRecipe.oneLineHeight
    readonly property real listCardTwoLineHeight: ListCardRecipe.twoLineHeight
    readonly property real listCardThreeLineHeight: ListCardRecipe.threeLineHeight
    readonly property real listCardMinimumWidth: ListCardRecipe.minimumWidth
    readonly property real listCardLeadingPadding: ListCardRecipe.leadingPadding
    readonly property real listCardTrailingPadding: ListCardRecipe.trailingPadding
    readonly property real listCardVerticalPadding: ListCardRecipe.verticalPadding
    readonly property real listCardSpacing: ListCardRecipe.spacing
    readonly property real listCardIconSize: ListCardRecipe.iconSize
    readonly property real listCardCardRadius: ListCardRecipe.cardRadius
    readonly property real listCardCardMinimumSize: ListCardRecipe.cardMinimumSize
    readonly property real listCardCardPadding: ListCardRecipe.cardPadding
    readonly property real chipAvatarSize: ChipRecipe.avatarSize
    readonly property real chipDraggedOpacity: 0.16
    readonly property real chipHeight: ChipRecipe.height
    readonly property real badgeDotDiameter: BadgeRecipe.dotDiameter
    readonly property real badgeLabelHeight: BadgeRecipe.labelHeight
    readonly property real badgeLabelMinimumWidth: BadgeRecipe.labelMinimumWidth
    readonly property real badgeHorizontalPadding: BadgeRecipe.labelHorizontalPadding
    readonly property real badgeOffsetX: BadgeRecipe.offsetX
    readonly property real badgeOffsetY: BadgeRecipe.offsetY
    readonly property color badgeContainer: error
    readonly property color badgeForeground: errorForeground
    readonly property font labelSmall: Qt.font({ family: root.effectiveFontFamily,
        pixelSize: 11, weight: Font.Medium, letterSpacing: 0.5 })
    readonly property real chipMinimumWidth: ChipRecipe.minimumWidth
    readonly property real chipRadius: ChipRecipe.radius
    readonly property real chipPadding: ChipRecipe.padding
    readonly property real chipIconPadding: ChipRecipe.iconPadding
    readonly property real chipSpacing: ChipRecipe.spacing
    readonly property real chipIconSize: ChipRecipe.iconSize
    readonly property real chipTrailingTarget: ChipRecipe.trailingTarget
    readonly property real chipEmbedSpacing: ChipRecipe.embedSpacing
    // QCM 0.6.1: standard.defaultEffects, standard.fastSpatial and short3.
    readonly property real buttonShapeSpringStiffness: 1600
    readonly property real buttonShapeSpringDampingRatio: 1
    readonly property real buttonSpringVisibilityThreshold: 0.01
    readonly property real buttonGroupSpringStiffness: 1400
    readonly property real buttonGroupSpringDampingRatio: 0.9
    readonly property real buttonGroupExpandedRatio: 0.15
    readonly property int iconFillMotionDuration: 150
    readonly property int chipSelectionDuration: 100
    readonly property int chipPaddingDuration: 50
    readonly property int chipSelectionEasing: Easing.Linear
    readonly property int chipPaddingEasing: Easing.Linear
    readonly property color chipAssistInk: surfaceForeground
    readonly property color chipInk: surfaceVariantForeground
    readonly property color chipSelectedInk: secondaryContainerForeground
    readonly property color chipIconInk: primary
    readonly property color chipDisabledOutline: Qt.alpha(surfaceForeground, disabledContainerOpacity)

    readonly property real progressThickness: ProgressRecipe.thickness
    readonly property real progressGap: ProgressRecipe.gap
    readonly property real progressStopDiameter: ProgressRecipe.stopDiameter
    readonly property real progressLinearMinimumWidth: ProgressRecipe.linearMinimumWidth
    readonly property real progressCircularSize: ProgressRecipe.circularSize
    readonly property real progressCircularGapAngle: ProgressRecipe.circularGapAngle
    readonly property real progressWavyLinearMinimumWidth: ProgressRecipe.wavyLinearMinimumWidth
    readonly property real progressWavyCircularSize: ProgressRecipe.wavyCircularSize
    readonly property real progressLinearWaveAmplitude: ProgressRecipe.linearWaveAmplitude
    readonly property real progressCircularWaveAmplitude: ProgressRecipe.circularWaveAmplitude
    readonly property real progressDeterminateWaveLength: ProgressRecipe.determinateWaveLength
    readonly property real progressIndeterminateWaveLength: ProgressRecipe.indeterminateWaveLength
    readonly property real progressCircularWaveLength: ProgressRecipe.circularWaveLength
    readonly property color progressIndicator: primary
    readonly property color progressTrack: secondaryContainer
    readonly property color progressCircularTrack: transparent
    readonly property color progressDisabledIndicator: disabledLabel
    readonly property color progressDisabledTrack: disabledContainer
    readonly property int progressValueDuration: 150
    readonly property int progressLinearCycleDuration: 1800
    readonly property int progressCircularCycleDuration: 5400
    readonly property int progressContiguousCycleDuration: 333
    readonly property int progressRetreatCycleDuration: 6000
    readonly property int progressWaveCycleDuration: 1000
    readonly property int progressAmplitudeDuration: 500
    readonly property int progressOpacityDuration: 100

    // QCM 0.6.1 loading shape geometry and timing, independent of circular progress.
    readonly property real busyContainerSize: 48
    readonly property real busyShapeSize: 40
    readonly property int busyShapeDuration: 650
    readonly property int busyShowDelay: 0
    readonly property int busyMinimumHideDelay: 0
    readonly property int busyMaximumHideDelay: 1000
    readonly property color busyIndicator: primary
    readonly property color busyDisabledIndicator: disabledLabel

    readonly property real checkBoxIndicatorSize: CheckBoxRecipe.indicatorSize
    readonly property real checkBoxStateLayerDiameter: CheckBoxRecipe.stateLayerDiameter
    readonly property real checkBoxHorizontalPadding: spacingSmall
    readonly property real checkBoxVerticalPadding: 15
    readonly property real checkBoxSpacing: spacingSmall
    readonly property real checkBoxMinimumWidth: checkBoxIndicatorSize + 2 * checkBoxHorizontalPadding + checkBoxSpacing
    readonly property real checkBoxMinimumHeight: checkBoxIndicatorSize + 2 * checkBoxVerticalPadding
    readonly property color checkBoxOutline: surfaceVariantForeground
    readonly property color checkBoxActiveOutline: surfaceForeground
    readonly property color checkBoxSelectedIndicator: primary
    readonly property color checkBoxSelectedGlyph: primaryForeground
    readonly property color checkBoxDisabledIndicator: disabledLabel
    readonly property color checkBoxDisabledGlyph: surface
    readonly property color checkBoxStateLayer: surfaceForeground
    readonly property color checkBoxSelectedStateLayer: primary

    readonly property real radioColorChoiceDiameter: RadioRecipe.colorChoiceDiameter
    readonly property real radioColorChoiceSelectedDiameter: RadioRecipe.colorChoiceSelectedDiameter
    readonly property real radioColorChoiceSelectionRingWidth: RadioRecipe.colorChoiceSelectionRingWidth
    readonly property real radioIndicatorDiameter: RadioRecipe.indicatorDiameter
    readonly property real radioOutlineWidth: RadioRecipe.outlineWidth
    readonly property real radioDotDiameter: RadioRecipe.dotDiameter
    readonly property real radioStateLayerDiameter: RadioRecipe.stateLayerDiameter
    readonly property real radioHorizontalPadding: spacingSmall
    readonly property real radioVerticalPadding: 14
    readonly property real radioSpacing: spacingSmall
    readonly property real radioMinimumWidth: radioIndicatorDiameter + 2 * radioHorizontalPadding + radioSpacing
    readonly property real radioMinimumHeight: radioIndicatorDiameter + 2 * radioVerticalPadding
    readonly property int radioSelectionDuration: 150
    readonly property int radioSelectionEasing: Easing.Linear
    readonly property real radioFocusIndicatorWidth: RadioRecipe.focusWidth
    readonly property real radioFocusIndicatorDiameter: radioIndicatorDiameter + 4 * radioFocusIndicatorWidth
    readonly property color radioIndicator: surfaceVariantForeground
    readonly property color radioCheckedIndicator: primary
    readonly property color radioActiveIndicator: surfaceForeground
    readonly property color radioDisabledIndicator: disabledLabel
    readonly property color radioStateLayer: surfaceForeground
    readonly property color radioCheckedStateLayer: primary
    readonly property color radioPressedStateLayer: primary
    readonly property color radioCheckedPressedStateLayer: surfaceForeground

    readonly property real switchTrackWidth: SwitchRecipe.trackWidth
    readonly property real switchTrackHeight: SwitchRecipe.trackHeight
    readonly property real switchTrackOutlineWidth: SwitchRecipe.edgeInset
    readonly property real switchThumbUncheckedDiameter: SwitchRecipe.thumbUncheckedDiameter
    readonly property real switchThumbCheckedDiameter: SwitchRecipe.thumbCheckedDiameter
    readonly property real switchThumbPressedDiameter: SwitchRecipe.thumbPressedDiameter
    readonly property real switchIconSize: 16
    readonly property real switchStateLayerDiameter: 28
    readonly property int switchColorDuration: 200
    readonly property int switchMotionDuration: shapeDuration
    readonly property int switchMotionEasing: shapeEasing
    readonly property color switchTrack: surfaceContainerHighest
    readonly property color switchCheckedTrack: primary
    readonly property color switchThumb: outline
    readonly property color switchCheckedThumb: primaryForeground
    readonly property color switchActiveThumb: surfaceVariantForeground
    readonly property color switchCheckedActiveThumb: primaryContainer
    readonly property color switchIcon: surfaceContainerHighest
    readonly property color switchCheckedIcon: primaryContainerForeground
    readonly property color switchDisabledTrack: Qt.alpha(surfaceForeground, disabledContainerOpacity)
    readonly property real switchDisabledThumbOpacity: disabledLabelOpacity
    readonly property color switchStateLayer: surfaceForeground
    readonly property color switchCheckedStateLayer: primary

    readonly property real appToolbarHeight: 64
    readonly property real appToolbarPadding: 8
    readonly property real searchHeight: 56
    readonly property real searchMinimumWidth: 200
    readonly property InputSize searchMetrics: InputSize {
        height: root.searchHeight; horizontalPadding: 16; verticalPadding: 0
        iconSize: 24; spacing: 16; font: root.bodyLarge
    }
    readonly property real appNavigationCompactBreakpoint: 600
    readonly property real appNavigationExpandedBreakpoint: 1200
    readonly property real appNavigationExpandedWidth: 220
    readonly property real appNavigationSheetWidth: 360
    readonly property real appNavigationMinimumHeight: 400
    readonly property real appNavigationScrimOpacity: 0.32
    readonly property int appNavigationMotionDuration: 300
    readonly property int appNavigationMotionEasing: Easing.OutCubic
    readonly property real navigationDestinationHeight: 56
    readonly property real navigationDestinationLeadingPadding: 16
    readonly property real navigationDestinationTrailingPadding: 24
    readonly property real navigationDestinationSpacing: 12

    readonly property real navigationIconSize: 24
    readonly property real navigationRippleOpacity: 0.10
    readonly property real navigationBarIndicatorWidth: 64
    readonly property real navigationBarIndicatorStartWidth: 48
    readonly property real navigationBarIndicatorHeight: 32
    readonly property real navigationBarLabelSpacing: 4
    readonly property real navigationBarLabelHeight: 16
    readonly property real navigationBarItemHeight: navigationBarIndicatorHeight + navigationBarLabelSpacing + navigationBarLabelHeight
    readonly property int navigationBarSelectionDuration: 100
    readonly property int navigationBarSelectionEasing: Easing.Linear
    readonly property real navigationRailCollapsedWidth: NavigationRecipe.collapsedWidth
    readonly property real navigationRailIndicatorWidth: NavigationRecipe.indicatorWidth
    readonly property real navigationRailIndicatorHeight: NavigationRecipe.indicatorHeight
    readonly property real navigationRailExpandedIndicatorSize: NavigationRecipe.expandedHeight
    readonly property real navigationRailIndicatorMargin: 16
    readonly property real navigationRailExpandedWidth: navigationRailExpandedIndicatorSize + navigationRailIndicatorMargin * 2
    // Qt adaptation of QCM's standard 700/.9 SpringMotion, not an exact spring port.
    readonly property int navigationRailSelectionDuration: 250
    readonly property int navigationRailSelectionEasing: Easing.OutCubic
    readonly property real tabMinimumWidth: 80
    readonly property real tabHeight: 48
    readonly property real tabHorizontalPadding: 16
    readonly property real tabSpacing: 8
    readonly property real tabBarSpacing: 1
    readonly property real tabDividerHeight: 1
    readonly property real tabIndicatorHeight: TabRecipe.indicatorThickness
    readonly property real tabIndicatorRadius: 3
    readonly property real tabIndicatorMinimumWidth: TabRecipe.minimumIndicatorWidth
    readonly property int tabIndicatorDuration: 250
    readonly property list<real> tabIndicatorEasingCurve: [0.2, 0, 0, 1, 1, 1]
    readonly property font titleSmall: Qt.font({ family: root.effectiveFontFamily,
        pixelSize: 14, weight: Font.Medium, letterSpacing: 0.1 })

    readonly property real sliderTrackThickness: SliderRecipe.trackThickness
    readonly property real sliderMediumTrackThickness: 40
    readonly property real sliderHandleExtent: SliderRecipe.handleExtent
    readonly property real sliderHandleLength: SliderRecipe.handleLength
    readonly property real sliderHandleWidth: SliderRecipe.handleWidth
    readonly property real sliderActiveHandleWidth: SliderRecipe.activeHandleWidth
    readonly property real sliderTrackGap: SliderRecipe.trackGap
    readonly property real sliderTrackInnerRadius: SliderRecipe.trackInnerRadius
    readonly property real sliderFocusExpansion: SliderRecipe.focusExpansion
    readonly property real sliderFocusWidth: SliderRecipe.focusWidth
    readonly property real sliderValueMinimum: SliderRecipe.valueMinimum
    readonly property real sliderValueGap: SliderRecipe.valueGap
    readonly property real sliderStopDiameter: SliderRecipe.stopDiameter
    readonly property int sliderMaxVisibleStops: SliderRecipe.maxVisibleStops
    readonly property real sliderMinimumLength: 200
    readonly property real sliderInsetIconSize: 24
    readonly property real sliderInsetIconPadding: 8
    readonly property int sliderMotionDuration: 100
    readonly property list<real> sliderLabelEasingCurve: [0.2, 0, 0, 1, 1, 1]
    readonly property real sliderValueElevation: 3

    readonly property real referenceCardWidth: 400
    readonly property real inputGalleryPadding: 12
    readonly property real inputGallerySpacing: spacingSmall
    readonly property real comboBoxMinimumWidth: 64
    readonly property real comboBoxHeight: comboBoxMedium.height
    readonly property real comboBoxHorizontalPadding: comboBoxMedium.horizontalPadding
    readonly property real comboBoxIndicatorSize: comboBoxMedium.iconSize
    readonly property real comboBoxSpacing: comboBoxMedium.spacing
    readonly property real comboBoxPopupMaximumWidth: 280
    readonly property real comboBoxPopupMargin: 12
    readonly property real comboBoxPopupGap: 4
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
    readonly property int dialogEnterDuration: 250
    readonly property int dialogFadeDuration: 150
    readonly property real dialogClosedScale: 0.9
    readonly property real dialogScrimOpacity: 0.32
    readonly property real dialogMinimumWidth: 280
    readonly property real dialogMaximumWidth: 560
    readonly property real dialogPadding: 24
    readonly property real dialogVerticalPadding: 12
    readonly property real dialogCornerRadius: radiusExtraLarge
    readonly property real feedbackCornerRadius: radiusExtraSmall
    readonly property real snackbarMinimumHeight: 48
    readonly property int snackbarTimeout: 5000
    readonly property real tooltipMaximumWidth: 320
    readonly property int tooltipDelay: 500
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
    readonly property real buttonBusyIndicatorInset: ButtonRecipe.busyIndicatorInset
    readonly property real buttonBusyIndicatorStrokeWidth: ButtonRecipe.busyIndicatorStrokeWidth
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
    readonly property font headlineMedium: Qt.font({ family: root.effectiveFontFamily,
        pixelSize: 28, weight: Font.Normal, letterSpacing: 0 })
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
