# Pickers and carousel

QCM 0.6.1 picker and carousel references, adapted to Qt 6.12 native controls.
Date/color/carousel use `191260585a829ee4ae2c99e6232b7145b5c34474`; the
time-picker port uses `229bc3e64ff71f1ac88cf73e976637ffbcf7e33c`. No QCM runtime.

| Public type | Contract |
|---|---|
| `Material3DatePicker` | Embeddable StyleKit Pane, Single/Range and Calendar/Input, locale/bounds and controlled selection requests. See [date-picker](date-picker.md). |
| `Material3DatePickerDialog` | Native Dialog containing the same date picker, with committed `selectedDate`, draft `currentDate` and `acceptedDate(date)`. |
| `Material3TimePicker` | Embeddable StyleKit Pane with Clock/Input modes, 12/24-hour presentation and controlled `selectedHour`/`selectedMinute` requests. See [time-picker](time-picker.md). |
| `Material3TimePickerDialog` | Native Dialog containing the same time picker; `currentHour`/`currentMinute` own its draft and `acceptedTime(hour, minute)` uses canonical 24-hour values. |
| `Material3ColorPicker` | Embeddable native Control with HSV/RGB, alpha, gradient channels and QCM trailing-alpha hex (`#RRGGBBAA`). See [color-picker](color-picker.md). |
| `Material3ColorPickerButton` | Native Button with QCM split swatch, tonal colorize glyph and owned color dialog; `color`/`showAlpha`, caller-owned `accepted(color)`. |
| `Material3ColorPickerDialog` | Native Dialog containing the same color editor, with committed `selectedColor`, draft `currentColor` and `acceptedColor(color)`. |
| `Material3Carousel` | Native StyleKit Pane/Button/PageIndicator composition around the pinned QCM keyline engine and public Qt Flickable. Six layouts, horizontal/vertical and mirrored navigation; see [carousel](carousel.md). |

Inline picker inputs stay bound to caller state and emit change requests. The
Dialog variants copy committed values into a
draft; rejecting discards edits; acceptance emits a request, never assigns the
input property. Date selections outside the inclusive range are ignored. An
invalid or inverted range disables confirmation. Invalid initial time or invalid
time-editor text disables the user-facing OK button. On the Dialog hosts,
`selectDate`, `selectTime`, and `selectColor` update only the draft. On inline
controls, selection methods emit requests without assigning caller inputs.
Native Dialog open/close/focus and acceptance remain available: programmatic
`accept()` retains native behavior, but an invalid time emits no `acceptedTime`.

`PickersCarouselGallery.qml` uses `QtQuick.Dialogs.FileDialog` directly with
`OpenFiles` and its native `selectedFiles`/accepted signal. Cancel keeps caller
state. QuickDialogs belongs only to the example; Style does not depend on it.

The time picker includes the QCM analog dial and Clock/Input mode switching.
Color wheel/triangle and year/month/day date navigation are also implemented.
Platform file-dialog pixel parity remains outside the kit. Carousel uses QCM
snapping; reduced motion finishes an active snap immediately.

Verification scope: the public comparison consumer covers controlled inline
requests, date bounds/cancel/reopen/accept, time validation/12-hour canonical
acceptance, alpha color cancel/accept and native carousel keyboard/bounded
navigation through the shared source/installed consumer. OS file chooser
interaction and native GPU appearance require the root review gate; offscreen
checks do not open the chooser.

Migration: previous dialog uses of `Material3DatePicker`, `Material3TimePicker`
and `Material3ColorPicker` must use the `Dialog` suffixed types. The old draft and
accept/cancel APIs are preserved there; inline controls need no window or popup.
