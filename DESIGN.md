# Qavsi Material3 — ilk bağımsız dilim

Qt 6.12 tabanlı Small Filled button prototipi. Material3 görsel sözleşmesi bu
pakete aittir; Merce Theme, Runtime, ortak palette veya kontrol sarmalayıcısı yoktur.

## Kaynak

Birincil kaynak Google Material 3. Sayısal referans: MDC-Android **1.13.0**,
commit `84c0e6d6d493fcf176d2099683245b78afbeb78d`:

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

| Alan | İlk dilim |
|---|---|
| Kullanım | Normal, text-only `SK.Button`; default Small Filled |
| Container | 40 logical px minimum paint yüksekliği; round radius 20; elevation 0 |
| Padding | Small token leading/trailing 16; Qt dikey padding 10 |
| Typography | Label Large 14 logical px, Medium/500, tracking 0.1 |
| Light | primary `#6750a4`, foreground `#ffffff`, surface `#fef7ff` |
| Dark | primary `#d0bcff`, foreground `#381e72`, surface `#141218` |
| Hover | primary üstünde foreground %8 state layer |
| Focus | klavye `visualFocus` için foreground %10 state layer |
| Pressed / ripple | foreground %10; pointer konumundan, klavyede merkezden yayılır |
| Ripple hareketi | Qt uyarlaması: 300 ms `OutCubic` genişleme, 180 ms linear sönme |
| Focus ring | Qt erişilebilirlik uyarlaması: primary, 2 logical px çizgi, 2 px dış boşluk |
| Disabled | on-surface %12 container / %38 label; native input kapısı |

**Açık sapmalar:** Label Large'ın resmi line-height'ı 20'dir; Qt'nin native
IconLabel/QFont satır kutusu kullanılır, exact line-height zorlanmaz. QFont 0.1
tracking'i bu SDK'da 0.09375'e yuvarlar. Default font platform fontudur; Roboto
paketlenmez. Caller kurulu bir fontu `fontFamily` ile seçebilir.

40 px paint ve 10 px Qt padding bu ilk masaüstü uyarlamasının tarifidir; Android
widget'in inset/minimum alanını aynen kopyalamaz. Bağımsız 48 px touch alanı henüz
uygulanmadı; kiosk/touch uygunluğu iddia edilmez. Metin büyüyünce implicitHeight
büyüyebilir; caller açık height verirse clipping sorumluluğu tüketicidedir.

State-layer ve ripple alpha'ları üst üste eklenmez; sönme sırasında tek alpha
sonucu hover/focus katmanına geçer. Android selector'ünün default %16 değeri ripple
çıkış rengi içindir, idle katman değildir. MDC button native `RippleDrawable`
kullanır; bu paketin 300/180 ms süreleri ve `OutCubic` seçimi resmi button motion
token'ı değildir.

Klavye halkası yalnız enabled ve `visualFocus` durumunda görünür; mouse/touch
focus'u halka üretmez. Qt'nin [visualFocus sözleşmesi](https://doc.qt.io/qt-6/qml-qtquick-controls-control.html#visualFocus-prop)
Tab, Backtab ve shortcut focus nedenlerini kapsar. Dış halka layout ölçüsünü
büyütmez; kırpan bir üst öğe kullanılıyorsa görünmesi için yer bırakılmalıdır.
Checked native durum olarak korunabilir; toggle button'ın seçili şekli/semantik
renk tarifi henüz kapsam dışındadır.

`Material3Style.reducedMotion` typed bool ve varsayılan `false` değerindedir.
`effectiveReducedMotion`, bu girdi ile
`Application.styleHints.accessibility.motionPreference === Qt.MotionPreference.ReducedMotion`
sonucunun OR birleşimidir. Sistem azaltılmış hareket istiyorsa caller `false`
vererek animasyonu açamaz. [Qt 6.12 public motionPreference](https://doc.qt.io/qt-6/qaccessibilityhints.html#motionPreference-prop)
değişiklikleri izlenir; hareket azaltıldığında ripple genişlemesi/sönmesi durur,
pressed state anlık ve statik kalır. Disable, hide ve cancel yolları aktif ripple'ı
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
tipi, blur, font provider, ButtonSupport veya üçüncü taraf bağımlılık yoktur.

Painter'ın Image yolu Metal'de CPU çizimi ve texture upload maliyeti getirir.
Shader aynı geometri, premultiplied renk, alpha çözümlemesi ve hareket girdilerini
kullanır; iki renderer'ın kenar antialiasing'i piksel düzeyinde farklılaşabilir.
Ölçüm aynı Metal backend'inde yapılır; software FPS'i Metal ile kıyaslanmaz.
Benchmark sonuç ve sınırları [doğrulama raporunda](evidence/VERIFICATION.md) tutulur.
StyleKit transitions örnekte kapalıdır; ripple'ın kendi animasyonu hareket
politikasına bağlıdır. Source/installed tüketim sözleşmesi aynıdır; internal QML
factory/data dosyaları ve C++ registration metadata'sı paketle taşınır.

Variation ekleme/kaldırma yapılmaz; default Small tarifi sabittir. Qt SDK'sı
değiştirilmez. Shape morph, loading, icon button, diğer boyutlar,
elevated/tonal/outlined/text ve diğer kontrol family'leri henüz desteklenmez.
Qt'nin diğer kontroller için verdiği fallback görünümü Material3 coverage sayılmaz.

Kabul kanıtı: [evidence/VERIFICATION.md](evidence/VERIFICATION.md).
