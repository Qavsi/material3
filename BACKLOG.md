# Material3 backlog

Deferred after the QCM 0.6.1 button-family slice (2026-10-27).
These items do not block the TextField family.

| ID | Area | Remaining work |
|---|---|---|
| BTN-001 | Busy buttons | Native-button loading content and determinate/indeterminate progress, including icon-only usage |
| BTN-002 | Connected groups | Redistribute neighbour widths during press while retaining native selection/input |
| BTN-003 | Icon motion | Animate intermediate Material FILL axis values; checked-to-filled selection already exists |
| BTN-004 | Shape motion | Adapt QCM spring-based corner motion; current duration/easing behavior remains |
| BDG-001 | Badge family | Dot, count, maximum/capped count and text overlays as a separate style/delegate family |

Current slice: native SK.TextField, default outlined, textFieldFilled variation,
placeholderText as floating caption, TextFieldSupport affixes/icons/messages,
Theme, accessibility motion and software. Native outlined ComboBox now includes
floating label, popup/selection, role models, editable acceptance and caller factory
preservation. QCM XS–XL field and ComboBox recipes are implemented; the comparison shows their reference cards.

Input-family investigations (not confirmed defects):

| ID | Area | Follow-up |
|---|---|---|
| INPUT-001 | Large option models | Profile popup width measurement for large short-label models before adding a cache; the current short-list path scans on open and stops at the maximum width |
| SDK-001 | Qt 6.12 StyleKit startup | Cold launches can crash in QQStyleKitReader::resetReadersForStyle when caller popup/delegate readers are created during initial style completion. The comparison defers its caller-popup API examples and reference menus, keeping variation recipe galleries eager. Source repeated starts pass; the SDK root cause remains upstream work. |

| ID | Area | Follow-up |
|---|---|---|
| RANGE-001 | Minimum span | Native Qt RangeSlider has no pre-accept minimum-span validator. The discrete example is20/80 initially, not an enforced20 gap; do not correct caller values after acceptance. |
| NAV-001 | Rail motion | Exact QCM spring parity and a complete responsive rail/drawer are outside the isolated item slice; current rail selection uses Theme-based Qt easing. The comparison defers Navigation reader creation until Style completion to avoid SDK-001 in the isolated family build. |
