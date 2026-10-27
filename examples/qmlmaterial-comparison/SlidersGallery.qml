pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Layouts
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Style
import Qavsi.Material3.Theme

Column {
    id: root
    required property Material3Theme tokens
    readonly property ComparisonMetrics metrics: ComparisonMetrics { }
    spacing: tokens.spacingLarge

    component Caption: Text {
        font: root.tokens.labelMedium
        color: root.tokens.surfaceVariantForeground
        textFormat: Text.PlainText
    }
    Text {
        width: parent.width
        text: qsTr("Sliders")
        font: root.tokens.titleLarge
        color: root.tokens.surfaceForeground
        horizontalAlignment: Text.AlignHCenter
        textFormat: Text.PlainText
    }
    DemoCard {
        width: parent.width
        tokens: root.tokens
        title: qsTr("M3")
        contentPadding: root.tokens.inputGalleryPadding
        minimumContentWidth: root.metrics.sliderGalleryMinimumWidth
        RowLayout {
            width: parent.width
            spacing: root.tokens.spacingSmall
            Text {
                Layout.fillWidth: true
                font: root.tokens.bodyLarge
                color: root.tokens.surfaceForeground
                text: qsTr("Volume")
            }
            Text {
                font: root.tokens.bodyMedium
                color: root.tokens.surfaceForeground
                text: qsTr("Read only")
            }
            SK.Switch {
                spacing: 0
                id: readOnlySwitch
                objectName: "comparison.slider.readOnly"
                Accessible.name: qsTr("Read only")
            }
        }
        SK.Slider {
            objectName: "comparison.slider.volume"
            width: parent.width
            from: 0; to: 100; value: 40; stepSize: 1
            live: false
            SliderSupport.labelBehavior: SliderSupport.LabelVisible
            SliderSupport.readOnly: readOnlySwitch.checked
            Accessible.name: qsTr("Volume")
        }
        RowLayout {
            width: parent.width
            spacing: root.tokens.spacingLarge
            Column {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignTop
                spacing: root.tokens.spacingSmall
                Caption { text: qsTr("Continuous") }
                SK.Slider {
                    objectName: "comparison.slider.continuous"
                    width: parent.width
                    from: 0; to: 100
                    Accessible.name: qsTr("Continuous")
                }
                Caption { text: qsTr("No value / stop indicators") }
                SK.Slider {
                    objectName: "comparison.slider.noIndicators"
                    width: parent.width
                    from: 0; to: 100
                    SliderSupport.labelBehavior: SliderSupport.LabelGone
                    SliderSupport.tickVisibilityMode: SliderSupport.TickNone
                    Accessible.name: qsTr("No value or stop indicators")
                }
                Caption { text: qsTr("Discrete snap, no indicators") }
                SK.Slider {
                    objectName: "comparison.slider.discreteNoIndicators"
                    width: parent.width
                    from: 0; to: 100; stepSize: 20; snapMode: SK.Slider.SnapAlways
                    SliderSupport.labelBehavior: SliderSupport.LabelGone
                    SliderSupport.tickVisibilityMode: SliderSupport.TickNone
                    Accessible.name: qsTr("Discrete snap without indicators")
                }
                Caption { text: qsTr("Discrete + stops") }
                SK.Slider {
                    objectName: "comparison.slider.discrete"
                    width: parent.width
                    from: 0; to: 100; stepSize: 20; snapMode: SK.Slider.SnapAlways
                    Accessible.name: qsTr("Discrete with stops")
                }
                Caption { text: qsTr("Snap on release, no stops") }
                SK.Slider {
                    objectName: "comparison.slider.snapOnRelease"
                    width: parent.width
                    from: 0; to: 100; stepSize: 20; snapMode: SK.Slider.SnapOnRelease
                    SliderSupport.tickVisibilityMode: SliderSupport.TickNone
                    Accessible.name: qsTr("Snap on release without stops")
                }
                Caption { text: qsTr("Value label always") }
                SK.Slider {
                    objectName: "comparison.slider.alwaysVisible"
                    width: parent.width
                    from: 0; to: 100; value: 50
                    SliderSupport.labelBehavior: SliderSupport.LabelVisible
                    Accessible.name: qsTr("Value label always")
                }
                Caption { text: qsTr("Range") }
                SK.RangeSlider {
                    objectName: "comparison.range.continuous"
                    width: parent.width
                    from: 0; to: 100; first.value: 20; second.value: 80
                    live: false
                    SliderSupport.readOnly: readOnlySwitch.checked
                    Accessible.name: qsTr("Range")
                }
                Caption { text: qsTr("Discrete range") }
                SK.RangeSlider {
                    objectName: "comparison.range.discrete"
                    width: parent.width
                    from: 0; to: 100; first.value: 20; second.value: 80
                    stepSize: 10; snapMode: SK.RangeSlider.SnapAlways
                    Accessible.name: qsTr("Discrete range")
                }
                Caption { text: qsTr("Inset icon") }
                SK.Slider {
                    objectName: "comparison.slider.inset"
                    width: parent.width
                    from: 0; to: 100; value: 50
                    SK.StyleVariation.variations: ["sliderMedium"]
                    SliderSupport.insetIcon: "material:volume_up"
                    SliderSupport.insetIconAtMinimum: "material:volume_off"
                    SliderSupport.labelBehavior: SliderSupport.LabelGone
                    SliderSupport.tickVisibilityMode: SliderSupport.TickNone
                    Accessible.name: qsTr("Volume with inset icon")
                }
            }
            GridLayout {
                Layout.alignment: Qt.AlignTop
                columns: 2
                rowSpacing: root.tokens.spacingMedium
                columnSpacing: root.tokens.spacingLarge
                Column {
                    spacing: root.tokens.spacingSmall
                    Caption { text: qsTr("Continuous") }
                    SK.Slider {
                        objectName: "comparison.slider.verticalContinuous"
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: root.metrics.sliderGalleryVerticalLength
                        orientation: Qt.Vertical
                        from: 0; to: 100
                        Accessible.name: qsTr("Vertical continuous")
                    }
                }
                Column {
                    spacing: root.tokens.spacingSmall
                    Caption { text: qsTr("Discrete + stops") }
                    SK.Slider {
                        objectName: "comparison.slider.verticalDiscrete"
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: root.metrics.sliderGalleryVerticalLength
                        orientation: Qt.Vertical
                        from: 0; to: 100; stepSize: 20; snapMode: SK.Slider.SnapAlways
                        Accessible.name: qsTr("Vertical discrete with stops")
                    }
                }
                Column {
                    spacing: root.tokens.spacingSmall
                    Caption { text: qsTr("Snap on release") }
                    SK.Slider {
                        objectName: "comparison.slider.verticalSnapOnRelease"
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: root.metrics.sliderGalleryVerticalLength
                        orientation: Qt.Vertical
                        from: 0; to: 100; stepSize: 20; snapMode: SK.Slider.SnapOnRelease
                        SliderSupport.tickVisibilityMode: SliderSupport.TickNone
                        Accessible.name: qsTr("Vertical snap on release")
                    }
                }
                Column {
                    spacing: root.tokens.spacingSmall
                    Caption { text: qsTr("Inset icon") }
                    SK.Slider {
                        objectName: "comparison.slider.verticalInset"
                        anchors.horizontalCenter: parent.horizontalCenter
                        height: root.metrics.sliderGalleryInsetVerticalLength
                        orientation: Qt.Vertical
                        from: 0; to: 100; value: 60
                        SK.StyleVariation.variations: ["sliderMedium"]
                        SliderSupport.insetIcon: "material:music_note"
                        SliderSupport.insetIconAtMinimum: "material:volume_off"
                        SliderSupport.labelBehavior: SliderSupport.LabelGone
                        SliderSupport.tickVisibilityMode: SliderSupport.TickNone
                        Accessible.name: qsTr("Vertical music slider")
                    }
                }
            }
        }
    }
}
