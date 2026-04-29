# ZRPD_EDEV — Proje Ozeti

> **Son guncelleme:** 2026-04-24
> **Branch:** `main` (son commit: `cd4a071`)
> **Platform:** SAP ECC 6.0 (ABAP 7.50) — HR modulu
> **Paket:** `ZRPD_EDEV`

## 1. Proje Ne Yapiyor?

`ZRPD_EDEV`, IK surecinde personel belgelerinin (ikametgah, diploma vb.) **e-Devlet uzerinden otomatik yuklenip dogrulanmasini** saglayan bir HR enhancement paketidir. Manuel PA30 girisinde yasanan dogrulama eksikligi, sahtecilik riski ve veri tutarsizligini ortadan kaldirir.

**Akis:**
```
PA30 (IT0006/IT0022) -> F9 barkod -> e-Devlet API
                     -> PDF indir  -> Python OCR -> ABAP parser
                     -> alan eslesme -> DJTL (AL11 + PA9657)
```

## 2. Mimari (ust duzey)

| Katman | Obje(ler) | Sorumluluk |
|--------|-----------|------------|
| **Enhancement** | `ZCL_IM_RPD_EDEV` (BAdI `HRPAD00INFTY`) | PA30 dispatcher; UPLOAD/VIEW/DELETE |
| **Parser** | `ZCL_ZRPD_EDEV_DOC_BASE` + `_IKA` + `_MEZ` | Belge formatina ozel alan cikarma |
| **OCR Kopru** | `ZCL_ZRPD_EDEV_OCR_PY` | Python OCR'i `SXPG_COMMAND_EXECUTE` ile cagirir |
| **e-Devlet API** | `ZCL_ZRPD_EDEV_EDEVLET` | Barkod/TCKN ile e-Devlet sorgulama |
| **Exception** | `ZCX_ZRPD_EDEV` (tek sinif, msgno ile tip ayrimi — K3) | Hata yonetimi |
| **DJTL entegrasyonu** | Dinamik cagri (`CALL METHOD (class)->(method)`) | Dosya/PA9657 kaydi `ZRPD_DJTL` paketinde (compile-time bagimsiz) |

**Dosya referanslari:**
- Enhancement giris noktasi: [src/zcl_im_rpd_edev.clas.abap](../src/zcl_im_rpd_edev.clas.abap)
- Spec: [docs/SPEC/SPEC_ZRPD_EDEV_001_HR.md](SPEC/SPEC_ZRPD_EDEV_001_HR.md)
- DJTL teknik teslim: [docs/DJTL_TEKNIK_TESLIM.md](DJTL_TEKNIK_TESLIM.md)

## 3. Neler Yapildi? (kronolojik)

### Faz 1 — Altyapi (2026-04-06 / 04-07)
- Proje spec'i yazildi (SPEC_ZRPD_EDEV_001_HR — IT0006 ikametgah senaryosu).
- DDIC foundation: 45 abapGit objesi (domain, data element, tablo, search help).
- Tablo isimleri 16-char DB limitine sigacak sekilde kisaltildi (DCTYP->DTYP, DCFLD->DFLD, ...).
- Core layer: 6 exception + 6 interface + sabit class. (Sonradan K1/K3 kapsaminda sadelestirildi.)
- Data Access: 3 repository class, parser katmani (DOC_BASE soyut + DOC_IKA + DOC_FAC).

### Faz 2 — OCR Pipeline (2026-04-07 / 04-08)
- Python tarafi: `ocr_extract.py` — PyMuPDF + Tesseract 5.4.0 ile image-based PDF'ten text cikarma.
- ABAP tarafi: `ZCL_ZRPD_EDEV_OCR_PY` — SXPG ile Python cagrisi (`TYPE sxpgcostab-parameters`, string olmaz).
- Test raporu: `ZRPD_EDEV_R_TEST` (SE38) — PDF yukle, OCR/parse sonucunu ALV'de goster.
- Parser'da 4 farkli ikametgah PDF formati destegi (tablo/blok/pipe/duz metin).
- NBSP (U+00A0), Turkce label, adres slash (13/1) gibi OCR tuzaklari tek tek cozuldu.

