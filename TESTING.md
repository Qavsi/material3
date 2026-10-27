# Material3 test contract

The user approved three public seams on 2026-10-27. Tests describe observable
behavior at these seams; they do not navigate the kit's private delegate tree.

| Seam | Kept coverage | Outside the routine gate |
|---|---|---|
| Native SK.Button / SK.Menu / SK.TextField / SK.ComboBox / SK.TabBar consumption | Pointer/keyboard activation, disabled/cancel behavior, selection, FAB display, menu activation/dismissal, floating caption/native editing, accessory space/rendering, message wrapping/accessible description and live caller bindings; ComboBox floating caption, first/last rows, native selection/acceptance and caller factories | Internal object names, loaders, ripple phase, shadow geometry, per-size/appearance permutations |
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

Navigation coverage checks native TabBar keyboard selection.
Public control selectors are used; private family delegates are not inspected.

The comparison's --check path enables QAccessible before creating the QML engine.
This exercises Qt's implicit placeholder descriptions on software as well as native
Metal, so supporting/error description regressions cannot hide behind inactive
accessibility. The same consumer pass preserves explicit caller descriptions.
