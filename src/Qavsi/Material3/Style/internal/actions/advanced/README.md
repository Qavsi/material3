# Advanced button port

MIT Copyright (c) 2026 Enes Alp. Ported from Merce's Material3 joined, connected,
segmented, split and FAB variations/delegates at commit
`69fed5720b47e4f6150bd42607d1333540bb785e`. Canonical geometry is generated from
`tokens/material3.json`; QmlMaterial comparison provenance is in `tools/README.md`.

These are native `SK.Button` geometry/appearance variations. Application behavior,
button groups, menu ownership, checkability and selection remain with Qt and the
consumer. They do not import Merce, Foundation, MButton, a font package or Runtime.
SmallButtonBackground supplies the shared Metal shader/software painter and focus
feedback. Its subclass only resolves the joined four-corner mask and shape motion.

The advanced visual content requires an explicit helper:

```qml
SK.Button {
    id: action
    text: qsTr("Selected")
    checkable: true
    SK.StyleVariation.variations: ["segmentedSmallLeading"]
    contentItem: Material3ButtonContent { control: action }
}
```

Qt 6.12 StyleKit has no button content-delegate hook. The style cannot install
this content automatically; without this opt-in the native SDK content remains.
The helper exposes its resolved text foreground as readonly color, matching the
native SDK IconLabel contract. Background interaction ink can read it independently
of caller icon tint. The helper reads StyleReader.background.data, native icon/name/source, font,
display, text, spacing and RTL state. It never assigns control state, enabled,
font, padding or geometry. Helper `iconWidth`/`iconHeight` default to the selected
recipe's optical size. To consume an explicit native icon-size binding, assign
`iconWidth: action.icon.width; iconHeight: action.icon.height` on the helper. No
heuristic attempts to distinguish Qt's default 24 from an explicit caller value.
The original control bindings are never replaced. Intentional additions are the segmented checkmark,
connected optical offset, split arrow rotation and FAB collapsed/expanded content.
Packaged icons use AppIcon/Qavsi.Icons; unpackaged names/sources keep Qt's QIcon path.

The helper uses `QtQuick.Controls.impl/IconLabel`, matching Qt 6.12's own
`SK.Button.qml` icon renderer. This is a private QML API dependency, confined to
one helper; upgrade and installed-consumer tests must verify it for each new Qt
baseline. No private C++ Qt link target is required. Native QIcon resolution is
preserved rather than implementing another icon provider.

`Material3AdvancedButtonVariations` registers XS/S/M/L/XL connected text/icon,
segmented and split geometry names, the existing unsized Small aliases and FAB
roles. These groups use separate native buttons. Do not combine a competing
common/icon size variation with one of these family sizes. Qt 6.12's known dynamic
variation cache issue still applies; initialize role names before control creation.
`buttonGroup` provides the canonical joined gap, `segmentedGroup` overlaps outlines.

Reduced motion completes shape/content movement immediately. Software shares the
same native geometry and falls back to the existing painter. Elevation is the
base renderer's optional backend behavior, not a second control runtime.

Text layout reserves the ceiling of the natural label advance. GridLayout rounds
allocated pixels; rounding down a fractional advance can otherwise elide even a
short label with sufficient native button space. Explicitly constrained buttons
still elide normally, and FAB label width remains tied to expansion progress.

`Material3ButtonGroup` is an opt-in layout for native buttons. Bind `tokens` to
its Material3Theme and explicitly bind `reduceMotion` to the style policy; it
defaults to true. For a standalone group under Material3Style, use the native StyleReader's
buttonGroup spacing as groupStyle (see the public motion/chips contract), and:

```qml
Material3ButtonGroup {
    tokens: materialStyle.tokens
    reduceMotion: materialStyle.effectiveReducedMotion || !SK.StyleKit.transitionsEnabled
    spacing: groupStyle.spacing
    SK.Button {
        text: qsTr("One")
        Material3ButtonGroup.managed: true
        width: Material3ButtonGroup.layoutWidth
    }
    SK.Button {
        text: qsTr("Two")
        Material3ButtonGroup.managed: true
        width: Material3ButtonGroup.layoutWidth
    }
}
```

The OS ReducedMotion preference always wins, including live preference changes.
Software and reduced motion snap width feedback to its endpoint; hidden or
minimized groups stop it. Unmanaged widths keep their caller bindings. Invalid
native dimensions count as zero only for allocation; caller fields are unchanged.
