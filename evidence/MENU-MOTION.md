# QCM menu motion port

Reference: QmlMaterial 0.6.1, `191260585a829ee4ae2c99e6232b7145b5c34474`.
Existing shader/driver source pins stay unchanged; menu recipe pins are recorded
in `third_party/ripple-reference/provenance.json`.

## Implementation

- Native `SK.Menu` / `SK.MenuItem` input and lifecycle remain intact.
- Private Material3Ripple is shared by button and menu backgrounds; Metal shader
  and software painter are reused. Menu press is .10/restart; button remains .12.
- Public MenuEnter/MenuExit helpers bind native Popup.enter/exit explicitly.
  Theme owns 300/150 ms, opacity, scale .8/1 and QCM easing curves.
- StyleKit per-corner geometry feeds the same resolved ripple mask.
- Theme, reduced motion and caller transition ownership are preserved. No SDK,
  QCM/Skia runtime dependency or new control wrapper was added.

## Focused verification

- Source build: passed. Style qmllint: passed without warnings.
- Source CTest: 4/4; Small159, Comparison891, material colors303,
  MCU hex4 assertions; all zero failures.
- Relocated installed find_package consumers: Small159/0 and Comparison891/0
  on offscreen/software. Module exports and dependency audit passed.
- QML Preview: running on the left display; light/dark, menu opening,
  action activation/closing and reduced-motion selection received a short
  manual check. QCM reference is also available on that display.

Detailed Metal pixel/frame parity, performance and transition stress comparisons
were deferred at the user's request. Earlier exploratory native fixture results
are not claimed as a passed hardware regression gate.

Qt 6.12 retains its native limitations: an active transition can finish within
its original duration when reduced motion changes; reopen during exit can be
ignored until closed. No SDK workaround was introduced.
