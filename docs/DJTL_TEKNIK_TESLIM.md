# DJTL Teknik Teslim Dokumani

> **Hedef ekip:** ZRPD_DJTL gelistirme ekibi
> **Kaynak:** ZRPD_EDEV (e-Devlet entegrasyon paketi)
> **Baglami kisa ozet:** EDEV tarafi refactor edildi; PA9657 uzerindeki dokuman yonetimi icin DJTL tarafinda bir dizi degisiklik gerekiyor. Bu dokuman o degisikliklerin tam teknik tanimidir.

---

## 1. Ozet ve Baglami

### 1.1 EDEV tarafinda yapilanlar

- `zcl_im_rpd_edev` enhancement class'i **dispatcher pattern'e** gecirildi. `process_command` metodu tek giris noktasi.
- 3 komut destekleniyor: **UPLOAD**, **VIEW**, **DELETE** (subdispatch: `UPLOAD_FROM_FILE`, `UPLOAD_FROM_EDEVLET`).
- `in_update` metodu DJTL'ye **dinamik cagri** yapar (`create object lo_djtl type ('ZCL_ZRPD_DJTL_FILE')`). EDEV, DJTL'ye compile-time bagimli degildir.
- `ZRPD_EDEV_T_DTYP` tablosuna iki alan eklendi: `DJTL_ATIP` (NUMC2 — PA9657 subtype) ve `INFOTYPE` (NUMC4).
- Mevcut `IKAMETGAH` satiri: `DJTL_ATIP=05`, `INFOTYPE=0006`.

### 1.2 DJTL ekibinden beklenen toplam kapsam

| # | Is Kalemi | Ozet |
|---|-----------|------|
| 1 | PA9657 `SOURCE` alani + domain | Belge kaynagini (kullanici/e-devlet/diger) PA9657'de tut |
| 2 | Yeni method `write_file_and_create_record` | Dosya yazimi + PA9657 kayit olusturma atomik |
| 3 | Yeni method `view_document` | AL11 dosyayi HTML viewer'da goster |
| 4 | Yeni method `delete_document` | AL11 dosya + PA9657 kayit sil (idempotent) |
| 5 | BAdI `HRPAD00INFTY~IN_UPDATE` | PA30'dan silme esnasinda dokumani da sil |
| 6 | T_DTYP satirlari (SM30) | Yeni belge tipleri icin veri |

### 1.3 Onkosul — `ZCL_ZRPD_DJTL_FILE` mevcut durumu

Su an EDEV `in_update` icinde mevcut metoda su imza ile cagri yapiyor:

```abap
call method lo_djtl->('WRITE_FILE_TO_AL11')
  exporting
    iv_pernr          = gv_pending_pernr
    iv_subtyp         = gv_pending_atip      " NUMC2
    iv_datum          = sy-datum
    iv_uzeit          = sy-uzeit
    iv_file_data      = gv_pending_file      " xstring
    iv_file_extension = gv_pending_ext       " 'PDF' / 'JPG' / 'PNG'
  importing
    ev_xuploaded      = lv_ok
    ev_filename       = lv_filep
    ev_message        = lv_msg.
```

**Bu method aynen kalabilir (geri uyumluluk icin) ancak yeni gelistirmelerde Bolum 3'teki sadelestirilmis imza kullanilacak.**

---

## 2. PA9657 `SOURCE` Alani ve Domain

### 2.1 Yeni Domain: `ZRPD_DJTL_D_SOURCE`

| Ozellik | Deger |
|---------|-------|
| Tip | NUMC |
| Uzunluk | 2 |
| Fix values | Evet |

**Fix values:**

| Kod | Kisa Metin | Uzun Aciklama |
|-----|-----------|---------------|
| `00` | Kullanici girisi | Bos gelen ya da manuel giris yapilan kayitlar. Default. |
| `01` | e-Devlet | EDEV dispatcher `UPLOAD_FROM_EDEVLET` komutuyla gelen belgeler |
| `99` | Diger | Gelecekteki kaynak turleri (ornegin tarayici, mobil app) icin yedek |

