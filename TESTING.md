# Material3 test contract

The user approved three public seams on 2026-10-27. Tests describe observable
behavior at these seams; they do not navigate the kit's private delegate tree.

| Seam | Kept coverage | Outside the routine gate |
|---|---|---|
| Native SK.Button / SK.Menu / SK.TextField / SK.ComboBox / SK.TabBar / SK.Switch / SK.RadioButton / SK.Slider / SK.RangeSlider consumption | Pointer/keyboard activation, disabled/cancel behavior, selection, FAB display, menu activation/dismissal, floating caption/native editing, accessory space/rendering, message wrapping/accessible description and live caller bindings; ComboBox floating caption, first/last rows, native selection/acceptance and caller factories | Internal object names, loaders, ripple phase, shadow geometry, per-size/appearance permutations |
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
