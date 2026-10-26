# Changelog

## Unreleased

- Add opt-in seed-based Material Color Utilities C++ generation for Neutral
  and TonalSpot, preserving static defaults and caller role bindings.
- Validate generated colors against the independent QmlMaterial reference.

- Bağımsız `Qavsi/material3` deposu, MIT lisansı ve kaynak/installed paketinde
  lisans bildirimleri; runtime, Theme ve kontrol API'leri korunur.

- Qt 6.12 StyleKit üzerinde bağımsız Material3 Small Filled button, typed
  light/dark Theme, source/installed CMake tüketimi ve software renderer desteği.
- Sol ekran yerleşimli QML Preview örneği ve native input/caller binding kontrolleri.
- Native `SK.Button` üzerinde pointer/klavye ripple'ı, yalnız klavye focus'unda dış
  halka ve sistem tercihiyle birleşen `Material3Style.reducedMotion` girdisi.
- Pill'e kırpılan internal software painter, alpha birikimi olmadan
  hover/focus'a sönme ve cancel/disable/hide temizliği. 300/180 ms ripple süreleri
  ve 2 px halka/2 px boşluk açık Qt uyarlamalarıdır.
- Örnekte manuel hareket seçimi; ripple, klavye focus'u, azaltılmış hareket ve
  source/installed internal delegate aktarımı için contract check kapsamı.
- Metal'de build-time `.qsb` ripple shader'ı; software/diğer backend'lerde painter
  fallback'i ve ortak native Qt focus halkası. Tema, hareket ve input mantığı
  renderer'dan bağımsız; ShaderTools yalnız source build gereksinimi.