### 2.2 Yeni Data Element: `ZRPD_DJTL_DE_SOURCE`

- Domain: `ZRPD_DJTL_D_SOURCE`
- Field label: `Kaynak` / `Belge Kaynagi` / `Source` / `Document Source`

### 2.3 PA9657 CI Include Eklemesi

`CI_P9657` (veya ilgili customer include) icine yeni alan:

| Alan Adi | Data Element | Aciklama |
|----------|--------------|----------|
| `SOURCE` | `ZRPD_DJTL_DE_SOURCE` | Belge kaynagi |

### 2.4 Aktivasyon Sirasi (kritik)

```
1) DOMA  ZRPD_DJTL_D_SOURCE
2) DTEL  ZRPD_DJTL_DE_SOURCE
3) TABL  CI_P9657   (include)
4) TABL  PA9657     (etkilenen tablo — aktivasyon sirasi bozulmamali)
5) CLAS  ZCL_ZRPD_DJTL_FILE  (yeni method imzasi)
6) BAdI  HRPAD00INFTY impl   (IN_UPDATE eklentisi)
```

### 2.5 Migration Notu

Mevcut PA9657 kayitlari icin `SOURCE = '00'` (Kullanici girisi) kabul edilir — backfill gerekli degil (NUMC default zaten `'00'`).

---

## 3. Yeni Method: `write_file_and_create_record`

### 3.1 Sorumluluk

Tek method icinde **atomik** olarak:
1. `iv_file_data` (xstring) AL11'e yazilir.
2. PA9657 kaydi olusturulur (`HR_INFOTYPE_OPERATION` / `INS`, `NOCOMMIT_MODE = 'X'`).
3. PA9657 `SOURCE` alani `iv_source` ile doldurulur.

### 3.2 Imza

```abap
methods write_file_and_create_record
  importing
    iv_pernr     type p_pernr
    iv_subtyp    type djtl_atip            " NUMC2 — ATip
    iv_file_data type xstring              " Dosyanin kendisi
    iv_source    type zrpd_djtl_de_source  " 00 / 01 / 99
  exporting
    ev_xuploaded type abap_bool
    ev_filename  type string
    ev_message   type string.
```

### 3.3 Kaldirilan Parametreler (mevcut `write_file_to_al11` ile karsilastirma)

| Eski | Neden kaldirildi |
|------|------------------|
| `iv_datum` | DJTL kendi icinde `sy-datum` kullanir |
| `iv_uzeit` | DJTL kendi icinde `sy-uzeit` kullanir |
| `iv_file_extension` | DJTL xstring magic-byte ile tespit eder (alternatif: her zaman PDF) |

### 3.4 Hata Durumlari

| Durum | Davranis |
|-------|----------|
| AL11 yazilamadi | `ev_xuploaded = abap_false`, `ev_message = 'AL11 yazma hatasi: ...'` |
| PA9657 olusturulamadi | Dosya silinir (rollback), `ev_xuploaded = abap_false`, `ev_message = HR_INFOTYPE_OPERATION return metni` |
| Basarili | `ev_xuploaded = abap_true`, `ev_filename = <AL11 tam yol>`, `ev_message = 'Basarili'` |

> **Not:** `NOCOMMIT_MODE = 'X'` cagrilir; final COMMIT WORK cagiran ust katmanin (PA30 infotype islemi) sorumlulugunda.

---

## 4. Yeni Method: `view_document`

### 4.1 Imza

```abap
methods view_document
  importing
    iv_pernr  type p_pernr
    iv_subtyp type djtl_atip.
  " Cikti yok — ekran acar
```

### 4.2 Ic Akis

1. `EPS2_GET_DIRECTORY_LISTING` ile AL11'de `<kayit klasoru>/<pernr>_<subtyp>_*` pattern'i ara
2. Bulunan dosyanin full path'ini `OPEN DATASET FOR INPUT IN BINARY MODE` ile oku
3. `cl_gui_html_viewer` (veya `cl_gui_pdf_viewer`) ile modal ekranda goster
4. Dosya yoksa: `MESSAGE 'Dokuman bulunamadi' TYPE 'S' DISPLAY LIKE 'W'` ve return

