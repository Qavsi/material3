pragma ComponentBehavior: Bound
import QtQuick
import Qt.labs.StyleKit as SK

SK.StyleVariation {
    id: root
    required property Material3Style sourceStyle
    slider.background.data: Material3SliderParameters {
        tokens: root.sourceStyle.tokens
        reducedMotion: root.sourceStyle.effectiveReducedMotion
        trackThickness: root.sourceStyle.tokens.sliderMediumTrackThickness
    }
}
