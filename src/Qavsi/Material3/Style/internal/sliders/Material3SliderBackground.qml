pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Templates as T
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Theme
import Qavsi.Icons

Item {
    id: root
    objectName: "material3.sliderBackground"
    required property T.Control control
    required property SK.DelegateStyle delegateStyle
    readonly property T.Slider slider: control as T.Slider
    readonly property T.RangeSlider range: control as T.RangeSlider
    readonly property Material3SliderParameters parameters: delegateStyle.data as Material3SliderParameters
    readonly property Material3Theme tokens: parameters.tokens
    readonly property bool horizontal: slider ? slider.horizontal : range.horizontal
    readonly property real thickness: parameters.trackThickness
    readonly property point origin: Qt.point(control.background.x + parent.x + x, control.background.y + parent.y + y)
    readonly property real start: horizontal ? control.leftPadding - origin.x : control.topPadding - origin.y
    readonly property real end: horizontal ? control.width - control.rightPadding - origin.x
        : control.height - control.bottomPadding - origin.y
    readonly property real crossCenter: horizontal ? control.topPadding + control.availableHeight / 2 - origin.y
        : control.leftPadding + control.availableWidth / 2 - origin.x
    readonly property var firstNode: slider ?? range.first
    readonly property var secondNode: range ? range.second : null
    readonly property real firstCenter: horizontal ? firstNode.handle.x + firstNode.handle.width / 2 - origin.x
        : firstNode.handle.y + firstNode.handle.height / 2 - origin.y
    readonly property real secondCenter: range ? horizontal ? secondNode.handle.x + secondNode.handle.width / 2 - origin.x
        : secondNode.handle.y + secondNode.handle.height / 2 - origin.y : firstCenter
    readonly property bool minimumAtStart: horizontal && !control.mirrored
    readonly property real lowerCenter: Math.min(firstCenter, secondCenter)
    readonly property real upperCenter: Math.max(firstCenter, secondCenter)
    readonly property real lowerGap: firstCenter <= secondCenter ? firstGap : secondGap
    readonly property real upperGap: firstCenter <= secondCenter ? secondGap : firstGap
    readonly property real firstGap: tokens.sliderTrackGap + firstLineWidth / 2
    readonly property real secondGap: tokens.sliderTrackGap + secondLineWidth / 2
    readonly property color activeColor: control.enabled ? tokens.primary : tokens.surfaceForeground
    readonly property color inactiveColor: control.enabled ? tokens.surfaceContainerHighest : tokens.surfaceForeground
    readonly property bool canAnimate: ready && visible && control.visible && root.Window.window
        && root.Window.window.visible && root.Window.window.visibility !== Window.Minimized
        && root.SK.StyleKit.transitionsEnabled && !parameters.reducedMotion
    property real firstLineWidth: firstNode.pressed || control.visualFocus && (slider !== null || firstNode.handle.activeFocus)
        ? tokens.sliderActiveHandleWidth : tokens.sliderHandleWidth
    property real secondLineWidth: range && (secondNode.pressed || control.visualFocus && secondNode.handle.activeFocus)
        ? tokens.sliderActiveHandleWidth : tokens.sliderHandleWidth
    property bool ready: false
    readonly property real rangeFrom: slider ? slider.from : range.from
    readonly property real rangeTo: slider ? slider.to : range.to
    readonly property real step: slider ? slider.stepSize : range.stepSize
    readonly property bool discrete: step > 0 && rangeFrom !== rangeTo
        && (range !== null || slider.snapMode === T.Slider.SnapAlways)
    readonly property int stopCount: control.SliderSupport.tickVisibilityMode === SliderSupport.TickNone ? 0
        : discrete ? Math.min(tokens.sliderMaxVisibleStops, Math.max(2, Math.floor(Math.abs(rangeTo - rangeFrom) / step) + 1))
        : control.SliderSupport.tickVisibilityMode === SliderSupport.TickAll ? 2 : 0
    readonly property real handleExtent: horizontal ? firstNode.handle.width : firstNode.handle.height
    readonly property real minimumCenter: start + handleExtent / 2
    readonly property real maximumCenter: end - handleExtent / 2
    readonly property bool hasInsetIcon: slider !== null && thickness >= tokens.sliderMediumTrackThickness
        && control.SliderSupport.insetIcon.length > 0
    readonly property real iconSize: tokens.sliderInsetIconSize
    readonly property real iconPad: tokens.sliderInsetIconPadding
    readonly property bool iconOnActive: horizontal
        ? Math.abs(firstCenter - (minimumAtStart ? start : end)) - firstGap >= iconSize + 2 * iconPad
        : firstCenter - firstGap - start < iconSize + 2 * iconPad
    readonly property real iconAxis: horizontal
        ? minimumAtStart === iconOnActive ? start + iconPad : end - iconPad - iconSize
        : iconOnActive ? firstCenter + firstGap + iconPad : start + iconPad

    width: parent.width
    height: parent.height
    implicitWidth: delegateStyle.width
    implicitHeight: delegateStyle.height
    visible: delegateStyle.visible
    opacity: control.enabled ? 1 : tokens.disabledLabelOpacity
    Accessible.ignored: true
    Component.onCompleted: ready = true
    onCanAnimateChanged: if (!canAnimate) { firstLineAnimation.complete(); secondLineAnimation.complete() }
    Behavior on firstLineWidth {
        enabled: root.canAnimate
        NumberAnimation { id: firstLineAnimation; duration: root.tokens.sliderMotionDuration; easing.type: Easing.Linear }
    }
    Behavior on secondLineWidth {
        enabled: root.canAnimate
        NumberAnimation { id: secondLineAnimation; duration: root.tokens.sliderMotionDuration; easing.type: Easing.Linear }
    }
    Binding {
        target: root.control.Accessible
        property: "readOnly"
        value: true
        when: root.control.SliderSupport.readOnly
    }
    // Qt checks connected Accessible actions before its default value mutation.
    Loader {
        active: root.control.SliderSupport.readOnly
        sourceComponent: Connections {
            target: root.control.Accessible
            function onIncreaseAction(): void { }
            function onDecreaseAction(): void { }
        }
    }
    Material3SliderTrack {
        objectName: "material3.sliderTrack.start"
        horizontal: root.horizontal; thickness: root.thickness; innerRadius: root.tokens.sliderTrackInnerRadius
        crossCenter: root.crossCenter
        start: root.start; end: Math.max(start, root.lowerCenter - root.lowerGap)
        outerStart: true
        color: root.range || !root.minimumAtStart ? root.inactiveColor : root.activeColor
    }
    Material3SliderTrack {
        objectName: "material3.sliderTrack.active"
        horizontal: root.horizontal; thickness: root.thickness; innerRadius: root.tokens.sliderTrackInnerRadius
        crossCenter: root.crossCenter
        start: root.lowerCenter + root.lowerGap; end: root.upperCenter - root.upperGap
        color: root.activeColor
        visible: root.range !== null && width > 0 && height > 0
    }
    Material3SliderTrack {
        objectName: "material3.sliderTrack.end"
        horizontal: root.horizontal; thickness: root.thickness; innerRadius: root.tokens.sliderTrackInnerRadius
        crossCenter: root.crossCenter
        start: Math.min(root.end, root.upperCenter + root.upperGap); end: root.end
        outerEnd: true
        color: root.range || root.minimumAtStart ? root.inactiveColor : root.activeColor
    }
    Repeater {
        model: root.stopCount
        Rectangle {
            required property int index
            readonly property real logicalPosition: index / (root.stopCount - 1)
            readonly property real visualPosition: root.minimumAtStart ? logicalPosition : 1 - logicalPosition
            readonly property real center: root.minimumCenter + visualPosition * (root.maximumCenter - root.minimumCenter)
            readonly property bool selected: root.range
                ? logicalPosition >= Math.min(root.range.first.position, root.range.second.position)
                    && logicalPosition <= Math.max(root.range.first.position, root.range.second.position)
                : logicalPosition < root.slider.position
            objectName: "material3.sliderStop"
            width: root.tokens.sliderStopDiameter; height: width; radius: width / 2
            x: root.horizontal ? center - width / 2 : root.crossCenter - width / 2
            y: root.horizontal ? root.crossCenter - height / 2 : center - height / 2
            color: selected ? root.tokens.primaryForeground : root.tokens.surfaceVariantForeground
            visible: Math.abs(center - root.firstCenter) > root.firstGap + width / 2
                && (root.range === null || Math.abs(center - root.secondCenter) > root.secondGap + width / 2)
            Accessible.ignored: true
        }
    }
    Loader {
        active: root.hasInsetIcon
        sourceComponent: AppIcon {
            objectName: "material3.sliderInsetIcon"
            name: root.slider.value === root.slider.from && root.control.SliderSupport.insetIconAtMinimum.length > 0
                ? root.control.SliderSupport.insetIconAtMinimum : root.control.SliderSupport.insetIcon
            size: root.iconSize
            color: root.iconOnActive ? root.control.enabled ? root.tokens.primaryForeground : root.tokens.surfaceForeground
                : root.tokens.surfaceVariantForeground
            appearance: root.parameters.iconAppearance
            x: root.horizontal ? root.iconAxis : root.crossCenter - width / 2
            y: root.horizontal ? root.crossCenter - height / 2 : root.iconAxis
        }
    }
}
