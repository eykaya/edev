# Gelistirme Spesifikasyonu

> Tek dokumanda kapsam, tasarim, fonksiyonel ve teknik detaylar, test plani ve deployment.
> Bu dokumana bakan herhangi bir gelistirici, ne zaman bakarsa baksin, yapilacak isi eksiksiz anlayabilmeli ve uygulayabilmelidir.

---

## SPEC_ZRPD_EDEV_001_HR: Personel Dokuman Yonetim Sistemi — Ikametgah Belgesi

### Dokuman Bilgileri

| Alan | Deger |
|---|---|
| Spec Numarasi | SPEC_ZRPD_EDEV_001_HR |
| Gelistirme Adi | Personel Dokuman Yonetim Sistemi — Ikametgah Belgesi |
| Gelistirme Tipi | Backend ABAP |
| SAP Modulu | HR |
| SAP Platformu | ECC 6.0 (ABAP 7.50) |
| RICEF Tipi | I-Interface + E-Enhancement |
| Karmasiklik | Large |
| Versiyon | 1.0 |
| Yazar | Emre Yalcinkaya |
| Tarih | 2026-04-06 |
| Durum | Onayli |
| Paket | ZRPD_EDEV |
| GitHub Repo | {repo URL} |

### Versiyon Tarihcesi

| Versiyon | Tarih | Yazar | Degisiklik |
|---|---|---|---|
| 1.0 | 2026-04-06 | Emre Yalcinkaya | Ilk taslak — tum fazlar tamamlandi, onaylandi |

### Tablo Isim Degisiklikleri (16-char DB limiti)

SAP ECC transparent tablolari 16 karakter DB limiti nedeniyle asagidaki kisaltmalar yapilmistir:

| Spec Adi (Orijinal) | SAP Adi (Gercek) | Aciklama |
|---|---|---|
| ZRPD_EDEV_T_DCTYP | ZRPD_EDEV_T_DTYP | Belge tipi tanimlari |
| ZRPD_EDEV_T_DCFLD | ZRPD_EDEV_T_DFLD | Alan tanimlari |
| ZRPD_EDEV_T_DCMAP | ZRPD_EDEV_T_DMAP | IT eslestirme |
| ZRPD_EDEV_T_PARAM | ZRPD_EDEV_T_PARM | Sistem parametreleri |
| ZRPD_EDEV_T_CNTRY | ZRPD_EDEV_T_CTRY | Ulke donusum |
| ZRPD_EDEV_T_DCVAL | ZRPD_EDEV_T_DVAL | Alan degerleri |
| ZRPD_EDEV_T_APILOG | ZRPD_EDEV_T_ALOG | API log |
| ZRPD_EDEV_T_PROCLOG | ZRPD_EDEV_T_PLOG | Islem log |
| ZRPD_EDEV_T_DOC | ZRPD_EDEV_T_DOC | Belgeler (degismedi) |

> **Not:** Spec dokumani orijinal isimleri kullaniyor. SAP sistemindeki gercek isimler kisaltilmis halidir.

---

## FAZ 1: KAPSAM VE AMAC

### 1.1 Gerekce

IK departmanlari calisanlarin ikametgah belgelerini manuel olarak SAP PA30 ekraninda IT0006 (Adres) infotype'ina giriyor. Bu surec asagidaki problemleri yaratmaktadir:

- **Dogrulama eksikligi:** Belge gercekligi elle kontrol ediliyor; sahtecilik tespiti yapilamiyor.
- **Yuksek iscilik maliyeti:** Her belge islemi 10-15 dakika suruyor; IK uzmaninin vaktini verimsiz kullaniyor.
- **Manuel hata riski:** Adres bilgileri yanlis girilebiliyor; ilce/il kodu eslesmesi hatali yapilabiliyor.
- **Denetim izi eksikligi:** Kim, ne zaman hangi belgeyi yukledi ve hangi veriyi girdi bilgisi tutulmuyor.
- **Arsivsizlik:** Belgeler fiziksel dosyalarda veya dagitik DMS sistemlerinde saklaniyor; merkezi erisim yok.

Bu gelistirme, ikametgah belgesi yuklemeden IT0006 kaydinin otomatik olusturulmasina kadar tum sureci dijitallestiriyor. Mimari, `ZCL_ZRPD_EDEV_DOC_BASE` soyut sinifi uzerine kurulu; diger belge tipleri (kimlik, diploma, mesleki sertifika) sonraki iterasyonlarda subclass olarak eklenecek.

### 1.2 Mevcut Surec (As-Is)

1. Calisan e-Devlet (turkiye.gov.tr) uzerinden "Yerlesim Yeri Belgesi" PDF indirir ve IK'ya iletir (e-posta veya elden).
2. IK uzmani belgeyi gozle inceler; sahtecilik veya gecerlilik kontrolu yapilamaz.
3. IK uzmani PA30 transaction'ini acar, PERNR girer, IT0006 infotype'ini secer.
4. Belgeden adresi elle okuyarak tum alanlari (cadde, ilce, il, posta kodu, ulke) SAP'a girer. Bu adim ortalama 10-15 dakika suruyor.
5. Belge fiziksel dosyaya veya yerel DMS'e kaldiriliyor; SAP ile iliskilendirilmiyor.
6. Herhangi bir hata veya guncelleme gerektiginde adim 3-5 tekrarlanabiliyor.

**Sorunlu noktalar:**
- Adim 2: Sahtecilik/gecerlilik tespiti yok.
- Adim 4: Veri giris hatasi riski yuksek, zaman kaybi buyuk.
- Adim 5: Merkezi arsiv yok, belgeye SAP'tan erisilemiyor.
- Hicbir adimda: Denetim izi, kim/ne zaman gibi log tutulmuyor.

### 1.3 Hedef Surec (To-Be)

1. IK uzmani `ZRPD_EDEV_UPLOAD` transaction'ini acar.
2. PERNR ve belge tipini (IKAMETGAH) girer; bilgisayarindan PDF dosyasini secer.
3. Sistem otomatik olarak asagidakileri gerceklestirir:
   - PDF'ten barkod ve TC kimlik numarasini cikarir (ABAP yerlesik parser, basa­risizsa OCR/LLM fallback).
   - e-Devlet API'si uzerinden belge gecerliligini dogrular (barkod + TCKN).
   - Belge iceriginden adres alanlarini cikarir (mahalle, cadde, ilce, il, posta kodu).
   - Cikartilan alanlari IT0006 subtype 1 formatina donusturur.
4. IK uzmani sonuc ekraninda cikartilan verileri gorur; yanlislik varsa duzeltir ve onaylar.
5. Onay uzerine sistem IT0006 kaydini `HR_INFOTYPE_OPERATION` BAPI ile SAP HR'a yazar; belge PDF'i `ZRPD_EDEV_T_DOC` tablosunda saklanir.
6. Tum adimlar `ZRPD_EDEV_T_APILOG` ve `ZRPD_EDEV_T_PROCLOG` tablolarinda loglanir.

### 1.4 Kapsam

| Kapsam Icinde | Kapsam Disinda |
|---|---|
| Ikametgah belgesi yukleme, saklama, indirme, listeleme | Kimlik / Diploma / Mesleki Sertifika belge tipleri (sonraki iterasyon) |
| e-Devlet API entegrasyonu ile belge dogrulama | Fiori / OData arayuzu |
| PDF-metin cikartma (ABAP yerlesik + OCR + LLM fallback) | ESS (Employee Self-Service) portali |
| Adres alanlarini regex ile ayristirma | Toplu (batch) belge isleme |
| IT0006 Subtype 1 kaydini otomatik olusturma | Belge onay is akisi (workflow) |
| Islem ve API loglama | Harici DMS entegrasyonu |
| SM30 bakim gorunumleri (T_DCTYP, T_DCFLD, T_DCMAP, T_PARAM) | Mobil uygulama |
| PERNR bazli belge listeleme (ZRPD_EDEV_LIST) | Dijital imza dogrulama |
| Dogrulama kurallari V-001 — V-037 | Birden fazla dil destegi (TR disinda) |

### 1.5 Paydaslar ve Roller

| Rol | Isim / Departman | Sorumluluk |
|---|---|---|
| Is Sahibi | IK Direktoru | Gereksinim tanimlar, UAT onaylar |
| Fonksiyonel Danismani | IK Cozum Ekibi | FS yazar, test koordinasyonu, dogrulama kurallari |
| Teknik Danismani | ABAP Gelistirici (Emre Yalcinkaya) | TS yazar, kodlama, birim testleri |
| Basis / Sistem | Basis Ekibi | Transport, SM59 tanimlama, STRUST sertifikasi, yetkilendirme rolleri |
| Son Kullanici | IK Uzmani | ZRPD_EDEV_UPLOAD ve ZRPD_EDEV_LIST kullanimi, UAT testi |
| Guvenlik | Bilgi Guvenlik Ekibi | e-Devlet API erisim onay, TCKN maskeleme denetim |

### 1.6 Kullanici Personalari

Uygulanmaz — Bu gelistirme Backend ABAP'tir; Fiori kullanici personasi gerekmez.

### 1.7 Basari Kriterleri

