// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT

pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme
import "Material3ConnectedButtonRecipe.js" as ConnectedRecipe
import "Material3SegmentedButtonRecipe.js" as SegmentedRecipe
import "Material3SplitButtonRecipe.js" as SplitRecipe
import "Material3FabRecipe.js" as FabRecipe
import "Material3JoinedRecipe.js" as JoinedRecipe

QtObject {
    id: registrations
    required property var sourceStyle
    property Material3Theme tokens: sourceStyle.tokens
    default property list<QtObject> variations: [
        SK.StyleVariation { name: "buttonGroup"; toolBar.spacing: JoinedRecipe.spacing },
        SK.StyleVariation { name: "segmentedGroup"; toolBar.spacing: -registrations.tokens.outlineWidth },
        Material3SegmentedButtonVariation { name: "segmentedExtraSmallLeading"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: SegmentedRecipe.extraSmall; horizontalPadding: tokens.segmentedExtraSmallPadding; leading: true },
        Material3ConnectedButtonVariation { name: "connectedExtraSmallLeading"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: ConnectedRecipe.extraSmall; horizontalPadding: tokens.buttonExtraSmallPadding; leading: true },
        Material3ConnectedButtonVariation { name: "connectedIconExtraSmallLeading"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: ConnectedRecipe.extraSmall; iconGeometry: true; horizontalPadding: 0; leading: true },
        Material3SegmentedButtonVariation { name: "segmentedExtraSmallMiddle"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: SegmentedRecipe.extraSmall; horizontalPadding: tokens.segmentedExtraSmallPadding },
        Material3ConnectedButtonVariation { name: "connectedExtraSmallMiddle"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: ConnectedRecipe.extraSmall; horizontalPadding: tokens.buttonExtraSmallPadding },
        Material3ConnectedButtonVariation { name: "connectedIconExtraSmallMiddle"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: ConnectedRecipe.extraSmall; iconGeometry: true; horizontalPadding: 0 },
        Material3SegmentedButtonVariation { name: "segmentedExtraSmallTrailing"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: SegmentedRecipe.extraSmall; horizontalPadding: tokens.segmentedExtraSmallPadding; trailing: true },
        Material3ConnectedButtonVariation { name: "connectedExtraSmallTrailing"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: ConnectedRecipe.extraSmall; horizontalPadding: tokens.buttonExtraSmallPadding; trailing: true },
        Material3ConnectedButtonVariation { name: "connectedIconExtraSmallTrailing"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: ConnectedRecipe.extraSmall; iconGeometry: true; horizontalPadding: 0; trailing: true },
        Material3SplitButtonVariation { name: "splitExtraSmallLeading"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: SplitRecipe.extraSmall; leading: true },
        Material3SplitButtonVariation { name: "splitExtraSmallTrailing"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: SplitRecipe.extraSmall; trailing: true },
        Material3SegmentedButtonVariation { name: "segmentedSmallLeading"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: SegmentedRecipe.small; horizontalPadding: tokens.segmentedSmallPadding; leading: true },
        Material3ConnectedButtonVariation { name: "connectedSmallLeading"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: ConnectedRecipe.small; horizontalPadding: tokens.buttonSmallPadding; leading: true },
        Material3ConnectedButtonVariation { name: "connectedIconSmallLeading"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: ConnectedRecipe.small; iconGeometry: true; horizontalPadding: 0; leading: true },
        Material3SegmentedButtonVariation { name: "segmentedSmallMiddle"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: SegmentedRecipe.small; horizontalPadding: tokens.segmentedSmallPadding },
        Material3ConnectedButtonVariation { name: "connectedSmallMiddle"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: ConnectedRecipe.small; horizontalPadding: tokens.buttonSmallPadding },
        Material3ConnectedButtonVariation { name: "connectedIconSmallMiddle"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: ConnectedRecipe.small; iconGeometry: true; horizontalPadding: 0 },
        Material3SegmentedButtonVariation { name: "segmentedSmallTrailing"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: SegmentedRecipe.small; horizontalPadding: tokens.segmentedSmallPadding; trailing: true },
        Material3ConnectedButtonVariation { name: "connectedSmallTrailing"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: ConnectedRecipe.small; horizontalPadding: tokens.buttonSmallPadding; trailing: true },
        Material3ConnectedButtonVariation { name: "connectedIconSmallTrailing"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: ConnectedRecipe.small; iconGeometry: true; horizontalPadding: 0; trailing: true },
        Material3SplitButtonVariation { name: "splitSmallLeading"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: SplitRecipe.small; leading: true },
        Material3SplitButtonVariation { name: "splitSmallTrailing"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: SplitRecipe.small; trailing: true },
        Material3SegmentedButtonVariation { name: "segmentedMediumLeading"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: SegmentedRecipe.medium; horizontalPadding: tokens.segmentedMediumPadding; leading: true },
        Material3ConnectedButtonVariation { name: "connectedMediumLeading"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: ConnectedRecipe.medium; horizontalPadding: tokens.buttonMediumPadding; leading: true },
        Material3ConnectedButtonVariation { name: "connectedIconMediumLeading"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: ConnectedRecipe.medium; iconGeometry: true; horizontalPadding: 0; leading: true },
        Material3SegmentedButtonVariation { name: "segmentedMediumMiddle"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: SegmentedRecipe.medium; horizontalPadding: tokens.segmentedMediumPadding },
        Material3ConnectedButtonVariation { name: "connectedMediumMiddle"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: ConnectedRecipe.medium; horizontalPadding: tokens.buttonMediumPadding },
        Material3ConnectedButtonVariation { name: "connectedIconMediumMiddle"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: ConnectedRecipe.medium; iconGeometry: true; horizontalPadding: 0 },
        Material3SegmentedButtonVariation { name: "segmentedMediumTrailing"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: SegmentedRecipe.medium; horizontalPadding: tokens.segmentedMediumPadding; trailing: true },
        Material3ConnectedButtonVariation { name: "connectedMediumTrailing"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: ConnectedRecipe.medium; horizontalPadding: tokens.buttonMediumPadding; trailing: true },
        Material3ConnectedButtonVariation { name: "connectedIconMediumTrailing"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: ConnectedRecipe.medium; iconGeometry: true; horizontalPadding: 0; trailing: true },
        Material3SplitButtonVariation { name: "splitMediumLeading"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: SplitRecipe.medium; leading: true },
        Material3SplitButtonVariation { name: "splitMediumTrailing"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: SplitRecipe.medium; trailing: true },
        Material3SegmentedButtonVariation { name: "segmentedLargeLeading"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: SegmentedRecipe.large; horizontalPadding: tokens.segmentedLargePadding; leading: true },
        Material3ConnectedButtonVariation { name: "connectedLargeLeading"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: ConnectedRecipe.large; horizontalPadding: tokens.buttonLargePadding; leading: true },
        Material3ConnectedButtonVariation { name: "connectedIconLargeLeading"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: ConnectedRecipe.large; iconGeometry: true; horizontalPadding: 0; leading: true },
        Material3SegmentedButtonVariation { name: "segmentedLargeMiddle"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: SegmentedRecipe.large; horizontalPadding: tokens.segmentedLargePadding },
        Material3ConnectedButtonVariation { name: "connectedLargeMiddle"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: ConnectedRecipe.large; horizontalPadding: tokens.buttonLargePadding },
        Material3ConnectedButtonVariation { name: "connectedIconLargeMiddle"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: ConnectedRecipe.large; iconGeometry: true; horizontalPadding: 0 },
        Material3SegmentedButtonVariation { name: "segmentedLargeTrailing"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: SegmentedRecipe.large; horizontalPadding: tokens.segmentedLargePadding; trailing: true },
        Material3ConnectedButtonVariation { name: "connectedLargeTrailing"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: ConnectedRecipe.large; horizontalPadding: tokens.buttonLargePadding; trailing: true },
        Material3ConnectedButtonVariation { name: "connectedIconLargeTrailing"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: ConnectedRecipe.large; iconGeometry: true; horizontalPadding: 0; trailing: true },
        Material3SplitButtonVariation { name: "splitLargeLeading"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: SplitRecipe.large; leading: true },
        Material3SplitButtonVariation { name: "splitLargeTrailing"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: SplitRecipe.large; trailing: true },
        Material3SegmentedButtonVariation { name: "segmentedExtraLargeLeading"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: SegmentedRecipe.extraLarge; horizontalPadding: tokens.segmentedExtraLargePadding; leading: true },
        Material3ConnectedButtonVariation { name: "connectedExtraLargeLeading"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: ConnectedRecipe.extraLarge; horizontalPadding: tokens.buttonExtraLargePadding; leading: true },
        Material3ConnectedButtonVariation { name: "connectedIconExtraLargeLeading"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: ConnectedRecipe.extraLarge; iconGeometry: true; horizontalPadding: 0; leading: true },
        Material3SegmentedButtonVariation { name: "segmentedExtraLargeMiddle"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: SegmentedRecipe.extraLarge; horizontalPadding: tokens.segmentedExtraLargePadding },
        Material3ConnectedButtonVariation { name: "connectedExtraLargeMiddle"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: ConnectedRecipe.extraLarge; horizontalPadding: tokens.buttonExtraLargePadding },
        Material3ConnectedButtonVariation { name: "connectedIconExtraLargeMiddle"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: ConnectedRecipe.extraLarge; iconGeometry: true; horizontalPadding: 0 },
        Material3SegmentedButtonVariation { name: "segmentedExtraLargeTrailing"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: SegmentedRecipe.extraLarge; horizontalPadding: tokens.segmentedExtraLargePadding; trailing: true },
        Material3ConnectedButtonVariation { name: "connectedExtraLargeTrailing"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: ConnectedRecipe.extraLarge; horizontalPadding: tokens.buttonExtraLargePadding; trailing: true },
        Material3ConnectedButtonVariation { name: "connectedIconExtraLargeTrailing"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: ConnectedRecipe.extraLarge; iconGeometry: true; horizontalPadding: 0; trailing: true },
        Material3SplitButtonVariation { name: "splitExtraLargeLeading"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: SplitRecipe.extraLarge; leading: true },
        Material3SplitButtonVariation { name: "splitExtraLargeTrailing"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: SplitRecipe.extraLarge; trailing: true },
        Material3SegmentedButtonVariation { name: "segmentedLeading"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: SegmentedRecipe.small; horizontalPadding: tokens.segmentedSmallPadding; leading: true },
        Material3ConnectedButtonVariation { name: "connectedLeading"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: ConnectedRecipe.small; leading: true },
        Material3ConnectedButtonVariation { name: "connectedIconLeading"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: ConnectedRecipe.small; iconGeometry: true; horizontalPadding: 0; leading: true },
        Material3SegmentedButtonVariation { name: "segmentedMiddle"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: SegmentedRecipe.small; horizontalPadding: tokens.segmentedSmallPadding },
        Material3ConnectedButtonVariation { name: "connectedMiddle"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: ConnectedRecipe.small },
        Material3ConnectedButtonVariation { name: "connectedIconMiddle"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: ConnectedRecipe.small; iconGeometry: true; horizontalPadding: 0 },
        Material3SegmentedButtonVariation { name: "segmentedTrailing"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: SegmentedRecipe.small; horizontalPadding: tokens.segmentedSmallPadding; trailing: true },
        Material3ConnectedButtonVariation { name: "connectedTrailing"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: ConnectedRecipe.small; trailing: true },
        Material3ConnectedButtonVariation { name: "connectedIconTrailing"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: ConnectedRecipe.small; iconGeometry: true; horizontalPadding: 0; trailing: true },
        Material3SplitButtonVariation { name: "splitLeading"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: SplitRecipe.small; leading: true },
        Material3SplitButtonVariation { name: "splitTrailing"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; metrics: SplitRecipe.small; trailing: true },
        Material3FabVariation { name: "fabSmall"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; minimumHeight: FabRecipe.smallHeight; cornerRadius: tokens.radiusExtraSmall },
        Material3FabVariation { name: "fab"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens },
        Material3FabVariation { name: "fabLarge"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; minimumHeight: FabRecipe.largeHeight; minimumIconSize: FabRecipe.largeIconSize; cornerRadius: tokens.radiusExtraLarge },
        Material3FabVariation { name: "fabExtended"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; expanded: true },
        Material3FabVariation {
            name: "fabMenuAction"
            sourceStyle: registrations.sourceStyle
            tokens: registrations.tokens
            elevated: false
            cornerRadius: minimumHeight / 2
            parameters.contentRole: "fabMenuAction"
            button {
                leftPadding: registrations.tokens.spacingLarge
                rightPadding: registrations.tokens.spacingLarge
                spacing: registrations.tokens.spacingSmall
            }
        },
        Material3FabVariation {
            name: "fabMenuToggle"
            sourceStyle: registrations.sourceStyle
            tokens: registrations.tokens
            elevated: true
            button {
                checked {
                    text.color: registrations.tokens.primaryForeground
                    background {
                        radius: FabRecipe.height / 2
                        color: registrations.tokens.primary
                    }
                    hovered.background.color: registrations.tokens.primary
                    focused.background.color: registrations.tokens.primary
                    pressed {
                        background {
                            color: registrations.tokens.primary
                            radius: FabRecipe.height / 2
                        }
                    }
                }
            }
        },
        Material3FabVariation { name: "navigationFab"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; elevated: false },
        Material3FabVariation { name: "navigationFabExpanded"; sourceStyle: registrations.sourceStyle; tokens: registrations.tokens; elevated: false; expanded: true }
    ]
}
