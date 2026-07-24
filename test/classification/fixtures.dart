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

// SGK PRİM TAHAKKUK FİŞİ: modeled on a real e-SGK sample. Labels and values
// are dumped in two disconnected groups — every label, then every value, in
// the same relative order the fields appear on the visual form (ADRES,
// Kullanıcı/Makine No, Sıra No/Fiş No, Sicil No, Unvanı, Belge Kabul
// Tarihi, AİT OLDUĞU YIL/AY) — rather than as adjacent "label: value" pairs.
const sgkPrimText = '''
T.C.
SOSYAL GÜVENLİK KURUMU BAŞKANLIĞI
SİGORTA PRİMLERİ GENEL MÜDÜRLÜĞÜ
TAHAKKUK FİŞİ
No AÇIKLAMA PRİME ESAS KAZANÇ
TUTARI
PRİM ORANI
%
PRİM TUTARI
:
:
:
:
:
(5510) ASIL Belge türü:
22.07.2026 14:40
AİT OLDUĞU YIL / AY
ADRES:
BELGE KABUL TARİHİ
Sicil No
Kullanıcı / Makine No
Sıra No / Fiş numarası
Unvanı
:
MERKEZ MAH. ATATÜRK CAD. No:1 İSTANBUL
WWWMUHT / EBV2-01
1000 / 22.07.2026-MBBG-1000
441000101100000000000-00/000
YILMAZ TİCARET LTD. ŞTİ.
22.07.2026
2026/06
SGM(kod-ad) : SGK MERKEZ SOSYAL GÜVENLİK MERKEZİ
1 KISA VADELİ SİGORTA KOLLARI PRİMİ 45.230,50 2,25 1.017,69
2 MALULLUK,YAŞLILIK VE ÖLÜM SİG. PRİMİ 45.230,50 21,00 9.498,41
3 GENEL SAĞLIK SİGORTASI PRİMİ 45.230,50 12,50 5.653,81
4 İŞSİZLİK SİGORTASI PRİMİ 45.230,50 3,00 1.356,92
GÜN SAYISI:
TOPLAM PRİM
NET PRİM TUTARI
ÖDENECEK NET TUTAR
İŞSİZLİK TUTARI
KİŞİ SAYISI: 12
360
50.000,00
0,00
49.500,00
1.500,00
45.230,50
''';

const sgkPrimYearRolloverText = '''
T.C.
SOSYAL GÜVENLİK KURUMU BAŞKANLIĞI
SİGORTA PRİMLERİ GENEL MÜDÜRLÜĞÜ
TAHAKKUK FİŞİ
AİT OLDUĞU YIL / AY
ADRES:
BELGE KABUL TARİHİ
Sicil No
Kullanıcı / Makine No
Sıra No / Fiş numarası
Unvanı
:
MERKEZ MAH. ATATÜRK CAD. No:1 İSTANBUL
WWWMUHT / EBV2-01
1000 / 22.07.2026-MBBG-1000
441000101100000000000-00/000
DEMIR YAPI A.Ş.
22.07.2026
2026/12
GÜN SAYISI:
ÖDENECEK NET TUTAR
150
18.000,00
''';

const sgkPrimLeapYearText = '''
T.C.
SOSYAL GÜVENLİK KURUMU BAŞKANLIĞI
SİGORTA PRİMLERİ GENEL MÜDÜRLÜĞÜ
TAHAKKUK FİŞİ
AİT OLDUĞU YIL / AY
ADRES:
BELGE KABUL TARİHİ
Sicil No
Kullanıcı / Makine No
Sıra No / Fiş numarası
Unvanı
:
MERKEZ MAH. ATATÜRK CAD. No:1 İSTANBUL
WWWMUHT / EBV2-01
1000 / 22.07.2026-MBBG-1000
441000101100000000000-00/000
KAYA İNŞAAT LTD. ŞTİ.
22.07.2026
2028/01
GÜN SAYISI:
ÖDENECEK NET TUTAR
240
22.500,00
''';

// SGK sigortalı bildirgeleri (işe giriş/işten ayrılış): modeled on real
// e-SGK samples. The identity section's field values (Adı, Soyadı, Baba
// Adı, Ana Adı, Doğum Yeri, Doğum Tarihi) are dumped as a contiguous block
// near the end, disconnected from their labels — see
// extractSgkBildirgePersonName's doc comment.
const sgkIseGirisText = '''
T.C.
SOSYAL GÜVENLİK KURUMU
SİGORTALI İŞE GİRİŞ BİLDİRGESİ
(4/1-a-b ve 506 SK GM 20 kapsamındaki sigortalılar için) 01.07.2026 09:00:00
SOSYAL GÜVENLİK SİCİL NUMARASI
(T.C.KİMLİK NUMARASI)
A-SİGORTALININ KİMLİK/ADRES BİLGİLERİ
16 Sigortalının işe başladığı tarih
Meslek Adı ve Kodu
01.07.2026
MERKEZ MAH. ATATÜRK CAD. No:1 İSTANBUL /
YILMAZ TİCARET LTD. ŞTİ.
2411.05 -İnşaat Mühendisi
0
1 2 3 4 5 6 7 8 9 0
AHMET
YILMAZ
BABAADI
ANAADI
İSTANBUL
1995-03-12
''';

const sgkIstenCikisText = '''
T.C.
SOSYAL GÜVENLİK KURUMU
SİGORTALI İŞTEN AYRILIŞ BİLDİRGESİ
(4/1-a-b ve 506 SK GM 20 kapsamındaki sigortalılar için)
SOSYAL GÜVENLİK SİCİL NUMARASI
(T.C.KİMLİK NUMARASI)
A-SİGORTALININ KİMLİK/ADRES BİLGİLERİ
C-SİGORTALININ HİZMET BİLGİLERİ
15 Sigortalının İşten Ayrılış Tarihi
1234567890123
15.07.2026 16
0.0 0.0 0
0.0 14
0
06
0
15
0
07
0
0
0
0
X
YILMAZ TİCARET LTD. ŞTİ. MERKEZ MAH. ATATÜRK CAD. No:1 İSTANBUL
0
B-SİGORTALININ SOSYAL GÜVENLİK BİLGİLERİ
01.10.2008 Tarihinden Önce Hizmeti
Varsa;
AHMET
YILMAZ
BABAADI
ANAADI
İSTANBUL
1995-03-12
E
''';

const unrelatedText = '''
Bu belge herhangi bir vergi veya SGK belgesi değildir.
Sadece rastgele bir metin örneğidir.
''';
