# Bağımsız repo aktarımı ve tüketim doğrulaması

Tarih: **2026-10-25**. Repo: [Qavsi/material3](https://github.com/Qavsi/material3).
Bize ait kod/belgeler **MIT © 2026 Enes Alp**. Mimari kayıtları [Qavsi/qavsi](https://github.com/Qavsi/qavsi) reposundadır.

## Aktarım sınırı

Yeni kaynak ağacı Merce dışında, kendi Git deposundadır. Theme, Style, shader, painter, örnek ve CMake yardımcılarını içeren **20 uygulama dosyası birebir** korundu. Root CMake'e yalnız lisans/notices kurulum kuralı eklendi; tüketim belgeleri ve yayın kapsamı güncellendi. Orijinal çalışma taslakları silinmedi; SDK/MButton değişikliği yapılmadı.

Public target'lar `QavsiMaterial3::Theme` / `QavsiMaterial3::Style`, QML URI'leri `Qavsi.Material3.Theme` / `Qavsi.Material3.Style` olarak korunur. Eski ham loglar yayımlanmaz; uygulama penceresiyle sınırlı görüntüler ve önceki benchmark özeti tarihsel kanıttır.

## Temiz çalıştırmalar

Qt **6.12.0**, macOS **26.5.2 arm64**, AppleClang **21.0.0.21000101**, CMake **4.4.3**, Ninja, Debug. CMake minimumu 3.30'dur; 3.30 executable'ı ayrıca sınanmadı.

| Senaryo | Assertion | Failure |
|---|---:|---:|
| Source consumer, offscreen/software | 118 | 0 |
| Relocated installed consumer, offscreen/software | 118 | 0 |
| Source consumer, gerçek Cocoa/Metal | 122 | 0 |
| Relocated installed consumer, gerçek Cocoa/Metal | 122 | 0 |
| Relocated installed consumer, gerçek Cocoa/software | 120 | 0 |

Source Theme/Style/example ve installed example, SDK `qmllint --max-warnings 0` ile geçti. Sayılar bağımsız test case sayısı değil, assertion sayısıdır.

[Gerçek loglardan üretilen sonuçlar ve 20 dosyanın SHA-256'ları](extraction-results.json). Ham koşum logları geçici test dizininde tutuldu.

## Source / installed izolasyonu

- Source tüketicisi yeni kit reposunu `add_subdirectory` ile alır.
- Library-only build, örnek kapalı olarak derlenip kuruldu; lisanslar pakete dahil.
- Install prefix taşındı; ilk prefix artık yokken installed consumer configure edildi.
- Consumer örneği kaynakları ayrı bir geçici dizine kopyalandı; kit kaynak klasörü veya `QAVSI_MATERIAL3_SOURCE` seçeneği kullanılmadı.
- `find_package` ve relocatable import-root metadata'sı kurulu prefix'i kullandı.
- Export/link kayıtlarında Merce/Runtime bağımlılığı veya kit source/build yolu yok.
- Installed consumer Qt ShaderTools aramadı; gömülü `.qsb` ile Metal'de çalıştı.
- Runtime `QML_IMPORT_PATH` / `addImportPath` çözümü eklenmedi.
- Native testler yalnız sol ekranda çalıştı.

Yeniden üretim: [README source/installed adımları](../README.md). Kurulum adımlarından sonra prefix'i taşı ve tüketiciyi kaynak ağacından ayır:

```sh
mv prefix prefix-relocated
cp -R examples/small-button /tmp/qavsi-installed-consumer
qt-cmake -S /tmp/qavsi-installed-consumer -B build-installed -G Ninja \
  -DCMAKE_BUILD_TYPE=Debug -DCMAKE_PREFIX_PATH="$PWD/prefix-relocated"
cmake --build build-installed --parallel
ctest --test-dir build-installed --output-on-failure
```

Qt kendi SDK konumundan bulunmalıdır; bu prefix yalnız Qavsi paketidir. Kit kaynak build'i ShaderTools ister; installed tüketim istemez.

## Yayın öncesi inceleme

Altı QML geçişi (binding, layout, lifecycle, delegate, state, performance), C++ ownership/thread/fallback ve CMake/export/install kontrolünde aktarımı engelleyen somut hata bulunmadı. Ek deterministik tarayıcı mevcut kaynakta 21 QML ve 25 C++ biçim/pattern notu üretti; bu aktarımda toplu stil değişikliği yapılmadı. SDK strict qmllint sonucu ayrı olarak sıfır uyarıdır.

MIT bizim implementasyonumuzu kapsar; Qt dış bağımlılık, Google tasarım girdileri sürümü sabit referanstır. [Üçüncü taraf notları](../THIRD_PARTY_NOTICES.md).

## Sınırlar

Bu ilk Small Filled dilimi stable SDK veya bütün Material3 kontrol ailesi değildir. Windows/Linux/WASM, static Qt ve üretim deployment/signing sınanmadı. Kurulu SDK'nın optional QmlAssetDownloader/Qt6TaskTree configure uyarısı ve offscreen font alias uyarısı bu kontrolleri engellemedi. Performans bu aktarımda yeniden ölçülmedi; önceki ölçümlerin kapsamı [tarihsel raporda](VERIFICATION.md) ayrı belirtilir.
