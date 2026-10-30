# Material3 test contract

The user approved three public seams on 2026-10-27. Tests describe observable
behavior at these seams; they do not navigate the kit's private delegate tree.

Progress coverage stays at those seams: native range/value/mode bindings,
accessible numeric progress, rendered fill and reduced-motion feedback, and
BusyIndicator running. Dynamic modes use the public `Material3ProgressContent`
opt-in around the Qt 6.12.0 default-content defect. Source and relocated installed
consumers exercise the same gallery; private animation phases are not asserted.

| Seam | Kept coverage | Outside the routine gate |
|---|---|---|
| Native SK.Button / SK.Menu / SK.TextField / SK.ComboBox / SK.TabBar / SK.Switch / SK.CheckBox / SK.RadioButton / SK.Slider / SK.RangeSlider consumption | Pointer/keyboard activation, disabled/cancel behavior, selection, FAB display, menu activation/dismissal, floating caption/native editing, accessory space/rendering, message wrapping/accessible description and live caller bindings; ComboBox floating caption, first/last rows, native selection/acceptance and caller factories | Internal object names, loaders, ripple phase, shadow geometry, per-size/appearance permutations |
| Theme and reduced motion | Independent color oracle, role overrides/invalid inputs, light/dark rendered primary, OS preference, static pressed feedback, immediate menu opening | Every renderer/color/timing combination and frame parity with QCM |
| Source / installed consumption | Real example using the exported targets/URIs; relocated find_package consumer | Rebuilding every consumer after a styling-only edit |

The color oracle stays: it checks public Theme roles against independently
captured QCM values and is fast. The duplicate generated-map assertions,
private MCU utility test and hidden style/delegate probes were removed.
Control selectors belong to the example app; they are not kit internals.
Public clicked/triggered/toggled signals are behavior, not collaborator mocks.

## Focused runs

```sh
cmake --build <build> --target qavsi-small-button qavsi-material3-comparison
ctest --test-dir <build> -L controls --output-on-failure

cmake --build <build> --target qavsi-material-colors-check
ctest --test-dir <build> -L theme --output-on-failure
```

Both labels run offscreen/software, including a real rendered-output smoke.
Use the relevant label after a control or Theme change. Run all three CTest
entries when both boundaries change. No unconditional Metal/pixel matrix is
part of the default gate.

After CMake, export, QML registration or dependency changes, also build and run
one example without QAVSI_MATERIAL3_SOURCE, using a relocated installed prefix
through CMAKE_PREFIX_PATH. The example must consume find_package targets only.

## New behavior

One agreed seam, one failing behavior test, the smallest implementation, then
pass. Expected values come from the public contract or an independent reference.
Do not reproduce implementation formulas. Refactoring belongs to review;
removing implementation-coupled tests is not a reason to modify product behavior.
Manual QCM comparison and optional experiments are separate from this gate.
Historical evidence remains a record of its original revision, not current coverage.

Input size coverage remains at the native consumer seam: one QCM table checks
XS–XL TextField/ComboBox height, font size and tracking; explicit caller font
assignment is retained. It does not inspect private delegate trees.

The comparison keeps XS–XL recipe controls in the initial style tree. Its caller-
popup API gallery is loaded on the next event-loop turn to avoid Qt 6.12's
mutable reader-reset iteration during initial style completion. The stock-popup
return fixture is activated only after window exposure; it checks public popup,
parent and model restoration. This bootstrap boundary is a consumer workaround,
not an SDK patch. See SDK-001 in BACKLOG.md.

The new families add one small native-consumer pass: TabBar keyboard selection,
Switch activation/disabled behavior and QCM indicator geometry, Slider native
stepping/read-only pointer+keyboard gating with application updates still valid,
and RangeSlider native handle stepping. A transient native Slider also verifies
that a press-cancellation callback can synchronously destroy its control safely.
Tests use public control selectors and
properties, not private family delegates or animation phases. No full per-stop,
per-orientation or frame-by-frame QCM matrix is part of the routine gate.

RadioButton coverage stays at the same native-consumer seam: one exclusive
selection group, actual selected-dot rendering, read-only pointer/keyboard and
accessibility gating, programmatic updates, and cancellation of a pending key
press on entering read-only. It does not inspect the private delegate tree.

The comparison's --check path enables QAccessible before creating the QML engine.
This exercises Qt's implicit placeholder descriptions on software as well as native
Metal, so supporting/error description regressions cannot hide behind inactive
accessibility. The same consumer pass preserves explicit caller descriptions.

