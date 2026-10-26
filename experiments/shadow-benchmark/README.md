# Shadow renderer benchmark

Standalone experiment only. No Qavsi or Merce production target is changed.
QCM is a benchmark reference dependency, not a new dependency of Material3.

## Reproduce

```sh
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=/Users/techalp/Qt/6.12.0/macos \
  -DQCM_SOURCE=/Volumes/Mac/SCS/dev/Qavsi/references/QmlMaterial \
  -DCMAKE_SKIP_INSTALL_RULES=ON
cmake --build build --parallel 6
python3 run.py
python3 analyze.py
```

The source snapshot uses QmlMaterial commit
`229bc3e64ff71f1ac88cf73e976637ffbcf7e33c`. Eight shadow source hashes are
recorded in `results/reference.json`; those files have no local modifications.
QCM's existing local reference-build portability adjustments are not part of
the shadow algorithm. The Qt SDK is unchanged.

The benchmark requires the left display (negative global x, at least 1800x950
available logical pixels). It refuses to use the right display. Keep this
window exposed while measuring. Previously running QCM/Qavsi demos are closed.
No system power, accessibility, or display preferences are changed.

## Workloads

- 100 and1000 visible 28x28 casters, radius 6. Fixed geometry across both counts;
  the full 40x25 stress grid and shadow extents fit in 1800x950. No scrolling,
  culling, or virtualized model hides the requested work.
- 100 real FAB-sized 56x56 casters, radius 16, as a second representative workload.
- Static elevation 6, with the same tiny 2x2 heartbeat rectangle moving in all
  modes to force scene redraw. This measures redraw cost, not idle power use.
- Animated elevation 6 to 8 and back, 250ms each way, one shared OutCubic driver.
  The benchmark disables QCM's own per-item 250ms Behavior to avoid repeatedly
  retargeting an animation. This isolates rendering and binding propagation;
  it does not measure complete QCM input/hover animation behavior.
- Three repetitions; deterministic shuffled case order, 1500ms warmup,
  4000ms measurement. All timed processes run serially. Builds, profilers,
  screenshots, and UI inspection do not run during measured windows.

## Renderers

- `none`: same casters, no shadow. Scene overhead baseline.
- `rectangular1`: current one-layer fixed numeric profile: blur 3, offsetY 1,
  opacity 0.30; sets all four radii like the production delegate. It does not
  respond to elevation. It is a cost baseline, not a visual/animated peer.
- `rectangular2`: two uncached RectangularShadow items, uniform-radius optimized.
  Uses QCM ambient/spot dimensions and alpha values, mapped to Qt's different
  falloff. This is an approximation, not pixel-identical QCM rendering.
- `qcm`: actual MD.Elevation, uniform-corner analytic path; QCM combines ambient
  and spot into one geometry with a shared per-window falloff texture.

RectangularShadow computes its falloff in a shader; it is not Gaussian blur.
Its default `cached:false` is preserved. Unequal-corner QCM BlurMask behavior,
cached Qt effects, dark-theme readability, software fallbacks and whole-button
StyleKit input/layout overhead are outside this renderer experiment.

## Metrics and validation

- Actual Qt 6.12/Metal backend, requested screen, all caster bounds, shadow
  renderer counts, and visible shadow pixels are checked before warmup.
- For animated QCM/two-layer Qt runs, endpoint screenshots must differ and the
  elevation property must reach 8 before timing starts. No pixel equality is
  asserted between the algorithms.
- Frame intervals use QQuickWindow::frameSwapped.60Hz can cap all methods at
  similar FPS even when their costs differ. A normal Qt event loop runs while
  sampling; QTest polling sleeps are not used during measurement.
- Process CPU time sums all process threads, divided by rendered frames. It can
  exceed one frame's wall time because multiple CPU cores execute in parallel.
- Render-thread synchronization and command-recording stages use direct signal
  connections and QElapsedTimer. These are elapsed wall times including waits
  and scheduling, not actual thread CPU time. The historical raw JSON field
  names `syncCpu` and `renderRecordingCpu` are preserved with the recorded source
  hashes; analysis maps them to stage-elapsed names. Actual CPU claims use only
  process `cpuMsPerFrame` from std::clock, never these stage timers.
- GPU elapsed time is obtained from QRhiCommandBuffer::lastCompletedGpuTime,
  with timestamps explicitly enabled. The API returns asynchronous prior
  completed-frame values; samples are not paired to current-frame CPU timings.
  This diagnostic executable uses Qt6::GuiPrivate for RHI headers and is tied
  to this Qt build. Production code acquires no such dependency.
- RSS is the process resident set, including shared Qt/QCM libraries. It is not
  dedicated GPU memory. Creation time includes module loading and warm caches;
  it is secondary evidence, not cold-start latency.
- Missing frames/exposure, QML warnings, missing shadow pixels, or missing GPU
  samples reject a run. Failed attempts remain in logs and are excluded.
- Raw JSONs/logs and source hashes are retained. Tables show the median of three
  per-run metrics. Min/max run ranges are in `summary.json`; no pooled/median
  confusion and no fabricated GPU percentile from CPU recording intervals.

`shadow-preview` is a development-only QML Preview/profiler executable with
QT_QML_DEBUG. The reported timing matrix uses `shadow-benchmark`, which has no
QML debug connection or profiler instrumentation. Neither executable ships.

## API references

- https://doc.qt.io/qt-6/qml-qtquick-effects-rectangularshadow.html
- https://doc.qt.io/qt-6/qquickwindow.html
- https://doc.qt.io/qt-6/qquickgraphicsconfiguration.html#setTimestamps
- https://doc.qt.io/qt-6/qrhicommandbuffer.html#lastCompletedGpuTime
