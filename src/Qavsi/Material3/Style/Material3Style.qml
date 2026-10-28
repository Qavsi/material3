pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

SK.Style {
    id: root
    property Material3Theme lightTokens: Material3Theme { }
    property Material3Theme darkTokens: Material3Theme { dark: true }
    property bool reducedMotion: false
    readonly property bool effectiveReducedMotion: reducedMotion
        || Application.styleHints.accessibility.motionPreference === Qt.MotionPreference.ReducedMotion
    readonly property Material3Theme tokens: themeName === "Dark" ? darkTokens : lightTokens
    readonly property Material3ComboBoxDelegate comboBoxDelegate: Material3ComboBoxDelegate { }
    readonly property SmallButtonDelegate buttonDelegate: SmallButtonDelegate { }
    readonly property Material3MenuDelegate menuDelegate: Material3MenuDelegate { }
    readonly property Material3TextFieldDelegate textFieldDelegate: Material3TextFieldDelegate { }


    readonly property Material3ProgressDelegate progressFactory: Material3ProgressDelegate { }
    readonly property SK.StyleVariation circularProgress: SK.StyleVariation {
        name: "progressCircular"
        progressBar {
            indicator {
                width: root.tokens.progressCircularSize
                height: root.tokens.progressCircularSize
                fillWidth: false
                fillHeight: false
                data: Material3ProgressParameters {
                    tokens: root.tokens
                    reducedMotion: root.effectiveReducedMotion
                    circular: true
                }
            }
        }
    }
    progressBar {
        padding: 0
        background {
            visible: false
            width: 0
            height: 0
            margins: 0
        }
        indicator {
            width: root.tokens.progressLinearMinimumWidth
            height: root.tokens.progressThickness
            margins: 0
            fillWidth: true
            fillHeight: true
            alignment: Qt.AlignCenter
            delegate: root.progressFactory.indicator
            data: Material3ProgressParameters { tokens: root.tokens; reducedMotion: root.effectiveReducedMotion }
            foreground.visible: false
        }
    }
    busyIndicator {
        padding: 0
        background {
            visible: false
            width: 0
            height: 0
            margins: 0
        }
        indicator {
            width: root.tokens.progressCircularSize
            height: root.tokens.progressCircularSize
            margins: 0
            fillWidth: true
            fillHeight: true
            alignment: Qt.AlignCenter
            delegate: root.progressFactory.indicator
            data: Material3ProgressParameters {
                tokens: root.tokens
                reducedMotion: root.effectiveReducedMotion
                circular: true
                busy: true
            }
            foreground.visible: false
        }
    }
    readonly property Material3CheckBoxDelegate checkBoxFactory: Material3CheckBoxDelegate { }
    readonly property Material3RadioButtonDelegate radioFactory: Material3RadioButtonDelegate { }
    readonly property Material3SwitchDelegate switchFactory: Material3SwitchDelegate { }
    readonly property Material3AppNavigationDelegate appNavigationFactory: Material3AppNavigationDelegate { }
    readonly property Material3NavigationDelegate navigationDelegate: Material3NavigationDelegate { }
    fonts.itemDelegate: root.tokens.bodyLarge
    fonts.tabBar: root.tokens.titleSmall
    readonly property Material3SliderDelegate sliderDelegate: Material3SliderDelegate { }
    readonly property Material3SliderVariation mediumSlider: Material3SliderVariation {
        sourceStyle: root
        name: "sliderMedium"
    }

    themeName: "Light"
    fonts.system: root.tokens.labelLarge
    fonts.button: root.tokens.labelLarge
    fonts.textField: root.tokens.bodyLarge
    fonts.comboBox: root.tokens.bodyLarge
    comboBox {
        leftPadding: root.tokens.comboBoxHorizontalPadding
        rightPadding: root.tokens.comboBoxHorizontalPadding
        topPadding: 0
        bottomPadding: 0
        spacing: root.tokens.comboBoxSpacing
        text {
            color: root.tokens.surfaceForeground
            alignment: Qt.AlignLeft | Qt.AlignVCenter
            padding: 0
        }
        background {
            width: root.tokens.comboBoxMinimumWidth
            height: root.tokens.comboBoxHeight
            radius: root.tokens.textFieldCornerRadius
            color: root.tokens.transparent
            gradient: null
            margins: 0
            border.width: root.tokens.textFieldOutlineWidth
            border.color: root.tokens.outline
            shadow.visible: false
            delegate: root.comboBoxDelegate.background
            data: Material3ComboBoxParameters { tokens: root.tokens; reducedMotion: root.effectiveReducedMotion }
        }
        indicator {
            color: root.tokens.transparent
            margins: 0
            fillWidth: false
            fillHeight: false
            alignment: Qt.AlignRight | Qt.AlignVCenter
            foreground {
                width: root.tokens.comboBoxIndicatorSize
                height: root.tokens.comboBoxIndicatorSize
                color: root.tokens.surfaceVariantForeground
                margins: 0
                fillWidth: false
                fillHeight: false
                alignment: Qt.AlignCenter
                delegate: root.comboBoxDelegate.indicator
            }
        }
        hovered.background.border.color: root.tokens.surfaceForeground
        focused {
            background.border.width: root.tokens.textFieldFocusedOutlineWidth
            background.border.color: root.tokens.primary
        }
        disabled {
            text.color: root.tokens.disabledLabel
            background.border.color: root.tokens.disabledContainer
            indicator.foreground.color: root.tokens.disabledLabel
        }
    }
    readonly property Material3DialogDelegate dialogDelegate: Material3DialogDelegate { }
    dialog {
        leftPadding: root.tokens.dialogPadding
        rightPadding: root.tokens.dialogPadding
        topPadding: root.tokens.dialogVerticalPadding
        bottomPadding: root.tokens.dialogVerticalPadding
        spacing: 0
        text {
            color: root.tokens.surfaceForeground
            leftPadding: root.tokens.dialogPadding
            rightPadding: root.tokens.dialogPadding
            topPadding: root.tokens.dialogPadding
            bottomPadding: root.tokens.dialogVerticalPadding
        }
        background {
            width: root.tokens.dialogMinimumWidth
            radius: root.tokens.dialogCornerRadius
            color: root.tokens.surfaceContainerHigh
            gradient: null
            border.width: 0
            margins: 0
            data: Material3MenuParameters { tokens: root.tokens; reducedMotion: root.effectiveReducedMotion }
            shadow {
                visible: true
                color: root.tokens.shadow
                opacity: root.tokens.elevationContainerOpacity
                delegate: root.dialogDelegate.shadow
            }
        }
    }
    dialogButtonBox {
        leftPadding: root.tokens.dialogPadding
        rightPadding: root.tokens.dialogPadding
        topPadding: root.tokens.dialogVerticalPadding
        bottomPadding: root.tokens.dialogVerticalPadding
        spacing: root.tokens.spacingSmall
        background { color: root.tokens.transparent; gradient: null; border.width: 0; shadow.visible: false }
    }
    popup {
        leftPadding: 0
        rightPadding: 0
        topPadding: root.tokens.menuVerticalPadding
        bottomPadding: root.tokens.menuVerticalPadding
        background {
            width: root.tokens.menuMinimumWidth
            height: root.tokens.menuMinimumHeight
            radius: root.tokens.menuCornerRadius
            color: root.tokens.surfaceContainer
            gradient: null
            border.width: 0
            margins: 0
            data: Material3MenuParameters { tokens: root.tokens; reducedMotion: root.effectiveReducedMotion }
            shadow {
                visible: true
                color: root.tokens.shadow
                opacity: root.tokens.elevationContainerOpacity
                delegate: root.menuDelegate.shadow
            }
        }
    }
    textField {
        background {
            delegate: root.textFieldDelegate.background
            data: Material3TextFieldParameters {
                tokens: root.tokens
                reducedMotion: root.effectiveReducedMotion
            }
        }
    }
    button {
        background {
            data: SmallButtonParameters {
                tokens: root.tokens
                reduceMotion: root.effectiveReducedMotion
            }
            delegate: root.buttonDelegate.background
            shadow.delegate: root.buttonDelegate.shadow
        }
    }
    flatButton.background.delegate: root.buttonDelegate.background
    flatButton.background.shadow.delegate: root.buttonDelegate.shadow
    flatButton.background.data: root.button.background.data
    roundButton.background.delegate: root.buttonDelegate.background
    roundButton.background.shadow.delegate: root.buttonDelegate.shadow
    roundButton.background.data: root.button.background.data
    delayButton.background.delegate: root.buttonDelegate.background
    delayButton.background.shadow.delegate: root.buttonDelegate.shadow
    delayButton.background.data: root.button.background.data
    toolButton.background.delegate: root.buttonDelegate.background
    toolButton.background.shadow.delegate: root.buttonDelegate.shadow
    toolButton.background.data: root.button.background.data
    menu {
        leftPadding: 0
        rightPadding: 0
        topPadding: root.tokens.menuVerticalPadding
        bottomPadding: root.tokens.menuVerticalPadding
        spacing: 0
        background {
            width: root.tokens.menuMinimumWidth
            height: root.tokens.menuMinimumHeight
            radius: root.tokens.menuCornerRadius
            color: root.tokens.surfaceContainer
            gradient: null
            border.width: 0
            margins: 0
            data: Material3MenuParameters {
                tokens: root.tokens
                reducedMotion: root.effectiveReducedMotion
            }
            shadow {
                visible: true
                color: root.tokens.shadow
                opacity: root.tokens.elevationContainerOpacity
                delegate: root.menuDelegate.shadow
            }
        }
        focused {
            background {
                color: root.tokens.surfaceContainer
                border.width: 0
            }
        }
    }
    menuItem {
        leftPadding: root.tokens.menuItemHorizontalPadding
        rightPadding: root.tokens.menuItemHorizontalPadding
        topPadding: 0
        bottomPadding: 0
        spacing: root.tokens.menuItemSpacing
        text.color: root.tokens.surfaceForeground
        background {
            width: root.tokens.menuMinimumWidth
            height: root.tokens.menuItemHeight
            radius: 0
            color: root.tokens.transparent
            gradient: null
            border.width: 0
            margins: 0
            shadow.visible: false
            data: root.menu.background.data
            delegate: root.menuDelegate.itemBackground
        }
        hovered.background.color: root.tokens.transparent
        highlighted.background.color: root.tokens.transparent
        focused.background.color: root.tokens.transparent
        pressed.background.color: root.tokens.transparent
        checked {
            background.color: root.tokens.secondaryContainer
            hovered.background.color: root.tokens.secondaryContainer
            highlighted.background.color: root.tokens.secondaryContainer
            focused.background.color: root.tokens.secondaryContainer
            pressed.background.color: root.tokens.secondaryContainer
        }
        disabled {
            text.color: root.tokens.disabledLabel
            background.color: root.tokens.transparent
            checked.background.color: root.tokens.secondaryContainer
        }
    }
    checkBox {
        leftPadding: root.tokens.checkBoxHorizontalPadding
        rightPadding: root.tokens.checkBoxHorizontalPadding
        topPadding: root.tokens.checkBoxVerticalPadding
        bottomPadding: root.tokens.checkBoxVerticalPadding
        spacing: root.tokens.checkBoxSpacing
        text {
            color: root.tokens.surfaceForeground
            alignment: Qt.AlignLeft | Qt.AlignVCenter
            padding: 0
        }
        background {
            width: root.tokens.checkBoxMinimumWidth
            height: root.tokens.checkBoxMinimumHeight
            margins: 0
            visible: false
            shadow.visible: false
        }
        indicator {
            width: root.tokens.checkBoxIndicatorSize
            height: root.tokens.checkBoxIndicatorSize
            visible: true
            margins: 0
            fillWidth: false
            fillHeight: false
            alignment: Qt.AlignLeft | Qt.AlignVCenter
            color: root.tokens.transparent
            gradient: null
            border.width: 0
            shadow.visible: false
            foreground.visible: false
            delegate: root.checkBoxFactory.indicator
            data: Material3CheckBoxParameters {
                tokens: root.tokens
                reducedMotion: root.effectiveReducedMotion
            }
        }
        checked.indicator.foreground.visible: false
        hovered.indicator.foreground.visible: false
        pressed.indicator.foreground.visible: false
        focused.indicator.foreground.visible: false
        disabled {
            text.color: root.tokens.disabledLabel
            indicator.foreground.visible: false
            checked.indicator.foreground.visible: false
        }
    }

    radioButton {
        leftPadding: root.tokens.radioHorizontalPadding
        rightPadding: root.tokens.radioHorizontalPadding
        topPadding: root.tokens.radioVerticalPadding
        bottomPadding: root.tokens.radioVerticalPadding
        spacing: root.tokens.radioSpacing
        text {
            color: root.tokens.surfaceForeground
            alignment: Qt.AlignLeft | Qt.AlignVCenter
            padding: 0
        }
        background {
            width: root.tokens.radioMinimumWidth
            height: root.tokens.radioMinimumHeight
            margins: 0
            visible: false
            shadow.visible: false
        }
        indicator {
            width: root.tokens.radioIndicatorDiameter
            height: root.tokens.radioIndicatorDiameter
            visible: true
            margins: 0
            fillWidth: false
            fillHeight: false
            alignment: Qt.AlignLeft | Qt.AlignVCenter
            color: root.tokens.transparent
            gradient: null
            border.width: 0
            shadow.visible: false
            foreground.visible: false
            delegate: root.radioFactory.indicator
            data: Material3RadioButtonParameters {
                tokens: root.tokens
                reducedMotion: root.effectiveReducedMotion
            }
        }
        checked.indicator.foreground.visible: false
        hovered.indicator.foreground.visible: false
        pressed.indicator.foreground.visible: false
        focused.indicator.foreground.visible: false
        disabled {
            text.color: root.tokens.disabledLabel
            indicator.foreground.visible: false
            checked.indicator.foreground.visible: false
        }
    }

    switchControl {
        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        bottomPadding: 0
        spacing: root.tokens.spacingSmall
        text {
            color: root.tokens.surfaceForeground
            alignment: Qt.AlignLeft | Qt.AlignVCenter
            padding: 0
        }
        // Native Switch derives its natural width from the hidden background.
        background {
            width: root.tokens.switchTrackWidth
            height: root.tokens.switchTrackHeight
            visible: false
            margins: 0
            shadow.visible: false
        }
        handle.visible: false
        indicator {
            visible: true
            width: root.tokens.switchTrackWidth
            height: root.tokens.switchTrackHeight
            radius: root.tokens.switchTrackHeight / 2
            margins: 0
            alignment: Qt.AlignLeft | Qt.AlignVCenter
            fillWidth: false
            fillHeight: false
            color: root.tokens.switchTrack
            gradient: null
            border.width: root.tokens.switchTrackOutlineWidth
            border.color: root.tokens.outline
            foreground.visible: false
            delegate: root.switchFactory.indicator
            data: Material3SwitchParameters {
                tokens: root.tokens
                reducedMotion: root.effectiveReducedMotion
            }
        }
        checked.indicator.foreground.visible: false
        checked.indicator.color: root.tokens.switchCheckedTrack
        disabled {
            text.color: root.tokens.disabledLabel
            indicator.color: root.tokens.switchDisabledTrack
            indicator.border.color: Qt.alpha(root.tokens.outline, root.tokens.disabledContainerOpacity)
            checked.indicator.color: root.tokens.switchDisabledTrack
        }
    }

    toolBar {
        padding: root.tokens.appToolbarPadding
        spacing: root.tokens.spacingSmall
        background {
            height: root.tokens.appToolbarHeight
            radius: root.tokens.appToolbarHeight / 2
            color: root.tokens.surfaceContainer
            gradient: null
            margins: 0
            border.width: 0
            shadow.visible: false
        }
    }

    tabBar {
        leftPadding: 0; rightPadding: 0; topPadding: 0; bottomPadding: 0
        spacing: root.tokens.tabBarSpacing
        background {
            height: root.tokens.tabHeight
            radius: 0
            color: root.tokens.transparent
            gradient: null
            margins: 0
            border.width: 0
            shadow.visible: false
            delegate: root.navigationDelegate.barBackground
            data: Material3NavigationParameters { tokens: root.tokens; reducedMotion: root.effectiveReducedMotion }
        }
    }
    tabButton {
        leftPadding: root.tokens.tabHorizontalPadding
        rightPadding: root.tokens.tabHorizontalPadding
        topPadding: 0; bottomPadding: 0
        spacing: root.tokens.tabSpacing
        text { color: root.tokens.surfaceForeground; alignment: Qt.AlignCenter; padding: 0 }
        background {
            width: root.tokens.tabMinimumWidth
            height: root.tokens.tabHeight
            radius: 0
            color: root.tokens.transparent
            gradient: null
            margins: 0
            border.width: 0
            shadow.visible: false
            delegate: root.navigationDelegate.itemBackground
            data: Material3NavigationParameters { tokens: root.tokens; reducedMotion: root.effectiveReducedMotion }
        }
        hovered.background.color: root.tokens.transparent
        focused.background.color: root.tokens.transparent
        pressed.background.color: root.tokens.transparent
        checked { text.color: root.tokens.primary; background.color: root.tokens.transparent }
        disabled { text.color: root.tokens.disabledLabel; background.color: root.tokens.transparent; checked.text.color: root.tokens.disabledLabel }
    }

    slider {
        padding: 0
        background {
            visible: true
            width: root.tokens.sliderMinimumLength
            height: root.tokens.sliderHandleLength
            color: root.tokens.transparent
            gradient: null
            margins: 0
            border.width: 0
            shadow.visible: false
            delegate: root.sliderDelegate.background
            data: Material3SliderParameters { tokens: root.tokens; reducedMotion: root.effectiveReducedMotion }
        }
        indicator.visible: false
        handle {
            width: root.tokens.sliderHandleExtent
            height: root.tokens.sliderHandleLength
            margins: 0
            fillWidth: false
            fillHeight: false
            color: root.tokens.transparent
            border.width: 0
            delegate: root.sliderDelegate.handle
            data: root.slider.background.data
            first.delegate: root.sliderDelegate.firstHandle
            second.delegate: root.sliderDelegate.secondHandle
            // Explicit child dimensions/data prevent relying on undocumented handle inheritance.
            first.width: root.tokens.sliderHandleExtent
            first.height: root.tokens.sliderHandleLength
            first.data: root.slider.background.data
            second.width: root.tokens.sliderHandleExtent
            second.height: root.tokens.sliderHandleLength
            second.data: root.slider.background.data
        }
        vertical {
            background.width: root.tokens.sliderHandleLength
            background.height: root.tokens.sliderMinimumLength
            handle.width: root.tokens.sliderHandleLength
            handle.height: root.tokens.sliderHandleExtent
            handle.first.width: root.tokens.sliderHandleLength
            handle.first.height: root.tokens.sliderHandleExtent
            handle.second.width: root.tokens.sliderHandleLength
            handle.second.height: root.tokens.sliderHandleExtent
        }
    }

    light: SmallButtonTheme { tokens: root.lightTokens; sourceStyle: root }
    dark: SmallButtonTheme { tokens: root.darkTokens; sourceStyle: root }
}
