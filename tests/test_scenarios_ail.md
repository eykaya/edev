# PA0021 Aile Belgesi (Nüfus Kayıt Örneği) Parser Test Senaryoları

`ZCL_ZRPD_EDEV_DOC_AIL` parser sınıfının `parse_fields` çıktısı için referans senaryolar. Her senaryo değişikliğinden ÖNCE bu listenin tamamı yeşil olmalı (mevcut `IKA` parserdaki uygulama gibi).

Test data: e-Devlet "Nüfus Kayıt Örneği" PDF'leri. Belge formatı:
```
SIRA | BSN | C | YAKINLIK DERECESİ | T.C. KİMLİK NO | ADI | SOYADI | BABA ADI | ANA ADI | DOĞUM YERİ VE TARİHİ | MED.HALİ VE DİNİ | TESCİL TARİHİ | OLAYLAR VE TARİHLERİ
```
Bir aile bireyi 3-4 fiziksel OCR satırına yayılmış (multi-line cell).

## Genel Kurallar

- **Kendisi** satırı her zaman atlanır (PA0021'e yazılmaz). Parser çıktısında `row_*__yakinlik = 'KENDISI'` olan satır YOKtur.
- Yakınlık değerleri normalize edilir (Türkçe → ASCII): `'Eşi'` → `'ESI'`, `'Kızı'` → `'KIZI'`, `'Oğlu'` → `'OGLU'`.
- Cinsiyet: 'E' → `fasex='1'`, 'K' → `fasex='2'`.
- Doğum tarihi `dd.mm.yyyy` → DATS `YYYYMMDD`.
- Compound ad ('İNCİ SERA', 'AYŞE GÜL') boşluklı korunur.

## Senaryolar

### Senaryo 1 — Ana belge (Eş + 1 Çocuk, [docs/belge.pdf](../docs/belge.pdf))

ELIF (Kendisi, atlanır), ERKAN (Eşi), İNCİ SERA (Kızı).

**Beklenen çıktı:**

| field_name | value | confidence |
|---|---|---|
| barkod | NV01-3ZF4-BJ52-XRXJ | 100.00 |
| row_1__yakinlik | ESI | 100.00 |
| row_1__erbnr | 22750235006 | 100.00 |
| row_1__favor | ERKAN | 100.00 |
| row_1__fanam | BEK | 100.00 |
| row_1__fasex | 1 | 100.00 |
| row_1__fgbdt | 19960206 | 100.00 |
| row_1__fgbot | BAKIRKÖY | 100.00 |
| row_2__yakinlik | KIZI | 100.00 |
| row_2__erbnr | 74320063588 | 100.00 |
| row_2__favor | İNCİ SERA | 100.00 |
| row_2__fanam | BEK | 100.00 |
| row_2__fasex | 2 | 100.00 |
| row_2__fgbdt | 20250923 | 100.00 |
| row_2__fgbot | BAKIRKÖY | 100.00 |

### Senaryo 2 — Sadece Eş

Kendisi (atlanır) + Eşi (1 satır), çocuk yok.

**Beklenen çıktı:** 1 row, `row_1__yakinlik='ESI'`. SUBTY=2 INS akışında `apply_vals_to_p0021` 0 row döner → "Eşi için PA0021 kaydı mevcut" mesajı (BAdI tarafı; parser değil).

### Senaryo 3 — 3 Çocuk + 1 Eş (varsayımsal)

Kendisi (atlanır) + Eşi + 3 çocuk = 4 row. Test verisi `tests/fixtures/ail_es_3cocuk.txt` (OCR text dump) hazırlanmalı.

**Beklenen çıktı:** `row_1`..`row_4`, sırasıyla ESI, KIZI/OGLU, KIZI/OGLU, KIZI/OGLU.

### Senaryo 4 — Tüm çocuklar zaten kayıtlı

Belge 2 çocuk içeriyor; her ikisi de PA0021 SUBTY=2'de aktif kayıtlı (ERBNR match).

**Beklenen davranış:** Parser her zaman tüm satırları döner (parser SUBTY-aware değil). BAdI tarafı `apply_vals_to_p0021` duplicate kontrolünden sonra `lt_remaining` boş bulur → ekrana yazma yok, info mesajı `'Personelin tüm çocukları için 21 bilgi tipinde kayıt bulunuyor'`.

### Senaryo 5 — Eş zaten kayıtlı + 1 yeni çocuk

Belge: Kendisi + Eşi + 1 çocuk. Eş ERBNR PA0021 SUBTY=1'de aktif kayıtlı; çocuk yeni.

**Beklenen davranış (BAdI tarafı):**
- SUBTY=1 INS → "Eşi için PA0021 kaydı mevcut" mesajı, ekran dolmaz
- SUBTY=2 INS → çocuk satırı dynpro'ya yazılır, normal SAVE akışı

## Bilinen OCR Tuzakları

| Tuzak | Çözüm |
|---|---|
| Tesseract NBSP (U+00A0) ekler | `parse_fields` başında `cl_abap_conv_in_ce=>uccp('00A0')` ile `\| \|` (string template) ile değiştir |
| `replace ... with ' '` literal char trim'lenir | `lv_repl type string = \| \|` kullan |
| `lv_a && ' ' && lv_b` compound ad'da boşluksuz birleşir | `\|{ lv_a } { lv_b }\|` template kullan |
| OCR'da Türkçe karakter bozulması ('İ' → 'l') | `tr_to_ascii` helper ile normalize |
| Tablo bitiş başlığı (`BSN ADI DÜŞÜNCELER`) `BSN` içerebilir | `find_table_bounds`'da sadece `DUSUNCELER` tek başına yeterli |

## Uygulama Test'leri

`ZCL_ZRPD_EDEV_DOC_AIL` testclasses include'da 11 ABAP Unit testi mevcut. `mcp__sap-adt__abap_unit_test` ile çalıştır:

| Test | Doğrulama |
|---|---|
| `GET_DOC_TYPE_RETURNS_AILE` | Doc type sabiti |
| `VALIDATE_CONTENT_POS` | Pozitif validate |
| `VALIDATE_CONTENT_NEG` | KIMLIK belgesi reddediliyor |
| `PARSE_FIELDS_BARKOD` | Barkod çıkarımı |
| `PARSE_FIELDS_KENDISI_ATLANIR` | Kendisi row YOK |
| `PARSE_FIELDS_ES_SATIRI` | Eş alanları doğru |
| `PARSE_FIELDS_KIZI_SATIRI` | Kızı alanları doğru |
| `NBSP_SEPARATOR_HANDLED` | NBSP temizliği |
| `GENDER_VARIANT_K_RETURNS_2` | K → '2' |
| `COMPOUND_AD_PARSE_DOGRU` | İNCİ SERA boşluklı |
| `DUSUNCELER_TABLE_END_DETECTED` | DÜŞÜNCELER sonrası satır row'a girmez |
