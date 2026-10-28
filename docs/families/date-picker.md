# Date picker

QmlMaterial 0.6.1 (`1912605`) `qml/picker/DatePicker.qml` and
`example/compositions/DatePickers.qml` supply the composition and geometry reference.
Qt 6.12 StyleKit remains the implementation; no QCM runtime dependency is added.

`Material3DatePicker` is an embeddable native `SK.Pane`. The 360px surface contains
24px header padding and a native DayOfWeekRow/MonthGrid with 40px day targets,
8px gaps and 36px selected circles. Theme owns geometry, colors and typography.
Immutable `datePicker` and `pickerDay` variations own native surfaces and day states.
Single and Range are selection modes; Calendar and Input are display modes.
The header exposes the supporting label, selected-date headline and edit/calendar toggle.
Native buttons retain focus, activation and accessibility. Arrow keys request adjacent
dates, Page Up/Down navigate bounded months. Locale controls calendar ordering, names
and input formatting; `Date.fromLocaleDateString` parses input without a custom parser.

The caller owns `selectedDate`, `rangeStart` and `rangeEnd`. Handle
`selectedDateChangeRequested(date)` and `rangeChangeRequested(start, end)` to commit
requests. A range begins with an invalid end date, then orders the second selected
date. `minimumDate`/`maximumDate` default to 1900-01-01/2100-12-31. Invalid dates and
out-of-bounds requests are ignored. Range input rejects an end before its start.
`selectionValid` reports whether the caller's complete selection is valid.

`Material3DateTextField` is a reusable native TextField for the same bounds and locale
contract. Its text editing belongs to the native field; valid editing completion emits
`selectedDateChangeRequested`. `inputDateFormat` defaults to the locale's short date
format. Invalid input stays visible and provides an accessible validation description.

`Material3DatePickerDialog` wraps the inline picker. It preserves `selectedDate`,
`currentDate`, `minimumDate`, `maximumDate`, `selectDate`, `month`, `year`,
`shiftMonth`, `isSelectable`, `dayNumber`, `open`, `reject`, `accept` and `acceptedDate`.
The dialog owns only a draft. Reject preserves caller state; reopen restores the committed
date; accept emits one valid date. The former `Material3DatePicker` dialog usage must
rename its type to `Material3DatePickerDialog`.

The comparison Date picker section demonstrates input, Single/Range and inline calendar.
Its standalone date field is visible only in Single mode, matching QCM.
Input mode focuses the native Date/Start date editor; Range adds End date.
The existing TextField floating captions own these labels, and TextFieldSupport
shows the locale date format below each editor. No alternate field style is added.
The input calendar glyph opens the separate dialog; there is no extra dialog trigger. `checkInlineDatePicker` verifies public bounded requests and
caller-owned binding updates. Existing dialog acceptance/cancellation checks remain.
Rendering uses existing native materials, so software rendering and reduced motion
retain the same behavior. A dedicated range dialog is outside this implementation.

Calendar dialogs reuse the internal date-input editor without another calendar
launcher. This shares parsing/validation while preventing recursive dialog creation.

The month header uses the existing native `ghost` text-button variation with its disclosure icon.
It toggles the inline year view. Year selection shows the twelve localized months;
month selection returns to days. Year/month navigation never emits date/range
selection requests. The first/last allowed years and partial-month enabled states
come from the date bounds. Years use a virtualized 3-column GridView (312px,
52px cells); months use 3 columns with 78px cells. `pickerNavigationItem` maps
transparent/selected-tonal, disabled and feedback states in the StyleKit layer.
Calendar arrows, PageUp/Down and Home/End move focus; Enter/Space select.
The calendar body stays 312px tall across all three views.
