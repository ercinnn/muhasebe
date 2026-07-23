/// Synthetic fixture texts modeling the layout described in the
/// classification spec. These are hand-built approximations (not copies of
/// any real government document) meant to exercise the regex/label
/// extraction rules; adjust once real sample PDFs are available in Faz 4.
library;

const kdvTaxAccrualText = '''
T.C.
HAZİNE VE MALİYE BAKANLIĞI
GELİR İDARESİ BAŞKANLIĞI
MERKEZ VERGİ DAİRESİ MÜDÜRLÜĞÜ
TAHAKKUK FİŞİ

SOYADI (UNVANI): YILMAZ TİCARET LTD. ŞTİ.
ADI: -
Vergilendirme Dönemi: 05/2026-05/2026

Ana Vergi Kodu: 0015
Vergi Adı: GERÇEK USULDE KATMA DEĞER VERGİSİ
Tahakkuk Eden: 1.939,70
Vadesi: 26/06/2026

TOPLAM                                                       1.939,70

Fiş No: 2026072201Y7m0000088
''';

const mahsupTaxAccrualText = '''
T.C.
HAZİNE VE MALİYE BAKANLIĞI
GELİR İDARESİ BAŞKANLIĞI
MERKEZ VERGİ DAİRESİ MÜDÜRLÜĞÜ
TAHAKKUK FİŞİ

SOYADI (UNVANI): DEMIR YAPI A.Ş.
ADI: -
Vergilendirme Dönemi: 06/2026-06/2026

Ana Vergi Kodu: 0015
Vergi Adı: GERÇEK USULDE KATMA DEĞER VERGİSİ
Tahakkuk Eden: 3.500,00
Mahsup Edilen: 3.500,00
Vadesi: 26/07/2026

TOPLAM                                                       0,00

Fiş No: 2026080101Y7m0000099
''';

const missingToplamTaxAccrualText = '''
T.C.
HAZİNE VE MALİYE BAKANLIĞI
GELİR İDARESİ BAŞKANLIĞI
TAHAKKUK FİŞİ

SOYADI (UNVANI): KAYA İNŞAAT LTD. ŞTİ.
ADI: -
Vergilendirme Dönemi: 04/2026-04/2026

Ana Vergi Kodu: 0003
Vergi Adı: GELİR VERGİSİ S. (MUHTASAR)
Vadesi: 26/05/2026

Fiş No: 2026060101Y7m0000012
''';

const multiRowTaxAccrualText = '''
T.C.
HAZİNE VE MALİYE BAKANLIĞI
GELİR İDARESİ BAŞKANLIĞI
TAHAKKUK FİŞİ

SOYADI (UNVANI): OZTURK GIDA A.Ş.
ADI: -
Vergilendirme Dönemi: 07/2026-07/2026

Ana Vergi Kodu: 9022
Vergi Adı: KATMA DEĞER VERGİSİ TEVKİFATI
Tahakkuk Eden: 850,25
Vadesi: 26/08/2026

Ana Vergi Kodu: 0091
Vergi Adı: DAMGA VERGİSİ
Tahakkuk Eden: 120,00
Vadesi: 20/08/2026

TOPLAM                                                          970,25

Fiş No: 2026090101Y7m0000034
''';

const geciciVergiTaxAccrualText = '''
T.C.
HAZİNE VE MALİYE BAKANLIĞI
GELİR İDARESİ BAŞKANLIĞI
TAHAKKUK FİŞİ

SOYADI (UNVANI): AK PLASTİK SAN. TİC. LTD. ŞTİ.
ADI: -
Vergilendirme Dönemi: 01/2026-03/2026

Ana Vergi Kodu: 0016
Vergi Adı: GELİR GEÇİCİ VERGİ
Tahakkuk Eden: 12.400,00
Vadesi: 17/05/2026

TOPLAM                                     12.400,00

Fiş No: 2026051701Y7m0000056
''';

const sgkPrimText = '''
T.C.
SOSYAL GÜVENLİK KURUMU BAŞKANLIĞI
İŞYERİ PRİM TAHAKKUK FİŞİ

Unvan: YILMAZ TİCARET LTD. ŞTİ.
AİT OLDUĞU YIL / AY: 2026/06
Sigortalı Sayısı: 12
Gün Sayısı: 360
PRİM TUTARI: 45.230,50
ÖDENECEK NET TUTAR: 45.230,50
''';

const sgkPrimYearRolloverText = '''
T.C.
SOSYAL GÜVENLİK KURUMU BAŞKANLIĞI
İŞYERİ PRİM TAHAKKUK FİŞİ

Unvan: DEMIR YAPI A.Ş.
AİT OLDUĞU YIL / AY: 2026/12
Sigortalı Sayısı: 5
Gün Sayısı: 150
PRİM TUTARI: 18.000,00
ÖDENECEK NET TUTAR: 18.000,00
''';

const sgkPrimLeapYearText = '''
T.C.
SOSYAL GÜVENLİK KURUMU BAŞKANLIĞI
İŞYERİ PRİM TAHAKKUK FİŞİ

Unvan: KAYA İNŞAAT LTD. ŞTİ.
AİT OLDUĞU YIL / AY: 2028/01
Sigortalı Sayısı: 8
Gün Sayısı: 240
PRİM TUTARI: 22.500,00
ÖDENECEK NET TUTAR: 22.500,00
''';

const sgkIseGirisText = '''
T.C.
SOSYAL GÜVENLİK KURUMU BAŞKANLIĞI
SİGORTALI İŞE GİRİŞ BİLDİRGESİ

Adı Soyadı: AHMET YILMAZ
İşe Başlama Tarihi: 01/07/2026
Meslek Kodu: 2411.05
''';

const sgkIstenCikisText = '''
T.C.
SOSYAL GÜVENLİK KURUMU BAŞKANLIĞI
SİGORTALI İŞTEN AYRILIŞ BİLDİRGESİ

Adı Soyadı: AHMET YILMAZ
İşten Ayrılış Tarihi: 15/07/2026
''';

const unrelatedText = '''
Bu belge herhangi bir vergi veya SGK belgesi değildir.
Sadece rastgele bir metin örneğidir.
''';
