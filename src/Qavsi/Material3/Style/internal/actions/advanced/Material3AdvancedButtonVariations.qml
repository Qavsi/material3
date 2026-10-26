// Copyright (c) 2026 Enes Alp
// SPDX-License-Identifier: MIT

pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import "Material3ConnectedButtonRecipe.js" as ConnectedRecipe
import "Material3SegmentedButtonRecipe.js" as SegmentedRecipe
import "Material3SplitButtonRecipe.js" as SplitRecipe
import "Material3FabRecipe.js" as FabRecipe
import "Material3JoinedRecipe.js" as JoinedRecipe

QtObject {
    id: registrations
    required property var sourceStyle
    default property list<QtObject> variations: [
        SK.StyleVariation { name: "buttonGroup"; toolBar.spacing: JoinedRecipe.spacing },
        SK.StyleVariation { name: "segmentedGroup"; toolBar.spacing: -registrations.sourceStyle.tokens.outlineWidth },
        Material3SegmentedButtonVariation { name: "segmentedExtraSmallLeading"; sourceStyle: registrations.sourceStyle; metrics: SegmentedRecipe.extraSmall; horizontalPadding: sourceStyle.tokens.segmentedExtraSmallPadding; leading: true },
        Material3ConnectedButtonVariation { name: "connectedExtraSmallLeading"; sourceStyle: registrations.sourceStyle; metrics: ConnectedRecipe.extraSmall; horizontalPadding: sourceStyle.tokens.buttonExtraSmallPadding; leading: true },
        Material3ConnectedButtonVariation { name: "connectedIconExtraSmallLeading"; sourceStyle: registrations.sourceStyle; metrics: ConnectedRecipe.extraSmall; iconGeometry: true; horizontalPadding: 0; leading: true },
        Material3SegmentedButtonVariation { name: "segmentedExtraSmallMiddle"; sourceStyle: registrations.sourceStyle; metrics: SegmentedRecipe.extraSmall; horizontalPadding: sourceStyle.tokens.segmentedExtraSmallPadding },
        Material3ConnectedButtonVariation { name: "connectedExtraSmallMiddle"; sourceStyle: registrations.sourceStyle; metrics: ConnectedRecipe.extraSmall; horizontalPadding: sourceStyle.tokens.buttonExtraSmallPadding },
        Material3ConnectedButtonVariation { name: "connectedIconExtraSmallMiddle"; sourceStyle: registrations.sourceStyle; metrics: ConnectedRecipe.extraSmall; iconGeometry: true; horizontalPadding: 0 },
        Material3SegmentedButtonVariation { name: "segmentedExtraSmallTrailing"; sourceStyle: registrations.sourceStyle; metrics: SegmentedRecipe.extraSmall; horizontalPadding: sourceStyle.tokens.segmentedExtraSmallPadding; trailing: true },
        Material3ConnectedButtonVariation { name: "connectedExtraSmallTrailing"; sourceStyle: registrations.sourceStyle; metrics: ConnectedRecipe.extraSmall; horizontalPadding: sourceStyle.tokens.buttonExtraSmallPadding; trailing: true },
        Material3ConnectedButtonVariation { name: "connectedIconExtraSmallTrailing"; sourceStyle: registrations.sourceStyle; metrics: ConnectedRecipe.extraSmall; iconGeometry: true; horizontalPadding: 0; trailing: true },
        Material3SplitButtonVariation { name: "splitExtraSmallLeading"; sourceStyle: registrations.sourceStyle; metrics: SplitRecipe.extraSmall; leading: true },
        Material3SplitButtonVariation { name: "splitExtraSmallTrailing"; sourceStyle: registrations.sourceStyle; metrics: SplitRecipe.extraSmall; trailing: true },
        Material3SegmentedButtonVariation { name: "segmentedSmallLeading"; sourceStyle: registrations.sourceStyle; metrics: SegmentedRecipe.small; horizontalPadding: sourceStyle.tokens.segmentedSmallPadding; leading: true },
        Material3ConnectedButtonVariation { name: "connectedSmallLeading"; sourceStyle: registrations.sourceStyle; metrics: ConnectedRecipe.small; horizontalPadding: sourceStyle.tokens.buttonSmallPadding; leading: true },
        Material3ConnectedButtonVariation { name: "connectedIconSmallLeading"; sourceStyle: registrations.sourceStyle; metrics: ConnectedRecipe.small; iconGeometry: true; horizontalPadding: 0; leading: true },
        Material3SegmentedButtonVariation { name: "segmentedSmallMiddle"; sourceStyle: registrations.sourceStyle; metrics: SegmentedRecipe.small; horizontalPadding: sourceStyle.tokens.segmentedSmallPadding },
        Material3ConnectedButtonVariation { name: "connectedSmallMiddle"; sourceStyle: registrations.sourceStyle; metrics: ConnectedRecipe.small; horizontalPadding: sourceStyle.tokens.buttonSmallPadding },
        Material3ConnectedButtonVariation { name: "connectedIconSmallMiddle"; sourceStyle: registrations.sourceStyle; metrics: ConnectedRecipe.small; iconGeometry: true; horizontalPadding: 0 },
        Material3SegmentedButtonVariation { name: "segmentedSmallTrailing"; sourceStyle: registrations.sourceStyle; metrics: SegmentedRecipe.small; horizontalPadding: sourceStyle.tokens.segmentedSmallPadding; trailing: true },
        Material3ConnectedButtonVariation { name: "connectedSmallTrailing"; sourceStyle: registrations.sourceStyle; metrics: ConnectedRecipe.small; horizontalPadding: sourceStyle.tokens.buttonSmallPadding; trailing: true },
        Material3ConnectedButtonVariation { name: "connectedIconSmallTrailing"; sourceStyle: registrations.sourceStyle; metrics: ConnectedRecipe.small; iconGeometry: true; horizontalPadding: 0; trailing: true },
        Material3SplitButtonVariation { name: "splitSmallLeading"; sourceStyle: registrations.sourceStyle; metrics: SplitRecipe.small; leading: true },
        Material3SplitButtonVariation { name: "splitSmallTrailing"; sourceStyle: registrations.sourceStyle; metrics: SplitRecipe.small; trailing: true },
        Material3SegmentedButtonVariation { name: "segmentedMediumLeading"; sourceStyle: registrations.sourceStyle; metrics: SegmentedRecipe.medium; horizontalPadding: sourceStyle.tokens.segmentedMediumPadding; leading: true },
        Material3ConnectedButtonVariation { name: "connectedMediumLeading"; sourceStyle: registrations.sourceStyle; metrics: ConnectedRecipe.medium; horizontalPadding: sourceStyle.tokens.buttonMediumPadding; leading: true },
        Material3ConnectedButtonVariation { name: "connectedIconMediumLeading"; sourceStyle: registrations.sourceStyle; metrics: ConnectedRecipe.medium; iconGeometry: true; horizontalPadding: 0; leading: true },
        Material3SegmentedButtonVariation { name: "segmentedMediumMiddle"; sourceStyle: registrations.sourceStyle; metrics: SegmentedRecipe.medium; horizontalPadding: sourceStyle.tokens.segmentedMediumPadding },
        Material3ConnectedButtonVariation { name: "connectedMediumMiddle"; sourceStyle: registrations.sourceStyle; metrics: ConnectedRecipe.medium; horizontalPadding: sourceStyle.tokens.buttonMediumPadding },
        Material3ConnectedButtonVariation { name: "connectedIconMediumMiddle"; sourceStyle: registrations.sourceStyle; metrics: ConnectedRecipe.medium; iconGeometry: true; horizontalPadding: 0 },
        Material3SegmentedButtonVariation { name: "segmentedMediumTrailing"; sourceStyle: registrations.sourceStyle; metrics: SegmentedRecipe.medium; horizontalPadding: sourceStyle.tokens.segmentedMediumPadding; trailing: true },
        Material3ConnectedButtonVariation { name: "connectedMediumTrailing"; sourceStyle: registrations.sourceStyle; metrics: ConnectedRecipe.medium; horizontalPadding: sourceStyle.tokens.buttonMediumPadding; trailing: true },
        Material3ConnectedButtonVariation { name: "connectedIconMediumTrailing"; sourceStyle: registrations.sourceStyle; metrics: ConnectedRecipe.medium; iconGeometry: true; horizontalPadding: 0; trailing: true },
        Material3SplitButtonVariation { name: "splitMediumLeading"; sourceStyle: registrations.sourceStyle; metrics: SplitRecipe.medium; leading: true },
        Material3SplitButtonVariation { name: "splitMediumTrailing"; sourceStyle: registrations.sourceStyle; metrics: SplitRecipe.medium; trailing: true },
        Material3SegmentedButtonVariation { name: "segmentedLargeLeading"; sourceStyle: registrations.sourceStyle; metrics: SegmentedRecipe.large; horizontalPadding: sourceStyle.tokens.segmentedLargePadding; leading: true },
        Material3ConnectedButtonVariation { name: "connectedLargeLeading"; sourceStyle: registrations.sourceStyle; metrics: ConnectedRecipe.large; horizontalPadding: sourceStyle.tokens.buttonLargePadding; leading: true },
        Material3ConnectedButtonVariation { name: "connectedIconLargeLeading"; sourceStyle: registrations.sourceStyle; metrics: ConnectedRecipe.large; iconGeometry: true; horizontalPadding: 0; leading: true },
        Material3SegmentedButtonVariation { name: "segmentedLargeMiddle"; sourceStyle: registrations.sourceStyle; metrics: SegmentedRecipe.large; horizontalPadding: sourceStyle.tokens.segmentedLargePadding },
        Material3ConnectedButtonVariation { name: "connectedLargeMiddle"; sourceStyle: registrations.sourceStyle; metrics: ConnectedRecipe.large; horizontalPadding: sourceStyle.tokens.buttonLargePadding },
        Material3ConnectedButtonVariation { name: "connectedIconLargeMiddle"; sourceStyle: registrations.sourceStyle; metrics: ConnectedRecipe.large; iconGeometry: true; horizontalPadding: 0 },
        Material3SegmentedButtonVariation { name: "segmentedLargeTrailing"; sourceStyle: registrations.sourceStyle; metrics: SegmentedRecipe.large; horizontalPadding: sourceStyle.tokens.segmentedLargePadding; trailing: true },
        Material3ConnectedButtonVariation { name: "connectedLargeTrailing"; sourceStyle: registrations.sourceStyle; metrics: ConnectedRecipe.large; horizontalPadding: sourceStyle.tokens.buttonLargePadding; trailing: true },
        Material3ConnectedButtonVariation { name: "connectedIconLargeTrailing"; sourceStyle: registrations.sourceStyle; metrics: ConnectedRecipe.large; iconGeometry: true; horizontalPadding: 0; trailing: true },
        Material3SplitButtonVariation { name: "splitLargeLeading"; sourceStyle: registrations.sourceStyle; metrics: SplitRecipe.large; leading: true },
        Material3SplitButtonVariation { name: "splitLargeTrailing"; sourceStyle: registrations.sourceStyle; metrics: SplitRecipe.large; trailing: true },
        Material3SegmentedButtonVariation { name: "segmentedExtraLargeLeading"; sourceStyle: registrations.sourceStyle; metrics: SegmentedRecipe.extraLarge; horizontalPadding: sourceStyle.tokens.segmentedExtraLargePadding; leading: true },
        Material3ConnectedButtonVariation { name: "connectedExtraLargeLeading"; sourceStyle: registrations.sourceStyle; metrics: ConnectedRecipe.extraLarge; horizontalPadding: sourceStyle.tokens.buttonExtraLargePadding; leading: true },
        Material3ConnectedButtonVariation { name: "connectedIconExtraLargeLeading"; sourceStyle: registrations.sourceStyle; metrics: ConnectedRecipe.extraLarge; iconGeometry: true; horizontalPadding: 0; leading: true },
        Material3SegmentedButtonVariation { name: "segmentedExtraLargeMiddle"; sourceStyle: registrations.sourceStyle; metrics: SegmentedRecipe.extraLarge; horizontalPadding: sourceStyle.tokens.segmentedExtraLargePadding },
        Material3ConnectedButtonVariation { name: "connectedExtraLargeMiddle"; sourceStyle: registrations.sourceStyle; metrics: ConnectedRecipe.extraLarge; horizontalPadding: sourceStyle.tokens.buttonExtraLargePadding },
        Material3ConnectedButtonVariation { name: "connectedIconExtraLargeMiddle"; sourceStyle: registrations.sourceStyle; metrics: ConnectedRecipe.extraLarge; iconGeometry: true; horizontalPadding: 0 },
        Material3SegmentedButtonVariation { name: "segmentedExtraLargeTrailing"; sourceStyle: registrations.sourceStyle; metrics: SegmentedRecipe.extraLarge; horizontalPadding: sourceStyle.tokens.segmentedExtraLargePadding; trailing: true },
        Material3ConnectedButtonVariation { name: "connectedExtraLargeTrailing"; sourceStyle: registrations.sourceStyle; metrics: ConnectedRecipe.extraLarge; horizontalPadding: sourceStyle.tokens.buttonExtraLargePadding; trailing: true },
        Material3ConnectedButtonVariation { name: "connectedIconExtraLargeTrailing"; sourceStyle: registrations.sourceStyle; metrics: ConnectedRecipe.extraLarge; iconGeometry: true; horizontalPadding: 0; trailing: true },
        Material3SplitButtonVariation { name: "splitExtraLargeLeading"; sourceStyle: registrations.sourceStyle; metrics: SplitRecipe.extraLarge; leading: true },
        Material3SplitButtonVariation { name: "splitExtraLargeTrailing"; sourceStyle: registrations.sourceStyle; metrics: SplitRecipe.extraLarge; trailing: true },
        Material3SegmentedButtonVariation { name: "segmentedLeading"; sourceStyle: registrations.sourceStyle; metrics: SegmentedRecipe.small; horizontalPadding: sourceStyle.tokens.segmentedSmallPadding; leading: true },
        Material3ConnectedButtonVariation { name: "connectedLeading"; sourceStyle: registrations.sourceStyle; metrics: ConnectedRecipe.small; leading: true },
        Material3ConnectedButtonVariation { name: "connectedIconLeading"; sourceStyle: registrations.sourceStyle; metrics: ConnectedRecipe.small; iconGeometry: true; horizontalPadding: 0; leading: true },
        Material3SegmentedButtonVariation { name: "segmentedMiddle"; sourceStyle: registrations.sourceStyle; metrics: SegmentedRecipe.small; horizontalPadding: sourceStyle.tokens.segmentedSmallPadding },
        Material3ConnectedButtonVariation { name: "connectedMiddle"; sourceStyle: registrations.sourceStyle; metrics: ConnectedRecipe.small },
        Material3ConnectedButtonVariation { name: "connectedIconMiddle"; sourceStyle: registrations.sourceStyle; metrics: ConnectedRecipe.small; iconGeometry: true; horizontalPadding: 0 },
        Material3SegmentedButtonVariation { name: "segmentedTrailing"; sourceStyle: registrations.sourceStyle; metrics: SegmentedRecipe.small; horizontalPadding: sourceStyle.tokens.segmentedSmallPadding; trailing: true },
        Material3ConnectedButtonVariation { name: "connectedTrailing"; sourceStyle: registrations.sourceStyle; metrics: ConnectedRecipe.small; trailing: true },
        Material3ConnectedButtonVariation { name: "connectedIconTrailing"; sourceStyle: registrations.sourceStyle; metrics: ConnectedRecipe.small; iconGeometry: true; horizontalPadding: 0; trailing: true },
        Material3SplitButtonVariation { name: "splitLeading"; sourceStyle: registrations.sourceStyle; metrics: SplitRecipe.small; leading: true },
        Material3SplitButtonVariation { name: "splitTrailing"; sourceStyle: registrations.sourceStyle; metrics: SplitRecipe.small; trailing: true },
        Material3FabVariation { name: "fabSmall"; sourceStyle: registrations.sourceStyle; minimumHeight: FabRecipe.smallHeight; cornerRadius: sourceStyle.tokens.radiusExtraSmall },
        Material3FabVariation { name: "fab"; sourceStyle: registrations.sourceStyle },
        Material3FabVariation { name: "fabLarge"; sourceStyle: registrations.sourceStyle; minimumHeight: FabRecipe.largeHeight; minimumIconSize: FabRecipe.largeIconSize; cornerRadius: sourceStyle.tokens.radiusExtraLarge },
        Material3FabVariation { name: "fabExtended"; sourceStyle: registrations.sourceStyle; expanded: true },
        Material3FabVariation {
            name: "fabMenuAction"
            sourceStyle: registrations.sourceStyle
            elevated: false
            cornerRadius: minimumHeight / 2
            parameters.contentRole: "fabMenuAction"
            button {
                leftPadding: registrations.sourceStyle.tokens.spacingLarge
                rightPadding: registrations.sourceStyle.tokens.spacingLarge
                spacing: registrations.sourceStyle.tokens.spacingSmall
            }
        },
        Material3FabVariation {
            name: "fabMenuToggle"
            sourceStyle: registrations.sourceStyle
            elevated: false
            button {
                checked {
                    text.color: registrations.sourceStyle.tokens.primaryForeground
                    background {
                        radius: FabRecipe.height / 2
                        color: registrations.sourceStyle.tokens.primary
                    }
                    hovered.background.color: registrations.sourceStyle.tokens.primary
                    focused.background.color: registrations.sourceStyle.tokens.primary
                    pressed {
                        background {
                            color: registrations.sourceStyle.tokens.primary
                            radius: FabRecipe.height / 2
                        }
                    }
                }
            }
        },
        Material3FabVariation { name: "navigationFab"; sourceStyle: registrations.sourceStyle; elevated: false },
        Material3FabVariation { name: "navigationFabExpanded"; sourceStyle: registrations.sourceStyle; elevated: false; expanded: true }
    ]
}
