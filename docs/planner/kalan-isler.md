# Kalan Isler — Sonraki Oturum Planlari

> Her is karti bagimsiz bir oturumda alinabilecek sekilde yazilmistir.
> Oncelik sirasi bagimlilik zincirini yansitir — ust sira bitmeden alt sira baslamamali.

---

## Oturum A: Parser Iyilestirme + OCR Performans

**Amac:** OCR hizini artir, eksik alanlari duzelt.

### A1. OCR Performans
- **Sorun:** Tesseract 300 DPI ile ~5-8 sn suruyor
- **Cozum:** DPI 200'e dusur, sadece ust yarisini crop et (adres+kimlik bilgileri ust yarida)
- **Dosya:** `F:\usr\sap\edev\ocr_extract.py` (sunucudaki script)
- **Test:** `ZRPD_EDEV_R_TEST` ile sure olcumu

### A2. Barkod Tanima
- **Sorun:** PDF 4 (KADIR MELIH) barkod bos donuyor — OCR barkod satirini okuyamiyor
- **Cozum:** Barkod genellikle sayfanin ust 1/4'unda. O bolgeyi ayri crop edip OCR yap. Alternatif: `pyzbar` ile direkt barkod decode
- **Test:** 4 farkli PDF ile barkod cikarma

### A3. Adres No Fallback
- **Sorun:** `|` olmayan belgelerde (PDF 1) adres no bos
- **Cozum:** OCR metninde `\d{10}` pattern ara (adres no her zaman 10 haneli sayi)
- **Dosya:** `ocr_extract.py` parse() fonksiyonu

### A4. Ad Soyad Temizleme
- **Sorun:** Bazi belgelerde basinda `!` veya `:` kaliyor
- **Mevcut fix:** `re.sub(r"^[!:;\s]+", "", adi)` — calisiyor ama daha robust olmali

---

## Oturum B: e-Devlet API Entegrasyonu

**Amac:** Barkod + TCKN ile belge gecerliligini dogrula.

### B1. ZCL_ZRPD_EDEV_EDEVLET Class
- **Interface:** `ZIF_ZRPD_EDEV_EDEVLET` (zaten mevcut, `verify` metodu)
- **Spec:** `docs/SPEC/SPEC_ZRPD_EDEV_001_HR.md` section 3.6.1
- **Endpoint:** `https://m.turkiye.gov.tr/api.php?p=belge-dogrulama&qr=barkod:{BC};tckn:{TCKN};`
- **SM59:** `ZRPD_EDEV_EDEVLET` destination tanimlanmali
- **HTTP Client:** `ZCL_ZRPD_EDEV_HTTP` (EGOV referans: `zcl_zrpd_egov_ai_http.clas.abap`)
- **Retry:** 3x ustelden bekleme (T_PARM: API_RETRY_COUNT=3, API_RETRY_BASE_WAIT=2)

### B2. SM59 + STRUST Kurulumu
- **SM59:** ZRPD_EDEV_EDEVLET destination (HTTPS, turkiye.gov.tr)
- **STRUST:** TLS 1.2+ kok sertifikasi yuklemesi gerekir
- **Not:** Kullanicinin (Emre) Basis ekibinden istenmeli

---

## Oturum C: Orchestrator + IT0006 Mapper

**Amac:** Tum pipeline'i birlestir: upload -> OCR -> parse -> verify -> map -> HR kayit.

### C1. ZCL_ZRPD_EDEV_DOC_MGR
- **Interface:** `ZIF_ZRPD_EDEV_DOC_MGR` (mevcut — 8 metod)
- **Spec:** Section 4.3 class listesi, constructor injection pattern
- **Constructor:** io_doc_repo, io_cust_repo, io_edevlet, io_ocr_svc, io_llm_api, io_logger, io_it_map
- **upload metodu akisi:**
  1. Girdi dogrulama (V-001..V-004)
  2. PDF kaydet (DOC_REP.save)
  3. OCR calistir (OCR_PY.extract_text)
  4. JSON parse et (/UI2/CL_JSON)
  5. TCKN/barkod dogrula
  6. e-Devlet verify (EDEVLET.verify)
  7. IT0006 esle (IT_MAP)
  8. Tum adimlari logla (LOGGER)
- **Referans:** EGOV `zcl_zrpd_egov_doc_prc` (step_01..step_06 pattern)