### 4.3 Hata Durumlari

- Birden cok dosya bulundu: en son tarihli olan gosterilir (warning log)
- AL11 okuma hatasi: error mesaji, ekran acilmaz

---

## 5. Yeni Method: `delete_document`

### 5.1 Imza

```abap
methods delete_document
  importing
    iv_pernr   type p_pernr
    iv_subtyp  type djtl_atip
    iv_skip_record_delete type abap_bool default abap_false  " HRPAD00INFTY cagrisinda X
  exporting
    ev_success type abap_bool
    ev_message type string.
```

### 5.2 Ic Akis

1. `EPS2_GET_DIRECTORY_LISTING` ile AL11 dosyayi bul
2. `DELETE DATASET <full_path>` ile dosyayi sil
3. `iv_skip_record_delete = abap_false` ise (EDEV butonundan gelen cagri): `HR_INFOTYPE_OPERATION` / `DEL` ile PA9657 kaydini da sil
4. `iv_skip_record_delete = abap_true` ise (PA30 silme zaten BAdI icinde, kayit silme ust katmanda oluyor): sadece dosya silme

### 5.3 Idempotency

- Dosya yoksa: `ev_success = abap_true`, `ev_message = 'Dokuman zaten yok'` — **error degil**
- PA9657 kayit yoksa: benzer sekilde warning, success

### 5.4 Popup Onayi

Popup **cagiran tarafin sorumlulugu** (bkz. Bolum 6 ve 7). `delete_document` method'u popup gostermez.

---

## 6. EDEV'in Dinamik Cagirim Kod Ornekleri

### 6.1 Upload — `in_update` (yeni imzaya gore)

```abap
data: lo_djtl   type ref to object,
      lv_ok     type abap_bool,
      lv_filep  type string,
      lv_msg    type string,
      lv_source type zrpd_djtl_de_source.

" iv_source turetimi: dispatcher command'den
case gv_pending_command.
  when 'UPLOAD_FROM_FILE'.
    lv_source = '00'.
  when 'UPLOAD_FROM_EDEVLET'.
    lv_source = '01'.
  when others.
    lv_source = '99'.
endcase.

create object lo_djtl type ('ZCL_ZRPD_DJTL_FILE').
call method lo_djtl->('WRITE_FILE_AND_CREATE_RECORD')
  exporting
    iv_pernr     = gv_pending_pernr
    iv_subtyp    = gv_pending_atip
    iv_file_data = gv_pending_file
    iv_source    = lv_source
  importing
    ev_xuploaded = lv_ok
    ev_filename  = lv_filep
    ev_message   = lv_msg.
```

### 6.2 View — `process_view`

```abap
create object lo_djtl type ('ZCL_ZRPD_DJTL_FILE').
call method lo_djtl->('VIEW_DOCUMENT')
  exporting
    iv_pernr  = lv_pernr
    iv_subtyp = lv_atip.
```

### 6.3 Delete — `process_delete` (popup + cagri)

```abap
data lv_answer type c length 1.

call function 'POPUP_TO_CONFIRM'
  exporting
    titlebar              = 'Dokuman Silme Onayi'
    text_question         = 'Bu islem PA9657 kaydiyla birlikte AL11''deki dokumani da silecek. Devam edilsin mi?'
    default_button        = '2'
    display_cancel_button = abap_false
  importing
    answer                = lv_answer.

check lv_answer = '1'.  " Evet

create object lo_djtl type ('ZCL_ZRPD_DJTL_FILE').
call method lo_djtl->('DELETE_DOCUMENT')
  exporting
    iv_pernr              = lv_pernr
    iv_subtyp             = lv_atip
    iv_skip_record_delete = abap_false
  importing
    ev_success            = lv_ok
    ev_message            = lv_msg.
```

---

## 7. PA30 Silme Entegrasyonu — BAdI `HRPAD00INFTY~IN_UPDATE`

### 7.1 Problem

PA9657 kaydi PA30'dan (SE17/SE37 degil, standart ekran) silindiginde AL11 uzerindeki dokuman **kaliyordu**. Dosya sizintisi.

