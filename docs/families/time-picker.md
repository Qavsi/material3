# Time picker

`Material3TimePicker` adapts QmlMaterial's `TimePicker.qml`, `TimeInput.qml`
and time state/dial behavior from revision
`229bc3e64ff71f1ac88cf73e976637ffbcf7e33c` (MIT). It is an embeddable native
`SK.Pane`; the optional Dialog host is a separate public type. QCM is a source
reference, not a build or runtime dependency.

## Controlled inline picker

The application owns `selectedHour` (0–23) and `selectedMinute` (0–59).
`selectedTimeChangeRequested(hour, minute)` requests a change; it never assigns
those inputs. Handle the request in application state and keep the bindings live:

```qml
import QtQuick
import Qavsi.Material3.Style

Item {
    id: root
    property int hour: 9
    property int minute: 30

    Material3TimePicker {
        selectedHour: root.hour
        selectedMinute: root.minute
        use24Hour: true
        onSelectedTimeChangeRequested: (hour, minute) => {
            root.hour = hour
            root.minute = minute
        }
    }
}
```

The application selects `Material3Style` at its composition root, as for the
other controls. The inline picker needs no popup or window of its own.

| API | Contract |
|---|---|
| `displayMode` | `Material3TimePicker.Clock` or `Material3TimePicker.Input`; both edit the same controlled time. |
| `selection` | `Material3TimePicker.Hours` or `Material3TimePicker.Minutes`; selects the active dial/editor part. |
| `use24Hour` | Presentation only. The default follows the control's `locale`; all requests still use canonical 0–23 hours. |
| `showModeToggle` | Shows the native Clock/Input toggle; defaults to true. |
| `supportingText` | Picker heading; defaults to “Select time”. |
| `selectedTimeValid` | Whether the supplied hour/minute are in their canonical ranges. |
| `selectionValid` | Whether both the supplied time and current editor text are valid. |
| `selectTime(hour, minute)` | Requests one valid canonical time; ignores out-of-range values without replacing the inputs. |
| `commitInput()` | Validates and normalizes the current editor text; returns success. It does not commit application state on the caller's behalf. |
| `discardInput()` | Restores editor text from the current controlled time. It does not undo changes the application has already accepted. |
| `focusSelection()` | Focuses the active editor in Input mode, or the dial in Clock mode. |
| `hourField`, `minuteField` | Readonly aliases to the native editors, available for application focus, validation and accessibility integration. |

Clock mode retains hour/minute selection, the 24-hour inner ring and the 12-hour
AM/PM selector. Input mode uses native StyleKit TextFields with locale-aware
digits and validation. A 12-hour display of 11:59 PM still requests `23, 59`.
Escape restores local input and propagates to the native host; inside a Dialog it
rejects the draft, while inline use needs no popup handling. Invalid text itself is
never emitted as a time. A period change can still update
the last valid canonical time without replacing an invalid editing buffer.

## Dialog host and migration

The previous `Material3TimePicker` type was a Dialog. Rename those uses to
`Material3TimePickerDialog`; code calling `open()`, `reject()`, `accept()` or
handling `acceptedTime` belongs on that host:

```qml
Material3TimePickerDialog {
    selectedHour: root.hour
    selectedMinute: root.minute
    use24Hour: true
    onAcceptedTime: (hour, minute) => {
        root.hour = hour
        root.minute = minute
    }
}
```

The Dialog preserves `selectedHour`, `selectedMinute`, `use24Hour`,
`currentHour`, `currentMinute`, `selectionValid`, `selectTime(hour, minute)`
and `acceptedTime(hour, minute)`. `displayMode` controls the hosted picker;
the readonly `picker` alias exposes the same public inline component.

Opening resets `currentHour`/`currentMinute` from the committed inputs, clears
uncommitted text and selects Hours. The hosted picker updates only this draft.
Cancel/Escape discards the draft; reopening starts from the application value.
Valid acceptance emits one canonical `acceptedTime` without assigning the
committed inputs. Invalid time or editor text disables the user-facing OK button.

Qt retains ownership of the Dialog's result and lifecycle. Programmatic
`accept()` still accepts/closes the native Dialog; it is not overridden as a
validation gate. The custom `acceptedTime` signal is emitted only if the picker
can validate its input, so invalid programmatic acceptance cannot commit a time.

## Theme, rendering and verification boundary

Time-picker dimensions come from `tokens/material3.json`, its generated recipe
and `Material3Theme`; semantic colors, typography and motion remain kit-owned.
The Dialog adds no second content-padding layer: the embedded picker owns its
Theme insets in both contexts. A scoped `timePickerLabel` recipe removes generic
StyleKit Label insets and uses Theme line heights (heading/support 12/16,
dial 16/24, display 57/64). The source mode-toggle target remains 48px around its
40px paint area.

The dial uses native Qt input and Qt Quick painting without a shader-only path
or an additional library. Reduced motion completes/disables hand movement;
the public API is the same on Metal and software. Numeric Repeater identity keeps
clock label delegates stable during value changes; Input mode releases the hidden
label view. Narrow horizontal AM/PM order and outer corners follow mirroring.
Text selection uses the semantic primary/on-primary pair for visible contrast.

The clock face is an accessible Pane with a localized full-time description and
guarded increase/decrease actions, following the existing color-wheel pattern.
It does not promise a scalar Dial ValueInterface across hour/minute modes; native
hour/minute editors retain their standard text/value accessibility.

The private `materialtimestate.h/.cpp` and `materialtimedial.h/.cpp` adapt QCM
behavior to this controlled-input boundary. They are implementation details;
applications consume the public picker, editor aliases and Dialog signals.

Verification belongs to the existing comparison consumer: one inline request
and caller-binding scenario, then Dialog cancel/reopen/accept with canonical
12-hour values and invalid-input handling. Existing Theme/reduced-motion,
software and source/relocated-installed gates apply. No private state/dial
selectors, per-frame assertions or new renderer/size matrix are required.
