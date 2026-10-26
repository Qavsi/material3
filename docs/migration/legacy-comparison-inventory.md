# Önceki karşılaştırma uygulaması ve aktarım sınırları

İnceleme tarihi: **2026-10-25**. Eski tüketici: `MerceMaterial3Demo/`.
Yerel inceleme kökü `/Volumes/Mac/SCS/dev/MerceMaterial3Demo` idi; bu yol yeni
kitin CMake veya çalışma zamanı bağımlılığı değildir.

## Kaynak yüzeyi

| Kaynak | Sorumluluk / aktarım |
|---|---|
| `Main.qml` | Tek style seçimi, responsive pencere, sayfa modeli; Merce Theme/profile bağlamını taşımadan kitin kendi Theme'ına bağlanır. |
| `Navigation.qml` | Rail/drawer/page selection; native Popup davranışı korunur. Merce/AlGit ve ops/cart seçimleri yeni Material3 core API'si değildir. |
| `ComponentsPage.qml`, `DemoCard.qml` | Galeri yerleşimi, intrinsic row ölçümü, scroll/focus reveal; consumer yerleşimi olarak yeniden kullanılabilir. |
| `ActionsGallery.qml` | İlk buton aktarımının temel ekranı. Alt bölümlerin farklı içerik gereksinimleri aşağıda ayrılır. |
| `CommunicationGallery.qml` | Busy button, progress, snackbar/tooltip boşlukları; buton loading sözleşmesi için ayrı kaynak. |
| `SelectionGallery.qml` | Field, ComboBox, check/radio/switch, menu; sonraki kontrol ailesi aktarımı. |
| `ExtendedGallery.qml` | Slider, tabs ve genişletilmiş örnekler; sonraki kontrol ailesi aktarımı. |
| `ReferencePage.qml`, `SwipeDismissExample.qml` | Token/type/shape sayfaları ve native swipe tüketimi; buton diliminin bağımlılığı yapılmaz. |
| `main.cpp`, `SelectionInteractionTests.*`, `SwipeInteractionTests.*` | Lifecycle, input ve renderer testleri. Merce özel nesne/reader beklentileri gerçek native SK sözleşmesine göre yeniden yazılır. |
| `icons/{add,check,close,description}.svg` | Mevcut dört `icon.source` varlığı; provenans/lisansları korunur. |
| `PARITY.md`, `GAPS-actions.md`, `GAPS-selection.md` | Tarihsel test ve açıklar. Tamamlanma beyanı olarak değil, aktarım kontrol listesi olarak kullanılır. |

Statik sayım: **10 QML dosyası / 2239 satır**, **74 MButton**, **68 AppLabel**,
**2 MBadge** örneği. Doğrudan `AppIcon {}` örneği yoktur; paketli font ikonları
MButton içerik katmanından gelmektedir. Ana uygulama ve iki C++ test dosyası
3353 satırdır. Bunlar kaynakta yazılı örnek sayılarıdır; Repeater ile oluşan
çalışma zamanı nesne sayısı değildir.

22 native SK tipi ve üç `StyleReader` bildirimi vardır: ApplicationWindow,
Page, Pane, Action, BusyIndicator, CheckBox, ComboBox,
ItemDelegate, Menu, MenuItem, ProgressBar, RadioButton, RangeSlider, ScrollBar,
SearchField, Slider, SwipeDelegate, Switch, TabBar, TabButton, TextField, ToolBar.
Eski uygulama altı Merce CMake hedefi ve 41 benzersiz `Theme` yolu kullanır;
bu yüzden yalnız `add_subdirectory` yolunu değiştirmek bağımsızlaştırma değildir.

## İlk buton ailesi için kaynak haritası

Satırlar inceleme anındaki `ActionsGallery.qml` içindir. Yeni dosyaya kopyalanınca
satır numaraları değişebilir; kalıcı takip `objectName` ve örnek başlığıdır.

| Eski satırlar | Alt bölüm | Native SK aktarımı / açık içerik işi |
|---|---|---|
| 44–89 | Common buttons + XS/S/M/L/XL | Elevated/Filled/FilledTonal/Outlined/Text, icon/disabled örnekleri. Native `SK.Button`, `icon.source`, `display` ve style-owned görünümle başlanır. |
| 90–211 | Standard/Connected groups | Native ButtonGroup, Row/RowLayout ve checkable davranışı korunur. Joined corners, optical content offset ve komşu width redistribution ayrı yeteneklerdir; sonuncusu eskide de eksikti. |
| 212–289 | Segmented | Exclusive/multi selection native kalır. Eski otomatik checked checkmark ve özel içerik `MerceStyle.segmentedButtonContentDelegate` + MButton factory protokolüne bağlıdır. Sadece kenar/delegate taşımak checkmark aktarımı sayılmaz. |
| 290–346 | Split | Main/menu iki ayrı native hedef; erişilebilir expanded durumu ve Menu konumu consumer'a aittir. Trailing ok rotation/optical offset eski `splitIndicatorContentDelegate` üzerinden çizilir. |
| 347–360 | FAB / Extended FAB | Tarif eski `Material3FabVariation` içindedir; içerik `Material3NavigationItemContent` üzerinden expanded icon/label morph kullanır. Bu protokol native SK.Button background API'siyle otomatik taşınmaz. |
| 361–450 | Icon buttons + size/width | Standard/Filled/Tonal/Outlined ve checkable/disabled örnekleri. Native `display: IconOnly` ve erişilebilir ad korunur. Paketli font provider ve FILL=0/1 geçişi ayrı destek sözleşmesi gerektirir. |
| 451–500 | Icon button badge overlays | Capping/showZero ve açıklama app verisidir; pasif dot/count/text görseli label/delegate tarifidir. MBadge yeni kit bağımlılığı olmaz. |

