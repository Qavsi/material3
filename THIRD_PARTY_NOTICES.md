# Third-party notices

Qavsi Material3's original implementation and documentation are licensed under
the MIT License in [LICENSE](LICENSE), Copyright (c) 2026 Enes Alp.
This license does not replace the terms of separately supplied dependencies
or linked reference material.

## Qt

Qt Core, Gui, Qml, Quick, Quick Controls and LabsStyleKit are external build/runtime dependencies;
Qt ShaderTools is a kit build dependency and Qt Test is used by the example's
checks. No Qt implementation, SDK binary or font is vendored in this repository.
Consumers supply Qt under the license applicable to their Qt installation.
Redistributing Qt with an application requires preserving Qt's applicable terms
and notices; the MIT license for this kit does not license Qt.

- [Qt licensing](https://www.qt.io/licensing/)
- [Qt 6 licensing documentation](https://doc.qt.io/qt-6/licensing.html)

## Google Material Design reference

The numeric color, geometry, typography and state-layer reference is
Material Components for Android 1.13.0, commit
`84c0e6d6d493fcf176d2099683245b78afbeb78d`.
Upstream source files are licensed under Apache-2.0. Pinned file links and
explicit Qt adaptations are recorded in [DESIGN.md](https://github.com/Qavsi/material3/blob/main/DESIGN.md).

- [Upstream project](https://github.com/material-components/material-components-android/tree/84c0e6d6d493fcf176d2099683245b78afbeb78d)
- [Upstream Apache-2.0 license](https://github.com/material-components/material-components-android/blob/84c0e6d6d493fcf176d2099683245b78afbeb78d/LICENSE)

No Google widget implementation, upstream widget source snapshot or font is
redistributed in the runtime kit. The optional comparison example includes the
Google SVG assets separately identified below. The kit-specific Qt/QML mapping
is original; adapted rendering implementations and their notices are identified
separately below. Numeric reference values are not presented as a Google
endorsement or full Material3 conformance.

## Comparison example assets and layout reference

The optional `examples/qmlmaterial-comparison` consumer carries the prior
QmlMaterial comparison layout. QmlMaterial is MIT licensed; its preserved
[license](https://github.com/Qavsi/material3/blob/main/examples/qmlmaterial-comparison/QMLMATERIAL-LICENSE.txt) and
[pinned provenance](https://github.com/Qavsi/material3/blob/main/docs/migration/upstream-reference.md) accompany the example.
QmlMaterial is not a kit runtime/build dependency and is not vendored here.
The native TextField recipe additionally references QmlMaterial 0.6.1
(`191260585a829ee4ae2c99e6232b7145b5c34474`), its input layout, floating
caption and filled/outlined geometry. The adaptation uses Qt's native TextField
and Shape APIs; no QCM control or input runtime is linked.
The native ComboBox recipes, floating caption and option-menu geometry use the
same pinned QCM reference; Qt retains model, editing and selection ownership.

The example’s `icons/*.svg` are Google Material Symbols Rounded, pinned to
material-design-icons `10ecc14790612ca8fd164e3f4ffe9c16fc50d5b7`, under Apache-2.0.
Their [full license](https://github.com/Qavsi/material3/blob/main/examples/qmlmaterial-comparison/icons/LICENSE-Apache-2.0.txt),
[provenance](https://github.com/Qavsi/material3/blob/main/examples/qmlmaterial-comparison/icons/README.md) and
[hash manifest](https://github.com/Qavsi/material3/blob/main/examples/qmlmaterial-comparison/icons/manifest.json) are retained.
The runtime kit does not install these archived example assets or expose a font provider.
The live gallery now selects the independent Qavsi.Icons.Material provider;
its matching Google font/catalog and Apache-2.0 notices belong to that package.

## Google Material Color Utilities

The runtime Theme library embeds a private seed-only C++ subset from
[material-foundation/material-color-utilities](https://github.com/material-foundation/material-color-utilities),
pinned revision `ca894db8b6aebb2833f1805ae61573c92e3f1660`.
Copyright notices remain in the upstream files; the complete
[Apache-2.0 license](third_party/material-color-utilities/LICENSE) is distributed
and installed with the package. [Provenance](third_party/material-color-utilities/provenance.json)
records every original and local SHA-256.

Local modifications: standard C++ aggregate initialization, standard C++20 pi,
explicit optional header if needed, and replacing Abseil hexadecimal formatting
with `std::to_chars`. Modified files carry notices. The color algorithm is unchanged.
Only Neutral/TonalSpot and their transitive dependencies are compiled; image
quantization, image extraction and scoring are excluded. QmlMaterial is used
only to record independent reference outputs and is not a kit dependency.
The kit's own code remains MIT; this does not relicense Google's source files.

## QCM / AOSP / Skia ripple adaptation

The button shader mathematics and press/hold/release sequence adapt pinned
QmlMaterial229bc3e64ff71f1ac88cf73e976637ffbcf7e33c RippleSkia.qml/ripple.frag.
QCM is MIT; the original realistic ripple is Copyright (C) 2021 The Android
Open Source Project (Apache-2.0); driver constants derive from Skia's
Copyright 2023 Google LLC source (BSD-style). Their full notices/licenses and
official source pins/hashes are in third_party/ripple-reference and installed
under share/licenses/QavsiMaterial3/ripple-reference. No Skia library is linked.
The Qt shader uses correct single premultiplication and zero-radius guards;
the software gradient approximates the wave edge without sparkle noise.

## QCM / Skia analytic shadow adaptation

The internal shadow renderers adapt the rounded-rectangle ambient/spot mesh,
Gaussian corner-cutout mask, profile textures and shaders from pinned QmlMaterial
`229bc3e64ff71f1ac88cf73e976637ffbcf7e33c`, including its Skia-derived
mathematics. Source pins, local adaptation notes and full upstream notices
are preserved in `third_party/shadow-reference/` and installed under
`share/licenses/QavsiMaterial3/shadow-reference`. The QCM library and the full
Skia engine are not linked. Material3 lighting, opacity and motion decisions
remain in this kit's Theme/style adapter rather than the drawing primitive.
