# DJTL Entegrasyon — Developer Teslim Dokumani

## Repo

**GitHub:** https://github.com/eykaya/edev
**Branch:** `main`
**Son commit:** `3357f6d` — `feat(edev): DJTL entegrasyon — UPLOAD/VIEW/DELETE e2e`
**Transport:** `ER1K900803` (HR: Edevlet paketi)
**SAP Sistem:** ER1 (ECC 6.0)

---

## Mevcut Durum

EDEV paketi (`ZRPD_EDEV`) DJTL paketine (`ZRPD_DJTL`) basariyla baglanmis durumda. PA30 uzerinden IT0006 (Adres) ekraninda:

- **Upload (e-Devlet):** Barkod ile e-Devlet'ten PDF indirilir, ikametgah alanlari parse edilir, Save'de PA9657 kaydi + AL11 dosya olusturulur. Calisiyor.
- **Upload (Dosya):** Dosya secilir, Save'de PA9657 + AL11. Calisiyor.
- **View:** PA9657'deki kaydin AL11 dosyasini goruntuler. Calisiyor (DJTL impl gerekli).
- **Delete:** Popup onayi + PA9657 kayit + AL11 dosya silme. Calisiyor (DJTL impl gerekli).

---

## Oncelikli Kalan Isler

### 1. DJTL Ekibine Iletilecek Bug Fix'ler (CRITICAL)

Bu 2 fix olmadan PA9657 kaydi eksik/hatali gorunur:

**A) PA9657'de Alt Tip bos**
- Dosya: `ZCL_ZRPD_DJTL_FILE` → `WRITE_FILE_AND_CREATE_RECORD`
- Sorun: `DPSTY` alani set edilmiyor, ekranda "Alt Tip" bos
- Fix: INSERT VALUE yapısina `dpsty = iv_subtyp` eklenmeli

**B) Dosya adinda saat 000000**
- Dosya: `ZCL_ZRPD_DJTL_FILE` → `WRITE_FILE_AND_CREATE_RECORD`
- Sorun: `WRITE_FILE_TO_AL11` cagirisinda `iv_uzeit` gecilmiyor
- Fix: `iv_uzeit = sy-uzeit` eklenmeli

### 2. GUI Status Refactor (HIGH)

**Problem:** Mevcut `SET PF-STATUS 'INS' OF PROGRAM 'ZRPD_EDEV_R_SGUI'` yaklaşimi kirilgan — PA30 redraw'inda butonlar kaybolabiliyor. Silme butonu goruntulenmeyebiliyor.

**Onerilen cozum:** MP965700 module pool'unun kendi CUA status'unu kullanmak:
1. SE41 → `MP965700` → mevcut status'u kopyala → `ZSTANDARD` yarat
2. Application Toolbar'a 3 buton: `ZDOC` (Yukle), `ZDOC_VIEW` (Goruntule), `ZDOC_DEL` (Sil)
3. PBO module'de `SET PF-STATUS 'ZSTANDARD'`
4. PAI module'de `CASE sy-ucomm → zcl_im_rpd_edev=>process_command(...)`
5. Eski `ZRPD_EDEV_R_SGUI` programi ve `before_output` icindeki SET PF-STATUS kaldir

Detayli plan: `docs/oturumlar/djtl-entegrasyon_emres-mbp_20260416_1703.md` → "GUI Status Plani" bolumu

### 3. PA30 Kayit Silindiginde Dokuman da Silinmeli (MEDIUM)

- PA9657 kaydi PA30'dan silindiginde AL11 dosyasi kaliyor (sizinti)
- `HRPAD00INFTY~IN_UPDATE` BAdI'sinde `ipspar` operasyon kontrolu + `DELETE_DOCUMENT` cagrisi
- Detay: `docs/DJTL_TEKNIK_TESLIM.md` Bolum 7

### 4. Diger Backlog (LOW)

