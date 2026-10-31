pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

SK.StyleVariation {
    id: root
    required property Material3Style sourceStyle
    property Material3Theme tokens: sourceStyle.tokens
    required property var metrics
    property bool filled: false

    textField {
        leftPadding: root.metrics.horizontalPadding
        rightPadding: root.metrics.horizontalPadding
        topPadding: root.metrics.verticalPadding
        bottomPadding: root.filled ? root.metrics.verticalPadding / 2 : root.metrics.verticalPadding
        text.alignment: Qt.AlignLeft | (root.filled ? Qt.AlignBottom : Qt.AlignVCenter)
        background {
            height: root.metrics.height
            color: root.filled ? root.tokens.textFieldFilledContainer : root.tokens.transparent
            border.color: root.filled ? root.tokens.textFieldIndicator : root.tokens.outline
            data: Material3TextFieldParameters {
                tokens: root.tokens
                reducedMotion: root.sourceStyle.effectiveReducedMotion
                metrics: root.metrics
                filled: root.filled
            }
        }
        hovered.background.border.color: root.tokens.surfaceForeground
        focused.background.border.color: root.tokens.primary
        disabled {
            background.color: root.filled ? root.tokens.textFieldDisabledFilledContainer : root.tokens.transparent
            background.border.color: root.tokens.disabledContainer
        }
    }
}
