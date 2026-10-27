# Shadow list and cold-cache study — 2026-10-27

24 valid native runs: 12 Metal timing runs, 4 OpenGL compatibility timing runs and 8 separate draw-call diagnostics. Production files and Qt SDK are unchanged. No commit or push.

## Scope and environment

- Qt 6.12.0, macOS macOS Tahoe (26.5.2), Apple M4, Release. Metal/threaded is the primary timing target; OpenGL requests a 3.3 Core context and uses the basic render loop required by this macOS setup.
- Left VA2419 display only, 1800x950 client area, DPR1/60Hz. All 50 items and their shadow margins are visible. Counts, backend, display, warnings and shadow pixels are validity gates.
- Real-control scene: 50 enabled native SK.Button controls, buttonSmall/elevated, 100x40, elevation1. The no-shadow scene keeps the same controls and disables only their elevation items. Hover is disabled to prevent pointer location changing the workload.
- Blur scenes: 50 80x56 cards. Same radii=(4,12,20,8); mixed adds index%5 to every radius. The exact Material3Elevation adapter is copied with one import added. This is a primitive/card workload, separate from the complete-control workload.
- Static controls and steady 6↔8dp BlurMask animation use a small repaint heartbeat. Four seconds per timing sample; Metal has three repetitions. OpenGL has one repetition and is a compatibility check, not a comparative performance claim.
- Initial animation is 0→12dp over 250ms. UI/scene setup is allowed 800ms before it starts; corner textures remain cold. This is a cold per-process corner cache, not a flushed driver/disk shader cache.

## Steady measurements

CPU is process CPU time across all threads divided by queued frames; it is not frame latency. Frame columns are wall-clock intervals between QQuickWindow.frameSwapped notifications (queued for presentation, not confirmed display scanout). Each listed percentile is the median of per-run percentiles; worst is the largest observed interval across all repeats.

| Backend / scene | CPU ms/frame | GPU mean ms | Frame p50 / p95 / p99 ms | Worst ms | Draw calls/frame |
|---|---:|---:|---|---:|---:|
| metal / 50 SK.Button, shadow off | 2.044 | 0.242 | 16.661 / 17.742 / 18.487 | 21.228 | 151 |
| metal / 50 SK.Button, analytic shadow on | 1.957 | 0.337 | 16.658 / 17.550 / 17.948 | 26.705 | 152 |
| metal / 50 BlurMask cards, identical radii | 2.605 | 0.222 | 16.642 / 17.686 / 18.196 | 18.893 | 101 |
| metal / 50 BlurMask cards, five radius sets | 2.384 | 0.396 | 16.676 / 17.503 / 17.847 | 19.222 | 101 |
| opengl / 50 SK.Button, shadow off | 2.205 | — | 16.663 / 20.757 / 22.465 | 26.455 | 151 |
| opengl / 50 SK.Button, analytic shadow on | 1.965 | — | 16.654 / 21.651 / 24.774 | 33.905 | 152 |
| opengl / 50 BlurMask cards, identical radii | 2.636 | — | 16.680 / 17.851 / 22.409 | 38.655 | 101 |
| opengl / 50 BlurMask cards, five radius sets | 3.449 | — | 16.682 / 18.152 / 32.822 | 33.216 | 101 |

GPU values are medians of per-run means of asynchronous completed-frame QRhi timestamps; they are not paired to the current CPU frame. OpenGL returned no usable GPU timestamps, shown as unavailable. Full GPU p50/p95/p99, CPU ranges and per-run data remain in JSON.

## Initial animation and cache lifetime — Metal

Animation wall time ends at the QML animation-finished signal. First-frame queue time starts at the animation request, excluding the previous idle interval. Frame maxima exclude that separate first-frame latency. Short animations contain roughly 15 frames, so tail percentiles have low sample counts.

