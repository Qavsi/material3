# QCM Material3 shadow integration

Updated 2026-10-26: Qt 6.12.0, macOS 26.5.2 arm64, Apple M4.
Both QCM elevation paths are now adapted: uniform-corner analytic ambient/spot
and unequal-corner Gaussian Outer BlurMask. The previous RectangularShadow
approximation and Metal-only selection are removed. No commit, push, SDK patch,
Merce change, or MButton removal was performed.

## Architecture and recipe

`SK.Button -> background.shadow.delegate -> SmallButtonShadow -> Material3Elevation -> analytic / BlurMask`.
Theme owns levels, lighting, alpha, duration/easing, and blur sigma recipe.
Existing `shadow.visible` and `contentRole` select Elevated/FAB without replacing
size variation data. StyleKit owns the one shadow slot; `SmallButtonShadow` maps button state and
paint geometry, the adapter owns reduced-motion transitions, and the private
primitives own geometry, shaders and render-thread resources. No new
shared Runtime, generic effects module, QCM library, or Skia engine dependency
is added. Production C++ uses public Qt scene-graph APIs.

| Control | Idle / focus / pressed | Hover | Disabled / hidden |
|---|---:|---:|---:|
| Elevated | 1 | 3 | 0 |
| FAB / Extended FAB | 6 | 8 | 0 |
| Filled / Tonal / Outlined / Text | 0 | 0 | 0 |

Unequal corners use QCM's `max(elevation*1.2,0.5)` sigma, shadow color alpha
multiplied by 0.35, and Outer mode. All visual recipe inputs are Theme tokens.
The Gaussian implementation retains 128-sample linear CDF, 4x4 subpixel cutouts,
separable convolution, half-pixel quantization, four cutout samplers, the
quantized shader sigma, 176-byte uniform layout, `RequiresFullMatrix`, and
54-vertex halo geometry. Source pins and upstream notices are in
[shadow-reference](../third_party/shadow-reference/NOTICE.md) and install with
the kit. Only the Outer mask needed by elevation is exposed internally.

Finite-input, tile-size and convolution-work checks prevent invalid allocation.
The render-thread cache retains at most 16 MiB of alpha8 payload; active material
references can outlive cache eviction, so this is not a total GPU-memory cap.
The BlurMask cache is retained per window until sceneGraphInvalidated, so hiding
all unequal-corner shadows does not discard warm masks. A direct, single-shot
connection releases the retained owner on the rendering thread; materials can
retain their references until their scene graph nodes are destroyed. Analytic
profile textures retain their existing weak bookkeeping. See
[cache lifetime verification](BLUR-CACHE-LIFETIME.md).

## Explicit Qt adaptations

QCM analytic drops caller color alpha and cubes inherited opacity. Both upstream
paths carry straight RGB despite premultiplied scene-graph blending. The port
preserves input alpha, normal Qt inherited opacity, and premultiplied RGB, as in
the ripple adaptation. Colored/partial-opacity raw QCM equality is deliberately
not claimed. Separate tests verify the Qt alpha/source-over contract.

Software retains painter ripple/fill/focus and suppresses GPU shadows. Hardware
uses QCM analytic/BlurMask selection. OpenGL requires version 3 or newer.
The GLES interpolation guard is selected per generated shader language; see
[ES portability verification](SHADOW-GLES.md). The macOS comparison bootstrap
requests a standard Qt 3.3 core context before QGuiApplication. Initial legacy
GL2.1 testing found missing GLSL120 graphics pipelines; its structural assertion
count was not a valid graphics pass. Those failures remain recorded as an
[excerpt and summary](logs/shadow-qcm-complete/legacy-opengl-summary.json).
The final Core run requires real shadow pixels and passes without those warnings.

## Functional and packaging gates

| Gate | Result |
|---|---|
| Source build / ctest | 4/4 pass |
| Source comparison software | 589 assertions, 0 failures |
| Source comparison Metal | 620 assertions, 0 failures |
| Source comparison OpenGL Core | 620 assertions, 0 failures |
| Relocated installed comparison software | 589 assertions, 0 failures |
| Relocated installed Small Button software | 159 assertions, 0 failures |
| Relocated installed comparison Metal | 620 assertions, 0 failures |
| Source and installed-comparison module-aware qmllint | pass |
| Original install prefix absent / relocated consumption | pass |
| Installed shader helper and upstream notices | present |
| Exported CMake dependency boundary | no source/Merce/Runtime/private-Qt dependency |
| QML Preview MCP | current source executable restarted successfully |
| Live visual observation | light Elevated and dark FAB observed after shadow-slot fix, QCM reference on left |

Tests cover analytic/BlurMask live switching, corner order TL/TR/BL/BR, QCM
sigma/alpha, visible outside shadow and clear Outer center, real hardware pixels,
opacity/color/size updates, reduced motion enabled mid-animation, zero/hide
cleanup, caller bindings, native focus/Space activation, Theme changes, and
software suppression. Metadata-only OpenGL assertions are insufficient; the
final native OpenGL run executes the shadow pixel checks too.

