# Pickers and carousel

QCM 0.6.1 (`191260585a829ee4ae2c99e6232b7145b5c34474`) picker and
carousel references, adapted to Qt 6.12 native controls. No QCM runtime.

| Public type | Contract |
|---|---|
| `Material3DatePicker` | Embeddable StyleKit Pane, Single/Range and Calendar/Input, locale/bounds and controlled selection requests. See [date-picker](date-picker.md). |
| `Material3DatePickerDialog` | Native Dialog containing the same date picker, with committed `selectedDate`, draft `currentDate` and `acceptedDate(date)`. |
| `Material3TimePicker` | Native Dialog/ComboBox. `selectedHour` (0–23), `selectedMinute` (0–59), `use24Hour`; `acceptedTime(hour, minute)` always uses canonical 24-hour values. |
| `Material3ColorPicker` | Embeddable native Control with HSV/RGB, alpha, gradient channels and QCM trailing-alpha hex (`#RRGGBBAA`). See [color-picker](color-picker.md). |
| `Material3ColorPickerButton` | Native Button with QCM split swatch, tonal colorize glyph and owned color dialog; `color`/`showAlpha`, caller-owned `accepted(color)`. |
| `Material3ColorPickerDialog` | Native Dialog containing the same color editor, with committed `selectedColor`, draft `currentColor` and `acceptedColor(color)`. |
| `Material3Carousel` | Native StyleKit Pane/Button/PageIndicator composition around the pinned QCM keyline engine and public Qt Flickable. Six layouts, horizontal/vertical and mirrored navigation; see [carousel](carousel.md). |

Inline picker inputs stay bound to caller state and emit change requests. The
Dialog variants copy committed values into a
draft; rejecting discards edits; acceptance emits a request, never assigns the
input property. Date selections outside the inclusive range are ignored. An
invalid or inverted range disables confirmation. Invalid initial time likewise
disables confirmation. `selectDate`, `selectTime`, and `selectColor` update only
the draft. Native Dialog open/close/focus and acceptance remain available.

`PickersCarouselGallery.qml` uses `QtQuick.Dialogs.FileDialog` directly with
`OpenFiles` and its native `selectedFiles`/accepted signal. Cancel keeps caller
state. QuickDialogs belongs only to the example; Style does not depend on it.

The remaining picker gaps are the analog clock and platform file-dialog pixel parity.
Color wheel/triangle and year/month/day date navigation are implemented. Carousel
uses QCM snapping; reduced motion finishes an active snap immediately.

Verification: public comparison consumer checks date bounds/cancel/reopen/accept,
time validation/12-hour canonical acceptance, alpha color cancel/accept and native
carousel keyboard/bounded navigation. OS file chooser interaction and native GPU
appearance require the root review gate; offscreen checks do not open the chooser.

Migration: previous dialog uses of `Material3DatePicker` and
`Material3ColorPicker` must use the `Dialog` suffixed types. The old draft and
accept/cancel APIs are preserved there; inline controls need no window or popup.
