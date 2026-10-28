pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK

QtObject {
    id: root
    required property Material3Style sourceStyle
    readonly property SK.StyleVariation progressCircular: SK.StyleVariation {
        name: "progressCircular"
        progressBar {
            indicator {
                width: root.sourceStyle.tokens.progressCircularSize
                height: root.sourceStyle.tokens.progressCircularSize
                fillWidth: false
                fillHeight: false
                data: Material3ProgressParameters {
                    tokens: root.sourceStyle.tokens
                    reducedMotion: root.sourceStyle.effectiveReducedMotion
                    circular: true
                    wavy: false
                    motionType: 0
                }
            }
        }
    }
    readonly property SK.StyleVariation progressWavy: SK.StyleVariation {
        name: "progressWavy"
        progressBar {
            indicator {
                width: root.sourceStyle.tokens.progressWavyLinearMinimumWidth
                height: root.sourceStyle.tokens.progressThickness + root.sourceStyle.tokens.progressLinearWaveAmplitude * 2
                fillWidth: true
                fillHeight: true
                data: Material3ProgressParameters {
                    tokens: root.sourceStyle.tokens
                    reducedMotion: root.sourceStyle.effectiveReducedMotion
                    circular: false
                    wavy: true
                    motionType: 0
                }
            }
        }
    }
    readonly property SK.StyleVariation progressCircularWavy: SK.StyleVariation {
        name: "progressCircularWavy"
        progressBar {
            indicator {
                width: root.sourceStyle.tokens.progressWavyCircularSize
                height: root.sourceStyle.tokens.progressWavyCircularSize
                fillWidth: false
                fillHeight: false
                data: Material3ProgressParameters {
                    tokens: root.sourceStyle.tokens
                    reducedMotion: root.sourceStyle.effectiveReducedMotion
                    circular: true
                    wavy: true
                    motionType: 1
                }
            }
        }
    }
    readonly property SK.StyleVariation progressContiguous: SK.StyleVariation {
        name: "progressContiguous"
        progressBar {
            indicator {
                width: root.sourceStyle.tokens.progressLinearMinimumWidth
                height: root.sourceStyle.tokens.progressThickness
                fillWidth: true
                fillHeight: true
                data: Material3ProgressParameters {
                    tokens: root.sourceStyle.tokens
                    reducedMotion: root.sourceStyle.effectiveReducedMotion
                    circular: false
                    wavy: false
                    motionType: 1
                }
            }
        }
    }
    readonly property SK.StyleVariation progressCircularRetreat: SK.StyleVariation {
        name: "progressCircularRetreat"
        progressBar {
            indicator {
                width: root.sourceStyle.tokens.progressCircularSize
                height: root.sourceStyle.tokens.progressCircularSize
                fillWidth: false
                fillHeight: false
                data: Material3ProgressParameters {
                    tokens: root.sourceStyle.tokens
                    reducedMotion: root.sourceStyle.effectiveReducedMotion
                    circular: true
                    wavy: false
                    motionType: 1
                }
            }
        }
    }
}
