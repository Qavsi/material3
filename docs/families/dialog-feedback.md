# Dialogs and feedback

Qt retains Dialog standard buttons, accepted/rejected/reset roles, focus, Escape,
modal overlay and Popup lifetime. Material3Style maps only the real Dialog and
DialogButtonBox slots: solid surfaceContainerHigh, 280px minimum width, 28px
corners, 24px horizontal / 12px vertical padding, and shared level-3 elevation.
Menus and ComboBoxes are unchanged.

Qt 6.12 StyleKit has no Dialog font, header/footer factory or popup transition
slots. The explicit helpers cover those boundaries without replacing Dialog:

```qml
SK.Dialog {
    id: dialog
    standardButtons: SK.Dialog.Ok | SK.Dialog.Cancel
    header: Material3DialogHeader { control: dialog }
    footer: Material3DialogButtonBox { }
    enter: Material3DialogEnterTransition { control: dialog }
    exit: Material3DialogExitTransition { control: dialog }
    SK.Overlay.modal: Material3DialogOverlay { control: dialog }
}
```

Helpers resolve the selected Material3Style themselves. Content and viewport
position/width remain the consumer's responsibility; use dialogMaximumWidth
(560px) as a cap. The header uses native single-line elision with headlineSmall. The footer keeps native
DialogButtonBox roles and delegates to flat native buttons. Reduced motion makes
the opt-in transitions immediate; software keeps the solid surface and omits
hardware shadows. Native standard buttons continue to work without the helpers.

Material3ToolTip is a local Basic.ToolTip specialization because StyleKit has no
ToolTip type or slot. Keep native text/visible/delay/timeout/show/hide API. Plain
uses inverse surface/bodySmall, 4px radius, 4/8px padding and 500ms delay.
A nonempty subhead or actionItem Component selects the rich surface/bodyMedium
recipe with 16px padding and no automatic timeout. Set its parent to the anchor
control. Open rich tooltips explicitly; they accept keyboard focus and dismiss on
Escape/outside press, allowing pointer and keyboard access to their action. The shared attached Basic.ToolTip singleton is intentionally unchanged;
using it would recolor unrelated consumers globally.

Material3Snackbar is a native SK.Popup with text, native Action, showClose and
timeout (5000ms default, <=0 persistent). Its readonly actionControl is the native
Action button for focus or accessibility integration. It announces its message politely on
open, triggers a supplied Action through a native button, closes after the action
or Close, and runs its one-shot timer only while visible. It does not steal focus,
queue messages, own a global manager or depend on QCM/QtToastify. Set parent,
width and position in the consumer. Native popup close() remains available.

Reference: QmlMaterial 0.6.1, 191260585a829ee4ae2c99e6232b7145b5c34474,
qml/popup/Dialog{,Header,ButtonBox}.qml and qml/misc/{PlainToolTip,RichToolTip,SnakeBar}.qml.
These are Qt adaptations, not an assertion of complete QCM behavior parity.
ToolTip/snackbar currently open statically; rich tooltip and snackbar shadows,
stacked snackbar actions, queues, and interrupting an already-running Dialog
transition when reducedMotion changes are outside this slice.

The comparison's public-consumer pass covers light/dark opaque Dialog output,
Escape/rejection/focus return, acceptance, rich-tooltip keyboard focus/dismissal,
snackbar Action activation and timeout.
No private delegate/frame matrix is added. Hardware/UI review remains a separate gate.
