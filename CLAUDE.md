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
    auth/          davet kodu ile kayıt, e-posta+şifre veya Google OAuth ile giriş, rol bazlı yönlendirme
    classification/  SAF DART, Flutter bağımsız — sınıflandırma motoru (bkz. aşağı)
    upload/         muhasebeci: çoklu PDF yükleme, önizleme/düzeltme, gönderme
    documents/      ortak repo + mükellef ekranları (Ödemeler/Ödenenler/Takvim/Bilgilendirme/Ayarlar)
    clients/        muhasebeci: mükellef listesi + davet + mükellef iletişim bilgileri (telefon/WhatsApp)
    settings/       yalnız mobilde anlamlı
supabase/
  migrations/       şema, RLS, storage policy, pg_net webhook trigger
  functions/on-document-insert/     FCM v1 push gönderen Edge Function (Deno)
  functions/send-whatsapp-document/ WhatsApp Cloud API bildirim Edge Function (Deno, bkz. Durum)
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
`... watch`) çalıştırmak gerekir; `.g.dart`/`.freezed.dart` dosyaları
commit edilir.

## Geliştirme komutları

```
flutter run -d chrome --dart-define-from-file=env/dev.json
flutter run -d emulator-5554 --dart-define-from-file=env/dev.json
flutter test test/classification
flutter analyze
dart run build_runner build --delete-conflicting-outputs
flutter build apk --release --dart-define-from-file=env/dev.json
flutter build appbundle --release --dart-define-from-file=env/dev.json
```

CI (`.github/workflows/ci.yml`) `build_runner build` sonrası `git diff
--exit-code` ile üretilen dosyaların commit'lenmiş haliyle aynı olduğunu
kontrol ediyor — `@riverpod`/`@freezed` işaretli bir dosyayı değiştirip
`build_runner`'ı unutursan bu adım kırmızı olur.

`env/dev.json` gitignore'da — `env/dev.example.json`'dan türetilir
(`SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`).

Supabase hosted proje: `tkgbjurobhuyxdetyqxd`. Migration: `supabase db push`
(linked proje). Edge Function deploy:
`supabase functions deploy <fn> --no-verify-jwt`.

Firebase proje: `muhasebe-643d9` (`flutterfire configure` ile üretildi).
`lib/firebase_options.dart` ve `android/app/google-services.json` gerçek
değerler içeriyor ve commit edilmiş durumda (API key'ler gizli değil,
Firebase app-restriction ile korunuyor — standart pratik).

Android `applicationId`: `com.tahakkukfisi.app` (yayından önce
`com.muhasebeci.muhasebe_takip`'ten değiştirildi — yayınlandıktan sonra
değiştirilemez). Release imzalama `android/key.properties` +
`android/upload-keystore.jks` ile yapılıyor — ikisi de gitignore'da,
yalnızca bu makinede var. **Kaybedilirse uygulama bir daha
güncellenemez**, güvenli yedeklenmeli. `build.gradle.kts`,
`key.properties` yoksa release build'i debug key'e düşürüyor (fresh
checkout/CI hâlâ derlenebilsin diye).

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

