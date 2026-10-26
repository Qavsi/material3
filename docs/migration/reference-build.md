# Ayrı QmlMaterial yerel referans build'i

Tarih: **2026-10-25**. Bu kayıt yalnız sabit upstream referansını açılabilir
hale getirmek içindir; Qavsi Material3 kitinin doğrulama sonucu değildir.

## Sonuç ve sınır

- Baseline: `229bc3e64ff71f1ac88cf73e976637ffbcf7e33c`.
- **Configure ve full upstream build geçti (exit 0)**: uygulama, Material ve
  Layouts QML plugin'leri, qmldir ve qmltypes üretildi.
- Qt **6.12.0**, AppleClang **21.0.0.21000101**, C++20, Ninja, Debug.
- Bu alt görev uygulamayı başlatmadı. Canlı QML import, sol ekran yerleşimi,
  font görünümü, interaction ve Metal/software render henüz bu build kaydıyla
  doğrulanmış sayılmaz; UI görevi ayrıca yürütülür.
- Qt SDK'sı, Git LFS kurulumu veya Qavsi runtime bağımlılıkları değiştirilmedi.
  Hiçbir source/installed Qavsi tüketicisi QmlMaterial'a linklenmez.

## Kaynak ve yerel değişiklikler

Referans kitin dışında `Qavsi/references/QmlMaterial` altında durur. 16 LFS
varlığının 5,370,872 byte içeriği resmi `media.githubusercontent.com` adresinden
alındı. Her varlığın indirilen boyutu ve SHA-256 özeti upstream pointer'ın
`size` / `oid sha256` alanlarıyla eşleşti; [tam kayıt](reference-assets.json).
Git LFS kurulmadığından filtersiz Git durumunda materialized asset'ler değiştirilmiş
görünür; bu varlıkların kaynak içeriği hash üzerinden doğrulanır.

Upstream baseline'a eklenen **yerel test/build** farkları yalnız şunlardır:

1. `example/main.cpp`: `QGuiApplication::screens()` içinden en soldaki ekran
   seçilir. `QQmlApplicationEngine::setInitialProperties()` ile x/y/width/height,
   `engine.load()` öncesinde verilir. Hedef x ekran solundan 930, y kullanılabilir
   üstten 16; width 900, height en çok 940. Daha küçük ekranda kullanılabilir
   alana clamp edilir. Root tipi ApplicationWindow, QQuickWindowQmlImpl'den
   türediği için bu dört Window property kaynaktan desteklenir; canlı yerleşim
   kontrolü yine ayrı gereklidir.
2. `example/CMakeLists.txt`: yalnız Debug konfigürasyonunda `QT_QML_DEBUG`
   tanımlanır; main.cpp o durumda `QQmlDebuggingEnabler` header'ını içerir.
   Üretilmiş Ninja compile girdisinde Debug tanımı doğrulandı. Release'de
   debug tanımı eklenmez.
3. Kök upstream `CMakeLists.txt`: yalnız Clang ve `src/token/icon.cpp` için
   `-fconstexpr-steps=10000000` compiler seçeneği. Qt 6.12 moc'un ürettiği büyük
   IconToken metadata tablosu varsayılan constexpr değerlendirme bütçesini
   aştı. Hata `constexpr evaluation hit maximum step limit` idi; bütçe artırımı
   aynı dosyayı başarıyla derledi. SDK veya runtime kontrol koduna yama değildir.

Bu yerel değişiklikler Qavsi kitinin public API'si veya upstream'in orijinal davranışı
olarak sunulmaz. Referansın orijinal [MIT bildirimi](QMLMATERIAL-LICENSE.txt) korunur.

## Derleme komutu

Mevcut Qt'nin `qt-cmake` aracıyla:

```sh
qt-cmake -S <QmlMaterial-reference> -B <reference-build> -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug -DQM_BUILD_EXAMPLE=ON -DQM_BUILD_TESTS=OFF \
  -DQM_USE_PCH=OFF -DCMAKE_SKIP_INSTALL_RULES=ON
cmake --build <reference-build> --parallel 4
```

Yalnız `--target qm_example` executable'ı derler; shared QML modül/plugin
hazırlığını tek başına tamamlamaz. Bu yüzden default build hedefi de çalıştırıldı.
Kurulum yapılmadı. Upstream'in kendi build-tree QML import yolu bu ayrı
referansa aittir; Qavsi paket tüketim sözleşmesinin parçası değildir.

