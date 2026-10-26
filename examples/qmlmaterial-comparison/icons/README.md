# Karşılaştırma örneği ikonları

Bu klasördeki 15 SVG, resmi Google **Material Symbols Rounded** setinden alınır.
Font/provider veya kit API'si değildir; karşılaştırma ekranındaki native
`SK.Button.icon.source` örnekleri için yerel image asset'leridir. Derleme ve
çalıştırma sırasında ağ erişimi gerekmez.

Kaynak: [google/material-design-icons](https://github.com/google/material-design-icons/tree/10ecc14790612ca8fd164e3f4ffe9c16fc50d5b7), sabit commit
`10ecc14790612ca8fd164e3f4ffe9c16fc50d5b7` (2026-10-23T02:18:43Z). Normal dosyalar `FILL=0`, `star-filled.svg` ve
`settings-filled.svg` `FILL=1` çizimleridir. Diğer eksenler `wght=400`, `opsz=24`,
`GRAD=0`; SVG logical boyutu 24×24'tür. Google'ın [kaynak README'si](https://github.com/google/material-design-icons/blob/10ecc14790612ca8fd164e3f4ffe9c16fc50d5b7/README.md)
Regular ağırlığı 400 ve optical-size varsayılanını 24 olarak tanımlar.

SVG byte'ları değiştirilmedi; yalnız dosya isimleri tüketici kullanımı için
sadeleştirildi. Kaynak yolu, ham URL ve SHA-256 değerleri [manifest.json](manifest.json)
içindedir. Eski örneğin elle çizilmiş add/check varlıklarını kullanmaz.

Google Material Symbols varlıkları [Apache License 2.0](LICENSE-Apache-2.0.txt)
altındadır. Qavsi'nin MIT lisansı bu SVG'lerin lisansını değiştirmez. Resmi
[lisans ve kullanım açıklaması](https://github.com/google/material-design-icons/blob/10ecc14790612ca8fd164e3f4ffe9c16fc50d5b7/README.md#license) korunur.
Bu asset'ler font rasterizasyonunu, CurveRendering'i veya variable-font FILL
animasyonunu doğrulamaz; yalnız sabit Rounded glyph geometrisini sağlar.
