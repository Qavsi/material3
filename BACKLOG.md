# Material3 backlog

Outstanding QCM parity work and focused investigations. Existing native control
families remain usable while these follow-ups are deferred.

| ID | Area | Remaining work |
|---|---|---|
| BTN-001 | Busy buttons | Native-button loading content and determinate/indeterminate progress, including icon-only usage |

Current slice: native SK.TextField, default outlined, textFieldFilled variation,
placeholderText as floating caption, TextFieldSupport affixes/icons/messages,
Theme, accessibility motion and software. Native outlined ComboBox now includes
floating label, popup/selection, role models, editable acceptance and caller factory
preservation. QCM XS–XL field and ComboBox recipes are implemented; the comparison shows their reference cards.
The separate Badge family now covers dot, count/cap and text overlays; see [Badge](docs/families/badge.md).

Input-family investigations (not confirmed defects):

| ID | Area | Follow-up |
|---|---|---|
| INPUT-001 | Large option models | Profile popup width measurement for large short-label models before adding a cache; the current short-list path scans on open and stops at the maximum width |
| SDK-001 | Qt 6.12 StyleKit startup | Qt 6.12 can crash in QQStyleKitReader::resetReadersForStyle if its raw reader list changes during startup or a live Theme reset. The comparison defers caller-popup API examples and reference menus, but creates appearance/variation controls with the window and retains them. Source and installed consumer checks pass with these guards; the unsafe SDK reader iteration remains upstream work. |
| SDK-002 | Qt 6.12.0 ProgressBar mode changes | Default deferred content's Connections access properties on the wrong object. Dynamic modes explicitly use public Material3ProgressContent; static native controls remain supported. Remove the workaround only after an upstream fix and consumer mode-switch verification. |

| ID | Area | Follow-up |
|---|---|---|
| RANGE-001 | Minimum span | Native Qt RangeSlider has no pre-accept minimum-span validator. The discrete example is20/80 initially, not an enforced20 gap; do not correct caller values after acceptance. |
| NAV-001 | Rail motion | Exact QCM spring/drag reveal parity and the SearchView overlay remain. Responsive rail/drawer, toolbar/search, selection and side sheet are implemented; current motion uses Theme-based Qt easing. Navigation creation retains its SDK-001 startup guard. |

| ID | Area | Follow-up |
|---|---|---|
| TIME-001 | Time picker | Port the QCM analog dial and dial/input mode switching. The existing Dialog/ComboBox already supports 12/24-hour selection and canonical accepted values. |
| DEMO-001 | Reference pages | Add the QCM Color, Typography and Shape comparison pages. |

## Completed color/drawer slice — 2026-10-30

- Nine MCU schemes and 34 semantic roles, with existing enum values, static
  defaults and caller bindings preserved.
- QCM palette/seed and brightness choices owned by Main.qml. Header exposes only
  Appearance; the debug motion button is removed while OS/test APIs stay intact.
- Shared native Material3Drawer skin and colorChoice SK.RadioButton variation.
- Independent QCM evidence: 54 scenarios; source/software, relocated installed
  consumer and left-screen Metal appearance checked.
- See [the color contract](DESIGN.md#material-color-utilities) and
  [application navigation](docs/families/app-navigation.md).

## Completed button motion/chips slice — 2026-10-30

- QCM spring corners, opt-in native group width redistribution and quarter-step FILL.
- Elevated, custom-leading/avatar, editDelegate and native drag chip feedback.
- Native minimum targets and caller width/text/selection ownership retained.
- Busy/loading remains BTN-001; model reorder/removal stays application-owned.
- See [the public contract](docs/families/button-motion-chips.md).
