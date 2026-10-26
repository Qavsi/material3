# Material Color Utilities — Theme integration

Qt6.12.0 / macOS / Debug. No SDK change, commit or push.

The default MDC-Android palette is unchanged (`dynamicColors:false`). When
enabled,20 existing Material3Theme roles bind to a per-instance MaterialColorScheme.
Seed/scheme/contrast inputs are aliases to validated setters. Explicit caller
role values and live bindings remain intact across seed, dark and mode changes.
MCU is a pinned private PIC/hidden OBJECT subset embedded in the Theme library.

## Independent QCM comparison

Actual compiled MdColorMgr (QCM229bc3e64ff7), not a rewritten algorithm, recorded
three seeds(#bee7fd,#6750a4,#006875), Neutral/TonalSpot, Light/Dark at contrast0.
All12×20 existing semantic roles match exact ARGB:240 comparisons, zero mismatch.
QCM raw output includes62 roles per case; this integration exposes the20 current
kit roles, not a claim that all QCM roles/components have been migrated.

| Profile #bee7fd / Neutral / contrast0 | Primary | Surface |
|---|---|---|
| Light | #536068 | #fbf9f9 |
| Dark | #bac9d1 | #121314 |

Reference, source/library/probe hashes and repeat-run proof:
[material-color-reference.json](material-color-reference.json).
Exact reference probe sources are [preserved here](reference-material-colors).
Upstream MCU revision ca894db8b6aebb2833f1805ae61573c92e3f1660,29 files/13 C++ units;
[upstream/local fingerprints](../third_party/material-color-utilities/provenance.json).

## Passed checks

| Check | Result |
|---|---|
| Source focused color contract |291 assertions /0 failures |
| Relocated installed color consumer |291 /0 |
| Source-only HexFromArgb portability regression |4 /0 |
| Source Small software |121 /0 |
| Source comparison software /Metal |513 /0 each |
| Installed comparison offscreen software /Cocoa software /Metal |513 /0 each |
| Source/installed QML lint |PASS, no reported warnings |
| Library-only configure, examples OFF |PASS, focused tests OFF, no Qt Test lookup |
| Private packaging/symbol isolation |PASS |

Focused tests include exact QCM colors, legacy defaults, same-instance seed/
scheme/mode changes, independent engines/Themes, caller override/live binding,
invalid seed/enum/non-finite contrast rejection, finite contrast clamping,
opaque seed normalization and a real existing StyleKit button following live
seed/dark changes. QCM equivalence is tested at its fixed contrast0 only.

The package was installed, then renamed to a new prefix; the original prefix
is absent. Comparison and color consumers were copied outside the kit source
and built using only find_package. No MCU source/header/target is exported or
required. dyld exports contain no material_color_utilities symbols. Dependency
inspection found no QCM/MCU/Merce runtime library. Apache-2.0 license is installed.
Source build does not fetch dependencies. SDK optional Qt6TaskTree configure
warning is pre-existing and did not block these checks.

## Live UI and scope

QML Preview MCP was restarted after the C++ build and observed on the left
display alongside the existing QCM app. Qavsi's common and icon/FAB sections
showed the generated neutral blue/gray Light palette; the two Theme instances
use #bee7fd /Neutral /contrast0. User interacted with the live apps during
review; no further input was sent while that interaction was detected.
Numeric Light/Dark equivalence and native Metal/software paths passed above.

This is color-role equivalence, not pixel equality of every component/surface
mapping. Qavsi's consumer shell/layout and chosen surface roles are preserved.
Ripple behavior, shared font/FILL provider, additional control families, OS
accent/contrast hooks and image extraction are unchanged/out of scope. Linux,
Windows,WASM and static Qt were not tested in this change. No performance claim.

Raw logs: [material-colors](logs/material-colors).