Canlı: `https://tahakkukfisi.com/` (Cloudflare Registrar domain, GitHub
Pages'e DNS ile bağlı — apex+`www` CNAME → `ercinnn.github.io`, "DNS
only"/gri bulut). `https://ercinnn.github.io/muhasebe/` artık kullanılmıyor.
Kod değişince bu adım tekrar çalıştırılmadıkça site eski kalır.

**gh-pages branch'i her deploy'da `rm -rf .git && git init` ile sıfırdan
kuruluyor** — GitHub'ın custom domain için branch köküne yazdığı `CNAME`
dosyası bu sıfırlamada silinir, bu yüzden `echo tahakkukfisi.com >
build/web/CNAME` deploy komutunun kalıcı bir parçası; atlanırsa custom
domain ayarı GitHub tarafında sessizce düşer.

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
- **Riverpod keepAlive** — provider hiçbir widget'ta `ref.watch` edilmeden
  sadece `onPressed` içinde `ref.read(...).notifier` ile çağrılıyorsa,
  autodispose altında birden fazla `await`'li çağrı sırasında provider
  disposed olup hata sessizce yutulabilir (`fcmServiceProvider`,
  `documentActionsProvider`'da yaşandı — "Ödendi" butonu güncellenmiyordu).
  `@Riverpod(keepAlive: true)` çözer.
- **Realtime**: `documents` tablosu `supabase_realtime` publication'a
  eklenmeli (`alter publication supabase_realtime add table public.documents;`)
  yoksa `.stream()` `RealtimeSubscribeException` fırlatır.
- **flutter_local_notifications + Android**: core library desugaring
  gerektirir (`isCoreLibraryDesugaringEnabled = true` + dep).
- **Android bildirim kanalları immutable** — bir kanal ID'si oluşunca
  ses/önem ayarı cihazda kilitlenir; kod tarafında ayarı değiştirmek
  yetmez, kanal ID'sini değiştirip (`payment_reminders_v2` gibi) yeni bir
  kanal oluşturmak gerekir.
- **Orphan Gradle daemon'lar** — Android build sonrası kalan `java.exe`
  process'leri (2.5GB+ bellek) sonraki build'leri yavaşlatabilir; donma
  şüphesinde `tasklist | grep -iE "dart|java"` kontrol et.
- **adb + Git Bash/MSYS path mangling** — `/sdcard/...` gibi `/`-başlayan
  argümanlar mangle edilir; `MSYS_NO_PATHCONV=1` prefix'i veya çift-slash
  (`//sdcard/...`) kullan. Ekran koordinatları için `adb shell uiautomator
  dump` ile `bounds="[x1,y1][x2,y2]"` oku.
- **Gerçek GİB/SGK PDF'leri "etiket: değer" formatında DEĞİL** — pdfrx
  metni her formda önce TÜM etiketleri sonra TÜM değerleri ayrı bloklar
  halinde çıkarıyor (görsel sütun sırasına göre, etiket sırasına göre
  DEĞİL). Bu yüzden `label_extraction.dart`'taki extraction fonksiyonları
  regex/pozisyon tabanlı çalışıyor. Yeni bir belge türü/varyantı eklerken
  önce PDF'i `Read` tool'uyla oku, varsayımla fixture yazma. Gerçek kişi
  (şirket değil) mükelleflerde "SOYADI (ÜNVANI)" Türkçe `Ü` ile basılıyor
  (ASCII `U` değil).
- **pg_net webhook'ları Supabase gateway'inde varsayılan 401 alır** — bir
  DB trigger'ının `net.http_post` ile çağırdığı Edge Function'da kullanıcı
  JWT'si yoksa, Supabase'in varsayılan `verify_jwt = true` isteği
  fonksiyona hiç ulaştırmadan `401 UNAUTHORIZED_NO_AUTH_HEADER` ile
  reddeder. Çözüm: `supabase/config.toml`'da `[functions.X]` altında
  `verify_jwt = false` + `supabase functions deploy X --no-verify-jwt`.
  Hata Edge Function loglarında değil `net._http_response` tablosunda
  görülür.
- **Debug**: `npx --yes supabase@latest db query --linked "SELECT ..."` ile
  linked projeye Management API üzerinden SQL çalıştırılabilir (DB şifresi
  gerekmez). Webhook debug için en değerli tablolar: `net._http_response`
  (her pg_net isteğinin gerçek status/body'si) ve `vault.decrypted_secrets`.
  Bazen bu CLI komutu çıktısız takılabiliyor (sebep netleşmedi) — Supabase
  Dashboard SQL Editor güvenilir alternatif.
- **Supabase Dashboard SQL Editor'de Monaco editörüne native tıklama/yazma
  bazen hiç focus almıyor** (özellikle Disk IO Budget throttling altında).
  Çözüm: `window.monaco.editor.getModels()[0].setValue("...")` ile sorguyu
  doğrudan Monaco model API'siyle set et, sonra Run'a `ref` tabanlı tıkla
  (koordinat tabanlı tıklama viewport/screenshot boyut uyuşmazlığından
  yanlış yere gidebilir). `setValue()`'dan hemen sonra Run'a tıklamak
  bazen eski sorguyu çalıştırır — bir-iki tur beklemek yeterli.
- **Meta Business Manager template/mesaj editörü iki yazı tuzağı
  içeriyor**: (1) `{{` yazınca editör otomatik `}}` ekliyor — `{{1}}` gibi
  bir değişkeni tek seferde yazmak `{{1}}1}}` gibi çift kapanışa yol açar;
  doğrusu `{{`'ye kadar yazıp `End` ile otomatik `}}`'nin ötesine atlamak.
  (2) Her `type()` çağrısının sonundaki boşluk bir sonraki eklemeden önce
  kırpılıyor — boşluğu önceki parçanın sonuna değil, sonraki parçanın
  **başına** koy.
- **Meta App Dashboard'daki "Generate token" butonu arayüzde bozuk
  görünüyor** ("Not generated yet" hiç değişmez) ama token gerçekten
  üretiliyor (Graph API Explorer ile doğrulanabilir) — widget'ın kendi
  durum göstergesi güncellenmiyor sadece. Yan etki: her "başarısız"
  görünen deneme yeni bir test WABA'sı yaratıyor (OAuth ekranında
  duplicate test WABA'lar buradan gelir).
- **Meta System User adı sıkı bir format bekliyor** — tire/boşluk içeren
  adlar reddedilir; tek kelimelik CamelCase (`WhatsappEntegrasyonu`)
  kabul edildi.
- **Meta'nın "(#132001) Template name does not exist in the translation"
  hatası template'in var olmamasından değil, gönderen kimliğin template'i
  GÖREMEMESİNDEN de kaynaklanabilir** — template APPROVED/doğru dilde ve
  doğru WABA/telefon numarasıyla eşleşse bile, System User'ın o WhatsApp
  hesabı için sadece "Mesajlar" (gönder/yanıtla) izni olup "Mesaj
  şablonları (sadece görüntüleme)" izni yoksa aynı hatayı verir — Business
  Settings → Sistem kullanıcıları → WhatsApp hesabı → **Yönet**'teki
  "Atamaları yönet" panelinden kontrol et (WhatsApp Hesapları listesindeki
  özet etiket bu eksikliği göstermez). İzni açmak yeter, token yeniden
  üretmeye gerek yok (Meta izinleri her istekte canlı kontrol ediyor). Ayrı
  bir olası neden: Edge Function'daki sabit `WHATSAPP_GRAPH_API_VERSION`
  eski/sunset bir sürüm olabilir — güncel tut.
- **Push data-only, arka plan isolate'i kendi başına eksik** — FCM mesajı
  sessiz bir data payload'ı, uygulama kendi bildirimini kendi gösteriyor
  (`fcm_service.dart` foreground / `fcm_background_handler.dart` arka
  plan). Arka plan isolate `bootstrap()`'ı hiç çalıştırmaz:
  - `tz_data.initializeTimeZones()` + `tz.setLocalLocation(getLocation('Europe/Istanbul'))`
    çağrılmazsa `tz.local` `LateInitializationError` fırlatır (ya da UTC'ye
    düşüp hatırlatmalar 3 saat geç kurulur).
  - `NotificationService.init()` içindeki
    `requestNotificationsPermission()` bir Activity gerektirir — headless
    isolate'te native `NullPointerException` fırlatır. Arka planda
    `init(requestPermission: false)` ile atlanmalı.
  - `_scheduleAt` geçmiş bir tarih için hiçbir şey planlamaz — geçmiş
    `due_date`'li bir test belgesinde anlık bildirim gelir ama vade
    hatırlatması hiç planlanmaz.
- **Türkçe karakterli test PDF'i üretme** — `reportlab` ile sentetik PDF
  üretilebilir ama standart fontlar (Helvetica/WinAnsi) `İ ı Ş ş Ğ ğ`
  içermez; `pdfmetrics.registerFont(TTFont(...))` ile
  `C:/Windows/Fonts/arial.ttf` gömülmeli (Identity-H/Unicode CMap). pdfrx
  metni content stream sırasına göre çıkarır, fixture'da satır sırası
  yeterli, x/y önemsiz.
- **Supabase PKCE code_verifier, isteği başlatan storage'a bağlı** —
  `resetPasswordForEmail`/OAuth/email-onay linkleri başlatıldığı yerin
  (web origin'i ya da mobil local storage'ı) dışında bir yerde açılırsa
  `AuthException(Code verifier could not be found)` ile sessizce
  başarısız olur. Çözüm: `redirectTo`'yu web'de dinamik origin, mobilde
  `muhasebetakip://...` custom scheme olarak ayarlamak (AndroidManifest
  intent-filter + iOS `CFBundleURLTypes`), ve Supabase Dashboard →
  Authentication → URL Configuration'a `muhasebetakip://**`'i eklemek —
  atlanırsa aynı sessiz-fallback tekrarlanır.
- **Google OAuth ile `handle_new_user` trigger'ı çakışırdı** — trigger her
  `auth.users` insert'inde `role` metadata'sı yoksa exception atıyordu; bu
  e-posta/şifre `signUp()` için doğruydu ama Google OAuth callback'inin
  metadata'sında `role` olmadığından insert'i tamamen iptal ediyordu.
  Çözüm (`20260730140000_google_oauth_signup.sql`): trigger yalnızca
  `role` varsa profil oluşturur; Google girişi profilsiz iner,
  `resolveRedirect` bunu `hasSession && user == null` ile yakalayıp
  `/complete-signup`'a yönlendirir (`complete_oauth_signup` RPC davet
  kodunu `auth.uid()` ile tekrar doğrular). Aynı e-postayla önceden
  e-posta/şifre hesabı olan biri Google ile girerse kimlikler otomatik
  birleşir.
- **E-posta onayı + şifre politikası iki yerde tanımlı, birlikte
  değişmeli** — Supabase Dashboard (`Authentication → Providers → Email`)
  hosted projeyi kontrol eder; `supabase/config.toml`'daki `[auth]` yalnızca
  yerel `supabase start` içindir, `supabase config push` çalıştırmak
  `site_url`/redirect URL'lerini production'ı kıracak şekilde ezer —
  bilerek kullanılmıyor. İstemci tarafı aynı kuralı
  `password_policy.dart`'ta ayrıca doğruluyor. Resend, custom SMTP olarak
  devrede.
- **Claude Code'un Bash tool'undan `flutter run -d web-server`
  başlatılırken stdin `/dev/null`'a bağlanıyor** — terminaldeki `r`/`R`
  hot reload tuşları çalışmaz. Kaynak değişikliğini yansıtmak için: portu
  dinleyen `dart.exe` PID'ini (`netstat -ano` → `Get-CimInstance
  Win32_Process`) `taskkill /PID <pid> /T /F` ile öldürüp aynı portta
  yeniden başlat — aynı origin'e navigate edince Supabase oturumu
  (localStorage) korunur.
- **`flutter run -d web-server` sayfası bazen sonsuza kadar beyaz kalır,
  hata vermeden** — özellikle Dart Debug Chrome uzantısı olmayan bir
  tarayıcıda (ör. claude-in-chrome) DWDS debug bağlantısı hiç kurulamayıp
  modül yüklemesi kalıcı takılabiliyor ("The web-server device requires
  the Dart Debug Chrome extension" uyarısı log'da görülür). Teşhis:
  tarayıcıda `performance.getEntriesByType('resource').length` birkaç
  kontrol arasında artmıyorsa süreç ölmüştür. Kesin çözüm: DWDS'e hiç
  ihtiyaç duymayan statik bir release build al (`MSYS_NO_PATHCONV=1
  flutter build web --dart-define-from-file=env/dev.json --base-href /`)
  ve `python -m http.server <port>` gibi sade bir dosya sunucusuyla
  servis et.
- **`delete_own_account` gerçek `auth.users`'ı silmiyor, bilinçli kabul
  edilmiş bir açık bırakıyor** — hesap "silindiğinde" yalnızca
  `profiles.deleted_at` set edilip isim anonimleştiriliyor; `auth.users`
  satırı hemen geçersiz olmuyor. `resolveRedirect` bunu yalnızca
  **uygulama içi** yönlendirmeyle engelliyor — RPC'lerde/RLS'de
  `deleted_at is null` kontrolü yok, yani çalınmış bir token süresi
  dolana kadar kullanılabilir. Bilerek düzeltilmedi; ileride ana RPC'lere
  bu kontrolü eklemek bir seçenek.
- **`USE_EXACT_ALARM` Play politikasında "çalar saat/takvim" olmayan
  uygulamalar için uygun değil** — bu izin Play Console'da "temel işlev
  çalar saat/takvim" beyanı gerektiriyordu, kaldırıldı; yalnızca daha az
  kısıtlayıcı `SCHEDULE_EXACT_ALARM` kaldı.
- **Play Console'da bir per-item dialog'un kendi "Kaydet"i yalnızca
  session state'e yazıyor, sunucuya değil** — Veri güvenliği/Uygulama
  içeriği gibi formlarda modal'ı kapatmak yetmez, üstteki `⋮` menüsünden
  ayrıca "Taslağı kaydet" yapılmazsa ilerleme sessizce kaybolur (reload
  sonrası "Başlamadı"ya döner). Bazı grid butonları da taze bir
  `read_page`/`find` `ref`'i gerektirir — bayat `ref` sessizce no-op olur.
- **Yeni (13 Kasım 2023 sonrası oluşturulan) kişisel geliştirici hesapları
  için "Uygulamayı incelemeye gönder" kilidi, Internal testing'in
  kendisiyle değil Closed testing zorunluluğuyla ilgili** — buton
  belirsiz bir mesajla kilitli kalır, gerçek sebep
  (support.google.com/googleplay/android-developer/answer/14151465): bu
  hesap sınıfı Production'a geçmeden önce en az **12 test kullanıcısıyla
  en az 14 gün kesintisiz** Closed testing şart koşuyor. Bir Closed
  testing kanalı oluşturup aynı AAB'yi ekleyip en az bir ülke + bir test
  kullanıcı listesi atayınca kilit anında açılır.
- **Meta Business Verification akışında bir reCAPTCHA adımı çıkabilir —
  Claude Code bunu çözemez/atlayamaz**, kullanıcı kendisi tıklamalı.
- **Bir kaynağı (telefon numarası, domain vb.) yeni bir entegrasyona
  bağlamadan önce, o kaynağın halihazırda başka bir amaçla kullanılıp
  kullanılmadığını erken sor** — WhatsApp Business Platform'a eklenen bir
  telefon numarası, normal WhatsApp/WhatsApp Business **uygulamasından**
  tamamen kopar. Bu çakışma, kullanıcıya numara kararı ilk gündeme
  geldiğinde söylenmeliydi, Business Verification belgeleri
  yüklendikten sonra değil.

## Durum

Web (`tahakkukfisi.com`) production'da güncel, tüm ana akışlar
(auth — davet kodu/e-posta+şifre/Google, sınıflandırma, upload,
ödemeler/takvim/bilgilendirme, hesap dondurma/silme, WhatsApp switch'i)
Glassmorphism tasarımıyla web'de uçtan uca doğrulandı. **2026-07-29'dan
sonraki hiçbir özellik gerçek Android cihazda ayrıca doğrulanmadı** —
yalnızca ilk mobil bildirim/glassmorphism/şifre sıfırlama turu (Samsung
A51, Temmuz sonu) gerçek cihazda test edildi.

Test hesapları: `muhasebeci.demo@example.com` / `mukellef.demo@example.com`
(şifre `PlayReview2026!Fisi`) — birbirine bağlı muhasebeci/mükellef çifti,
Play Store reviewer'lara da verildi. Gerçek kişisel hesap:
`cakalogluer@gmail.com` (`role=client`, gerçek muhasebecisi
`uuysall@gmail.com` — WhatsApp testleri için geçici olarak demo
muhasebeciye bağlanıp sonra geri bağlandı, bkz. gotcha'lar).

Sınıflandırma motoru gerçek GİB/SGK belgeleriyle doğrulandı (bkz.
gotcha'lar). SGK işe giriş/işten ayrılış alanları tek örnekle test edildi,
yeni örnekle tekrar kontrol edilmeli.

Reminder ayarları (`defaultReminderHour=9`, `defaultReminderDaysBefore=1`,
`settings_repository.dart`) varsayılan/doğru değerlerinde.

Not: ikinci, bağımsız bir firma için kopyalama fikri gündemden kaldırıldı —
tekrar gündeme gelmedikçe önerilmemeli.

**Play Store**: `com.tahakkukfisi.app`, "Nice Yazılım" geliştirici hesabı.
Mağaza listesi/Data Safety/IARC tamamlandı, imzalı AAB (versionCode 3)
Internal + Closed testing'e yüklendi, 14 değişiklik Google incelemesine
gönderildi. Production'a geçiş **Closed testing'e en az 12 gerçek
kullanıcının 14 gün kesintisiz katılımını** bekliyor (bkz. gotcha'lar),
henüz tamamlanmadı.

**WhatsApp bildirimi**: Kod tamam, gerçek `documents` insert trigger'ıyla
uçtan uca doğrulandı (WhatsApp + FCM push aynı anda, birbirini
etkilemeden çalışıyor). `Ayarlar → Mükellef Bilgileri`'nde muhasebeci
artık telefon + "WhatsApp bildirimi gönder" switch'ini uygulamadan
yönetebiliyor. Şu an yalnızca Meta'nın ücretsiz **test numarasıyla**
(`+1 555-604-1485`, yalnızca doğrulanmış test alıcısına — şu an sadece
kullanıcının kendi numarası) çalışıyor. Gerçek numaraya geçiş için Meta
Business Verification süreci başlatıldı (belgeler yüklendi, ~2 iş günü
inceleme) ama **numara kararı askıda** — kullanıcının mevcut iş telefonu
kişisel/başka iş için WhatsApp Business uygulamasıyla aktif kullanılıyor,
bu numarayı WABA'ya bağlamak o kullanımı bozar (bkz. Backlog, gotcha'lar).

## Backlog

Play Store production'a geçiş:
- **Closed testing**: "Kapalı test - alfa" kanalına en az 12 gerçek test
  kullanıcısı davet edilip (katılım linki:
  `https://play.google.com/apps/testing/com.tahakkukfisi.app`) en az 14
  gün kesintisiz kayıtlı tutulmalı — tamamlanmadan Production'a başvuru
  açılmıyor.
- Google'ın 14 değişiklik incelemesi sonucu beklenmeli (genelde 7 gün).
- İkisi tamamlanınca Kontrol panelindeki "Üretime erişim için başvuruda
  bulunma" formu doldurulup Production'a terfi başvurusu yapılmalı.
- Google OAuth consent screen'i Testing'den çıkarıp Publish App yapma.

WhatsApp gerçek numaraya geçiş:
- Business Verification sonucu bekleniyor (~2 iş günü, 2026-09-14'te
  başladı) — sonuç numaradan bağımsız, geçerli kalır.
- **Kullanıcı ayrı/dedike bir telefon numarası temin etmeli** — mevcut iş
  telefonu kişisel kullanımda olduğu için kullanılamıyor. Numara hazır
  olunca: WABA'ya eklenip SMS/arama koduyla doğrulanmalı, ardından
  `WHATSAPP_PHONE_NUMBER_ID`/`WHATSAPP_ACCESS_TOKEN` gerçek değerlerle
  güncellenmeli.
- **İYS (ticari elektronik ileti onay sistemi) uygulanabilirliği hâlâ
  netleşmedi** — `whatsapp_enabled` varsayılan `false` kill switch bu
  yüzden var; genel açılışa (herkese `true`) geçmeden önce hukuki netlik
  gerekiyor.

Diğer:
- **Deleted account session gap** (bkz. gotcha'lar): bilerek kabul
  edilmiş bir artık risk, ana RPC'lere `deleted_at is null` kontrolü
  eklemek gelecekte bir seçenek.
- **CAPTCHA/rate limiting** (login/signup): Supabase Auth zaten IP bazlı
  temel rate limiting uyguluyor; hCaptcha/Turnstile ayrı bir üçüncü taraf
  hesabı gerektirdiğinden bekletiliyor.