- `process_p0006` ~145 statement → sub-method'lara bolunmeli (Clean ABAP limit: 100)
- `docs/DJTL_TEKNIK_TESLIM.md` imzalari gercek haliyle guncellenmeli (iv_begda, iv_config planda yoktu)
- T_DTYP SM30: yeni belge tipleri (KIMLIK/0002/02, DIPLOMA/0022/06, BANKA_IBAN/0009/14)

---

## Repo Yapisi

```
src/
  zcl_im_rpd_edev.clas.abap         ← ANA ENTEGRASYON CLASS'I (tum degisiklikler burada)
  zcl_zrpd_edev_edevlet.clas.abap   ← e-Devlet API istemci
  zcl_zrpd_edev_doc_ika.clas.abap   ← Ikametgah parser
  zcl_zrpd_edev_doc_base.clas.abap  ← Parser base class
  zcl_zrpd_edev_ocr_py.clas.abap    ← Python OCR koprusu
  zcx_zrpd_edev.clas.abap           ← Exception class
  zrpd_edev_r_sgui.prog.abap        ← GUI Status (refactor sonrasi silinecek)
  zrpd_edev_r_test.prog.abap        ← Test raporu (SE38)
  zrpd_edev_enh.enho.*.abap         ← PA30 enhancement (BAdI impl)
  zrpd_edev_t_*.tabl.xml            ← Config tablolari (T_DTYP, T_DMAP, ...)

docs/
  DJTL_ENTEGRASYON_GOREVLERI.md     ← Guncel is kalemleri
  DJTL_TEKNIK_TESLIM.md             ← DJTL ekibine teknik handoff (11 bolum)
  oturumlar/
    djtl-entegrasyon_emres-mbp_20260416_1703.md  ← Oturum logu (yapilan/kalan/buglar/review)
    PLAN_DJTL_ENTEGRASYON.md         ← Plan modu ciktisi
    TESLIM_DJTL_ENTEGRASYON.md       ← BU DOKUMAN
```

---

## EDEV ↔ DJTL Etkilesim Haritasi

```
PA30 (SAPFP50M)
  |
  ├── [&ZDOC buton] → zcl_im_rpd_edev=>process_command('UPLOAD')
  │   ├── upload_from_edevlet → process_p0006 (barkod+PDF+parse)
  │   └── upload_from_file (frontend dosya sec)
  │       ↓ gv_pending_* state set
  │
  ├── [SAVE] → if_ex_hrpad00infty~in_update
  │   └── ZCL_ZRPD_DJTL_FILE=>WRITE_FILE_AND_CREATE_RECORD
  │       (pernr, subtyp, begda, file_data, source, config)
  │       → AL11 dosya + PA9657 INSERT
  │
  ├── [&ZDOC_VIEW] → process_view → get_current_record (PA9657 SELECT)
  │   └── ZCL_ZRPD_DJTL_FILE=>VIEW_DOCUMENT (pernr, subtyp, config)
  │
  └── [&ZDOC_DEL] → process_delete → popup + get_current_record
      └── ZCL_ZRPD_DJTL_FILE=>DELETE_DOCUMENT
          (pernr, subtyp, config, filep, skip_record_delete=false)
```

**Tum DJTL cagrilari dinamik** (`('CLASS')=>('METHOD')`). DJTL paketi yoksa `has_djtl_method()` false doner, warning mesaji gosterilir, dump olmaz.

---

## Onemli Notlar

- **DJTL paketinde hicbir degisiklik yapilmadi** — sadece EDEV tarafinda entegrasyon kodu
- **DJTL method imzalari degisirse runtime hatasi olur** — degisiklik oncesi koordinasyon sart
- **Transport sirasi:** DJTL transport'u EDEV'den once tasinmali (DJTL yoksa EDEV zarif duser ama islem yapmaz)
- Proje standartlari: `CLAUDE.md` ve `docs/standartlar/` altinda (Clean ABAP, K1-K12 retrospektif kurallari)
- Oturum detay logu: `docs/oturumlar/djtl-entegrasyon_emres-mbp_20260416_1703.md`
