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

GitHub: `https://github.com/ercinnn/muhasebe` (public — Pages ücretsiz
planda yalnızca public repo'da çalışıyor). Web build **manuel** deploy
ediliyor, CI/CD yok:

```
flutter build web --dart-define-from-file=env/dev.json --base-href /muhasebe/
cd build/web && rm -rf .git && git init -q && git checkout -q -b gh-pages \
  && git add -A && git commit -q -m "Deploy web build" \
  && git remote add origin https://github.com/ercinnn/muhasebe.git \
  && git push -f origin gh-pages
```

Canlı: `https://ercinnn.github.io/muhasebe/`. Kod her değiştiğinde bu adım
tekrar çalıştırılmadıkça site eski kalır — unutma.

Release APK için proguard kuralı gerekiyor
(`android/app/proguard-rules.pro` + `build.gradle.kts`'teki
`proguardFiles(...)`): `google_mlkit_text_recognition` kullanılmayan
Chinese/Devanagari/Japanese/Korean recognizer sınıflarına referans veriyor,
R8 bunları "missing class" hatasıyla reddediyor — `-dontwarn` kuralları
olmadan `flutter build apk --release` başarısız olur.

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
  `flutter build web --base-href /muhasebe/` verirken de aynı mangle olur
  (`/muhasebe/` → `C:/Program Files/Git/muhasebe/` oluyor) — yine
  `MSYS_NO_PATHCONV=1` gerekiyor.
- **Gerçek GİB/SGK PDF'leri "etiket: değer" formatında DEĞİL** —
  sınıflandırma motoru başta bunu varsayıyordu (bkz. eski
  `test/classification/fixtures.dart`, "gerçek belgenin kopyası değil"
  diye not düşülmüştü) ama gerçek pdfrx çıktısı tamamen farklı: her form
  önce TÜM etiketleri, sonra TÜM değerleri ayrı bloklar halinde basıyor
  (görsel sütun/tablo sırasına göre, etiket sırasına göre DEĞİL). Örnekler:
  - Tahakkuk fişi: "Vadesi" ve "Vergilendirme Dönemi" tablo başlığı, "Fiş
    No" diye bir etiket HİÇ yok (değer barkodun altındaki alfanumerik kod).
    Çözüm: `label_extraction.dart`'taki `extractTaxPeriod` /
    `extractEarliestRowDueDate` / `extractFisNo` — regex/pozisyon tabanlı,
    etiket aramıyor.
  - SGK prim tahakkuk fişi: aynı sorun, `extractLastAmount` (sayfadaki son
    tutar = ÖDENECEK NET TUTAR) ve dönem regex'iyle (`\d{4}/\d{1,2}`)
    çözüldü.
  - SGK işe giriş/işten ayrılış bildirgeleri: çok alanlı form, kimlik
    bilgileri (Adı/Soyadı/Baba Adı/Ana Adı/Doğum Yeri/Doğum Tarihi) metnin
    sonunda ardışık bir blok halinde, doğum tarihinin `YYYY-MM-DD` formatı
    üzerinden geriye doğru offsetle bulunuyor (`extractSgkBildirgePersonName`).
    Tarih alanları (işe başlama/işten ayrılış) tek örnekle doğrulandı, GİB
    fişindeki kadar sağlam değil — yeni gerçek örnek gelirse tekrar kontrol
    et.
  - Yeni bir belge türü/varyantı eklerken önce PDF'i `Read` tool'uyla oku
    (gerçek pdfrx metnini gösterir), varsayımla fixture yazma.
  - Gerçek kişi mükelleflerde (şirket değil) tahakkuk fişinde "SOYADI
    (ÜNVANI)" etiketi Türkçe `Ü` ile basılıyor, eski fixture'lar ASCII `U`
    varsayıyordu (`SOYADI (UNVANI)`) — `tax_accrual_rule.dart` bu yüzden
    gerçek kişilerde soyadını hiç okuyamıyordu (şirket unvanlarında ADI
    hanesi zaten "-" olduğundan sorun fark edilmemişti). Düzeltildi;
    `personName` artık `ADI` + `SOYADI (ÜNVANI)` birleştiriyor (bkz.
    `individualKdvTaxAccrualText` fixture'ı).
- **pg_net webhook'ları Supabase gateway'inde varsayılan olarak 401 alır** —
  `documents` INSERT trigger'ı (`notify_document_insert`) Edge Function'ı
  `net.http_post` ile çağırıyor ama `Authorization` header'ı göndermiyor
  (fonksiyonun kendi `x-webhook-secret` kontrolü var, kullanıcı JWT'si yok).
  Supabase'in varsayılan `verify_jwt = true` davranışı bu isteği fonksiyon
  koduna hiç ulaşmadan `401 UNAUTHORIZED_NO_AUTH_HEADER` ile reddediyor —
  push bildirimlerinin hiç gitmemesinin kök nedeni buydu. Çözüm:
  `supabase/config.toml`'da `[functions.on-document-insert]` altında
  `verify_jwt = false`, sonra `supabase functions deploy on-document-insert
  --no-verify-jwt` ile yeniden deploy. Bu tür server-to-server (kullanıcı
  oturumu olmayan) webhook fonksiyonlarında hep gerekli. Hata `net._http_response`
  tablosunda görülür (bkz. aşağıdaki debug notu), Edge Function loglarında değil
  (istek gateway'de fonksiyona ulaşmadan reddedildiği için).
- **Debug: eski Supabase CLI (2.78) `functions logs` / `db query` komutlarını
  desteklemiyor** — `npx --yes supabase@latest db query --linked "SELECT ..."`
  ile linked projeye doğrudan SQL çalıştırılabiliyor (Management API üzerinden,
  DB şifresi gerekmez). Webhook/trigger debug için en değerli tablo
  `net._http_response` (pg_net'in attığı her HTTP isteğin gerçek status/body'si —
  `notify_document_insert` gibi trigger'ların fiilen 200 mü 401 mi döndürdüğünü
  gösterir) ve `vault.decrypted_secrets` (webhook secret'larının set edilip
  edilmediğini doğrulamak için).
- **Push bildirimi data-only, ekranda anlık bir şey GÖSTERMEZ** —
  `on-document-insert` FCM mesajı sessiz bir data payload'ı; uygulama bunu
  alınca (foreground/background handler, `fcm_service.dart` /
  `fcm_background_handler.dart`) sadece `notification_service_mobile.dart`
  üzerinden vade tarihine göre yerel bir alarm PLANLAR (vade-1 gün ve vade
  günü, varsayılan saat 09:00 — `settings_repository.dart`). `_scheduleAt`
  geçmiş bir tarih için hiçbir şey planlamıyor (satır ~80: `if (scheduled
  .isBefore(now)) return;`), yani `due_date` geçmişte olan bir test belgesi
  gönderilirse push sunucu tarafında başarıyla gitse bile (`sent:1`)
  telefonda HİÇBİR bildirim çıkmaz — bu bir hata değil, tasarım. Uçtan uca
  test için `due_date` bugünden ileride olmalı.
- **Türkçe karakterli test PDF'i üretme** — sınıflandırma motorunu gerçek
  belge olmadan (örn. ileri tarihli bir vade ile) test etmek için `reportlab`
  ile sentetik PDF üretilebilir, ama standart fontlar (Helvetica + WinAnsi)
  Türkçe `İ ı Ş ş Ğ ğ` karakterlerini barındırmaz (Latin-1/WinAnsi'de yok,
  ISO-8859-9'da var) — `pdfmetrics.registerFont(TTFont(...))` ile
  `C:/Windows/Fonts/arial.ttf` gömülmeli (Identity-H/Unicode CMap). pdfrx
  (PDFium) metni content stream'deki `Tj`/`TJ` sırasına göre çıkarıyor,
  görsel pozisyona göre DEĞİL (bkz. yukarıdaki "etiket:değer değil" notu) —
  yani gerçek bir fixture'ı taklit ederken her satırı ayrı bir
  `canvas.drawString(...)` çağrısıyla, fixture'daki satır sırasıyla birebir
  aynı sırada basmak yeterli; x/y koordinatları extraction sonucunu etkilemiyor.

## Durum

7 faz da tamamlandı ve commit edildi (Supabase şema/RLS → auth/roller →
sınıflandırma motoru+test → muhasebeci yükleme akışı → mükellef
liste/takvim ekranları → mobil bildirim sistemi → web görsel bildirimler).
Firebase gerçek proje ile bağlandı, Android emülatörde FCM token kaydı
uçtan uca doğrulandı (`device_tokens` tablosuna yazıyor, disposed-Ref
hatası yok).

Push bildirim kurulumu tamamlandı ve sunucu tarafında uçtan uca doğrulandı:
`FCM_SERVICE_ACCOUNT_JSON`/`WEBHOOK_SECRET` secret'ları set, Vault'ta
`edge_function_url`/`webhook_secret` mevcut. Yolda bir kök neden bulundu ve
düzeltildi — trigger'ın attığı webhook isteği gateway'de `401
UNAUTHORIZED_NO_AUTH_HEADER` ile reddediliyordu (bkz. "Önemli gotcha'lar" —
`verify_jwt = false` fix'i, `supabase/config.toml`). Düzeltme sonrası yeni
bir belge gönderiminde `net._http_response` `{"sent":1}` / status 200
döndürdüğü doğrulandı. Kalan tek şey: push data-only olduğundan (bkz. ilgili
gotcha) gerçek cihazda görünür bir bildirim ancak `due_date`'e yakın bir
zamanda (varsayılan vade-1 gün ve vade günü saat 09:00) çıkıyor — anlık
"yeni belge geldi" bildirimi şu an sistemde yok, istenirse ayrı eklenebilir.

Proje GitHub'a taşındı (`ercinnn/muhasebe`, public) ve web build GitHub
Pages'te yayında (`https://ercinnn.github.io/muhasebe/`, manuel deploy —
yukarıdaki "Geliştirme komutları" bölümüne bak).

Sınıflandırma motoru gerçek GİB tahakkuk fişi + SGK belgeleriyle test edilip
düzeltildi (bkz. "Önemli gotcha'lar" — gerçek PDF'ler etiket:değer formatında
değil). Tax accrual (KDV/KDV2/Muhtasar/Geçici Vergi/Damga) ve SGK prim
tahakkuk fişi düzeltmeleri gerçek örneklerle uçtan uca doğrulandı. SGK işe
giriş/işten ayrılış bildirgelerinde isim çıkarımı sağlam, tarih alanları
(işe başlama/işten ayrılış) tek örnekle test edildi — uygulamada farklı
örneklerle ayrıca doğrulanmalı.

Test hesapları (Supabase `auth.users`, şifreler sıfırlandı — güncel şifre
için önceki konuşma geçmişine ya da veritabanına bak):
`muhasebeci.demo@example.com` (accountant), `mukellef.demo@example.com`
(client).

**Kalan adım:** Vadesi ileri tarihli bir belge gönderip (test için
`C:\Projects\Flutter\Pdf\Tahakkuk_KDV1_test_future_20260820.pdf` — vade
20/08/2026 — kullanılabilir) telefonda vade tarihine yakın saatte gerçek
bildirimin göründüğünü doğrulamak.
