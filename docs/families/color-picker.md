# Color picker

`Material3ColorPicker` is an embeddable native `SK.Control`. Its controlled
`color` input stays caller-owned: connect `onColorChangeRequested: value => color = value`
(or update the application property bound to `color`). Setters request a change;
they never assign the input. `showAlpha` hides the alpha row without removing alpha.
`mode` selects `Material3ColorPicker.Hsv` (default) or `Material3ColorPicker.Rgb`.

HSV/RGB channel geometry follows QmlMaterial 0.6.1, commit `1912605` (MIT).
Native `SK.Slider` and editable `SK.SpinBox` retain keyboard, focus, validation
and accessibility. Track paint uses software-compatible Rectangle gradients;
alpha uses the QCM checkerboard colors from Theme. All non-color-data paint and
channel dimensions come from Material3Theme. The default `showHeader: true` includes the QCM 240px hue ring and rotating SV triangle.
The inline gallery sets `showHeader: false`, as in QCM. No screen-color sampler is included.

`setHue`, `setSaturation`, `setValue`, `setSV`, `setAlpha`, `setR`, `setG`, `setB`
accept normalized values, clamp finite values to [0,1], and reject non-finite
input. RGB/HSV edits preserve alpha. Hue is remembered while the supplied color
is achromatic. `setColor(color)` emits a request using a QML color.
`setHex(string)` returns false without emitting for invalid input; accepted
forms are `#RRGGBB` and `#RRGGBBAA`. Six digits preserve current alpha. Eight
digits use trailing alpha, **not Qt's #AARRGGBB string syntax**.

`Material3ColorPickerDialog` wraps the same editor in native `SK.Dialog`.
`selectedColor` supplies the committed value; `currentColor` owns the draft.
`selectColor(color)` changes that draft. Opening resets it from `selectedColor`;
Cancel/Escape discards the draft and OK emits `acceptedColor(color)` once.
The previous dialog name `Material3ColorPicker` now denotes the inline control;
dialog callers must migrate to `Material3ColorPickerDialog`.

The comparison consumer shows the inline editor and split swatch dialog launcher.
`checkInlineColorPicker` checks a public controlled-input slice, HSV/RGB alpha
preservation, caller binding survival and invalid hex rejection. Whole-gallery
native rendering and installed consumers remain the shared verification gates.

`Material3ColorPickerButton` ports QCM's split swatch and colorize glyph: the whole
native button opens its color dialog; the glyph is not a screen eyedropper.
The trailing plate/ink use the same MCU HCT TonalPalette calculation as QCM.
`color` stays caller-owned and `accepted(color)` requests a committed update.
`dialog` exposes the native host, and hiding/disabling/reparenting dismisses it.
The gallery uses this swatch above the inline editor, with no extra Choose color button.

The native color dialog matches QCM's full picker: centered Pick color title,
240px hue ring, inscribed SV triangle, RGBA8 input chip, XS mode selector,
220px gradient tracks and 60×24 native spin boxes. It uses the regular dialog
surface, existing reduced-motion-aware transitions and modal scrim. Only dialog
accept commits `currentColor` to the caller; pointer and keyboard edits remain drafts.
