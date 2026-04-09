# Ikametgah Parser Test Senaryolari

Bu dosya `ZCL_ZRPD_EDEV_DOC_IKA` parser'inin regresyon testleri icin kullanilir.
Her fix oncesi bu 4 senaryo gecmelidir.

OCR text dosyalari SAP sunucuda: `F:\usr\sap\edev\{test,ik4,ik5,ik7}_text.txt`

---

## Senaryo 1: GIZEM KORKMAZ

**Dosya:** test.pdf / test_text.txt
**Format:** Label-based (Kimlik No : deger)
**Ozellik:** Klasik 2-satir adres, cift NO (bina + ic kapi)

| Alan | Beklenen |
|------|----------|
| tc_kimlik_no | 45337404886 |
| barkod | (bos) |
| ad_soyad | GIZEM KORKMAZ |
| adres_no | 2467013534 |
| mahalle | YAVUZTURK |
| cadde | (bos) |
| sokak | PAZAR |
| site_apartman | (bos) |
| blok | (bos) |
| bina_no | 23 |
| ic_kapi_no | 3 |
| ilce | USKUDAR |
| il | ISTANBUL |
| belge_tarihi | 20251120 |

---

## Senaryo 2: KADIR MELIH YILDIZ

**Dosya:** ik4.pdf / ik4_text.txt
**Format:** Label-based (farkli OCR layout)
**Ozellik:** INSAAT keyword (site_apartman yok), BLOK fallback, 3-satir adres, `/` satir sonunda

| Alan | Beklenen |
|------|----------|
| tc_kimlik_no | 61243335502 |
| barkod | (bos) |
| ad_soyad | KADIR MELIH YILDIZ |
| adres_no | 2543859421 |
| mahalle | ADNAN KAHVECI |
| cadde | (bos) |
| sokak | DEFNE |
| site_apartman | (bos) |
| blok | A |
| bina_no | 3 |
| ic_kapi_no | 3 |
| ilce | BEYLIKDUZU |
| il | ISTANBUL |
| belge_tarihi | 20240121 |

---

## Senaryo 3: EMRE YALCINKAYA

**Dosya:** ik5.pdf / ik5_text.txt
**Format:** Tablo (OCR sirasi bozuk)
**Ozellik:** NBSP bosluklar, RESIDENCE + BLOK, alfanumerik bina_no (11A), `/ ` satir sonunda

| Alan | Beklenen |
|------|----------|
| tc_kimlik_no | 14879334616 |
| barkod | NV02-IYF8-5YN7-KVK4 |
| ad_soyad | EMRE YALCINKAYA |
| adres_no | 3147720498 |
| mahalle | UGUR MUMCU |
| cadde | SAFAHAT |
| sokak | (bos) |
| site_apartman | TEKNIKYAPI UPCITY RESIDENCE SITESI |
| blok | A |
| bina_no | 11A |
| ic_kapi_no | 34 |
| ilce | KARTAL |
| il | ISTANBUL |
| belge_tarihi | 20260331 |

> Not: Turkce karakter kiyaslamasi yapilmaz (OCR Turkce/ASCII karisik uretir).
> Kiyaslama to_upper + Turkce-insensitive olmalidir.

---

## Senaryo 4: KUBILAY KAAN SAHIN

**Dosya:** ik7.pdf / ik7_text.txt
**Format:** Tablo (OCR sirasi bozuk)
**Ozellik:** NBSP bosluklar, bina_no icinde slash (13/1), tek NO (ic kapi yok)

| Alan | Beklenen |
|------|----------|
| tc_kimlik_no | 53284702146 |
| barkod | NV02-5ZDH-2TPV-IRWL |
| ad_soyad | KUBILAY KAAN SAHIN |
| adres_no | 1183954666 |
| mahalle | CAMCESME |
| cadde | (bos) |
| sokak | BAYBURT |
| site_apartman | (bos) |
| blok | (bos) |
| bina_no | 13/1 |
| ic_kapi_no | (bos) |
| ilce | PENDIK |
| il | ISTANBUL |
| belge_tarihi | 20260409 |

---

## Test Calistirma

### abap_run ile (hizli)
SAP'de `abap_run` ile 4 text dosyasini okuyup parse et, beklenen sonuclarla karsilastir.

### R_TEST ile (manuel)
Eclipse'ten `ZRPD_EDEV_R_TEST` (SE38) calistir, PDF sec, sonuclari yukardaki tablolarla karsilastir.