MButton'a özgü eski kullanım noktaları `iconName`, `iconPosition`, `variant`,
`size`, `extraVariations`, `loading`, `loadingLabelVisible` ve
`loadingKeepsWidth` alanlarıdır. Bunları aynı adlı wrapper ekleyerek körlemesine
kopyalamak amaçlanmaz. Normal `icon.source` Qt ikonudur; `material:star` gibi
paket adları native Qt tema adıyla eşdeğer değildir.

Eski `ActionsGallery.qml:14–27` erken variation ölçümüne karşı completed guard ve
ToolBar `StyleReader` kullanır. İncelemeyi taşırken bunun nedenini kaybetmeyin;
Qt cache davranışını yeni tüketicide yeniden sınamadan guard'ın kalktığı veya
hataya ihtiyaç kalmadığı söylenmemelidir.

## Korunacak diğer aile ilerlemesi

Aşağıdaki durumlar eski Merce kaynak/dokümanlarında kayıtlıdır; **Qavsi kitinde
uygulandığı veya yeniden test edildiği anlamına gelmez**.

| Aile | Korunacak ilerleme | Açıklar / aktarım sınırı |
|---|---|---|
| Field / ComboBox | Native SK kontrol, style-owned floating caption, filled/outlined, açık label association, hata renkleri | Dynamic variation cache; integrated prefix/suffix/support/accessory slot'ları ve XS/XL ComboBox eksikleri |
| Check/radio/switch | Native davranış, shared feedback, track/thumb geometrisi, caller SVG/Action icon API'si | Switch native fixed 50 ms x Behavior reduced motion dışında; cold Metal thumb geçişi/reference state ink farkları |
| Menu / Action | Native Menu/MenuItem/Action, uzun SVG row, keyboard/check/submenu ve in-row feedback | Native typography/width/placement/transition farkları; form ComboBox ayrı tarif |
| Slider / RangeSlider | Native input/value, yatay/dikey track/handle, stops/label rolleri, crossing/disabled tanıları | Page recreation variation kaybı, minimumRange ve inset icon/five track size açıkları |
| Tabs | Native TabBar/TabButton, content-width underline ve rectangular feedback | Page recreation sonrası font çözümlemesi |
| Swipe | Native SwipeDelegate, model-owned mark/reset/remove ve keyboard alternatifleri | Native velocity/distance eşikleri, aktif motion iptali farkları |
| Progress / tooltip / snackbar | Native kontrol ve açık destek boşlukları | ProgressBar SDK uyarısı; zengin progress/tooltip ve eski source-only notifications yeni kitin parçası değil |
| Navigation / FAB / groups | Rail/drawer/scrim, grouped recipes, selection ve expanded content | Merce application shell politikası ayrılmalı; expressive FAB menu, group redistribution ve bazı motion testleri açık |

## Qt ve test aktarım kontrol listesi

1. **Variation/cache lifecycle:** mevcut TextField/ComboBox'a variation
   ekleyip kaldırma ile page destroy/recreate sonrası Slider policy ve Tab font
   senaryolarını ayrı sınayın. Eski uygulama bunları
   [QTBUG-148461](https://bugreports.qt.io/browse/QTBUG-148461) ile ilişkili kanıt
   olarak kaydeder; bu not tracker'ın bugünkü çözüm durumu beyanı değildir.
   Eski full `--smoke-test`, stock Qt 6.12.0 üzerinde bu yüzden kırmızıdır.
2. **ProgressBar:** eski native indeterminate toggle
   `Cannot assign to non-existent property "firstProgress"` ve undefined `stop`
   uyarıları üretmiştir. SDK değiştirilmez, app-local sahte renderer ile örtülmez.
3. **Caller sahipliği:** native `enabled`, font, padding, implicit geometry,
   icon/cache/Action ve event binding'leri korunmalı. Eski testlerde MButton'ın
   private `buttonLabel`, `buttonIcon`, `contentStyle` nesnelerine bakan kontroller
   yeni gerçek sözleşmeye göre uyarlanmalı; yalnız nesne adları değiştirilmemeli.
4. **Tema/renderer/motion:** light/dark, active press sırasında reduced motion,
   hide/disable/cancel, Tab/Backtab/mouse focus, source/installed ve Metal/software
   her aktarım diliminde tekrar ölçülmeli. Eski menü 72-case ve seçim 42-case
   sonuçları tarihsel Merce kanıtıdır; yeni kit sonucu diye kopyalanmamalı.
5. **Kapsam sınırı:** eski Merce seed-palette/full tonal pair, Roboto typescale,
   chips, sheets/carousel/pickers/table boşlukları da vardır. Yeni bağımsız Theme
   bunları kendi resmi Google sözleşmesiyle ele almalı; Merce profile/palette
   farklarını yeni Material3 tasarım kuralı olarak miras almamalı.

Bu statik envanter, Qavsi aktarımı için build/test/UI eşliği sonucu içermez.

## Güncel aktarım kanıtı

Yukarıdaki tarama tarihsel kaynak envanteridir. Yeni kitin buton ailesi için
yeniden çalıştırılan source/installed ve renderer kontrolleri
[BUTTON-FAMILY raporunda](../../evidence/BUTTON-FAMILY.md) tutulur; canlı karşılaştırma ve kalan farklar
[ayrı incelemededir](button-family-visual-review.md).
