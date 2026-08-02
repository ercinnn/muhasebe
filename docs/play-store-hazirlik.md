# Play Store Yayın Hazırlığı

Google Play Console geliştirici hesabı kimlik doğrulaması tamamlanana kadar
hazırlanan taslaklar (2026-08-03). Uygulama oluşturulduğunda bu içerikler
ilgili formlara birebir işlenebilir.

## Mağaza listesi metinleri

**Uygulama adı:** Tahakkuk Fişi

**Kısa açıklama (80 karakter sınırı):**
Muhasebecinizden gelen belgeleri takip edin, ödemeleri kaçırmayın.

**Tam açıklama:**

Tahakkuk Fişi, muhasebeciler ile mükelleflerini aynı uygulamada buluşturan
bir belge takip ve hatırlatma uygulamasıdır.

**Muhasebeciler için:**
- Resmi vergi ve SGK belgelerini (PDF) tek tek veya toplu yükleyin
- Uygulama belgeyi otomatik olarak sınıflandırır: ödeme/bilgilendirme türü,
  tutar, vade tarihi, fiş numarası
- Yüklemeden önce önizleyip gerekirse düzeltin
- Belgeyi doğru mükellefe tek dokunuşla gönderin
- Mükelleflerinizin iletişim bilgilerini tek yerden yönetin

**Mükellefler için:**
- Muhasebecinizin gönderdiği tüm belgeleri liste ve takvim üzerinden görün
- Ödenmesi gereken tutarları ve vade tarihlerini kaçırmayın
- Belgeyi "Ödendi" olarak işaretleyin, ödenenler geçmişinizi ayrı sekmede
  takip edin
- Vade yaklaşınca ve vade gününde otomatik hatırlatma bildirimi alın
- Yeni bir belge geldiğinde anında bildirim alın

**Güvenlik:**
Tüm veriler Supabase altyapısında, satır bazlı erişim kontrolleriyle (RLS)
korunur — her kullanıcı yalnızca kendi verilerine erişebilir.

Muhasebeci-mükellef iletişimini kağıt/WhatsApp/e-posta karmaşasından
kurtarıp tek, düzenli bir akışa taşımak için tasarlandı.

**Kategori önerisi:** İş (Business) veya Finans (Finance)
**İletişim e-postası:** cakalogluer@gmail.com (teyit edilmeli)
**Gizlilik politikası URL:** https://tahakkukfisi.com/privacy.html

**Görsel varlıklar:** `assets/store/` klasöründe hazır
(`feature_graphic.png` 1024×500, `screenshot_1.png`–`screenshot_8.png`
921×1842, hepsi Play Console 2:1 en-boy oranı sınırına uygun).

---

## Data safety (Veri güvenliği) formu taslağı

Veri topluyoruz, ama üçüncü taraflarla (kendi amaçları için) paylaşmıyoruz —
Supabase ve Firebase yalnızca altyapı/işlemci olarak kullanılıyor.

| Kategori | Alt tür | Toplanıyor mu | Paylaşılıyor mu | Amaç | Zorunlu/Opsiyonel |
|---|---|---|---|---|---|
| Kişisel bilgiler | Ad Soyad | Evet | Hayır | Uygulama işlevselliği, Hesap yönetimi | Zorunlu |
| Kişisel bilgiler | E-posta adresi | Evet | Hayır | Uygulama işlevselliği, Hesap yönetimi, Geliştirici iletişimi | Zorunlu |
| Dosyalar ve belgeler | Kullanıcının sağladığı dosyalar | Evet | Hayır | Uygulama işlevselliği | Zorunlu |
| Finansal bilgiler | Diğer finansal bilgiler (belge tutarı, vade tarihi) | Evet | Hayır | Uygulama işlevselliği | Zorunlu |
| Cihaz veya diğer kimlikler | Cihaz kimliği (FCM push token) | Evet | Hayır | Uygulama işlevselliği | Opsiyonel (bildirim izni reddedilirse toplanmaz) |
| Uygulama etkinliği | Uygulama içi etkileşimler (giriş zamanı, belge görüntülenme durumu) | Evet | Hayır | Uygulama işlevselliği, Analitik | Zorunlu |

Toplanmayan/geçerli olmayan kategoriler: Konum, Sağlık ve fitness, Mesajlar,
Fotoğraf/video, Ses dosyaları, Takvim, Kişiler, Web tarama geçmişi, Reklam
kimliği.

**Veri güvenliği pratikleri:**
- Aktarım sırasında şifreleme: Evet (HTTPS/TLS)
- Kullanıcı veri silme talep edebilir mi: Evet (Ayarlar → Hesabımı Sil)
- Bağımsız güvenlik incelemesinden geçti mi: Hayır

**Not:** "Finansal bilgiler" kategorisi Google'ın taksonomisinde daha çok
ödeme yöntemi/satın alma geçmişi için düşünülmüş; bizim durumumuzda
vergi/SGK belge tutarları söz konusu. Hem "Dosyalar ve belgeler" hem
"Finansal bilgiler"i işaretlemek daha muhafazakar bir yaklaşım.

---

## İçerik derecelendirmesi (IARC anketi) taslağı

