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
flutter build apk --release --dart-define-from-file=env/dev.json
```

`env/dev.json` gitignore'da — `env/dev.example.json`'dan türetilir
(`SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`).

Supabase hosted proje: `tkgbjurobhuyxdetyqxd`. Migration: `supabase db push`
(linked proje). Edge Function deploy:
`supabase functions deploy on-document-insert --no-verify-jwt`.

Firebase proje: `muhasebe-643d9` (`flutterfire configure` ile üretildi).
`lib/firebase_options.dart` ve `android/app/google-services.json` gerçek
değerler içeriyor ve commit edilmiş durumda (API key'ler gizli değil,
Firebase app-restriction ile korunuyor — standart pratik).

GitHub: `https://github.com/ercinnn/muhasebe` (public — Pages ücretsiz
planda yalnızca public repo'da çalışıyor). Web build **manuel** deploy
ediliyor, CI/CD yok:

```
flutter build web --dart-define-from-file=env/dev.json --base-href /
echo tahakkukfisi.com > build/web/CNAME
cd build/web && rm -rf .git && git init -q && git checkout -q -b gh-pages \
  && git add -A && git commit -q -m "Deploy web build" \
  && git remote add origin https://github.com/ercinnn/muhasebe.git \
  && git push -f origin gh-pages
```

