pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme
import "Material3ButtonRecipe.js" as ButtonRecipe
import "Material3IconButtonRecipe.js" as IconRecipe

// Legacy action names remain stable; app state and native input stay on SK.Button.
QtObject {
    id: root
    required property Material3Style sourceStyle
    required property Material3Theme tokens
    default property list<QtObject> registrations: [
        SK.StyleVariation { name: "standardButtonGroup"; toolBar.spacing: root.tokens.spacingSmall },
        ButtonVariation { name: "filled"; sourceStyle: root.sourceStyle; tokens: root.tokens; containerColor: tokens.primary; contentColor: tokens.primaryForeground },
        ButtonVariation { name: "elevated"; sourceStyle: root.sourceStyle; tokens: root.tokens; containerColor: tokens.surfaceContainerLow; contentColor: tokens.primary; elevated: true },
        ButtonVariation { name: "filledTonal"; sourceStyle: root.sourceStyle; tokens: root.tokens; containerColor: tokens.secondaryContainer; contentColor: tokens.secondaryContainerForeground; checkedContainerColor: tokens.secondary; checkedContentColor: tokens.secondaryForeground },
        ButtonVariation { name: "outline"; sourceStyle: root.sourceStyle; tokens: root.tokens; containerColor: tokens.transparent; contentColor: tokens.primary; outlined: true },
        ButtonVariation { name: "ghost"; sourceStyle: root.sourceStyle; tokens: root.tokens; containerColor: tokens.transparent; contentColor: tokens.primary },
        ButtonVariation { name: "checkable"; sourceStyle: root.sourceStyle; tokens: root.tokens; containerColor: tokens.secondaryContainer; contentColor: tokens.secondaryContainerForeground },
        SK.StyleVariation { name: "iconOnly"; control.padding: 0; control.spacing: 0 },
        ButtonSizeVariation { name: "buttonExtraSmall"; sourceStyle: root.sourceStyle; tokens: root.tokens; paintHeight: ButtonRecipe.extraSmallHeight; minimumIconSize: ButtonRecipe.extraSmallIconSize; pressedRadius: tokens.radiusSmall; horizontalPadding: tokens.buttonExtraSmallPadding },
        ButtonSizeVariation { name: "buttonSmall"; sourceStyle: root.sourceStyle; tokens: root.tokens; paintHeight: ButtonRecipe.smallHeight; minimumIconSize: ButtonRecipe.smallIconSize; pressedRadius: tokens.radiusSmall; horizontalPadding: tokens.buttonSmallPadding },
        ButtonSizeVariation { name: "buttonMedium"; sourceStyle: root.sourceStyle; tokens: root.tokens; paintHeight: ButtonRecipe.mediumHeight; minimumIconSize: ButtonRecipe.mediumIconSize; pressedRadius: tokens.radiusMedium; horizontalPadding: tokens.buttonMediumPadding },
        ButtonSizeVariation { name: "buttonLarge"; sourceStyle: root.sourceStyle; tokens: root.tokens; paintHeight: ButtonRecipe.largeHeight; minimumIconSize: ButtonRecipe.largeIconSize; pressedRadius: tokens.radiusLarge; horizontalPadding: tokens.buttonLargePadding; contentSpacing: tokens.buttonLargeSpacing },
        ButtonSizeVariation { name: "buttonExtraLarge"; sourceStyle: root.sourceStyle; tokens: root.tokens; paintHeight: ButtonRecipe.extraLargeHeight; minimumIconSize: ButtonRecipe.extraLargeIconSize; pressedRadius: tokens.radiusLarge; horizontalPadding: tokens.buttonExtraLargePadding; contentSpacing: tokens.buttonExtraLargeSpacing },
        ButtonSizeVariation { name: "buttonSmallRectangular"; sourceStyle: root.sourceStyle; tokens: root.tokens; paintHeight: ButtonRecipe.smallHeight; minimumIconSize: ButtonRecipe.smallIconSize; pressedRadius: tokens.radiusSmall; cornerRadius: tokens.radiusMedium; horizontalPadding: tokens.buttonSmallPadding },
        ButtonSizeVariation { name: "small"; sourceStyle: root.sourceStyle; tokens: root.tokens; paintHeight: ButtonRecipe.smallHeight; minimumIconSize: ButtonRecipe.smallIconSize; pressedRadius: tokens.radiusSmall; horizontalPadding: tokens.buttonSmallPadding },
        ButtonSizeVariation { name: "large"; sourceStyle: root.sourceStyle; tokens: root.tokens; paintHeight: ButtonRecipe.largeHeight; minimumIconSize: ButtonRecipe.largeIconSize; pressedRadius: tokens.radiusLarge; horizontalPadding: tokens.buttonLargePadding; contentSpacing: tokens.buttonLargeSpacing },
        IconButtonVariation { name: "iconStandard"; sourceStyle: root.sourceStyle; tokens: root.tokens; containerColor: tokens.transparent; contentColor: tokens.surfaceVariantForeground; checkedContainerColor: tokens.transparent; checkedContentColor: tokens.primary },
        IconButtonVariation { name: "iconFilled"; sourceStyle: root.sourceStyle; tokens: root.tokens; containerColor: tokens.primary; contentColor: tokens.primaryForeground },
        IconButtonVariation { name: "iconFilledCheckable"; sourceStyle: root.sourceStyle; tokens: root.tokens; containerColor: tokens.surfaceContainerHighest; contentColor: tokens.primary },
        IconButtonVariation { name: "iconTonal"; sourceStyle: root.sourceStyle; tokens: root.tokens; containerColor: tokens.secondaryContainer; contentColor: tokens.secondaryContainerForeground; checkedContainerColor: tokens.secondaryContainer; checkedContentColor: tokens.secondaryContainerForeground },
        IconButtonVariation { name: "iconTonalCheckable"; sourceStyle: root.sourceStyle; tokens: root.tokens; containerColor: tokens.surfaceContainerHighest; contentColor: tokens.surfaceVariantForeground; checkedContainerColor: tokens.secondaryContainer; checkedContentColor: tokens.secondaryContainerForeground },
        IconButtonVariation { name: "iconOutlined"; sourceStyle: root.sourceStyle; tokens: root.tokens; containerColor: tokens.transparent; contentColor: tokens.surfaceVariantForeground; outlined: true; checkedContainerColor: tokens.inverseSurface; checkedContentColor: tokens.inverseSurfaceForeground },
        IconButtonSizeVariation { name: "iconExtraSmall"; sourceStyle: root.sourceStyle; tokens: root.tokens; metrics: IconRecipe.extraSmall; containerWidth: IconRecipe.extraSmall.defaultWidth },
        IconButtonSizeVariation { name: "iconExtraSmallNarrow"; sourceStyle: root.sourceStyle; tokens: root.tokens; metrics: IconRecipe.extraSmall; containerWidth: IconRecipe.extraSmall.narrowWidth },
        IconButtonSizeVariation { name: "iconExtraSmallWide"; sourceStyle: root.sourceStyle; tokens: root.tokens; metrics: IconRecipe.extraSmall; containerWidth: IconRecipe.extraSmall.wideWidth },
        IconButtonSizeVariation { name: "iconSmall"; sourceStyle: root.sourceStyle; tokens: root.tokens; metrics: IconRecipe.small; containerWidth: IconRecipe.small.defaultWidth },
        IconButtonSizeVariation { name: "iconSmallNarrow"; sourceStyle: root.sourceStyle; tokens: root.tokens; metrics: IconRecipe.small; containerWidth: IconRecipe.small.narrowWidth },
        IconButtonSizeVariation { name: "iconSmallWide"; sourceStyle: root.sourceStyle; tokens: root.tokens; metrics: IconRecipe.small; containerWidth: IconRecipe.small.wideWidth },
        IconButtonSizeVariation { name: "iconMedium"; sourceStyle: root.sourceStyle; tokens: root.tokens; metrics: IconRecipe.medium; containerWidth: IconRecipe.medium.defaultWidth; checkedRadius: tokens.radiusLarge; pressedRadius: tokens.radiusMedium },
        IconButtonSizeVariation { name: "iconMediumNarrow"; sourceStyle: root.sourceStyle; tokens: root.tokens; metrics: IconRecipe.medium; containerWidth: IconRecipe.medium.narrowWidth; checkedRadius: tokens.radiusLarge; pressedRadius: tokens.radiusMedium },
        IconButtonSizeVariation { name: "iconMediumWide"; sourceStyle: root.sourceStyle; tokens: root.tokens; metrics: IconRecipe.medium; containerWidth: IconRecipe.medium.wideWidth; checkedRadius: tokens.radiusLarge; pressedRadius: tokens.radiusMedium },
        IconButtonSizeVariation { name: "iconLarge"; sourceStyle: root.sourceStyle; tokens: root.tokens; metrics: IconRecipe.large; containerWidth: IconRecipe.large.defaultWidth; checkedRadius: tokens.radiusExtraLarge; pressedRadius: tokens.radiusLarge },
        IconButtonSizeVariation { name: "iconLargeNarrow"; sourceStyle: root.sourceStyle; tokens: root.tokens; metrics: IconRecipe.large; containerWidth: IconRecipe.large.narrowWidth; checkedRadius: tokens.radiusExtraLarge; pressedRadius: tokens.radiusLarge },
        IconButtonSizeVariation { name: "iconLargeWide"; sourceStyle: root.sourceStyle; tokens: root.tokens; metrics: IconRecipe.large; containerWidth: IconRecipe.large.wideWidth; checkedRadius: tokens.radiusExtraLarge; pressedRadius: tokens.radiusLarge },
        IconButtonSizeVariation { name: "iconExtraLarge"; sourceStyle: root.sourceStyle; tokens: root.tokens; metrics: IconRecipe.extraLarge; containerWidth: IconRecipe.extraLarge.defaultWidth; checkedRadius: tokens.radiusExtraLarge; pressedRadius: tokens.radiusLarge },
        IconButtonSizeVariation { name: "iconExtraLargeNarrow"; sourceStyle: root.sourceStyle; tokens: root.tokens; metrics: IconRecipe.extraLarge; containerWidth: IconRecipe.extraLarge.narrowWidth; checkedRadius: tokens.radiusExtraLarge; pressedRadius: tokens.radiusLarge },
        IconButtonSizeVariation { name: "iconExtraLargeWide"; sourceStyle: root.sourceStyle; tokens: root.tokens; metrics: IconRecipe.extraLarge; containerWidth: IconRecipe.extraLarge.wideWidth; checkedRadius: tokens.radiusExtraLarge; pressedRadius: tokens.radiusLarge }
    ]
}
