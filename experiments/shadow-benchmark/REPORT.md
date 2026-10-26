# Shadow renderer performance — 2026-10-26

**Completed: 60 valid native runs, 20 scenarios, three repetitions each.**

On this Apple M4 / Qt 6.12.0 / Metal / Release setup, QCM Elevation scales better than two uncached RectangularShadow items for the tested uniform-corner workload. At 1000 animated casters, its median process CPU cost is 68.58% lower and its median per-run GPU elapsed mean is 52.45% lower. Both still present at approximately 60 FPS.

## Representative results

Numbers below are medians of three independent per-run measurements. CPU is process time across all threads per presented frame. GPU is the median of each run's mean asynchronous completed-frame elapsed time, not a GPU p50.

| Casters / geometry | Workload | Qt two-layer CPU ms/frame | QCM CPU ms/frame | Qt GPU mean ms | QCM GPU mean ms |
|---|---|---:|---:|---:|---:|
| 100 / 28x28 r6 | static redraw | 2.500 | 1.425 | 0.146 | 0.152 |
| 100 / 28x28 r6 | animated | 4.964 | 2.789 | 0.171 | 0.108 |
| 1000 / 28x28 r6 | static redraw | 6.941 | 4.282 | 0.728 | 0.377 |
| 1000 / 28x28 r6 | animated | 26.819 | 8.426 | 0.807 | 0.384 |
| 100 / 56x56 r16 | static redraw | 2.221 | 1.537 | 0.158 | 0.139 |
| 100 / 56x56 r16 | animated | 5.780 | 2.900 | 0.188 | 0.191 |

## Repeat ranges and frame pacing

At 1000 casters, the run ranges do not overlap between the two comparable renderers; the observed cost difference exceeds the run-to-run variation.

| Workload / renderer | CPU range ms/frame | GPU mean range ms | Median frame p95 ms | Intervals over25ms |
|---|---:|---:|---:|---:|
| Static redraw / rectangular2 | 6.841–7.698 | 0.720–0.778 | 17.87 | 2/716 |
| Static redraw / qcm | 4.198–5.462 | 0.375–0.498 | 18.23 | 1/715 |
| Animated / rectangular2 | 25.283–27.656 | 0.762–0.959 | 23.53 | 18/716 |
| Animated / qcm | 8.408–9.383 | 0.382–0.394 | 17.83 | 3/717 |

CPU/frame is summed across process threads and can exceed one frame's wall time without lowering FPS. A 60 Hz display caps observed FPS; these results do not mean three times the FPS. In the static 1000 scenario, QCM's lower CPU cost does not produce a lower frame p95.

Small GPU workloads show substantial variability. In particular, the 100 actual FAB-sized animated case is effectively tied on GPU cost (Qt 0.188 ms, QCM 0.191 ms); do not claim a general GPU improvement at ordinary control counts. Its process CPU median is about 50% lower with QCM.

## Interpretation and decision

- QCM emits ambient and spot geometry together and shares a per-window falloff texture. Its material comparison permits compatible shadows to batch. This source-level design is consistent with the measured scaling; draw-call counts were not independently captured.
- A single fixed RectangularShadow can be cheaper, but it omits elevation movement and is not the same visual work. Full baseline results are in [table.md](results/table.md).
- Prefer QCM's elevation model for the Material3 renderer if matching QCM and scaling many shadows are requirements. A future adaptation should stay internal to the Material3 delegate; the whole QCM control library need not become a production dependency. No renderer migration is performed by this experiment.
- Keep the production software fallback as it is. This test ranks Metal renderers and does not establish a software-shadow policy.

## Measurement contract

- Apple M4, macOS Tahoe 26.5.2, Qt 6.12.0, Release (-O3/-DNDEBUG), native Metal, left VA2419Series 1920x1080 at DPR 1 / 60 Hz. Window 1800x950; right display was never selected.
- 100/1000 simultaneously visible 28x28 shapes; 100 additional 56x56 FAB-sized shapes. No clipped/offscreen/virtualized controls reduce the requested workload. These are shadow-casting rectangles, not 1000 complete interactive StyleKit controls.
- Uniform corners. Static elevation 6 with a shared tiny heartbeat forcing redraw; animated elevation 6↔8 with a shared 250 ms OutCubic driver. QCM's built-in per-instance Behavior is disabled to isolate renderer/binding cost.
- Each case has 1500 ms warmup and 4000 ms timing, three deterministic shuffled repetitions. Only one timed process runs at once. No profiler/build/UI inspection runs during timing.
- Pixel evidence verifies all shadows at base elevation. Animated QCM/two-layer Qt additionally verifies that endpoint pixels change. The two falloff algorithms are not pixel-identical.
- Actual backend, left screen, caster count/bounds, shadow count, pixel visibility, nonempty GPU timestamps, and zero QML warnings are gates. All 60 valid runs pass. Two earlier attempts lost exposure and were rejected; their logs remain.
- CPU is std::clock process CPU time. GPU timestamps are QRhi lastCompletedGpuTime with timestamp collection enabled; they refer asynchronously to previous completed frames. RHI headers/QtGuiPrivate are confined to the diagnostic executable.
- Important raw-data naming correction: `syncCpu` and `renderRecordingCpu` store QElapsedTimer elapsed stage durations, including waiting/scheduling. They are not actual CPU times. The recorded raw keys/source hashes are preserved; the analyzer names them stageElapsed. CPU claims in this report use only `cpuMsPerFrame`.
- Node counts, complete-control layout/input cost, unequal-corner BlurMask, cached Qt shadows, idle energy, software, other GPUs/platforms, and matching every visual detail are not measured.

## Separate profiler diagnostics

Two development-only 1000-caster animated runs were recorded after the timing matrix. They use the debug-enabled shadow-preview executable and are excluded from all comparison medians. Both profiler processes and both trace parsers exit 0. The traces are about 80 KiB each.

- [QCM diagnostic](profiler/reports/profile-report-shadow-qcm.md)
- [Two-layer Qt diagnostic](profiler/reports/profile-report-shadow-rectangular2.md)

The rendering trace summaries contain animation cadence but no captured QML CPU range hotspots. They cannot identify a QML binding bottleneck or establish actual draw-call counts. Use the uninstrumented native timing matrix for the quantitative comparison.

QML Preview was restarted after measurements and the running 100-caster QCM scene was visually checked on the left display.

## Reproduction and evidence

- [Build/run instructions and limitations](README.md)
- [All 60 raw JSON results](results/all-results.json)
- [Median table](results/table.md)
- [Summary with run ranges](results/summary.json)
- [Case order and source hashes](results/manifest.json)
- [Pinned QCM shadow sources and hashes](results/reference.json)

QCM shadow files at commit 229bc3e64ff71f1ac88cf73e976637ffbcf7e33c have no local diff. The Qt SDK and production Theme/Style/fallback code were not modified. No commit or push was performed.
