# QmlMaterial referansı ve provenans

QmlMaterial, karşılaştırma ve kaynak okuma referansıdır. Yeni Qavsi kitine
vendor edilmez; linklenen bir runtime bağımlılığı değildir. Material3 tasarım
kararlarında birincil otorite Google'ın resmi kaynakları ve kitin `DESIGN.md`
sözleşmesidir.

## Sabit karşılaştırma tabanı

Eski karşılaştırmanın kullandığı commit değişmeden korunur:

- Proje: [hypengw/QmlMaterial](https://github.com/hypengw/QmlMaterial).
- Baseline: [`229bc3e64ff71f1ac88cf73e976637ffbcf7e33c`](https://github.com/hypengw/QmlMaterial/tree/229bc3e64ff71f1ac88cf73e976637ffbcf7e33c).
- GitHub commit zamanı: **2026-10-15T14:49:58Z**.
- [Baseline README](https://github.com/hypengw/QmlMaterial/blob/229bc3e64ff71f1ac88cf73e976637ffbcf7e33c/README.md).
- [Baseline MIT lisansı](https://github.com/hypengw/QmlMaterial/blob/229bc3e64ff71f1ac88cf73e976637ffbcf7e33c/LICENSE), bu dizinde [aynı bildirim](QMLMATERIAL-LICENSE.txt) korunur.

Yerel kaynak referansı inceleme sırasında kitin dışında
`Qavsi/references/QmlMaterial` dizinine alındı; HEAD baseline'da detached tutulur.
Bu yol paket kurulumuna, public import yoluna veya tüketici CMake'ine girmez.
İlk checkout makinede `git-lfs` olmadığı için komuta özgü LFS filtreleri
atlanarak kaynak okuma amacıyla tamamlandı. Sonrasında 16 public LFS asset,
resmi GitHub media endpoint'inden alınarak pointer boyutu ve SHA-256 OID'sine
karşı doğrulandı; [asset kaydı](reference-assets.json). Yerel Qt 6.12 referans
build'i, üç açık yerel test/build değişikliğiyle tamamlandı; ayrıntılar
[build raporunda](reference-build.md). Bu işlem fontları veya upstream kontrol
implementasyonunu Qavsi paketine taşımaz.

## Baseline kaynak haritası

Aşağıdaki yollar baseline commit'e aittir:

| Kaynak | Karşılaştırma amacı |
|---|---|
| [`example/Components.qml`](https://github.com/hypengw/QmlMaterial/blob/229bc3e64ff71f1ac88cf73e976637ffbcf7e33c/example/Components.qml) | Card/kategori sırası ve bileşen durumları |
| [`example/ButtonGroups.qml`](https://github.com/hypengw/QmlMaterial/blob/229bc3e64ff71f1ac88cf73e976637ffbcf7e33c/example/ButtonGroups.qml) | Standard/connected/segmented grup kompozisyonu |
| [`example/FABMenus.qml`](https://github.com/hypengw/QmlMaterial/blob/229bc3e64ff71f1ac88cf73e976637ffbcf7e33c/example/FABMenus.qml) | Eski Merce karşılaştırmasında tam uygulanmayan expressive FAB örnekleri |
| [`qml/button/Button.qml`](https://github.com/hypengw/QmlMaterial/blob/229bc3e64ff71f1ac88cf73e976637ffbcf7e33c/qml/button/Button.qml) | Label/icon layout, MDC state, corner/elevation, ripple/focus çizimi |
| [`qml/button/IconButton.qml`](https://github.com/hypengw/QmlMaterial/blob/229bc3e64ff71f1ac88cf73e976637ffbcf7e33c/qml/button/IconButton.qml) | Icon action/toggle, size/width durumları |
| [`qml/button/BusyButton.qml`](https://github.com/hypengw/QmlMaterial/blob/229bc3e64ff71f1ac88cf73e976637ffbcf7e33c/qml/button/BusyButton.qml) | Idle/busy/progress ve content hide; native SK loading API'si olduğu varsayılmaz |
| [`qml/button/SplitButton.qml`](https://github.com/hypengw/QmlMaterial/blob/229bc3e64ff71f1ac88cf73e976637ffbcf7e33c/qml/button/SplitButton.qml), [`SegmentedButton.qml`](https://github.com/hypengw/QmlMaterial/blob/229bc3e64ff71f1ac88cf73e976637ffbcf7e33c/qml/button/SegmentedButton.qml) | Joined geometry ve content davranış ayrımı |
| [`qml/visual/Ripple.qml`](https://github.com/hypengw/QmlMaterial/blob/229bc3e64ff71f1ac88cf73e976637ffbcf7e33c/qml/visual/Ripple.qml), [`RippleShape.qml`](https://github.com/hypengw/QmlMaterial/blob/229bc3e64ff71f1ac88cf73e976637ffbcf7e33c/qml/visual/RippleShape.qml) | Referans feedback ve renderer yolları |

QmlMaterial kendi C++ kontrol ailesini ve `Qcm.Material as MD` API'sini kullanır.
README açıkça QtQuick.Controls / QtQuick.Templates tabanlı olmadığını belirtir;
Qt StyleKit için hazır bir Material3 style değildir. Koddan davranış okunabilir;
`MD.Action`, `MD.ButtonBase`, attached property veya contentItem atamalarını
native SK API'sine bire bir kopyalamak doğru değildir.

Baseline README'ye göre default ikonlar embedded static Rounded Material Symbols,
`wght=400`, `opsz=24`, `GRAD=0`, `FILL=0/1` fontlarıdır.
`QM_ICON_FONT_URL` ile kısmi variable WOFF2 seçilebilir. Bu font/provider yolu,
Qt `icon.source` image veya platform icon theme desteğiyle aynı sözleşme değildir.
Font veya başka upstream varlıklar kopyalanacaksa kendi lisansları ayrıca
incelenip korunmalıdır; proje MIT lisansı üçüncü taraf font lisansının yerine
geçmez.

## Yeni upstream sürümü ayrı iştir

**2026-10-25** tarihinde resmi GitHub API'sinden doğrulanan `main` snapshot:

- Commit: [`191260585a829ee4ae2c99e6232b7145b5c34474`](https://github.com/hypengw/QmlMaterial/commit/191260585a829ee4ae2c99e6232b7145b5c34474).
- Commit mesajı: **0.6.1**; zaman **2026-10-22T15:11:05Z**.
- [İki sabit commit karşılaştırması](https://github.com/hypengw/QmlMaterial/compare/229bc3e64ff71f1ac88cf73e976637ffbcf7e33c...191260585a829ee4ae2c99e6232b7145b5c34474): **12 ahead / 0 behind / 12 total commits**.
- [Resmi API metadata kaydı](upstream-snapshot.json).

Bu snapshot'a geçmek mevcut karşılaştırma hedefini sessizce değiştirmez.
0.6.1'in yeni/değişen kompozisyon, picker, action/command/presentation ve motion
özellikleri ikinci bir kaynak audit'i olarak incelenmelidir. Bu belgede onların
Qavsi desteği veya görsel eşliği iddia edilmez. Tekrarlanabilir karşılaştırma için
önce eski baseline ile ilk buton aktarımı doğrulanır; yeni hedef seçilirse yeni
commit ve senaryo listesi ayrı kaydedilir.

## Lisans sahipliği

Upstream MIT bildirimi **Copyright (c) 2024-2025 hypengw** olarak korunur.
Örnek yerleşim/metin veya substantial code uyarlanırsa bu bildirim dağıtımdan
çıkarılmaz. Qavsi'nin MIT bildirimi bu upstream bildiriminin yerine geçmez.
Bu envanter harici referansı kaydeder; upstream kaynak ağacı, binary, font veya
image paket içine aktarılmamıştır.
