pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

SK.StyleVariation {
    id: root
    required property var sourceStyle
    required property string kind
    readonly property Material3Theme tokens: sourceStyle.tokens
    readonly property color container: kind === "filled" ? tokens.surfaceContainerHighest
        : kind === "outlined" ? tokens.surface : tokens.surfaceContainerLow
    readonly property Material3ListCardDelegate factory: Material3ListCardDelegate { }
    readonly property Material3ListCardParameters parameters: Material3ListCardParameters {
        tokens: root.tokens
        reducedMotion: root.sourceStyle.effectiveReducedMotion
        elevated: root.kind === "elevated"
    }
    pane {
        padding: root.tokens.listCardCardPadding
        text { color: root.tokens.surfaceForeground; alignment: Qt.AlignLeft | Qt.AlignVCenter; padding: 0 }
        background {
            width: root.tokens.listCardCardMinimumSize
            height: root.tokens.listCardCardMinimumSize
            color: root.container
            radius: root.tokens.listCardCardRadius
            margins: 0
            gradient: null
            border.width: root.kind === "outlined" ? root.tokens.outlineWidth : 0
            border.color: root.tokens.outline
            data: root.parameters
            shadow {
                visible: true
                color: root.tokens.shadow
                opacity: root.tokens.elevationContainerOpacity
                delegate: root.factory.shadow
            }
        }
        disabled {
            text.color: root.tokens.disabledLabel
            background.color: root.tokens.disabledContainer
            background.shadow.visible: false
        }
    }
    button {
        padding: root.tokens.listCardCardPadding
        text { color: root.tokens.surfaceForeground; alignment: Qt.AlignLeft | Qt.AlignVCenter; padding: 0 }
        background {
            width: root.tokens.listCardCardMinimumSize
            height: root.tokens.listCardCardMinimumSize
            color: root.container
            radius: root.tokens.listCardCardRadius
            margins: 0
            gradient: null
            border.width: root.kind === "outlined" ? root.tokens.outlineWidth : 0
            border.color: root.tokens.outline
            data: root.parameters
            delegate: root.factory.background
            shadow {
                visible: true
                color: root.tokens.shadow
                opacity: root.tokens.elevationContainerOpacity
                delegate: root.factory.shadow
            }
        }
        disabled {
            text.color: root.tokens.disabledLabel
            background.color: root.tokens.disabledContainer
            background.shadow.visible: false
        }
        hovered.background.color: root.container
        focused.background.color: root.container
        pressed { background.color: root.container; background.radius: root.tokens.listCardCardRadius }
        checked {
            background.color: root.container
            background.radius: root.tokens.listCardCardRadius
            hovered.background.color: root.container
            focused.background.color: root.container
            pressed { background.color: root.container; background.radius: root.tokens.listCardCardRadius }
        }
    }
    itemDelegate {
        padding: root.tokens.listCardCardPadding
        text { color: root.tokens.surfaceForeground; alignment: Qt.AlignLeft | Qt.AlignVCenter; padding: 0 }
        background {
            width: root.tokens.listCardCardMinimumSize
            height: root.tokens.listCardCardMinimumSize
            color: root.container
            radius: root.tokens.listCardCardRadius
            margins: 0
            gradient: null
            border.width: root.kind === "outlined" ? root.tokens.outlineWidth : 0
            border.color: root.tokens.outline
            data: root.parameters
            delegate: root.factory.background
            shadow {
                visible: true
                color: root.tokens.shadow
                opacity: root.tokens.elevationContainerOpacity
                delegate: root.factory.shadow
            }
        }
        disabled {
            text.color: root.tokens.disabledLabel
            background.color: root.tokens.disabledContainer
            background.shadow.visible: false
        }
        hovered.background.color: root.container
        focused.background.color: root.container
        pressed { background.color: root.container; background.radius: root.tokens.listCardCardRadius }
        checked {
            background.color: root.container
            background.radius: root.tokens.listCardCardRadius
            hovered.background.color: root.container
            focused.background.color: root.container
            pressed { background.color: root.container; background.radius: root.tokens.listCardCardRadius }
        }
    }
}
