# Changelog

## Unreleased

- Add QCM-referenced linear/circular ProgressBar and circular BusyIndicator on native StyleKit controls, Theme motion, visible reduced-motion feedback and software rendering. Opt-in `Material3ProgressContent` supports live indeterminate mode changes around the Qt 6.12.0 deferred-content defect.

- Add QCM dot, count, capped-count and text badges on one native `SK.Label`, with semantic/contrast roles, full-count accessibility, safe zero handling and Theme/software rendering.

- Add Theme-owned native toolbar/search material and Material3AppNavigation:
  responsive rail/drawer, controlled selection, live native search and modeless details.

- Add QCM CheckBox styling on native `SK.CheckBox`: unchecked, checked and indeterminate paths, native tristate input, mixed accessibility state, Theme/ripple/focus and software rendering.

- TextField accessible descriptions preserve caller ownership when native placeholder descriptions are active; comparison checks enable accessibility before loading QML.
- Add native navigation bar, rail-item and primary-tab recipes with package icons, Theme motion and software rendering.
- Add QCM Switch track/thumb/icon styling while retaining native checked state, keyboard input and disabled behavior.
- Add horizontal/vertical Slider and RangeSlider recipes, value labels, stops and read-only input policy; protect cancellation when application callbacks destroy a control.
- Add native RadioButton styling and read-only selection/accessibility policy, retaining exclusive groups and application updates.
- Add Assist, Filter, Input, Suggestion and Embed chip recipes on native buttons, with shared disabled selection and a separate trailing Action.
- Connect reference menus to shared native Actions and packaged icons; correct dark-theme content and remove inherited Text Button hover borders while preserving keyboard focus.

- Native `SK.MenuItem`, butonlarla ortak private ripple katmanına bağlandı:
  Metal shader/software painter, menüye özel %10 press ve per-corner mask.
  Native `SK.Menu` için Theme tabanlı 300/150 ms enter/exit yardımcıları eklendi;
  reduced motion, caller transition binding'leri ve native input sahipliği korunur.

- Ripple now follows QCM's Skia wave/sparkle mathematics on Metal and its
 450ms hold-at40% /350ms release /150+150ms fade sequence. The software painter
 keeps a soft-wave fallback; reduced motion uses static pressed feedback.
 Native button activation, theme bindings and cancellation guards remain owned
 by the existing StyleKit delegate; upstream attribution is installed.

- Material3ButtonContent bağımsız Qavsi.Icons Core'a bağlandı; uygulama seçtiğinde
  Material sağlayıcısı gerçek variable-font glyph çizer. Galerinin FILL için
  SVG seçme koşulları kaldırıldı; ikon ailelerinde checked→filled stil verisine
  taşındı, common/FAB istisnaları ve native QIcon yolu korundu.
- İkon görünümü400/24/GRAD0/CurveRendering olarak Theme'den aktarılır; software
  QtRendering fallback'i, transparent renk ve dikdörtgen slot desteği korunur.

- Material3Theme'e opt-in seed/scheme/contrast tabanlı Material Color Utilities
  eklendi. Mevcut statik palette, rol override'ları, StyleKit, tema ve fallback
  korunur; MCU private source implementation olarak Theme'e gömülür.
- QCM karşılaştırması light/dark'ta aynı #bee7fd / Neutral / contrast0 girdisini
  kullanır. Gerçek MdColorMgr'den12 senaryo referansı ve odaklı renk sözleşme
  testleri eklendi; SDK veya Merce/Runtime bağımlılığı eklenmedi.

- Qt 6.12.0 dinamik reader font başlangıç sınırı variation cache hatasından
  ayrı belgelendi. Yalnız test fixture hazırlığındaki native state geçişiyle
  gerçek Theme font assert'i korunur; SDK veya public tüketici API'si değiştirilmez.
