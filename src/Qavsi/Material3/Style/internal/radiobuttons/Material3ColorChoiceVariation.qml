pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK

SK.StyleVariation {
    id: root
    required property Material3Style sourceStyle
    name: "colorChoice"
    radioButton {
        leftPadding: 0; rightPadding: 0; topPadding: 0; bottomPadding: 0
        spacing: 0
        background {
            width: root.sourceStyle.tokens.minimumTargetSize
            height: root.sourceStyle.tokens.minimumTargetSize
        }
        indicator {
            width: root.sourceStyle.tokens.radioColorChoiceDiameter
            height: root.sourceStyle.tokens.radioColorChoiceDiameter
            alignment: Qt.AlignCenter
            delegate: root.sourceStyle.radioFactory.indicator
            data: Material3RadioButtonParameters {
                tokens: root.sourceStyle.tokens
                reducedMotion: root.sourceStyle.effectiveReducedMotion
                colorChoice: true
            }
        }
    }
}
