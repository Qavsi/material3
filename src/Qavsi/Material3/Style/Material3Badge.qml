pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

SK.Label {
    id: root
    property int count: -1
    property int maxCount: 99
    property bool showZero: false
    property bool dot: false
    readonly property Material3Style sourceStyle: root.SK.StyleKit.style as Material3Style
    readonly property Material3Theme tokens: sourceStyle ? sourceStyle.tokens : null
    readonly property string countText: count < 0 || (count === 0 && !showZero) ? ""
        : count > Math.max(0, maxCount) ? String(Math.max(0, maxCount)) + "+" : String(count)
    readonly property bool dotMode: text.length === 0

    SK.StyleVariation.variations: ["badge"]
    text: countText
    textFormat: Text.PlainText
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    // Empty native Labels retain a font line even when no glyph is painted.
    font: tokens ? (dotMode ? Qt.font({ pixelSize: 1 }) : tokens.labelSmall) : Application.font
    visible: text.length > 0 || (dot && count !== 0)
    leftPadding: !tokens ? 0 : dotMode ? tokens.badgeDotDiameter / 2
        : Math.max(tokens.badgeHorizontalPadding, (tokens.badgeLabelMinimumWidth - contentWidth) / 2)
    rightPadding: leftPadding
    topPadding: tokens ? Math.max(0, ((dotMode ? tokens.badgeDotDiameter : tokens.badgeLabelHeight) - contentHeight) / 2) : 0
    bottomPadding: topPadding
    Accessible.role: Accessible.StaticText
    Accessible.ignored: dotMode
    Accessible.name: count >= 0 && text === countText ? String(count) : text
}
