/// Fixture texts modeling the layout of a real GİB tahakkuk fişi PDF as
/// extracted by pdfrx (see a sample in `009281_..._THK.pdf`): labels and
/// values are NOT colon-separated, and the reading order is jumbled by the
/// PDF's underlying text stream rather than the visual table layout — e.g.
/// "Vergilendirme Dönemi" is a column header with its value ("MM/YYYY-
/// MM/YYYY") printed several lines below/after it, and there is no "Fiş No"
/// label at all (the receipt number is the barcode's alphanumeric caption).
library;

const kdvTaxAccrualText = '''
TAHAKKUK FİŞİ
T.C
HAZİNE VE MALİYE BAKANLIĞI
İSTANBUL
VERGİ KİMLİK NUMARASI 1234567890 ( T.C. Kimlik No )
SOYADI (UNVANI) YILMAZ TİCARET LTD. ŞTİ.
ADI -
Kabul Tarihi Vergilendirme Dönemi Düzenleme
Tarihi
Ana Vergi Kodu 0015
GERÇEK USULDE KATMA DEĞER VERGİSİ
22/06/2026 05/2026-05/2026 22/06/2026
MAKİNA NO
KADIKÖY
SIRA NO
ADRES
BAĞDAT CAD.
Kapı No:1 Daire No:2 Tel:
 KADIKÖY İSTANBUL
2026072201Y7m0000088
VADESİ ÖDENECEK
OLAN
MAHSUP
EDİLEN
TAHAKKUK
EDEN
ORAN
TÜRÜ MATRAH
0015 KDV1 10.000,00 1.939,70 0,00 1.939,70 26/06/2026
TOPLAM 1.939,70
İşlem Türü 0010
Thk Türü 9000
YALNIZ BİN DOKUZYÜZOTUZDOKUZ TL YETMİŞ Kr .dir
009281 VERGİ DAİRESİ MÜDÜRLÜĞÜ
2200610719
İLİ DEFTERDARLIĞI
''';

const mahsupTaxAccrualText = '''
TAHAKKUK FİŞİ
T.C
HAZİNE VE MALİYE BAKANLIĞI
İSTANBUL
VERGİ KİMLİK NUMARASI 9876543210 ( T.C. Kimlik No )
SOYADI (UNVANI) DEMIR YAPI A.Ş.
ADI -
Kabul Tarihi Vergilendirme Dönemi Düzenleme
Tarihi
Ana Vergi Kodu 0015
GERÇEK USULDE KATMA DEĞER VERGİSİ
22/07/2026 06/2026-06/2026 22/07/2026
MAKİNA NO
KADIKÖY
SIRA NO
ADRES
BAĞDAT CAD.
Kapı No:1 Daire No:2 Tel:
 KADIKÖY İSTANBUL
2026080101Y7m0000099
VADESİ ÖDENECEK
OLAN
MAHSUP
EDİLEN
TAHAKKUK
EDEN
ORAN
TÜRÜ MATRAH
0015 KDV1 10.000,00 0,00 3.500,00 3.500,00 26/07/2026
TOPLAM 0,00
İşlem Türü 0010
Thk Türü 9000
YALNIZ SIFIR TL .dir
009281 VERGİ DAİRESİ MÜDÜRLÜĞÜ
2200610719
İLİ DEFTERDARLIĞI
''';

const missingToplamTaxAccrualText = '''
TAHAKKUK FİŞİ
T.C
HAZİNE VE MALİYE BAKANLIĞI
İSTANBUL
VERGİ KİMLİK NUMARASI 1122334455 ( T.C. Kimlik No )
SOYADI (UNVANI) KAYA İNŞAAT LTD. ŞTİ.
ADI -
Kabul Tarihi Vergilendirme Dönemi Düzenleme
Tarihi
Ana Vergi Kodu 0003
GELİR VERGİSİ S. (MUHTASAR)
22/05/2026 04/2026-04/2026 22/05/2026
MAKİNA NO
KADIKÖY
SIRA NO
ADRES
BAĞDAT CAD.
Kapı No:1 Daire No:2 Tel:
 KADIKÖY İSTANBUL
2026060101Y7m0000012
VADESİ ÖDENECEK
OLAN
MAHSUP
EDİLEN
TAHAKKUK
EDEN
ORAN
TÜRÜ MATRAH
0003 STPJ 5.000,00 500,00 0,00 500,00 26/05/2026
İşlem Türü 0010
Thk Türü 9000
009281 VERGİ DAİRESİ MÜDÜRLÜĞÜ
2200610719
İLİ DEFTERDARLIĞI
''';

const multiRowTaxAccrualText = '''
TAHAKKUK FİŞİ
T.C
HAZİNE VE MALİYE BAKANLIĞI
İSTANBUL
VERGİ KİMLİK NUMARASI 6677889900 ( T.C. Kimlik No )
SOYADI (UNVANI) OZTURK GIDA A.Ş.
ADI -
Kabul Tarihi Vergilendirme Dönemi Düzenleme
Tarihi
Ana Vergi Kodu 9022
KATMA DEĞER VERGİSİ TEVKİFATI
Ana Vergi Kodu 0091
DAMGA VERGİSİ
26/09/2026 07/2026-07/2026 26/09/2026
MAKİNA NO
KADIKÖY
SIRA NO
ADRES
BAĞDAT CAD.
Kapı No:1 Daire No:2 Tel:
 KADIKÖY İSTANBUL
2026090101Y7m0000034
VADESİ ÖDENECEK
OLAN
MAHSUP
EDİLEN
TAHAKKUK
EDEN
ORAN
TÜRÜ MATRAH
9022 STPJ 5.000,00 850,25 0,00 850,25 26/08/2026
0091 DMG 1.200,00 120,00 0,00 120,00 20/08/2026
TOPLAM 970,25
İşlem Türü 0010
Thk Türü 9000
YALNIZ DOKUZYÜZYETMİŞ TL YİRMİBEŞ Kr .dir
009281 VERGİ DAİRESİ MÜDÜRLÜĞÜ
2200610719
İLİ DEFTERDARLIĞI
''';

const geciciVergiTaxAccrualText = '''
TAHAKKUK FİŞİ
T.C
HAZİNE VE MALİYE BAKANLIĞI
İSTANBUL
VERGİ KİMLİK NUMARASI 5544332211 ( T.C. Kimlik No )
SOYADI (UNVANI) AK PLASTİK SAN. TİC. LTD. ŞTİ.
ADI -
Kabul Tarihi Vergilendirme Dönemi Düzenleme
Tarihi
Ana Vergi Kodu 0016
GELİR GEÇİCİ VERGİ
17/04/2026 01/2026-03/2026 17/04/2026
MAKİNA NO
KADIKÖY
SIRA NO
ADRES
BAĞDAT CAD.
Kapı No:1 Daire No:2 Tel:
 KADIKÖY İSTANBUL
2026051701Y7m0000056
VADESİ ÖDENECEK
OLAN
MAHSUP
EDİLEN
TAHAKKUK
EDEN
ORAN
TÜRÜ MATRAH
0016 GVGEC 50.000,00 12.400,00 0,00 12.400,00 17/05/2026
TOPLAM 12.400,00
İşlem Türü 0010
Thk Türü 9000
YALNIZ ONİKİBİNDÖRTYÜZ TL .dir
009281 VERGİ DAİRESİ MÜDÜRLÜĞÜ
2200610719
İLİ DEFTERDARLIĞI
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
