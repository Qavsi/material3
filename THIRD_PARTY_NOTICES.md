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
