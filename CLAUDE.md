# muhasebe_takip

Muhasebeci–mükellef belge takip uygulaması. Muhasebeci resmi PDF vergi/SGK
belgelerini yükler, uygulama içeriği otomatik sınıflandırır (ödeme/bilgi,
tür, tutar, vade, fiş no...) ve ilgili mükellefe gönderir. Mükellef
belgelerini liste + takvim üzerinden takip eder, ödendi işaretler, mobilde
push + yerel alarm hatırlatmaları alır.

Flutter (web + Android öncelikli, iOS kod yolu hazır ama APNs kurulmadı) +
Supabase (Auth/Postgres/RLS/Storage/Realtime/Edge Functions) + Firebase
Cloud Messaging.

## Mimari

Feature-first, her feature içinde `data/domain/application/presentation`:

```
lib/
  core/            config (dart-define), router (go_router), theme, ortak widget'lar, sabitler
  services/
    supabase/      Supabase client provider
    pdf/           pdfrx tabanlı metin çıkarma (compute() ile)
    notifications/ platform-gated bildirim servisi (mobil: yerel alarm, web: yalnız görsel/Realtime)
    push/          fcm_service.dart — FCM token kaydı + foreground handler (yalnız mobil)
  features/
    auth/          davet kodu ile kayıt, giriş, rol bazlı yönlendirme
    classification/  SAF DART, Flutter bağımsız — sınıflandırma motoru (bkz. aşağı)
    upload/         muhasebeci: çoklu PDF yükleme, önizleme/düzeltme, gönderme
    documents/      ortak repo + mükellef ekranları (Ödemeler/Takvim/Bilgilendirme/Ayarlar)
    clients/        muhasebeci: mükellef listesi + davet
    settings/       yalnız mobilde anlamlı
supabase/
  migrations/       şema, RLS, storage policy, pg_net webhook trigger
  functions/on-document-insert/  FCM v1 push gönderen Edge Function (Deno)
test/classification/  sınıflandırma motoru unit testleri (34 test, saf dart)
```

`lib/features/classification/**` içinde asla `package:flutter/...` import
edilmez — `flutter test` olmadan `dart test` ile de çalışabilmeli.

Platform gating iki türlü yapılıyor, karıştırma:
- `firebase_messaging` / `flutter_local_notifications` web'de de derlenir →
  runtime `kIsWeb` dalı yeterli (`notificationServiceProvider`).
- Web implementasyonu olmayan paketler (ör. OCR) → conditional export:
  `export 'x_stub.dart' if (dart.library.io) 'x_mobile.dart';`

State management: Riverpod codegen (`@riverpod` / `@Riverpod(keepAlive: true)`).
Kod değiştikten sonra `dart run build_runner build` (veya geliştirirken
`... watch`) çalıştırmak gerekir; `.g.dart` dosyaları commit edilir.

## Geliştirme komutları

```
flutter run -d chrome --dart-define-from-file=env/dev.json
flutter run -d emulator-5554 --dart-define-from-file=env/dev.json
flutter test test/classification
flutter analyze
dart run build_runner build --delete-conflicting-outputs
```

`env/dev.json` gitignore'da — `env/dev.example.json`'dan türetilir
(`SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`).

Supabase hosted proje: `tkgbjurobhuyxdetyqxd`. Migration uygulamak için
`supabase db push` (linked proje). Edge Function deploy:
`supabase functions deploy on-document-insert`.

Firebase proje: `muhasebe-643d9` (`flutterfire configure` ile üretildi).
`lib/firebase_options.dart` ve `android/app/google-services.json` artık
gerçek değerler içeriyor ve commit edilmiş durumda (API key'ler gizli
değil, Firebase tarafı app-restriction ile korunuyor — standart pratik).

## Önemli gotcha'lar (bu oturumda öğrenildi)

- **Postgrest/RPC builder'ları lazy** — `Future` implement ederler ama
  yalnızca `.then()`/`await` ile tetiklenirler. Fire-and-forget
  `onPressed: () => repo.markPaid(id)` HİÇBİR ŞEY YAPMAZ; her zaman
  `onPressed: () async { await repo.markPaid(id); }` şeklinde awaitlenmeli.
- **Riverpod autodispose vs keepAlive** — bir provider async iş bitene
  kadar veya uzun ömürlü stream/listener tutuyorsa (`.listen(...)`)
  `@Riverpod(keepAlive: true)` olmalı; aksi halde hiçbir widget izlemiyorsa
  provider disposed olur ve `Ref` kullanımı "Cannot use the Ref of X after
  it has been disposed" hatası fırlatır. Örnek: `fcmServiceProvider` —
  `initialize()` içindeki `await getToken()` sırasında disposed oluyordu,
  `keepAlive: true` ile düzeltildi (bkz. `lib/services/push/fcm_service.dart`).
- **`documents` tablosu Realtime publication'a eklenmeli** —
  `alter publication supabase_realtime add table public.documents;`
  olmadan `.stream()` `RealtimeSubscribeException` fırlatır.
- **Android + flutter_local_notifications** — core library desugaring
  gerektiriyor (`android/app/build.gradle.kts`:
  `isCoreLibraryDesugaringEnabled = true` + `coreLibraryDesugaring` dep).
- **Orphan Gradle daemon'lar** — Android build sonrası `java.exe`
  process'leri bazen elde kalıp sonraki build'leri/ortamı yavaşlatır
  (2.5GB+ bellek). Donma şüphesinde önce `tasklist | grep -iE "dart|java"`
  kontrol et, kod regresyonu varsaymadan önce orphan process'leri ele.
- **adb path'leri** — Git Bash/MSYS `/sdcard/...` yollarını mangle'lar;
  `MSYS_NO_PATHCONV=1` prefix'i veya `//sdcard/...` çift-slash kullan.
  Tam koordinat için ekran görüntüsünü gözle kestirmek yerine
  `adb shell uiautomator dump` ile `bounds="[x1,y1][x2,y2]"` oku.

## Durum

7 faz da tamamlandı ve commit edildi (Supabase şema/RLS → auth/roller →
sınıflandırma motoru+test → muhasebeci yükleme akışı → mükellef
liste/takvim ekranları → mobil bildirim sistemi → web görsel bildirimler).
Firebase gerçek proje ile bağlandı, Android emülatörde FCM token kaydı
uçtan uca doğrulandı (`device_tokens` tablosuna yazıyor, disposed-Ref
hatası yok).

**Kalan adımlar (push bildirimin gerçekten cihaza ulaşması için,
kullanıcı daha sonra yapacak):**

1. Firebase Console → Project Settings → Service Accounts → "Generate new
   private key" ile servis hesabı JSON'ı indir.
2. `supabase secrets set FCM_SERVICE_ACCOUNT_JSON='<json içeriği>'`
3. `supabase/migrations/20260723230102_documents_insert_webhook.sql`
   başındaki yoruma göre Vault secret'larını ayarla:
   - `select vault.create_secret('https://tkgbjurobhuyxdetyqxd.supabase.co/functions/v1/on-document-insert', 'edge_function_url');`
   - `select vault.create_secret('<rastgele paylaşılan secret>', 'webhook_secret');`
4. Aynı `webhook_secret` değerini Edge Function tarafına da yaz:
   `supabase secrets set WEBHOOK_SECRET=<aynı değer>`
5. Muhasebeci hesabından yeni bir belge gönderip Android'de gerçek push
   bildiriminin geldiğini uçtan uca doğrula.
