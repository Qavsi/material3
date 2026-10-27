# Standalone shadow-list / cold-cache experiment

See [REPORT.md](REPORT.md) for the original baseline and
[cache lifetime verification](../../evidence/BLUR-CACHE-LIFETIME.md) for the fix.
The harness changes no production source, SDK, control API or software fallback. It freezes committed
Material3 and Icons sources and verifies all 19 shadow-source hashes before
adding a small cache-generation probe to the temporary copy.

macOS only: Qt 6.12, CMake 3.30, C++20, native left display at least1800x950.
The draw-counter library uses the pinned Qt 6.12/macOS C++ ABI and is diagnostic
only. Never load it into another application or into a timing process.

## Reproduce

Choose a NEW snapshot directory; prepare.py deliberately refuses overwrite.
The source commits listed in inputs.json must exist in the local repositories.

```sh
python3 prepare.py /private/tmp/qavsi-shadow-list-replay
cmake -S . -B /private/tmp/qavsi-shadow-list-replay/build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=/Users/techalp/Qt/6.12.0/macos \
  -DSTUDY_SNAPSHOT=/private/tmp/qavsi-shadow-list-replay \
  -DQAVSI_ICONS_SOURCE=/private/tmp/qavsi-shadow-list-replay/icons \
  -DCMAKE_SKIP_INSTALL_RULES=ON
cmake --build /private/tmp/qavsi-shadow-list-replay/build --parallel 5
python3 run.py /private/tmp/qavsi-shadow-list-replay/build
python3 analyze.py
```

Preserve the current results directory under a new name before another series;
run.py refuses to overwrite/mix raw results. Keep all builds, previews and other
GPU diagnostics stopped during timing. The initial measured series temporarily
paused one already-running Material3 preview process and resumed it in finally;
the runner itself does not pause or kill other applications.

The randomized 24-process series has three timing repeats per Metal scene,
one timing repeat per OpenGL scene, and one separate draw-call diagnostic for
each backend/scene. Metal uses threaded rendering. OpenGL uses basic rendering
because this macOS NSOpenGLContext requires main-thread view attachment.

Cold animations start at0. Warm-retained-cache animations preload sigma buckets
outside timing and start at0.012dp to retain cache ownership; zero cache misses
are mandatory. In the original baseline, returning all elevations to exactly0 releases the
renderer-owned cache. repeat-after-zero captures this separately. The candidate
retains the bounded cache until scene graph invalidation.

Tests/gates are embedded in the diagnostic: percentile self-check, Release,
actual backend, left display, 50 visible/unclipped items, native-control count,
shadow pixels, nonempty frames, zero QML warnings, nonzero intercepted draw
calls and zero new warm-cache textures. No private probe is added to the kit's
routine tests. Results contain per-run JSON, logs, PNGs, manifest and summary.

## Verify the cache-lifetime candidate

Keep `results/` unchanged. Prepare a NEW snapshot with the current production
BlurMask cache implementation overlaid on the same pinned baseline. The probe
and lifecycle counters are added only to that temporary copy.

```sh
python3 prepare.py /private/tmp/qavsi-shadow-cache-replay --cache-candidate
cmake -S . -B /private/tmp/qavsi-shadow-cache-replay/build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=/Users/techalp/Qt/6.12.0/macos \
  -DSTUDY_SNAPSHOT=/private/tmp/qavsi-shadow-cache-replay \
  -DQAVSI_ICONS_SOURCE=/private/tmp/qavsi-shadow-cache-replay/icons \
  -DCMAKE_SKIP_INSTALL_RULES=ON
cmake --build /private/tmp/qavsi-shadow-cache-replay/build --parallel 3
python3 run.py /private/tmp/qavsi-shadow-cache-replay/build results-cache-retained \
  --require-cache-reuse
python3 analyze.py results-cache-retained --summary-only
```

`--require-cache-reuse` requires zero new corner textures when returning from
zero elevation after warming. It fails with exit10 on the original weak cache.
The recorded candidate series is in `results-cache-retained/`; hashes are in
`cache-candidate-inputs.json`.

The separate functional lifecycle check uses the built `shadow-list-study`
executable with `--backend metal --scene blur-mixed --require-cache-reuse
--lifecycle --output metal-lifecycle.json` and `QSG_RENDER_LOOP=threaded`.
For OpenGL use `--backend opengl` and `QSG_RENDER_LOOP=basic`. Both use only
the left display. Metal tests two hide/releaseResources/recreate cycles;
OpenGL/basic retains its graph on hide, so it tests two window-destruction/
recreation cycles. Both require three cache creations and destructions, zero
wrong-thread destructions, and pixel-identical recreated scenes. The repaint
heartbeat is reset before image comparison. `cache-lifetime/` retains results.

Lifecycle runs include snapshots/context recreation and are functional checks,
not timing evidence. The candidate removes repeated generation of retained
masks; first-time sigma/radius values and values evicted by the LRU still cost.