Canlı: `https://tahakkukfisi.com/` (Cloudflare Registrar'dan alınan custom
domain, GitHub Pages'e DNS ile bağlı — apex `CNAME` → `ercinnn.github.io`,
`www` aynı şekilde, ikisi de Cloudflare'de "DNS only"/gri bulut).
`https://ercinnn.github.io/muhasebe/` artık kullanılmıyor. Kod her
değiştiğinde bu adım tekrar çalıştırılmadıkça site eski kalır.

**gh-pages branch'i her deploy'da `rm -rf .git && git init` ile sıfırdan
kuruluyor** — GitHub'ın custom domain için branch köküne yazdığı `CNAME`
dosyası bu sıfırlamada silinir. `echo tahakkukfisi.com > build/web/CNAME`
adımı bu yüzden deploy komutunun kalıcı bir parçası; atlanırsa bir sonraki
deploy'da custom domain ayarı GitHub tarafında sessizce düşer (Settings →
Pages'te tekrar boş görünür).

Release APK proguard kuralı gerektiriyor (`android/app/proguard-rules.pro`
+ `build.gradle.kts`'teki `proguardFiles(...)`): `google_mlkit_text_recognition`
kullanılmayan Chinese/Devanagari/Japanese/Korean recognizer sınıflarına
referans veriyor, `-dontwarn` kuralları olmadan R8 "missing class" hatasıyla
release build'i reddeder.

## Önemli gotcha'lar

- **Postgrest/RPC builder'ları lazy** — `Future` implement eder ama yalnızca
  `.then()`/`await` ile tetiklenir. Fire-and-forget
  `onPressed: () => repo.markPaid(id)` HİÇBİR ŞEY YAPMAZ; her zaman
  `onPressed: () async { await repo.markPaid(id); }`.
- **Riverpod keepAlive** — provider async iş bitene kadar veya uzun ömürlü
  stream/listener tutuyorsa `@Riverpod(keepAlive: true)` olmalı, aksi halde
  autodispose provider'da "Cannot use the Ref after it has been disposed"
  hatası çıkar (bkz. `fcmServiceProvider`).
- **Realtime**: `documents` tablosu `supabase_realtime` publication'a
  eklenmeli (`alter publication supabase_realtime add table public.documents;`)
  yoksa `.stream()` `RealtimeSubscribeException` fırlatır.
- **flutter_local_notifications + Android**: core library desugaring
  gerektirir (`isCoreLibraryDesugaringEnabled = true` + dep).
- **Android bildirim kanalları immutable** — bir kanal ID'si bir kere
  oluşturulunca ses/önem ayarı cihazda kilitlenir; kod tarafında ayarı
  değiştirmek yetmez, kanal ID'sini değiştirip (`payment_reminders_v2`
  gibi) yeni bir kanal oluşturmak gerekir.
- **Orphan Gradle daemon'lar** — Android build sonrası kalan `java.exe`
  process'leri (2.5GB+ bellek) sonraki build'leri yavaşlatabilir; donma
  şüphesinde `tasklist | grep -iE "dart|java"` kontrol et, regresyon
  varsaymadan önce.
- **adb + Git Bash/MSYS path mangling** — `/sdcard/...` ve
  `--base-href /muhasebe/` gibi `/`-başlayan argümanlar mangle edilir
  (`C:/Program Files/Git/...` olur); `MSYS_NO_PATHCONV=1` prefix'i veya
  çift-slash (`//sdcard/...`) kullan. Ekran koordinatları için
  `adb shell uiautomator dump` ile `bounds="[x1,y1][x2,y2]"` oku.
- **Gerçek GİB/SGK PDF'leri "etiket: değer" formatında DEĞİL** — pdfrx
  metni her formda önce TÜM etiketleri sonra TÜM değerleri ayrı bloklar
  halinde çıkarıyor (görsel sütun sırasına göre, etiket sırasına göre
  DEĞİL). Bu yüzden `label_extraction.dart`'taki extraction fonksiyonları
  (`extractTaxPeriod`, `extractEarliestRowDueDate`, `extractFisNo`,
  `extractLastAmount`, `extractSgkBildirgePersonName`) etiket aramak yerine
  regex/pozisyon tabanlı çalışıyor. Yeni bir belge türü/varyantı eklerken
  önce PDF'i `Read` tool'uyla oku, varsayımla fixture yazma. Not: gerçek
  kişi (şirket değil) mükelleflerde "SOYADI (ÜNVANI)" Türkçe `Ü` ile
  basılıyor (ASCII `U` değil) — `personName` artık `ADI` + bu alanı
  birleştiriyor.
- **pg_net webhook'ları Supabase gateway'inde varsayılan 401 alır** — bir
  DB trigger'ının `net.http_post` ile çağırdığı Edge Function'da kullanıcı
  JWT'si yoksa (server-to-server, kendi `x-webhook-secret` kontrolü var),
  Supabase'in varsayılan `verify_jwt = true` isteği fonksiyona hiç
  ulaştırmadan `401 UNAUTHORIZED_NO_AUTH_HEADER` ile reddeder. Çözüm:
  `supabase/config.toml`'da `[functions.X]` altında `verify_jwt = false` +
  `supabase functions deploy X --no-verify-jwt`. Hata Edge Function
  loglarında değil `net._http_response` tablosunda görülür.
- **Debug**: `npx --yes supabase@latest db query --linked "SELECT ..."` ile
  linked projeye Management API üzerinden SQL çalıştırılabilir (DB şifresi
  gerekmez, eski CLI'da yerleşik `db query` yok). Webhook debug için en
  değerli tablolar: `net._http_response` (her pg_net isteğinin gerçek
  status/body'si) ve `vault.decrypted_secrets`.
- **Push data-only, arka plan isolate'i kendi başına eksik** — FCM mesajı
  sessiz bir data payload'ı, uygulama kendi bildirimini kendi gösteriyor
  (`fcm_service.dart` foreground / `fcm_background_handler.dart` arka
  plan). Arka plan isolate `bootstrap()`'ı hiç çalıştırmaz, kendi
  başına init etmesi gerekenler:
  - `tz_data.initializeTimeZones()` + `tz.setLocalLocation(getLocation('Europe/Istanbul'))`
    çağrılmazsa `tz.local` `LateInitializationError` fırlatır (ya da hiç
    çağrılmamışsa varsayılan UTC'ye düşüp hatırlatmalar 3 saat geç kurulur).
  - `NotificationService.init()` içindeki
    `requestNotificationsPermission()` bir Activity gerektirir — headless
    isolate'te native `NullPointerException` fırlatıp `init()`'i (ve
    dolayısıyla bildirimi) hiç göstermeden patlatır. Arka planda
    `init(requestPermission: false)` ile atlanmalı.
  - `_scheduleAt` geçmiş bir tarih için hiçbir şey planlamaz (`if
    (scheduled.isBefore(now)) return;`) — `due_date` geçmişte olan bir test
    belgesinde anlık "Belge Geldi" bildirimi gelir ama vade hatırlatması
    hiç planlanmaz.
- **Türkçe karakterli test PDF'i üretme** — `reportlab` ile sentetik PDF
  üretilebilir ama standart fontlar (Helvetica/WinAnsi) `İ ı Ş ş Ğ ğ`
  içermez; `pdfmetrics.registerFont(TTFont(...))` ile
  `C:/Windows/Fonts/arial.ttf` gömülmeli (Identity-H/Unicode CMap). pdfrx
  metni content stream sırasına göre çıkarır (görsel pozisyona göre
  değil), yani fixture taklidi yaparken satır sırası yeterli, x/y önemsiz.
- **Supabase PKCE code_verifier, isteği başlatan storage'a bağlı** —
  `resetPasswordForEmail` çağrıldığı yerin (web origin'i ya da mobil
  uygulamanın local storage'ı) dışında bir yerde recovery linkine
  tıklanırsa `AuthException(Code verifier could not be found in local
  storage)` ile sessizce başarısız olur (kullanıcı sadece o context'te
  zaten var olan eski oturuma düşer, hata görmez). Bu yüzden mobilde
  `password_reset_controller.dart`, `redirectTo`'yu web'de dinamik origin,
  mobilde `muhasebetakip://reset-password` custom scheme olarak ayarlıyor
  (AndroidManifest.xml intent-filter + iOS Info.plist
  `CFBundleURLTypes`) — link her zaman isteği başlatan app/browser
  context'ine geri döner. Supabase Dashboard → Authentication → URL
  Configuration → Redirect URLs listesine `muhasebetakip://**` de
  eklenmeli, yoksa aynı sessiz-fallback davranışı (bkz. Site URL gotcha'sı)
  tekrarlanır.

## Durum

7 faz tamamlandı: Supabase şema/RLS → auth/roller → sınıflandırma
motoru+test → muhasebeci yükleme akışı → mükellef liste/takvim ekranları →
mobil bildirim sistemi → web görsel bildirimler. Web build GitHub
Pages'te yayında.

Push bildirimleri uçtan uca doğrulandı (gerçek Samsung A51 cihazında):
anlık "Belge Geldi" bildirimi her yeni belgede geliyor (uygulama tamamen
kapalıyken de), ödeme belgelerinde ayrıca vade-1 gün/vade günü hatırlatması
planlanıyor — bu akıştaki arka-plan bug'ları (izin isteği crash'i,
timezone init eksikliği) düzeltildi (bkz. gotcha'lar). Vade hatırlatması
artık alarm-stili (`payment_reminders_v2` kanalı, tam ekran + alarm sesi +
max önem) — bu da gerçek cihazda doğrulandı (2026-07-27), sesli/tam ekran
bildirim geliyor.

Ödemeler/Bilgilendirme/Takvim kartlarında okunmadı göstergesi var
(`seen_at`/`seenAt`, `payment_list_tile.dart` + `info_screen.dart`).

Şifremi unuttum akışı eklendi ve hem web hem mobilde (gerçek Samsung A51
cihazında, `muhasebetakip://` deep link ile) uçtan uca doğrulandı —
gerçek şifre değişikliği + yeni şifreyle giriş dahil (2026-07-28). Bkz.
PKCE code_verifier gotcha'sı.

Sınıflandırma motoru gerçek GİB/SGK belgeleriyle doğrulandı (bkz.
gotcha'lar). SGK işe giriş/işten ayrılış tarih alanları tek örnekle test
edildi — yeni örnekle tekrar kontrol edilmeli.

Test hesapları: `muhasebeci.demo@example.com` / `mukellef.demo@example.com`
(Supabase `auth.users`, şifre sıfırlandı — önceki konuşmaya bak). Gerçek
cihaz testleri `cakalogluercin86@gmail.com` (mükellef) ile de yapıldı.

Reminder ayarları test için değiştirildi (days before = 1, hour = 0) —
doğrulama tamamlandığı için varsayılana (`defaultReminderHour = 9`,
`defaultReminderDaysBefore = 1`, `settings_repository.dart`) döndürülmeli.

Not: ikinci, bağımsız bir firma için kopyalama fikri gündemden kaldırıldı —
tekrar gündeme gelmedikçe önerilmemeli.
