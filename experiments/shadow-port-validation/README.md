# Actual Material3 shadow port sanity benchmark

This standalone diagnostic copies the frozen shadow benchmark harness and adds
`ported`, which instantiates the real `Qavsi.Material3.Style.RoundedRectShadow`.
QCM comes from the existing Release reference dylib; its source is not rebuilt.
No production dependency on QCM or Qt private RHI headers is introduced.

```sh
cmake -S /private/tmp/qavsi-shadow-port-benchmark \
  -B /private/tmp/qavsi-shadow-port-benchmark/build -G Ninja \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_PREFIX_PATH=/Users/techalp/Qt/6.12.0/macos \
  -DQAVSI_MATERIAL3_SOURCE=/Volumes/Mac/SCS/dev/Qavsi/material3 \
  -DQAVSI_ICONS_SOURCE=/Volumes/Mac/SCS/dev/Qavsi/icons \
  -DQCM_REFERENCE_BUILD=/private/tmp/qavsi-shadow-benchmark/build \
  -DCMAKE_SKIP_INSTALL_RULES=ON
cmake --build /private/tmp/qavsi-shadow-port-benchmark/build --parallel 6
python3 /private/tmp/qavsi-shadow-port-benchmark/run.py
```

The twelve timed processes run serially: 1000 static/animated casters, QCM/ported,
three deterministically shuffled repeats, 1500ms warmup and 4000ms samples.
All other build/profiler/GUI activity must finish before running. The left
display must remain exposed. Exact fixture, actual port source and binary hashes
are recorded; changed source/binary inputs cannot resume a previous series.

Both modes import and link the same actual Material3 kit and frozen QCM library.
Both use 28x28/radius6 black casters at elevation 6, ambientOpacity 0.039,
spotOpacity 0.25, lightDirection(0,-1,1), lightRadius 800/600. One shared driver
animates 6-to8; QCM's built-in per-instance Behavior is disabled. This is a
renderer/binding sanity check, not a whole-control or input-animation benchmark.

The same actual-Metal, left-display, visible-object-count, shadow-pixel and
endpoint-change gates apply. Stage timings have corrected elapsed-time names;
they are not CPU metrics. Quantitative CPU claims use processCPU time only.
GPU timestamps are asynchronous completed-frame values. Three-repeat medians
and ranges go to `results/summary.json`; raw evidence remains separate from
the original sixty-run benchmark.

The 2026-10-26 run completed all twelve validity-gated measurements. Results
and ranges are in `results/summary.json`; interpretation and functional gatesare in [ANALYTIC-SHADOW.md](../../evidence/ANALYTIC-SHADOW.md). This archived
fixture records the original local paths; recreate them or adjust the runner
paths and start a fresh results directory for another machine.
