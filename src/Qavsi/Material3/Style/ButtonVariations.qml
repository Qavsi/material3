pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import "Material3ButtonRecipe.js" as ButtonRecipe
import "Material3IconButtonRecipe.js" as IconRecipe

// Legacy action names remain stable; app state and native input stay on SK.Button.
QtObject {
    id: root
    required property Material3Style sourceStyle
    default property list<QtObject> registrations: [
        SK.StyleVariation { name: "standardButtonGroup"; toolBar.spacing: root.sourceStyle.tokens.spacingSmall },
        ButtonVariation { name: "filled"; sourceStyle: root.sourceStyle; containerColor: sourceStyle.tokens.primary; contentColor: sourceStyle.tokens.primaryForeground },
        ButtonVariation { name: "elevated"; sourceStyle: root.sourceStyle; containerColor: sourceStyle.tokens.surfaceContainerLow; contentColor: sourceStyle.tokens.primary; elevated: true },
        ButtonVariation { name: "filledTonal"; sourceStyle: root.sourceStyle; containerColor: sourceStyle.tokens.secondaryContainer; contentColor: sourceStyle.tokens.secondaryContainerForeground; checkedContainerColor: sourceStyle.tokens.secondary; checkedContentColor: sourceStyle.tokens.secondaryForeground },
        ButtonVariation { name: "outline"; sourceStyle: root.sourceStyle; containerColor: sourceStyle.tokens.transparent; contentColor: sourceStyle.tokens.primary; outlined: true },
        ButtonVariation { name: "ghost"; sourceStyle: root.sourceStyle; containerColor: sourceStyle.tokens.transparent; contentColor: sourceStyle.tokens.primary },
        ButtonVariation { name: "checkable"; sourceStyle: root.sourceStyle; containerColor: sourceStyle.tokens.secondaryContainer; contentColor: sourceStyle.tokens.secondaryContainerForeground },
        SK.StyleVariation { name: "iconOnly"; control.padding: 0; control.spacing: 0 },
        ButtonSizeVariation { name: "buttonExtraSmall"; sourceStyle: root.sourceStyle; paintHeight: ButtonRecipe.extraSmallHeight; minimumIconSize: ButtonRecipe.extraSmallIconSize; pressedRadius: sourceStyle.tokens.radiusSmall; horizontalPadding: sourceStyle.tokens.buttonExtraSmallPadding },
        ButtonSizeVariation { name: "buttonSmall"; sourceStyle: root.sourceStyle; paintHeight: ButtonRecipe.smallHeight; minimumIconSize: ButtonRecipe.smallIconSize; pressedRadius: sourceStyle.tokens.radiusSmall; horizontalPadding: sourceStyle.tokens.buttonSmallPadding },
        ButtonSizeVariation { name: "buttonMedium"; sourceStyle: root.sourceStyle; paintHeight: ButtonRecipe.mediumHeight; minimumIconSize: ButtonRecipe.mediumIconSize; pressedRadius: sourceStyle.tokens.radiusMedium; horizontalPadding: sourceStyle.tokens.buttonMediumPadding },
        ButtonSizeVariation { name: "buttonLarge"; sourceStyle: root.sourceStyle; paintHeight: ButtonRecipe.largeHeight; minimumIconSize: ButtonRecipe.largeIconSize; pressedRadius: sourceStyle.tokens.radiusLarge; horizontalPadding: sourceStyle.tokens.buttonLargePadding; contentSpacing: sourceStyle.tokens.buttonLargeSpacing },
        ButtonSizeVariation { name: "buttonExtraLarge"; sourceStyle: root.sourceStyle; paintHeight: ButtonRecipe.extraLargeHeight; minimumIconSize: ButtonRecipe.extraLargeIconSize; pressedRadius: sourceStyle.tokens.radiusLarge; horizontalPadding: sourceStyle.tokens.buttonExtraLargePadding; contentSpacing: sourceStyle.tokens.buttonExtraLargeSpacing },
        ButtonSizeVariation { name: "buttonSmallRectangular"; sourceStyle: root.sourceStyle; paintHeight: ButtonRecipe.smallHeight; minimumIconSize: ButtonRecipe.smallIconSize; pressedRadius: sourceStyle.tokens.radiusSmall; cornerRadius: sourceStyle.tokens.radiusMedium; horizontalPadding: sourceStyle.tokens.buttonSmallPadding },
        ButtonSizeVariation { name: "small"; sourceStyle: root.sourceStyle; paintHeight: ButtonRecipe.smallHeight; minimumIconSize: ButtonRecipe.smallIconSize; pressedRadius: sourceStyle.tokens.radiusSmall; horizontalPadding: sourceStyle.tokens.buttonSmallPadding },
        ButtonSizeVariation { name: "large"; sourceStyle: root.sourceStyle; paintHeight: ButtonRecipe.largeHeight; minimumIconSize: ButtonRecipe.largeIconSize; pressedRadius: sourceStyle.tokens.radiusLarge; horizontalPadding: sourceStyle.tokens.buttonLargePadding; contentSpacing: sourceStyle.tokens.buttonLargeSpacing },
        IconButtonVariation { name: "iconStandard"; sourceStyle: root.sourceStyle; containerColor: sourceStyle.tokens.transparent; contentColor: sourceStyle.tokens.surfaceVariantForeground; checkedContainerColor: sourceStyle.tokens.transparent; checkedContentColor: sourceStyle.tokens.primary },
        IconButtonVariation { name: "iconFilled"; sourceStyle: root.sourceStyle; containerColor: sourceStyle.tokens.primary; contentColor: sourceStyle.tokens.primaryForeground },
        IconButtonVariation { name: "iconFilledCheckable"; sourceStyle: root.sourceStyle; containerColor: sourceStyle.tokens.surfaceContainerHighest; contentColor: sourceStyle.tokens.primary },
        IconButtonVariation { name: "iconTonal"; sourceStyle: root.sourceStyle; containerColor: sourceStyle.tokens.secondaryContainer; contentColor: sourceStyle.tokens.secondaryContainerForeground; checkedContainerColor: sourceStyle.tokens.secondaryContainer; checkedContentColor: sourceStyle.tokens.secondaryContainerForeground },
        IconButtonVariation { name: "iconTonalCheckable"; sourceStyle: root.sourceStyle; containerColor: sourceStyle.tokens.surfaceContainerHighest; contentColor: sourceStyle.tokens.surfaceVariantForeground; checkedContainerColor: sourceStyle.tokens.secondaryContainer; checkedContentColor: sourceStyle.tokens.secondaryContainerForeground },
        IconButtonVariation { name: "iconOutlined"; sourceStyle: root.sourceStyle; containerColor: sourceStyle.tokens.transparent; contentColor: sourceStyle.tokens.surfaceVariantForeground; outlined: true; checkedContainerColor: sourceStyle.tokens.inverseSurface; checkedContentColor: sourceStyle.tokens.inverseSurfaceForeground },
        IconButtonSizeVariation { name: "iconExtraSmall"; sourceStyle: root.sourceStyle; metrics: IconRecipe.extraSmall; containerWidth: IconRecipe.extraSmall.defaultWidth },
        IconButtonSizeVariation { name: "iconExtraSmallNarrow"; sourceStyle: root.sourceStyle; metrics: IconRecipe.extraSmall; containerWidth: IconRecipe.extraSmall.narrowWidth },
        IconButtonSizeVariation { name: "iconExtraSmallWide"; sourceStyle: root.sourceStyle; metrics: IconRecipe.extraSmall; containerWidth: IconRecipe.extraSmall.wideWidth },
        IconButtonSizeVariation { name: "iconSmall"; sourceStyle: root.sourceStyle; metrics: IconRecipe.small; containerWidth: IconRecipe.small.defaultWidth },
        IconButtonSizeVariation { name: "iconSmallNarrow"; sourceStyle: root.sourceStyle; metrics: IconRecipe.small; containerWidth: IconRecipe.small.narrowWidth },
        IconButtonSizeVariation { name: "iconSmallWide"; sourceStyle: root.sourceStyle; metrics: IconRecipe.small; containerWidth: IconRecipe.small.wideWidth },
        IconButtonSizeVariation { name: "iconMedium"; sourceStyle: root.sourceStyle; metrics: IconRecipe.medium; containerWidth: IconRecipe.medium.defaultWidth; checkedRadius: sourceStyle.tokens.radiusLarge; pressedRadius: sourceStyle.tokens.radiusMedium },
        IconButtonSizeVariation { name: "iconMediumNarrow"; sourceStyle: root.sourceStyle; metrics: IconRecipe.medium; containerWidth: IconRecipe.medium.narrowWidth; checkedRadius: sourceStyle.tokens.radiusLarge; pressedRadius: sourceStyle.tokens.radiusMedium },
        IconButtonSizeVariation { name: "iconMediumWide"; sourceStyle: root.sourceStyle; metrics: IconRecipe.medium; containerWidth: IconRecipe.medium.wideWidth; checkedRadius: sourceStyle.tokens.radiusLarge; pressedRadius: sourceStyle.tokens.radiusMedium },
        IconButtonSizeVariation { name: "iconLarge"; sourceStyle: root.sourceStyle; metrics: IconRecipe.large; containerWidth: IconRecipe.large.defaultWidth; checkedRadius: sourceStyle.tokens.radiusExtraLarge; pressedRadius: sourceStyle.tokens.radiusLarge },
        IconButtonSizeVariation { name: "iconLargeNarrow"; sourceStyle: root.sourceStyle; metrics: IconRecipe.large; containerWidth: IconRecipe.large.narrowWidth; checkedRadius: sourceStyle.tokens.radiusExtraLarge; pressedRadius: sourceStyle.tokens.radiusLarge },
        IconButtonSizeVariation { name: "iconLargeWide"; sourceStyle: root.sourceStyle; metrics: IconRecipe.large; containerWidth: IconRecipe.large.wideWidth; checkedRadius: sourceStyle.tokens.radiusExtraLarge; pressedRadius: sourceStyle.tokens.radiusLarge },
        IconButtonSizeVariation { name: "iconExtraLarge"; sourceStyle: root.sourceStyle; metrics: IconRecipe.extraLarge; containerWidth: IconRecipe.extraLarge.defaultWidth; checkedRadius: sourceStyle.tokens.radiusExtraLarge; pressedRadius: sourceStyle.tokens.radiusLarge },
        IconButtonSizeVariation { name: "iconExtraLargeNarrow"; sourceStyle: root.sourceStyle; metrics: IconRecipe.extraLarge; containerWidth: IconRecipe.extraLarge.narrowWidth; checkedRadius: sourceStyle.tokens.radiusExtraLarge; pressedRadius: sourceStyle.tokens.radiusLarge },
        IconButtonSizeVariation { name: "iconExtraLargeWide"; sourceStyle: root.sourceStyle; metrics: IconRecipe.extraLarge; containerWidth: IconRecipe.extraLarge.wideWidth; checkedRadius: sourceStyle.tokens.radiusExtraLarge; pressedRadius: sourceStyle.tokens.radiusLarge }
    ]
}
