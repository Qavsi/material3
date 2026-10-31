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

## QCM progress port

Source: QmlMaterial 0.6.1, `191260585a829ee4ae2c99e6232b7145b5c34474`:
`example/Components.qml`, `src/control/progress_indicator.cpp`, linear/circular
updators, `src/indicator/progress_indicator_geometry.cpp`, `src/path/measured_path.cpp`
and the Cubic point/split functions from `src/shape/rounded_polygon.cpp`.

The private geometry preserves QCM's measured cubic paths, wavelength rounding,
phase offset, rounded caps, track gaps and endpoint dot. It is compiled into this
kit; no QCM module, runtime, new dependency or private Qt API is linked.

Immutable StyleKit recipes provide:

- Default linear: 4px stroke, 4px gap/stop dot, 100px minimum width.
- `progressWavy`: 240px minimum width, 10px height, 3px amplitude; wavelength
  40px for determinate, 20px for indeterminate; 1000ms wave cycle.
- `progressCircular`: 40px control, 32px content path, 4px stroke, 8-degree gap.
- `progressCircularWavy`: 48px control, 1.6px inward wave and 15px wavelength;
  Retreat is its default indeterminate motion.
- `progressContiguous`: QCM three segments, 333ms motion and half-gap spacing.
- `progressCircularRetreat`: QCM 6000ms grow/shrink/spin motion.

Disjoint remains 1800ms; circular Advance remains 5400ms. Position interpolation
is 150ms; QCM amplitude transitions use 500ms standard/emphasized-accelerate curves.
Wave amplitude flattens below10% and above90%. Native completed progress stays
full, matching the reference gallery's Keep behavior; no drain API is added.

`Material3ProgressContent` keeps the Qt6.12 mode-switch workaround above. Its
`wavy`, `circular` and `motionType` presentation properties select the same renderer;
`running` controls only indeterminate playback. Use `Material3ProgressContent.Disjoint` /
`Contiguous` for linear motion and `Advance` / `Retreat` for circular motion. Stopping completes the current
linear segments/collapses circular arcs, then fades in100ms, as in QCM.
Determinate waves keep moving independently of indeterminate playback.
`trackColor` defaults to the Theme's linear/circular role; the comparison selects
`tokens.progressTrack` for determinate circles, as the QCM example does.

```qml
SK.ProgressBar {
    SK.StyleVariation.variations: ["progressWavy"]
    value: job.progress
}
SK.ProgressBar {
    id: loading
    indeterminate: true
    contentItem: Material3ProgressContent {
        control: loading
        wavy: true
        running: application.loading
    }
}
```

A FrameAnimation passes actual frame time to QCM's adapted transition/segment math;
no NumberAnimation clock or refresh-rate-dependent phase is used. Hidden/disabled
controls and hidden/minimized windows stop the kit clock. Theme reduced motion and
StyleKit transitions disable the clock and retain QCM's fixed visible sample
(linear75%, Advance12.5%, Retreat25%). A paused indicator is hidden immediately
under reduced motion. Native BusyIndicator retains running with its separate morphing content below.

QQuickPaintedItem Image draws the same paths on Metal and software. This retains
the software fallback and avoids private Qt Shape APIs; it has CPU/texture-upload
cost, unlike QCM's CurveRenderer. No claim of equal renderer performance is made.

## Morphing BusyIndicator

The same pinned QCM 0.6.1 supplies `qml/indicator/BusyIndicator.qml`,
`loading_indicator_updator.cpp`, `rounded_polygon.hpp/.cpp`, `morph.cpp` and the
seven factories from `material_shapes.cpp`. Sequence:
SoftBurst → Cookie9Sided → Pentagon → Pill → Sunny → Cookie4Sided → Oval → repeat.
Each phase is 650 ms; spring stiffness 200/damping ratio 0.6, radial normalization,
unclamped geometry overshoot and the rotation cycle are preserved. Phase does not
wrap at seven, because rotation has a longer period. Only these seven shape/morph
pairs are cached once. A transparent 48 px paint target surrounds the 40 px shape,
so the overshoot isn't clipped. No full 35-shape catalog, Skia runtime or private
Qt adapter is imported. The painter uses the primary/disabled Theme ink.

Ordinary `SK.BusyIndicator` receives this delegate without extra properties.
For per-operation timing use the public content helper:

```qml
SK.BusyIndicator {
    id: busy
    running: request.running
    visible: page.showLoading
    contentItem: Material3BusyIndicatorContent {
        control: busy
        showDelay: 150
        minHideDelay: 500
    }
}
```

`showDelay` avoids flashing for short work. `minHideDelay` is the minimum shown
time from the actual reveal, capped at 1000 ms; both default to 0. Stopping cancels
a pending show and freezes the last shape during the remaining minimum budget.
Restarting cancels a pending hide and starts the show policy again. The inner
paint is hidden, not the native control: running/visible bindings remain owned
by the caller. FrameAnimation uses monotonic elapsed time; reduced motion gives
a static first shape while retaining the delays. Hidden/disabled/minimized views
stop the animation clock. ProgressBar and button loading use their existing
progress renderer.

## Verification

The real source/installed gallery follows QCM's shared percentage slider, straight
and wavy determinate rows, paired circles, playback button, three indeterminate
lines and three indeterminate circles. BusyIndicator shows immediate feedback and a delayed short/normal operation sample.
The native-consumer check covers rendered wave extent, QCM10/48px geometry,
play/stop under reduced motion, live range/value/mode bindings and accessible
progress value. One public native BusyIndicator scenario verifies short-work
suppression, minimum visibility and the caller's visible binding; existing
rendered static/animated feedback checks cover reduced motion/software. It does
not inspect private timers, path caches or animation phases.