- Karşılaştırma QmlMaterial kaynak kapsamına indirildi: Common XS/S/M, Icon
  XS/S/M/L ve üç S width modu. Kitin beş boyut API'si test-only C++/QML
  fixture'larında korunur; demo'ya ek gizli kontroller eklenmez.
- Standalone icon geometry native StyleKit margins/inset eşlemesine taşındı:
  plate 30/40/56/96/136, target 40/48/64/104/144; XS minimum 40 uyarlaması, diğer
  boyutlarda inset 4/padding 8. Caller width/height binding'leri korunur.
- Icon toggle renkleri ve Outlined checked border 1 kaynakla eşlendi; M checked/
  pressed radius 16/12 oldu. ComparisonMetrics yalnız tüketiciye ait appearance 36
  ve common-size 12 sıra aralığını ayırır; With Badges ayrı aktarım ailesidir.

- Boş font ailesi uygulamanın gerçek fontuna çözülür; buton ölçüsü font alias fallback’ine bırakılmaz.

- Common buton geometrisi pinned QmlMaterial'a göre kalibre edildi: Small yatay
  padding 24, XS–XL padding 16/24/24/32/32 ve gap 8/8/8/12/12; Google M3 renkleri,
  Label Large, dikey padding 10 ve caller binding sahipliği korundu.
- FAB köşeleri Small/Normal/Large 4/16/28 ve Extended 16 oldu. Extended mantıksal
  leading/trailing inset'leri ve RTL optik hizası; Create'de aynı native button
  üzerinde display ile 56 px ikon hedefine daralma/genişleme eklendi.
- Karşılaştırmaya iki/altı eylemli inline FAB menüler eklendi: native trigger,
  clipped scrolling viewport, seçim/Escape ile focus dönüşü, klavye dolaşımı ve
  Theme/reduced-motion uyumlu 400/200/100 ms hareket. Genel Menu skin aktarılmaz;
  Qt 6.12 font sınırı nedeniyle action titleMedium tüketicide Theme'e bağlanır.

- Merce’de geliştirilen common/icon/connected/segmented/split/FAB buton tarifleri,
  bağımsız Material3 Theme/variation/delegate katmanına aktarıldı. Native SK.Button
  korunur; özel içerik için opt-in Material3ButtonContent sağlanır.
- Önceki QmlMaterial Actions karşılaştırma galerisi bağımsız source/installed
  tüketici olarak aktarıldı; Google SVG provenance ve eski aile envanteri korundu.
- Kanonik Material3 geometri JSON’u ve bağımsız isteğe bağlı recipe üretici/
  validation araçları taşındı; Node build/runtime gereksinimi olmadı.

- Bağımsız `Qavsi/material3` deposu, MIT lisansı ve kaynak/installed paketinde
  lisans bildirimleri; runtime, Theme ve kontrol API'leri korunur.

- Qt 6.12 StyleKit üzerinde bağımsız Material3 Small Filled button, typed
  light/dark Theme, source/installed CMake tüketimi ve software renderer desteği.
- Sol ekran yerleşimli QML Preview örneği ve native input/caller binding kontrolleri.
- Native `SK.Button` üzerinde pointer/klavye ripple'ı, yalnız klavye focus'unda dış
  halka ve sistem tercihiyle birleşen `Material3Style.reducedMotion` girdisi.
- Tarifin köşelerine kırpılan internal software painter, alpha birikimi olmadan
  hover/focus'a sönme ve cancel/disable/hide temizliği. 300/180 ms ripple süreleri
  ve 2 px halka/2 px boşluk açık Qt uyarlamalarıdır.
- Örnekte manuel hareket seçimi; ripple, klavye focus'u, azaltılmış hareket ve
  source/installed internal delegate aktarımı için contract check kapsamı.
- Metal'de build-time `.qsb` ripple shader'ı; software/diğer backend'lerde painter
  fallback'i ve ortak native Qt focus halkası. Tema, hareket ve input mantığı
  renderer'dan bağımsız; ShaderTools yalnız source build gereksinimi.
