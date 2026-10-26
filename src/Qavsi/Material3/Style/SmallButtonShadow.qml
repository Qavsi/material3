import QtQuick
import QtQuick.Templates as T
import Qt.labs.StyleKit as SK

// StyleKit owns this shadow separately from the background delegate.
Material3Elevation {
    id: root
    required property SK.DelegateStyle delegateStyle
    required property T.AbstractButton control
    readonly property SmallButtonParameters parameters: delegateStyle.data as SmallButtonParameters
    readonly property bool floatingSurface: parameters.contentRole === "fab"
    readonly property real baseElevation: floatingSurface ? tokens.elevationLevel3 : tokens.elevationLevel1
    readonly property real hoverElevation: floatingSurface ? tokens.elevationLevel4 : tokens.elevationLevel2
    readonly property real maximumRadius: Math.min(width, height) / 2
    readonly property bool feedbackEnabled: Math.floor(width * Screen.devicePixelRatio) > 0
        && Math.floor(height * Screen.devicePixelRatio) > 0
        && control.enabled && control.visible && control.opacity > 0
        && delegateStyle.visible && delegateStyle.opacity > 0
        && delegateStyle.shadow.visible && delegateStyle.shadow.opacity > 0
        && Window.window && Window.window.visible && Window.window.visibility !== Window.Minimized

    tokens: parameters.tokens
    reducedMotion: parameters.reduceMotion
    targetElevation: !feedbackEnabled ? tokens.elevationLevel0
        : control.down ? baseElevation : control.hovered ? hoverElevation : baseElevation
    color: delegateStyle.shadow.color
    opacity: delegateStyle.opacity * delegateStyle.shadow.opacity
    visible: feedbackEnabled && hardware
    width: parameters.paintWidth > 0 ? Math.min(parent.width,
        Math.max(parameters.paintWidth, control.implicitContentWidth + control.leftPadding + control.rightPadding))
        : parent.width
    height: parameters.paintHeight > 0 ? Math.min(parent.height,
        Math.max(parameters.paintHeight, control.implicitContentHeight + control.topPadding + control.bottomPadding))
        : parent.height
    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    cornerRadii: Qt.vector4d(Math.max(0, Math.min(delegateStyle.topLeftRadius, maximumRadius)),
        Math.max(0, Math.min(delegateStyle.topRightRadius, maximumRadius)),
        Math.max(0, Math.min(delegateStyle.bottomLeftRadius, maximumRadius)),
        Math.max(0, Math.min(delegateStyle.bottomRightRadius, maximumRadius)))
}