### 7.2 Cozum

BAdI `HRPAD00INFTY` impl'i icinde `IN_UPDATE` metodu:

```abap
method if_ex_hrpad00infty~in_update.
  " Sadece PA9657 ve DEL operasyonunda calis
  check innnn-infty = '9657'.
  check is_operation = 'DEL'.  " (COP icin gerekiyorsa ayri dal)

  " Mevcut kaydin PERNR ve SUBTY bilgisini oku
  data(lv_pernr)  = innnn-pernr.
  data(lv_subtyp) = innnn-subty.

  " Popup onayi
  data lv_answer type c length 1.
  call function 'POPUP_TO_CONFIRM'
    exporting
      titlebar              = 'Dokuman Silme Onayi'
      text_question         = 'Bu islem AL11''deki dokumani da silecek. Devam edilsin mi?'
      default_button        = '2'
      display_cancel_button = abap_false
    importing
      answer                = lv_answer.

  if lv_answer <> '1'.
    " Kullanici vazgecti — infotype silme islemini de iptal et
    raise exception type cx_hrpa_violated_assertion.
  endif.

  " Dokumani sil (kayit silme zaten ust katmanda yapilacak)
  data lo_djtl type ref to object.
  data lv_ok  type abap_bool.
  data lv_msg type string.

  create object lo_djtl type ('ZCL_ZRPD_DJTL_FILE').
  call method lo_djtl->('DELETE_DOCUMENT')
    exporting
      iv_pernr              = lv_pernr
      iv_subtyp             = lv_subtyp
      iv_skip_record_delete = abap_true    " Kayit silmeyi atla — PA30 zaten siliyor
    importing
      ev_success            = lv_ok
      ev_message            = lv_msg.
endmethod.
```

### 7.3 Iki Giris Noktasi — Ayni Davranis

| Giris Noktasi | Kayit Silme | Dosya Silme | Popup |
|---------------|-------------|-------------|-------|
| EDEV butonu (`process_delete`) | `delete_document` yapar (`iv_skip_record_delete = false`) | `delete_document` yapar | EDEV tarafinda gosterilir |
| PA30 standart kayit silme | PA30 kendisi yapar | BAdI `IN_UPDATE` icinde `delete_document` yapar (`iv_skip_record_delete = true`) | BAdI icinde gosterilir |

### 7.4 Operation Kodlari Referansi

| Kod | Aciklama |
|-----|----------|
| `INS` | Insert — yeni kayit |
| `MOD` | Modify — mevcut kayit guncelleme |
| `DEL` | Delete — kayit silme (**bizim ilgilendigimiz**) |
| `COP` | Copy — kopyalama (gerekirse ayri dal) |

---

## 8. T_DTYP Veri Girisi (SM30)

### 8.1 Mevcut Satir

| DOC_TYPE | INFOTYPE | DJTL_ATIP | PARSER_CLASS | ACTIVE |
|----------|----------|-----------|--------------|--------|
| IKAMETGAH | 0006 | 05 | ZCL_ZRPD_EDEV_DOC_IKA | X |

### 8.2 Eklenmesi Beklenen Satirlar (ornek)

| DOC_TYPE | INFOTYPE | DJTL_ATIP | PARSER_CLASS | ACTIVE |
|----------|----------|-----------|--------------|--------|
| KIMLIK | 0002 | 02 | _(bos)_ | X |
| DIPLOMA | 0022 | 06 | _(bos)_ | X |
| BANKA_IBAN | 0009 | 14 | _(bos)_ | X |
| ... | ... | ... | ... | ... |

### 8.3 Kural

- `PARSER_CLASS` **bos** → passthrough: EDEV islemez, dosya direkt DJTL'ye gider
- `PARSER_CLASS` **dolu** → EDEV isle: barkod dogrulama, e-Devlet sorgulama, parse, mapping

---

## 9. Test Senaryolari

### 9.1 Upload — Dosya yukleme
1. PA30 → 9657 → Dokuman Yukle butonu → dosya sec → enter
2. AL11'de dosya olusmali
3. PA9657'de kayit olusmali, `SOURCE = '00'`