### C2. ZCL_ZRPD_EDEV_IT_MAP
- **Gorev:** Cikartilan alanlari IT0006 Subtype 1 alanlarına esle
- **Spec:** Section 3.3 (SAP Hedef Eslestirme)
- **T_DMAP kurallari:** DIRECT, DATE_CONVERT, UPPER, LOOKUP_IL, LOOKUP_CNTRY
- **BAPI:** HR_INFOTYPE_OPERATION (INFTY=0006, SUBTYPE=1, OPERATION=INS/MOD)
- **Mevcut IT0006:** End-date (ENDDA=bugun-1) + yeni kayit (MOD+INS pattern)

---

## Oturum D: UI Raporlari

**Amac:** Son kullanici arayuzu — PDF yukle, sonuc gor, belge listele.

### D1. ZRPD_EDEV_R_UPLOAD (Production)
- **Fark:** Test raporundan farkli — DOC_MGR uzerinden tam pipeline calistirir
- **Selection screen:** PERNR (zorunlu, F4), DOC_TYPE (zorunlu, F4->T_DTYP), FILE_PATH
- **Akis:** GUI_UPLOAD -> DOC_MGR.upload -> sonuc ekrani (cikartilan degerler + onay)
- **Spec:** Section 3.7

### D2. ZRPD_EDEV_R_LIST
- **Selection screen:** PERNR (zorunlu)
- **Cikti:** ALV Grid (DOC_REP.find_by_pernr)
- **Aksiyonlar:** Belge sec -> PDF indir (GUI_DOWNLOAD)
- **Spec:** Section 3.7

### D3. Transaction Kodlari
- ZRPD_EDEV_UPLOAD -> ZRPD_EDEV_R_UPLOAD
- ZRPD_EDEV_LIST -> ZRPD_EDEV_R_LIST

---

## Oturum E: Test + Mock + Customizing

### E1. Mock Class'lar (TEST paketi)
- ZCL_ZRPD_EDEV_MK_DREP (implements ZIF_DOC_REPO — in-memory tablo)
- ZCL_ZRPD_EDEV_MK_CREP (implements ZIF_CUST_REPO — sabit degerler)
- ZCL_ZRPD_EDEV_MK_EDVL (implements ZIF_EDEVLET — her zaman verified)
- ZCL_ZRPD_EDEV_MK_EXTS (implements ZIF_EXT_SVC — sabit JSON donusu)

### E2. Unit Test
- DOC_MGR test class (constructor injection ile mock'lar)
- IT_MAP test class (T_DMAP kurallari ile eslestirme)
- Target: coverage >= 90%

### E3. Customizing Initial Data
- T_DTYP: IKAMETGAH belge tipi (ACTIVE=X, VERIFY_METHOD=EDEVLET)
- T_DFLD: 10 alan tanimi (tckn, barcode, full_name, ...)
- T_DMAP: IT0006 eslestirme kurallari (street->STRAS, city->ORT01, ...)
- T_PARM: API_TIMEOUT=30, API_RETRY_COUNT=3, MAX_FILE_SIZE=10, DOC_VALIDITY_DAYS=90

---

## Oturum F: Deployment + Go-Live

### F1. DDIC Tamamlama
- Lock object: EZRPD_EDEV_T_DOC (abapGit ile basarisiz — manuel olusturulmali)
- Yetki objesi: ZRPD_EDEV_DOC (ACTVT + DOC_TYPE)
- SM30 bakim gorunumleri: T_DTYP, T_DFLD, T_DMAP, T_PARM, T_CTRY

### F2. Transport
- Transport: ER1K900803
- Tum nesnelerin TR'de oldugunu dogrula (transport_contents)
- QAS'a release + test
- PRD'ye release

---

## Teknik Notlar (Sonraki Oturum Icin)

**Deploy yontemi:**
- ABAP class'lar: abapGit push + pull (implementation'lar bos gelirse Eclipse Ctrl+F3)
- Alternatif: ADT `abap_set_source` + `raw_http preauditRequested=false` ile aktive
- Program (PROG): ADT ile yazilip aktive edilebilir (class'lardan farkli, calisiyor)
- Python script: `OPEN DATASET` + `TRANSFER` ile sunucuya yazilir

**SAP Sunucu bilgileri:**
- Host: EYKHRNSAP, OS: Windows NT
- Python: F:\usr\sap\Python38-32\python.exe (3.8.5)
- Tesseract: F:\usr\sap\Tesseract-OCR\tesseract.exe (5.4.0)
- SM69: Z_EDEV_PY, Z_EDEV_OCR
- Transport: ER1K900803, ZEKI task: ER1K900805
