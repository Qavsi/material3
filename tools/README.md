# Material3 recipe tooling

Copyright (c) 2026 Enes Alp. The source and generated recipe files use the
repository's [MIT License](../LICENSE).

These optional, Node.js-standard-library-only tools maintain the kit's internal
paint recipes. Node.js 22+ is needed **only** to regenerate or verify recipes;
CMake source builds, installed consumers and application runtime use committed
QML JavaScript outputs and do not require Node.js, npm or a token-tool dependency.
No package installation is needed.

From the repository root:

```sh
node tools/recipes/generate.mjs
node tools/recipes/generate.mjs --check
node tools/recipes/material3-format.test.mjs
node tools/recipes/generation.test.mjs
```

The canonical source is [tokens/material3.json](../tokens/material3.json).
Generated files belong in
[src/Qavsi/Material3/Style/internal/recipes](../src/Qavsi/Material3/Style/internal/recipes).
Commit source and regenerated outputs together. Never edit the generated files.
The checker rejects missing, stale and unexpected outputs without rewriting them.
All families are validated before generation writes any output. Format tests cover
missing and unknown leaves, wrong types, non-finite/invalid numbers, geometry
bounds and aliases; generation tests cover stale/missing/extra output, invalid
source without partial writes, missing aliases and cycles.

## Ownership and limits

Recipes own only optical paint dimensions. The kit's own `Material3Theme` owns
semantic colors, typography, shape roles, motion, elevation and target-size policy.
The historical `style.material3` key namespace is kept for stable token aliases;
it does not import Merce, expose a universal theme or make a profile contract.
The recipes do not automatically claim that each corresponding control family is
implemented or conforms to the latest Google Material specification. In particular,
the current common/FAB geometry is aligned to pinned QmlMaterial `229bc3e64ff7`,
while semantic colors, Label Large and state-layer roles remain based on
MDC-Android 1.13.0. The initial Small Filled prototype's 16 px horizontal padding
is historical; the current Small contract uses 24 px on each side. XS/S/M/L/XL
padding is 16/24/24/32/32, with gaps 8/8/8/12/12 and unchanged optical heights.
Geometry alignment does not replace the kit's semantic roles or copy the
reference seed palette. Future families require the same explicit source split. Carousel, Picker and
ScrollBar optical dimensions now use their own generated recipes. Motion, opacity,
semantic shape and minimum input-target policy remain in Theme.

## Source provenance

Extracted from Enes Alp's MIT-licensed
[Merce](https://github.com/tech-alp/Merce/tree/69fed5720b47e4f6150bd42607d1333540bb785e)
checkout:

- `tools/design-tokens/tokens/styles/material3.json`
- `tools/design-tokens/src/merce-style-format.mjs`
- `tools/design-tokens/src/token-value-utils.mjs` (recipe-used exports only)
- `tools/design-tokens/src/style-format.test.mjs`
- `tools/design-tokens/src/validate-style.mjs` (validation behavior adapted into generator)

Original copyright: **Copyright (c) 2026 Enes Alp**, MIT. The extracted namespace
and aliases are retained; descriptions refer to this kit's Theme instead of Merce
profiles. Subsequent common/FAB geometry corrections follow the pinned reference
and are recorded in DESIGN.md and CHANGELOG.md. Generator paths and the required-token error identify
this repository. No Merce Theme manifest, brand registry, profile, Style Dictionary
package or other style's source was copied.

Merce's [Material3 reference notes](https://github.com/tech-alp/Merce/blob/69fed5720b47e4f6150bd42607d1333540bb785e/docs/material3.md)
identify [QmlMaterial](https://github.com/hypengw/QmlMaterial/tree/229bc3e64ff71f1ac88cf73e976637ffbcf7e33c)
as the behavioral/geometry comparison reference. These recipe descriptions retain
that attribution. This extraction copies Merce's recipes and generator, not the
QmlMaterial runtime, control implementations, fonts or other assets. This tooling
covers optical recipes, not a second universal theme. FAB corner/inset and
inline-menu motion/typography tokens belong to the kit's Theme; they are not
runtime dependencies on QmlMaterial. See the current reference split in
[DESIGN.md](../DESIGN.md) and
[THIRD_PARTY_NOTICES.md](../THIRD_PARTY_NOTICES.md).