| Scene / phase | Animation wall ms | First frame queued ms | Worst interval ms | New corner textures | Convolution elapsed ms |
|---|---:|---:|---:|---:|---:|
| blur-same / first-0-to-12 | 275.017 | 23.750 | 24.314 | 44 | 11.789 |
| blur-same / warm-retained-cache | 263.799 | 13.020 | 17.349 | 0 | 0.000 |
| blur-same / repeat-after-zero | 265.691 | 15.801 | 19.448 | 44 | 12.027 |
| blur-mixed / first-0-to-12 | 271.700 | 21.978 | 26.427 | 198 | 48.139 |
| blur-mixed / warm-retained-cache | 257.865 | 7.083 | 17.671 | 0 | 0.000 |
| blur-mixed / repeat-after-zero | 264.691 | 15.119 | 26.311 | 198 | 47.995 |

The warm-retained-cache phase explicitly populates all 29 half-pixel sigma buckets outside timing, then starts at 0.012dp so the materials retain cache ownership. Zero new textures are required and verified. This differs from returning every elevation to exactly0.

The repeat-after-zero phase returns all 50 elevations to 0 for 100ms. Material3Elevation destroys its renderers, the last strong BlurMask cache owner disappears, and the next animation generates corner textures again. The measured cold cost can recur; a one-time warmup is not sufficient if cache ownership is later released.

Convolution time is steady_clock elapsed time around mask convolution on the render thread, summed over new textures. It is not thread CPU time and does not isolate GPU upload. Only the frozen measurement copy contains this probe (atomic miss count plus elapsed timer); production renderer files are untouched.

## Draw-call method

Diagnostic processes load libdrawcounter.dylib through DYLD_INSERT_LIBRARIES. Mach-O interposition counts actual QRhiCommandBuffer::draw/drawIndexed API submissions for each frame. Counts are whole Qt Quick scene draw submissions, including bodies, labels and heartbeat; they are not inferred from nodes or batches. This fixture uses neither indirect draws nor external render nodes. This is not an OS-compositor draw count.

The injected library is absent from every timing process, and the application rejects an injected timing run. Each diagnostic uses a separate 600ms steady sample; its CPU/GPU timings are excluded from the tables. The counter requires nonzero observed calls to pass.

50 native analytic shadows add one draw submission (151→152). Each BlurMask scene submits101 whole-scene calls, including card bodies and the heartbeat. This is not an isolated shadow-only count. Repeated versus mixed radius sets have the same call count; the source RequiresFullMatrix restriction remains in effect. Do not compare the152 complete-button calls directly with101 card-scene calls.

## Interpretation

- At 50 native controls on this M4, the analytic shadow adds one draw and about 0.1ms mean GPU time. CPU ranges overlap; the lower on-shadow CPU median is measurement variation, not an optimization benefit.
- Unequal-corner first animation has measurable render-thread texture-generation cost, especially with multiple radius sets. Warm retained cache removes generation work. Preserve this scope: it does not affect the analytic button/FAB path.
- Consider cache ownership/lifetime before choosing pre-warm. Crossfade and vertex-attribute batching are not implemented by this study. The steady workload does not by itself justify either change on this device.
- OpenGL/basic passed all rendering/counter gates. Its first-frame latency can exceed 50ms in this one-run compatibility sample. Metal and OpenGL render loops differ; do not interpret their CPU figures as an isolated backend comparison.

## Evidence and limits

- results/manifest.json: shuffled order, binary hash, exits and durations. results/summary.json: per-scenario medians/ranges. Each raw JSON, log and PNG is retained.
- inputs.json: frozen revisions, production shadow hashes and harness/counter hashes. All 19 production shadow source files matched the frozen committed revision before the study.
- An initial forced-threaded OpenGL diagnostic crashed with `-[NSOpenGLContext setView:] must be called from the main thread.` Its excluded log is retained outside results. Validation-only attempts are not timing evidence.
- An existing Material3 preview process was temporarily SIGSTOP-paused for the series and SIGCONT-resumed in finally. No build, QML Preview connection, UI automation or draw-call instrumentation ran inside the timing processes.
- No GLES/Vulkan/D3D/device run; no1000-item unequal-corner claim. No software-shadow policy change. Three Metal repeats and one OpenGL repeat are a targeted check, not a universal FPS guarantee.

AI assistance has been used to create this output.
