# Native QCM / Qavsi shadow parity

Temporary diagnostic only. Uses the existing pinned QCM Release build and current
Material3 library in one process; it changes no repository or benchmark evidence.
Do not run concurrently with timing benchmarks. The window uses only the left
display and requires DPR1 for integer-aligned patch comparison.

```sh
rtk cmake -S /private/tmp/qavsi-shadow-parity -B /private/tmp/qavsi-shadow-parity/build -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH=/Users/techalp/Qt/6.12.0/macos
rtk cmake --build /private/tmp/qavsi-shadow-parity/build --parallel 4
rtk /private/tmp/qavsi-shadow-parity/build/shadow-parity.app/Contents/MacOS/shadow-parity --backend metal --output /private/tmp/qavsi-shadow-parity/metal.json --snapshots /private/tmp/qavsi-shadow-parity/metal-images
rtk /private/tmp/qavsi-shadow-parity/build/shadow-parity.app/Contents/MacOS/shadow-parity --backend opengl --output /private/tmp/qavsi-shadow-parity/opengl.json --snapshots /private/tmp/qavsi-shadow-parity/opengl-images
```

Override `QCM_BUILD`, `M3_BUILD`, `M3_SOURCE` on the configure command when needed.
Rebuild the current Material3 target before this harness. The QML scene requires
`RoundedRectShadow` and `BlurMaskShadow` registered in `Qavsi.Material3.Style`.

The fixture compares actual `MD.RRectShadowImpl` or `MD.BlurMaskImpl` against the
ported primitive at the same elevation/sigma/corners/color/opacity. Both patches
come from one `grabWindow()` frame. It includes black elevation1/3/6/8/12, circle,
pill, zero radius, unequal TL/TR/BL/BR `[4,12,20,8]`, fractional radii, zero corner,
dark background, colored alpha, and inherited opacity0.5.

Opaque black strict cases accept max channel error2/255 and mean error0.20/255 on
shadow-affected pixels outside the caster AABB. Both renderers must draw visible
shadow pixels. Analytic cases additionally call the current production geometry
functions and record generated/finite vertex and index counts. Blur cases use
actual native pixels; the analytic CPU geometry probe does not apply to that path.

No reference normalization hides upstream differences. QCM analytic drops input
color alpha and cubes inherited opacity; both upstream paths store straight RGB
where the port uses Qt-premultiplied color. Raw colored/analytic opacity cases are
reported as diagnostic deviations, not marked as exact parity. Separate port-only
checks verify linear opacity, color-alpha scaling, colored source-over bounds,
and zero ink at transparent colored input. Black BlurMask color-alpha/opacity0.5
cases remain strict raw comparisons.

The fixture compares renderers, not Theme or StyleKit policy. Sigma and blur alpha
match the QCM adapter directly (`max(elevation*1.2,.5)`, `colorAlpha*.35`, `Outer`).
An unavailable native OpenGL context is an unavailable test, never a Metal pass.

Nine pure `safeCutout` checks run before loading any QML/creating shadow textures:
normal Material3 input, zero/no-cutout, subthreshold radius, negative sigma/radius,
NaN sigma, infinite radius, and finite huge sigma/radius. Their assertions remain
active in Release through the report failure count; no huge input is allocated.
