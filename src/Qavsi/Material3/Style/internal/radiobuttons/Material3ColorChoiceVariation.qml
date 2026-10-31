pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme

SK.StyleVariation {
    id: root
    required property Material3Style sourceStyle
    property Material3Theme tokens: sourceStyle.tokens
    name: "colorChoice"
    radioButton {
        leftPadding: 0; rightPadding: 0; topPadding: 0; bottomPadding: 0
        spacing: 0
        background {
            width: root.tokens.minimumTargetSize
            height: root.tokens.minimumTargetSize
        }
        indicator {
            width: root.tokens.radioColorChoiceDiameter
            height: root.tokens.radioColorChoiceDiameter
            alignment: Qt.AlignCenter
            delegate: root.sourceStyle.radioFactory.indicator
            data: Material3RadioButtonParameters {
                tokens: root.tokens
                reducedMotion: root.sourceStyle.effectiveReducedMotion
                colorChoice: true
            }
        }
    }
}
