# DJTL Entegrasyon Gorevleri

EDEV paketindeki degisikliklerin DJTL (ZRPD_DJTL) tarafinda karsilanmasi gereken isler.

## Onkosul

EDEV tarafinda tamamlanan isler:
- `zcl_im_rpd_edev` refactor edildi: dispatcher (`process_command`), `in_update` (dinamik DJTL cagri), `upload_from_file`, `upload_from_edevlet`
- `ZRPD_EDEV_T_DTYP` tablosuna `DJTL_ATIP` (NUMC2) ve `INFOTYPE` (NUMC4) alanlari eklendi
- IKAMETGAH satiri guncellendi: DJTL_ATIP=05, INFOTYPE=0006
- Enhancement hook 3 komut destekliyor: UPLOAD, VIEW, DELETE

---

## 1. ZCL_ZRPD_DJTL_FILE Uyumlulugu

EDEV `in_update` metodu su sekilde dinamik cagri yapiyor:

```abap
create object lo_djtl type ('ZCL_ZRPD_DJTL_FILE').
call method lo_djtl->('WRITE_FILE_TO_AL11')
  exporting
    iv_pernr          = gv_pending_pernr
    iv_subtyp         = gv_pending_atip    " NUMC2 - 9657 ATip
    iv_datum          = sy-datum
    iv_uzeit          = sy-uzeit
    iv_file_data      = gv_pending_file    " xstring
    iv_file_extension = gv_pending_ext     " 'PDF' / 'JPG' / 'PNG'
  importing
    ev_xuploaded      = lv_ok
    ev_filename       = lv_filep
    ev_message        = lv_msg.
```

**Gerekli:** `ZCL_ZRPD_DJTL_FILE=>write_file_to_al11` mevcut imzasiyla uyumlu kalmali. Degisiklik yapilmamali.

---

## 2. PA9657 Kayit Olusturma

EDEV su an sadece dosya yazimini yapip `in_update`'de DJTL'ye delege ediyor. PA9657 kaydi henuz otomatik olusturulmuyor.

**Secenek A (Onerilen):** DJTL tarafinda `write_file_to_al11` sonrasinda PA9657 kaydini da otomatik olusturan bir method ekle:

```abap
methods write_file_and_create_record
  importing
    iv_pernr iv_subtyp iv_datum iv_uzeit
    iv_file_data iv_file_extension
  exporting
    ev_xuploaded ev_filename ev_message.
```

**Secenek B:** EDEV tarafinda `HR_INFOTYPE_OPERATION` ile PA9657 kaydi olusturulsun (NOCOMMIT_MODE='X'). Bu durumda EDEV'den PA9657'ye direkt erisim gerekir.

---

## 3. View ve Delete Implementasyonu

EDEV'de `process_view` ve `process_delete` su an placeholder:

```abap
message 'Goruntuleme henuz aktif degil' type 'S' display like 'I'.
message 'Silme henuz aktif degil' type 'S' display like 'I'.
```

**DJTL tarafinda yapilacak:** View/delete islemleri icin DJTL'de yeni method'lar eklenmeli. EDEV bunlari dinamik cagiracak:

```abap
" View icin
create object lo_djtl type ('ZCL_ZRPD_DJTL_FILE').
call method lo_djtl->('VIEW_DOCUMENT')
  exporting iv_pernr = lv_pernr  iv_subtyp = lv_atip.

" Delete icin
call method lo_djtl->('DELETE_DOCUMENT')
  exporting iv_pernr = lv_pernr  iv_subtyp = lv_atip.
```

DJTL'de eklenecek method'lar:

| Method | Input | Cikti | Aciklama |
|--------|-------|-------|----------|
| `view_document` | iv_pernr, iv_subtyp | - | EPS2_GET_DIRECTORY_LISTING + cl_gui_html_viewer |
| `delete_document` | iv_pernr, iv_subtyp | ev_success | DELETE DATASET + PA9657 kayit sil |

---

## 4. Barkod Saklama: F9 Long Text (IT0006)

**Yaklasim degisikligi:** Her bilgi tipine CONFG alani eklemek yerine, bilgi tipi kaydinin **F9 uzun metin (SAPScript long text)** alanı kullanılır. Barkod bu metne yazılır, `ITXEX = 'X'` flag set edilir; F9 butonu kullanıcıya aktif görünür ve standart text editörüyle barkod okunur.

**Konum:** [src/zcl_im_rpd_edev.clas.abap](../src/zcl_im_rpd_edev.clas.abap)
- `AFTER_INPUT` → `(MP000600)P0006-ITXEX = 'X'` (dynamic assign)
- `IN_UPDATE` → DJTL save basarili sonrasi `save_barcode_text` cagrilir
- `save_barcode_text` → `SAVE_TEXT` FM (TDOBJECT='PREL', TDID='0006', TDNAME = PSKEY encoding)

**Kapsam disi alinmis nokta:** P0006 CI include, T_DMAP barkod mapping'i — gerek yok.

---

## 5. T_DTYP Veri Girisi (SM30)

Yeni belge tipleri eklendikce T_DTYP'ye satirlar girilmeli:

| DOC_TYPE | INFOTYPE | DJTL_ATIP | PARSER_CLASS | ACTIVE |
|----------|----------|-----------|--------------|--------|
| IKAMETGAH | 0006 | 05 | ZCL_ZRPD_EDEV_DOC_IKA | X |
| KIMLIK | 0002 | 02 | | X |
| DIPLOMA | 0022 | 06 | | X |
| BANKA_IBAN | 0009 | 14 | | X |
| ... | ... | ... | ... | ... |

PARSER_CLASS bos = passthrough (EDEV islemez, direkt dosya yukle).
PARSER_CLASS dolu = EDEV isle (barkod, e-Devlet, parse, map).
