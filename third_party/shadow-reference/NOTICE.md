# QCM shadow renderer reference

The private Material3 analytic and Gaussian-mask shadow primitives adapt QmlMaterial
commit `229bc3e64ff71f1ac88cf73e976637ffbcf7e33c` (MIT, copyright 2024-2025 hypengw).
The pinned input files and SHA-256 hashes are recorded in `sources.json`.

QCM describes the ambient/spot parameter calculation as an independent
re-expression of Skia's analytic shadow model. Its source references
Skia CanvasKit 0.38.2 and Flutter 3.24.3. The Skia BSD-3-Clause license is carried
alongside the QCM MIT license. Skia's license text was verified against its
upstream Gitiles LICENSE at commit 79633dd54c6fa17b311dbb94fd3390394edb0bac:
https://skia.googlesource.com/skia.git/+/79633dd54c6fa17b311dbb94fd3390394edb0bac/LICENSE
This license-source commit is not a claim that QCM's shadow math was taken
from that exact Skia revision.

No Skia engine, Skia headers, Flutter engine, or QCM control library is linked.
The port uses Qt public QQuickItem/QSGGeometry/QSGMaterial/QSGTexture APIs.
The generated qsb shader resources are compiled by Qt ShaderTools.

## Adaptations

- Keep the uniform-corner ambient/spot mesh and 128-sample falloff calculations.
- Keep the unequal-corner Gaussian Outer mask: 128-sample linear CDF, 4x4
  subpixel cutout coverage, separable Gaussian convolution, half-pixel
  sigma/radius quantization, four corner textures, and item-local nine-patch halo.
- Supply ambient/spot opacity, light direction, and light-radius ratio from the
  kit rather than hardcoding Material policy in the drawing primitive.
- Keep each window's falloff texture shared while scene graph materials exist;
  weak cache bookkeeping owns no GPU resource. The final material deletes the
  texture on its render thread. No GUI-thread destruction callback deletes a
  texture, and no owning global cache survives scene graph invalidation.
- Use normal linear native Item opacity rather than QCM's opacity-cubed uniform.
  QCM analytic also discards input color alpha. Preserve it and premultiply
  tinted vertex RGB by alpha in both paths, as required by Qt source-over
  blending. Black shadows at full Item opacity preserve the QCM visual model;
  colored/partial-opacity analytic output deliberately corrects upstream behavior.
- Validate finite inputs, clamp radii/opacity, reject zero-sized or invalid
  geometry, and avoid creating a custom-material node on the software backend.
- Select the analytic path for uniform corners and the Gaussian Outer path
  for unequal corners on hardware. Software suppresses GPU shadows. No
  RectangularShadow approximation remains in the adapter.
- Bound Gaussian tiles to 2048 pixels per side and 64M convolution taps.
  The render-thread cache retains at most 16 MiB of alpha8 payload; live
  material references survive eviction. These guards do not change ordinary
  Material3 inputs. Normal/Solid/Inner mask modes are not exposed by this
  private elevation primitive because the QCM elevation adapter uses Outer.

Upstream geometry notes and license notices remain authoritative; this is
an internal port, not a declaration of a new public Qavsi shadow API.
