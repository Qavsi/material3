# Qavsi Material3 — Small Button

Qt **6.12+**, CMake **3.30+**, C++**20**. Yalnız Qt'ye ve kendi Theme/Style
modüllerine bağlı ilk bağımsız dilim. Geliştirme durumundadır; stable SDK
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
examples/small-button/     aynı source/installed tüketici ve contract check'leri
cmake/                     relocatable paket ve QML export'ları
evidence/                  gerçek çalıştırma kanıtları
```

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
de bu nesneden gelir. Yeni appearance/size variation API'si henüz yayımlanmaz.

Normal, text-only native `SK.Button`, pointer konumundan veya klavyede merkezden
yayılan ripple ve yalnız klavye focus'unda dış halka alır. Internal background
delegate ve pasif `PointHandler`, button'ın input/focus/activation sahipliğini
değiştirmez; caller font, ölçü, padding, spacing ve callback bağları korunur.
Ripple 300 ms `OutCubic` genişler, 180 ms linear söner. 2 px primary halka ve 2 px
dış boşlukla birlikte bu süreler Qt uyarlamasıdır; resmi MDC button motion/ring
ölçüsü olarak sunulmaz. Ayrıntılar ve pinned kaynaklar [DESIGN.md](DESIGN.md) içindedir.

`Material3Style.reducedMotion` bool girdisi varsayılan `false` değerindedir;
`true` statik pressed feedback seçer. `effectiveReducedMotion`, bu girdi ile
Qt 6.12 `Application.styleHints.accessibility.motionPreference` sistem
tercihini OR ile birleştirir. Sistem azaltılmış hareket istiyorsa `false`
animasyonu zorlayamaz. Örnek sayfanın hareket düğmesi manuel girdiyi değiştirir;
aktif press sırasında politika değişimi de uygulanır. Halka dışarı çizildiği
için kırpan layout'larda çevresinde yer bırakılmalıdır.

Metal'de ripple tek shader ile pill'e kırpılır; software'da public
`QQuickPaintedItem::Image` painter yolu korunur. Seçim kit içinde gerçek backend'e
göredir; shader hatası loglanıp painter'a düşer. Focus halkası iki yolda da native
Qt çizimidir. Source build Qt ShaderTools ister; shader pakete gömülür, installed
tüketici ShaderTools veya runtime shader derleyicisi istemez.
Loading, icon, başka boyutlar ve toggle geometrisi kapsam dışındadır.

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
  -DCMAKE_BUILD_TYPE=Debug -DQAVSI_MATERIAL3_SOURCE="$PWD"
cmake --build build-source --parallel
ctest --test-dir build-source --output-on-failure
```

## Installed tüketimi

```sh
qt-cmake -S . -B build-package -G Ninja -DCMAKE_BUILD_TYPE=Debug \
  -DCMAKE_INSTALL_PREFIX="$PWD/prefix" -DQAVSI_MATERIAL3_BUILD_EXAMPLE=OFF
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
azaltılmış hareket ve caller binding/geometry korunmasını kapsar. Source/installed
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

[evidence/VERIFICATION.md](evidence/VERIFICATION.md) ve bağlı ham log/görüntüler,
2026-10-25 tarihli ilk Small Button doğrulamasını korur. İçlerindeki eski geçici
ve Merce altı kaynak yolları tarihsel çalışma konumlarıdır; build bağımlılığı
veya tüketici konfigürasyonu değildir. Repo aktarımının yeni source/installed
doğrulaması [EXTRACTION.md](evidence/EXTRACTION.md) altında kaydedilir; eski sonuçlar
yeni çalıştırma diye sunulmaz.

[Görsel sözleşme](DESIGN.md) · [Bağımsız repo doğrulaması](evidence/EXTRACTION.md) · [Tarihsel renderer kanıtı](evidence/VERIFICATION.md)
