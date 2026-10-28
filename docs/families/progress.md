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
under reduced motion. Existing native BusyIndicator running/geometry remain intact.
QCM's separate morphing BusyIndicator and show/min-hide delays are outside this port.

QQuickPaintedItem Image draws the same paths on Metal and software. This retains
the software fallback and avoids private Qt Shape APIs; it has CPU/texture-upload
cost, unlike QCM's CurveRenderer. No claim of equal renderer performance is made.

## Verification

The real source/installed gallery follows QCM's shared percentage slider, straight
and wavy determinate rows, paired circles, playback button, three indeterminate
lines and three indeterminate circles. BusyIndicator remains a separate sample.
The native-consumer check covers rendered wave extent, QCM10/48px geometry,
play/stop under reduced motion, live range/value/mode bindings and accessible
progress value. It does not inspect private path caches or animation phases.
