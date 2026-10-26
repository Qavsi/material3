# Merce Material3 aktarım envanteri

Bu dizin, önceki Merce StyleKit çalışmasını bağımsız Qavsi Material3 kitine
aktarırken kaynakları ve kalan işleri korur. **Yeni kitin bütün kontrollerde
QmlMaterial eşliği sağladığı anlamına gelmez.** Çalışan kapsam ve güncel kanıt
kök `README.md`, `DESIGN.md` ve `evidence/` altında tutulur.

İlk aktarım kapsamı **buton ailesi ve karşılaştırma uygulamasıdır**. Diğer
kontrollerin önceki ilerlemesi silinmez; aile envanterinde sonraki aktarım
olarak izlenir. Önceki Merce uygulaması bağımsız kitin çalışma zamanı bağımlılığı
olmaz ve bu aktarım için değiştirilmez.

- [Önceki uygulama, aileler ve taşınacak testler](legacy-comparison-inventory.md)
- [QmlMaterial sabit referansı, kaynak haritası ve lisans](upstream-reference.md)
- [2026-10-25 resmi GitHub metadata kaydı](upstream-snapshot.json)
- [QmlMaterial MIT bildirimi](QMLMATERIAL-LICENSE.txt)
- [Ayrı yerel referans build sonucu](reference-build.md)

## Aktarım kuralları

1. Karşılaştırma ekranı pinned QmlMaterial kaynağındaki bölüm, örnek sırası ve
   görünür seçim sayısını izler; karşılık gelen metin ve `objectName` değerleri
   korunur. Önceki galeriye eklenmiş boyutlar referans kapsamını genişletmez. Merce `Theme` şemasını taklit eden bir
   uyumluluk singleton'ı eklenmez; token'lar kitin kendi typed Theme'ına taşınır.
2. Kök QML'de tek `Material3Style` seçilir. Sayfalarda seçili stile göre koşul
   yazılmaz. Native `SK.Button` input, focus, `Action`, `enabled`, `checked`,
   `icon.source` ve `display` sahipliğini korur.
3. Görsel tarifler, variation ve delegate katmanına taşınır. Eski MButton'ın
   içerik factory protokolüne bağlı davranışlar, yalnız background kopyalanarak
   taşınmış sayılmaz. `MButton`, `AppIcon`, `Merce.Platform` veya Runtime yeni
   tüketiciye import edilmez.
4. Her alt aile aynı source/installed tüketiciyle ve software/Metal üzerinde
   doğrulanır. Eski Merce test sonuçları yeni kitin sonucu olarak gösterilmez.
5. Loading, font paket adı, otomatik seçili checkmark veya FAB morph gibi ek
   yetenekler native StyleKit API'sinde yoksa açık bir kit sözleşmesiyle ele
   alınır. Uygulama binding'lerine imperatif yazılarak veya görünmezce kontrol
   nesnesi yeniden oluşturularak bir Qt hatası gizlenmez.
6. Eski `PARITY.md` içindeki uzun Merce bağlamı ve kişisel geçici kanıt yolları
   çalışma dokümanı olarak aynen yayımlanmaz. Yeniden çalıştırılan kanıtlar
   ayrı, taşınabilir dosyalarla kaydedilir.

## QmlMaterial'dan native StyleKit'e dönüşüm

Kaynak QmlMaterial kontrolünün tip/boyut ayarları:

```qml
MD.IconButton {
    mdState.type: MD.Enum.IBtFilledTonal
    mdState.size: MD.Enum.M
    icon.name: MD.Token.icon.settings
    checkable: true
}
```

Qavsi tüketicisinde native kontrol, statik recipe/appearance rollerini kullanır:

```qml
import QtQuick
import Qt.labs.StyleKit as SK
import Qavsi.Material3.Style

SK.Button {
    id: settings
    checkable: true
    icon.source: Qt.resolvedUrl(checked ? "icons/settings-filled.svg" : "icons/settings.svg")
    display: SK.Button.IconOnly
    SK.StyleVariation.variations: ["iconMedium", "iconTonalCheckable"]
    contentItem: Material3ButtonContent { control: settings }
}
```

