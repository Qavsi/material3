# Third-party notices

Qavsi Material3's original implementation and documentation are licensed under
the MIT License in [LICENSE](LICENSE), Copyright (c) 2026 Enes Alp.
This license does not replace the terms of separately supplied dependencies
or linked reference material.

## Qt

Qt Core, Gui, Qml, Quick and LabsStyleKit are external build/runtime dependencies;
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

No Google widget implementation, upstream source snapshot, icon or font is
redistributed in this kit. The Qt/QML implementation is original; numeric
reference values are not presented as a Google endorsement or full Material3
conformance.

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
