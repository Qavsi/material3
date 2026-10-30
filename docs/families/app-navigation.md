# Application navigation

QCM 0.6.1 reference: `191260585a829ee4ae2c99e6232b7145b5c34474`,
`qml/navigation/{FloatingToolbar,NavigationRail,Drawer,DrawerItem}.qml`,
`qml/input/SearchBar.qml`, `src/style/search_bar_state.cpp`,
`qml/popup/SideSheet.qml` and `include/qml_material/token/token.hpp`.
This is a StyleKit adaptation; QCM is not linked or vendored.

## Native consumption

`SK.ToolBar` uses the 64px toolbar surface, 8px padding and pill geometry.
`SK.TextField { SK.StyleVariation.variations: ["searchField"] }` supplies the
56px search surface and native editable text. `TextFieldSupport.leadingIcon`
and the existing affix/accessibility machinery remain available. Native input,
validation, selection, fonts and explicit caller bindings remain in Qt.
Search uses BodyLarge and surfaceContainerHighest, with onSurface ink and
onSurfaceVariant accessory ink. The placeholder remains native rather than
floating. Native placeholder ink uses surfaceVariantForeground while explicit
caller placeholderTextColor remains owned by the caller. There is no synthetic
editor or replacement input router.

`navigationDestination` styles native horizontal checkable Buttons with a 56px
pill, 16/24px optical padding and secondaryContainer selection. The existing
`navigationRailCollapsed` recipe and `Material3NavigationContent` remain intact.
Each native instance receives one immutable variation list. Destination and rail
recipes map the variation's generic control fields: Qt 6.12 initially left the
button-specific nested fields at the base Filled mapping until a Theme reset.
The recipes are still used only by native Buttons.

## Responsive composition

`Material3AppNavigation` is the one exported composition. It owns only presentation
and uses the caller's Theme, model and content. It does not install a window,
platform runtime or global Controls style.

```qml
Material3AppNavigation {
    id: shell
    anchors.fill: parent
    title: qsTr("Library")
    model: [
        { text: qsTr("Explore"), iconName: "material:explore" },
        { text: qsTr("Settings"), iconName: "material:settings" }
    ]
    currentIndex: applicationState.selectedDestination
    onActivated: index => applicationState.selectedDestination = index
    onSearchAccepted: text => applicationState.submitSearch(text)
    Text { text: shell.searchText }
}
```

Use an id to bind content to `shell.currentIndex` or `shell.searchText` in real
applications. The default `pageData` slot fills the body beside the rail.
The model is a JS array of objects with required `text` and optional `iconName`
and `enabled` roles. Reassign the array to publish model changes. Models with
sections, arbitrary delegates and proxy models are outside this small API.
`currentIndex` is controlled by the caller. `activated(int)` requests a selection;
update the caller model in that handler, as above. The shell never assigns this
property or removes its binding. Native destinations are non-checkable Buttons:
`checked` and `Accessible.selected` reflect the caller selection without native
toggle writes. Resizing never changes selection. Focused destinations follow the replacement rail item;
search and page focus are preserved. The small native rail/destination sets remain
alive while hidden: destroying their loading contexts during a responsive change
left stale StyleKit delegate contexts on the next live Theme reset in Qt 6.12.
Visibility changes preserve those contexts and keep each variation list immutable.
Invalid indexes display no selection; the shell does not silently rewrite them.

The available composition width drives readonly `navigationMode`:

- Below 600px: menu button and modal native Drawer.
- 600–1199px: 96px icon rail, with native tooltips and accessible labels.
- 1200px and up: 220px rail with horizontal labelled destinations.

Theme defaults to the selected Material3Style.tokens; an explicit tokens override is supported.
Reduced motion includes the selected Style policy, OS preference and transitions flag.
Theme owns all dimensions, breakpoints and motion. The default expanded width is
QCM's 220px; the thresholds use its compact/large classes against the local available
width, so nesting does not require window/platform APIs. The collapsed recipe
keeps its existing desktop pointer target and does not claim kiosk sizing.

`searchText` aliases `searchField.text`; `searchField` exposes the native SK.TextField
for caller font, input hints, validators and text bindings. `searchPlaceholderText`
sets its placeholder. `openNavigation()` opens only compact navigation.
`navigationDrawer` is the public native Drawer; Escape, outside press and native
gestures dismiss it. Activation closes it. A mode change closes the obsolete drawer.

`sideSheetContent: Component { ... }` enables the toolbar Details action.
`openSideSheet()` opens a nonmodal native Drawer on the trailing edge; `sideSheet`
exposes it for normal native open/close/visible APIs. The content Loader is active
only while visible. Escape, outside press and the Close details action dismiss it.
Underlying page controls remain interactive. Both sheets mirror with native RTL.
The optional details drawer remains interactive: Qt documents nonmodal plus
noninteractive Drawer as a persistent, non-closable panel
([Qt6.12 Drawer](https://doc.qt.io/qt-6/qml-qtquick-controls-drawer.html)).

The exported `Material3Drawer` shares this native material/motion skin with the
comparison appearance panel. It requires explicit `Material3Theme tokens`, keeps
native Popup/Drawer APIs, and combines padding with Qt SafeArea margins.
Its `reducedMotion` input, OS preference and parent StyleKit transitions control
the motion; it creates no StyleKit attached context on the Basic.Drawer QObject.

Qt 6.12 StyleKit has no Drawer type or style slot. Only the implementation imports
`QtQuick.Controls.Basic` for native Drawer, with Theme-owned surfaces and scrim;
public controls continue using StyleKit. Modal navigation uses a 0.32 scrim;
nonmodal details has no dimming. Position transitions are a 300ms OutCubic Qt
adaptation. Reduced motion, StyleKit transitions, hidden/minimized windows disable
animation. Rectangles render directly on software; no shader, layer or SDK patch
is introduced. QCM's spring/drag reveal and SearchView overlay are not claimed.

## Verification

`AppNavigationGallery.qml` demonstrates native toolbar/search, caller content,
selection and the nonmodal details sheet. The consumer check changes composition
width through all three modes, retains selection, edits native search and closes
the drawer and side sheet with Escape. It captures a native destination to check
selected-only fill and preserves explicit placeholder ink across state changes.
The same scenario changes Theme while the compact drawer is open after resizing.
This test uses the shell's public native aliases and no
private delegate selectors. Source and relocated installed consumers use the same
exported module.
