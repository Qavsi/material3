# Target-specific shadow interpolation — 2026-10-27

## Problem and fix

The four analytic/BlurMask vertex/fragment sources disabled `noperspective`
only when a build-wide GLES macro was set from QT_FEATURE_opengles2. A desktop
Qt build nevertheless emits GLSL ES300 inside each `.qsb` package. These ES
variants retained `noperspective` and required
`GL_NV_shader_noperspective_interpolation`, which is not a core ES300 feature.

The shadow shader group now uses `qt_add_shaders(PERTARGETCOMPILE)`. Each shader
uses Qt's `QSHADER_GLSL_ES` macro to omit the qualifier only for ES output.
This makes the result independent of the OpenGL flavor used to build Qt.
The four varying interfaces, bindings, uniforms, shader math, resource paths
and batchable variants remain intact. No control API, design token, software
renderer, cache budget or SDK change.

[Qt qt_add_shaders documentation](https://doc.qt.io/qt-6/qt-add-shaders.html)
documents PERTARGETCOMPILE; [QShaderBaker documentation](https://doc.qt.io/qt-6.8/qshaderbaker.html#setPerTargetCompilation)
defines QSHADER_GLSL_ES for ES targets only. The installed Qt 6.12 macro and qsb
were checked directly. Target-specific compilation adds offline compilation
work, not runtime work. ES uses normal perspective interpolation; non-ES
interpolation semantics are preserved, including transformed items.

## Artifact regression check

The checker extracts actual CMake-built packages, including standard and
batchable vertex variants, with the installed Qt 6.12 qsb.

| Target | Variants | Result |
|---|---:|---|
| GLSL ES300 | 6 | No noperspective or extension requirement |
| Desktop GLSL130/140/150/330 | 24 | Byte-identical to before the fix |
| Metal MSL12 | 6 | Byte-identical |
| HLSL50 | 6 | Byte-identical |
| SPIR-V100 | 6 | Byte-identical |

RED: old packages fail 6 ES checks. GREEN: all 48 extraction/portability/equality
checks pass. The non-ES equality comparison covers 42 compiled variants.
No stage, sampler or uniform reflection interface was made conditional.

## Native checks and scope

Release Qt 6.12, Apple M4, left VA2419 screen only. Four separate short native
checks pass:50 elevated native StyleKit buttons and 50 mixed-corner BlurMask
cards, on both Metal/threaded and OpenGL/basic. Each requires 50 visible shadow
samples and zero QML warnings. Draw counts remain 152 and 101 respectively.
The warmed repeat-from-zero cache regression also passes.

Both BlurMask snapshots match the previously committed PNGs exactly. Complete
button-scene PNG hashes differ and are retained as such; exact whole-scene
pixel equality is not claimed there. Native analytic shader bytes are unchanged.
No new PNGs are committed. These runs are functional smoke checks, not additional
CPU/GPU timing evidence.

[Inputs, raw checks and reproduction](../experiments/shadow-gles-compat/README.md)
retain package/source hashes, all 48 extraction results, expected old failures,
native JSON/logs and snapshot hashes. The isolated build excludes unrelated
uncommitted TextField/ComboBox work.

No real GLES runtime/device test, ES driver compilation/link test, Vulkan run
or D3D run. Shader extraction proves the unwanted ES extension requirement is
removed; it does not certify a particular driver/device. No GLES2/GLSL100
support is added. No full performance suite or software rerun: non-ES code is
identical and the software path bypasses these shaders.

AI assistance has been used to create this output.