Beklenen sonuç: Everyone / 3+ / PEGI 3 — içerik tanımlayıcısı olmadan.

| Soru | Cevap |
|---|---|
| Şiddet içeriği var mı? | Hayır |
| Cinsellik/çıplaklık içeriği var mı? | Hayır |
| Küfür/argo içeriği var mı? | Hayır |
| Kontrollü madde referansı var mı? | Hayır |
| Kumar (gerçek veya simüle) içeriyor mu? | Hayır |
| Korkutucu/dehşet içeriği var mı? | Hayır |
| Kullanıcı etkileşimi/iletişim izni var mı? | Hayır (muhasebeci-mükellef arası chat yok, tek yönlü belge paylaşımı) |
| Denetimsiz kullanıcı içeriği paylaşılıyor mu? | Hayır |
| Konum paylaşımı var mı? | Hayır |
| Kullanıcılar birbirleriyle serbestçe kişisel bilgi paylaşabiliyor mu? | Hayır (yalnızca davet koduyla kurulan kapalı muhasebeci-mükellef ilişkisi) |
| Dijital satın alma / uygulama içi satın alma var mı? | Hayır (ileride eklenebilir, o zaman anket güncellenmeli) |
| Reklam içeriyor mu? | Hayır (ileride eklenebilir, o zaman anket güncellenmeli) |
| Kısıtlanmamış internet erişimi sunuyor mu? | Kısmen (Destek/iletişim mailto linki) |

---

## Alarms & reminders izin gerekçesi (SCHEDULE_EXACT_ALARM / USE_EXACT_ALARM)

Play Console bu formu İngilizce doldurmayı bekliyor.

**İngilizce (Play Console'a girilecek):**

> Tahakkuk Fişi connects accountants and their clients for official Turkish
> tax/SGK (social security) payment documents. When a client has a pending
> payment with a real regulatory due date, the app schedules an exact-time,
> alarm-style local reminder (full-screen, high-importance, with sound) so
> the user does not miss the legal deadline.
>
> We require SCHEDULE_EXACT_ALARM / USE_EXACT_ALARM because:
> - The reminder must fire at a specific, user-configured time (default
>   9:00 AM) on the due date and one day before — payment deadlines are
>   fixed by law to specific dates, and Android's standard inexact/batched
>   notification delivery could delay the reminder past the point where
>   the user has time to act.
> - This is core app functionality, not incidental: the app's entire
>   purpose for the client (mükellef) role is to never miss a government
>   tax/SGK payment deadline.
>
> Exact alarms are used only for real payment due dates uploaded by the
> user's own accountant — never for marketing, re-engagement, or any
> non-essential purpose.

**Türkçe (referans için):**

> Tahakkuk Fişi, muhasebeciler ile mükellefleri resmi vergi/SGK ödeme
> belgeleri için buluşturur. Bir mükellefin yasal vade tarihi olan bekleyen
> bir ödemesi olduğunda, uygulama bu vadeyi kaçırmaması için tam saatinde
> çalan, alarm tarzı (tam ekran, yüksek önem, sesli) bir yerel hatırlatma
> planlar.
>
> SCHEDULE_EXACT_ALARM / USE_EXACT_ALARM iznini şu nedenle istiyoruz:
> - Hatırlatma, vade tarihinde ve bir gün öncesinde, kullanıcının
>   belirlediği tam saatte (varsayılan 09:00) çalmalı — ödeme vadeleri
>   yasayla belirli tarihlere bağlıdır, Android'in standart yaklaşık/toplu
>   bildirim teslimatı hatırlatmayı kullanıcının işlem yapabileceği
>   zamandan sonraya geciktirebilir.
> - Bu, uygulamanın yan bir özelliği değil, çekirdek işlevidir: mükellef
>   rolü için uygulamanın tüm amacı, bir devlet vergi/SGK ödeme vadesini
>   asla kaçırmamaktır.
>
> Tam zamanlı alarmlar yalnızca kullanıcının kendi muhasebecisinin
> yüklediği gerçek ödeme vadeleri için kullanılır — pazarlama veya tekrar
> etkileşim amaçlı hiçbir kullanım yoktur.

---

## Henüz yapılmadı / bekleyen adımlar

- **Google OAuth consent screen'i Testing'den çıkarıp Publish App yapma**
  (Google Cloud Console, `muhasebe-643d9` projesi) — tarayıcı uzantısı
  bağlantı sorunu nedeniyle 2026-08-03'te ertelendi, henüz kimlik
  doğrulamasından bağımsız olarak yapılabilir.
- Play Console kimlik doğrulaması tamamlanınca: uygulamayı oluştur → telefon
  numarası doğrulaması → ana mağaza girişi (yukarıdaki metin/görselleri
  yükle) → data safety + içerik derecelendirmesi formlarını gönder →
  `app-release.aab`'yi Internal testing'e yükleyip Production'a terfi
  ettir.
- Doğrulama durumu takibi: `play-console-verification-watch` adlı bulut
  rutini her 6 saatte bir Gmail'i kontrol ediyor
  (https://claude.ai/code/routines/trig_012EuCVbGuAgHFxgZ1ZpRAch).
