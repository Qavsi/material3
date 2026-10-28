# Qavsi Material3

Qt **6.12+**, CMake **3.30+**, C++**20**. Qt ve kendi Theme/Style modülleri üzerinde bağımsız StyleKit kiti.
Material Color Utilities'in private C++ alt kümesi kaynakla birlikte gelir.
Paketli ikon adaptörü bağımsız Qavsi.Icons Core paketini kullanır. Merce’de ilerlemiş buton ailesi bu
depoya aktarılır; diğer kontrol aileleri sırayla taşınacaktır. Geliştirme durumundadır; stable SDK
veya tüm Material3 kontrol ailesinin tamamlandığı anlamına gelmez.

Kaynak depo: [Qavsi/material3](https://github.com/Qavsi/material3).
Mimari ve karar kayıtları: [Qavsi/qavsi](https://github.com/Qavsi/qavsi).
Bu repo Merce'den bağımsızdır; Merce kaynakları, kurulumu veya Runtime gerekmez.

## Lisans

Bize ait kod ve belgeler [MIT](LICENSE) lisanslıdır. Harici Qt bağımlılıkları ve
tasarım referansları kendi koşullarını korur; [üçüncü taraf notları](THIRD_PARTY_NOTICES.md).


```text
src/Qavsi/Material3/Theme/   Material3Theme.qml — token'lar ve QFont
src/Qavsi/Material3/Style/   Material3Style.qml — composition root
                           SmallButtonTheme.qml — internal button mapping
                           SmallButtonDelegate.qml — internal Component factory
                           SmallButtonParameters.qml — typed delegate data
                           SmallButtonBackground.qml — ripple/focus background
                           materialbuttonfeedback.* — internal Qt painter
                           shaders/ — Metal ripple için build-time .qsb
                           internal/menus/ — native Menu için gölge factory/data
examples/small-button/     aynı source/installed tüketici ve contract check'leri
cmake/                     relocatable paket ve QML export'ları
evidence/                  gerçek çalıştırma kanıtları
```

Önkoşul: Qavsi.Icons Core kurulu olmalı veya kaynak build için kardeş `../icons`
checkout’u bulunmalıdır. Aşağıdaki komutlar ikinci yolu kullanır.

## QML tüketimi

```qml
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Style

SK.ApplicationWindow {
    visible: true
    SK.StyleKit.style: Material3Style { themeName: "Light" }
    SK.StyleKit.transitionsEnabled: false

    SK.Button {
        text: qsTr("Kaydet")
        onClicked: saveDocument()
    }
}
```

Stil yalnız composition root'ta seçilir. Sayfalarda style koşulu, MButton veya
Runtime import'u yoktur. `themeName: "Dark"` aynı kontrol nesnesini yeniden
oluşturmadan temayı değiştirir. Qt StyleKit seçimi process-global'dir; bu paket
onu pencere veya engine başına izole edilmiş gibi sunmaz.

Theme verileri `import Qavsi.Material3.Theme` ile bağımsız kullanılabilir.
`Material3Style.lightTokens` ve `darkTokens` typed `Material3Theme` girdileridir;
seçili nesne `style.tokens` üzerinden okunur. Örnek sayfanın canvas/text renkleri
de bu nesneden gelir. Buton variation ve içerik sözleşmesi aşağıdadır.

Normal, text-only native `SK.Button`, pointer konumundan veya klavyede merkezden
yayılan ripple ve yalnız klavye focus'unda dış halka alır. Internal background
delegate ve pasif `PointHandler`, button'ın input/focus/activation sahipliğini
değiştirmez; caller font, ölçü, padding, spacing ve callback bağları korunur.
Ripple QCM gibi450ms `OutCubic` ile %40'a genişleyip basılıyken bekler;
bırakınca350ms'de tamamlanır ve150+150ms katman fade'iyle söner. 2 px primary halka ve 2 px
dış boşlukla birlikte bu süreler Qt uyarlamasıdır; resmi MDC button motion/ring
ölçüsü olarak sunulmaz. Ayrıntılar ve pinned kaynaklar [DESIGN.md](DESIGN.md) içindedir.

`Material3Style.reducedMotion` bool girdisi varsayılan `false` değerindedir;
`true` statik pressed feedback seçer. `effectiveReducedMotion`, bu girdi ile
Qt 6.12 `Application.styleHints.accessibility.motionPreference` sistem
tercihini OR ile birleştirir. Sistem azaltılmış hareket istiyorsa `false`
animasyonu zorlayamaz. Örnek sayfanın hareket düğmesi manuel girdiyi değiştirir;
aktif press sırasında politika değişimi de uygulanır. Halka dışarı çizildiği
için kırpan layout'larda çevresinde yer bırakılmalıdır.

Metal'de ripple tek shader ile seçilen tarifin dört köşe yarıçapına göre kırpılır; software'da public
`QQuickPaintedItem::Image` painter yolu korunur. Seçim kit içinde gerçek backend'e
göredir; shader hatası loglanıp painter'a düşer. Focus halkası iki yolda da native
Qt çizimidir. Source build Qt ShaderTools ister; shader pakete gömülür, installed
tüketici ShaderTools veya runtime shader derleyicisi istemez.
Loading bu aktarımın dışındadır. Paketli font provider bağımsız Qavsi.Icons.Material modülündedir.

## Merce’den taşınan buton ailesi

Mevcut `Merce.Style.Material3` tarifleri ve `MerceMaterial3Demo/ActionsGallery.qml`
temel alınır. Bunlar yeni bir MButton sarmalayıcısına aktarılmaz: input, Action,
enabled, checked, text, icon ve display sahipliği native `SK.Button`’da kalır.

| Alt aile | Variation / içerik |
|---|---|
| Common | Filled (varsayılan), `elevated`, `filledTonal`, `outline`, `ghost` |
| Boyut | `buttonExtraSmall`, `buttonSmall`, `buttonMedium`, `buttonLarge`, `buttonExtraLarge` |
| Icon | `iconStandard`, `iconFilled`, `iconTonal`, `iconOutlined`; toggle için `iconFilledCheckable`/`iconTonalCheckable`; XS–XL ve Narrow/Default/Wide |
| Joined | `connectedLeading/Middle/Trailing`, icon rolleri ve native ButtonGroup |
| Segmented | leading/middle/trailing, XS/S/M; native seçim ve opt-in checkmark |
| Split | `splitLeading`, `splitTrailing`; iki native hedef, tüketicinin native Menu’sü |
| FAB | `fabSmall`, `fab`, `fabLarge`, `fabExtended` |
| Inline FAB menu | `fabMenuToggle`, `fabMenuAction`; tüketicide native button/Flickable bileşimi |
| Menu | native `SK.Menu` / `SK.MenuItem`; Material3 renk/ölçü ve tek gölge eşlemesi |

Güncel Qt geometri baseline'ı pinned QmlMaterial'dır: common XS/S/M/L/XL paint
32/40/48/56/72 px, yatay padding 16/24/24/32/32 ve içerik aralığı 8/8/8/12/12.
Default Small 24/24 px insets, idle radius 20 / pressed radius 8 kullanır. Önceki
16 px Small padding ilk prototipin tarihsel sözleşmesidir. Google MDC-Android
1.13.0 semantik renkleri, Label Large, native font satır kutusu ve dikey padding 10
korunur; karşılaştırmanın seed/scheme eşlemesi Theme üzerinden açıkça yapılır.
FAB Small/Normal/Large köşeleri 4/16/28, Extended köşesi 16'dır. Extended leading
ikonla 16 / text-only 20, trailing 20 ve gap 12 kullanır; RTL bu mantıksal inset'leri
çevirir. Tam ölçü tablosu [DESIGN.md](DESIGN.md) içindedir.

```qml
SK.Button {
    text: qsTr("Kaydet")
    SK.StyleVariation.variations: ["buttonLarge", "filledTonal"]
}
```

Qt 6.12’de aynı alanı yazan variation’larda **listedeki ilk isim kazanır**.
Size/shape önce, appearance sonra verilir. Kit kayıtları Light/Dark Theme
katmanındadır; Theme varsayılanlarının Style katmanındaki variation’ları ezmesi
önlenir. Qt’nin dinamik variation cache hatası için SDK değiştirilmez; bu
örnekte variation listeleri nesne kurulurken belirlenir. Mevcut butonda listeyi
sonradan ekleme/kaldırma düzelmiş sayılmaz.

Native StyleKit button, style verisindeki özel content factory’yi otomatik
kullanmaz. Recipe ikon ölçüsü, segmented checkmark, split ok dönüşü ve FAB
içeriği için açık, isteğe bağlı içerik delegate’i vardır:

```qml
SK.Button {
    id: addButton
    text: qsTr("Oluştur")
    icon.source: "icons/add.svg"
    SK.StyleVariation.variations: ["fabExtended"]
    contentItem: Material3ButtonContent { control: addButton }
}
```

Karşılaştırmadaki Create, aynı native butonda `display` değerini
`TextBesideIcon` / `IconOnly` yaparak genişler/daralır; metin, erişilebilir ad ve
sabit variation listesi korunur. İki inline FAB stack 280 px referans alanında
iki/altı eylem, seçimle kapanış, Escape, klavye dolaşımı ve uzun liste scroll'u
sunar. Sequence/spatial/effect 400/200/100 ms süreleri Qt uyarlamasıdır; reduced
motion'da anlık sonuç uygulanır. Qt 6.12 variation `fonts` sağlamadığı için menu
action `font: tokens.titleMedium` (16/500) tüketicinin kendi Theme binding'idir;
SDK değişikliği veya sayfa bazlı style koşulu gerekmez.

Bu bir button wrapper değildir; MButton’a ait private factory sözleşmesi
taşınmaz. `icon.name/source/color/cache` API’si korunur; paketli isim AppIcon’a, native isim/source Qt IconLabel’a gider. Helper’ın
`iconWidth` / `iconHeight` varsayılanı recipe ölçüsüdür; tüketici native ölçü
binding’ini istediğinde açıkça `iconWidth: addButton.icon.width` ve
`iconHeight: addButton.icon.height` bağlar. Kontrolün bu property’lerine kit
yazmaz. Helper native icon yolunda Qt 6.12’nin kendi SK.Button’ıyla aynı internal `IconLabel`’ı
kullanır; bu QML iç API’si yeni Qt sürümünde tekrar sınanmalıdır.

Renk rolleri Merce palette şemasından kopyalanmaz; kitin kendi Google M3
primary/secondary/container/surface/outline çiftleri kullanılır. Optik geometrinin
kanonik kaynağı `tokens/material3.json`; [üretici](tools/README.md) isteğe bağlı
Node stdlib aracıdır, CMake/runtime Node bağımlılığı değildir.

## QmlMaterial karşılaştırması

[Karşılaştırma tüketicisi](examples/qmlmaterial-comparison) önceki Actions
galerisinin sırasını, metinlerini, objectName değerlerini ve yatay scroll/focus
reveal davranışını korur. Stil yalnız `Main.qml`’de seçilir. Merce Theme,
Platform, Foundation veya Runtime bağlantısı yoktur.

```sh
qt-cmake -S examples/qmlmaterial-comparison -B build-comparison -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug -DQAVSI_MATERIAL3_SOURCE="$PWD" \
  -DQAVSI_ICONS_SOURCE="$PWD/../icons"
cmake --build build-comparison --parallel
ctest --test-dir build-comparison --output-on-failure
```

Aynı örnek installed tüketimde `QAVSI_MATERIAL3_SOURCE` verilmeden kurulu
`QavsiMaterial3` paketini bulur. QML Preview MCP’ye
`build-comparison/qavsi-material3-comparison.app/Contents/MacOS/qavsi-material3-comparison`
verilir. Native pencere sol ekranın sol yarısında açılır.

Güncel canlı karşılaştırma **QmlMaterial v0.6.1 (`191260585a82`)** üzerinden
yapılır. Önceki benchmark ve piksel ölçümleri kendi **`229bc3e64ff7`** kaynak
pinlerini korur. Güncel referans ayrı checkout/build olarak kullanılır;
kitin dependency’si veya alt modülü olmaz. Örnek ikonları bağımsız Qavsi.Icons.Material sağlayıcısından gelir.
Galeride paketli isimler sabittir; selected FILL kararını stilin parameters
politikası belirler. Font ve katalog Icons sağlayıcısına aittir.

Dot/count/capped/text badge’ler ayrı [Badge ailesindedir](docs/families/badge.md).
Rail/drawer, fields, slider ve tabs bu ekranın kit kapsamı
sayılmaz. Split menüsü, referans gibi sahne içi Popup.Item üzerinde Qt fallback’idir;
Material3 Menu aktarılmış sayılmaz.
İki inline FAB stack bu dilimdedir; tüm Expressive FAB menu ailesinin eşliği
iddia edilmez. Group neighbor-width redistribution ve font eksen animasyonu
halen kapsam boşluğudur. Bütün eski aile ilerlemesi
[aktarım envanterinde](docs/migration/legacy-comparison-inventory.md) korunur.

### Referans galerisi ve kit API'si

The gallery follows QmlMaterial: Common XS/S/M; Icon XS/S/M/L and S
Narrow/Default/Wide. The kit retains the public XS–XL roles in both families.
Routine tests cover public control behavior and caller bindings; exhaustive
size/shape comparison is separate. See [TESTING.md](TESTING.md).

Standalone icon plate/native hedef ölçüleri XS 30/40, S 40/48, M 56/64, L 96/104,
XL 136/144'tür. Native StyleKit background margins inset'lere eşlenir: XS 5,
diğerleri 4; padding 8, spacing 0. XS'nin referans 38 hedefi yerine minimum 40 Qavsi
uyarlamasıdır. Caller width/height binding'leri korunur; örneğin S 100×80 içinde
plate 92×72 olur. Kit normal QML implicit ölçülerini yeniden yazmaz.

Standard checked yüzey transparent/primary ink; Filled/Tonal toggle unchecked
`surfaceContainerHighest`, selected `primary`/`secondaryContainer` kullanır. Outlined
selected inverse-surface renklerini ve 1 px border'ını korur. M checked/pressed
köşeleri 16/12'dir. Tema, native checked/input API'si ve software painter yolu
aynı sözleşmeyi izler; tam tablo [DESIGN.md](DESIGN.md) içindedir.

`ComparisonMetrics.qml`, yalnız bu tüketicinin 36 px appearance ve 12 px common
size sıra aralığını taşır. Kit Theme'ına demo metriği eklenmez. QmlMaterial'ın
`mdState.type/size` ayarlarını native `SK.Button` + statik variation rollerine
çeviren [örnek ve aktarım sınırları](docs/migration/README.md) ayrı belgelenir.
With Badges, tek native SK.Label tabanlı Material3Badge ile ayrı aile olarak
aktarılır; MD kontrol sarmalayıcısı veya genel runtime eklenmez.

Qt 6.12.0'ın loaded-style dinamik reader font başlangıcı ayrıca sınırlıdır.
Earlier dynamic size probes and their font-reset preparation are no longer part
of the routine suite. This does not fix the SDK limitation documented in
[DESIGN.md](DESIGN.md). The current test policy is [TESTING.md](TESTING.md).

## Source tüketimi

Uygulamanın CMake'i:

```cmake
add_subdirectory(path/to/material3 material3)
target_link_libraries(my_app PRIVATE QavsiMaterial3::Style)
# qt_add_qml_module(my_app ...) içine:
# IMPORT_PATH "${QavsiMaterial3_QML_IMPORT_DIR}"
```

Depoyu edin ve kökünden gerçek örneği bağımsız source consumer olarak derle:

```sh
git clone https://github.com/Qavsi/material3.git
cd material3
```

```sh
qt-cmake -S examples/small-button -B build-source -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug -DQAVSI_MATERIAL3_SOURCE="$PWD" \
  -DQAVSI_ICONS_SOURCE="$PWD/../icons"
cmake --build build-source --parallel
ctest --test-dir build-source --output-on-failure
```

## Installed tüketimi

```sh
qt-cmake -S . -B build-package -G Ninja -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_INSTALL_PREFIX="$PWD/prefix" -DQAVSI_MATERIAL3_BUILD_EXAMPLE=OFF \
  -DQAVSI_ICONS_SOURCE="$PWD/../icons"
cmake --build build-package --parallel
cmake --install build-package
qt-cmake -S examples/small-button -B build-installed -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug -DCMAKE_PREFIX_PATH="$PWD/prefix"
cmake --build build-installed --parallel
ctest --test-dir build-installed --output-on-failure
```

Installed uygulama `find_package(QavsiMaterial3 0.1 CONFIG REQUIRED)` ve aynı
`QavsiMaterial3::Style` / `QavsiMaterial3::Theme` target'larını kullanır. QML
tooling import kökü relocatable `QavsiMaterial3_QML_IMPORT_DIR` metadata'sıdır;
runtime `QML_IMPORT_PATH`, `addImportPath` veya Merce build dizini gerekmez.
QML plugin'leri, qmldir ve qmltypes de kurulur; yalnız dylib kopyalamak yeterli değildir.
Internal background factory/data QML dosyaları ve C++ registration metadata'sı da
aynı paketle taşınır; consumer'a ek modül veya runtime kurulumu gerekmez.

Library-only configure Qt Test istemez. Bu doğrulama örneğinin `--check` yolu Qt
Test kullanır. CTest offscreen/software çalışır. Gerçek macOS Metal kontrolü:

```sh
QSG_RHI_BACKEND=metal build-source/qavsi-small-button.app/Contents/MacOS/qavsi-small-button --check
QT_QUICK_BACKEND=software build-source/qavsi-small-button.app/Contents/MacOS/qavsi-small-button --check
```

Contract check'leri pointer ripple başlangıcı/çıkışı, cancel/disable/hide temizliği,
Tab/Backtab halkası, mouse focus ayrımı, merkezden klavye feedback'i, tek activation,
azaltılmış hareket ve caller binding/geometry korunmasını kapsar. Aile check'leri
common/FAB ölçüleri ve durumları, Create display geçişi, inline FAB menu
klavye/focus/scroll davranışını da sınar; çalıştırma sonuçları aşağıdaki kanıtlardadır. Source/installed
tüketiminin bağımsız repo doğrulaması [aktarım raporundadır](evidence/EXTRACTION.md).
İlk renderer çalıştırmaları [tarihsel raporda](evidence/VERIFICATION.md) korunur.

## Shader / painter performans karşılaştırması

Örneğin `--benchmark` yolu yalnız ölçüm sahnesidir; public Style API'sinde renderer
zorlama seçeneği yoktur. Release build'de, aynı Metal backend'inde iki yolu ölçer:

```sh
QSG_RHI_BACKEND=metal build-source/qavsi-small-button.app/Contents/MacOS/qavsi-small-button --benchmark=shader --items=100
QSG_RHI_BACKEND=metal build-source/qavsi-small-button.app/Contents/MacOS/qavsi-small-button --benchmark=painter --items=100
```

1/100/400 adet 72×40 feedback yüzeyi, aynı renk/hareket, 2 saniye ısınma ve 5 saniye
örnek kullanılır. Önce bütün yüzeylerde gerçek idle/pressed/köşe pikselleri sınanır.
CPU/frame süreç CPU'sudur; `frameSwapped` aralıkları render thread'de ölçülür.
GPU süresi, bütün kontrol ağacı veya tam uygulama maliyeti değildir. Ölçümü build,
UI input veya diğer benchmark süreçleriyle paralel çalıştırmayın. Ham koşular ve
iki sıralı/ters sıralı turun ortalamaları [raporda](evidence/VERIFICATION.md).

## QML Preview

Debug örneği `QT_QML_DEBUG` ile derlenir. QML Preview MCP'ye macOS'ta
`build-source/qavsi-small-button.app/Contents/MacOS/qavsi-small-button` verilir.
Uygulama public QScreen API'siyle soldaki ekranı seçer. Preview alanı QML root
başlangıç girdisidir; yeniden yüklemede de sol ekran yerleşimi korunur.
Örnek, uygulama içinde `Qt::TabFocusAllControls` seçer; macOS sistem ayarını
değiştirmeden bütün düğmeler Tab/Backtab ile erişilebilir olur. Native testler
animasyon saati ve klavye girişi için kendi sol ekran penceresini aktif eder.

## Kanıtların kapsamı

Mevcut buton ailesinin güncel source/installed, Metal/software ve aktarım
sonuçları [güncel buton aktarım raporu](evidence/BUTTON-FAMILY.md) içindedir.
Önceki sol ekran/MCP hot reload incelemesi ile bu turdaki geometri/FAB
kalibrasyonu [görsel inceleme notlarında](docs/migration/button-family-visual-review.md)
ayrılır. Yeni koşuların kabul durumu aktarım raporundadır; tarihsel UI kanıtı yeni
tarifin doğrulanması yerine geçmez.


[evidence/VERIFICATION.md](evidence/VERIFICATION.md) ve bağlı ham log/görüntüler,
2026-10-25 tarihli ilk Small Button doğrulamasını korur. İçlerindeki eski geçici
ve Merce altı kaynak yolları tarihsel çalışma konumlarıdır; build bağımlılığı
veya tüketici konfigürasyonu değildir. Repo aktarımının yeni source/installed
doğrulaması [EXTRACTION.md](evidence/EXTRACTION.md) altında kaydedilir; eski sonuçlar
yeni çalıştırma diye sunulmaz.

[Görsel sözleşme](DESIGN.md) · [Bağımsız repo doğrulaması](evidence/EXTRACTION.md) · [Tarihsel renderer kanıtı](evidence/VERIFICATION.md)

## Seed tabanlı Material renkleri

Mevcut varsayılan palette ve caller renk override'ları korunur. Dinamik renkler
Theme üzerinden açıkça seçilir; kontrollerde stil/renk koşulu eklenmez:

```qml
import Qavsi.Material3.Theme

Material3Theme {
    dynamicColors: true
    seedColor: "#bee7fd"
    scheme: MaterialColorScheme.Neutral
    contrastLevel: 0
    dark: false
}
```

Bu Theme'i `Material3Style.lightTokens` ve dark:true olan ayrı örneğini
`darkTokens` girdisine verin. `TonalSpot` da desteklenir; kit varsayılanı
dynamicColors:false olduğundan mevcut uygulamaların rengi değişmez.
Karşılaştırma uygulaması QCM'nin `#bee7fd / Neutral / contrast0` girdilerini
iki mod için eşitler. Qt6.12 source/installed tüketimi aynıdır; MCU yalnız Theme
library'sine gömülen private implementation'dır, yeni runtime bağımlılığı yoktur.
Örnek kurulumuna ve QCM reference checkout'una ihtiyaç duymadan çalışır.

`QAVSI_MATERIAL3_BUILD_TESTS=ON` ile `material-colors` testi QCM'den bağımsız
kaydedilmiş12 referans senaryoyu, canlı seed/tema geçişini ve override sahipliğini
sınar. Renk girdileri ve kapsam sınırları [DESIGN.md](DESIGN.md#material-color-utilities)
içindedir. MCU [Apache-2.0](third_party/material-color-utilities/LICENSE) lisanslıdır.

## Paketli Material ikonları

Material3'ü kaynakla bağlarken önce Icons'u ekleyin veya kit configure'ına
`-DQAVSI_ICONS_SOURCE=/path/to/Qavsi/icons` verin. Kurulu kullanımda önce Icons
paketini kurun; Material3 config yalnız Core component'ini ister. Metin/native
QIcon tüketicisi Material fontunu yüklemek zorunda değildir.

```qml
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Style
import Qavsi.Icons.Material

SK.Button {
    id: settings
    icon.name: "material:settings"
    display: SK.Button.IconOnly
    checkable: true
    SK.StyleVariation.variations: ["iconSmall", "iconStandard"]
    contentItem: Material3ButtonContent { control: settings }
}
```

Uygulama `QavsiIcons::Material` target'ını bağlar; module IMPORTS metadata'sı da
aynı sağlayıcıyı seçebilir. Paketli adın stock SK.Button içeriğinde otomatik
çalıştığı iddia edilmez: açık content delegate gerekir. AppIcon'ın bağımsız
doğrudan kullanımı `import Qavsi.Icons` üzerinden yapılır; size/color caller'a,
font ve FILL çizimi sağlayıcıya, checked→filled politikası stile aittir.
Bare Qt icon.name ve icon.source desteği değişmez. Native source bridge yerel/qrc
varlıklara yöneliktir; SF/FontAwesome sağlayıcıları bu dilime dahil değildir.

QCM realistic ripple: Metal shader wave/ring/sparkle/turbulence matematiğini
doğrudan uyarlar. Software painter aynı yumuşak dalga ve input zamanlamasını
korur; sparkle noise çizmez. Hold sırasında yalnız Metal noise phase animasyonu
çalışır. Reduced motion statik %12 base kullanır. Skia/QCM kitaplığı bağlanmaz;
kaynak/lisans kayıtları third_party/ripple-reference altında kuruluma dahildir.


### QCM button elevation

Elevated buttons and FABs use the pinned QCM/Skia-derived shadow paths internally:
analytic ambient/spot for equal corners and Gaussian Outer BlurMask for unequal
corners. The renderer uses StyleKit's native `background.shadow.delegate` slot,
so there is exactly one shadow. Material3 owns levels, lighting, blur recipe and reduced motion;
applications keep native `SK.Button` and existing variations. Skia/QCM are not
kit build or runtime dependencies. Software retains painter feedback and omits
GPU shadows. OpenGL needs version 3 or newer; the macOS comparison bootstrap
requests a 3.3 core context, and legacy contexts suppress unsupported shadows.
GLES-targeted builds retain QCM's GLES shader guard.

[Shadow verification](evidence/ANALYTIC-SHADOW.md) records source/installed tests,
Metal/OpenGL pixel parity, Qt alpha adaptations and measured performance scope.
Adapted source pins and licenses install with the kit.


Menü yüzeyi `surfaceContainer`, satırlar LabelLarge kullanır. Menü minimumu
200 px, satır yüksekliği 48 px, köşeler 4 px ve dikey iç boşluk 8 px'dir;
bütün değerler Theme token'larından gelir. Klavye, seçim ve kapanış native
`SK.Menu`'de kalır. Inline FAB menüsünün `+ / ×` tetikleyicisi 6/8 elevation
alır; eylem satırları düz kalır. Menü item ripple
Metal'de mevcut shader, software'da mevcut painter ile çizilir. Butonun %12
press davranışı korunur; QCM 0.6.1 menü tarifi %10 kullanır. Native popup hareketi
için `enter: Material3MenuEnterTransition { control: menu }` ve
`exit: Material3MenuExitTransition { control: menu }` açıkça bağlanır. Süre/easing
Theme'den gelir; kontrol `SK.Menu` kalır. Public Qt API sınırları ve mid-motion
reduced davranışı [DESIGN.md](DESIGN.md) içinde açıklanır.


## Native text fields

```qml
SK.TextField {
    placeholderText: qsTr("Name") // outlined; floats on focus or a value
}
SK.TextField {
    placeholderText: qsTr("Email")
    SK.StyleVariation.variations: ["textFieldFilled"]
}
```

The Material3 style is selected once at the window. Native text, validator,
readOnly, enabled, font and padding APIs remain available; no MTextField is
required. An initial nondefault placeholderTextColor keeps the native placeholder
instead of the floating caption. Use the Theme's semantic roles for its color.
The comparison app includes editable outlined/filled and invalid/disabled/read-only
examples. [DESIGN.md](DESIGN.md) defines the recipe; [BACKLOG.md](BACKLOG.md) lists
remaining button work. XS–XL appearance/size recipes are available:

```qml
SK.TextField {
    placeholderText: qsTr("Filled · XS")
    SK.StyleVariation.variations: ["textFieldFilledExtraSmall"]
}
SK.ComboBox {
    model: [qsTr("Small"), qsTr("Medium"), qsTr("Large")]
    ComboBoxSupport.label: qsTr("Size")
    SK.StyleVariation.variations: ["comboBoxSmall"]
}
```

TextField recipe names combine `textFieldFilled` or `textFieldOutlined` with
`ExtraSmall/Small/Medium/Large/ExtraLarge`. ComboBox names use `comboBox` with
the same size suffixes. Defaults are medium. Set the complete recipe at creation;
Qt 6.12's dynamic variation limitation still applies. These recipes supply the
QCM font size/tracking and geometry while retaining native editing APIs.

### Prefix, suffix, icons and messages

```qml
import Qavsi.Icons.Material

SK.TextField {
    placeholderText: qsTr("Amount")
    validator: DoubleValidator { bottom: 0; decimals: 2 }
    TextFieldSupport.prefix: "$"
    TextFieldSupport.suffix: "USD"
    TextFieldSupport.leadingIcon: "material:payments"
    TextFieldSupport.trailingIcon: "material:info"
    TextFieldSupport.supportingText: qsTr("Enter the amount before tax.")
    TextFieldSupport.errorText: qsTr("Enter a valid amount.")
}
```

`TextFieldSupport` comes from Qavsi.Material3.Style. Only the chosen icon provider
must be imported; the style depends on Qavsi.Icons Core, not a specific font.
Affixes never enter the native text or validator value. Icons are decorative.
The message wraps and contributes to implicitHeight. Error follows
`!acceptableInput`; a server error can bind TextFieldSupport.error explicitly,
and assigning undefined restores native validation. The error message replaces
supporting text and updates the default accessible description.

Nondefault native padding/insets or an explicit accessible description keep
caller ownership. Custom geometry must leave enough space for accessories;
default geometry is augmented/restored automatically by the delegate.


## Native progress

`SK.ProgressBar` defaults to QCM linear styling; `progressCircular` selects the
circular recipe. `SK.BusyIndicator` keeps native `running` with circular motion.
For live indeterminate mode changes on Qt 6.12.0, opt into the content helper:

```qml
SK.ProgressBar {
    id: download
    value: application.progress
    indeterminate: application.totalUnknown
    Accessible.name: qsTr("Download progress")
    contentItem: Material3ProgressContent { control: download }
}
SK.ProgressBar { SK.StyleVariation.variations: ["progressCircular"]; value: 0.6 }
SK.BusyIndicator { running: application.loading; Accessible.name: qsTr("Loading") }
```

The helper follows the selected `Material3Style` Theme and reduced motion.
See [family usage, SDK boundary and rendering limits](docs/families/progress.md).

## Native ComboBox

```qml
SK.ComboBox {
    model: [qsTr("Personal"), qsTr("Team"), qsTr("Production")]
    ComboBoxSupport.label: qsTr("Workspace")
}
```

Select Material3Style once at the window. The private field/popup/row factories
follow that style; consumer pages need no style condition or custom input router.
`model`, `textRole`, `valueRole`, `currentIndex`, `currentValue`, `editable`,
`editText`, `accepted` and `activated` keep native semantics. The caption floats
on focus or a value, and selected-row color is independent of navigation/hover.

The popup width cap comes from Theme (280); height follows available window
space. Caller-defined popup/delegate/contentItem are preserved.
The ComboBox is outlined, matching the pinned QCM implementation; no filled
ComboBox variant is exposed. [ComboBoxGallery.qml](examples/qmlmaterial-comparison/ComboBoxGallery.qml)
shows string/role models, editable/disabled controls and caller-owned factories.

### Navigation, Switch and Slider

The comparison also contains the QCM navigation bar, isolated icon rail items,
primary tabs, four Switch examples and horizontal/vertical Slider/RangeSlider
examples. Controls remain native StyleKit types; family rendering lives in
`internal/navigation`, `internal/switches` and `internal/sliders`.

```qml
SK.Switch {
    checked: true
    icon.name: checked ? "material:check" : "material:close"
    icon.width: tokens.switchIconSize
    icon.height: tokens.switchIconSize
    icon.color: checked ? tokens.switchCheckedIcon : tokens.switchIcon
}
SK.Slider {
    from: 0
    to: 100
    value: 40
    stepSize: 1
    SliderSupport.readOnly: saveJob.running
    SliderSupport.labelBehavior: SliderSupport.LabelVisible
    SliderSupport.tickVisibilityMode: SliderSupport.TickAutoLimit
}
```

Here `tokens` is the selected Material3Style.tokens instance and `saveJob.running`
is application state. Qt 6.12 does not supply a switch icon size/ink style slot,
so the optional native icon fields are explicit Theme bindings. Native Slider
steps, snap modes, live updates and RangeSlider first/second values are unchanged.
Use `sliderMedium` with SliderSupport.insetIcon for the thick inset-icon recipe.
An enforced minimum span for native RangeSlider is not currently supported.

### Checkboxes

Native `SK.CheckBox` has a QCM0.6.1 18px indicator, tick/indeterminate paths,
40px ripple and the kit's keyboard focus ring. Theme, disabled roles, native RTL,
reduced motion and software rendering use the existing kit paths.

```qml
SK.CheckBox { text: qsTr("Selected"); checked: true }
SK.CheckBox {
    text: qsTr("Partial selection")
    tristate: true
    checkState: Qt.PartiallyChecked
}
```

The ordinary default is unchecked. Native Qt owns binary/tristate keyboard and
pointer activation; `nextCheckState` remains available to callers. The style
mirrors the partial state to Accessible.checkStateMixed through public QML.
No support attachment, wrapper or state variation is required. The comparison
shows unchecked, indeterminate, checked and disabled examples.

### Radio buttons

Use native StyleKit controls; sibling radios retain Qt's auto-exclusive selection.

```qml
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Style

Column {
    SK.RadioButton {
        text: qsTr("option 1")
        checked: true
        RadioButtonSupport.readOnly: saveJob.running
    }
    SK.RadioButton {
        text: qsTr("option 2")
        RadioButtonSupport.readOnly: saveJob.running
    }
}
```

`RadioButtonSupport.readOnly` blocks user selection while retaining the enabled
appearance and caller bindings. Programmatic checked updates remain valid. The
comparison gallery shows three options and a Read only switch, matching QCM.

### Chips

Chips retain the native button API. Use one immutable chip role with the content
helper; no Label wrapper or extra selection state is introduced.

```qml
SK.Button {
    id: filterChip
    text: qsTr("Filter")
    checkable: true
    SK.StyleVariation.variations: ["chipFilter"]
    contentItem: Material3ChipContent { control: filterChip }
}
```

Roles: chipAssist, chipFilter, chipInput, chipSuggestion and QCM's chipEmbed.
Input's Material3ChipContent.trailingAction accepts a native Qt Quick Action;
its text names the separate accessible action and its enabled state is honored.
The handler decides whether to update/remove the application item. A trailing X
never activates the parent chip. trailingIconName is decoration only.
The comparison shows enabled/disabled kinds and a constrained long label.

### Shared menu Actions

The comparison's Open action menu uses Qt Quick Actions owned outside the popup.
MenuItem.action supplies text, icon, enabled, checkable and checked automatically;
activation uses the native Action signal without an extra onTriggered bridge.

```qml
import QtQuick.Controls as C

C.Action {
    id: command
    text: qsTr("First action")
    icon.name: "material:add"
}
SK.MenuItem {
    id: item
    action: command
    icon.color: (contentItem as Material3MenuItemContent).color
    contentItem: Material3MenuItemContent { control: item }
}
```

The optional content helper draws package icons through AppIcon while retaining
Qt's native MenuItemIconLabel for text, mnemonics, shortcuts and ordinary QIcons.
The native icon color binds to the helper's StyleReader color; an explicit caller
assignment retains normal Qt binding ownership. QCM's three reference commands
include the long label and its document icon.
