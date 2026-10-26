# Qavsi.Icons — Material3 integration

Qt6.12.0/macOS/Debug. No SDK change, commit or push; existing Merce/MButton untouched.
This report supersedes the earlier gallery SVG/FILL description only; previous
Material Color / geometry reports remain historical snapshots.

## Ownership

Independent Qavsi.Icons Core owns exact package routing, per-engine registry,
public QIcon/QPainter native/local source fallback and the AppIcon contract.
It has no Theme, StyleKit, font, semantic alias map or design token dependency.
The optional Material module owns the matching Google Rounded2.978 font and
4304-name catalog (10ecc147 revision), its Apache license, glyph validation,
axis rendering and CurveRendering→QtRendering software fallback.

Material3 owns checked→filled through typed style parameters. Only icon-button
appearances/sizes and connected icon geometry opt in; common/FAB icons retain
outline defaults, segmented selection retains its checkmark. Theme passes
wght400/opsz24/GRAD0/CurveRendering. QCM's FAB500 is a documented intentional
weight difference, not an exact parity claim. No variation mutation is needed.

The explicit Material3ButtonContent adapter uses AppIcon for package:icon and
keeps Qt IconLabel for unpackaged native name/source. Native SK.Button remains
the input, checked, focus, accessibility and binding owner. Transparent icon
color and non-square slots are tested. Settings no longer switches SVGs; the
semantic FAB add/close name change is preserved. Old SVG assets are archived.

Core resolves relative fallback URLs in the caller's QML context. QIcon/QPixmap
rasterization happens on the GUI thread; render-thread paint uses cached QImage.
Invalid sizes collapse without QFont warnings; invalid appearance fields use
provider defaults. Unknown names warn once per name/engine and fall back.

## Verification

| Gate | Result |
|---|---|
| Source Icons software DPR1 /DPR2 |89/0 each |
| Core-only software DPR1 /DPR2 |56/0 each |
| Source Icons native Metal |89/0 |
| Relocated installed Icons software DPR1 /DPR2 /Metal |89/0 each |
| Source Material3 comparison software /Metal |538/0 each |
| Installed Material3 offscreen software /Metal /Cocoa software |538/0 each |
| Source /installed text-only consumer |121/0 each |
| Theme colors /MCU utility regression |291/0;4/0 |
| Source /installed /mixed source-kit+installed-Core lint |PASS |
| Mixed source-kit+installed-Core build |PASS |
| Independent integration review |No blockers |

Tests include actual software and Metal font pixels/FILL endpoints, live tint,
transparent tint, native/source fallback, relative URL pixels, per-engine isolation,
late provider registration, missing-name warnings, finite appearance validation
and zero/NaN size collapse. The comparison covers Light/Dark, reduced motion,
icon appearances, selected/common policy and existing geometry/interaction checks.

Both packages were installed then renamed; the original prefix is absent.
Consumers copied outside the source tree use only find_package. Material3 depends
only on Core; the example selects Material through normal module IMPORTS and
target linking. Qt6.12 cannot query IMPORTS TARGET on an imported target, so the
provider dependency uses its URI; build-tool IMPORT_PATH metadata supplies Core
types for a source kit using installed Icons. No engine import-path workaround.
The text consumer links Core but not Material; Core-only installation has no
Material module/font/target and rejects a required Material component clearly.

QML Preview MCP was started again after macOS unlock; CUA observed and operated
the running source comparison alongside QmlMaterial on the left display.
All four icon-button appearances were toggled from empty to filled and back in
Light and Dark. Qavsi accessibility values changed0→1→0 for each settings button;
screenshots confirmed real glyph fill in both apps, with unchanged exact names.
Light→Dark preserved all four selected states and updated foreground/container
colors; Dark→Light preserved the empty states. Disabled glyphs remained muted.
Both apps were left in Light with the second/fourth appearance selected, so
filled and outline endpoints can be inspected together. Native test windows
were positioned on the left before showing. No source implementation, SDK,
system appearance settings or commit changed during this visual review.
This is a visual behavior comparison, not a pixel-diff or whole-gallery parity
claim; layouts/surface-role choices and QCM's FAB500 difference remain as documented.
SDK optional Qt6TaskTree configure warning is pre-existing; final lint has no QML warnings.

No Linux/Windows/WASM/static-Qt gate, SF/FA migration, animated FILL morph or new
performance claim. Native local/qrc fallback does not support remote images.
Font provenance, full file fingerprints and gate details:
[icons-integration.json](icons-integration.json). Raw logs: [icons](logs/icons).
