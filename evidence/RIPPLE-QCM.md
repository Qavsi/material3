# QCM realistic ripple port

Qt6.12.0/macOS/Metal + software; no SDK change, commit or new Skia runtime dependency.
Source: pinned QmlMaterial229bc3e64ff71f1ac88cf73e976637ffbcf7e33c,
RippleSkia.qml + assets/shader/ripple.frag. Earlier simple disk ripple evidence
is historical; the production ripple now follows the QCM realistic effect.

Metal uses the same touch→center soft-circle wave, farthest-corner radius,
soft ring, triangle noise, four sparkle bands and three rotating circle grids.
Press450ms OutCubic→0.4; hold at0.4 with7s noise loop; release350ms→1→0.
State base fades to live hover/focus over150ms, then wave opacity fades over150ms.
Repress resumes the current progress. Two12% layers use premultiplied source-over.
Qt color uniforms are premultiplied once; zero-radius/dimension guards remain.

The existing StyleKit delegate owns visual state. Native SK.Button keeps press,
checked, focus, cancellation and activation ownership. Passive pointer tracking
does not grab input. Keyboard starts centrally. Cancel/disable/hide/minimize
clear feedback. Theme changes retain the live renderer and held native press.
Reduced motion uses static12% base only; no wave/noise. Software keeps the same
wave center/timing/fade via QPainter gradient, with an8-step cubic edge and no
sparkle noise. Software hold does not animate unused phase.

## Verification

- Source software:159 assertions/0; Metal:163/0.
- Comparison family:538/0, software and Metal.
- Color regressions:291/0; MCU utility:4/0. QML lint clean.
- Independent reference/math review: no blockers.
- Installed independent consumer:159/0 software,163/0 native Metal.
- QML Preview MCP restarted; CUA observed the running comparison and exercised
  the Filled button with a180ms hold/release on the left display. Live QCM
  frame-by-frame pixel parity was not measured. Full status: ripple-qcm.json.

New tests cover hold, early release, release-phase ordering, repress continuity,
stop/cleanup, reduced-motion boundaries, actual local wave pixels, theme and
one native activation per gesture. Timing checks account for one display frame;
render sampling waits for actual visible progress rather than a fixed90ms.
Native test windows are placed on the left display before showing.

There is no new performance claim. The16-cell Metal benchmark could not acquire
its required active window; the existing comparison harness rejects offscreen
software because it requires actual Metal. Those gates are recorded as skipped,
not passed. Shader and painter are not claimed pixel-identical, and QCM's0.85
debug fixture opacity is not substituted for its0.12 runtime opacity.

Google Material Color Utilities C++ remains the private Neutral/TonalSpot seed
subset (29 files/13 units, upstream ca894db8b6aebb2833f1805ae61573c92e3f1660).
It is active when Material3Theme.dynamicColors=true; the default static palette
is preserved. Existing12×20-role/240 exact QCM ARGB comparisons remain valid;
this ripple change does not change color generation. Full QCM62-role/9-scheme
API equivalence is not claimed.

QCM MIT, original AOSP2021 Apache-2.0 and Skia driver BSD notices are preserved
and installed under share/licenses/QavsiMaterial3/ripple-reference. Official
pins/blobs/hashes: third_party/ripple-reference/provenance.json.

[Machine-readable gates/fingerprints](ripple-qcm.json); [logs](logs/ripple-qcm).