| # | Kriter | Olcum Yontemi |
|---|---|---|
| 1 | Belge yukleme suresi ≤ 2 dakika (10-15 dk'dan dusme) | UAT suresini kronometreyle ol; ortalama 5 islemde ≤ 2 dk |
| 2 | e-Devlet dogrulama basari orani ≥ %95 gecerli belgeler icin | Test ortaminda 20 gecerli belgeyle deneme; ≥ 19 onaylanmali |
| 3 | Adres cikartma dogrulugu ≥ %90 (5 alandan en az 4.5 ortalama) | 20 farkli belge uzerinde manuel karsilastirma |
| 4 | IT0006 kaydinin manuel girisle birebir eslesmesi | 20 kayit karsilastirilir; hicbir CRITICAL alan hatasi olmamal |
| 5 | Birim test coverage ≥ %90 (ZCL_ZRPD_EDEV_DOC_MGR, DOC_BASE, DOC_IKA, IT_MAP) | abapUnit + coverage raporu |
| 6 | Hata durumunda anlasilir hata mesaji gosterilmesi | Her hata kodunun TR mesaji mevcut; gelistirici kendi kendine tanimlayabiliyor |
| 7 | Buyuk PDF (10 MB) yuklemesi ≤ 30 saniye tamamlanir | 10 MB test dosyasiyla kronometreyle ol |

### 1.8 Acik Sorular

| # | Soru | Sorumlu | Durum |
|---|---|---|---|
| 1 | e-Devlet API test ortami mevcut mu? Sandbox endpoint URL'si nedir? | Basis Ekibi | Kapali — production URL kullaniliyor; test ortami yok; SM59'da ayri destination tanimlanacak |
| 2 | OCR API hangi servis saglayicisi kullanilacak? (Easy OCR, Google Cloud Vision, Azure) | Teknik Danismani | Kapali — SM59 destination parametrik; servis degisimi kod degisikliği gerektirmiyor |
| 3 | LLM API hangi model/saglayici? (OpenAI, Azure OpenAI, Anthropic) | Teknik Danismani | Kapali — SM59 destination parametrik; ZCL_ZRPD_EDEV_LLM_API birlesik JSON arayuzu kullaniyor |
| 4 | TCKN-PERNR uyusmazliginda hard error mi, warning mi? | IK Direktoru | Kapali — Warning (V-013); IK uzmaninin devam etme karari kendisinde |
| 5 | Mevcut IT0006 kaydi varsa: uzerine yaz mi yoksa end-date koy yeni kayit ac mi? | Fonksiyonel Danismani | Kapali — Mevcut kaydini end-date ile bitir (ENDDA=bugun-1), yeni kayit ac (MOD+INS pattern) |

---

## FAZ 2: KAVRAMSAL TASARIM

### 2.1 Cozum Mimarisi (Yuksek Seviye)

Cozum 8 katmanli bir paket yapisi uzerine kuruludur. Her katman tek bir sorumluluge sahip olup bagimliliklar tek yonludur (ust katman alt katmani cagirabilir, tersi yasak).

```
+--------------------------------------------------+
|              ZRPD_EDEV (Ana Paket)               |
|  ZRPD_EDEV_UI      Raporlar, Transaction Code    |
|  ZRPD_EDEV_LOGIC   Orchestrator, Parser, Mapper  |
|  ZRPD_EDEV_API     e-Devlet, OCR, LLM adaptorler |
|  ZRPD_EDEV_DATA    Repository (DB erisim)         |
|  ZRPD_EDEV_CORE    Arayuzler, Exception'lar       |
|  ZRPD_EDEV_CUST    Customizing (T_DCTYP vs)      |
|  ZRPD_EDEV_TEST    Mock'lar, abapUnit testleri    |
+--------------------------------------------------+

Akis:
  UI (Rapor)
    |
    v
  ZCL_ZRPD_EDEV_DOC_MGR  [Orchestrator, implements ZIF_ZRPD_EDEV_DOC_MGR]
    |         |          |         |
    v         v          v         v
  DOC_REPO  CUS_REP  EDEVLET   DOC_IKA (via FAC)
  (DB)      (Cust.)  (API)     (Parser/Validator)
    |                  |
    v                  v
  T_DOC vs.     turkiye.gov.tr
  (ECC DB)      OCR API / LLM API

  IT_MAP
    |
    v
  HR_INFOTYPE_OPERATION (IT0006)
```

Tum bagimliliklar constructor injection ile verilir; mock'larla birim testinde gercek DB/HTTP cagrilmaz.

### 2.2 Modul / Bilesen Etkilesimleri

| Kaynak | Hedef | Iletisim Tipi | Aciklama |
|---|---|---|---|
| ZRPD_EDEV_R_UPLOAD | ZCL_ZRPD_EDEV_DOC_MGR | OO Method Call | Yuklemeisteginidelegasyon |
| ZCL_ZRPD_EDEV_DOC_MGR | ZCL_ZRPD_EDEV_DOC_REP | OO Method Call | T_DOC / T_DCVAL CRUD |
| ZCL_ZRPD_EDEV_DOC_MGR | ZCL_ZRPD_EDEV_CUS_REP | OO Method Call | T_DCTYP, T_DCFLD, T_DCMAP, T_PARAM okuma |
| ZCL_ZRPD_EDEV_DOC_MGR | ZCL_ZRPD_EDEV_EDEVLET | HTTP REST | e-Devlet barkod dogrulama |
| ZCL_ZRPD_EDEV_DOC_MGR | ZCL_ZRPD_EDEV_OCR_SVC | HTTP REST | PDF-metin cikartma (fallback 1) |
| ZCL_ZRPD_EDEV_DOC_MGR | ZCL_ZRPD_EDEV_LLM_API | HTTP REST | PDF-metin cikartma (fallback 2) |
| ZCL_ZRPD_EDEV_DOC_MGR | ZCL_ZRPD_EDEV_DOC_FAC | OO Method Call | Belge tipine gore parser instance |
| ZCL_ZRPD_EDEV_DOC_MGR | ZCL_ZRPD_EDEV_IT_MAP | OO Method Call | IT0006 alan eslestirme |
| ZCL_ZRPD_EDEV_IT_MAP | HR_INFOTYPE_OPERATION | BAPI | IT0006 kayit yazma |
| ZCL_ZRPD_EDEV_IT_MAP | PA0000 | Open SQL | Aktif personel dogrulama |
| ZCL_ZRPD_EDEV_IT_MAP | PA0771 | Open SQL | TCKN dogrulama (MERNI alani) |
| ZCL_ZRPD_EDEV_IT_MAP | T005S | Open SQL | Il kodu eslestirme (STATE alani) |

### 2.3 Veri Akisi

```
GIRDI                      ISLEM                          CIKTI
------                     ------                         ------
PERNR + DOC_TYPE           1. Girdi dogrulama             Hata mesaji (basa­risizsa)
+ PDF (XSTRING)               (V-001 .. V-004)
                           |
                           v
                           2. PDF kaydet (T_DOC)          DOC_GUID (RAW16)
                           |
                           v
                           3. Metin cikart                Tam metin (STRING)
                              ABAP -> OCR -> LLM
                           |
                           v
                           4. Barkod + TCKN cikar         BARCODE, TCKN (STRING)
                           |
                           v
                           5. e-Devlet dogrula            VERIFIED flag (CHAR1)
                              (barkod + TCKN)
                           |
                           v
                           6. Adres alanlarini ayristir   T_DCVAL kayitlari
                              (9 alan, regex tabanli)
                           |
                           v
                           7. IT0006 eslestir             IT0006 alan degerleri
                              (T_DCMAP kurallari)
                           |
                           v
                           8. IT0006 kayit yaz            PERNR + donem IT0006
                              HR_INFOTYPE_OPERATION
                           |
                           v
                           9. Tum adimlar logla           T_APILOG, T_PROCLOG
```

### 2.4 Entegrasyon Noktalari

| # | Dis Sistem / Modul | Yon | Protokol | Senkron/Asenkron | Aciklama |
|---|---|---|---|---|---|
| 1 | e-Devlet turkiye.gov.tr | Giden | HTTPS GET | Senkron | Barkod + TCKN ile belge gecerlilik sorgusu |
| 2 | OCR API (SM59: ZRPD_EDEV_OCR) | Giden | HTTPS POST | Senkron | PDF binary -> metin; ABAP cikartma basarisiz oldugunda |
| 3 | LLM API (SM59: ZRPD_EDEV_LLM) | Giden | HTTPS POST | Senkron | PDF binary -> yapisal JSON; OCR de basarisiz oldugunda |
| 4 | HR Infotype 0006 (Adres) | Dahili | BAPI | Senkron | HR_INFOTYPE_OPERATION ile IT0006 yazma |
| 5 | PA0000, PA0771 | Dahili | Open SQL | Senkron | Aktif personel / TCKN kontrolu |
| 6 | T005S (Ulke/Bolge) | Dahili | Open SQL | Senkron | Il kodu (STATE) eslestirme |

### 2.5 Teknoloji Secimleri

| Karar | Secim | Alternatif | Gerekce |
|---|---|---|---|
| Gelistirme tipi | OO ABAP (Class-based) | Procedural / FM | Testedilebilirlik, mock destek, SOLID ilkeleri; Clean ABAP kuralina uyum |
| Veri erisimi | Open SQL | CDS / ADBC | ECC 6.0 kisiti; RAP yok; CDS read-only view olarak kullanilabilir fakat bu gelistirmede gerekli degil |
| Dis iletisim | HTTP REST (CL_HTTP_CLIENT) | SOAP / RFC | e-Devlet ve OCR/LLM API'leri REST JSON; ECC 6.0 icin CL_HTTP_CLIENT (CL_WEB_HTTP_CLIENT değil) |
| Cikti / UI | ABAP Report + Selection Screen | Fiori / ALV Grid | Kapsam disinda Fiori; rapor yaklasimiyla en hizli delivery; ALV gerektirecek listeleme icin ZRPD_EDEV_R_LIST |
| JSON isleme | /UI2/CL_JSON | SAP_JSON / SXML | ECC 6.0 SP15+ mevcut; Fiori Tools SP ile birlikte geliyor; test edilmis |
| Kilitleme | Enqueue (Lock Object) | Optimistic Lock | Ayni DOC_GUID'e ayni anda erisimi onler |
| PDF cikartma | ABAP-first (SCMS), sonra OCR, sonra LLM | Direkt OCR/LLM | Maliyet ve latency; saf ABAP en hizli, en ucuz |

### 2.6 Floorplan Secim Gerekcesi

Uygulanmaz — Bu gelistirme Backend ABAP'tir; Fiori/UI5 arayuzu kapsam disindadir.

### 2.7 Navigasyon Akisi

Uygulanmaz — Bu gelistirme Backend ABAP'tir; Fiori navigasyon akisi kapsam disindadir.

---

## FAZ 3: FONKSIYONEL SPESIFIKASYON

### 3.1 Detayli Is Gereksinimleri

**FR-001 — Belge Yukleme**
IK uzmani ZRPD_EDEV_UPLOAD transaction'ini acarak PERNR, belge tipi (IKAMETGAH) ve PDF dosyasini girer. Sistem asagidaki kontrollerden geciren tum adimlar tamamlaninca ekranda sonuc gosterir.

**FR-002 — Belge Saklama**
Yuklenen PDF, CONTENT (RAWSTRING) olarak `ZRPD_EDEV_T_DOC` tablosunda saklanir. Her yukleme icin benzersiz bir DOC_GUID (RAW16, SY-GUID ile uretilir) atanir. Dosya adi, MIME tipi, boyut, yukleme kullanici/tarih/saat kaydedilir.

**FR-003 — PDF Metin Cikartma**
Sistem once ABAP yerlesik yontemini (SCMS_XSTRING_TO_BINARY + SCMS_BINARY_TO_STRING) dener. Sonuc bos veya bozuk gelirse OCR API'ye gider. OCR de basarisiz olursa LLM API'ye gider. Kullanilan yontem T_DCVAL'daki her alan icin EXTRACT_METHOD alani ile kaydedilir. Uc yontem de basarisiz olursa 010 (W) mesaji gosterilir.

**FR-004 — Barkod ve TCKN Cikartma**
Metin elde edildikten sonra regex ile barkod (`[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}`) ve TCKN (`[1-9]\d{10}`) cikartilir. TCKN icin mod10/11 checksum algoritması dogrulanir. Barkod cikartilamamissa V-010 hata mesaji gosterilir.

**FR-005 — e-Devlet Dogrulama**
Cikartilan barkod ve TCKN, `turkiye.gov.tr` API'sine gonderilir. Dogrulama basarili olursa belge durumu VERIFIED olarak guncellenir. Basarisiz olursa REJECTED. API erisim hatasindan dolayi denemeler T_PARAM'daki `API_RETRY_COUNT` (varsayilan 3) ve `API_RETRY_BASE_WAIT` (varsayilan 2 saniye, ustelden) kadar tekrarlanir.

**FR-006 — Adres Alani Ayristirma**
Dogrulama sonrasi metin, regex kaliplari ile 9 alana ayristirilir: tckn, barcode, full_name, neighborhood, street_address, district, city, postal_code, country. Her alan icin guven skoru (CONFIDENCE DEC5_2) hesaplanir: tam regex eslesmesi=100, etiket tabanli=95, konumsal=80. Guven skoru T_PARAM `AI_CONFIDENCE_THRESHOLD` (varsayilan 80) altinda kalan alanlar kullaniciya sariyla isaretlenir.

**FR-007 — IT0006 Eslestirme ve Kayit**
Ayristirilan alanlar, T_DCMAP tablosundaki eslestirme kurallarina gore IT0006 alanlarina donusturulur. Donusum kurallari: DIRECT, DATE_CONVERT, UPPER, LOOKUP_IL (T005S'ten il kodu), LOOKUP_CNTRY (ulke adi -> LAND1). Mevcut aktif IT0006 kaydi varsa bitis tarihi bugun-1 yapilir; yeni kayit olusturulur.

**FR-008 — Belge Listeleme**
ZRPD_EDEV_LIST transaction'i, PERNR bazinda yuklenmis tum belgelerin listesini gosterir: belge tipi, yukleme tarihi, durum, yukleyen kullanici. Listeden belge secilebilir ve PDF indirilebilir.

**FR-009 — Loglama**
Tum dis API cagrilari ZRPD_EDEV_T_APILOG'a kaydedilir; TCKN ve barkod maskelenerek loglanir (ilk/son 2 karakter gorunur, arasi `*`). Tum islem adimlari ZRPD_EDEV_T_PROCLOG'a kaydedilir.

**FR-010 — Bakim Gorunumleri**
T_DCTYP, T_DCFLD, T_DCMAP ve T_PARAM tablolari icin SM30 uyumlu bakim gorunumleri saglanir. Bu gorunumler uzerinden Basis veya fonksiyonel ekip ek belge tipleri ve eslestirme kurallari tanimlayabilir.

### 3.2 Veri Alanlari

Asagidaki alanlar ikametgah belgesinden cikartilir:

| # | Alan Adi | Aciklama (TR) | Aciklama (EN) | Tip / Uzunluk | Ornek Deger | Zorunlu |
|---|---|---|---|---|---|---|
| 1 | tckn | TC Kimlik No | Turkish ID Number | CHAR 11 | 10000000146 | Evet |
| 2 | barcode | Barkod No | Barcode Number | CHAR 50 | ABCD-1234-EFGH-5678 | Evet |
| 3 | full_name | Ad Soyad | Full Name | CHAR 80 | AHMET YILMAZ | Evet |
| 4 | neighborhood | Mahalle | Neighborhood | CHAR 60 | ATATURK MAH. | Evet |
| 5 | street_address | Cadde/Sokak No | Street Address | CHAR 80 | CUMHURIYET CAD. NO:15/3 | Evet |
| 6 | district | Ilce | District | CHAR 40 | CANKAYA | Evet |
| 7 | city | Il | City/Province | CHAR 40 | ANKARA | Evet |
| 8 | postal_code | Posta Kodu | Postal Code | CHAR 5 | 06420 | Hayir |
| 9 | country | Ulke | Country | CHAR 3 | TR | Evet (varsayilan TR) |
| 10 | issue_date | Belge Tarihi | Issue Date | DATS 8 | 20260315 | Evet |

### 3.3 SAP Hedef Eslestirme (Mapping)

IT0006 Subtype 1 (Daimi Ikamet) alanlarına eslestirme:

| Kaynak Alan | Hedef Obje | Hedef Alan | Donusum Kurali | Varsayilan Deger |
|---|---|---|---|---|
| street_address | PA0006 / IT0006 | STRAS | DIRECT (max 60 karakter, kisaltilir) | — |
| city | PA0006 / IT0006 | ORT01 | UPPER | — |
| district | PA0006 / IT0006 | ORT02 | UPPER | — |
| postal_code | PA0006 / IT0006 | PSTLZ | DIRECT | — |
| country | PA0006 / IT0006 | LAND1 | LOOKUP_CNTRY (Turkiye/TURKIYE/Turkey -> TR) | TR |
| city | PA0006 / IT0006 | STATE | LOOKUP_IL (T005S LAND1='TR', BEZEI~=city -> BLAND) | — |
| full_address | PA0006 / IT0006 | LOPTS | DIRECT (max 40 karakter) | — |
| neighborhood | PA0006 / IT0006 | ORTS2 | UPPER | — |
| — | PA0006 / IT0006 | ANSSA | — | 1 (Subtype sabit) |
| — | PA0006 / IT0006 | MOLGA | — | 45 (Turkiye) |
| issue_date | PA0006 / IT0006 | BEGDA | DATE_CONVERT | — |
| — | PA0006 / IT0006 | ENDDA | — | 99991231 |

**Not:** `full_address` alani belge metnindeki tam adres satirindan, diger alanlar parcali cikartmadan elde edilir. STRAS 60 karakteri asarsa `SUBSTRING( street_address, 1, 60 )` ile kisaltilir; log uyarisi yazilir.

### 3.4 Dogrulama Kurallari

| # | Kural ID | Kosul | Aksiyon | Hata Mesaji |
|---|---|---|---|---|
| 1 | V-001 | MIME type = 'application/pdf' | Abort | 018 E: Dosya PDF olmalidir |
| 2 | V-002 | Dosya boyutu <= T_PARAM.MAX_FILE_SIZE MB | Abort | 018 E: Dosya boyutu siniri asildi: &1 MB (max &2 MB) |
| 3 | V-003 | PA0000 WHERE PERNR=iv_pernr AND MASSN NE 'UE' AND ENDDA >= sy-datum | Abort | 002 E: &1 personel bulunamadi veya aktif degil |
| 4 | V-004 | T_DCTYP.ACTIVE = 'X' icin verilen DOC_TYPE | Abort | 001 E: Belge tipi &1 aktif degil |
| 5 | V-010 | Regex eslesmesi: `[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}` | Abort | 013 E: Gecersiz barkod numarasi |
| 6 | V-011 | TCKN 11 rakam, ilk rakam sifir olmayan | Abort | 013 E: Gecersiz TC kimlik numarasi formati |
| 7 | V-012 | TCKN mod10/11 checksum gecerli (asagida algoritma) | Abort | 013 E: TC kimlik numarasi checksum hatasi |
| 8 | V-013 | TCKN = PA0771-MERNI (PERNR icin) | Warning, devam | 015 W: Belgedeki TC (&1) personel kaydıyla (&2) uyusmuyor |
| 9 | V-021 | e-Devlet API dogrulama = basarili | Abort | 007 W: Dogrulama basarisiz: &1 |
| 10 | V-022 | ( sy-datum - issue_date ) <= T_PARAM.DOC_VALIDITY_DAYS | Abort | 016 E: Belge suresi dolmus: &1 gun once duzenlenmis (max &2 gun) |
| 11 | V-031 | city Turkiye 81 il listesinde (T_CNTRY ile veya sabit tablo) | Abort | Sehir degerlendirilemiyor: bilinmeyen il |
| 12 | V-037 | Tum alanlar SAP alan uzunluk limitlerini gecmiyor | Warning + kesme | Uzun alan STRAS 60 kara ile kesildi |
| 13 | V-017 | Ayni PERNR + DOC_TYPE ayni gun daha once yuklenmemis | Warning, devam | 017 W: Ayni gun ayni belge tipi zaten yuklenmis |

### 3.5 Yetkilendirme Gereksinimleri

| Yetki Objesi | Alan | Deger | Aciklama |
|---|---|---|---|
| P_ORGIN (HR: HR Nesneleri) | INFTY | 0006 | IT0006 yazma yetkisi |
| P_ORGIN | AUTHC | W (Write) | Yazma |
| P_ORGIN | PERSA | Kullanicinin yetkili oldugu personel alani | Alan bazli kisitlama |
| S_GUI | ACTVT | 60 (Upload) | Dosya yuklemek icin GUI_UPLOAD yetkisi |
| ZRPD_EDEV_DOC | ACTVT | 01 (Create), 03 (Read), 06 (Delete) | Ozel yetki objesi; BAdI yoksa authority-check koduyla uygulaniyor |
| ZRPD_EDEV_DOC | DOC_TYPE | IKAMETGAH | Belge tipi bazli kisitlama |

**Uygulama:** ZCL_ZRPD_EDEV_DOC_MGR->upload metodunda AUTHORITY-CHECK OBJECT 'ZRPD_EDEV_DOC' ID 'ACTVT' FIELD '01' cagrilir. SY-SUBRC <> 0 ise ZCX_ZRPD_EDEV_VALID firlatilir.

### 3.6 Dis Servis Detaylari

#### 3.6.1 e-Devlet Belge Dogrulama API

| Alan | Deger |
|---|---|
| Servis Adi | e-Devlet Belge Dogrulama |
| Endpoint | https://m.turkiye.gov.tr/api.php |
| SM59 Destination | ZRPD_EDEV_EDEVLET |
| Protokol | HTTPS GET |
| Kimlik Dogrulama | Yok (public endpoint) |
| TLS Versiyonu | 1.2+ (STRUST'ta kok sertifika yuklu olmali) |
| Timeout | T_PARAM.API_TIMEOUT saniye (varsayilan 30) |
| Retry | 3x, 2/4/8 saniye bekleme (ustelden) |

**Girdi Parametreleri:**
| # | Parametre | Tip | Zorunlu | Aciklama |
|---|---|---|---|---|
| 1 | p | STRING | Evet | Sabit deger: `belge-dogrulama` |
| 2 | qr | STRING | Evet | Format: `barkod:{BARCODE};tckn:{TCKN};` |

Ornek URL: `https://m.turkiye.gov.tr/api.php?p=belge-dogrulama&qr=barkod:ABCD-1234-EFGH-5678;tckn:10000000146;`

**Yanit Alanlari:**
| # | Alan | Tip | Aciklama | Ornek Deger |
|---|---|---|---|---|
| 1 | HTTP Status | NUMC3 | 200=basarili, 4xx/5xx=hata | 200 |
| 2 | Body (HTML/JSON) | STRING | Basarili: "gecerli" iceriyor; Gecersiz: "gecersiz" iceriyor | `...belge gecerlidir...` |
| 3 | RV_VERIFIED | CHAR1 | X=dogru, ' '=yanlis (parse edilen) | X |

**Yanit Yorumlama:** Yanit govdesi `TURKCE_GECERLI_PATTERN` (`gecerli` veya `verified`) iceriyorsa RV_VERIFIED='X'. Kelimenin olmadigi veya `gecersiz` icerdigi durumlarda RV_VERIFIED=' '. API cagrisi HTTP 5xx veya network hatasi verirse ZCX_ZRPD_EDEV_API firlatilir, retry mekanizmasi devreye girer.

#### 3.6.2 OCR API

| Alan | Deger |
|---|---|
| Servis Adi | OCR Text Extraction Service |
| Endpoint | SM59 ZRPD_EDEV_OCR ile tanimlanir |
| Protokol | HTTPS POST (multipart/form-data veya JSON base64) |
| Kimlik Dogrulama | T_PARAM icinde API key veya SM59 logon data |
| Timeout | T_PARAM.API_TIMEOUT saniye |

**Girdi:** Multipart POST; PDF binary (XSTRING -> Base64 encode).

**Beklenen Yanit:**
```json
{
  "text": "YERLESIM YERI BELGESI\nADI SOYADI: AHMET YILMAZ\n...",
  "confidence": 97.5
}
```

#### 3.6.3 LLM API

| Alan | Deger |
|---|---|
| Servis Adi | LLM Text Extraction Service |
| Endpoint | SM59 ZRPD_EDEV_LLM ile tanimlanir |
| Protokol | HTTPS POST (application/json) |
| Kimlik Dogrulama | T_PARAM icinde Bearer token veya SM59 logon data |
| Timeout | T_PARAM.API_TIMEOUT saniye |

**Girdi Govdesi (ornek OpenAI uyumlu):**
```json
{
  "model": "gpt-4o",
  "messages": [
    { "role": "system", "content": "PDF metnini yapi­siz JSON formatina cevir." },
    { "role": "user",   "content": "Base64_PDF_STRING" }
  ]
}
```

**Beklenen Yanit:**
```json
{
  "choices": [
    { "message": { "content": "{ \"tckn\": \"10000000146\", \"city\": \"ANKARA\", ... }" } }
  ]
}
```

### 3.7 UI Tasarimi

Uygulanmaz — Bu gelistirme Backend ABAP raporlari (klasik selection screen + liste) kullaniyor; Fiori/SAPUI5 kapsam disinda.

**Not (Report arayuzu ozetl):**

`ZRPD_EDEV_UPLOAD` (ZRPD_EDEV_R_UPLOAD): Selection screen alanlari: PERNR (zorunlu, F4), DOC_TYPE (zorunlu, F4 -> T_DCTYP), FILE_PATH (yerel dosya yolu). F8 ile calistirinca GUI_UPLOAD ile PDF yuklenir, islem baslatilir, sonuc mesaji ekranda gosterilir.

`ZRPD_EDEV_LIST` (ZRPD_EDEV_R_LIST): Selection screen: PERNR (zorunlu). F8 ile ZRPD_EDEV_T_DOC listesi ALV Grid olarak gosterilir. Satirdan belge secilip "Indir" butonu ile PDF indirilebilir.

### 3.8 Entity Gereksinimleri

Uygulanmaz — Bu gelistirme CDS/OData entity kullanmiyor; Fiori kapsam disinda.

---

## FAZ 4: TEKNIK SPESIFIKASYON

### 4.1 Proje Bilgileri

| Alan | Deger |
|---|---|
| Proje Kodu | ZRPD_EDEV |
| SAP Release | ECC 6.0 (Basis Release 7.50) |
| ABAP Syntax | 7.50 (VALUE #, CORRESPONDING #, COND #, FOR...IN, METHOD chaining mevcut) |
| Gelistirme Zorlugu | Complex |
| Rapor Modu | Real-time (interactive) |
| Benzer SAP Programlari | RPUAUD00 (HR Audit), RPU_FILL_DM_ADDRESS (IT0006 toplu guncelleme) |
| Transport Request | MCP araciligiyla olusturulur (transport_create) |

### 4.2 Naming Convention

Tum nesneler `docs/standartlar/naming-convention.md` standardini izler:

```
DDIC Nesneleri  : ZRPD_EDEV_[Tip Kodu]_[Tanitici]
  Tablo         : ZRPD_EDEV_T_DOC
  Yapi          : ZRPD_EDEV_S_DOCHD
  Tablo Tipi    : ZRPD_EDEV_TT_DOCHD
  Domain        : ZRPD_EDEV_D_DCTYP
  Data Element  : ZRPD_EDEV_DE_DCTYP

OO Nesneleri    : Z[Tip]_ZRPD_EDEV_[Tanitici]
  Interface     : ZIF_ZRPD_EDEV_DOC_MGR
  Class         : ZCL_ZRPD_EDEV_DOC_MGR
  Exception     : ZCX_ZRPD_EDEV_BASE

Diger           :
  Report        : ZRPD_EDEV_R_UPLOAD
  Transaction   : ZRPD_EDEV_UPLOAD
  Lock Obj      : EZRPD_EDEV_T_DOC
  Message Class : ZRPD_EDEV_M

Sabitler        : ZCL_ZRPD_EDEV_CONST sinifinda CLASS-DATA ... CONSTANT ...
```

### 4.3 Teknik Nesneler

#### Yaratilan Paketler

| Paket Adi | Ust Paket | Aciklama |
|---|---|---|
| ZRPD_EDEV | — | Ana paket |
| ZRPD_EDEV_CORE | ZRPD_EDEV | Arayuzler, exception'lar, sabitler |
| ZRPD_EDEV_CUST | ZRPD_EDEV | Customizing tablolari ve bakim gorunumleri |
| ZRPD_EDEV_DATA | ZRPD_EDEV | Uygulama tablolari, repository siniflari |
| ZRPD_EDEV_LOGIC | ZRPD_EDEV | Orchestrator, parser, mapper siniflar |
| ZRPD_EDEV_API | ZRPD_EDEV | Dis servis adaptorleri (e-Devlet, OCR, LLM) |
| ZRPD_EDEV_UI | ZRPD_EDEV | Raporlar, transaction kodlari |
| ZRPD_EDEV_TEST | ZRPD_EDEV | Mock siniflari, abapUnit test siniflari |

#### Yaratilan Domain'ler

| Domain Adi | Paket | ABAP Tipi | Uzunluk | Fixed Values |
|---|---|---|---|---|
| ZRPD_EDEV_D_DCTYP | CUST | CHAR | 10 | IKAMETGAH, KIMLIK, DIPLOMA, MESLEKI |
| ZRPD_EDEV_D_DSTAT | CUST | CHAR | 20 | DRAFT, UPLOADED, PROCESSING, VERIFIED, REJECTED, MAPPED, COMMITTED, ERROR, vd. |
| ZRPD_EDEV_D_EXMTH | CUST | CHAR | 10 | FORM, OCR_EASY, OCR_GCV, LLM, NONE |
| ZRPD_EDEV_D_FLDNM | CUST | CHAR | 40 | — |
| ZRPD_EDEV_D_BCNO | CUST | CHAR | 50 | — |
| ZRPD_EDEV_D_INFTY | CUST | NUMC | 4 | — |
| ZRPD_EDEV_D_IFLNM | CUST | CHAR | 30 | — |
| ZRPD_EDEV_D_CONVR | CUST | CHAR | 20 | DIRECT, DATE_CONVERT, UPPER, LOOKUP_IL, LOOKUP_CNTRY, CONCAT |

#### Yaratilan Data Element'ler

| Data Element Adi | Paket | Domain | Saha Etiket (TR) |
|---|---|---|---|
| ZRPD_EDEV_DE_DCTYP | CUST | ZRPD_EDEV_D_DCTYP | Belge Tipi |
| ZRPD_EDEV_DE_DSTAT | CUST | ZRPD_EDEV_D_DSTAT | Belge Durumu |
| ZRPD_EDEV_DE_EXMTH | CUST | ZRPD_EDEV_D_EXMTH | Cikartma Yontemi |
| ZRPD_EDEV_DE_FLDNM | CUST | ZRPD_EDEV_D_FLDNM | Alan Adi |
| ZRPD_EDEV_DE_BCNO | CUST | ZRPD_EDEV_D_BCNO | Barkod No |
| ZRPD_EDEV_DE_INFTY | CUST | ZRPD_EDEV_D_INFTY | Infotype No |
| ZRPD_EDEV_DE_IFLNM | CUST | ZRPD_EDEV_D_IFLNM | Infotype Alan Adi |
| ZRPD_EDEV_DE_CONVR | CUST | ZRPD_EDEV_D_CONVR | Donusum Kurali |
| ZRPD_EDEV_DE_FLDVL | DATA | — (CHAR 255) | Alan Degeri |
| ZRPD_EDEV_DE_GUID | CORE | — (RAW 16) | Unique ID (GUID) |

#### Yaratilan Tablolar

| Tablo Adi | Paket | Tip | Key Alanlari | Aciklama |
|---|---|---|---|---|
| ZRPD_EDEV_T_DCTYP | CUST | Customizing | MANDT + DOC_TYPE | Belge tipi tanim tablosu |
| ZRPD_EDEV_T_DCFLD | CUST | Customizing | MANDT + DOC_TYPE + FIELD_NAME | Belge tipi alan tanimlari |
| ZRPD_EDEV_T_DCMAP | CUST | Customizing | MANDT + DOC_TYPE + FIELD_NAME | IT alan eslestirme kurallari |
| ZRPD_EDEV_T_PARAM | CUST | Customizing | MANDT + PARAM_KEY | Sistem parametre tablosu |
| ZRPD_EDEV_T_CNTRY | CUST | Customizing | MANDT + COUNTRY_NAME | Ulke adi -> LAND1 donusum tablosu |
| ZRPD_EDEV_T_DOC | DATA | Application | MANDT + DOC_GUID | Belge baslik + icerik tablosu |
| ZRPD_EDEV_T_DCVAL | DATA | Application | MANDT + DOC_GUID + FIELD_NAME | Cikartilan alan degerleri |
| ZRPD_EDEV_T_APILOG | DATA | Log | MANDT + LOG_GUID | Dis API cagrisi loglari |
| ZRPD_EDEV_T_PROCLOG | DATA | Log | MANDT + LOG_GUID | Islem adim loglari |

**ZRPD_EDEV_T_DCTYP — Tablo Alan Detaylari:**
| Alan | Data Element | Tip | Uzunluk | Aciklama |
|---|---|---|---|---|
| MANDT | MANDT | CLNT | 3 | Mandant (otomatik) |
| DOC_TYPE | ZRPD_EDEV_DE_DCTYP | CHAR | 10 | Belge tipi kodu (key) |
| DESCRIPTION | — | CHAR | 60 | TR aciklama |
| DESCRIPTION_EN | — | CHAR | 60 | EN aciklama |
| VERIFY_METHOD | — | CHAR | 10 | EDEVLET / NONE |
| ACTIVE | — | CHAR | 1 | X=aktif |

**ZRPD_EDEV_T_DCFLD — Tablo Alan Detaylari:**
| Alan | Data Element | Tip | Uzunluk | Aciklama |
|---|---|---|---|---|
| MANDT | MANDT | CLNT | 3 | |
| DOC_TYPE | ZRPD_EDEV_DE_DCTYP | CHAR | 10 | Key |
| FIELD_NAME | ZRPD_EDEV_DE_FLDNM | CHAR | 40 | Key |
| FIELD_DESCR | — | CHAR | 60 | TR alan aciklamasi |
| DATA_TYPE | — | CHAR | 10 | CHAR / DATS / NUMC |
| MAX_LENGTH | — | NUMC | 4 | Maksimum karakter |
| IS_REQUIRED | — | CHAR | 1 | X=zorunlu |
| SORT_ORDER | — | NUMC | 4 | Sira no |
| REGEX_PATTERN | — | CHAR | 120 | Dogrulama regex |

**ZRPD_EDEV_T_DCMAP — Tablo Alan Detaylari:**
| Alan | Data Element | Tip | Uzunluk | Aciklama |
|---|---|---|---|---|
| MANDT | MANDT | CLNT | 3 | |
| DOC_TYPE | ZRPD_EDEV_DE_DCTYP | CHAR | 10 | Key |
| FIELD_NAME | ZRPD_EDEV_DE_FLDNM | CHAR | 40 | Key |
| INFOTYPE | ZRPD_EDEV_DE_INFTY | NUMC | 4 | Hedef infotype (ornek 0006) |
| INFOTYPE_FIELD | ZRPD_EDEV_DE_IFLNM | CHAR | 30 | Hedef infotype alan adi (ornek STRAS) |
| CONVERSION_RULE | ZRPD_EDEV_DE_CONVR | CHAR | 20 | Donusum kural kodu |
| DEFAULT_VALUE | — | CHAR | 60 | Bos cikartma icin varsayilan |

**ZRPD_EDEV_T_PARAM — Tablo Alan Detaylari:**
| Alan | Data Element | Tip | Uzunluk | Aciklama |
|---|---|---|---|---|
| MANDT | MANDT | CLNT | 3 | |
| PARAM_KEY | — | CHAR | 30 | Key |
| PARAM_VALUE | — | CHAR | 60 | Deger |
| DESCRIPTION | — | CHAR | 120 | Aciklama |

**ZRPD_EDEV_T_CNTRY — Tablo Alan Detaylari:**
| Alan | Data Element | Tip | Uzunluk | Aciklama |
|---|---|---|---|---|
| MANDT | MANDT | CLNT | 3 | |
| COUNTRY_NAME | — | CHAR | 60 | Ulke adi (normalize edilmis, buyuk harf) |
| LAND1 | LAND1 | CHAR | 3 | SAP ulke kodu |

Ornek kayitlar: TURKIYE->TR, TURKEY->TR, TÜRKIYE->TR

**ZRPD_EDEV_T_DOC — Tablo Alan Detaylari:**
| Alan | Data Element | Tip | Uzunluk | Aciklama |
|---|---|---|---|---|
| MANDT | MANDT | CLNT | 3 | |
| DOC_GUID | ZRPD_EDEV_DE_GUID | RAW | 16 | Birincil anahtar |
| PERNR | PERSNO | NUMC | 8 | Personel numarasi |
| DOC_TYPE | ZRPD_EDEV_DE_DCTYP | CHAR | 10 | Belge tipi |
| FILE_NAME | — | CHAR | 128 | Orjinal dosya adi |
| MIME_TYPE | — | CHAR | 40 | application/pdf |
| FILE_SIZE | — | INT4 | — | Byte cinsinden boyut |
| CONTENT | — | RAWSTRING | — | PDF binary icerik (LOB) |
| DOC_STATUS | ZRPD_EDEV_DE_DSTAT | CHAR | 20 | Durum kodu |
| BARCODE | ZRPD_EDEV_DE_BCNO | CHAR | 50 | Cikartilan barkod |
| TCKN | — | CHAR | 11 | Cikartilan TCKN (maskelenmemis) |
| UPLOAD_DATE | — | DATS | 8 | Yukleme tarihi |
| UPLOAD_TIME | — | TIMS | 6 | Yukleme saati |
| UPLOAD_USER | — | SYUNAME | 12 | Yukleyen kullanici |
| CHANGED_DATE | — | DATS | 8 | Son degisiklik tarihi |
| CHANGED_TIME | — | TIMS | 6 | Son degisiklik saati |
| CHANGED_USER | — | SYUNAME | 12 | Son degistiren kullanici |

**ZRPD_EDEV_T_DCVAL — Tablo Alan Detaylari:**
| Alan | Data Element | Tip | Uzunluk | Aciklama |
|---|---|---|---|---|
| MANDT | MANDT | CLNT | 3 | |
| DOC_GUID | ZRPD_EDEV_DE_GUID | RAW | 16 | Key (T_DOC ile FK) |
| FIELD_NAME | ZRPD_EDEV_DE_FLDNM | CHAR | 40 | Key |
| FIELD_VALUE | ZRPD_EDEV_DE_FLDVL | CHAR | 255 | Cikartilan deger |
| CONFIDENCE | — | DEC | 5_2 | Guven skoru (0.00-100.00) |
| EXTRACT_METHOD | ZRPD_EDEV_DE_EXMTH | CHAR | 10 | Kullanilan yontem |

**ZRPD_EDEV_T_APILOG — Tablo Alan Detaylari:**
| Alan | Data Element | Tip | Uzunluk | Aciklama |
|---|---|---|---|---|
| MANDT | MANDT | CLNT | 3 | |
| LOG_GUID | ZRPD_EDEV_DE_GUID | RAW | 16 | Key |
| DOC_GUID | ZRPD_EDEV_DE_GUID | RAW | 16 | Ilgili belge |
| LOG_DATE | — | DATS | 8 | |
| LOG_TIME | — | TIMS | 6 | |
| LOG_USER | — | SYUNAME | 12 | |
| API_DEST | — | CHAR | 32 | SM59 destination adi |
| TCKN_MASKED | — | CHAR | 11 | İlk 2 + `*******` + son 2 |
| BARCODE_MASKED | — | CHAR | 50 | İlk 4 + `****...****` + son 4 |
| HTTP_CODE | — | NUMC | 3 | HTTP status kodu |
| DURATION_MS | — | INT4 | — | Millisaniye cinsinden sure |
| RESPONSE_SNIPPET | — | CHAR | 255 | Yanit ilk 255 karakter |
| SUCCESS | — | CHAR | 1 | X=basarili |

**ZRPD_EDEV_T_PROCLOG — Tablo Alan Detaylari:**
| Alan | Data Element | Tip | Uzunluk | Aciklama |
|---|---|---|---|---|
| MANDT | MANDT | CLNT | 3 | |
| LOG_GUID | ZRPD_EDEV_DE_GUID | RAW | 16 | Key |
| DOC_GUID | ZRPD_EDEV_DE_GUID | RAW | 16 | Ilgili belge |
| LOG_DATE | — | DATS | 8 | |
| LOG_TIME | — | TIMS | 6 | |
| LOG_USER | — | SYUNAME | 12 | |
| STEP | — | CHAR | 30 | Adim kodu (UPLOAD, EXTRACT, VERIFY vb.) |
| STATUS | — | CHAR | 2 | OK / ER / WA |
| METHOD_USED | ZRPD_EDEV_DE_EXMTH | CHAR | 10 | Kullanilan cikartma yontemi |
| MESSAGE | — | CHAR | 255 | Aciklama |

#### Structure / Table Type

| Adi | Paket | Tur | Aciklama |
|---|---|---|---|
| ZRPD_EDEV_S_DOCHD | DATA | Structure | T_DOC alanlari (CONTENT alani haric) — listeleme icin |
| ZRPD_EDEV_S_DCVAL | DATA | Structure | T_DCVAL alanlari — alan deger transferi icin |
| ZRPD_EDEV_S_UPLOD | CORE | Structure | Yukleme transferi: PERNR + DOC_TYPE + FILE_NAME + MIME_TYPE + CONTENT (XSTRING) |
| ZRPD_EDEV_TT_DOCHD | DATA | Table Type | ZRPD_EDEV_S_DOCHD tablosu |
| ZRPD_EDEV_TT_DCVAL | DATA | Table Type | ZRPD_EDEV_S_DCVAL tablosu |

#### Lock Object

| Lock Obje Adi | Paket | Kilitledigi Tablo | Aciklama |
|---|---|---|---|
| EZRPD_EDEV_T_DOC | DATA | ZRPD_EDEV_T_DOC | DOC_GUID ile satirsal kilit; ayni anda iki islem ayni belgeyi degistiremez |

#### Class / Interface

**Arayuzler (ZRPD_EDEV_CORE paketi):**

| Arayuz Adi | Metotlar | Aciklama |
|---|---|---|
| ZIF_ZRPD_EDEV_DOC_MGR | upload, download, download_all, list, verify_edevlet, extract_data, validate_doc_type, map_to_infotype | Ana orchestrator arayuzu |
| ZIF_ZRPD_EDEV_DOC_REPO | save, find_by_guid, find_by_pernr, update_status, save_values, get_values, delete | Belge repository arayuzu |
| ZIF_ZRPD_EDEV_CUST_REPO | get_doc_type, get_fields, get_mappings, get_param | Customizing repository arayuzu |
| ZIF_ZRPD_EDEV_EXT_SVC | extract_text | Dis metin cikartma servisi arayuzu (OCR / LLM) |
| ZIF_ZRPD_EDEV_EDEVLET | verify | e-Devlet dogrulama arayuzu |
| ZIF_ZRPD_EDEV_LOGGER | log_api_call, log_step | Loglama arayuzu |

**ZIF_ZRPD_EDEV_DOC_MGR Metot Imzalari:**
```
METHODS:
  upload
    IMPORTING is_uplod TYPE zrpd_edev_s_uplod
    RETURNING VALUE(rv_guid) TYPE zrpd_edev_de_guid
    RAISING zcx_zrpd_edev_upload zcx_zrpd_edev_valid.

  download
    IMPORTING iv_guid TYPE zrpd_edev_de_guid
    RETURNING VALUE(rs_file) TYPE zrpd_edev_s_uplod
    RAISING zcx_zrpd_edev_notfnd.

  download_all
    IMPORTING iv_pernr TYPE persno
    RETURNING VALUE(rt_files) TYPE zrpd_edev_tt_dochd
    RAISING zcx_zrpd_edev_notfnd.

  list
    IMPORTING iv_pernr TYPE persno
    RETURNING VALUE(rt_docs) TYPE zrpd_edev_tt_dochd.

  verify_edevlet
    IMPORTING iv_guid TYPE zrpd_edev_de_guid
    RAISING zcx_zrpd_edev_api zcx_zrpd_edev_valid.

  extract_data
    IMPORTING iv_guid TYPE zrpd_edev_de_guid
    RETURNING VALUE(rt_values) TYPE zrpd_edev_tt_dcval
    RAISING zcx_zrpd_edev_extract.

  validate_doc_type
    IMPORTING iv_guid TYPE zrpd_edev_de_guid
    RETURNING VALUE(rv_valid) TYPE abap_bool
    RAISING zcx_zrpd_edev_valid.

  map_to_infotype
    IMPORTING iv_guid TYPE zrpd_edev_de_guid
    RETURNING VALUE(rt_mappings) TYPE zrpd_edev_tt_dcval
    RAISING zcx_zrpd_edev_valid.
```

**Siniflar:**

| Sinif Adi | Paket | Tip | Inherits / Implements | Aciklama |
|---|---|---|---|---|
| ZCL_ZRPD_EDEV_CONST | CORE | CLASS (Abstract) | — | Tum sabit degerleri (ABAP 7.50: CLASS-DATA sabitler) |
| ZCL_ZRPD_EDEV_DOC_BASE | LOGIC | CLASS (Abstract) | — | PDF/TCKN/tarih yardimci metodlari; get_doc_type, parse_fields, validate_content soyut |
| ZCL_ZRPD_EDEV_DOC_IKA | LOGIC | CLASS | Extends DOC_BASE | Ikametgah'a ozel parser, 9 alan |
| ZCL_ZRPD_EDEV_DOC_MGR | LOGIC | CLASS | Implements ZIF_ZRPD_EDEV_DOC_MGR | Ana orchestrator; constructor injection |
| ZCL_ZRPD_EDEV_DOC_FAC | LOGIC | CLASS | — | Factory: DOC_TYPE -> DOC_BASE alt sinifi |
| ZCL_ZRPD_EDEV_IT_MAP | LOGIC | CLASS | — | T_DCMAP kurallari ile IT0006 eslestirme ve yazma |
| ZCL_ZRPD_EDEV_DOC_REP | DATA | CLASS | Implements ZIF_ZRPD_EDEV_DOC_REPO | T_DOC, T_DCVAL CRUD |
| ZCL_ZRPD_EDEV_CUS_REP | DATA | CLASS | Implements ZIF_ZRPD_EDEV_CUST_REPO | T_DCTYP, T_DCFLD, T_DCMAP, T_PARAM okuma |
| ZCL_ZRPD_EDEV_LOGGER | DATA | CLASS | Implements ZIF_ZRPD_EDEV_LOGGER | T_APILOG, T_PROCLOG yazma |
| ZCL_ZRPD_EDEV_EDEVLET | API | CLASS | Implements ZIF_ZRPD_EDEV_EDEVLET | e-Devlet HTTP GET; SM59: ZRPD_EDEV_EDEVLET |
| ZCL_ZRPD_EDEV_OCR_SVC | API | CLASS | Implements ZIF_ZRPD_EDEV_EXT_SVC | OCR HTTP POST; SM59: ZRPD_EDEV_OCR |
| ZCL_ZRPD_EDEV_LLM_API | API | CLASS | Implements ZIF_ZRPD_EDEV_EXT_SVC | LLM HTTP POST; SM59: ZRPD_EDEV_LLM |
| ZCL_ZRPD_EDEV_MK_DREP | TEST | CLASS | Implements ZIF_ZRPD_EDEV_DOC_REPO | Mock repository |
| ZCL_ZRPD_EDEV_MK_CREP | TEST | CLASS | Implements ZIF_ZRPD_EDEV_CUST_REPO | Mock customizing |
| ZCL_ZRPD_EDEV_MK_EDVL | TEST | CLASS | Implements ZIF_ZRPD_EDEV_EDEVLET | Mock e-Devlet |
| ZCL_ZRPD_EDEV_MK_EXTS | TEST | CLASS | Implements ZIF_ZRPD_EDEV_EXT_SVC | Mock OCR/LLM |

**ZCL_ZRPD_EDEV_DOC_MGR Constructor:**
```abap
METHODS constructor
  IMPORTING
    io_doc_repo  TYPE REF TO zif_zrpd_edev_doc_repo
    io_cust_repo TYPE REF TO zif_zrpd_edev_cust_repo
    io_edevlet   TYPE REF TO zif_zrpd_edev_edevlet
    io_ocr_svc   TYPE REF TO zif_zrpd_edev_ext_svc
    io_llm_api   TYPE REF TO zif_zrpd_edev_ext_svc
    io_logger    TYPE REF TO zif_zrpd_edev_logger
    io_it_map    TYPE REF TO zcl_zrpd_edev_it_map.
```

**ZCL_ZRPD_EDEV_DOC_BASE Soyut Metotlar:**
```abap
METHODS get_doc_type ABSTRACT RETURNING VALUE(rv_type) TYPE zrpd_edev_de_dctyp.
METHODS parse_fields ABSTRACT
  IMPORTING iv_text TYPE string
  RETURNING VALUE(rt_vals) TYPE zrpd_edev_tt_dcval
  RAISING zcx_zrpd_edev_extract.
METHODS validate_content ABSTRACT
  IMPORTING iv_text TYPE string
  RETURNING VALUE(rv_valid) TYPE abap_bool.
```

**ZCL_ZRPD_EDEV_DOC_BASE Somut Metotlar:**
```abap
METHODS pdf_to_text
  IMPORTING iv_content TYPE xstring
  RETURNING VALUE(rv_text) TYPE string.  " SCMS tabanli, bos donerse caller fallback basar

METHODS extract_tckn
  IMPORTING iv_text TYPE string
  RETURNING VALUE(rv_tckn) TYPE char11
  RAISING zcx_zrpd_edev_extract.  " Regex [1-9]\d{10}

METHODS extract_barcode
  IMPORTING iv_text TYPE string
  RETURNING VALUE(rv_bc) TYPE zrpd_edev_de_bcno
  RAISING zcx_zrpd_edev_extract.  " Regex [A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}

METHODS validate_tckn
  IMPORTING iv_tckn TYPE char11
  RETURNING VALUE(rv_valid) TYPE abap_bool.

METHODS parse_date
  IMPORTING iv_raw TYPE string
  RETURNING VALUE(rv_date) TYPE dats
  RAISING zcx_zrpd_edev_extract.  " DD.MM.YYYY veya DD/MM/YYYY -> YYYYMMDD
```

#### Exception Sinif Hiyerarsisi

| Exception Sinifi | Paket | Ust Sinif | Aciklama |
|---|---|---|---|
| ZCX_ZRPD_EDEV_BASE | CORE | CX_STATIC_CHECK | Tum exception'larin ust sinifi |
| ZCX_ZRPD_EDEV_UPLOAD | CORE | ZCX_ZRPD_EDEV_BASE | Yukleme hatalari |
| ZCX_ZRPD_EDEV_EXTRACT | CORE | ZCX_ZRPD_EDEV_BASE | Metin cikartma hatalari |
| ZCX_ZRPD_EDEV_API | CORE | ZCX_ZRPD_EDEV_BASE | Dis API hatalari (HTTP, timeout, parse) |
| ZCX_ZRPD_EDEV_VALID | CORE | ZCX_ZRPD_EDEV_BASE | Dogrulama hatalari |
| ZCX_ZRPD_EDEV_NOTFND | CORE | ZCX_ZRPD_EDEV_BASE | Kayit bulunamadi |

ECC 6.0 syntax: `RAISE EXCEPTION TYPE zcx_zrpd_edev_api EXPORTING textid = ... mv_param1 = ...`
RAISE EXCEPTION NEW kullanilmaz (7.50 ECC'de desteklenmez).

#### Function Group / Function Module / BAPI

| Fonksiyon Grubu | Fonksiyon / BAPI | Aciklama |
|---|---|---|
| — (SAP Standard) | HR_INFOTYPE_OPERATION | IT0006 kayit olusturma/guncelleme |
| — (SAP Standard) | SCMS_XSTRING_TO_BINARY | XSTRING -> ikili tablo donusumu |
| — (SAP Standard) | SCMS_BINARY_TO_STRING | Ikili tablo -> STRING donusumu |
| — (SAP Standard) | GUI_UPLOAD | Kullanici bilgisayarindan dosya yukleme (R_UPLOAD raporunda) |

**HR_INFOTYPE_OPERATION Parametreleri:**
```
INFTY = '0006'
SUBTYPE = '1'
OBJECTID = pernr (PERNR tipi)
LOCKINDICATOR = 'X'
VALIDITYBEGIN = issue_date (DATS)
VALIDITYEND = '99991231' (DATS)
OPERATION = 'INS' veya 'MOD'
TCLAS = 'A'
RECORDNUMBER = '000'
NOCOMMIT = ' '  " Her INSERT sonrasi commit; batch degiliz
INNNN (PI0006) = dolu IT0006 yapisi
```

#### BAdI / Enhancement / User-Exit

| Tip | Adi | Implementasyon Adi | Method/Form | Aciklama |
|---|---|---|---|---|
| BAdI | HRPAD00INFTY | ZRPD_EDEV_HRPAD_IMP | AFTER_CREATE | IT0006 olusturulduktan sonra opsiyonel sonraki adimlar (akis tetikleme vs.) — bu iterasyonda bos implementasyon |

**Not:** Mevcut bu iterasyonda BAdI implementasyonu bos birakilmaktadir. Sonraki iterasyonlarda workflow veya e-posta bildirimi eklenebilir.

#### Search Help

| Adi | Paket | Kaynak Tablo / FM | Aciklama |
|---|---|---|---|
| ZRPD_EDEV_SH_DCTYP | CUST | ZRPD_EDEV_T_DCTYP | Belge tipi F4 yardimi |
| ZRPD_EDEV_SH_PERNR | UI | PA0001 (PERNR+ENAME) | Personel numarasi F4 yardimi (SAP standard olmadiginda) |

#### Yetki Nesneleri

| Yetki Objesi | Alanlari | Aciklama |
|---|---|---|
| ZRPD_EDEV_DOC | ACTVT (01/03/06), DOC_TYPE (IKAMETGAH) | Belge yonetim yetki objesi |
| P_ORGIN | INFTY, AUTHC, PERSA | HR standard infotype erisim |
| S_GUI | ACTVT | Dosya yukleme (GUI_UPLOAD) |

### 4.4 Mesaj Class

| Mesaj Class | No | Tip | EN | TR |
|---|---|---|---|---|
| ZRPD_EDEV_M | 001 | E | Document type &1 is not active | Belge tipi &1 aktif degil |
| ZRPD_EDEV_M | 002 | E | Employee &1 not found or inactive | &1 personel bulunamadi veya aktif degil |
| ZRPD_EDEV_M | 003 | E | Document &1 not found | &1 belge bulunamadi |
| ZRPD_EDEV_M | 004 | S | Document uploaded successfully | Belge basariyla yuklendi |
| ZRPD_EDEV_M | 005 | E | Upload failed: &1 | Yukleme basarisiz: &1 |
| ZRPD_EDEV_M | 006 | S | e-Devlet verification successful | e-Devlet dogrulama basarili |
| ZRPD_EDEV_M | 007 | W | Verification failed: &1 | Dogrulama basarisiz: &1 |
| ZRPD_EDEV_M | 008 | E | API error: &1 &2 | API hatasi: &1 &2 |
| ZRPD_EDEV_M | 009 | S | Data extracted using &1 method | &1 yontemiyle veri cikartildi |
| ZRPD_EDEV_M | 010 | W | All extraction methods failed | Tum cikartma yontemleri basarisiz |
| ZRPD_EDEV_M | 011 | E | Wrong document type: expected &1, detected &2 | Yanlis belge tipi: beklenen &1, tespit edilen &2 |
| ZRPD_EDEV_M | 012 | S | &1 fields mapped to IT&2 infotype | &1 alan IT&2 infotype ile eslesti |
| ZRPD_EDEV_M | 013 | E | Invalid barcode number | Gecersiz barkod numarasi |
| ZRPD_EDEV_M | 014 | I | &1 failed, switching to &2 method | &1 basarisiz, &2 yontemine gecildi |
| ZRPD_EDEV_M | 015 | W | TC in document (&1) does not match employee record (&2) | Belgedeki TC (&1) personel kaydiyla (&2) uyusmuyor |
| ZRPD_EDEV_M | 016 | E | Document expired: issued &1 days ago (max &2 days) | Belge suresi dolmus: &1 gun once duzenlenmis (max &2 gun) |
| ZRPD_EDEV_M | 017 | W | Same document type already uploaded today | Ayni gun ayni belge tipi zaten yuklenmis |
| ZRPD_EDEV_M | 018 | E | File size exceeded: &1 MB (max &2 MB) | Dosya boyutu siniri asildi: &1 MB (max &2 MB) |
| ZRPD_EDEV_M | 019 | S | IT0006 record created successfully | IT0006 kaydi basariyla olusturuldu |
| ZRPD_EDEV_M | 020 | E | IT0006 record could not be created: &1 | IT0006 kaydi olusturulamadi: &1 |

### 4.5 Algoritma ve Is Mantigi

#### 4.5.1 Ana Akis — ZCL_ZRPD_EDEV_DOC_MGR->upload

```
METOD: upload( is_uplod: PERNR + DOC_TYPE + FILE_NAME + MIME_TYPE + CONTENT )
DONUYOR: rv_guid (RAW16)

1. GIRDI DOGRULAMA
   1.1 V-001: MIME type = 'application/pdf'
       Hayirsa -> RAISE EXCEPTION TYPE zcx_zrpd_edev_upload (mesaj 018)
   1.2 V-002: FILE_SIZE <= T_PARAM.MAX_FILE_SIZE * 1048576 (byte)
       Hayirsa -> RAISE EXCEPTION TYPE zcx_zrpd_edev_upload (mesaj 018)
   1.3 V-003: PA0000 aktif mi (PERNR + MASSN + ENDDA)
       Hayirsa -> RAISE EXCEPTION TYPE zcx_zrpd_edev_valid (mesaj 002)
   1.4 V-004: T_DCTYP.ACTIVE = 'X' (DOC_TYPE icin)
       Hayirsa -> RAISE EXCEPTION TYPE zcx_zrpd_edev_valid (mesaj 001)

2. KILIT AL
   CALL FUNCTION 'ENQUEUE_EZRPD_EDEV_T_DOC'
   Hata: RAISE EXCEPTION TYPE zcx_zrpd_edev_upload

3. BELGE KAYDET (T_DOC)
   rv_guid = sy-guid (yeni RAW16 GUID)
   DOC_STATUS = 'UPLOADED'
   io_doc_repo->save( ... )

4. METIN CIKAR (Chain of Responsibility)
   4.1 DENE: ZCL_ZRPD_EDEV_DOC_BASE->pdf_to_text( CONTENT )
       lv_text bos veya 50 karakterden kisa degilse: 6. ADIMA GEC
   4.2 MESAJ 014 I: ABAP basarisiz, OCR deneniyor
       DENE: io_ocr_svc->extract_text( CONTENT, DOC_TYPE )
       Bos degilse: 6. ADIMA GEC
   4.3 MESAJ 014 I: OCR basarisiz, LLM deneniyor
       DENE: io_llm_api->extract_text( CONTENT, DOC_TYPE )
       Bos degilse: 6. ADIMA GEC
   4.4 Hepsi basarisiz: MESAJ 010 W, DOC_STATUS='ERROR', kilit birak, RETURN

5. DOC_STATUS GUNCELLE: 'PROCESSING'
   io_doc_repo->update_status( rv_guid, 'PROCESSING' )

6. BARKOD + TCKN CIKAR
   lo_doc = ZCL_ZRPD_EDEV_DOC_FAC=>create_instance( DOC_TYPE )
   lv_barcode = lo_doc->extract_barcode( lv_text )
   lv_tckn = lo_doc->extract_tckn( lv_text )
   V-011 / V-012: validate_tckn dogrula
   Hata: RAISE EXCEPTION TYPE zcx_zrpd_edev_extract (mesaj 013)
   V-013: PA0771-MERNI != lv_tckn -> MESAJ 015 W (soft warning, devam)
   T_DOC guncelle: BARCODE, TCKN

7. E-DEVLET DOGRULAMA
   io_edevlet->verify( lv_tckn, lv_barcode ) -> rv_verified, rv_content
   V-021: rv_verified != 'X' -> RAISE EXCEPTION TYPE zcx_zrpd_edev_valid (mesaj 007)
   V-022: issue_date yasligi kontrol (rv_content'ten parse et)
   DOC_STATUS = 'VERIFIED'
   log_api_call ( ... )

8. ALAN AYRISTIR
   lt_values = lo_doc->parse_fields( lv_text )
   io_doc_repo->save_values( rv_guid, lt_values )
   DOC_STATUS = 'MAPPED'

9. IT0006 YAZAR
   io_it_map->map_fields( rv_guid, lt_values, DOC_TYPE ) -> lt_mapped
   BAPI: HR_INFOTYPE_OPERATION ile IT0006 yaz
   Basarili: DOC_STATUS = 'COMMITTED', MESAJ 019 S
   Hata: RAISE EXCEPTION TYPE zcx_zrpd_edev_upload (mesaj 020)

10. KILIT BIRAK
    CALL FUNCTION 'DEQUEUE_EZRPD_EDEV_T_DOC'

11. DONDURMECE: rv_guid
```

#### 4.5.2 TCKN Checksum Algoritması

```abap
" iv_tckn = '10000000146' (ornek gecerli)
DATA(lv_d1)  = CONV i( iv_tckn+0(1) ).
DATA(lv_d2)  = CONV i( iv_tckn+1(1) ).
...  " d1..d9 benzer sekilde
DATA(lv_d10) = CONV i( iv_tckn+9(1) ).
DATA(lv_d11) = CONV i( iv_tckn+10(1) ).

" d10 hesaplama
DATA(lv_calc_d10) =
  ( ( lv_d1 + lv_d3 + lv_d5 + lv_d7 + lv_d9 ) * 7
    - ( lv_d2 + lv_d4 + lv_d6 + lv_d8 ) ) MOD 10.
IF lv_calc_d10 < 0. lv_calc_d10 = lv_calc_d10 + 10. ENDIF.

" d11 hesaplama
DATA(lv_calc_d11) =
  ( lv_d1 + lv_d2 + lv_d3 + lv_d4 + lv_d5
  + lv_d6 + lv_d7 + lv_d8 + lv_d9 + lv_calc_d10 ) MOD 10.

rv_valid = COND #(
  WHEN lv_calc_d10 = lv_d10 AND lv_calc_d11 = lv_d11 THEN abap_true
  ELSE abap_false ).
```

Ornek: `10000000146` -> d1..d9=1,0,0,0,0,0,0,0,1 -> calc_d10=((1+0+0+0+1)*7-(0+0+0+0))/10 mod 10 = (35) mod 10 = 5... (gercek hesaplama; kod yukaridaki formulu izler)

Bilinen test TCKN: `10000000146` -> GECERLI, `10000000140` -> GECERSIZ (d10 yanlis)

#### 4.5.3 Adres Ayristirma Algoritması — ZCL_ZRPD_EDEV_DOC_IKA->parse_fields

```
GIRDI: lv_text (STRING, buyuk harf normalize edilmis, Turkce karakterler korunmus)
CIKTI: lt_vals (TT_DCVAL)

1. NORMALIZE
   TRANSLATE lv_text TO UPPER CASE.
   " Turkce buy. harf donusumu: i->I, s->S, c->C, g->G, u->U, o->O
   " (ECC'de TRANSLATE, Turkce char icin bakici metot gerekebilir)

2. MAHALLE (neighborhood)
   REGEX: (.+?)\s*(MAH\.|MAHALLESİ|MH\.)
   Eslesen ilk grup -> NEIGHBORHOOD
   Confidence: 95% (etiket tabanli)

3. CADDE/SOKAK (street_address)
   REGEX: ([\w\s]+)\s+(CAD\.|CD\.|SOK\.|SK\.|BLV\.)\s*NO\s*[:.]?\s*(\d+[\w/]*)
   Tum parcalari birlestir: "CUMHURIYET CAD. NO:15/3"
   Confidence: 95%

4. ILC (district) + IL (city)
   REGEX: ([\w\s]+)\/([\w\s]+)
   Sol taraf = district, sag taraf = city
   V-031: city 81 il listesinde mi? (ZCL_ZRPD_EDEV_CONST->get_81_iller)
   Confidence: 100% (kesin regex) / 80% (positional)

5. POSTA KODU (postal_code)
   REGEX: \b\d{5}\b
   Confidence: 100%

6. BELGE TARIHI (issue_date)
   REGEX: \b(\d{2})[./](\d{2})[./](\d{4})\b
   parse_date metoduna yonlendir -> YYYYMMDD
   Confidence: 100%

7. TC KIMLIK NO (tckn — dogrulama adiminda zaten cikartildi)
   Sonucta dahil et; EXTRACT_METHOD='FORM'

8. BARKOD (barcode — dogrulama adiminda cikartildi)
   Sonucta dahil et; EXTRACT_METHOD='FORM'

9. ULKE (country)
   VARSAYILAN: 'TR' (Turkiye)
   Confidence: 100%

10. Her alan icin ZRPD_EDEV_S_DCVAL yapisi olustur ve lt_vals'a ekle.
```

#### 4.5.4 IT0006 Alan Eslestirme — ZCL_ZRPD_EDEV_IT_MAP->map_fields

```
GIRDI: iv_doc_guid, it_values (TT_DCVAL), iv_doc_type
CIKTI: rt_mapped (TT_DCVAL, IT0006 alanlari dolu)

1. T_DCMAP'TAN KURALLARI OKU
   SELECT * FROM zrpd_edev_t_dcmap
     WHERE doc_type = iv_doc_type
     INTO TABLE lt_map.

2. HER ESLESTIRME ICIN:
   LOOP AT lt_map INTO DATA(ls_map).
     READ TABLE it_values ... lv_src_val.

     CASE ls_map-conversion_rule.
       WHEN 'DIRECT'.
         lv_tgt_val = lv_src_val.
         " Uzunluk kontrolu: ls_map-infotype_field uzunlugu (ABAP DDIC metaveri)
         IF strlen( lv_tgt_val ) > lv_max_len.
           lv_tgt_val = lv_tgt_val(lv_max_len).
           log_step( STEP='MAP_TRUNCATE', STATUS='WA', MESSAGE=... ).
         ENDIF.

       WHEN 'UPPER'.
         lv_tgt_val = lv_src_val.
         TRANSLATE lv_tgt_val TO UPPER CASE.

       WHEN 'LOOKUP_CNTRY'.
         SELECT SINGLE land1 FROM zrpd_edev_t_cntry
           WHERE country_name = lv_src_val_upper
           INTO lv_tgt_val.
         IF sy-subrc <> 0. lv_tgt_val = 'TR'. ENDIF.

       WHEN 'LOOKUP_IL'.
         SELECT SINGLE bland FROM t005s
           WHERE land1 = 'TR'
             AND ( bezei = lv_src_val OR bezei2 = lv_src_val )
           INTO lv_tgt_val.
         IF sy-subrc <> 0.
           log_step( STEP='MAP_IL_NOTFND', STATUS='WA', ... ).
         ENDIF.

       WHEN 'DATE_CONVERT'.
         " lv_src_val 'YYYYMMDD' formatinda oldugunu varsay (onceden cevrildi)
         lv_tgt_val = lv_src_val.

       WHEN 'CONCAT'.
         " Birden fazla kaynak: virgul ayiraci ile birlestir
         " (bu iterasyonda kullanilmiyor)

     ENDCASE.

     APPEND ls_mapped TO rt_mapped.
   ENDLOOP.

3. SABİT DEGERLER EKLE (T_DCMAP'ta DEFAULT_VALUE olan satirlar)
   ANSSA = '1', MOLGA = '45'
```

#### 4.5.5 IT0006 Yazma — HR_INFOTYPE_OPERATION

```abap
" Mevcut kaydi bul
SELECT SINGLE * FROM pa0006
  WHERE pernr = iv_pernr
    AND subty = '1'
    AND endda >= sy-datum
  INTO ls_pa0006_existing.

IF sy-subrc = 0.
  " Mevcut kaydi kapat
  ls_pa0006_existing-endda = sy-datum - 1.
  CALL FUNCTION 'HR_INFOTYPE_OPERATION'
    EXPORTING
      infty     = '0006'
      subtype   = '1'
      objectid  = iv_pernr
      operation = 'MOD'  " endda guncelleme
    TABLES
      innn = ls_pa0006_existing  " Guncellenmis kayit
    EXCEPTIONS
      OTHERS = 1.
  IF sy-subrc <> 0.
    RAISE EXCEPTION TYPE zcx_zrpd_edev_upload EXPORTING ... " mesaj 020
  ENDIF.
ENDIF.

" Yeni kayit olustur
CLEAR ls_pa0006_new.
MOVE-CORRESPONDING lt_mapped TO ls_pa0006_new.  " ya da field-by-field
ls_pa0006_new-pernr = iv_pernr.
ls_pa0006_new-subty = '1'.
ls_pa0006_new-begda = lv_issue_date.
ls_pa0006_new-endda = '99991231'.
ls_pa0006_new-anssa = '1'.
ls_pa0006_new-molga = '45'.

CALL FUNCTION 'HR_INFOTYPE_OPERATION'
  EXPORTING
    infty     = '0006'
    subtype   = '1'
    objectid  = iv_pernr
    operation = 'INS'
    nocommit  = ' '
  TABLES
    innn = ls_pa0006_new
  EXCEPTIONS
    OTHERS = 1.
IF sy-subrc <> 0.
  RAISE EXCEPTION TYPE zcx_zrpd_edev_upload EXPORTING ... " mesaj 020
ENDIF.
```

### 4.6 Hata Yonetimi Stratejisi

| Hata Durumu | Exception Class | Recovery | Kullanici Mesaji |
|---|---|---|---|
| PDF degilse | ZCX_ZRPD_EDEV_UPLOAD | Abort — kullanici PDF yuklemeli | 018 E |
| Dosya cok buyuk | ZCX_ZRPD_EDEV_UPLOAD | Abort — kullanici dosyayi kucultmeli | 018 E |
| PERNR bulunamadi | ZCX_ZRPD_EDEV_VALID | Abort — PERNR kontrol edilmeli | 002 E |
| Barkod cikartilamamasi | ZCX_ZRPD_EDEV_EXTRACT | Abort — belge kalitesi dusuktugunden OCR denensin | 013 E |
| TCKN checksum hatasi | ZCX_ZRPD_EDEV_EXTRACT | Abort — belge gecersiz | 013 E |
| TCKN-PERNR uyusmamasi | (exception yok, warning) | Devam — kullanici onay verir | 015 W |
| e-Devlet API timeout | ZCX_ZRPD_EDEV_API | Retry 3x (2/4/8 sn), sonra Abort | 008 E |
| e-Devlet dogrulama reddi | ZCX_ZRPD_EDEV_VALID | Abort — belge sahte veya suresi dolmus | 007 W |
| Belge suresi dolmus | ZCX_ZRPD_EDEV_VALID | Abort — yeni belge yuklenmeli | 016 E |
| OCR API hatasi | ZCX_ZRPD_EDEV_API | Fallback LLM'e gec | 014 I |
| LLM API hatasi | ZCX_ZRPD_EDEV_API | Abort — tum yontemler basarisiz | 010 W + 008 E |
| IT0006 yazma hatasi | ZCX_ZRPD_EDEV_UPLOAD | Abort — Basis/IK el ile kontrol etmeli | 020 E |
| Lock alinamadi | ZCX_ZRPD_EDEV_UPLOAD | Abort — az sonra tekrar deneyin | 005 E |

**Genel kural:** Exception yakalandiktan sonra DOC_STATUS='ERROR' yapilmali, kilit birakilmali ve kullaniciya mesaj gosterilmelidir. Hicbir exception sessizce yutulmaz.

**ECC 6.0 exception syntax:**
```abap
RAISE EXCEPTION TYPE zcx_zrpd_edev_api
  EXPORTING
    textid   = zcx_zrpd_edev_api=>api_error
    mv_param1 = 'ZRPD_EDEV_EDEVLET'
    mv_param2 = lv_http_code.
```

### 4.7 Performans Degerlendirmeleri

| Alan | Deger |
|---|---|
| Beklenen islem hacmi | 50-100 belge/gun (IK boyutu) |
| Paralel isleme gerekli mi | Hayir (her islem interactive, kullanici bekliyor) |
| Buffer stratejisi | Customizing tablolari (T_DCTYP, T_DCMAP, T_PARAM): Generic Buffer; uygulama tablolari: yok |
| T_DCTYP Buffer | ZRPD_EDEV_T_DCTYP: BUFFERED (Full) — kucuk, seyrek degisen |
| T_DCMAP Buffer | ZRPD_EDEV_T_DCMAP: BUFFERED (Full) — kucuk, seyrek degisen |
| T_PARAM Buffer | ZRPD_EDEV_T_PARAM: BUFFERED (Full) — kucuk, statik |
| Index ihtiyaci | T_DOC uzerinde PERNR + DOC_TYPE ikincil index (listeleme sorgulari icin) |
| RAWSTRING depolama | T_DOC.CONTENT; buyuk satirlar icin LOB (LOBS uzantisi); CONTENT alan bant genisligi icin dikkat |
| e-Devlet API gecikmesi | Tipik 1-3 sn; timeout 30 sn; retry 3x ile max 15 sn ek |
| OCR API gecikmesi | Tipik 5-15 sn; buyuk PDF'lerde 30 sn'ye cikabilir |
| Commit frekansi | Her islem basina 1 commit (interactive mod, batch yok) |

### 4.8 CDS Veri Modeli

Uygulanmaz — Bu gelistirme ECC 6.0 Backend ABAP'tir; CDS view kullanimiyor.

### 4.9 OData Servis

Uygulanmaz — Bu gelistirme Backend ABAP raporlarini kullaniyor; OData kapsam disinda.

### 4.10 RAP Behavior

Uygulanmaz — RAP sadece S/4HANA ve BTP Cloud'da kullanilir; bu gelistirme ECC 6.0'dadir.

### 4.11 UI Annotation Ozeti

Uygulanmaz — Bu gelistirme Fiori Elements kullanmiyor.

### 4.12 Fiori Launchpad

Uygulanmaz — Bu gelistirme Backend ABAP'tir; Fiori Launchpad kapsam disinda.

### 4.13 SEGW Projesi

Uygulanmaz — Bu gelistirme OData/Fiori kullanmiyor.

### 4.14 BSP / ICF

Uygulanmaz — Bu gelistirme BSP/ICF kullanmiyor.

### 4.15 Frontend

Uygulanmaz — Bu gelistirme Freestyle UI5 kullanmiyor; ABAP raporlari (Selection Screen + ALV) kullaniyor.

### 4.16 i18n Metinleri

Uygulanmaz — Bu gelistirme Backend ABAP'tir; i18n/properties dosyasi kullanilmiyor. Turkce metinler ZRPD_EDEV_M mesaj sinifindan gelir.

---

## FAZ 5: KODLAMA VE TEST

> TDD akisi: once test kodu yazilir (RED), sonra minimal implementasyon (GREEN), sonra refactor (IMPROVE).
> Test plani bu dokumanda tanimlanir; test kodu `ZRPD_EDEV_TEST` paketinde uygulanir.

### 5.1 Unit Test Senaryolari

| # | Test Sinifi | Test Metodu | Senaryo | Girdi | Beklenen Sonuc |
|---|---|---|---|---|---|
| 1 | ZCL_ZRPD_EDEV_DOC_BASE_TEST | test_validate_tckn_valid | Gecerli TCKN checksum | '10000000146' | rv_valid = abap_true |
| 2 | ZCL_ZRPD_EDEV_DOC_BASE_TEST | test_validate_tckn_invalid | Gecersiz TCKN checksum | '10000000140' | rv_valid = abap_false |
| 3 | ZCL_ZRPD_EDEV_DOC_BASE_TEST | test_validate_tckn_leading_zero | Sifir ile baslayan TCKN | '01234567890' | rv_valid = abap_false (V-011) |
| 4 | ZCL_ZRPD_EDEV_DOC_BASE_TEST | test_validate_tckn_too_short | 10 haneli TCKN | '1000000014' | rv_valid = abap_false |
| 5 | ZCL_ZRPD_EDEV_DOC_BASE_TEST | test_parse_date_dot | Noktali tarih formati | '15.03.1990' | '19900315' |
| 6 | ZCL_ZRPD_EDEV_DOC_BASE_TEST | test_parse_date_slash | Egik cizgili tarih | '15/03/1990' | '19900315' |
| 7 | ZCL_ZRPD_EDEV_DOC_BASE_TEST | test_parse_date_invalid | Gecersiz tarih | 'AB.CD.EFGH' | ZCX_ZRPD_EDEV_EXTRACT |
| 8 | ZCL_ZRPD_EDEV_DOC_IKA_TEST | test_parse_fields_full | Tam ikametgah metni | 'ATATURK MAH. CUMHURIYET CAD. NO:15/3 CANKAYA/ANKARA 06420' | 5 alan dogru: neighborhood, street_address, district, city, postal_code |
| 9 | ZCL_ZRPD_EDEV_DOC_IKA_TEST | test_parse_fields_no_postal | Posta kodu olmadan | 'ATATURK MAH. CUMHURIYET CAD. NO:15 CANKAYA/ANKARA' | 4 alan dogru, postal_code bos |
| 10 | ZCL_ZRPD_EDEV_DOC_IKA_TEST | test_parse_fields_missing_district | Ilce/il ayracisiz | 'ATATURK MAH. CUMHURIYET CAD. NO:15' | ZCX_ZRPD_EDEV_EXTRACT veya bos district/city |
| 11 | ZCL_ZRPD_EDEV_DOC_IKA_TEST | test_validate_content_ikametgah | Ikametgah metni | 'YERLESIM YERI BELGESI...NUFUS MUDURLUGU' | rv_valid = abap_true |
| 12 | ZCL_ZRPD_EDEV_DOC_IKA_TEST | test_validate_content_wrong_type | Yanlis belge tipi | 'NUFUS KAYIT ORNEGI' | rv_valid = abap_false |
| 13 | ZCL_ZRPD_EDEV_IT_MAP_TEST | test_map_city_ankara | Ankara -> STATE kodu | city='ANKARA', T005S mock | STATE='06' |
| 14 | ZCL_ZRPD_EDEV_IT_MAP_TEST | test_map_country_turkiye | Ulke donusumu | country_name='TURKIYE' | LAND1='TR' |
| 15 | ZCL_ZRPD_EDEV_IT_MAP_TEST | test_map_field_truncation | 60+ karakter cadde | street_address=70 karakter | STRAS=60 karakter (kesik), log WA |
| 16 | ZCL_ZRPD_EDEV_IT_MAP_TEST | test_map_direct | Direkt kopyalama | postal_code='06420' | PSTLZ='06420' |
| 17 | ZCL_ZRPD_EDEV_DOC_MGR_TEST | test_upload_happy_path | Tam basarili yukleme | Gecerli PERNR + IKAMETGAH + PDF | rv_guid dolu, DOC_STATUS='COMMITTED' |
| 18 | ZCL_ZRPD_EDEV_DOC_MGR_TEST | test_upload_invalid_mime | PDF olmayan dosya | MIME='image/jpeg' | ZCX_ZRPD_EDEV_UPLOAD |
| 19 | ZCL_ZRPD_EDEV_DOC_MGR_TEST | test_upload_pernr_inactive | Pasif personel | PA0000 mock: PERNR bos | ZCX_ZRPD_EDEV_VALID (002) |
| 20 | ZCL_ZRPD_EDEV_DOC_MGR_TEST | test_upload_edevlet_rejected | e-Devlet reddi | Mock: rv_verified=' ' | ZCX_ZRPD_EDEV_VALID (007) |
| 21 | ZCL_ZRPD_EDEV_DOC_MGR_TEST | test_upload_fallback_to_ocr | ABAP cikartma bos | Mock: ABAP bos, OCR dolu | Mesaj 014 I loglandi, OCR cikartmasi kullanildi |
| 22 | ZCL_ZRPD_EDEV_DOC_MGR_TEST | test_upload_fallback_to_llm | OCR de bos | Mock: ABAP+OCR bos, LLM dolu | Mesaj 014 I x2 loglandi, LLM cikartmasi kullanildi |
| 23 | ZCL_ZRPD_EDEV_DOC_MGR_TEST | test_upload_all_extract_fail | Hepsi basarisiz | Mock: hepsi bos | Mesaj 010 W, DOC_STATUS='ERROR', RETURN |
| 24 | ZCL_ZRPD_EDEV_DOC_MGR_TEST | test_upload_tckn_mismatch | TCKN uyusmamasi | PA0771 mock farkli TCKN | Mesaj 015 W, devam ediyor (abort yok) |
| 25 | ZCL_ZRPD_EDEV_DOC_MGR_TEST | test_upload_doc_expired | 31 gunluk belge | T_PARAM.DOC_VALIDITY_DAYS=30 | ZCX_ZRPD_EDEV_VALID (016) |
| 26 | ZCL_ZRPD_EDEV_DOC_MGR_TEST | test_auth_check_fail | Yetki yoksa | Authority-check mock: SY-SUBRC=4 | ZCX_ZRPD_EDEV_VALID |

### 5.2 CDS Test

Uygulanmaz — Bu gelistirme CDS view kullanmiyor.

### 5.3 Frontend Testler

Uygulanmaz — Bu gelistirme Freestyle UI5 kullanmiyor.

### 5.4 Entegrasyon Test Senaryolari

| # | Senaryo | Onkosul | Adimlar | Beklenen Sonuc | Gercek Sonuc | Basarili |
|---|---|---|---|---|---|---|
| E-001 | Happy path (uctan uca) | PERNR=10000001 aktif; T_DCTYP IKAMETGAH aktif; e-Devlet SM59 calisir; TEST belge PDF mevcut | 1. ZRPD_EDEV_UPLOAD ac, PERNR+tip+PDF gir, F8 | DOC_STATUS=COMMITTED; IT0006 kaydi PA0006'da gorunur; LOG kayitlari yazildi | — | — |
| E-002 | e-Devlet API hatasi | SM59 ZRPD_EDEV_EDEVLET yanlis host | Yukleme baslat | Retry 3x sonra 008 E hatasi; DOC_STATUS=ERROR | — | — |
| E-003 | Gecersiz barkod | Barkod alani olmayan PDF | Yukleme baslat | 013 E mesaji; islem durduruluyor | — | — |
| E-004 | Buyuk dosya (11 MB) | T_PARAM.MAX_FILE_SIZE=10 | 11 MB PDF yukle | 018 E mesaji; yukleme reddedildi | — | — |
| E-005 | Yetkilendirme reddi | Kullanicinin ZRPD_EDEV_DOC yetkisi yok | ZRPD_EDEV_UPLOAD calistir | Yetki hatasi; islem baslamadan red | — | — |
| E-006 | Buyuk veri seti | 50 belge ayni gun | 50 ardindan yukleme | Her biri basarili; performans < 30 sn/islem; kilit catismasi yok | — | — |
| E-007 | Esmanlilik | Ayni PERNR, iki farkli terminal | Ayni anda iki yukleme | Birincisi basarili; ikincisi kilit hatasi (005 E) | — | — |
| E-008 | ABAP cikartma sonrasi OCR fallback | FlateDecode sikistirilmis PDF | Yukleme baslat | 014 I loglaniyor; OCR devreye giriyor; sonuc dogru | — | — |
| E-009 | IT0006 mevcut kaydi kapatma | PERNR'nin aktif IT0006 Subtype 1 kaydi var | Yeni ikametgah yukle | Eski kayit ENDDA=bugun-1; yeni kayit BEGDA=belge tarihi | — | — |
| E-010 | ZRPD_EDEV_LIST listeleme | 3 onceki yukleme var PERNR icin | ZRPD_EDEV_LIST calistir | 3 satir ALV'de; her satirdan PDF indirilebiliyor | — | — |

### 5.5 Test Verileri

| # | Veri Seti | Aciklama | Olusturma Yontemi |
|---|---|---|---|
| 1 | TEST_VALID_IKAMETGAH.PDF | Gercek formata uygun, gecerli barkod + TCKN, dogru tarih (max 30 gun eski) | El ile hazirlanan ornek belge veya e-Devlet ornegi |
| 2 | TEST_INVALID_BARCODE.PDF | Barkod alani olmayan PDF | Metin editoru ile hazirlandi |
| 3 | TEST_EXPIRED.PDF | 60 gun onceki tarihli belge | El ile tarihi duzenle |
| 4 | TEST_LARGE_10MB.PDF | Tam 10 MB ikametgah belgesi | Padding ile buyutulmus PDF |
| 5 | TEST_LARGE_11MB.PDF | 11 MB — sinir asimi testi | Padding ile buyutulmus PDF |
| 6 | TEST_FLATDECODE.PDF | FlateDecode sikistirilmis; ABAP metin cikartamiyor | Gercel tarayici PDF'i |
| 7 | MOCK_PERNR_10000001 | Aktif personel, PA0771-MERNI eslestirilmis TCKN | Test sisteminde mevcut veya manuel INSERT |
| 8 | MOCK_PERNR_10000002 | Pasif personel (MASSN='UE') | Test sisteminde mevcut |
| 9 | T_PARAM initial data | Bolum 4.3'teki T_PARAM satirlari | SM30 bakimi veya ABAP INSERT scripti |
| 10 | T_DCTYP initial data | IKAMETGAH aktif kayit | SM30 bakimi |

### 5.6 Mock Gereksinimleri

| Arayuz | Mock Sinifi | Paket | Davranis |
|---|---|---|---|
| ZIF_ZRPD_EDEV_DOC_REPO | ZCL_ZRPD_EDEV_MK_DREP | TEST | Bellek ici iternal tablo; gercek DB yerine |
| ZIF_ZRPD_EDEV_CUST_REPO | ZCL_ZRPD_EDEV_MK_CREP | TEST | Sabit test verileri dondurur (T_DCTYP, T_PARAM) |
| ZIF_ZRPD_EDEV_EDEVLET | ZCL_ZRPD_EDEV_MK_EDVL | TEST | mv_should_verify flag ile VERIFIED/REJECTED aktar |
| ZIF_ZRPD_EDEV_EXT_SVC | ZCL_ZRPD_EDEV_MK_EXTS | TEST | mv_response STRING; bos string = basarisiz, dolu = basarili |
| ZIF_ZRPD_EDEV_LOGGER | (ZCL_ZRPD_EDEV_LOGGER gercek) | DATA | Test sirasinda gercek logger kullanilabilir; LOG tablosu kontrol edilebilir |

**Mock sinif ornek (ZCL_ZRPD_EDEV_MK_EDVL):**
```abap
CLASS zcl_zrpd_edev_mk_edvl DEFINITION
  PUBLIC FINAL
  CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES zif_zrpd_edev_edevlet.
    DATA mv_should_verify TYPE abap_bool VALUE abap_true.
    DATA mv_raise_api_error TYPE abap_bool VALUE abap_false.
ENDCLASS.

CLASS zcl_zrpd_edev_mk_edvl IMPLEMENTATION.
  METHOD zif_zrpd_edev_edevlet~verify.
    IF mv_raise_api_error = abap_true.
      RAISE EXCEPTION TYPE zcx_zrpd_edev_api EXPORTING textid = ...
    ENDIF.
    rv_verified = mv_should_verify.
    rv_content  = COND #( WHEN mv_should_verify = abap_true
                          THEN 'Belge gecerlidir' ELSE 'Belge gecersizdir' ).
  ENDMETHOD.
ENDCLASS.
```

### 5.7 Coverage Hedefleri

| Bilesen | Hedef | Aciklama |
|---|---|---|
| ZCL_ZRPD_EDEV_DOC_BASE | %95+ | Tum yardimci metotlar; parse_date, validate_tckn, extract_barcode |
| ZCL_ZRPD_EDEV_DOC_IKA | %95+ | parse_fields 9 alan; validate_content |
| ZCL_ZRPD_EDEV_DOC_MGR | %90+ | Orchestrator; happy path + tum error branch'leri |
| ZCL_ZRPD_EDEV_IT_MAP | %90+ | Tum CONVERSION_RULE case'leri + truncation |
| ZCL_ZRPD_EDEV_DOC_REP | %85+ | CRUD metotlari; mock DB ile |
| ZCL_ZRPD_EDEV_CUS_REP | %85+ | Okuma metotlari |
| ZCL_ZRPD_EDEV_EDEVLET | %70+ | HTTP cagri; mock HTTP response ile |
| ZRPD_EDEV_R_UPLOAD | %70+ | Selection screen + calistirma akisi |

---

## FAZ 6: REVIEW VE DOGRULAMA

### 6.1 Kod Review Ozeti

| Tarih | Reviewer | CRITICAL | HIGH | MEDIUM | LOW | Tumu Kapatildi mi |
|---|---|---|---|---|---|---|
| — | — | — | — | — | — | Kodlama asamasinda doldurulacak |

### 6.2 Performans Review Ozeti

| # | Seviye | Sorun | Etki | Oneri | Durum |
|---|---|---|---|---|---|
| 1 | — | — | — | — | Kodlama asamasinda doldurulacak |

### 6.3 Guvenlik Review Ozeti

- [ ] Hardcoded credential yok (SM59 logon data kullaniliyor)
- [ ] SQL injection riski yok (parameterized Open SQL)
- [ ] Authority check mevcut (DB modifikasyonu oncesinde AUTHORITY-CHECK)
- [ ] BAPI/FM sonrasi SY-SUBRC kontrolu yapiliyor (HR_INFOTYPE_OPERATION sonrasi)
- [ ] Hassas veri loglanmiyor (TCKN ve barkod log tablolarinda maskeleniyor)

### 6.4 abaplint Sonuclari

```
{abaplint ciktisi kodlama asamasinda buraya yapistirin}
```

Hata sayisi: 0 (hedef)

---

## FAZ 7: DEPLOYMENT

### 7.1 Transport Stratejisi

| Alan | Deger |
|---|---|
| Deploy Yontemi | MCP (Dassian-ADT) veya abapGit |
| Transport Tipi | Workbench (siniflar, raporlar, DDIC) + Customizing (T_DCTYP, T_DCMAP, T_PARAM, T_CNTRY initial data) |
| Transport Route | DEV -> QAS -> PRD |
| Transport Request No | MCP: transport_create komutu ile olusturulacak |
| Bagimli Transport'lar | Customizing transport'u Workbench transport'undan ONCE release edilmeli |

**MCP Deployment Akisi:**
```
abap_set_source -> abap_syntax_check -> abap_activate -> abap_atc_run
    -> transport_create -> transport_assign -> transport_release
```

**Onemli:** STRUST sertifikasi (e-Devlet kok sertifikasi) ve SM59 destination tanimlari (ZRPD_EDEV_EDEVLET, ZRPD_EDEV_OCR, ZRPD_EDEV_LLM) her ortam icin (QAS, PRD) Basis tarafindan ayrica yapilandirilmalidir. Bu nesneler transport edilmez.

### 7.2 Aktivasyon Sirasi

Asagidaki sira kesinlikle izlenmelidir (bagimliliklar nedeniyle):

1. **Domain'ler:** ZRPD_EDEV_D_DCTYP, D_DSTAT, D_EXMTH, D_FLDNM, D_BCNO, D_INFTY, D_IFLNM, D_CONVR (8 adet, bagimsiliz)
2. **Data Element'ler:** ZRPD_EDEV_DE_DCTYP, DE_DSTAT, DE_EXMTH, DE_FLDNM, DE_BCNO, DE_INFTY, DE_IFLNM, DE_CONVR, DE_FLDVL, DE_GUID (10 adet, domain'lere bagimli)
3. **Customizing Tablolari:** ZRPD_EDEV_T_DCTYP, T_DCFLD, T_DCMAP, T_PARAM, T_CNTRY (data element'lere bagimli)
4. **Uygulama Tablolari:** ZRPD_EDEV_T_DOC, T_DCVAL, T_APILOG, T_PROCLOG
5. **Lock Objesi:** EZRPD_EDEV_T_DOC (T_DOC'a bagimli)
6. **Yapilar:** ZRPD_EDEV_S_DOCHD, S_DCVAL, S_UPLOD (tablolara bagimli)
7. **Tablo Tipleri:** ZRPD_EDEV_TT_DOCHD, TT_DCVAL (yapilara bagimli)
8. **Arayuzler (bagimsiliz):** ZIF_ZRPD_EDEV_DOC_MGR, DOC_REPO, CUST_REPO, EXT_SVC, EDEVLET, LOGGER (6 adet)
9. **Exception Siniflari:** ZCX_ZRPD_EDEV_BASE (once), sonra 5 alt sinif
10. **ZCL_ZRPD_EDEV_CONST** (sabitler; bagimsiliz)
11. **ZCL_ZRPD_EDEV_LOGGER** (ZIF_LOGGER'a bagimli)
12. **Repository Siniflari:** ZCL_ZRPD_EDEV_DOC_REP, CUS_REP (arayuz + tablo bagimliligi)
13. **API Adaptor Siniflari:** ZCL_ZRPD_EDEV_EDEVLET, OCR_SVC, LLM_API
14. **Logic Siniflari:** ZCL_ZRPD_EDEV_DOC_BASE (abstract) -> DOC_IKA, DOC_FAC, IT_MAP, DOC_MGR
15. **Mock Siniflari (TEST paketi):** ZCL_ZRPD_EDEV_MK_DREP, MK_CREP, MK_EDVL, MK_EXTS
16. **Test Siniflari (TEST paketi):** ZCL_ZRPD_EDEV_DOC_BASE_TEST, DOC_IKA_TEST, IT_MAP_TEST, DOC_MGR_TEST
17. **Raporlar:** ZRPD_EDEV_R_UPLOAD, ZRPD_EDEV_R_LIST, ZRPD_EDEV_R_VERIFY
18. **Transaction Kodlari:** ZRPD_EDEV_UPLOAD, ZRPD_EDEV_LIST
19. **Mesaj Sinifi:** ZRPD_EDEV_M (20 mesaj, 001-020)

### 7.3 Uyarlama (Customizing) Gereksinimleri

| Islem | Tablo / View | Aciklama |
|---|---|---|
| Belge tipi tanimla | ZRPD_EDEV_T_DCTYP | Initial data: IKAMETGAH kaydini ekle (Bolum 4.3'teki tablo) |
| Alan tanimlari | ZRPD_EDEV_T_DCFLD | 9 alan icin kayit; regex pattern'leri dahil |
| IT eslestirme kurallari | ZRPD_EDEV_T_DCMAP | 8 kayit: IKAMETGAH alanlari -> IT0006 alanlari (Bolum 4.3'teki tablo) |
| Sistem parametreleri | ZRPD_EDEV_T_PARAM | 10 kayit: MAX_FILE_SIZE=10, API_TIMEOUT=30, vb. (Bolum 4.3'teki tablo) |
| Ulke donusum tablosu | ZRPD_EDEV_T_CNTRY | Min. 3 kayit: TURKIYE->TR, TURKEY->TR, TÜRKIYE->TR |
| SM59 Destination | ZRPD_EDEV_EDEVLET | Tip G, host: m.turkiye.gov.tr, port: 443, HTTPS, TLS 1.2+ |
| SM59 Destination | ZRPD_EDEV_OCR | Tip G, OCR servis saglayicisinin URL'sine gore |
| SM59 Destination | ZRPD_EDEV_LLM | Tip G, LLM API URL'sine gore |
| STRUST Sertifika | — | e-Devlet kok sertifikasini SSL Client (Standard) trust listesine ekle |
| Yetki Rol | ZRPD_EDEV_DOC_ROLE | ZRPD_EDEV_DOC + P_ORGIN INFTY=0006 + S_GUI iceren rol olustur, IK uzmanina ata |

### 7.4 Frontend Deployment

Uygulanmaz — Bu gelistirme Backend ABAP'tir; Fiori frontend deployment kapsam disinda.

### 7.5 Fiori Launchpad Deployment

Uygulanmaz — Bu gelistirme Backend ABAP'tir; Fiori Launchpad kapsam disinda.

### 7.6 Go-Live Kontrol Listesi

**Kod Kalitesi:**
- [ ] Tum unit testler basarili (26 test senaryosu)
- [ ] Tum entegrasyon testleri basarili (10 senaryo)
- [ ] abaplint hatasiz (`npm run lint`)
- [ ] Kod review tamamlandi (CRITICAL/HIGH bulgu yok)
- [ ] Guvenlik review tamamlandi (TCKN maskeleme, authority-check dogrulandi)
- [ ] Performans testi yapildi (50 islem < 30 sn/islem)

**Sistem:**
- [ ] ZRPD_EDEV_DOC_ROLE yetki rolu olusturuldu ve IK uzmanina atandi
- [ ] SM59 destination'lari (EDEVLET, OCR, LLM) her ortamda tanimli ve test edildi
- [ ] STRUST kok sertifikasi yuklendi
- [ ] Customizing tablolari QAS ve PRD'e transport edildi
- [ ] Initial data dogrulandi (T_DCTYP, T_DCMAP, T_PARAM)
- [ ] Transport request released

**Fiori:**
Uygulanmaz

**Final:**
- [ ] Son kullanici testi (UAT) onaylandi — IK uzmani 5 gercek belge ile test etti
- [ ] Dokumantasyon guncellendi (bu spec, review bulgulari eklendi)
- [ ] GitHub repo'ya push yapildi

### 7.7 Geri Alma Plani (Rollback)

**Transport Geri Alma:**
1. Basis, transport request'i geri almak icin QAS/PRD'de `STMS -> Import Queue -> Backward Transport` kullanir.
2. Workbench nesneleri (siniflar, raporlar, DDIC) onceki versiyona geri doner.
3. Customizing data'si transport geri alinsa da T_DOC'taki uygulama verileri etkilenmez; manuel temizlik gerekebilir.

**Veri Temizleme (gerekiyorsa):**
```abap
" Sadece DEV/QAS — PRD'de asla calistirma
DELETE FROM zrpd_edev_t_doc WHERE upload_date = sy-datum.
DELETE FROM zrpd_edev_t_dcval WHERE ...
DELETE FROM zrpd_edev_t_apilog WHERE log_date = sy-datum.
DELETE FROM zrpd_edev_t_proclog WHERE log_date = sy-datum.
COMMIT WORK.
```

**IT0006 Geri Alma:**
e-Devlet ile dogrulanmis ve kaydedilmis IT0006 kayitlari icin: IK uzmani PA30 -> IT0006 -> ilgili kaydi siler veya end-date'i geri alir. Otomatik rollback mekanizmasi yoktur; manuel duzeltme gerekir. Bu nedenle PRD'de dikkatli test yapilmasi kritiktir.

**SM59 / STRUST:**
Rollback gerekirse Basis, SM59 destination'larini deaktive eder; bu durumda sistem e-Devlet dogrulamasi yapamiyor olarak davranir (ZCX_ZRPD_EDEV_API firlatilir, kullanici hata mesaji alir).

---

## EKLER

### Ek-A: Ilgili Dokumantasyon

| # | Dokuman | Konum | Aciklama |
|---|---|---|---|
| 1 | Naming Convention | docs/standartlar/naming-convention.md | Tum ABAP nesne adlandirma kurallari |
| 2 | Clean ABAP Kurallari | docs/standartlar/clean-abap.md | Kodlama standartlari |
| 3 | Yasaklanan Pratikler | docs/standartlar/yasaklanan-pratikler.md | Kullanilmamasi gereken pattern'ler |
| 4 | Test Kurallari | docs/standartlar/test-kurallari.md | abapUnit test standartlari |
| 5 | Aktivasyon Sirasi | docs/mimari/aktivasyon-sirasi.md | Genel aktivasyon siralama rehberi |
| 6 | Paket Yapisi | docs/mimari/paket-yapisi.md | SAP paket hiyerarsisi |
| 7 | ECC Kisitlari | docs/platform/ecc-kisitlari.md | ECC 6.0 sinirlamalari (ENUM yok, RAISE EXCEPTION NEW yok, vs.) |
| 8 | SAP Clean ABAP Rehberi | https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md | SAP resmi stil rehberi |
| 9 | HR_INFOTYPE_OPERATION | SAP Help Portal | IT0006 yazma BAPI dokumantasyonu |
| 10 | turkiye.gov.tr API | https://turkiye.gov.tr | e-Devlet belge dogrulama API |

### Ek-B: Acik Konular

| # | Konu | Sorumlu | Hedef Tarih | Durum |
|---|---|---|---|---|
| 1 | e-Devlet test ortami: DEV gelistirmesi sirasinda gercek API'ye mi girilecek? Kabul edilebilir rate limit nedir? | Basis Ekibi | 2026-04-13 | Kapali — production URL; test ortami yok; rate limit T_PARAM.RATE_LIMIT_PER_TCKN ile korunuyor |
| 2 | OCR servis saglayicisi secimi: EasyOCR (acik kaynak, kendi sunucu) mi yoksa Google Cloud Vision/Azure mi? | Proje Yoneticisi | 2026-04-13 | Kapali — ZCL_ZRPD_EDEV_OCR_SVC SM59 destination parametrik; servis degisimi kod degisikligi gerektirmiyor |
| 3 | LLM API servis secimi | Proje Yoneticisi | 2026-04-13 | Kapali — SM59 destination parametrik |
| 4 | 81 il listesi: ABAP sabiti olarak mi, T_CNTRY gibi ayri tablo mu? | Teknik Danismani | 2026-04-13 | Kapali — ZCL_ZRPD_EDEV_CONST icinde sabit liste; guncelleme nadiren gerekecegi icin kod degisikligi kabul edilebilir |
| 5 | BAdI HRPAD00INFTY implementasyonu bu iterasyonda gereksiz mi? | Fonksiyonel Danismani | 2026-04-13 | Kapali — Bos implementasyon; sonraki iterasyonda workflow eklenecek |

### Ek-C: Onay Kayitlari

| Gate | Onaylayan | Tarih | Notlar |
|---|---|---|---|
| Gate 1: Kavramsal Tasarim (Faz 2 sonrasi) | Emre Yalcinkaya | 2026-04-06 | 8 katmanli paket mimarisi, constructor injection, chain-of-responsibility metin cikartma onaylandi |
| Gate 2: Spesifikasyon (Faz 4 sonrasi) | Emre Yalcinkaya | 2026-04-06 | Tum teknik nesneler, algoritma, test plani onaylandi; 5 acik soru kapatildi |
| Gate 3: Review (Faz 6 sonrasi) | Emre Yalcinkaya | TBD | Kodlama tamamlaninca doldurulacak |
