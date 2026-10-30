# Button motion and advanced Chips

Reference: QCM 0.6.1, 191260585a829ee4ae2c99e6232b7145b5c34474.
Controls remain native SK.Button; application state and Actions stay caller-owned.

## Motion

Common/icon and joined corners use QCM damped-spring sampling with velocity
preserved on retarget. Theme owns standard.defaultEffects 1600/1 and
standard.fastSpatial 1400/0.9 stiffness/damping. Public Qt animation APIs are used.
Material FILL uses QCM's 150ms linear, direction-aware quarter steps.
AppIcon remains unchanged; only the Material provider reads optional
appearance.axes.FILL. Missing/nonfinite values fall back to filled.

## Group layout

Material3ButtonGroup is an opt-in layout, separate from native ButtonGroup
selection. Bind tokens to the Material3Theme and reduceMotion to
materialStyle.effectiveReducedMotion || !SK.StyleKit.transitionsEnabled.
Use the existing native StyleReader buttonGroup/standardButtonGroup spacing.

Each managed native button declares:

```qml
Material3ButtonGroup.managed: true
width: Material3ButtonGroup.layoutWidth
```

Optional preferredWidth/minimumWidth/weight/compressionLimit control allocation.
Unmanaged widths retain caller bindings and cannot donate. A press grows within
the available neighbor budget while preserving total width. A 40px icon already
at its minimum cannot shrink further. RTL follows native child mirroring.
Width/corner feedback snaps in software/reduced motion and stops while hidden
or minimized. OS ReducedMotion always wins; standalone reduceMotion defaults true.

## Chips

The immutable chipAssist/chipFilter/chipInput/chipSuggestion/chipEmbed roles stay.
Material3ChipContent adds elevated, leadingItem, edit and editDelegate.

```qml
SK.Button {
    id: chip
    text: contact.displayName
    checkable: true
    SK.StyleVariation.variations: ["chipInput"]
    contentItem: Material3ChipContent {
        control: chip
        elevated: true
        leadingItem: contactAvatar
        edit: contactEditing
        editDelegate: contactEditor
    }
}
```

leadingItem is caller-owned/sized; the application commits or cancels editing.
Assist/Filter/Suggestion paint elevation; Input/Embed retain QCM's Rectangle-based
no-shadow rendering. trailingAction stays independently focusable.
Application DragHandler/Drag.active owns the gesture; the style supplies the
drag state layer/elevation. No model reorder/removal is performed by the kit.

## Verification

One native group scenario covers activation, widths, caller bindings, RTL and
reduced-motion switching; one chip scenario covers editor focus/commit and drag.
Existing selection/Action checks are reused. The Icons public render fixture
checks fractional FILL and fallback; no private/timing matrix is added.
