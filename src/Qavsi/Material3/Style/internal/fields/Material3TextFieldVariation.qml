pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK

SK.StyleVariation {
    id: root
    required property Material3Style sourceStyle
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
            color: root.filled ? root.sourceStyle.tokens.textFieldFilledContainer : root.sourceStyle.tokens.transparent
            border.color: root.filled ? root.sourceStyle.tokens.textFieldIndicator : root.sourceStyle.tokens.outline
            data: Material3TextFieldParameters {
                tokens: root.sourceStyle.tokens
                reducedMotion: root.sourceStyle.effectiveReducedMotion
                metrics: root.metrics
                filled: root.filled
            }
        }
        hovered.background.border.color: root.sourceStyle.tokens.surfaceForeground
        focused.background.border.color: root.sourceStyle.tokens.primary
        disabled {
            background.color: root.filled ? root.sourceStyle.tokens.textFieldDisabledFilledContainer : root.sourceStyle.tokens.transparent
            background.border.color: root.sourceStyle.tokens.disabledContainer
        }
    }
}
