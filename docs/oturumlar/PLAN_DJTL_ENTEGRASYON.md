# DJTL Ekibine Teknik Teslim Dokumani — Plan

## Context

EDEV paketi `zcl_im_rpd_edev` refactor edildi (dispatcher → UPLOAD/VIEW/DELETE). DJTL (ZRPD_DJTL) tarafinda karsilanmasi gereken 5 is kalemi `docs/DJTL_ENTEGRASYON_GOREVLERI.md` icinde listelenmis durumda. Kullanici yorumlari sonrasi bu islerin DJTL ekibi tarafindan yapilabilmesi icin **tek bir cikti** uretilecek: teknik teslim MD dokumani.

**Scope disi:** Bu turda hicbir ABAP kodu yazilmayacak, `docs/DJTL_ENTEGRASYON_GOREVLERI.md` guncellenmeyecek, DDIC/tablo degisikligi yapilmayacak. Sadece teslim dokumani olusturulacak.

---

## Tek Ciktiya: `docs/DJTL_TEKNIK_TESLIM.md`

Dokumanin bolum planı (yazilacak icerik):

### Bolum 1 — Ozet ve Baglami
- EDEV tarafinda ne degisti (dispatcher, T_DTYP alanlari, enhancement hook 3 komut)
- DJTL ekibinden beklenen toplam kapsam (5 madde ozeti)
- Onkosul: ZCL_ZRPD_DJTL_FILE mevcut durumu

### Bolum 2 — PA9657 `SOURCE` Alani ve Domain
- Yeni alan: `SOURCE` (NUMC2) — PA9657 icin CI include uzerinden
- Yeni domain: `ZRPD_DJTL_D_SOURCE`, fix values:
  - `00` Kullanici girisi (bos/default)
  - `01` e-Devlet
  - `99` Diger
- DDIC aktivasyon sirasi: DOMA → DTEL → CI include → PA9657
- Migration notu: mevcut kayitlar icin `SOURCE = '00'` default

### Bolum 3 — Yeni Method: `write_file_and_create_record`
- Sorumluluk: xstring'i AL11'e yaz + PA9657 kaydini olustur (atomik)
- Imza:

```abap
methods write_file_and_create_record
  importing
    iv_pernr     type p_pernr
    iv_subtyp    type djtl_atip       " NUMC2
    iv_file_data type xstring
    iv_source    type zrpd_djtl_d_source  " 00/01/99
  exporting
    ev_xuploaded type abap_bool
    ev_filename  type string
    ev_message   type string.
```

- Method icinde `sy-datum` / `sy-uzeit` DJTL tarafinda alinir (EDEV gondermez)
- File extension xstring magic-byte ile tespit edilir (veya default PDF)
- PA9657 kaydi `HR_INFOTYPE_OPERATION` ile olusturulur (NOCOMMIT_MODE='X'), `SOURCE` alani `iv_source` ile doldurulur
- Hata durumlari: dosya yazilamadi, PA9657 olusturulamadi → rollback + `ev_message`

### Bolum 4 — Yeni Method: `view_document`
- Imza: `iv_pernr`, `iv_subtyp` → (cikti yok, ekran acar)
- Ic akis: `EPS2_GET_DIRECTORY_LISTING` ile AL11 dosyayi bul → `cl_gui_html_viewer` ile goster
- Dosya yoksa: bilgi mesaji

### Bolum 5 — Yeni Method: `delete_document`
- Imza: `iv_pernr`, `iv_subtyp` → `ev_success` (abap_bool)
- Ic akis: `DELETE DATASET` (AL11) + PA9657 kayit silme (`HR_INFOTYPE_OPERATION` DEL, eger kayit hala varsa)
- **Idempotent:** dosya yoksa warning, error degil
- Popup onayi cagiran tarafin sorumlulugu (bkz. Bolum 7)

### Bolum 6 — EDEV'in Dinamik Cagirim Kod Ornekleri
- `in_update` icinde `write_file_and_create_record` cagrisi (mevcut `write_file_to_al11` yerine)
- `process_view` icinde `view_document` cagrisi (placeholder degisimi)
- `process_delete` icinde `delete_document` cagrisi + popup onayi
- `iv_source` turetimi: dispatcher command → `UPLOAD_FROM_FILE=00`, `UPLOAD_FROM_EDEVLET=01`

### Bolum 7 — PA30 Silme Entegrasyonu (HRPAD00INFTY~IN_UPDATE)
- PA9657 kaydi PA30'dan silindiginde dokumanin da silinmesi icin
- BAdI `HRPAD00INFTY~IN_UPDATE` icinde:
  - `is_operation = 'DEL'` (veya `'COP'` vs. arastirilacak) tespit edilir
  - Onay popup'i: `"Bu islem PA9657 kaydiyla birlikte AL11'deki dokumani da silecek. Devam edilsin mi?"`
  - Onay sonrasi `delete_document` cagrilir
- Iki giris noktasi (EDEV butonu + PA30 silme) ayni davranisi uretir — dosya sizintisi kapanir

### Bolum 8 — T_DTYP Veri Girisi (SM30)
- Mevcut satir: `IKAMETGAH | 0006 | 05 | ZCL_ZRPD_EDEV_DOC_IKA | X`
- DJTL ekibinden eklenmesi istenen satirlar: KIMLIK (0002/02), DIPLOMA (0022/06), BANKA_IBAN (0009/14), ...
- Kural: `PARSER_CLASS` bos → passthrough; dolu → EDEV isle

### Bolum 9 — Test Senaryolari
- **Upload (dosya):** EDEV buton → dosya sec → AL11'de dosya + PA9657 kayit (SOURCE=00) olustu mu?
- **Upload (e-devlet):** EDEV buton → e-devlet akisi → AL11 dosya + PA9657 (SOURCE=01)
- **View:** PA9657 kayit uzerinde goruntule → HTML viewer acildi mi?
- **Delete (EDEV butonu):** onay popup + AL11 dosya + PA9657 kayit gitti mi?
- **Delete (PA30 kayit silme):** onay popup + AL11 dosya da silindi mi?
- **Idempotency:** dosya yoksa `delete_document` hata vermiyor, warning

### Bolum 10 — Aktivasyon Sirasi ve Transport
- Sira: DOMA `ZRPD_DJTL_D_SOURCE` → DTEL → CI include `CI_P9657` → TABL `PA9657` → CLAS `ZCL_ZRPD_DJTL_FILE` method imzalari → BAdI impl
- Tek transport onerisi (bagimlilik zinciri kirilmasin)
- EDEV tarafi imza degisikliginden etkilenir — DJTL transport'u EDEV transport'undan once tasinmali

### Bolum 11 — Scope Disi (Hatirlatma)
- Bilgi tiplerine CONFG alani eklenmesi bu teslimin disinda (ayri bilgi tipi projeleri)

---

## Kritik Okuma Dosyalari (referans icin)
- [docs/DJTL_ENTEGRASYON_GOREVLERI.md](/Users/emreyalcinkaya/Projects/EDEV/docs/DJTL_ENTEGRASYON_GOREVLERI.md) — kaynak liste
- [src/zcl_im_rpd_edev.clas.abap](/Users/emreyalcinkaya/Projects/EDEV/src/zcl_im_rpd_edev.clas.abap) — dispatcher, `in_update`, dinamik cagri pattern'i

## Dogrulama
- Dokuman uretildikten sonra kullanici review eder.
- Onay sonrasi DJTL ekibine Git/email ile paylasilir.
- Bu turda kod, tablo, domain, enhancement, BAdI implementasyonu **yapilmayacak** — sadece MD dosyasi yazilacak.
