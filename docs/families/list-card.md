# ListItem and Card

QmlMaterial 0.6.1 (`191260585a829ee4ae2c99e6232b7145b5c34474`, MIT)
ListItem / SelectionListItem / ToggleListItem and Card recipes are adapted to
native Qt 6.12 StyleKit controls. No custom input control is added.

## Public consumption

Use native `SK.ItemDelegate` with an immutable `listOneLine`, `listTwoLine` or
`listThreeLine` variation. Their minimum heights are 56, 72 and 96 logical px.
`checkable` / `checked` supply native selection; checked resolves the secondary
container automatically. `enabled: false` keeps native input gating. A plain
ItemDelegate retains its native content and accessibility.

For richer content, opt into `Material3ListItemContent { control: row }` as the
native delegate's contentItem. It reads `text`, `font`, `display`, `mirrored`,
`icon` and state without assigning them. Optional `overline`, `supportingText`,
`supportingMaximumLineCount`, `trailingText` and `trailingIconName` support
compact metadata. `iconWidth` / `iconHeight` are explicit helper slot overrides
(default 24px); native icon properties are never assigned. Icons use the existing Qavsi.Icons package. The helper is
decorative; the native control remains the accessible owner. Set an appropriate
native `Accessible.description` when supporting text contributes meaning.

Use immutable `cardFilled`, `cardElevated` or `cardOutlined` variations on
`SK.Pane` for passive surfaces and `SK.Button` / `SK.ItemDelegate` for native
interactive cards. Card radius is 12, minimum surface is 64 and padding is 16.
Filled uses surfaceContainerHighest, elevated uses surfaceContainerLow and
outlined uses surface plus the outline role. Native caller content, sizing,
focus, actions and event handlers remain application-owned.

## Rendering and scope

Theme owns colors, geometry and motion. Geometry is generated from
`tokens/material3.json`; no Node runtime is required. Interactive surfaces reuse
the existing ripple and keyboard focus ring. Card shadows reuse Material3Elevation
with level 0/1 idle and level 1/2 hover; software keeps readable fill and outline
without shadows. Existing effectiveReducedMotion governs feedback and elevation.

No selection model, list virtualization wrapper, automatic section dividers,
drag elevation or dynamic variation switching is added. Applications compose
those behaviors with native views and models. Rich content uses native Qt font
metrics rather than exact QCM line boxes. Explicit heights can clip enlarged text.

## Verification

The existing comparison consumer checks native list Space selection, disabled
pointer gating, interactive card Space activation and a passive native surface.
It observes public controls only. The same comparison is the source/installed
consumer. `ListCardsGallery` supplies visual review of one/two/three-line rows,
selected/disabled states and all three card appearances.

Disabled list surfaces intentionally use on-surface at 38% opacity, including
selected rows: the pinned QCM `ListItemState` binds `backgroundOpacity` to
`stateTokens().disabled_content` (0.38), rather than `disabled_container` (0.12).
This stronger neutral fill matches the reference source; it is not inherited
StyleKit disabled styling. Disabled labels use the same 38% content opacity.