### Faz 3 — Kurulum & MCP (2026-04-09 / 04-10)
- `tools/abap-mcp-unified/` submodule eklendi (dassian-adt'in yerine).
- `setup-mcp.sh` — submodule build + `~/.claude/settings.json` otomatik guncelleme.
- Kurulum rehberi: [docs/araclar/kurulum-rehberi.md](araclar/kurulum-rehberi.md).

### Faz 4 — PA30 UI & Sadelestirme (2026-04-11 / 04-12)
- PA30 menu entegrasyonu (Yukle / Goruntule / Sil).
- **K1-K12 retrospektif kurallari** yazildi: [docs/standartlar/yasaklanan-pratikler.md](standartlar/yasaklanan-pratikler.md).
  Preemptive interface/factory, multi-exception, global mock gibi pratikler yasaklandi.
- Mimari sadelestirme: interface'ler kaldirildi (single-use), exception tek class'a indirildi.

### Faz 5 — DJTL Entegrasyonu (2026-04-16)
- **Dispatcher pattern:** `process_command(iv_action)` tek giris — UPLOAD / VIEW / DELETE.
- Subdispatch: `UPLOAD_FROM_FILE`, `UPLOAD_FROM_EDEVLET`.
- DJTL class'i (`ZCL_ZRPD_DJTL_FILE`) **dinamik olarak** cagriliyor — EDEV compile-time bagimli degil.
- `ZRPD_EDEV_T_DTYP` tablosuna `DJTL_ATIP` (NUMC2) ve `INFOTYPE` (NUMC4) alanlari eklendi.
- E2E calisir durumda: dosya yukle -> PA9657 kaydi -> AL11 dosya yazimi.
- DJTL ekibine teslim dokumani: [docs/DJTL_TEKNIK_TESLIM.md](DJTL_TEKNIK_TESLIM.md) (11 bolum, imza + aktivasyon sirasi + test senaryolari).

### Faz 6 — IT0006 F9 Barkod + Session Fix (2026-04-20 / 04-24)
- IT0006 (Adres) infotype'inda **F9 (standart text)** alanina barkod append ediliyor (PCL1 EXPORT/IMPORT `(tx)` pattern'i).
- 78-char satir formati; mevcut barkodlar korunuyor, yeni barkod ayri satir olarak ekleniyor.
- **Kritik fix (023cbca):** DJTL `WRITE_FILE_AND_CREATE_RECORD` cagrisi `IN_UPDATE`'ten `AFTER_INPUT`'a tasindi.
  - Sebep: HR BAdI `IN_UPDATE` ayri update task session'inda calisir, `CLASS-DATA` goremez (pending state kaybolur).
  - Memory kaydi: [feedback_hr_badi_class_data.md](../../../.claude/projects/c--Users-akpin-OneDrive-Masa-st--Yeni-klas-r-edev/memory/feedback_hr_badi_class_data.md).

## 4. Mevcut Durum

### Calisiyor
- PA30 IT0006 uzerinde **UPLOAD** (dosyadan ve e-Devlet'ten) e2e.
- OCR + parser ikametgah icin 4 format destegi.
- F9 barkod append (duplicate korumali).
- DJTL PA9657 + AL11 yazimi (AFTER_INPUT fix sonrasi stabil).

### Acik Isler (tam liste: [docs/planner/kalan-isler.md](planner/kalan-isler.md))

| Oncelik | Kalem |
|---------|-------|
| CRITICAL | DJTL tarafinda `DPSTY` (Alt Tip) set edilmiyor + dosya adinda saat 000000 (2 bug — [TESLIM_DJTL_ENTEGRASYON.md](oturumlar/TESLIM_DJTL_ENTEGRASYON.md)) |
| HIGH | GUI Status refactor — `SET PF-STATUS OF PROGRAM` kirilgan, MP965700 kendi CUA'sina tasinmali |
| MEDIUM | PA30 standart silme -> AL11 sizintisi — `HRPAD00INFTY~IN_UPDATE` BAdI implementasyonu (DJTL tarafinda) |
| LOW | Mezuniyet belgesi parser (DOC_MEZ) — iskelet var, F4 kapsami tamamlanmadi |
| LOW | e-Devlet API (`ZCL_ZRPD_EDEV_EDEVLET`) — SM59/STRUST Basis'ten bekleniyor |

## 5. Onemli Teknik Notlar

- **Tuzaklar:** [CLAUDE.md](../CLAUDE.md) — OCR NBSP, `REPLACE WITH ' '` bos string, Turkce dosya adi.
- **K1-K12 kurallari:** Yeni gelistirmede interface/factory/subclass eklemeden once kontrol edilmeli.
- **Aktivasyon sirasi:** DOMA -> DTEL -> TABL -> CLAS -> ENHO (detay: [docs/mimari/aktivasyon-sirasi.md](mimari/aktivasyon-sirasi.md)).
- **7-faz surec:** Her yeni spec icin — [docs/surec/gelistirme-sureci.md](surec/gelistirme-sureci.md).

## 6. Sistem Referanslari

| Ogelerde | Deger |
|----------|-------|
| SAP Sistem | ER1 (ECC 6.0) |
| Transport | `ER1K900803` — HR: Edevlet paketi |
| Python | `F:\usr\sap\Python38-32\python.exe` |
| Tesseract | `F:\usr\sap\Tesseract-OCR\tesseract.exe` (5.4.0) |
| OCR Script | `F:\usr\sap\edev\ocr_extract.py` |
| SM69 | `Z_EDEV_PY`, `Z_EDEV_OCR` |
