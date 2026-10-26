# Buton karşılaştırması ve geometri kalibrasyonu

2026-10-25 · Qt 6.12.0 · macOS · yalnız sol ekran.

## Önceki baseline UI incelemesi

Qavsi comparison ve ayrı QmlMaterial `229bc3e64ff7` referansı birlikte açıldı.
Qavsi QML Preview MCP oturumunda Main.qml pencere başlığı geçici değiştirildi;
yeniden derleme olmadan native başlık değişti ve özgün dosya geri alındı.
Bu önceki inceleme Common, connected, segmented, split ve FAB bölümlerini,
açık/koyu tema ve full/reduced motion seçimini kapsıyordu. O koşuda Common
butonların dar, normal FAB'ın fazla yuvarlak ve Extended FAB'ın pill olduğu
kaydedildi. Aşağıdaki tarif kalibrasyonu bu farkları hedefler; eski UI kanıtı yeni
değişikliklerin kabul kanıtı sayılmaz.

## Bu turdaki tarif değişiklikleri

| Alan | Güncel sözleşme |
|---|---|
| Common | XS/S/M/L/XL paint 32/40/48/56/72; padding 16/24/24/32/32; gap 8/8/8/12/12. Text-only ve ikonlu butonda aynı inset'ler. Default Small 24/24, minimum genişlik 64, idle radius 20 / pressed 8. |
| Typography | Common Label Large 14/500 korunur. Native QFont satır kutusu ve Small dikey padding 10 Qt uyarlamalarıdır. Önceki Small 16 px padding tarihsel kalır. |
| FAB shape | Small 40/radius 4, Normal 56/radius 16, Large 96/radius 28, Extended 56/radius 16. Hover/press bu rounded rectangle köşelerini değiştirmez. |
| Extended | Minimum genişlik 80; leading ikonla 16 / text-only 20, trailing 20, gap 12. RTL'de mantıksal inset ve optik offset yönü çevrilir. |
| Create | Aynı native SK.Button üzerinde TextBesideIcon/IconOnly ile genişleme ve 56 px ikon hedefine daralma; text/Accessible.name binding'i ve variation listesi korunur. |
| Inline FAB menus | Referanstaki 280 px alanda iki/altı eylem; kısa stack başlangıçta açık, uzun kapalı. Native trigger/action ve clipped Flickable; seçim/Escape ile kapanış ve focus dönüşü, klavye dolaşımı ve uzun liste scroll'u. |
| Motion | Theme sequence/spatial/effect 400/200/100 ms; pinned referanstan Qt uyarlaması. Reduced motion'da reveal/width/opacity anlık son değerine geçer; shader/painter seçimi kitte kalır. |
| Menu action font | Qt 6.12 StyleVariation fonts alanı sağlamaz. Tüketici `font: tokens.titleMedium` (16/500) bağlar; stil koşulu veya SDK değişikliği eklenmez. |

Geometri/davranış referansı pinned QmlMaterial'dır. Semantik renkler ve state
layer'lar MDC-Android 1.13.0 kaynağını korur. Tam sözleşme [DESIGN.md](../../DESIGN.md)
içindedir. Bu turun source/installed, Metal/software ve canlı UI kabul durumu
[evidence/BUTTON-FAMILY.md](../../evidence/BUTTON-FAMILY.md) ile kayıt altına alınır;
Test sonuçları kabul raporunda; güncel çalışan UI gözlemleri son bölümdedir.

## Kalan farklar ve kapsam

| Alan | Durum |
|---|---|
| Palette | Qavsi sabit Google M3 mor şemasını, referans mavi/gri seed şemasını kullanır. Bu bilinçli Theme farkıdır. |
| Demo yerleşimi | Qavsi bağımsız buton ailesi tüketicisidir; referansın tam navigation rail/shell'i aktarılmaz. |
| Split menüsü | Sahne içi Popup.Item üzerinde Qt fallback'idir. Genel Material3 Menu skin ailesi bu dilimde değildir; inline FAB action stack'leri ayrı bileşimdir. |
| Açık kapsam | Group neighbor-width redistribution, font FILL morph ve bütün güncel Expressive ailesinin eşliği iddia edilmez. |

Karşılaştırma piksel düzeyinde eşitlik iddiası değildir. Demo'ya yerel renk
veya stil seçimi koşulu eklenmez; stil/variation/delegate ve kendi Theme
sözleşmesi korunur. Commit/push bu tur kapsamında yapılmaz.

## Referansın macOS açılışı

Referansın ilk native açılışı Linux XDP portal assert'i nedeniyle kapanıyordu.
Yalnız ayrı referans checkout'unda APPLE kaynak seçimi ve Qt public QStyleHints
fallback'i eklendi; Linux DBus kodu macOS'a linklenmiyor. Kaynak widget/QML
tasarımı değiştirilmedi. Ayrıntılar [reference-build.md](reference-build.md) içindedir.

## Güncel çalışan UI kontrolü

Son derleme QML Preview MCP ile açıldı; Qavsi ve yerel QmlMaterial sol ekranda
incelendi. Common buton ölçüleri ve FAB köşeleri karşılaştırıldı. Qavsi'nin
Light/Dark geçişi, Create yazısının kapanıp aynı 56 px ikon FAB'a daralması ve
tekrar genişlemesi, artıdan açılan iki aksiyon listesi gözlendi. Kendi tema paleti
ve tüketici yerleşimi korundu; piksel düzeyinde eşlik iddiası yoktur.

Boş font ailesinin explicit override oluşturduğu doğrulandı; Theme artık boş
girdiyi Application.font.family ile çözüyor. Native Small log'unda gerçek
.AppleSystemUIFont ailesi kayıtlıdır. Güncel sayı ve ham loglar
[kabul raporundadır](../../evidence/BUTTON-FAMILY.md).

## QCM Icon buttons galeri eşlemesi

QML Preview'da dört enabled ve dört disabled appearance, dört boyut (XS/S/M/L)
ve üç Small width mode görüldü; yerel QCM aynı bölümde açıldı. Common görünür
modeli XS/S/M ile sınırlı; kütüphanenin fazladan desteklediği boyutlar testlere
ayrıldı. Görsel/durum farkları StyleKit native margin/padding, variation ve
delegate katmanında düzeltildi; demo renk/çizim hack'i eklenmedi.
With Badges ayrı ve henüz çevrilmemiş aile olarak açık kalır.