### 9.2 Upload — e-Devlet akisi
1. PA30 → 9657 → e-Devlet butonu → akis tamamlanir
2. AL11'de dosya + PA9657 kayit, `SOURCE = '01'`

### 9.3 View
1. PA30 → 9657 → kayit uzerinde Goruntule butonu
2. HTML viewer acilir ve dokuman gosterilir

### 9.4 Delete — EDEV butonundan
1. PA30 → 9657 → kayit uzerinde Sil butonu
2. Popup onayi → Evet
3. AL11 dosya silinir, PA9657 kayit silinir

### 9.5 Delete — PA30 standart silme
1. PA30 → 9657 → kayit sec → F12 (sil)
2. Popup onayi → Evet
3. AL11 dosya silinir (BAdI), PA9657 kayit silinir (standart)
4. Popup → Hayir: kayit **da** silinmez (exception ile rollback)

### 9.6 Idempotency
1. AL11'den dosya manuel silindikten sonra `delete_document` cagrisi: hata degil, warning

---

## 10. Aktivasyon Sirasi ve Transport

### 10.1 Sira (Bolum 2.4 ile ayni)

```
DOMA → DTEL → CI_P9657 → PA9657 → CLAS (ZCL_ZRPD_DJTL_FILE) → BAdI impl
```

### 10.2 Transport Stratejisi

**Tek transport** onerilir — bagimlilik zinciri parcalanirsa DEV/QAS'ta aktivasyon kirilir.

### 10.3 EDEV Tarafi ile Koordinasyon

- EDEV tarafindaki `in_update` yeni imzaya gore guncellendiginde DJTL imzasinin DEV/QAS/PRD'de **hazir olmasi gerek**.
- **Tavsiye:** DJTL transport'u EDEV transport'undan **once** tasinir. Boylece EDEV dinamik cagrisi calismaya basladiginda DJTL hazir durumda olur.
- Rollback plani: EDEV eski imzaya geri alinabilir (`write_file_to_al11` silinmedi).

---

## 11. Scope Disi (Hatirlatma)

Asagidaki konular **bu teslimde** yok; ayri projelerde ele alinacak:

- **Bilgi tipi CONFG alani:** Her bilgi tipine (9657, 0006, vb.) barkod/dokuman ID tutacak bir alan eklenmesi — ilgili bilgi tipi projelerinde.
- **Bilgi tipi gelistirmeleri:** KIMLIK, DIPLOMA vb. parser class'larinin yazilmasi — EDEV tarafinda, DJTL disinda.

---

## Ekler

### Ek A — Dosya Adlandirma Konvansiyonu (mevcut DJTL pattern'i referans)

DJTL zaten bir dosya adlandirma konvansiyonu kullaniyor olabilir. Eger yoksa onerilen:

```
/<AL11_ROOT>/DJTL/<PERNR>/<SUBTY>_<SY-DATUM>_<SY-UZEIT>.<ext>
```

### Ek B — Ilgili Objeler

| Obje | Tip | Paket |
|------|-----|-------|
| `ZCL_ZRPD_DJTL_FILE` | CLAS | ZRPD_DJTL |
| `ZRPD_DJTL_D_SOURCE` | DOMA | ZRPD_DJTL |
| `ZRPD_DJTL_DE_SOURCE` | DTEL | ZRPD_DJTL |
| `CI_P9657` | TABL (include) | ZRPD_DJTL |
| `PA9657` | TABL | HR standard (extend via include) |
| `HRPAD00INFTY` | BADI | HR standard |
| `zcl_im_rpd_edev` | CLAS (enhancement) | ZRPD_EDEV |
| `ZRPD_EDEV_T_DTYP` | TABL | ZRPD_EDEV |

### Ek C — Iletisim

Entegrasyon sorulari icin EDEV tarafina danisilabilir. EDEV kod referansi: [`src/zcl_im_rpd_edev.clas.abap`](src/zcl_im_rpd_edev.clas.abap) — `process_command`, `in_update`, `process_view`, `process_delete` metodlari.
