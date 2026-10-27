# Standalone shadow-list / cold-cache experiment

See [REPORT.md](REPORT.md) for measured results. This experiment changes no
production source, SDK, control API or software fallback. It freezes committed
Material3 and Icons sources and verifies all 19 shadow-source hashes before
adding a small cache-generation probe to the temporary copy.

macOS only: Qt 6.12, CMake 3.30, C++20, native left display at least1800x950.
The draw-counter library uses the pinned Qt6.12/macOS C++ ABI and is diagnostic
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
are mandatory. Returning all elevations to exactly0 releases the renderer-owned
cache, so repeat-after-zero is captured as a separate phase.

Tests/gates are embedded in the diagnostic: percentile self-check, Release,
actual backend, left display, 50 visible/unclipped items, native-control count,
shadow pixels, nonempty frames, zero QML warnings, nonzero intercepted draw
calls and zero new warm-cache textures. No private probe is added to the kit's
routine tests. Results contain per-run JSON, logs, PNGs, manifest and summary.
