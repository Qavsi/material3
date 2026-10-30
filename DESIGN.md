# Qavsi Material3 — StyleKit

Qt 6.12 tabanlı bağımsız, aşamalı Material3 StyleKit kiti. Semantik renkler ve typografi Google
Material 3 kaynaklarından, bu tur kullanıcı isteğiyle eşlenen Qt buton geometrisi
ve FAB davranışları pinned QmlMaterial referansından gelir. Görsel sözleşme bu
pakete aittir; Merce Theme, Runtime, ortak palette veya kontrol sarmalayıcısı yoktur.

## Kaynak

Renk çiftleri, Label Large ve state-layer referansı Google Material 3 / MDC-Android
**1.13.0**, commit `84c0e6d6d493fcf176d2099683245b78afbeb78d`:

- [Small/filled token'ları](https://github.com/material-components/material-components-android/blob/84c0e6d6d493fcf176d2099683245b78afbeb78d/lib/java/com/google/android/material/button/res/values/tokens.xml)
- [Non-dynamic light/dark renk rolleri ve palette](https://github.com/material-components/material-components-android/blob/84c0e6d6d493fcf176d2099683245b78afbeb78d/lib/java/com/google/android/material/color/res/values/tokens.xml)
- [Label Large](https://github.com/material-components/material-components-android/blob/84c0e6d6d493fcf176d2099683245b78afbeb78d/lib/java/com/google/android/material/typography/res/values/tokens.xml)
- [State-layer opacity](https://github.com/material-components/material-components-android/blob/84c0e6d6d493fcf176d2099683245b78afbeb78d/lib/java/com/google/android/material/resources/res/values/tokens.xml)
- [Filled ripple renk/durum seçimi](https://github.com/material-components/material-components-android/blob/84c0e6d6d493fcf176d2099683245b78afbeb78d/lib/java/com/google/android/material/color/res/color/m3_button_ripple_color_selector.xml)
- [Ripple alpha eşlemesi](https://github.com/material-components/material-components-android/blob/84c0e6d6d493fcf176d2099683245b78afbeb78d/lib/java/com/google/android/material/resources/res/values/dimens.xml)
- [Android button ripple implementasyonu](https://github.com/material-components/material-components-android/blob/84c0e6d6d493fcf176d2099683245b78afbeb78d/lib/java/com/google/android/material/button/MaterialButtonHelper.java)

Google token dosyalarının lisansı Apache-2.0'dır. Bu belge Google tarafından
yayımlanmış veya onaylanmış bir DESIGN.md değildir. Android widget implementasyonu,
Compose ve Expressive'nin bütün davranışları bu prototipin destek beyanı değildir.

Qt geometri/davranış karşılaştırması
[QmlMaterial `229bc3e64ff71f1ac88cf73e976637ffbcf7e33c`](https://github.com/hypengw/QmlMaterial/tree/229bc3e64ff71f1ac88cf73e976637ffbcf7e33c)
olarak sabittir. Aşağıdaki common/FAB ölçüleri ve inline FAB menü davranışları bu
referansa göre kalibre edilir; MDC-Android'in resmi ölçüleri diye sunulmaz.
Kitin varsayılan mor palette'i korunur. Karşılaştırma uygulaması dinamik renkleri
açıp QCM'nin seed/scheme girdilerini açıkça eşitler; bu tercih kitin varsayılanı değildir.

## Sahiplik

- `Material3Theme`: typed renk çiftleri, Small ölçüleri, Label Large QFont ve
  state-layer sonuçları. Hex renkler yalnız burada bulunur.
- `Material3Style`: doğrudan `SK.Style`; Light/Dark seçimi, family font eşlemesi ve
  azaltılmış hareket politikası.
- Internal `Material3ControlTheme`: direct `SK.Theme` composition root for native control mappings and theme-local family variations.
- Internal `Material3TextFieldVariations`: field recipe registration, separate from base control mappings.
- Internal `SmallButtonDelegate` / `SmallButtonParameters`: background factory ve
  `DelegateStyle.data` üzerinden typed token/hareket aktarımı.
- Internal `SmallButtonBackground`: pasif pointer gözlemi, ortak ripple durumu,
  backend seçimi ve native Qt focus halkası. Metal'de shader, software'da
  `MaterialButtonFeedback` painter çizimi. Input, focus ve activation native
  `SK.Button` üzerinde kalır.
- Tüketici: metin, olaylar, uygulama durumu, yerleşim ve style seçimi.

`lightTokens` / `darkTokens` kendi `Material3Theme` nesneleriyle değiştirilebilir.
Renk ve `fontFamily` girdileri typed binding'dir; uygulamanın `font`, ölçü, padding
ve spacing bağlarına imperatif yazılmaz. Sıfır değerleri geçerli override'dır.

Composition root `pragma ComponentBehavior: Bound` kullanır. Yalnız internal
`SmallButtonDelegate` factory'si unbound `Component` olarak tutulur: Qt 6.12
StyleKit delegate'i kontrolün bağlamında oluşturur. Root id'sini bu bağlama
taşımak yerine typed `SmallButtonParameters`, `DelegateStyle.data` ile aktarılır.

## Tarif ve Qt uyarlaması

| Alan | Güncel Small Filled |
|---|---|
| Kullanım | Normal, text-only `SK.Button`; default Small Filled |
| Container | 40 logical px minimum paint yüksekliği; idle radius 20, pressed radius 8; elevation 0 |
| Padding | QmlMaterial Small leading/trailing 24; Qt dikey padding 10 |
| Typography | Label Large 14 logical px, Medium/500, tracking 0.1 |
| Light | primary `#6750a4`, foreground `#ffffff`, surface `#fef7ff` |
| Dark | primary `#d0bcff`, foreground `#381e72`, surface `#141218` |
| Hover | primary üstünde foreground %8 state layer |
| Focus | klavye `visualFocus` için foreground %10 state layer |
| Pressed / ripple | QCM foreground %12 base + %12 shader layer; pointer konumundan, klavyede merkezden |
| Ripple hareketi | QCM:450ms OutCubic→0.4 hold;350ms OutCubic→1 release;150+150ms fade |
| Focus ring | Qt erişilebilirlik uyarlaması: primary, 2 logical px çizgi, 2 px dış boşluk |
| Disabled | on-surface %12 container / %38 label; native input kapısı |

**Açık sapmalar:** Label Large'ın resmi line-height'ı 20'dir; Qt'nin native
IconLabel/QFont satır kutusu kullanılır, exact line-height zorlanmaz. QFont 0.1
tracking'i bu SDK'da 0.09375'e yuvarlar. Default font platform fontudur; Roboto
paketlenmez. Boş `fontFamily`, `Application.font.family` üzerinden çözülür;
Qt.font() içine boş family geçirmek uygulama fontunu miras almaz. Caller kurulu bir fontu `fontFamily` ile seçebilir.

İlk Small prototipindeki 16 px yatay padding tarihsel baseline'dır; güncel
sözleşme, ikonlu ve text-only butonlarda 24/24 px kullanır. Önceki
[evidence/VERIFICATION.md](evidence/VERIFICATION.md) bu eski koşuyu korur.
40 px paint ve 10 px dikey Qt padding masaüstü uyarlamasıdır; Android widget'in
inset/minimum alanını aynen kopyalamaz. Bağımsız 48 px touch alanı henüz
uygulanmadı; kiosk/touch uygunluğu iddia edilmez. Metin büyüyünce implicitHeight
büyüyebilir; caller açık height verirse clipping sorumluluğu tüketicidedir.

### Common geometrisi

Ölçüler logical px'dir. Common idle köşeleri paint yüksekliğinin yarısıdır;
checked bu round şekli korur. XS'nin native hedefi 40 px kalırken 32 px yüzey
hedef içinde ortalanır; bütün common boyutlarda minimum genişlik 64'tür.

| Boyut | Paint yüksekliği | Leading / trailing | İçerik aralığı | İkon | Pressed radius |
|---|---|---|---|---|---|
| XS | 32 | 16 / 16 | 8 | 18 | 8 |
| S (default) | 40 | 24 / 24 | 8 | 18 | 8 |
| M | 48 | 24 / 24 | 8 | 24 | 12 |
| L | 56 | 32 / 32 | 12 | 24 | 16 |
| XL | 72 | 32 / 32 | 12 | 32 | 16 |

Bu boyutlar Label Large 14/500 ölçeğini değiştirmez. Common text-only ve
ikon/metin düzeni aynı yatay insets'i kullanır; genişlik doğal metin ölçüsünden
türetilir, sabit metin genişliği uygulanmaz.

### Standalone icon sözleşmesi

The reference gallery shows Common XS/S/M, Icon XS/S/M/L and S
Narrow/Default/Wide examples. All Common and Icon XS–XL roles remain public.
Exhaustive size/shape probes are outside the routine gate; public behavior and
caller bindings follow [TESTING.md](TESTING.md). No hidden size probes are added
to the gallery.

Standalone icon geometri eşlemesi Qt 6.12'nin kendi `Button.qml` sözleşmesini
kullanır: `background.margins` native `leftInset/rightInset/topInset/bottomInset`
alanlarına gider. Theme `iconButtonInset: 4` ve `iconButtonPadding: 8` sunar;
kontrol içi spacing 0'dır. Native implicit boyutlar Qt tarafından çözülür;
normal QML `implicitWidth/implicitHeight` alanları yeniden yazılmaz.

| Icon boyutu | Native hedef | Optical plate | Her kenarda inset | İkon | Checked / pressed radius |
|---|---|---|---|---|---|
| XS | 40 | 30 | 5 | 22 | 12 / 8 |
| S | 48 | 40 | 4 | 24 | 12 / 8 |
| M | 64 | 56 | 4 | 24 | 16 / 12 |
| L | 104 | 96 | 4 | 32 | 28 / 16 |
| XL | 144 | 136 | 4 | 40 | 28 / 16 |

XS için referans dış hedefi 38'dir; Qavsi minimum 40 politikası inset'i 5 yapar.
Diğer ölçüler referansın 4 px dış inset'ini izler. Caller açık width/height
bağlarsa background native inset'lerin içinde büyür: S için 100×80 hedef,
92×72 plate üretir. Width/height binding'leri canlı kalır; plate sabit 40'a
zorlanmaz. Narrow/Default/Wide S plate genişlikleri 32/40/52, dış genişlikleri
40/48/60'tır; yükseklikler 48 hedef /40 plate olarak kalır.

| Icon appearance | Unchecked container / ink | Checked container / ink |
|---|---|---|
| Standard | transparent / surfaceVariantForeground | transparent / primary |
| Filled checkable | surfaceContainerHighest / primary | primary / primaryForeground |
| Tonal checkable | surfaceContainerHighest / surfaceVariantForeground | secondaryContainer / secondaryContainerForeground |
| Outlined | transparent / surfaceVariantForeground | inverseSurface / inverseSurfaceForeground |

Galeride toggle Filled/Tonal için `iconFilledCheckable` / `iconTonalCheckable`
rolleri seçilir; normal action rolleri ayrıca korunur. Outlined checked durumda
1 px border'ı korur. Disabled checked Standard/Outlined container transparent,
Filled/Tonal container `disabledContainer`, bütün disabled ink `disabledLabel`
olur. M checked 16 / pressed 12 köşeleri Small'ın 12/8 değerlerine düşürülmez.

Dış galeri yerleşimi `examples/qmlmaterial-comparison/ComparisonMetrics.qml`
sahipliğindedir: `iconAppearanceSpacing: 36`, `commonSizeSpacing: 12`. Bunlar
buton içi spacing veya kit Theme token'ı değildir; ortak runtime eklenmez.
Referanstaki With Badges bölümü ayrı Badge ailesinde dot/count/capped/text
olarak aktarılır; aşağıdaki Badge sözleşmesine bakın.

### FAB geometrisi

| FAB | Yükseklik | Corner radius | İkon |
|---|---|---|---|
| Small | 40 | 4 | 24 |
| Normal | 56 | 16 | 24 |
| Large | 96 | 28 | 36 |
| Extended | 56 | 16 | 24 |

FAB köşeleri idle/hover/pressed/checked durumlarında aynı kalır. Extended minimum
genişliği 80'dir: ikon varsa leading 16, text-only ise leading 20; trailing 20,
ikon/metin aralığı 12'dir. Leading/trailing mantıksaldır: native `mirrored` ile
RTL'de ikon sırası ve asimetrik optik offset yönü çevrilir; collapsed ikon ortalanır.
İçerik genişliği glyph yuvarlama rezervini ve iki gerçek inset'i içerir.
Varsayılan native FAB padding'i 0'dır; bu optik inset'ler ve animated extent içerik
helper'ında uygulanır. Doğrulama native padding alanını değil, gerçek çizilmiş
ikon/metin konumunu ve genişliğini ölçer.

Demo'daki Create aynı `SK.Button` üzerinde native `display` değerini
`TextBesideIcon` / `IconOnly` arasında değiştirir; extended genişlikten 56 px ikon
hedefine geçer. Metin ve `Accessible.name: text` bağı korunur; variation listesi
sabit kalır. Bu davranış dinamik variation cache hatasına SDK yaması değildir.

### Inline FAB menüler

Karşılaştırma tüketicisinde referans gibi 280 px alanda iki action stack vardır:
iki satırlık stack başlangıçta açık, altı satırlık stack kapalıdır. Bunlar native
checkable `SK.Button` trigger, native action butonları ve clipped `Flickable`
bileşimidir; genel `SK.Menu`/Popup skin aktarımı değildir. Eylem seçimi veya Escape
stack'i kapatıp focus'u trigger'a döndürür. Up/Down ve Tab/Backtab eylemler arasında
geçer; uzun listede klavye odağı viewport'u kaydırır. Kapanış başlar başlamaz
input gate kapanır; görünür çıkış animasyonunun bitmesi beklenmez.

`Material3Theme` menü sequence/spatial/effect sürelerini 400/200/100 ms olarak
sunar. Bunlar pinned QmlMaterial referansından alınan Qt hareket uyarlamalarıdır;
resmi Google motion token'ı veya ripple'ın450/350/150ms süreleriyle aynı tarif
sayılmaz. Tema, `effectiveReducedMotion` ve software painter yolu korunur;
azaltılmış harekette reveal, genişlik ve opacity anlık son değerine gider.

Qt 6.12 `StyleVariation` içinde `fonts` alanı yoktur. Menü action typografisi
bu yüzden tüketicide `font: root.tokens.titleMedium` ile açıkça bağlanır
(16 px / 500); aynı kitin Theme verisidir. Genel font/padding binding'lerine
imperatif yazılmaz, demo'ya style koşulu eklenmez, Qt SDK'sı değiştirilmez.

Ripple artık QCM'nin iki katmanını source-over birleştirir: press base %12,
shader %12. Eski tek-alpha %10 yaklaşımı bu kullanıcı isteğiyle değiştirilmiştir.
Hover %8 ve keyboard focus %10 durumu korunur; release sırasında base bu duruma
150ms'de döner, ardından shader150ms'de söner. İki alpha doğrudan toplanmaz;
premultiplied source-over uygulanır. Bu QCM/Skia davranışıdır, MDC button'ın
native RippleDrawable implementasyonunu kopyaladığımız iddia edilmez.

Klavye halkası yalnız enabled ve `visualFocus` durumunda görünür; mouse/touch
focus'u halka üretmez. Qt'nin [visualFocus sözleşmesi](https://doc.qt.io/qt-6/qml-qtquick-controls-control.html#visualFocus-prop)
Tab, Backtab ve shortcut focus nedenlerini kapsar. Dış halka layout ölçüsünü
büyütmez; kırpan bir üst öğe kullanılıyorsa görünmesi için yer bırakılmalıdır.
Checked native durum olarak korunur; buton ailesinin seçili şekil ve renk
tarifleri aşağıdaki variation sözleşmesine aittir.

`Material3Style.reducedMotion` typed bool ve varsayılan `false` değerindedir.
`effectiveReducedMotion`, bu girdi ile
`Application.styleHints.accessibility.motionPreference === Qt.MotionPreference.ReducedMotion`
sonucunun OR birleşimidir. Sistem azaltılmış hareket istiyorsa caller `false`
vererek animasyonu açamaz. [Qt 6.12 public motionPreference](https://doc.qt.io/qt-6/qaccessibilityhints.html#motionPreference-prop)
değişiklikleri izlenir; hareket azaltıldığında ripple genişlemesi/sönmesi ve noise durur,
pressed state %12 base ile anlık/statik kalır. Disable, hide ve cancel yolları aktif ripple'ı
temizler; tercih aktif press sırasında da değiştirilebilir.

## Fallback ve kapsam sınırı

Native Qt label ve internal StyleKit background delegate kullanılır. Pasif
`PointHandler` press konumunu gözler; event ownership native button'da kalır.
Metal'de tek `ShaderEffect`, analitik yuvarlak maske ve ripple'ı doğrudan çizer;
offscreen texture veya `ShaderEffectSource` yoktur. Software ve diğer backend'lerde
private C++ `MaterialButtonFeedback`, public `QQuickPaintedItem::Image` yolunda
`QPainter` kullanır. Shader yükleme hatası da painter'a düşer ve hata loglanır.
Focus halkası her iki yolda aynı native `Rectangle` ile çizilir. Renderer seçimi
kit içinde gerçek `GraphicsInfo.api` değerini izler; tüketici koşulu gerekmez.

`qt_add_shaders` GLSL kaynağını build sırasında `.qsb` haline getirir ve Style
library'sine gömer. Qt ShaderTools yalnız kitin source build bağımlılığıdır;
installed tüketici runtime shader derlemez ve ShaderTools istemez. Private Qt
C++ target'ı, blur, ButtonSupport yoktur. Paketli ikon çizimi bağımsız Qavsi.Icons Core adaptörüne bağlanır. Theme, aşağıda
belirtilen MCU C++ alt kümesini private implementation olarak içerir.

Painter'ın Image yolu Metal'de CPU çizimi ve texture upload maliyeti getirir.
Shader aynı geometri, premultiplied renk, alpha çözümlemesi ve hareket girdilerini
kullanır; iki renderer'ın kenar antialiasing'i piksel düzeyinde farklılaşabilir.
Ölçüm aynı Metal backend'inde yapılır; software FPS'i Metal ile kıyaslanmaz.
Benchmark sonuç ve sınırları [doğrulama raporunda](evidence/VERIFICATION.md) tutulur.
StyleKit transitions örnekte kapalıdır; ripple'ın kendi animasyonu hareket
politikasına bağlıdır. Source/installed tüketim sözleşmesi aynıdır; internal QML
factory/data dosyaları ve C++ registration metadata'sı paketle taşınır.

## Aktarılan aile sözleşmesi

- Önceki Merce Material3 kaynaklarındaki common/icon/connected/segmented/split/FAB
  tarifleri kullanılır. MerceStyle/Theme/MButton veya genel Runtime miras alınmaz.
- Theme’de Google M3 primary/secondary ve container foreground çiftleri, tonal
  surface ve outline rolleri vardır. Semantik palette referansı MDC-Android
  1.13.0’dır; geometri/davranış kaynağı yukarıdaki pinned QmlMaterial’dır.
  Uygulamanın arbitrary brand/profile palette’i M3 standardı sayılmaz.
- Variation kayıtları Theme içindedir. Öncelik: Theme variation > Theme direct >
  Style variation > Style direct; listede ilk isim kazanır. Recipe/size rolü
  appearance’dan önce verilir. Dinamik liste değişimi Qt cache düzeltmesi değildir.
- Optik Small/XS/M/L/XL yükseklikleri 40/32/48/56/72; native masaüstü hedefinin
  alt sınırı 40’tır. XS optik yüzey daha büyük hedef içinde ortalanır. Bunlar 48 px
  kiosk/touch uygunluğu iddiası değildir. Caller açık ölçüleri kendi sahipliğindedir.
- Content factory otomatik değildir. Public `Material3ButtonContent` yalnız
  `SK.Button.contentItem` için opt-in delegate’tir. Recipe icon size, native
  text/display/RTL, segmented checkmark, split highlighted rotation/offset ve
  FAB expanded içerik buradadır. Color/geometry variation’a ait; seçim ve menu
  açma uygulamanın native ButtonGroup/checked/Menu davranışıdır.
- Helper `QtQuick.Controls.impl.IconLabel`’a bağımlıdır; bu SDK’nın SK.Button’ıyla
  aynı QIcon yoludur, private C++ Qt target’ı değildir. Qt sürüm yükseltmesinde
  source/installed testleri zorunludur. `iconWidth/iconHeight` explicit override’dır;
  helper kontrolün enabled/font/icon/geometry binding’lerini değiştirmez.
- Tüm corner mask/ripple/focus girdileri gerçek resolved variation foreground’u
  ve dört corner radius’u izler. Metal shader, software painter ve reduced motion
  aynı interaction state’i kullanır. Software’da elevation shadow devre dışıdır;
  dolgu, outline, metin ve focus okunaklı kalır.
- `tokens/material3.json` Merce’den taşınmış kanonik geometri kaynağıdır;
  üretilmiş JS elle değiştirilmez. İsteğe bağlı Node araçları build bağımlılığı olmaz.
- QmlMaterial karşılaştırmasının eski baseline ve Actions sırası korunur. Demo
  ikonları Qavsi.Icons.Material üzerinden gerçek paketli Material Symbols adlarıdır;
  font ve katalog kitte kopyalanmaz.

**Remaining scope:** morphing/wavy loading, the complete responsive navigation shell and
selection controls beyond the families documented below remain outside this slice. Split menü referans gibi
sahne içi Popup.Item ve Qt fallback’ini kullanır.
İki inline FAB action stack bu karşılaştırmaya dahildir; bütün Expressive FAB
menu ailesinin eşliği iddia edilmez. Grouped neighbor-width redistribution ve font FILL geçişi artık native
opt-in helper'larla sağlanır; [hareket/Chips sözleşmesi](docs/families/button-motion-chips.md). Karşılaştırmada StyleKit transition seçimi effectiveReducedMotion’a bağlıdır;
ripple ve helper’ın kendi motion politikası aynı tercihi izler. Small doğrulama
örneği için global StyleKit transition’ları kapalı kalır. Tam QmlMaterial veya güncel Expressive
eşliği iddia edilmez. Qt SDK’sı değiştirilmez.

Kabul kanıtı: [evidence/VERIFICATION.md](evidence/VERIFICATION.md).

### Progress / BusyIndicator

Native `SK.ProgressBar` has a 4 px rounded linear recipe, 4 px track gap and
endpoint dot. `progressCircular` selects the QCM 40 px outer / 32 px path /
4 px stroke circular recipe. Native `SK.BusyIndicator` uses the same circular
advance motion and retains `running`. Primary/secondary-container and
transparent circular track are semantic Theme roles; optical values come from
the generated Progress recipe. QCM 0.6.1's disjoint 1800 ms / advance 5400 ms
motion uses one software-compatible painter; reduced motion has visible static
feedback. Native completed progress stays full, without QCM drain-to-hidden.

Qt 6.12.0's default ProgressBar content has broken indeterminate-change
Connections. Dynamic modes opt into `Material3ProgressContent` explicitly;
the style does not replace caller content or patch Qt. Public API, source pins,
usage and limits are in [docs/families/progress.md](docs/families/progress.md).
QCM's measured cubic geometry now supplies progressWavy (10px),
progressCircularWavy (48px), progressContiguous and progressCircularRetreat.
The private Progress variation family owns these immutable recipes; canonical
wave geometry is generated from tokens/material3.json. The existing delegate
owns QCM amplitude, phase, finish/fade and segment calculations; native Qt retains
range/value/indeterminate and accessibility. The reference gallery uses one
percentage slider and QCM's play/pause composition, with semantic track overrides
for determinate circles. See the family document for exact source files and API.
Morphing BusyIndicator/loading shapes remain separate from this progress port.

## Qt 6.12 uygulama ayrıntıları

**Dinamik reader font başlangıcı:** Qt 6.12.0'da seçili stil zaten yüklenmişken
C++ `QQmlComponent` ile oluşturulan reader ilk font reset'ini kaçırabilir.
`setControlType()` içindeki `updateControl()` completion öncesinde çıkar;
`componentComplete()` yalnız tamamlanma flag'ini ayarlar. Cached font bir sonraki
native state güncellemesine kadar platform varsayılanı kalır. Statik Main
reader'ları ilk `Style.componentComplete()` / `reapplyStyle()` reset'ini alır.
[Qt 6.12 reader kaynağı](https://github.com/qt/qtdeclarative/blob/6.12/src/labs/stylekit/qqstylekitreader.cpp).

Earlier test-only size probes forced a native enabled-state change to refresh
this reader. Those implementation-coupled probes are retired from the routine
suite; the SDK limitation remains documented here. The kit and public consumer
API do not add this state change. SDK files and normal QML implicit dimensions
remain unchanged. See [TESTING.md](TESTING.md) for the current public test seams.

Native SK.Button içeriğinin IconLabel.color alanında notify yoktur. Ek içerik
helper’ı kendi bindable color alanını sunar. Helper kullanılmayan native butonun
interaction foreground’u internal, ertelenmiş StyleReader ile çözülür; bu okuyucu
Style.componentComplete okuyucu sıfırlamasından sonra oluşturulur. Böylece caller
icon.color (transparent dahil) değişikliği state-layer rengini bozmaz ve native
temanın canlı renk bağı korunur. SDK değiştirilmez.

GridLayout, kesirli doğal metin genişliğini aşağı yuvarlayabilir. İçerik helper’ı
preferred/max label genişliğini Math.ceil ile yuvarlar; gerçekten daraltılmış
caller genişliğinde normal elision korunur. Global control font veya ölçü
binding’lerine yazılmaz.

## Material Color Utilities

Renk seçimi karşılaştırma uygulamasında Main.qml'nin `seedColor`, `colorScheme`
ve `darkMode` durumudur; lightTokens/darkTokens aynı seed/scheme binding'lerini
kullanır. ThemePanel native çekmeceyi pencereyle birlikte oluşturur ve
pencere ömrünce korur; Qt 6.12'de geç variation reader yaratılması tema
resetinin raw-reader dolaşımını bozabildiği için runtime Loader kullanılmaz. Kapatma sırasında StyleKit reader'larını yok edip sonra
aynı stilin temasını yenilemez. Açma/kapatma ve klavye davranışı native Qt'dedir.

`Material3Drawer`, StyleKit'in Drawer sunmadığı Qt 6.12 için native Basic.Drawer
üzerine malzeme/hareket skin'idir; mevcut AppNavigation ve demo bunu paylaşır.
Theme girdisi açıktır; Basic.Drawer QObject'inde StyleKit attached context açılmaz.
`colorChoice` variation native SK.RadioButton'ın `palette.button` rengini
swatch verisi olarak kullanır. Focus, exclusive selection, readonly ve input
native kalır; 40px hedefte 28px QCM yüzeyi ve seçim halkası kanonik RadioButton
recipe'indedir. Normal form RadioButton'ları değişmez.

Demo AppearanceOptions.qml içindeki hex'ler QCM'nin seçilebilir başlangıç
renkleri ve varsayılan seed girdisidir; kontrol boyama token'ları değildir.
Palet seçenekleri açık enum değerleri taşır: Neutral=0 ve TonalSpot=1 korunur,
UI sırası enum ordinal'i olarak kullanılmaz. Kontrast API'si korunur; drawer
QCM gibi contrast=0 kullanır. Header yalnız Appearance açma ikonunu sunar;
açık/koyu seçimi paneldedir. Global Motion düğmesi gösterilmez; reducedMotion
API'si, OS tercihi ve test girdisi korunur.


`Material3Theme.dynamicColors` varsayılan `false` olarak mevcut MDC-Android
light/dark rol değerlerini korur. `true` olduğunda 34 semantik renk rolü,
kit içindeki Google Material Color Utilities C++ hesaplayıcısına bağlanır.
Geometri, typografi, disabled alpha, ripple/focus ve software painter sözleşmesi
değişmez. Her rol normal QML binding'idir: caller'ın açık renk veya canlı binding
override'ı seed/mode değişimi sırasında imperatif atamayla silinmez.

Girdiler: `seedColor` (varsayılan `#6750a4`), `scheme`
(`MaterialColorScheme.TonalSpot` varsayılan; ayrıca `Neutral`, `Rainbow`,
`Monochrome`, `Vibrant`, `Content`, `Fidelity`, `Expressive`, `FruitSalad`), `contrastLevel`
(varsayılan0) ve mevcut `dark`. Seed/scheme/contrast, Theme'in instance-owned
`colorScheme` hesaplayıcısına alias'tır. Geçersiz seed/enum ve non-finite contrast
son geçerli değeri koruyarak diagnostic üretir; seed alpha opaque'a normalize
edilir, finite contrast[-1,1] aralığına kırpılır. Bunlar OS erişilebilirlik
ayarlarına otomatik bağlantı iddiası değildir.

MCU kaynağı `material-foundation/material-color-utilities`
`ca894db8b6aebb2833f1805ae61573c92e3f1660` revizyonuna sabittir. QCM'nin aynı
renk algoritmasıyla eşleşen dokuz şemanın seed-only closure'ı kullanılır:
47 upstream dosya,22 C++ translation unit. Content/Fidelity için TemperatureCache
ve Lab dönüşümü gerekir; tam görüntü quantizer'ı dahil edilmez. Image quantization, score, Abseil,
QCM control/window/global Theme altyapısı alınmaz. C++20 aggregate/pi/header
taşınabilirlik düzeltmeleri ve HexFromArgb'ın `std::to_chars` karşılığı dışında
renk algoritması değiştirilmez. Değiştirilen dosyalar ve upstream/local hash'ler
[provenance](third_party/material-color-utilities/provenance.json) içinde kayıtlıdır.

Hesaplayıcı değişen girdilerde cache'i invalidate eder; bütün roller ilk okumada
birlikte üretilir ve instance içinde tutulur. Static mod generation okumaz;
frame başına renk hesaplanmaz. Renk üretimi renderer'dan bağımsızdır; Metal ile
software aynı ARGB çıktıyı kullanır. Private PIC/hidden OBJECT target Theme SHARED
library'sine gömülür; installed consumer'a MCU target/header/runtime kitaplığı
veya build sırasında ağ erişimi gerekmez. Apache-2.0 bildirimi kurulur.

Karşılaştırma kompozisyonunda lightTokens ve darkTokens ayrı ayrı dynamicColors
açar; seed `#bee7fd`, scheme `Neutral`, contrast0 ile QCM'nin varsayılanına eşitlenir.
QCM'nin palette üretimi contrast0 sabitler; farklı contrast seviyelerinde QCM
eşliği iddia edilmez. Bağımsız fixture, gerçek derlenmiş `MdColorMgr` üzerinden
üç seed ×dokuz scheme ×light/dark54 senaryo kaydeder; her senaryoda 34 rol
ARGB düzeyinde karşılaştırılır. Ham QCM çıktısı62 rol içerir; fixed/legacy/neutral
palette örneklerinin tümünün kit rolü olarak sunulduğu anlamına gelmez. [Referans kanıtı](evidence/material-color-reference.json).

## Qavsi.Icons bağlantısı ve FILL politikası

Material3 Style yalnız bağımsız `QavsiIcons::Core` target'ına bağlıdır. Native
metin veya QIcon kullanan tüketici Material fontunu import etmek zorunda değildir.
Paketli ikon isteyen uygulama `Qavsi.Icons.Material` import eder ve Material
target'ını bağlar. Karşılaştırma uygulaması bunu QML module `IMPORTS Qavsi.Icons.Material`
metadata'sında açıkça seçer; QML engine'e elle import path eklenmez.

`Material3ButtonContent`, `icon.name` paketli olduğunda `Qavsi.Icons.AppIcon`
üzerinden çizer. Bare Qt QIcon adları ve native `icon.source` yolu mevcut Qt
IconLabel adaptöründe kalır. Aynı alanda tek etkin renderer Loader ile seçilir;
metin etiketi `material3.button.label` adıyla font glyph Text'inden ayrılır.
Input, checkable, checked, enabled ve erişilebilir ad native SK.Button'a aittir.

Stilin typed parameters verisindeki `fillIconWhenChecked` varsayılan false'tur.
Standalone icon appearance ve icon size tarifleri true verir; connected icon
geometrisi de aynı politikayı kendi advanced parameters nesnesinde taşır. Size
ve appearance sırası bütün data nesnesini değiştirse bile FILL kararı korunur;
checked sırasında data nesnesi/variation listesi değiştirilmez. Normal common
buton/FAB ikonları otomatik dolmaz; segmented selected mark mevcut checkmark'ını
korur. Delegate, bu stil politikasını native checked ile birleştirip AppIcon'a
filled çizim isteği olarak aktarır. Core/provider StyleKit okumaz.

Theme ikon görünümü wght400, opsz24, GRAD0 ve CurveRendering olarak açıkça
aktarılır; Material provider software'da QtRendering'e düşer. Bu, önceki kullanıcı
kararıdır; QCM'nin FAB'da LabelLarge/500 kullanmasıyla birebir ağırlık eşliği
iddiası yoktur. Native icon.color (transparent dahil) korunur; ripple foreground
ayrı style text rolünden gelir. Bağımsız iconWidth/iconHeight verilirse font
boyutu küçük kenara sığdırılır; caller'ın dikdörtgen slotu büyütülmez.

Galeride settings için checked SVG koşulları kaldırılmıştır. Sabit
`material:settings` adı kullanılır. FAB trigger'daki add/close değişimi ise farklı
eylem sembolleri olduğundan `material:add`/`material:close` isimleri arasında
kalır. Ortak save/settings eşdeğer ad tablosu veya font paketleri arasında otomatik
isim eşleme yoktur. Eski SVG dosyaları referans varlığı olarak korunur; galeri
FILL davranışının implementasyonu değildir.

Qavsi.Icons.Material resmî Google Rounded2.978 font ve4304 isimlik matching katalog
paketler (sabit10ecc147 revizyonu); Core'a font/tema/tasarım token'ı taşınmaz.
Kaynak tüketimi `QAVSI_ICONS_SOURCE` ile önce Icons add_subdirectory yapabilir;
installed paket `find_dependency(QavsiIcons COMPONENTS Core)` kullanır. Material
provider seçimi uygulamada kalır. QT_QML_OUTPUT_DIRECTORY parent'a uyar; zorunlu
provider eklentisi standart QML modül dizininde bulunur. Source/installed aynı
target/API'leri kullanır. SDK, Merce/MButton veya diğer stiller değiştirilmez.

## QCM realistic ripple

Kaynak pinned QCM RippleSkia.qml ve assets/shader/ripple.frag'dır. Shader,
Skia/AOSP soft-circle wave, ring, triangle noise, dört sparkle bandı ve üç dönen
circle-grid turbulence hesabını taşır. Basma450ms OutCubic ile progress0.4'e
gider; hold bu değerde kalır. Bırakma350ms OutCubic→1, sonra0. Eşzamanlı base
fade150ms + shader opacity fade150ms'dir. Kuyruk sırasında yeniden basma mevcut
progress'i sıfırlamaz; yeniden0.4'e gider. Metal noise phase0→7000/214,7000ms loop
yalnız görünür shader dalgasında çalışır; painter hold boşuna frame üretmez.

Pasif PointHandler pozisyonu gözler; native AbstractButton pressed/canceled/
clicked/focus sahipliği değişmez. Cancel/disable/hide/minimize etkisi temizler.
Klavye başlangıcı merkezdedir. Renk/tema değişiminde aynı renderer kalır.
Reduced motion dalga/noise yerine statik base kullanır; release hemen temizler.
QCM'nin debugOpacity0.85 fixture'ı runtime hedef değildir; runtime0.12'dir.

Wave center touch'tan yüzey merkezine clamp(2*progress) ile ilerler; radius en
uzak köşeye olan mesafedir. Shader, var olan dört-corner SDF maske ve tek quad
kullanır. Sıfır radius/boyut koruması ve Qt'nin zaten premultiplied color uniform'u
için tek alpha çarpımı uygulanır. Software, aynı center/progress/fade/base ile
public QPainter radial gradient kullanır; sparkle noise yoktur. Cubic kenar
8 segmentle yaklaşık çizilir; Metal/software piksel eşliği iddia edilmez.

Yeni Skia/QCM runtime bağımlılığı yoktur. QCM MIT, AOSP Apache-2.0 ve Skia driver
BSD bildirimleri third_party/ripple-reference içinde tutulur ve kuruluma girer.
SDK, kontrol API'si ve mevcut tema renk algoritması değiştirilmez.


## QCM elevation integration

The shadow recipe belongs to this kit. No generic Runtime or Qavsi.Shadows
module is introduced. Native `SK.Button` and existing variation usage remain
unchanged. `SmallButtonBackground` resolves Elevated/FAB using existing
`shadow.visible` and typed `contentRole`; appearance does not replace size data.

| Appearance | Idle / focus / pressed | Hover | Disabled / hidden |
|---|---:|---:|---:|
| Elevated | level1 = 1 | level2 = 3 | 0 |
| FAB / Extended FAB | level3 = 6 | level4 = 8 | 0 |
| Filled / Tonal / Outlined / Text | 0 | 0 | 0 |

Theme owns the pinned QCM inputs: 250 ms emphasized-accelerate cubic
(0.3,0,0.8,0.2), ambient alpha 0.039, spot alpha 0.25, light direction (0,-1,1),
and light radius/height 800/600. Unequal corners use the QCM Outer mask recipe:
`sigma=max(elevation*shadowBlurSigmaFactor,shadowBlurMinimumSigma)` with 1.2/0.5,
and caller shadow alpha multiplied by `shadowBlurOpacity` 0.35. These are kit
inputs, not mandatory shared tokens for other design systems. The superseded
Qt blur/offset/opacity recipe and RectangularShadow adapter are removed.

The QCM renderer occupies native `background.shadow.delegate` through private
`SmallButtonShadow`; the background never draws a second shadow. The delegate
maps native button state and paint geometry, preserving background/shadow opacity.
Internal `Material3Elevation` owns transitions and reduced motion. An active
transition completes immediately when reduced motion is enabled. Equal corners
select the QCM analytic mesh; unequal corners select QCM Gaussian BlurMask.
The primitives own geometry, shader and render-thread textures, with no Theme,
control or animation policy. Software preserves painter ripple/fill/focus and
creates no GPU shadow. OpenGL below 3 is likewise suppressed; other RHI paths
use packaged shaders. Metal and desktop OpenGL Core are verified; Vulkan,
Direct3D and GLES runtime parity are not established by these runs.

The BlurMask implementation preserves 128-sample CDF, half-pixel sigma/radius
quantization, 4x4 subpixel cutouts, separable Gaussian convolution, four corner
textures, local-coordinate matrix handling, and Outer-mask alpha. Gaussian
allocation/work bounds and a bounded render-thread cache protect invalid or
excessive inputs; normal Material3 geometry is unchanged. Only Outer is needed
for elevation; this is not a new public general-purpose blur component.

Qt inherited opacity and correctly premultiplied color are preserved. This
intentionally corrects QCM's analytic opacity cubing/input-alpha discard and
straight-RGB blending. Raw colored/partial-opacity QCM equality is not claimed.
Opaque black reference equality, Qt alpha invariants, software, source/installed
consumption and actual runtime changes are recorded in
[shadow verification](evidence/ANALYTIC-SHADOW.md). Upstream source pins/notices
remain in `third_party/shadow-reference` and install with the kit.

The earlier sixty-run renderer benchmark and twelve-run analytic-port check
retain their original scope. They do not measure the new unequal-corner path
or complete StyleKit controls.

## QCM 0.6.1 menu and FAB comparison

The current comparison reference is QmlMaterial v0.6.1,
`191260585a829ee4ae2c99e6232b7145b5c34474`. Earlier benchmark results keep their
original `229bc3e` source pin; the updated reference is a separate checkout.

Native `SK.Menu` and `SK.MenuItem` remain the public controls. Material3Style
maps their surface, LabelLarge font, state colors and geometry; no new menu
control or QCM input router is introduced. The system font fallback is
LabelLarge; the explicit button font and caller font ownership are preserved.
Menu shadow is a private StyleKit shadow delegate over Material3Elevation:
level2=3, reduced-motion aware, with no GPU child on software.

| Menu input | QCM reference |
|---|---|
| Surface | surfaceContainer / surfaceForeground |
| Minimum background | 200 by 48 logical px |
| Corners / vertical padding |4 / 8 logical px |
| Rows |48 logical px; 16 px horizontal padding and spacing |
| Typography |LabelLarge 14/500/tracking 0.1 |

The comparison uses the same surfaceContainer role for ComponentCard, rather
than surfaceContainerLow. Dynamic color generation exposes Google's
GetSurfaceContainer() directly; fixed colors stay in Material3Theme.
Pointer opening has no initial selected row. Native menu routing owns keyboard
navigation, activation, dismissal and focus; the consumer requests modal input
without dimming, matching QCM. MenuItem feedback and native popup transitions follow the QCM motion recipe
below; QCM's MenuBase input router is not a runtime dependency.

The actual `fabMenuToggle` receives FAB elevation 6/8, matching both pinned and
current QCM. Action-stack rows remain flat. No shadow alpha or renderer
mathematics is changed to compensate for the previous disabled trigger shadow.

## Native menu motion and shared feedback

MenuItem uses a private Material3Ripple, shared with button backgrounds. The
existing Metal shader and software painter are reused. The state-layer color
is the live onSurface role, matching QCM StateMenuItem; it is not read from
Qt's non-notifiable internal label color. Persistent selected container color
stays in StyleKit mapping; hover/focus/press alpha belongs to the feedback
layer, so no interaction tint is applied twice.

QCM 0.6.1 Menu press opacity is 0.10 and each press resets wave progress/phase.
Button press opacity stays 0.12 and repress continues its current expansion.
The common 450/350ms expansion/release and 150+150ms fade recipe stays intact.
PointHandler observes input passively; native MenuItem owns activation and
keyboard navigation. Disabled/hidden/minimized/reduced-motion states stop the
animated wave. Reduced motion retains a static press state layer.

Qt 6.12 StyleKit does not assign Popup.enter/exit through StyleControl. The
public helpers connect the native properties explicitly, preserving caller
ownership and native exit lifetime:

```qml
SK.Menu {
    id: menu
    transformOrigin: mirrored ? Item.TopRight : Item.TopLeft
    enter: Material3MenuEnterTransition { control: menu }
    exit: Material3MenuExitTransition { control: menu }
}
```

The helpers read the selected Material3Style through the control's StyleKit
attachment. No style-name condition or duration/color literal is needed in
consumer pages. Caller-provided or explicitly null enter/exit bindings are
never installed over by a background delegate.

Enter uses 300 ms, opacity 0→1, scale 0.8→1, cubic(0.1,0.7,0.1,1).
Exit uses 150 ms, current opacity→0 and current scale→0.8,
cubic(0.3,0,0.8,0.2). Native Transition animates the complete PopupItem, including
content and shadow. There is no opacity-only background approximation or
extra effect layer. All motion values are owned by Material3Theme.

Reduced motion or `StyleKit.transitionsEnabled: false` sets future jobs to duration 0.
Qt clones native Transition jobs: changing duration or calling complete() on
the declarative prototype cannot cancel a prepared job through public API.
An already-running job can therefore finish within its original 300/150 ms
bound; following transitions are immediate. No synthetic close/open is used.
Qt 6.12 QQuickMenu also ignores open() while its exit is still visible, unlike
base QQuickPopup. After closed, normal open works. This native limitation is preserved rather than replacing Qt routing.


## Native TextField: outlined and filled

Reference: QmlMaterial 0.6.1 (`191260585a829ee4ae2c99e6232b7145b5c34474`),
`qml/input/TextField.qml`, `TextFieldEmbed.qml`, `FloatingPlaceholderText.qml`,
`OutlineTextFieldShape.qml` and `FilledTextFieldShape.qml`. This slice adds no
control wrapper, input router or dependency on Merce.

- `SK.TextField` is outlined by default. `textFieldFilled` selects filled;
  the family-prefixed variation avoids inheriting generic button variations.
- `placeholderText` is the single floating caption: rest inside when empty,
  float on focus or non-empty text, remain floated after blur with a value.
- Medium recipe: 56 logical px height, 16 px horizontal padding, BodyLarge
  16/400/tracking 0.5, 0.8 caption scale. All values belong to Material3Theme.
- Filled uses surfaceContainerHighest, top corners4, bottom underline1/2.
  The resting outlined background is transparent; its outline has a real gap
  behind the floated caption rather than a surface-colored patch.
- Foreground/indicator roles follow onSurfaceVariant, onSurface, primary and
  error. Invalid state uses native `acceptableInput`; readOnly stays enabled.
  Disabled content/outline use Material3 onSurface opacity roles.
- Editing, selection, cursor, validator, focus, readOnly and caller bindings
  remain owned by the native control. No delegate rewrites the input text.
- Label motion uses the Theme duration/easing. Effective reduced motion or
  disabled StyleKit transitions resolves the label directly to its end state.
  The same QML text/path implementation works on Metal and software.

Qt 6.12's native StyleKit placeholder reads the control palette directly rather
than the type palette. The background therefore uses a conditional, restoring
Binding to hide the default placeholder while it draws the floating caption.
An initially nondefault placeholderTextColor opts out and keeps the native
placeholder. No global palette or SDK patch is used.

The XS–XL sizes follow QCM's separate TextField and ComboBox token tables.

| Size | TextField height | ComboBox height | Font px / tracking |
|---|---:|---:|---|
| XS | 40 | 32 | 12 / 0.4 |
| S | 48 | 40 | 14 / 0.25 |
| M | 56 | 48 | 16 / 0.5 |
| L | 64 | 56 | 16 / 0.5 |
| XL | 72 | 72 | 16 / 0.5 |

Material3Theme owns typed size recipes: horizontal/vertical padding, adornment
size, gap and font. Private recipe variations map native geometry and supply
that same recipe through delegate data. TextField uses complete appearance+size
recipes (`textFieldFilledExtraSmall`, `textFieldOutlinedSmall`, etc.) because
StyleKit's opaque background.data slot cannot merge two independent axis objects.
One parameterized variation implementation supplies all recipes. `textFieldFilled`
remains the medium filled alias; outlined medium remains the default.
ComboBox uses `comboBoxExtraSmall/Small/Medium/Large/ExtraLarge`.
A restoring default-font binding applies the size typography; explicit caller
font ownership is retained. Recipe variations are assigned at creation; the
known Qt 6.12 dynamic-variation cache limitation remains.

The comparison's Text Inputs and Menus reference cards reproduce QCM's sample
order, 400px card width, 12px card padding and 8px input spacing. Native editing/contract examples
follow them. See [BACKLOG.md](BACKLOG.md) for deferred button work.

### TextField accessories and messages

`TextFieldSupport` is an attached content/status API on the native SK.TextField.
It provides prefix/suffix, leadingIcon/trailingIcon, supportingText/errorText and
an optional error override; it does not own text input or route events. Native
acceptableInput supplies the default error state. Assigning error=false/true
explicitly overrides it; error=undefined restores automatic validation.

The QCM 0.6.1 medium recipe supplies icon24/spacing12, affix spacing2 and support
spacing4. Supporting/error text uses BodySmall12/400/tracking0.4, line height16.
These are Theme tokens. Prefix/suffix appear when the caption floats or there is
no caption. They use the rendered input baseline, including its vertical-alignment
offset, elide at narrow widths and remain presentation only: the native text/validator value contains no affix.
Leading/trailing icons use AppIcon and package:icon names, Theme appearance and
onSurfaceVariant; an enabled error tints the trailing icon with the error role.
Icons are decorative, matching QCM, and do not introduce another focus stop.

Error text replaces supporting text when error=true and errorText is nonempty;
otherwise supportingText remains. The message wraps and reserves real native
bottom inset/padding, so subsequent controls do not overlap it. The 56px container
keeps its geometry while total implicit height includes the message. The selected
filled/outlined Theme recipe supplies the input's base bottom padding; supporting
space is added to that stable value. Logical
leading/trailing placement follows the native field's LayoutMirroring setting.
Optional decorations load only for fields that request them.

The geometry adapter temporarily augments default native padding/insets and
background minimum width, restoring their bindings when extras disappear or the
delegate is released. Initial nondefault caller values and later assignments keep
caller ownership; custom geometry must reserve enough room for accessories.
A binding initially equal to the style default cannot be distinguished through
public Qt API and is temporarily augmented until restoration. Text, font, explicit
width/height, selection, validator and readOnly remain native.

The placeholder supplies an initially empty Accessible.name, so adding a message
never removes the field label. Support/error text and affix units populate an
Accessible.description that is empty or still equals Qt's implicit placeholder
value. Accessibility-active startup is supported: the native placeholder is a
default, not a caller override. Other caller descriptions and later explicit
assignments keep ownership. As with geometry defaults, an explicit description
identical to the placeholder is indistinguishable through public Qt API.
Decorative labels/icons
are ignored individually, so the field description is not announced twice.


## Native ComboBox

Reference: QCM 0.6.1 `qml/input/ComboBox.qml`, `qml/popup/Menu.qml` and
`src/style/menu_item_state.cpp`, pinned to the same `191260585a829ee4ae2c99e6232b7145b5c34474` revision.
The adapter retains native SK.ComboBox model, textRole/valueRole, selection,
keyboard, editable acceptance and activation semantics.

- ComboBoxSupport.label supplies the floating caption. Focus or displayed/edit
  text raises it; a selected value keeps it raised after blur. QCM's ComboBox
  uses the outlined shape even though its exposed type property suggests more
  appearances. No unsupported filled variant is claimed.
- The medium geometry is 48px, horizontal padding12, indicator24 and spacing0,
  BodyLarge typography, extraSmall corner and the field caption motion tokens.
  The static down triangle has no font dependency. Native validator errors use
  the error role. The outline/gap renderer is shared with TextField.
- The default popup is modeless, retains ComboBox focus, has a 4px anchor gap,
  12px top/bottom safety margins, 8px vertical padding, a 200px minimum natural
  width and 280px default maximum width. Long rows elide; tall lists scroll.
  Width is measured on open and stops measuring after reaching the cap.
- Popup surfaces reuse Material3 popup/menu material, elevation and enter/exit
  transitions. MenuItem's checked container represents currentIndex, while
  highlightedIndex represents navigation/hover. Moving highlight never removes
  the selected container. All rows fill the available content width.
- Rows use native AbstractButton activation; no QCM input router, synthetic
  activated signal or model wrapper is introduced. Editable content remains
  the stock TextInput; a private noneditable display layer adds clipping/elision.
  Explicit caller content/factories are preserved; the label supplies the
  default accessible name.

Qt 6.12 StyleKit has no ComboBox popup/delegate style slots. The kit therefore
installs private factories only when public QML origin URLs identify the stock
StyleKit ComboBox. Custom caller factories stay installed; later assignments
retain caller ownership. Stock view/model attachment and popup parenting are
restored when the style delegate releases them. New popups are created after
component completion to avoid premature deferred StyleKit reader construction.
Native delegate replacement is guarded and selection restored before the actual
delegateChanged notification; caller QML selection bindings remain attached.

The native ownership/activation path is checked against
[Qt 6.12 ComboBox source](https://github.com/qt/qtdeclarative/blob/v6.12.0/src/quicktemplates/qquickcombobox.cpp).
The stock-origin adapter is scoped to Qt 6.12's StyleKit component layout and
must be rechecked when Qt changes that implementation. Motion policy and software
use the same existing kit paths; no Qt SDK source is changed.

## Native navigation, switches and sliders

Reference: QmlMaterial 0.6.1, `191260585a829ee4ae2c99e6232b7145b5c34474`:
`qml/navigation/{BarItem,RailItem,TabBar,TabButton}.qml`,
`qml/input/{Switch,Slider,RangeSlider,SliderHandle}.qml`, their state classes and
`example/Components.qml`. This is a Qt StyleKit adaptation, not a QCM runtime link.

- Native SK.TabBar / SK.TabButton own navigation selection, exclusivity, focus
  and keyboard input. The `navigationBar` / `navigationBarItem` variations use
  a 64x32 selected capsule with icon and label. `tabPrimary` uses the native tab
  bar and a content-width 3px underline. Independent `navigationRailCollapsed`
  and `navigationRailExpanded` Button recipes show the screenshot's icon items;
  a responsive rail/drawer container is not part of this slice.
  The comparison defers Navigation creation until Style completion, like its
  caller-popup examples, to avoid Qt 6.12 reader-reset crashes in an isolated build.
- `Material3NavigationContent` is an opt-in contentItem helper, like
  Material3ButtonContent. It preserves the native control, package:icon names,
  native icon color and checked-to-filled policy. Bar label ink is separate
  from selected icon ink. Native QFont metrics are retained; bar examples bind
  LabelMedium because Qt 6.12 has no variation-level fonts slot.
- Native SK.Switch owns checked/position, pointer, keyboard and mirrored drag
  behavior. The indicator paints a 52x32 track, 16px unchecked /24px checked or
  icon thumb, and 28px pressed thumb. The hidden background retains its natural
  dimensions because native Switch implicitWidth does not include the indicator.
  Icons use native icon.name/source/width/height/color unchanged. Qt 6.12's switch
  has no StyleKit icon slot/default ink: icon consumers explicitly bind its size
  and semantic color from Theme. Explicit zero sizes and transparent colors remain
  owned by the caller. Label-free examples use native spacing0 for optical centering.
- SK.Slider and SK.RangeSlider share StyleKit's `slider` group. Default track is
  16px; `sliderMedium` gives the 40px inset-icon track. Native handles retain their
  positions/input with a 4px line (2px active), 44px length and 6px track gap.
  Active/inactive split tracks, horizontal/vertical orientation, native RTL,
  native stepSize/snapMode/live behavior and range nodes are preserved.
- `SliderSupport` adds only missing presentation/input policies: floating,
  visible or hidden value labels; tick visibility; package inset icons; and a
  readOnly user-input gate. Preview labels use native valueAt(position), including
  live:false drags. Decorative stops are capped at20; this does not alter native
  snapping. Read-only blocks pointer/touch/wheel/value keys without writing enabled
  or value bindings, marks Accessible.readOnly and consumes accessible increment/
  decrement requests. Programmatic/native value setters intentionally remain valid.
  Releasing an active grab can invoke application callbacks; cancellation guards
  permit those callbacks to destroy the control without a subsequent stale access.
- Native RangeSlider has no minimum-span validator before accepting a value.
  The gallery's discrete range starts at20/80 but does not claim an enforced20
  minimum. No caller-value correction or replacement input router is installed.
- Generated Slider/Switch/RadioButton/Navigation/Tab geometry recipes are compiled as private
  Theme resources from the canonical tokens/material3.json outputs. Theme therefore
  stays independent of the Style target. Palette, typography and motion policy
  remain Theme-owned; comparison-only layout metrics stay in ComparisonMetrics.
- Bar selection uses100ms linear motion, tabs250ms standard cubic. Rail selection
  uses a250ms Qt OutCubic adaptation of QCM's spring; exact spring parity is not
  claimed. Every new motion follows effectiveReducedMotion, StyleKit transitions,
  visibility and window state. Simple Qt Quick tracks/thumbs render on software;
  existing Material3Ripple/Material3Elevation retain their Metal/painter policies.

### CheckBox

The native `SK.CheckBox` mapping follows QCM 0.6.1
`191260585a829ee4ae2c99e6232b7145b5c34474`, `qml/input/CheckBox.qml`,
`CheckShape.qml` and `src/style/check_box_state.cpp`. The generated recipe owns
an18px indicator and40px state layer. Theme owns LabelLarge, padding8/15,
spacing8, primary/onPrimary selected ink and onSurfaceVariant/onSurface outline.
Disabled ink uses onSurface at0.38, with surface for the selected mark.

One private Shape draws QCM's fill, hollow outline, tick and indeterminate dash;
its source paths are translated from7..25 to0..18 without changing geometry.
Curve rendering and Qt's software Shape renderer share the same paths. State
marks switch immediately, as in QCM; existing Material3Ripple and the kit's
keyboard-focus ring retain Theme/reduced-motion and Metal/software policies.

Native Qt owns checked/checkState, tristate/nextCheckState, input, focus, labels
and caller bindings. There is no CheckBox wrapper or selection variation list.
The indicator uses a restoring public Binding from checkState to
Accessible.checkStateMixed, omitted by stock Qt6.12 StyleKit; role, checked and
name remain native. QCM's controlled request-signal API and error/read-only
extensions are not introduced by this slice.

### RadioButton

The native `SK.RadioButton` mapping follows the same QCM 0.6.1 pin
`191260585a829ee4ae2c99e6232b7145b5c34474`: `qml/input/RadioButton.qml`,
`RadioIndicatorShape.qml` and `src/style/radio_button_state.cpp`. A20px circle
has a2px outline and10px selected dot; the state layer is40px. LabelLarge,
horizontal padding8, vertical padding14 and spacing8 give a 48px natural height.
Explicit caller fonts and native RTL layout remain owned by Qt. Geometry comes
from the canonical generated RadioButton recipe; colors/150ms linear selection
motion belong to Theme. Selection motion honors reduced motion, StyleKit
transitions, visibility and window state; the existing ripple keeps its
Metal/software backends. Focus retains this kit's accessible outer ring rather
than claiming exact QCM dual-ring parity.

`RadioButtonSupport.readOnly` supplies Qt's missing input policy without writing
checked/enabled or replacing native selection/grouping. It blocks pointer/touch,
selection keys, mnemonics and accessible activation; Tab navigation and parent
wheel scrolling remain available. Entering read-only cancels a pending native
press, and programmatic checked updates remain valid. Accessible.readOnly is
bound only while this policy is active. Accessible actions use native click()
when unlocked; their handlers remain installed across the read-only transition.
Native disabled styling remains separate.
The comparison-only Read only row spacing belongs to ComparisonMetrics.

### Chips

Chips are native SK.Button controls, not labels or replacement control types.
Assist/Suggestion command chips remain non-checkable; Filter/Input use native
checkable/checked. Their selected surface uses secondaryContainer and
chipSelectedInk; it persists after pointer exit and clears on deselection. The
comparison's disabled Filter/Input examples mirror the enabled chip selection,
as in QCM, while native enabled:false prevents user activation. The QCM-specific
Embed recipe is included as a command chip
with decorative trailing content. The five immutable variation roles are
chipAssist/chipFilter/chipInput/chipSuggestion/chipEmbed. Their private chipDismiss
role styles a native trailing Action button; no runtime variation switching is
needed. The native button still owns input, focus, disabled gating and selection.

QCM 0.6.1 pin191260585a829ee4ae2c99e6232b7145b5c34474
qml/chip/*.qml and src/style/chip_state.cpp supply the32px height,8px radius,
18px icons and16/8 optical padding. Canonical ChipRecipe geometry feeds Theme;
semantic ink, disabled0.38/0.12 roles and50/100ms linear filter motion remain
Theme-owned. Native LabelLarge/font overrides are retained. These desktop32px
controls do not claim a separate48px touch target.

Material3ChipContent is an opt-in contentItem helper, like Material3ButtonContent.
It supplies package icons, the selected Filter check, elision/RTL and an optional
native T.Action trailing slot. Logical padding correction applies only at the
style's default native padding; explicit custom padding stays caller-owned.
Native text remains complete for accessibility. The helper's iconWidth/iconHeight
use the recipe18px default because Qt6.12 has no per-variation icon-size slot.
A nondefault native icon color remains caller-owned. A decorative trailingIconName
has no separate activation; trailingAction creates a separately focusable native
button. The Action's handler owns model removal; the style never destroys a chip
or changes checked/enabled bindings. An unused trailing Action slot creates no
extra button. Existing Material3Ripple and Material3Elevation supply shader/painter
policies, Theme/reduced-motion/visibility gates and the kit focus ring.
Elevated, editing/avatar and native Drag.active inputs are supported; see
[motion/chips](docs/families/button-motion-chips.md). The application owns editor
commit/cancel and model changes. Input/Embed keep QCM's no-shadow rendering.

### Native Action menu ownership

Open action menu adapts QCM 0.6.1 ActionMenu's three reference Action objects with
native Qt Quick Action and MenuItem.action. Actions are owned outside the lazy
popup; text/icon/enabled/checkable/checked updates and activation remain Qt's
responsibility. No action mirror, custom command runtime or ActionMenu control
wrapper is introduced. The existing lazy-menu startup boundary remains intact.
Menu.addAction creates each native delegate when the popup first becomes visible,
matching QCM's deferred ActionMenu population; reopening preserves the same Actions.

Material3MenuItemContent only adapts the icon drawing slot for package:icon.
Qt's MenuItemIconLabel remains the text/mnemonic/shortcut/native-QIcon renderer;
check indicators, submenu arrows, focus, keyboard activation and menu dismissal
remain native. Glyph appearance follows Theme and the existing Qavsi.Icons provider.
The helper defers its StyleReader until native control completion, as existing
button backgrounds do for Qt 6.12. The menu delegate binds icon.color to that
reader's color; native caller assignments retain ordinary binding ownership.
The reference triggers retain flat:true: measured on Metal, their resting surface
alpha is 0 and hovered state-layer alpha 20/255, matching Theme's 0.08 hover policy.
FlatButton's Theme mapping explicitly suppresses inherited hover/focus/pressed
container borders and hover elevation, and uses the Small Button pill and pressed
corner tokens. The interior 0.08 state-layer measurement alone does not establish
that the container edge is correct: native Metal hover previously exposed an
opaque inherited border. Keyboard visualFocus retains the separate kit focus ring.

The Action-menu Theme pass also exercises rail items created after Style completion.
StyleKit may publish Navigation data before replacing the old button delegate.
That outgoing background stays hidden for mismatched typed data and uses the
selected Theme until its replacement is ready; no extra Theme instance is created.


## Badge

QCM 0.6.1 Badge uses one native SK.Label-based Material3Badge presentation helper.
The immutable badge/badgePrimary/badgeSecondary/badgeContrast recipes map semantic
foreground/container pairs; the private Rectangle delegate owns paint, Theme owns
LabelSmall and canonical BadgeRecipe geometry. Theme remains independent of Style.
Count, cap, showZero and decorative dot update without runtime variation changes.
Explicit native text/font/geometry/accessible-name bindings remain caller-owned.
There is no input handler, auto-target wrapper or extra label; ordinary anchors
place overlays. Full counts remain accessible while visual counts are capped.
No motion or GPU effect is needed, so software and reduced motion use the same path.
See [Badge family](docs/families/badge.md) for API and the QCM source pin.

## Application navigation composition

See [app-navigation](docs/families/app-navigation.md) for the QCM 0.6.1 pin, native
ToolBar/searchField mappings and public Material3AppNavigation contract. Theme
owns64px toolbar,56px search,96/220px rail,600/1200px breakpoints and sheet motion.
The shell composes existing rail recipes with native Buttons/TextField/ToolBar,
modal navigation and nonmodal details. Qt6.12 has no StyleKit Drawer; Basic.Drawer
is scoped to its implementation and does not change the application Controls style.
Selection and text survive responsive presentation changes. SearchView overlays,
QCM runtime integration and automatic application navigation are outside this API.

### Pickers and carousel

Native SK.Dialog compositions own date/time/color drafts and acceptance requests;
Qt MonthGrid owns locale/calendar data, and native ComboBox/Slider/TextField own
editing. Picker geometry and semantic ink live in Theme and immutable picker
variations. Material3Carousel composes native StyleKit Pane/Button/PageIndicator
with a public Qt Flickable and the pinned QCM keyline/snap engine. Uncontained,
MultiBrowse, Hero, HeroCenter, FullScreen and UncontainedMultiAspect share Theme
geometry and motion, including immediate reduced-motion snapping. Image cards
use Qt Image without shader-only masking, retaining the source gallery's rectangular
photos on Metal and software. FileDialog is a direct example-only QtQuick.Dialogs
consumer. See [picker contract](docs/families/pickers-carousel.md) and
[carousel contract](docs/families/carousel.md).


## ListItem / Card family

Native `SK.ItemDelegate` supplies list input, focus and selection. Immutable
`listOneLine` / `listTwoLine` / `listThreeLine` resolve 56/72/96 px minimum rows;
checked automatically resolves secondaryContainer. Optional public
`Material3ListItemContent` composes decorative overline, supporting text and
leading/trailing metadata without replacing native bindings/accessibility.

Immutable `cardFilled` / `cardElevated` / `cardOutlined` map native `SK.Pane`
and interactive `SK.Button` / `SK.ItemDelegate` surfaces, with 12px corners,
64px minimum and 16px padding. Existing ripple and elevation are reused;
software shadows remain omitted. See [family contract](docs/families/list-card.md).

## Dialog and feedback family

Native Dialog slots, explicit header/footer/overlay/transition delegates, local
Basic.ToolTip and native Popup snackbar contracts are specified in
[dialog-feedback.md](docs/families/dialog-feedback.md). The native Dialog owns
roles/focus/dismissal; all helper materials and dimensions resolve from Theme.

### Embedded pickers and ScrollBar

QCM 0.6.1 DatePicker and ColorPicker are embedded native StyleKit compositions.
Their Dialog-suffixed types host the same controls and own only draft/accept/cancel
state. Date Single/Range and Calendar/Input requests stay caller-owned; color
HSV/RGB channels use QCM trailing-alpha RGBA8, not Qt ARGB string syntax. See
[date picker](docs/families/date-picker.md) and [color picker](docs/families/color-picker.md).

Native SK.ScrollBar input and attached Flickable synchronization remain intact.
The StyleKit delegate paints the QCM8px overlay,2px idle/6px expanded thumb,
neutral38%/pressed80% ink and12% expanded track. AsNeeded feedback retains for
2450ms then fades using QCM medium1/250ms. Theme owns these values; reduced
motion hides immediately and no per-frame effect or SDK modification is involved.

The QCM ColorPickerButton preview remains separate from the inline channel editor.
Its native 32px split swatch uses HCT palette tones30/90 for the trailing plate and
80/30 for ink; the colorize glyph opens the picker dialog, not a screen sampler.
The date input's calendar glyph opens its dialog. No extra text-only date/color
launch buttons belong to the reference gallery.

Color dialogs use QCM 0.6.1's full ColorPicker: 240px hue ring with 22px thickness,
rotating SV triangle, RGBA8 chip, XS segmented mode selector and 60×24 channel
steppers. Channel tracks are 220×20 with 6px row spacing. The picker has 12px
horizontal padding and the standard dialog has 24px horizontal padding, giving
its natural 382px width. The inline composition alone hides the wheel header.
All physical hue/alpha colors describe color data; handle/checker contrast colors
are explicit Theme tokens. Pointer drags retain their grab inside a Flickable.

QCM date navigation uses a 48px month header, followed by an inline 3-column year
view (312px, 52px cells), then a 3-column month view (78px cells). The date header
is at least 100px, supporting Label Medium and Headline Medium 28px. Weekday rows
are 24px plus 4px top/bottom padding; day grids keep 40px cells and 8px gaps. All
navigation hover/pressed/focus/selected colors come from the kit's button styles
and `pickerNavigationItem`; gallery code contains no styling branches.
Year/month browsing and calendar keyboard focus do not commit date selection.

Year/month navigation buttons fill their 52/78px cells; idle corners are half
that height (26/39px), with the kit's Small pressed corner. The existing button
delegate clamps the resolved radius to the actual cell, so no separate surface
or custom button is introduced.

Date input mode reuses native TextField floating labels: Date for Single, Start date
and End date for Range, with the locale format as supporting text. Entering input
mode focuses the first editor as in QCM. The reference gallery hides its separate
single-date field in Range mode; this is content visibility, not a style branch.

### Review fixes and optical ownership

Carousel, Picker and ScrollBar optical dimensions follow the same canonical
`tokens/material3.json` -> generated recipe -> typed Theme flow as other families.
Semantic ink, typography, shape roles, motion and target-size policy remain in
Material3Theme. The neutral Material3ControlTheme composes default native mappings;
field recipe registration is a separate private family object. No common Runtime
or universal palette is introduced.

The private date helper normalizes calendar-day comparison and bounds in both
input and calendar. A read-only/disabled/hidden date field dismisses its open
calendar and rejects late acceptance. Calendar Tab focus always selects an enabled
visible day when one exists. Inactive Progress transitions settle to the current
public value without waiting for a stopped clock. Carousel owns model lifecycle
and retains logical selection when layout geometry changes. Unused QCM ring
broadcast and Progress compatibility state are excluded from the native adapters.
