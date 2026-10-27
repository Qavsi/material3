# BlurMask cache lifetime — 2026-10-27

## Change

Keep the existing bounded BlurMask texture cache alive for the lifetime of its window scene graph. Previously, the global map held weak references: when every unequal-corner elevation became zero, its renderers/materials were removed and the last cache owner disappeared. Returning to nonzero elevation generated the same masks again.

`acquireTextureCache()` now retains one shared owner per QQuickWindow. A direct, single-shot `sceneGraphInvalidated` connection erases it on the rendering thread. Materials can keep their references until their nodes are destroyed. After invalidation the next use creates a new cache for the new graphics context. Single-shot cleanup avoids accumulating callbacks across repeated reinitializations.

The existing 16 MiB alpha8-payload LRU budget is unchanged. This is not a total GPU-memory cap: texture overhead, the shared profile texture and active references outside the LRU are additional. The trade-off is intentionally retaining warm masks when all elevations temporarily become zero, until eviction or scene graph invalidation.

No public API, token, shader math, analytic button/FAB shadow, batching policy or software renderer changed. No SDK patch or new dependency. Only one of the 19 pinned production shadow-source files differs from the original benchmark baseline.

## Verification

- RED: the new `--require-cache-reuse` regression check on the original weak-cache implementation exited 10 after zero-to-positive elevation regenerated 198 corner textures in the mixed-radius scene.
- GREEN: 24 native candidate runs passed the same exposure, actual-backend, left-display, visible-item, shadow-pixel and zero-QML-warning gates as the baseline. Every warmed repeat-after-zero phase also required zero new textures. Timing runs have no draw-call instrumentation.
- Same pinned Material3/Icons baseline, Qt 6.12, Apple M4, Release, VA2419 left display, DPR1/60Hz and shuffled scenario order. Three Metal timing repeats per scene; one OpenGL compatibility timing repeat. Eight separate draw-call diagnostics. The only existing comparison preview process was temporarily paused and resumed in finally; no builds or UI automation ran during timing.

### Return from zero elevation

Metal values below are medians of three timing runs. Convolution is accumulated steady_clock elapsed time inside mask generation, not thread CPU time or isolated GPU upload.

| 50-card scene | New textures before → after | Convolution ms before → after |
|---|---:|---:|
| blur-same | 44 → 0 | 12.027 → 0.000 |
| blur-mixed | 198 → 0 | 47.995 → 0.000 |

OpenGL also recorded zero new textures and zero convolution work on warmed repeat-after-zero. Draw counts are unchanged:151 for 50 controls without elevation,152 with analytic elevation, and 101 for either complete BlurMask card scene. These are whole-scene draw submissions, not isolated shadow-only counts.

This does not remove first-use generation. The candidate first animation still creates 44 textures for identical radii and 198 for mixed radii. Warm phases explicitly populate all 29 half-pixel sigma buckets outside timing; production code does not prewarm. New or LRU-evicted sigma/radius combinations can still generate masks. Do not extrapolate these runs to a universal frame-time improvement.

### Resource lifecycle

These are separate functional checks; their times are not used as benchmark evidence.

| Backend / reset | Recreate cycles | Cache creations / destructions | Wrong-thread destructions | Recreated pixels |
|---|---:|---:|---:|---|
| metal / hide-release-resources | 2 | 3 / 3 | 0 | identical |
| opengl / window-destruction | 2 | 3 / 3 | 0 | identical |

Metal/threaded invalidates on hide plus releaseResources with persistence disabled, so the same window is recreated twice. OpenGL/basic retains its graph on hide in this setup: its test destroys and creates the window twice instead. Both checks also destroy the final window, require every cache to be freed on its owner thread and require new textures after a real context reset. The heartbeat marker is reset before image comparison.

## Evidence and reproduction

- [Original measurement](../experiments/shadow-list-cold-cache/REPORT.md), committed separately in 688d389.
- [Candidate summary](../experiments/shadow-list-cold-cache/results-cache-retained/summary.json) and [manifest](../experiments/shadow-list-cold-cache/results-cache-retained/manifest.json); raw JSON/log/PNG files are retained beside them.
- Lifecycle checks: [Metal](../experiments/shadow-list-cold-cache/cache-lifetime/metal.json), [OpenGL](../experiments/shadow-list-cold-cache/cache-lifetime/opengl.json).
- [Pinned candidate inputs and hashes](../experiments/shadow-list-cold-cache/cache-candidate-inputs.json). Instrumentation is only in the temporary frozen copy, not the production library.
- [Reproduction commands](../experiments/shadow-list-cold-cache/README.md#verify-the-cache-lifetime-candidate). `prepare.py --cache-candidate` overlays only the production cache implementation on the original frozen source before adding measurement probes.

## Limits

No GLES, Vulkan or D3D device run, no 1000-item mixed-corner workload and no total-GPU-memory measurement. The GLES noperspective/extension portability question remains separate. No software-backend timing rerun: this RHI cache is bypassed by the existing software path. No pre-warm, crossfade or batching change.

AI assistance has been used to create this output.
