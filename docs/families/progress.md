# Progress / BusyIndicator

The family keeps native `SK.ProgressBar` range/value/accessibility and native
`SK.BusyIndicator.running`. `Material3Style` supplies the indicator delegates;
`progressCircular` selects circular determinate or indeterminate ProgressBar.
Colors follow the current light/dark Theme. The circular track is transparent,
matching QCM.

```qml
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Style

SK.ProgressBar { value: 0.35; Accessible.name: qsTr("Download") }
SK.ProgressBar {
    SK.StyleVariation.variations: ["progressCircular"]
    value: 0.6
    Accessible.name: qsTr("Installation")
}
SK.BusyIndicator { running: application.loading; Accessible.name: qsTr("Loading") }
```

## Dynamic mode on Qt 6.12.0

The SDK's `StyleKit/ProgressBar.qml` indeterminate-change Connections access
`contentItem.firstProgress` and `contentItem.indeterminateAnim`, although those
properties belong to the content's child IndicatorDelegate. Changing the native
`indeterminate` property therefore emits an assignment error/TypeError.

For a control that changes modes, assign the opt-in content before completion.
Qt 6.12.0 eagerly instantiates the default content through its layout, and
retains the old Connections even with explicit content. The helper therefore
contains only the three compatibility properties the SDK accesses:
`firstProgress`, `secondProgress` and `indeterminateAnim` with no-op `restart()` /
`stop()` methods. These properties never drive the kit's rendering and create no
extra clock or animation. The kit reads native `position` / `indeterminate`
directly. No SDK code, private Qt object, caller binding or caller-provided
content is modified. `Material3ProgressContent` only paints; native ProgressBar
continues to own the range, clamping, mirrored direction and accessible value.

```qml
SK.ProgressBar {
    id: download
    from: 0
    to: application.total
    value: application.completed
    indeterminate: application.totalUnknown
    Accessible.name: qsTr("Download progress")
    contentItem: Material3ProgressContent {
        control: download
        // circular: true // Same helper for a circular progress control.
    }
}
```

The helper's `circular` property also sets its implicit square size, so it does
not require a variation. It reads tokens and effective reduced motion from the
control's selected `Material3Style`; explicit `tokens` / `reducedMotion` overrides
remain available. Ordinary QML width/height and content bindings remain
application owned. If the application already supplies custom content, this kit
does not replace it. Static native progress controls need no helper.

## Reference and rendering

Pinned source: QmlMaterial 0.6.1,
`191260585a829ee4ae2c99e6232b7145b5c34474`, files
`qml/indicator/{LinearIndicator,CircularIndicator}.qml`,
`src/anim/{linear_indicator_updator,circular_indicator_updator}.cpp`,
`include/qml_material/anim/interpolator.hpp` and
`src/indicator/progress_indicator_geometry.cpp`.

- Linear: 4 px rounded stroke, 4 px active/track gap, 4 px endpoint dot,
  100 px default minimum width; primary on secondary-container track.
- Circular: 40 px implicit square, 32 px path diameter, 4 px stroke, 8° gap,
  top origin; primary on transparent track.
- Indeterminate: QCM two-segment disjoint 1800 ms linear motion and the four
  expand/collapse advance cycles over 5400 ms for circular motion. Position
  changes use the QCM 150 ms standard cubic curve.
- Reduced motion, disabled or hidden controls do not run the kit's frame clock.
  Reduced motion retains QCM's visible fixed sample: linear at 75%, circular
  at 12.5% of the cycle. A stopped BusyIndicator paints nothing.
- A single `QQuickPaintedItem::Image` painter path supports software and hardware
  renderers. It has CPU drawing/texture-upload cost; no Skia, Canvas, runtime
  shader compilation or new external dependency is required.

This is QCM's standard straight/arc family. Wavy, contiguous, retreat,
multi-color, morphing Expressive loading shapes and show/min-hide delays are
outside this family. Native BusyIndicator uses the circular advance treatment;
it does not reproduce QCM's separate morphing BusyIndicator. At value==to,
ProgressBar keeps a full indicator, following native progress semantics;
QCM's optional drain-to-hidden completion animation is not applied.

## Verification

`ProgressGallery.qml` is a real source/installed consumer. Its normal check
verifies QCM implicit geometry, live range/value/mode bindings, rendered fill,
visible static reduced-motion feedback, native BusyIndicator running and
accessible progress value/name/role. Global consumer warnings catch the SDK
mode-switch error if the helper or its compatibility properties are removed. Tests do not
inspect private delegates or sample animation phases.

Run `cmake --build <build> --parallel 2`,
`ctest --test-dir <build> -L 'controls|theme' --output-on-failure`, recipe generator
checks and the relevant QML lint targets. Registration/export changes also need
the relocated installed-package comparison consumer described in `TESTING.md`.