[Current source hashes/results](analytic-shadow.json) and
[functional logs](logs/shadow-qcm-complete/) accompany this report.
An earlier fixture observed lost variation metadata for controls created after
Theme-object replacement. The final native-reader fixtures are precreated before
replacement, then runtime Theme transitions are exercised. This does not resolve
the separate Qt/kit reader-cache initialization issue or establish arbitrary late
creation after Theme replacement. Earlier diagnostic logs remain in
[logs/analytic-shadow](logs/analytic-shadow/).

## Native StyleKit composition regression

The unlocked live UI revealed a second shadow not covered by primitive parity:
Qt6.12 DelegateContainer creates its own shadow independently of a custom
background. The earlier nested QCM helper therefore appeared beside the default
Qt RectangularShadow. The QCM adapter now occupies the native
`background.shadow.delegate` slot for button, flat/round/delay/tool families;
the background has no shadow Loader or shadow-state policy. The new private
shadow delegate keeps paint geometry and `delegateStyle.opacity * shadow.opacity`;
control opacity remains inherited once.

The regression test compares the actual native SK.Button halo to exactly one
standalone elevation helper on an opaque host, outside the caster AABB. Elevated
(12800 halo pixels) and FAB (11264 pixels) have maximum RGBA channel difference
**0**, in source Metal/OpenGL Core and relocated installed Metal. This catches
extra native shadows that a primitive-only comparison misses.

Cua observed the corrected light Elevated and dark FAB via QML Preview, with the
QCM reference on the left display. A later recheck found the Mac relocked; no UI
source changed between those successful observations and final test completion.

## Same-process QCM pixel comparison

The [reproducible native fixture](../experiments/shadow-parity/README.md) imports
the existing pinned QCM Release library and current Qavsi library in one process.
Reference and port patches are captured in the same frame at integer-aligned
DPR1 on the left VA2419 Series. No reference normalization hides upstream defects.
Each backend runs 24 scenarios: 18 strict raw comparisons plus 6 expected upstream
alpha/color deviations, two port-only Qt alpha invariant groups, and nine pure
input/resource-bound checks before texture allocation.

| Backend | Analytic strict cases / maximum channel error | BlurMask strict cases / maximum channel error | Failures |
|---|---|---|---:|
| Metal | 9 / 1 of 255 | 9 / 0 | 0 |
| OpenGL Core | 9 / 1 of 255 | 9 / 0 | 0 |

Cases include levels 1/3/6/8/12, pill/circle/square, unequal/fractional/zero corners,
dark background, color alpha and inherited opacity. Strict parity evaluates the
shadow halo outside the caster rectangle. The separate functional helper test
verifies the Outer interior remains clear. All Qt opacity/alpha/premultiplication
and transparent-color invariants pass. Raw case data, finite analytic geometry
counts and paired images are preserved in
[Metal results](../experiments/shadow-parity/metal.json) and
[OpenGL results](../experiments/shadow-parity/opengl.json).

Vulkan, Direct3D, GLES runtime parity and unequal-corner 1000-item performance
were not tested. Compiled shader variants or uniform-path benchmarks do not
establish those results. The historical performance section below retains its
original uniform-renderer scope.

## Actual-port performance check

The original sixty-run [shadow benchmark](../experiments/shadow-benchmark/REPORT.md)
measures the original QCM renderer versus Qt shadow alternatives. Its percentages
must not be silently assigned to this port.

A separate [frozen bridge fixture](../experiments/shadow-port-validation/README.md)
measured the actual Material3 primitive against the existing Release QCM binary.
Both modes import/link both libraries. Twelve serial runs cover 1000 fully
visible 28x28/radius-6 casters, static or one shared 250 ms elevation 6-to-8
driver, three shuffled repetitions, 1500 ms warmup, and 4000 ms samples.
QCM's internal Behavior is disabled so it receives the same elevation input.
All runs passed renderer count, real shadow pixel, endpoint-change, exposure,
Metal backend, and zero-QML-warning gates. No builds, profiler, or UI automation
ran during timed samples.

Three-run medians, CPU and GPU in milliseconds:

| 1000 casters | QCM process CPU/frame | Port process CPU/frame | QCM GPU | Port GPU | Median FPS, QCM / port |
|---|---:|---:|---:|---:|---:|
| Static | 3.358 | 3.665 | 0.405 | 0.406 | 60.0 / 60.0 |
| Animated | 10.932 | 9.922 | 0.412 | 0.412 | 60.0 / 60.0 |

GPU medians are effectively equal. Static CPU was about 9.1% higher in the port;
animated CPU was about 9.2% lower. Ranges overlap, and three repetitions are a
sanity check rather than statistical evidence of superiority. One valid static
port run achieved 52.0 FPS and p95 frame interval 33.8 ms; it remains included.
Animated port runs were approximately 60 FPS. Full ranges and every raw run,
source/binary hash, logs, and caster snapshots are preserved in
[results](../experiments/shadow-port-validation/results/summary.json).

Process CPU is summed process CPU time divided by frames, not frame latency.
GPU timestamps are asynchronous completed-frame values. Stage elapsed times are
wall time, not CPU time. This renderer-only scene excludes full StyleKit control,
text, input, and per-control policy-animation costs. It does not establish a
universal performance win, 60-FPS guarantee, or non-Metal behavior.
