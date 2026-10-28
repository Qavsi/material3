# Carousel

QCM 0.6.1, commit `191260585a829ee4ae2c99e6232b7145b5c34474`, supplies the
keyline/scroll strategies, card masks, aspect-based extents, parallax and snapping.
The private port lives in `Style/internal/carousel`; it uses public Qt APIs, not
QCM's Control/CarouselItem runtime or Qt private Flickable/Scale classes.

```qml
Material3Carousel {
    model: photos // [{ imageUrl: "...", title: "...", aspectRatio: 1.5 }, ...]
    layout: Material3Carousel.MultiBrowse
    showPageIndicator: true
    showNavigationButtons: true
}
```

Layouts: `Uncontained`, `MultiBrowse`, `Hero`, `HeroCenter`, `FullScreen`,
`UncontainedMultiAspect`. `orientation` accepts `Qt.Horizontal`/`Qt.Vertical`;
`mirrored` follows the native Control. `currentIndex`, `count`, `next()` and
`previous()` remain bounded; native arrows and delegate keyboard handling use
visual direction. Shift+wheel navigates non-full-screen layouts; full-screen
accepts wheel without Shift. `itemSnapping` controls release snapping.

`itemExtent`, `itemSpacing`, `contentPadding`, `contentPaddingVertical`,
`initialItem`, `interactive`, `wheelNavigationEnabled` and `reduceMotion` configure
the composition. Defaults come from Theme. Reduced motion settles an active snap
and makes subsequent selection immediate. QCM's free-scroll cubic and spring
snapping remain distinct. Turning snapping off retains native Flickable movement.

The default `Material3CarouselImageDelegate` resolves `imageUrl`/`url`/`source`
and `title`; `aspectRatio` metadata avoids a late decode-driven multi-aspect relayout.
A custom `delegate: Material3CarouselItem { required property var model; ... }`
keeps native Button input, focus and accessibility. Each delegate receives `index`,
`model` (`modelData` is also supplied if declared). Named row fields are read
through `required property var model` and `model.title`/`model.someRole`, rather
than being assigned to same-named native Button properties. Qt 6.12 public
meta-properties do not expose dynamic QML required flags reliably; the adapter
therefore does not guess which inherited properties are model roles.
The wrapper owns item positioning and clipping; custom content belongs in the
item's default content property. `clicked(index)` reports activation without
changing the application's selection or navigation automatically.

Native roving Tab focus exposes the current card and the optional arrows. Images
and title text are decorative children of the named native Button. The image
recipe follows QCM's rectangular photo clipping; it does not add rounded GPU
masking. Qt Image and clipping render on Metal and software without shader fallbacks.
The optional example carries the same ten upstream JPG assets, not the runtime kit.

Migration: `Material3Carousel` previously extended ListView. Common model,
delegate, count, currentIndex and navigation calls remain; ListView-only properties
and attached properties are not part of the new composition. Use the new layout
and extent properties instead. Qt has no native Carousel control to style directly.

Models: integer, JS/variant lists and QAbstractItemModel rows. Live item-model
updates retain persistent-index handling. Destroying the model clears its rows
and pending snap safely. Runtime layout changes retain the selected logical card. Delegates are created when
needed and retained for the model lifetime; this is not an eviction cache for very
large image lists. No Skia or QCM library is linked.