`Material3Style` composition root'ta seçilir. `mdState` C++ kontrolü/sarmalayıcısı
ithal edilmez; kendi Theme'ımız, StyleKit variation'ları ve custom background /
içerik delegate'i görsel tarifi sağlar. Input, checked, Action, enabled ve
caller binding'leri native Qt'de kalır. Paketli font modülü gerekmez; bu demo
lisansı/hash'i kayıtlı SVG consumer asset'lerini kullanır. Variation listesi
oluşturma sırasında sabittir; Qt 6.12 dinamik cache hatası SDK değiştirilerek veya
buton yeniden oluşturularak gizlenmez.

### Görünür örnekler ve kütüphane kapsamı

- Demo: Common XS/S/M; Icon XS/S/M/L; S Narrow/Default/Wide. Kit ve kaynak API,
  Common/Icon için beş XS–XL boyutunu destekler. Library L/XL sözleşmeleri
  yalnız `checks.cpp` içindeki test-only `QQmlComponent` native SK.Button
  fixture'larına aittir; gizli QML galeri örnekleri değildir.
- Standalone icon: optical/native XS 30/40, S 40/48, M 56/64, L 96/104, XL 136/144.
  Native StyleKit `background.margins` → inset; Theme inset 4/padding 8 kullanır.
  XS minimum 40 için inset 5 olur; kaynak native hedefi 38'dir. Caller açık
  width/height bağladığında background inset'lerin içinde büyür.
- Toggle Standard transparent/primary; Filled/Tonal unchecked `surfaceContainerHighest`,
  checked primary/secondary-container; Outlined checked inverse-surface ve
  border 1. M checked 16/pressed 12. Kesin Theme rolleri [DESIGN.md](../../DESIGN.md)
  içindedir.
- `ComparisonMetrics.qml`: yalnız consumer görünümü için appearance spacing 36,
  common size spacing 12. Kit Theme veya yeni ortak runtime konusu değildir.
- With Badges: dot, count 9, capped 128/99 ve text alarm kaynak envanterinde ayrı
  Badge ailesidir; buton dönüşümüne ek kontrol olarak katılmaz. Genel Menu skin,
  font FILL morph ve group neighbor-width redistribution sınırları korunur.

Qt 6.12.0'da loaded-style dinamik `StyleReader` ilk font reset'ini kaçırır;
completion sonrası native state güncellemesi fontu yeniden çözer. Yalnız C++
fixture hazırlığında enabled false→true geçişi ve before/after font logu vardır;
Label Large 14 px şartı korunur. Bu test hazırlığı genel SDK font hatasını veya
dinamik variation cache hatasını çözmez; kit/public consumer API'sine taşınmaz.
Ayrıntı ve Qt kaynak bağlantısı [DESIGN.md](../../DESIGN.md) içindedir.

Source/installed, Light/Dark, reduced motion ve software/Metal kontrollerinin
sonuçları aşağıdaki güncel aktarım raporuna aittir. Bu dönüşüm notu yeni bir
başarılı build veya UI koşusu ilan etmez.

## Doğrulama durumu

İlk envanter 2026-10-25 tarihli kaynak ve metadata incelemesidir. Ardından
ayrı upstream referansı, LFS asset hash'leri doğrulanarak mevcut Qt 6.12 üzerinde
derlendi; [yerel build raporu](reference-build.md). Bu sonuç Qavsi aktarımının
build, UI, tema, fallback veya piksel eşliği sonucu değildir. Bu alt görevde
QML Preview veya canlı UI başlatılmadı; Qt SDK'sı değiştirilmedi.

## Güncel aktarım kanıtı

Yukarıdaki tarama tarihsel kaynak envanteridir. Yeni kitin buton ailesi için
yeniden çalıştırılan source/installed ve renderer kontrolleri
[BUTTON-FAMILY raporunda](../../evidence/BUTTON-FAMILY.md) tutulur; canlı karşılaştırma ve kalan farklar
[ayrı incelemededir](button-family-visual-review.md).
