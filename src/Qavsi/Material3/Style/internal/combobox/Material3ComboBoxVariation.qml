pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK

SK.StyleVariation {
    id: root
    required property Material3Style sourceStyle
    required property var metrics

    comboBox {
        leftPadding: root.metrics.horizontalPadding
        rightPadding: root.metrics.horizontalPadding
        topPadding: 0
        bottomPadding: 0
        spacing: root.metrics.spacing
        background {
            height: root.metrics.height
            data: Material3ComboBoxParameters {
                tokens: root.sourceStyle.tokens
                reducedMotion: root.sourceStyle.effectiveReducedMotion
                metrics: root.metrics
            }
        }
        indicator {
            foreground {
                width: root.metrics.iconSize
                height: root.metrics.iconSize
            }
        }
    }
}
