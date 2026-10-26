# Qavsi Material3 — buton ailesi

Qt 6.12 tabanlı bağımsız buton ailesi. Semantik renkler ve typografi Google
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
- Internal `SmallButtonTheme`: `SK.Theme` üzerinden Qt button alanlarına eşleme.
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

Karşılaştırma ekranı pinned QmlMaterial kaynağındaki Common XS/S/M, Icon
XS/S/M/L ve S için Narrow/Default/Wide örneklerini gösterir. Kütüphanenin Common
ve Icon XS–XL API'si korunur; referans API de beş boyut sunar. Ek L/XL kapsamı
`checks.cpp` içindeki test-only `QQmlComponent` native buton fixture'larıyla
sınanır; demo'ya gizli sahte kontroller veya görünürlük flag'leri eklenmez.

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
Referanstaki With Badges bölümü ayrı Badge ailesi olarak envanterde tutulur;
bu buton diliminde dot/count/capped/text badge aktarılmış sayılmaz.

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

**Açık sınırlar:** loading, badge, navigation, input, seçim kontrolleri, slider,
tabs ve genel Menu/Popup skin bu dilime dahil değildir. Split menü referans gibi
sahne içi Popup.Item ve Qt fallback’ini kullanır.
İki inline FAB action stack bu karşılaştırmaya dahildir; bütün Expressive FAB
menu ailesinin eşliği iddia edilmez. Grouped neighbor-width redistribution ve
font FILL morph açık kalır. Karşılaştırmada StyleKit transition seçimi effectiveReducedMotion’a bağlıdır;
ripple ve helper’ın kendi motion politikası aynı tercihi izler. Small doğrulama
örneği için global StyleKit transition’ları kapalı kalır. Tam QmlMaterial veya güncel Expressive
eşliği iddia edilmez. Qt SDK’sı değiştirilmez.

Kabul kanıtı: [evidence/VERIFICATION.md](evidence/VERIFICATION.md).

## Qt 6.12 uygulama ayrıntıları

**Dinamik reader font başlangıcı:** Qt 6.12.0'da seçili stil zaten yüklenmişken
C++ `QQmlComponent` ile oluşturulan reader ilk font reset'ini kaçırabilir.
`setControlType()` içindeki `updateControl()` completion öncesinde çıkar;
`componentComplete()` yalnız tamamlanma flag'ini ayarlar. Cached font bir sonraki
native state güncellemesine kadar platform varsayılanı kalır. Statik Main
reader'ları ilk `Style.componentComplete()` / `reapplyStyle()` reset'ini alır.
[Qt 6.12 reader kaynağı](https://github.com/qt/qtdeclarative/blob/6.12/src/labs/stylekit/qqstylekitreader.cpp).

Yalnız test-only boyut fixture'larının hazırlığında completion sonrası native
`enabled: false` → `true` geçişi yapılır; bu mevcut `updateControl()` /
`rebuildEffectiveFont()` yolunu çalıştırır. Tek Small probe'un before/after font
logu korunur; Label Large 14 px assert'i gevşetilmez veya literal font atanmaz.
Kit/public consumer API'sine bu geçiş eklenmez; genel dinamik font SDK hatası
giderilmiş sayılmaz. Bu sınır dinamik variation cache hatasından ayrıdır; SDK
ve normal QML implicit ölçüleri değiştirilmez.

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

`Material3Theme.dynamicColors` varsayılan `false` olarak mevcut MDC-Android
light/dark rol değerlerini korur. `true` olduğunda mevcut 20 semantik renk rolü,
kit içindeki Google Material Color Utilities C++ hesaplayıcısına bağlanır.
Geometri, typografi, disabled alpha, ripple/focus ve software painter sözleşmesi
değişmez. Her rol normal QML binding'idir: caller'ın açık renk veya canlı binding
override'ı seed/mode değişimi sırasında imperatif atamayla silinmez.

Girdiler: `seedColor` (varsayılan `#6750a4`), `scheme`
(`MaterialColorScheme.TonalSpot` varsayılan; ayrıca `Neutral`), `contrastLevel`
(varsayılan0) ve mevcut `dark`. Seed/scheme/contrast, Theme'in instance-owned
`colorScheme` hesaplayıcısına alias'tır. Geçersiz seed/enum ve non-finite contrast
son geçerli değeri koruyarak diagnostic üretir; seed alpha opaque'a normalize
edilir, finite contrast[-1,1] aralığına kırpılır. Bunlar OS erişilebilirlik
ayarlarına otomatik bağlantı iddiası değildir.

MCU kaynağı `material-foundation/material-color-utilities`
`ca894db8b6aebb2833f1805ae61573c92e3f1660` revizyonuna sabittir. QCM'nin aynı
renk algoritmasıyla eşleşen Neutral/TonalSpot seed-only closure'ı kullanılır:
29 upstream dosya,13 C++ translation unit. Image quantization, score, Abseil,
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
üç seed ×iki scheme ×light/dark12 senaryo kaydeder; her senaryoda mevcut20 rol
ARGB düzeyinde karşılaştırılır. Ham QCM çıktısı62 rol içerir; yeni kitin eksik
42 rolünün taşındığı anlamına gelmez. [Referans kanıtı](evidence/material-color-reference.json).

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
without dimming, matching QCM. MenuItem uses StyleKit state layers; QCM's custom ripple and enter/exit
animations are not part of this mapping or a port of its MenuBase router.

The actual `fabMenuToggle` receives FAB elevation 6/8, matching both pinned and
current QCM. Action-stack rows remain flat. No shadow alpha or renderer
mathematics is changed to compensate for the previous disabled trigger shadow.
