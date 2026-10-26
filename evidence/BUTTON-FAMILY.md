# Mevcut Material3 buton ailesinin bağımsız aktarımı

Tarih: **2026-10-25** · Qt **6.12.0** · Debug · macOS.
Bu rapor uncommitted çalışma ağacına aittir; yeni commit/push yapılmadı.
İlk Small diliminin EXTRACTION/VERIFICATION raporları tarihsel kanıttır;
bu aktarımın güncel kontrol kapsamı aşağıdadır.

## Taşınan kapsam

Merce Material3 common/icon/connected/segmented/split/FAB tarifleri ve önceki
ActionsGallery sırası korundu. Kit doğrudan SK.Style ve kendi Material3Theme’ını
kullanır. Native SK.Button davranışı korunur; özel içerik opt-in
Material3ButtonContent’tedir. Merce/Runtime import veya link bağımlılığı yoktur.
Eski Merce kaynakları ve MButton değiştirilmedi.

| Tüketici | Offscreen software | macOS Metal | macOS software |
|---|---:|---:|---:|
| Source Small | 121 / 0 hata | 125 / 0 hata | — |
| Installed Small | 121 / 0 hata | — | — |
| Source comparison | 513 / 0 hata | 513 / 0 hata | — |
| Installed comparison | 513 / 0 hata | 513 / 0 hata | 513 / 0 hata |

## Gerçek kontrol kapsamı

- Common appearance, optik boyut / native hedef ayrımı, XS–XL ikon hedefleri,
  Narrow/Default/Wide optik genişlikleri ve native disabled kapısı.
- Native Space, checkable ve exclusive ButtonGroup; split menü aç/kapat,
  sahne içi Popup.Item ve tamamlanan ikon dönüşü; reduced motion iptali.
- Aynı kontrol nesnelerinde tekrar Light/Dark geçişi, helper’sız SK.Button,
  transparent icon tint ve canlı interaction foreground renk bağı.
- Kesirli metin genişliği yüzünden oluşan gereksiz elision regresyonu.
- QmlMaterial common padding/gap ve idle/pressed köşeleri; FAB 4/16/28 ve
  Extended radius 16. Optik inset'ler gerçek label konumundan ölçülür.
- Create aynı SK.Button üzerinde display değiştirerek 56 px ikon FAB'a daralır,
  tekrar genişler; accessible name ve variation listesi korunur.
- İki/altı eylemli inline FAB menüsü; clipped/scrollable viewport, native giriş
  kapısı, klavye/focus dönüşü ve reduced motion uç durumları.
- Boş font girdisi gerçek uygulama ailesine çözülür. Native Metal Small log'u
  .AppleSystemUIFont ve graphicsApi 6 değerlerini doğrular.
- Kapanan/saydam ve sıfır alanlı satırların feedback katmanı ile Loader unload
  sırasında null güvenliği; güncel loglarda QML/painter hatası yoktur.
- Gerçek renderer üzerinden Metal shader / software painter seçimi ve shader
  hata durumunun kontrolü. Önceki Small testleri pointer ripple, focus,
  cancel/disable/hide ve caller binding’lerini de korur.
- Strict qmllint: Theme, Style, source ve installed comparison, max-warnings=0.
  12 recipe stale-output ve numeric/alias/invalid-source testleri geçti.

## Kurulum ve bağımsızlık

Aynı tüketici kit kaynaklarından ayrı bir dizine kopyalandı. Paket kuruldu,
prefix taşındı, ilk prefix kaldırıldı; ayrı tüketici yalnız find_package ile
derlendi. Cache’te source seçeneği/ShaderTools/Merce yok; export ve qmldir içinde
Merce/Runtime, source-build yolu veya ShaderTools bağımlılığı bulunmadı.
Library-only configure iki örneği de kapatır ve Qt Test aramaz.

Google’ın pinned 1.13.0 color XML alias’ları çözüldü: 17 rol çifti / 34 değer,
sıfır fark. URL/hash ve test edilen dosyaların fingerprint’leri
[sonuç JSON’undadır](button-family-results.json). Tam Google/Qt kaynak arşivi
bu repoya kopyalanmadı.

## Görsel kontrol ve sınırlar

QML Preview aktif; geçici başlık değişikliğiyle derlemesiz hot reload doğrulandı
ve kaynak geri alındı. İki uygulama sol ekranda birlikte açıldı. Qavsi Light/Dark,
metinler, common ölçüler ve FAB; referansın aynı alt aileleri canlı incelendi.
Create daralma/genişlemesi ve artıdan açılan aksiyon listeleri görüldü. Native
software klavye kontrolü Preview kapalıyken ayrıca geçti; Preview sonra yeniden açıldı.
Referansın macOS portal açılış hatası yalnız ayrı checkout'ta giderildi.
[Görsel inceleme ve kalan farklar](../docs/migration/button-family-visual-review.md).
Bu rapor tam/piksel düzeyinde QmlMaterial eşliği iddiası değildir.

Önceki aktarımın tek öğeli Debug shader benchmark kontrolü tarihsel kanıttır;
bu geometri kalibrasyonunda yeni performans ölçümü yapılmadı. Önceki 1/100/400 Release ölçümleri tarihsel
Small dilimine aittir; bütün yeni buton ailesi için performans sonucu sayılmaz.

Diğer kontrol aileleri, font provider/axis animasyonu, group width redistribution
ve genel Material3 Menu stili kapsam dışındadır. Split menü
Qt fallback’idir. Qt’nin dinamik variation cache hatası düzeltilmiş sayılmaz;
SDK değiştirilmedi. Internal IconLabel kullanımı Qt yükseltmesinde yeniden sınanmalı.
Linux/Windows/WASM/static Qt/deployment test edilmedi.

Güncel ham test logları: [logs/button-geometry](logs/button-geometry).

## QCM galeri kapsamı ve ikon karşılığı

QCM kaynak kodundaki görünür örnekler aynen seçilir: Common XS/S/M;
Icon XS/S/M/L; Small Narrow/Default/Wide ve dört enabled/disabled appearance.
Kütüphanenin beş boyutlu API'si test-only C++ fixture'larında korunur.
Karşılaştırma galerisine hidden test kontrolü veya test flag'i eklenmez.

Standalone ikonlar native StyleKit background margins/padding kullanır:
optik30/40/56/96/136; native hedef40/48/64/104/144; inset5/4/4/4/4.
XS'de Qavsi minimum40 politikası korunur (referans38). Connected inset0'dır.
Caller100×80 ve120×96 bağları sırasıyla92×72 ve112×88 plate verir.
Standard checked transparent/primary; Filled/Tonal toggle unchecked highest
surface; Tonal checked secondary container; Outlined checked border1 ve
Medium checked16/pressed12 kaynakla eşlendi. Ölçü, durum, tema, reduced motion,
Metal shader ve software painter kontrolleri source/installed513/0 geçti.

QML Preview MCP ve yerel QCM sol ekranda Icon buttons bölümünde incelendi.
Görünür örnek sayıları ve varsayılan yüzeyler karşılaştırıldı; Badge ailesi ayrı
olduğu için bu tur sahte bir karşılık eklenmedi. Tam shell/piksel eşliği iddiası yoktur.

Qt6.12 late StyleReader font başlangıcı SDK kusuru ayrı kaydedildi. Fixture
hazırlığı native enabled false→true geçişiyle fontu gerçek stilden hesaplatır;
font14 koşulu gevşetilmez. SDK ve normal uygulama kodu bu amaçla değiştirilmez.
Güncel ham loglar [icon-buttons](logs/icon-buttons) klasöründedir.