İlk generated build sistem diski dolduğu için `No space left on device` ile
durdu. Yalnız bu generated dizin harici diskte reference checkout'un yerel
`.qavsi-build/` dizinine taşındı; public kaynak veya başka build silinmedi.
Geçici eski yol symlink olarak korundu. `.qavsi-build/`, yalnız bu checkout'un
`.git/info/exclude` dosyasında dışlanır; public `.gitignore` değiştirilmedi.

Yerel çalıştırılabilir yol:

```text
/Volumes/Mac/SCS/dev/Qavsi/references/QmlMaterial/.qavsi-build/example/qm_example.app/Contents/MacOS/qm_example
```

Uyumluluk symlink yolu:

```text
/private/tmp/qavsi-qmlmaterial-reference-build/example/qm_example.app/Contents/MacOS/qm_example
```

Bu mutlak yollar yalnız makinedeki test konumlarıdır; paket, CMake hedefi veya
public QML import yolu değildir. Ham başarılı build logu `.qavsi-build/reference-build.log`,
varsayılan constexpr bütçesindeki hata `.qavsi-build/reference-build-default-limit.log`
altında yerel tutulur.

## Uyarılar

Configure, opsiyonel Qt QmlAssetDownloaderPrivate plugin'inin eksik TaskTree
bağımlılığına ve upstream'in Qt Quick/QuickShapes private header kullanımına dair
uyarı üretti; configure geçti. İlk qsb üretiminde `spirv-opt` bulunamadı uyarısı
vardı, qsb adımları çıkış hatası vermedi. Qt 6.12 deprecated/registration uyarıları
da kaydedildi. Başarılı build, bu uyarıların canlı UI etkisini veya bütün
upstream özelliklerin Qt 6.12 uyumunu kanıtlamaz.

## macOS UI kontrolü

Yerel harness ayrıca qm_example için MACOSX_BUNDLE ve
dev.qavsi.reference.qmlmaterial kimliği kullanır. Böylece native UI aracı,
upstream görünüm kodunu değiştirmeden referans penceresini tanır.
Çalıştırılabilir paket: .qavsi-build/example/qm_example.app;
ikili: qm_example.app/Contents/MacOS/qm_example.
Bu yalnız yerel test checkout’udur; kitin bağımlılığı değildir.

## macOS portal başlangıç düzeltmesi

İlk native/MCP başlatmasında, kaynak baseline’ın CMake UNIX dalı macOS’u da
Linux XDG portal backend’ine yönlendirdi. Sonuç Xdp::Xdp içinde
“Assertion failed: (res), xdp.cpp:55” idi. Assert kapatılmadı; SDK değiştirilmedi.

Yalnız yerel referans checkout’unda:

- APPLE için ayrı src/platform/macos/macos.cpp seçilir. Linux XDP/FileDialog/
  OpenURI kaynakları macOS’a derlenmez; DBus find/link koşulları APPLE’ı dışlar.
- Sistem Light/Dark bilgisi public QGuiApplication::styleHints() üzerinden gelir;
  colorSchemeChanged mevcut MdColorMgr yenilemesine bağlanır.
- Native accent aktarımı eklenmez; referansın mevcut palette seed’i korunur.
- URL/folder yönlendirmesi public QDesktopServices kullanır. FileDialog için
  projenin mevcut reddeden stub backend’i seçilir; native macOS dosya diyaloğu
  eklendiği iddia edilmez.

Configure/full build geçti. otool -L ile reference libqml_material.dylib’in
QtDBus’a linklenmediği doğrulandı. Offscreen/software başlangıç testinde uygulama
8 saniye hayatta kaldı; XDP assert, QML engine/type/library yükleme hatası yoktu.
Test kendi süreç grubunu kapattı. Yerel log/özet:
.qavsi-build/reference-macos-smoke.log ve reference-macos-smoke.json.

Bu küçük platform düzeltmesi referansı macOS’ta karşılaştırmaya açmak içindir;
kitin kaynak/installed bağımsızlığına veya referansın görünüm koduna eklenmez.
Native Metal, canlı font görünümü ve yan yana UI kontrolü ayrıca yürütülür.


## Son canlı UI kontrolü

macOS APPLE/XDP ayrımı sonrası native uygulama açıldı. Ayrı Qavsi QML Preview
oturumuyla sol ekranda birlikte incelendi; Common/connected/segmented/split/FAB
bölümleri görüldü. Qt SDK veya upstream QML tasarımı değiştirilmedi.
Native pencerede görülmesi tüm upstream özelliklerin veya software renderer
desteğinin doğrulanması anlamına gelmez.
