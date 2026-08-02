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
flutter build appbundle --release --dart-define-from-file=env/dev.json
```

CI (`.github/workflows/ci.yml`), `flutter analyze`/`flutter test`'ten sonra
`build_runner build` çalıştırıp `git diff --exit-code` ile üretilen
`.g.dart`'ların commit'lenmiş haliyle aynı olduğunu kontrol ediyor —
`@riverpod` ile işaretli bir dosyayı (method eklemek dahil, dönüş tipini
değiştirmesen bile) değiştirdikten sonra `build_runner` çalıştırmayı
unutursan bu adım kırmızı olur (2026-07-31'de `auth_controller.dart`/
`app_router.dart` düzenlemesinden sonra tam bu yüzden kırıldı — hash sabiti
dosya içeriğine göre değişiyor, method body'si `build()` imzasını
etkilemese de).

`env/dev.json` gitignore'da — `env/dev.example.json`'dan türetilir
(`SUPABASE_URL`, `SUPABASE_PUBLISHABLE_KEY`).

Supabase hosted proje: `tkgbjurobhuyxdetyqxd`. Migration: `supabase db push`
(linked proje). Edge Function deploy:
`supabase functions deploy on-document-insert --no-verify-jwt`.

Firebase proje: `muhasebe-643d9` (`flutterfire configure` ile üretildi).
`lib/firebase_options.dart` ve `android/app/google-services.json` gerçek
değerler içeriyor ve commit edilmiş durumda (API key'ler gizli değil,
Firebase app-restriction ile korunuyor — standart pratik).

Android `applicationId`: `com.tahakkukfisi.app` (2026-07-30'da
`com.muhasebeci.muhasebe_takip`'ten değiştirildi, Play Store yayınından
önce — yayınlandıktan sonra değiştirilemez). Firebase Android app'i bu yeni
applicationId için ayrıca kaydedildi (`flutterfire configure
--platforms=android`, ios/web'e dokunulmadı; `google-services.json`'da eski
paket adı için de bir client kaydı hâlâ duruyor, zararsız). Release
imzalama `android/key.properties` + `android/upload-keystore.jks` ile
yapılıyor — ikisi de gitignore'da, yalnızca bu makinede var. **Kaybedilirse
uygulama bir daha güncellenemez**, güvenli yedeklenmeli (parola yöneticisi
vb.). `android/app/build.gradle.kts`, `key.properties` yoksa release
build'i debug key'e düşürüyor (fresh checkout/CI hâlâ derlenebilsin diye).

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
  hatası çıkar (bkz. `fcmServiceProvider`). İkinci somut örnek:
  `documentActionsProvider` — hiçbir widget'ta `ref.watch` edilmiyor, sadece
  `onPressed` içinde anlık `ref.read(...).notifier` ile çağrılıyordu; birden
  fazla `await`'li `markPaid()` çalışırken provider disposed oluyor ve
  hata sessizce yutuluyordu (belge detayındaki "Ödendi" butonu asla
  güncellenmiyordu, sadece ekrandan çıkıp girince düzeliyordu — gerçek
  cihazda glass-restyle testi sırasında bulundu). `keepAlive: true` çözdü.
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
- **Google OAuth ile `handle_new_user` trigger'ı çakışırdı, şimdi ayrıştı**
  — trigger eskiden her `auth.users` insert'inde koşup client için davet
  kodu yoksa `raise exception` atıyordu; bu, e-posta/şifre `signUp()`
  çağrılarımız için doğruydu (`data:` içinde her zaman `role` gönderiyoruz)
  ama Google'ın OAuth callback'i de `auth.users`'a insert yapıyor ve onun
  metadata'sında `role` yok — trigger insert'i tamamen iptal ediyor,
  kullanıcı uygulamaya hiç ulaşamadan patlıyordu. Çözüm
  (`20260730140000_google_oauth_signup.sql`): trigger artık yalnızca
  `raw_user_meta_data` içinde `role` anahtarı varsa (yani bizim kontrollü
  `signUp()` çağrılarımızdan geliyorsa) profil oluşturuyor; Google girişi
  oturumla ama profilsiz iniyor, `app_router.dart`'taki `resolveRedirect`
  bunu `hasSession && user == null` ile yakalayıp `/complete-signup`'a
  yönlendiriyor (`CompleteSignupScreen` rol/isim/davet kodu topluyor,
  `complete_oauth_signup` RPC'si aynı davet kodu doğrulamasını
  `auth.uid()` ile tekrar yapıyor). Aynı e-postayla önceden e-posta/şifre
  hesabı olan biri Google ile girerse Supabase kimlikleri otomatik
  birleştiriyor — bu durumda profil zaten var, `/complete-signup`
  atlanıyor.
- **`signInWithOAuth`/`signUp` mobil redirect'i de PKCE gotcha'sına tabi**
  — `AuthController._authRedirectTo` aynı web-origin-vs-custom-scheme
  ayrımını (`password_reset_controller`'daki gibi) Google girişi ve
  e-posta onay linki için de kullanıyor (`muhasebetakip://login-callback`).
  AndroidManifest'teki `muhasebetakip` intent-filter'ı path'siz/genel
  olduğu için (bkz. şifre sıfırlama), ayrı bir path/manifest girişi
  gerekmedi.
