# Pickers and carousel

QCM 0.6.1 (`191260585a829ee4ae2c99e6232b7145b5c34474`) picker and
uncontained-carousel references, adapted to Qt 6.12 native controls. No QCM runtime.

| Public type | Contract |
|---|---|
| `Material3DatePicker` | Native StyleKit Dialog, `selectedDate`, inclusive `minimumDate`/`maximumDate`, locale-aware Qt MonthGrid. `currentDate` is the draft; `acceptedDate(date)` requests a caller update. |
| `Material3TimePicker` | Native Dialog/ComboBox. `selectedHour` (0–23), `selectedMinute` (0–59), `use24Hour`; `acceptedTime(hour, minute)` always uses canonical 24-hour values. |
| `Material3ColorPicker` | Native Dialog, RGB/alpha sliders and validated Qt hex input (`#RRGGBB` or `#AARRGGBB`). `selectedColor`, draft `currentColor`, `acceptedColor(color)`. |
| `Material3Carousel` | Native horizontal ListView with inherited `model`, `delegate`, `currentIndex`, `count`; `next()`/`previous()`, keyboard arrows, bounded item snapping. Caller owns delegate dimensions/content. |

Picker inputs stay bound to caller state. Opening copies committed values into a
draft; rejecting discards edits; acceptance emits a request, never assigns the
input property. Date selections outside the inclusive range are ignored. An
invalid or inverted range disables confirmation. Invalid initial time likewise
disables confirmation. `selectDate`, `selectTime`, and `selectColor` update only
the draft. Native Dialog open/close/focus and acceptance remain available.

`PickersCarouselGallery.qml` uses `QtQuick.Dialogs.FileDialog` directly with
`OpenFiles` and its native `selectedFiles`/accepted signal. Cancel keeps caller
state. QuickDialogs belongs only to the example; Style does not depend on it.

This slice supports the uncontained equal-width carousel recipe only. It does
not claim QCM's six keyline modes, wheel/triangle color selection, analog clock,
calendar text-entry mode, or platform file-dialog pixel parity. Carousel selection
moves immediately, so reduced motion never leaves a selection animation active.

Verification: public comparison consumer checks date bounds/cancel/reopen/accept,
time validation/12-hour canonical acceptance, alpha color cancel/accept and native
carousel keyboard/bounded navigation. OS file chooser interaction and native GPU
appearance require the root review gate; offscreen checks do not open the chooser.
