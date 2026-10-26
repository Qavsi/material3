# Menu / FAB comparison — 2026-10-26

Reference: QmlMaterial v0.6.1, commit
`191260585a829ee4ae2c99e6232b7145b5c34474`, Qt 6.12 Release.
Its independent latest checkout keeps the previous pinned benchmark checkout
and local macOS harness intact. 17 LFS assets were verified by SHA256 and size.

## Root causes and changes

- Native SK.Menu/MenuItem had no Material3 mapping, leaving default popup
  materials and geometry. The style now maps the QCM surface, LabelLarge,
  corner 4, minimum 200, 48 px rows and 8 px vertical padding. Native input remains
  in Qt, with modal/no-dim pointer routing and correct repeat-click dismissal.
- The inline plus/close FAB trigger explicitly requested elevated=false.
  It now receives the existing 6/8 FAB elevation; action rows remain flat.
- Comparison cards used surfaceContainerLow instead of QCM surfaceContainer.
  The adapter and Theme expose Google's GetSurfaceContainer() directly.
 12 oracle cases now compare 21 semantic roles; existing role values are intact.

## Verification

- Source Qt 6.12/Metal: **916 assertions, 0 failures**.
- Final source ctest: **4/4 passed** (software comparison, Small Button, MCU, utility checks).
- Relocated installed comparison and small-button software tests: passed.
- Source module-aware all_qmllint and both installed consumers: no warnings.
- Export audit: no source kit, Merce, Runtime or original install-prefix dependency.
- Actual small FAB and all 16 theme/motion/checked trigger combinations paint
  unclipped lower-halo pixels on hardware; software creates no GPU children.
- Source native Elevated/FAB single-layer composition still matches one helper,
  maximum channel error 0.
- QML Preview MCP started the updated source executable. CUA observed dark and
  light popup typography/surface/geometry and actual plus/close FAB shadows.
  Both reference and preview use the left display; native source test window
  geometry is (-1912,62,900,940) on VA2419 Series.

The native test harness requests frames while waiting for animations. A local
frame pump prevents desktop background-window throttling from looking like a
failed animation; production motion durations and renderer math are unchanged.
Earlier timing/focus attempts remain under /private/tmp and are not pass evidence.

## Limits

MenuItem uses StyleKit state layers. QCM's custom MenuBase router, ripple and
enter/exit animations are not copied. Native Metal and software are covered;
this patch does not add Vulkan/Direct3D/GLES or 1000-menu performance claims.
Installed kit dylibs target macOS 26.0; successful consumer builds do not prove
macOS 14.4 runtime compatibility. No SDK modification, commit or push was made.