Badge coverage uses a public native `SK.Label` presentation helper: live count
formatting/capping, full-count accessible names, explicit caller text ownership
and safe zero visibility. Rendered right-edge samples verify the capsule covers
both capped counts and long text. The same comparison consumes source and installed
packages; private background/delegate selectors and per-role permutations are
outside the routine gate. The Theme oracle adds on_error from its existing QCM
cases, without a new color matrix.

Chip coverage uses the same native-consumer seam: command activation/32px recipe,
native Filter/Input selection, keyboard access to the separate trailing Action,
no parent activation on removal, disabled gating and constrained-label ownership.
The public Action signal is observed; private chip delegates are not inspected.

The shared Action-menu check stays at the native-consumer seam: three MenuItems
reference native Actions, live metadata/state follows the Action, and one keyboard
activation emits one Action signal and closes the menu. Dark-theme output and
native icon-color ownership are checked at the consumer boundary. It does not
inspect a private menu renderer or assert per-frame hover pixels.

The two native flat menu triggers have one rendered-edge check each: pointer
focus must retain rounded, borderless state feedback. Hardware runs wait for
actual hover; offscreen runs cover pointer focus because they do not deliver
native cursor hover. No private background items are inspected.

Before scrolling a control into view, the consumer check renders pending layout.
Scroll offsets must use settled geometry after a window resize; otherwise the
floating-caption capture can fall above the Flickable clip despite correct focus.

CheckBox has one native-consumer pass: the QCM18px public indicator, binary Space
activation, the native three-state cycle, visibly distinct empty/tick/dash output,
mixed accessibility state and disabled pointer gating. It runs with the existing
reduced-motion/software consumer and is reused for installed consumption; no
private shape/delegate selectors or per-frame comparison are added.

Application navigation adds one public composition scenario: resize through
expanded/collapsed/drawer modes without losing selection, edit native search
with live searchText and dismiss the native drawer with Escape. Native controls
are reached through exported shell aliases; private visual children are not tested.
This scenario runs before other live Theme changes, so an initial variation-reader
failure cannot be hidden by a later Theme reset. A native destination capture
checks transparent initial unselected output and the selected tonal fill.

List/Card coverage uses native ItemDelegate/Button/Pane consumption: one Space
selection, disabled pointer gating, one Card activation and a passive surface.
No private delegates or appearance matrix are inspected.

Dialog/feedback coverage stays at the public native-consumer seam: opaque
light/dark Dialog output, accept/Escape/reject/focus return, native snackbar Action
activation and visible timeout (including zero for persistent messages), plus
rich-tooltip keyboard focus and Escape return to its anchor.

The application-navigation activation scenario explicitly focuses its public
native destination after the separate Theme/enabled ownership checks. A previous
scenario's focus is not a precondition for keyboard activation or rail restoration.

Embedded picker coverage extends the existing public consumer scenario: bounded
single/range requests, live caller-owned bindings, HSV/RGB alpha and RGBA8 input.
Dialog cancel/reopen checks exercise the same editor through its separate host.
Native ScrollBar coverage checks the8px overlay without an opaque idle track and
one actual native scroll request. No private delegate selectors or timing matrix.

Review regressions remain at the existing consumer/render seams: destroying an
item model safely clears a public Carousel, runtime layout change keeps the
selected card under the public activation point without leaking model roles into
native Button state, disabled native ProgressBar
value changes update its rendered fill, date-bound changes retain a keyboard Tab
entry and a read-only date field dismisses/rejects an already-open calendar.
No private engine/attached-property probes or per-layout/frame matrix is added.


Appearance coverage extends the existing native-consumer seam once: open the
native drawer, choose a palette and seed through actual pointer/keyboard input,
toggle brightness, preserve an existing TextField and caller text, then dismiss
and reopen with the same selection. Control names belong to the comparison app.
The existing Theme oracle covers 3 seeds x 9 schemes x light/dark at QCM's
contrast=0, with exact ARGB for 34 roles. Fixed static-role references come from
the pinned MDC XML. No per-control/palette/renderer timing matrix is introduced.

The appearance popup and its variation readers are constructed with the window,
before the first Theme reset. Qt 6.12 iterates its raw reader registry across
Theme notifications; lazy panel construction reproduced a crash in that reset.
The exact list-mutating callback was not isolated. The app keeps the native popup
alive, and Switch requests are deferred to the next event-loop turn. No SDK patch
or generic reader workaround is installed.
