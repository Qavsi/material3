# Badge

`Material3Badge` is a small presentation helper based on a single native
`SK.Label`. It has no input handler, wrapper control, second label or loader.
StyleKit owns the background and semantic colors; the selected Material3Style's
Theme owns typography and geometry. It uses the same Qt Quick Rectangle/Text
path on software and Metal, without animation or a shader dependency.

```qml
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Style

SK.Button {
    text: qsTr("Inbox")
    Material3Badge {
        count: 120                 // paints 99+, accessible name is 120
        anchors.right: parent.right
        anchors.top: parent.top
    }
}
```

| Property | Contract |
|---|---|
| `count` | Default -1 means no count; a nonnegative value generates native text. |
| `maxCount` | Default 99; larger positive counts display `99+`. Negative caps normalize to zero. |
| `showZero` | Default false hides zero; true displays `0`. Zero never becomes a dot. |
| `dot` | Default false; displays a decorative dot when there is no text and count is nonzero. |
| `text` | Native Label property; an explicit value/binding owns text and replaces automatic count formatting. |

Changing `count`, `maxCount`, `showZero` or `dot` never swaps variations. For
application-driven switching between count and arbitrary text, provide one native
`text` binding that owns the presentation. The helper does not rewrite that binding.
Explicit font, width, height, padding and Accessible.name assignments retain
normal QML ownership. The background paints the native label's full allocated
width and height, including long text and capped counts. A later caller Accessible.name remains intact when count
changes. Text is plain text, with no HTML interpretation.

The immutable `badge` variation defaults to error/errorForeground. Select
`badgePrimary`, `badgeSecondary` or `badgeContrast` at creation for the matching
foreground/container pair; contrast uses inverseSurface/inverseSurfaceForeground.
Disabled ink/container use the existing onSurface opacity roles.

The QCM 0.6.1 reference is `qml/misc/Badge.qml` and `token/badge.hpp` at
`191260585a829ee4ae2c99e6232b7145b5c34474`: dot diameter6, label minimum16×16,
horizontal padding4 and overlay offset(4,-4), in logical pixels. The committed
canonical BadgeRecipe feeds Theme independently of Style. LabelSmall is
11px/500/tracking0.5; native font metrics may grow the label for explicit fonts.
An empty native Label retains a font line, so dot mode uses the minimum font
without painting a glyph; Theme padding resolves its natural6×6 dimensions.
QCM's wrapper/auto-target and alignment API is intentionally omitted: position
the native label with ordinary anchors or layouts. To match its top-right
overlay, bind `anchors.rightMargin: -tokens.badgeOffsetX` and
`anchors.topMargin: tokens.badgeOffsetY` to the selected Theme.

Counts expose the full number as their default accessible name, even when capped.
Caller text exposes its full text. Decorative dots are ignored; applications
should include their meaning in the associated button's accessible name or
description. Badge adds no focus stop and does not consume button clicks.

The comparison's public native-consumer check covers live counts/caps, full-count
accessibility, zero visibility and rendered capsule coverage behind capped/long
labels. It is reused by relocated installed consumers.
The existing independent QCM color oracle also checks on_error. Root UI review
is still required for appearance acceptance.