- **E-posta onayı + şifre politikası iki yerde tanımlı, birlikte
  değişmeli** — Supabase Auth'un min uzunluk/karakter kuralı ve "Confirm
  email" anahtarı Dashboard'da (`Authentication → Providers → Email`)
  ayarlanıyor; `supabase/config.toml`'daki `[auth]`/`[auth.email]` aynı
  değerleri yalnızca yerel `supabase start` için taşıyor, hosted projeye
  otomatik yansımıyor (`supabase config push` tüm `config.toml`'u
  gönderiyor, dosyadaki `site_url`/`additional_redirect_urls` hâlâ
  `127.0.0.1` olduğu için bunu çalıştırmak production redirect URL'lerini
  sessizce ezip auth'u kırardı — bilerek kullanılmadı). İstemci tarafı
  aynı kuralı `lib/features/auth/domain/password_policy.dart`'ta
  ayrıca doğruluyor (sunucu reddinden önce anlık geri bildirim için).
  Resend, Supabase'in SMTP Settings'inde custom SMTP olarak devrede.
- **Claude Code'un Bash tool'undan `flutter run -d web-server` başlatılırken
  stdin `/dev/null`'a bağlanıyor** — bu yüzden terminaldeki `r`/`R` hot
  reload/restart tuşları çalışmaz (basılamaz). Kaynak değişikliğini
  tarayıcıya yansıtmanın tek yolu: portu dinleyen process'i (`netstat -ano
  | grep :PORT` → PID → `Get-CimInstance Win32_Process` ile
  `flutter_tools.snapshot ... run -d web-server` komut satırına sahip
  dart.exe PID'i bul) `taskkill /PID <pid> /T /F` ile öldürüp aynı portta
  yeniden `flutter run -d web-server --web-port=<port> ...` başlatmak.
  Tarayıcı sekmesini aynı origin'e (`http://localhost:<port>`) yeniden
  navigate edince Supabase oturumu (localStorage'da persist ediliyor)
  korunuyor, yeniden login gerekmiyor.
- **`flutter run -d web-server` sayfası bazen sonsuza kadar beyaz kalır,
  hata vermeden** — DDC modül yükleyicisi (`ddc_module_loader.js`) tüm
  script tag'lerini (bu projede ~1600 modül) baştan DOM'a ekliyor ama
  gerçek derleme `frontend_server_aot.dart.snapshot` alt sürecinde
  (flutter tool'un çocuğu) oluyor; bu alt süreç kaynak yetersizliğinde
  (aynı anda çalışan orphan Gradle daemon'ları, birden fazla `flutter run`
  denemesi vb.) sessizce ölürse, ana `flutter run` process'i hâlâ ayakta
  kalıp portu dinlemeye devam ediyor, tarayıcı bağlantıları
  `ESTABLISHED` kalıyor ama hiçbir modül asla gelmiyor — konsolda hata
  yok, `flutter run` log'unda da yeni satır yok. Teşhis: tarayıcıda
  `performance.getEntriesByType('resource').length` birkaç kontrol
  arasında hiç artmıyorsa (gerçek yavaşlıkta artmaya devam eder) ve
  derleyici PID'si (`Get-CimInstance Win32_Process` ile `frontend_server`
  komut satırını taşıyan `dartaotruntime.exe`) `tasklist`'te yoksa, süreç
  ölmüştür — tek çözüm `taskkill /F /T` ile tüm `flutter run` ağacını
  öldürüp portu sıfırdan başlatmak. Önlem: build/test/analyze gibi ağır
  komutları aynı anda bir `flutter run -d web-server` ile paralel
  çalıştırmaktan kaçın, orphan Gradle daemon'larını temizle (yukarıdaki
  madde). 2026-08-02: `taskkill` + yeniden başlatma bir kez işe yaramadı
  (aynı beyaz sayfa, `performance.getEntriesByType('resource').length`
  yine sabit) — `flutter run` log'u da "The web-server device requires
  the Dart Debug Chrome extension for debugging" uyarısı veriyordu; bu
  uzantı olmayan bir tarayıcıda (ör. claude-in-chrome) DWDS debug bağlantısı
  hiç kurulamayıp modül yüklemesi kalıcı olarak takılı kalabiliyor. Kesin
  çözüm: `MSYS_NO_PATHCONV=1 flutter build web --dart-define-from-file=env/dev.json
  --base-href /` ile statik bir release build alıp `python -m http.server
  <port>` gibi sade bir dosya sunucusuyla servis etmek — DWDS/debug
  bağlantısına hiç ihtiyaç duymadığından bu senaryoda güvenilir çalışıyor.
- **`delete_own_account` gerçek `auth.users`'ı silmiyor, bilinçli kabul
  edilmiş bir açık bırakıyor** — hesap "silindiğinde" yalnızca
  `profiles.deleted_at` set edilip `full_name` anonimleştiriliyor
  (`20260731150000_account_freeze_delete.sql`); `auth.users` satırı ve
  dolayısıyla oturum/refresh token hemen geçersiz olmuyor (bkz. o
  migration'ın yorumundaki cascade-delete gerekçesi). `resolveRedirect`
  bunu yalnızca **uygulama içi** yönlendirme ile engelliyor —
  `mark_document_paid` gibi mevcut RPC'lerde veya `documents`/storage RLS
  politikalarında `deleted_at is null` kontrolü yok. Yani "silinmiş" bir
  hesabın çalınmış/sızıntı bir token'ı, token süresi dolana kadar
  documents/storage'ı kullanmaya devam edebilir — 2026-07-31'de
  `/security-review` ile bulundu, bilerek (henüz) düzeltilmedi; ileride
  ana RPC'lere `deleted_at is null` kontrolü eklemek bir seçenek.

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

Mükellef ekranları (Ödemeler/Takvim/Bilgilendirme) Glassmorphism'e
geçirildi: `lib/core/theme/glass_theme.dart` + `lib/core/widgets/glass_*`
paylaşımlı bileşenler, gradient arka plan, toplam bekleyen tutar hero
kartı, mikro etkileşimler (kaydırma aksiyonları, "Ödendi" onay animasyonu +
titreşim, vade yaklaşınca nabız efekti, tüm ödemeler bitince confetti).
Gerçek cihazda (Samsung A51) hem kaydırma performansı hem tüm
etkileşimler doğrulandı (2026-07-28).

Muhasebeci ekranları (Mükelleflerim/Belge Yükle/Gönderilenler) ve
paylaşımlı belge detay ekranı da aynı Glassmorphism diline geçirildi
(2026-07-29): `AccountantHomeScreen` artık `ClientHomeScreen` ile aynı
transparent AppBar + `GradientScaffoldBackground` kabuk desenini
kullanıyor; `ClientsScreen`/`UploadScreen`/`UploadDraftCard`/
`SentDocumentsScreen` düz `Card`/`ListTile`/`DataTable`/`Chip`
kullanımlarından `GlassCard`/`GlassSurface`/`StatusBadge` + merkezi
urgency paletine geçti. `ShakeWrapper` artık `upload_draft_card.dart`'taki
`_ErrorRow`'da kullanılıyor (`trigger: draft.errorMessage`).
`document_detail_screen.dart` (hem muhasebeci hem mükellef tarafından
kullanılan paylaşımlı ekran) rol-nötr tek bir glass stiline geçirildi —
davranış değişmedi. Web'de (`flutter run -d web-server`, gerçek
`cakalogluer@gmail.com` muhasebeci hesabıyla) uçtan uca görsel doğrulandı;
gerçek cihazda ayrıca doğrulanmadı.

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

`documents` tablosundaki `documents_update_client`/`documents_update_accountant`
RLS politikaları kaldırıldı (2026-07-29, migration
`20260729120000_documents_update_rpc_only.sql`, canlıya uygulandı). Bunlar
satır sahipliğini kontrol ediyordu ama sütun kısıtlaması yoktu — geçerli
bir JWT'si olan biri PostgREST'e doğrudan istek atıp kendi belgesinin
`amount`/`due_date`/`status` gibi alanlarını `mark_document_paid`
RPC'sindeki kontrolleri atlayarak değiştirebilirdi. Uygulama zaten
`documents`'a hiç ham `.update()` çağrısı yapmıyor (sadece `.insert()` ve
`mark_document_paid`/`mark_document_seen` RPC'leri, ikisi de
`security definer` olduğundan RLS'den etkilenmiyor) — davranış değişmedi,
sadece kullanılmayan bir açık kapatıldı.

Tasarım tutarlılığı incelemesi (`design-reviewer` agent'ı, 2026-07-29)
yapıldı ve bulunan 10 maddenin tamamı uygulandı. En büyüğü: auth ekranları
(`login`/`signup`/`forgot_password`/`reset_password_screen.dart`) daha önce
iki glass-restyle geçişine de dahil olmamıştı (stok `Scaffold`/`Center`) —
artık diğer ekranlarla aynı `GradientScaffoldBackground` + `GlassCard`
kalıbını kullanıyor. `settings_screen.dart` da glass diline geçti
(`GlassCard` + `Theme.textTheme.titleLarge`). Diğerleri: `GlassStyle.
secondaryTextColor` sabiti eklendi (`Colors.black54` tekrarları yerine —
`payments_screen.dart`/`clients_screen.dart`/`sent_documents_screen.dart`);
`upload_draft_card.dart`'taki durum etiketleri `Chip` yerine `StatusBadge`,
"Gönderildi" ikonu `Colors.green` yerine `urgencyPaid`; takvim marker
rengi artık `urgencyUpcoming`'i `urgencySoon`'dan ayırt ediyor (önceden
ikisi de aynı turuncuydu); `calendar_screen.dart`/`info_screen.dart` boş
durumları ve `payments_screen.dart`'taki yaklaşan-ödeme banner'ı
`GlassCard`/`GlassSurface`'e taşındı; `document_detail_screen.dart` artık
hardcoded `840` yerine `Breakpoints.rail` kullanıyor; 3 icon-only "kapat"
butonuna `tooltip` eklendi. Web'de (`cakalogluer@gmail.com` muhasebeci,
`cakalogluercin86@gmail.com` mükellef) görsel doğrulandı — takvimdeki
soon/upcoming renk ayrımı ve yükleme taslak rozetleri hesapta yeterli veri
olmadığından görsel doğrulanamadı, yalnızca kod incelemesiyle teyit edildi;
gerçek cihazda hiçbiri ayrıca doğrulanmadı.

Mükellef tarafına "Ödenenler" ekranı eklendi (2026-07-29): ödendi
işaretlenen ödeme belgeleri `Ödemeler` listesinden çıkıp bu yeni sekmeye
taşınıyor, ödeme tarihine (`paidAt`) göre en yeni en üstte sıralanıyor.
`PaymentListTile` artık `status == paid` durumunda bir "Ödenmedi"
butonu/swipe aksiyonu gösteriyor (`documentActionsProvider.markUnpaid`),
bu da yeni `mark_document_unpaid` RPC'sini çağırıp belgeyi tekrar
`pending`'e alıyor ve (varsa) vade hatırlatmasını yeniden planlıyor
(`mark_document_paid`'in `cancelReminders`'ının simetriği). RPC migration
(`20260729130000_mark_document_unpaid.sql`) canlı Supabase'e uygulandı.
Web'de uçtan uca doğrulandı (deploy edildi); gerçek cihazda ayrıca
doğrulanmadı.

Takvim ekranında (`calendar_screen.dart`) üç değişiklik (2026-07-29):
`table_calendar`'ın varsayılan İngilizce format-toggle butonu ("2 weeks")
`headerStyle: HeaderStyle(formatButtonVisible: false)` ile kaldırıldı;
hafta artık Pazartesi'den başlıyor (`startingDayOfWeek:
StartingDayOfWeek.monday`); Cumartesi/Pazar hücreleri ve başlıkları
`urgencyOverdue` rengiyle (kırmızı) vurgulanıyor
(`CalendarStyle.weekendDecoration`/`weekendTextStyle` +
`DaysOfWeekStyle.weekendStyle`). Web'de doğrulandı. Not: "Çarşamba"
kısaltması "Car" görünüyor (Ç harfi eksik) — `table_calendar`'ın Türkçe
gün kısaltmalarıyla ilgili ayrı, önceden var olan bir sorun, henüz
düzeltilmedi.

Uygulama genelinde daha canlı bir renk paleti uygulandı (2026-07-29,
tek kaynak `lib/core/theme/glass_theme.dart` — `ColorScheme.fromSeed`
tüm Material3 rollerini, `appBackgroundGradient` her ekranın ortak
arka planını, `urgency*` sabitleri durum rozeti/işaretleyici renklerini
belirlediği için tek dosyadan tüm uygulamaya (web+mobil, muhasebeci+
mükellef) yayılıyor): seed rengi donuk indigo `#4F5FE0`'dan canlı
mor-mavi `#5B34F5`'e; arka plan gradyanı soluk pastel
(`#EEF1FF`→`#E3E9FD`→`#DCEBFB`) yerine belirgin mor→mavi→nane yeşili
(`#D8CCFF`→`#BFDDFF`→`#B9F3E4`); `urgencyPaid/Overdue/Soon/Upcoming`
daha doygun tonlara çekildi (`urgencyNeutral` kasıtlı olarak düşük
doygun bırakıldı). Web'de görsel doğrulandı ve deploy edildi; gerçek
cihazda ayrıca doğrulanmadı.

Play Store yayınına hazırlık (2026-07-30/31): gerçek uygulama ikonu
(`tahakkuk_fisi.png` → `assets/icon/icon.png`, `flutter_launcher_icons`
ile legacy+adaptive Android ikonları üretildi), `applicationId` →
`com.tahakkukfisi.app`, release upload keystore + `build.gradle.kts`
imzalama (bkz. gotcha'lar), `web/privacy.html` gizlilik politikası
(deploy edildi, `https://tahakkukfisi.com/privacy.html` canlıda).
`app-release.aab` ve `app-release.apk` derlendi, apksigner ile imza
doğrulandı (`CN=Tahakkuk Fisi`, debug key değil). Play Console'da
geliştirici hesabı/mağaza listesi/data safety formu/aab yükleme gibi asıl
yayına alma adımları henüz yapılmadı (bkz. aşağıdaki Backlog).

Google ile giriş eklendi (web + Android, Supabase OAuth ile — native
`google_sign_in` SDK'sı kullanılmadı, bkz. gotcha'lar): hem mevcut
e-posta/şifre hesabına bağlanma hem sıfırdan kayıt (yeni
`CompleteSignupScreen` + `complete_oauth_signup` RPC) gerçek Google
hesaplarıyla uçtan uca doğrulandı (web'de). Android'de ayrıca
doğrulanmadı. Google Cloud Console OAuth consent screen'i hâlâ "Testing"
modunda — yalnızca eklenen test kullanıcıları girebiliyor, "Publish App"
yapılmadı.

Şifre politikası sıkılaştırıldı (min 8 karakter + büyük/küçük harf/rakam,
hem `password_policy.dart`'ta hem Supabase Dashboard'da) ve e-posta onayı
(Resend SMTP üzerinden) açıldı — kayıt sonrası oturum verilmiyor, kullanıcı
onay linkine tıklayana kadar `signInWithPassword` `email not confirmed`
ile reddediyor; `signUp()` artık `emailRedirectTo` gönderiyor ve
`AuthController.signUpAccountant/signUpClient` `bool` dönüp ekranın "check
your inbox" mesajı göstermesini sağlıyor. Hepsi gerçek bir hesapla
(`cakalogluer+onaytest@gmail.com`) uçtan uca doğrulandı.

Yukarıdaki değişikliklerin tamamı commit'lenip `master`'a push edildi;
mevcut CI (`.github/workflows/ci.yml`) yeşil (ilk push'ta unutulan
`build_runner` yüzünden bir kez kırmızı oldu, bkz. gotcha'lar — ikinci
commit'le düzeltildi).

2026-07-31'de backlog'daki "Diğer" maddelerinin çoğu tamamlandı:
adaptive icon foreground içeriği (`assets/icon/icon_foreground.png`)
%66'dan %90'a çıkarıldı ve Android ikonları yeniden üretildi (kullanıcı
yeni bir görsel yüklemedi, mevcut görsel yeniden ölçeklendi — dairesel
maske önizlemesiyle kırpılma olmadığı doğrulandı); imzalı
`app-release.apk` derlendi. Ayarlar sayfasına uygulama sürümü +
geliştirici iletişim bilgisi eklendi (`package_info_plus`,
`app_info_section.dart`). Hesap dondurma (geçici, geri alınabilir giriş
engeli) ve hesap silme (soft-delete/anonimleştirme — `documents`
tablosundaki cascade-delete nedeniyle gerçek `auth.users` silme kasıtlı
olarak yapılmıyor, bkz. gotcha'lar) eklendi:
`profiles.frozen_at`/`deleted_at` + `freeze_own_account`/
`unfreeze_own_account`/`delete_own_account` RPC'leri, `resolveRedirect`'e
yeni `/account-frozen`/`/account-deleted` dallanması, muhasebeci tarafına
ilk kez bir Ayarlar sekmesi (`AccountantSettingsScreen`, iki alt sekme:
Hesap + Mükellef Bilgileri) eklendi. Mükellef Bilgileri alt sekmesinde
muhasebeci her mükellefi için telefon/adres/not girebiliyor
(`client_contact_info` tablosu, yalnızca ilgili muhasebeci erişebiliyor).
`/security-review` ile bulunan 2 gerçek RLS açığı (client_contact_info
update politikasında eksik sahiplik kontrolü; frozen_at/deleted_at'ın RPC
dışından ham `PATCH` ile değiştirilebilmesi) aynı gün kapatıldı. Tüm
migration'lar canlı Supabase'e uygulandı; hiçbiri gerçek cihazda ayrıca
doğrulanmadı (yalnızca web'de derleme/route testleriyle).

2026-08-01: reminder saati Samsung A51 cihazında Ayarlar'dan tekrar 9'a
çevrildi. Takvimde "Çarşamba" kısaltmasının "Car" gibi görünmesi
(`table_calendar`'ın `intl` tabanlı varsayılan gün başlığı yerine artık
`calendarBuilders.dowBuilder` ile sabit Türkçe kısaltma dizisi
kullanılıyor — `calendar_screen.dart`) ve mobilde uygulama içi AppBar'ların
(`role_shell_scaffold.dart`, `document_detail_screen.dart`) başlık/ikon
rengi düzeltildi: `backgroundColor: Colors.transparent` verilince Flutter
`Colors.transparent.computeLuminance()`'ı (alfa kanalını yok sayıp saf
siyah kabul eder) kullanarak arka planı "koyu" sanıyor ve başlığa düşük
kontrastlı gri bir ön plan rengi veriyordu — artık her iki AppBar'da
`foregroundColor: Colors.white` açıkça set ediliyor.

Bu ilk `foregroundColor: Colors.white` değişikliği yeni bir `design-lead`
agent'ının (bkz. `.claude/agents/design-lead.md` — statik kod taramasının
ötesinde uygulamayı gerçekten `flutter run -d web-server` ile başlatıp
tarayıcıda gezinen, ekran görüntüsü alan bir tasarım lideri) canlı
incelemesinde **gerçek bir regresyon** olarak yakalandı: `GradientScaffoldBackground`
yalnızca `Scaffold.body`'yi sarıyordu, AppBar alanı gradient'in dışında
kalıp temanın açık zemininde kalıyordu — beyaz başlık/ikonlar tamamen
görünmez oluyordu (önceki gri halinden daha kötü). Düzeltme: gradient artık
`body` yerine tüm `AdaptiveScaffold`/`Scaffold`'u (AppBar dahil) sarıyor
(`role_shell_scaffold.dart`, `document_detail_screen.dart`). Aynı canlı
incelemede "Çar" kısaltmasının tarayıcıda gerçekten "Car" render edildiği
de teyit edildi (2026-07-31'deki "küçük punto'da görülmesi zor" teorisi
yanlış çıktı) — gerçek neden `table_calendar`'ın varsayılan
`daysOfWeekHeight` (16px) değerinin cedilla'yı alttaki takvim satırıyla
görsel olarak çakıştırıp gizlemesiydi; `daysOfWeekHeight: 24` ile
düzeltildi. Her iki düzeltme de gerçek Chrome'da (`flutter run -d
web-server`, `cakalogluer@gmail.com` + `cakalogluercin86@gmail.com`
hesaplarıyla) görsel olarak doğrulandı. Henüz gerçek cihazda ayrıca
doğrulanmadı.

`design-lead` agent'ının aynı taramada bulduğu geri kalan tasarım
tutarlılığı notları da aynı gün (2026-08-02) düzeltildi:
`client_contact_info_screen.dart`'taki liste öğesi `GlassCard`'dan
`GlassSurface`'e çevrildi ve boş durumuna ikon eklendi (diğer ekranlardaki
desenle aynı); `accountant_settings_screen.dart`'taki çıplak `TabBar`
artık `GlassSurface` içinde hap biçimli bir indicator ile glass diline
uyuyor; takvim marker'ına (`calendar_screen.dart`) urgency'yi sözel olarak
anlatan bir `Semantics` etiketi eklendi (önceden yalnızca renkle
taşınıyordu); `clients_screen.dart`'taki "Bekleyen Davetler" başlığı
serbest `TextStyle` yerine `Theme.textTheme.titleSmall` kullanıyor. Web'de
canlı Chrome'da (`cakalogluer@gmail.com` hesabıyla, `tahakkukfisi.com`
üzerinde) AppBar/TabBar görsel olarak doğrulandı; kalan dördü yalnızca
`flutter analyze` ile teyit edildi, henüz görsel doğrulama yapılmadı.

2026-08-01: uygulama içinde gizlilik politikasına giden hiçbir bağlantı
olmadığı fark edildi (`web/privacy.html` yalnızca web'de canlıydı, hiçbir
ekran ona linklemiyordu). `AppInfoSection`'a (hem mükellef Ayarlar hem
muhasebeci Ayarlar → Hesap sekmesinde kullanılıyor, tek kaynaktan her iki
role de yayılıyor) `https://tahakkukfisi.com/privacy.html`'i harici
tarayıcıda açan bir "Gizlilik Politikası" satırı eklendi — yeni
`url_launcher` bağımlılığı gerektirdi (`AndroidManifest.xml`'deki mevcut
`<queries>` bloğuna Android 11+ paket görünürlüğü için bir `https` VIEW
intent'i de eklendi). Henüz gerçek cihazda doğrulanmadı.

## Backlog (2026-08-01 itibarıyla henüz yapılmadı)

Play Store yayına alma (bkz. yukarıdaki "Durum", teknik hazırlık bitti,
kalanlar Play Console'da manuel). Android'de Google girişi 2026-08-01'de
gerçek cihazda test edildi ve çalıştığı doğrulandı (önceden yalnızca
web'de doğrulanmıştı):
- Play Console geliştirici hesabı, mağaza listesi (açıklamalar, ekran
  görüntüleri, feature graphic 1024×500 — henüz yok)
- Data safety formu, içerik derecelendirmesi (IARC), izin bildirimi
  (Alarms & reminders → `SCHEDULE_EXACT_ALARM`/`USE_EXACT_ALARM` gerekçesi)
- `app-release.aab`'yi Internal testing'e yükleme → Production'a terfi
- Google OAuth consent screen'i Testing'den çıkarıp Publish App yapma

Diğer:
- **Deleted account session gap** (bkz. gotcha'lar,
  `delete_own_account`): bilerek kabul edilmiş bir artık risk, ana
  RPC'lere `deleted_at is null` kontrolü eklemek gelecekte bir seçenek.
- **CAPTCHA/rate limiting** (login/signup): Supabase Auth zaten IP bazlı
  temel rate limiting uyguluyor; hCaptcha/Turnstile entegrasyonu ayrı bir
  üçüncü taraf hesabı + site key gerektirdiğinden ayrı bir karar olarak
  bekletiliyor.
