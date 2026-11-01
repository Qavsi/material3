# Other native controls

QCM reference: `229bc3e64ff71f1ac88cf73e976637ffbcf7e33c`, NumberStepper,
StepperInput, TextEdit and BottomSheet. All use this kit's Theme and StyleKit;
there is no QCM runtime or new dependency.

## SpinBox

```qml
SK.SpinBox {
    from: 0
    to: 100
    editable: true
    value: 3
}
```

This is the native integer API, including validator, locale, stepSize, wrap,
textFromValue/valueFromText and valueModified. The compact QCM recipe is 24px,
with LabelSmall11, a font-measured value allowance and native up/down hit regions. Arrow triangles use Qt Shapes,
so they work without importing an icon-font provider. The ColorPicker's channel
editor consumes this shared skin. QCM's real-valued StepperInput model is not
reimplemented; this mapping leaves native SpinBox value semantics unchanged.

## TextArea

```qml
SK.TextArea {
    placeholderText: qsTr("Notes")
    wrapMode: TextEdit.Wrap
    selectByMouse: true
    SK.StyleVariation.variations: ["textAreaFilled"]
}
```

Omit the variation for outlined. Assign it at creation, like existing field
recipes. Placeholder is the single floating caption; native text, cursor,
selection, readOnly, wrap and caller font/geometry stay native. Selection uses
primary/onPrimary with the existing restoring default-binding policy. TextField-
only `TextFieldSupport` accessories are not attached to TextArea. The private
frame/label paint is shared with TextField, not copied into a wrapper control.

QCM only supplies the unframed TextEdit primitive. The framed outlined/filled
TextArea is this kit's existing Material3 field adaptation, not a direct QCM skin.

## BottomSheet

```qml
Material3BottomSheet {
    id: sheet
    modal: true
    Column {
        width: sheet.availableWidth
        SK.Label { text: qsTr("Share notes") }
        SK.Button { text: qsTr("Close"); onClicked: sheet.close() }
    }
}
```

Call `sheet.open()`; use `modal: false` for the standard nonmodal presentation.
The component inherits the existing scoped Basic.Drawer: native bottom-edge
swipe, position, interactive, open/close and dismissal remain available. Default
children go into `content`; tall content scrolls. Placement uses the host overlay,
not the gallery card. Theme owns maximum width, clearance, handle geometry,
surface/ink, upper corners and existing motion/elevation policy. Reduced motion
sets subsequent native transitions to zero duration (an already running native
transition may finish within250ms); software keeps the readable surface
and existing shadow fallback. QCM detents/velocity projection/nested-scroll
handoff are outside this native mapping.

The comparison gallery and its existing consumer scenario demonstrate all three
families. See [TESTING.md](../../TESTING.md) for the agreed public seams.

BottomSheet body padding is0 by default. Set spacing/padding on caller content.
The handle is48x4px idle and52x12px while native dragging; geometry follows the
100ms motion token. Native entry/exit uses QCM's250ms emphasized curves. Separate
modal and standard examples close one another without changing an open sheet's
modality. Reopening resets its internal scroll position.

Natural sheet height includes positive y offsets in caller content; scrolling
retains the bottom edge instead of clipping that offset.
