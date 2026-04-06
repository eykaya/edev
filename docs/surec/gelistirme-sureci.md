# Gelistirme Sureci (KRITIK!)

← [CLAUDE.md](../../CLAUDE.md)

Her gelistirme asagidaki 7 fazdan gecer. Karmasiklik seviyesine gore bazi fazlar atlanabilir (bkz. Karmasiklik Seviyeleri).

## Faz 1: Kapsam ve Amac
- Kullanicidan is gereksinimi alinir
- Mevcut surec (As-Is) ve hedef surec (To-Be) tanimlanir
- Kapsam icinde / disinda netlenir
- **Cikti:** Spec dokumaninin Faz 1 bolumu doldurulur
- **Planner:** Kart Backlog bucket'inda olusturulur

## Faz 2: Kavramsal Tasarim
- `sap-architect` agent ile cozum mimarisi cikarilir
- `planner` agent ile is kirilimi ve kart yapisi belirlenir
- Modul etkilesimleri, entegrasyon noktalari, teknoloji secimleri belirlenir
- **Cikti:** Spec dokumaninin Faz 2 bolumu doldurulur
- **Planner:** Kart Design bucket'ina tasinir
- **GATE 1: Kavramsal Tasarim Onayi** — mimari karar onaylanir

## Faz 3: Fonksiyonel Spesifikasyon
- `doc-writer` agent ile fonksiyonel detaylar yazilir
- Veri alanlari, mapping, dogrulama kurallari, yetkilendirme
- Fiori ise: UI tasarimi, entity gereksinimleri, value help
- **Cikti:** Spec dokumaninin Faz 3 bolumu doldurulur

## Faz 4: Teknik Spesifikasyon
- `doc-writer` agent ile teknik nesneler tanimlanir
- Tablo, class, interface, CDS, FM, enhancement tanimlari
- Algoritma, is mantigi (pseudocode), hata yonetimi, performans
- **Cikti:** `docs/SPEC/SPEC_ZRPD_{XXXX}_{NNN}_{MODUL}.md`
- **GATE 2: Spesifikasyon Onayi** — onay olmadan kodlamaya gecilmez

## Faz 5: Kodlama ve Test (TDD)
- Once `abap-tester` ile test kodu yazilir (RED)
- `abap-developer` / `fiori-developer` ile uygulama kodu yazilir (GREEN)
- Refactor ve coverage hedefleri karsilanir (IMPROVE)
- `abap-reviewer` her Write/Edit sonrasi otomatik review yapar
- MCP ile SAP'a deploy: `abap_set_source` -> `abap_activate` -> `abap_run` (unit test)
- **Cikti:** Calisan kod + basarili testler (lokal + SAP)
- **Planner:** Kart In Progress bucket'ina tasinir

## Faz 6: Review ve Dogrulama
- `abap-reviewer` ile kapsamli kod review
- `performance-optimizer` ile performans analizi
- Guvenlik review (hardcoded credential, SQL injection, authority)
- abaplint hatasiz gecmeli
- **Cikti:** Review raporu, tum CRITICAL/HIGH bulgular kapatilmis
- **Planner:** Kart Review bucket'ina tasinir
- **GATE 3: Review Onayi** — onay olmadan deployment'a gecilmez

## Faz 7: Deployment
- MCP ile: `transport_create` -> `transport_assign` -> `transport_release`
- GitHub repo'ya push yapilir
- **Cikti:** Transport released, SAP QAS/PRD'ye tasindi
- **Planner:** Kart Done bucket'ina tasinir + `planner-sync` impact analizi

## Karmasiklik Seviyeleri

| Seviye | Kriter | Gerekli Fazlar | Spec |
|---|---|---|---|
| **Micro** | < 1 saat, tek obje, bugfix/config | Yok | Commit mesajinda `[MICRO]` etiketi |
| **Small** | 1-8 saat, < 5 obje | Faz 1 + 4 + 5 | Lightweight spec (sadece Faz 1 ve 4) |
| **Medium/Large** | > 8 saat veya > 5 obje | Tam 7 faz | Tam spec |

**Karar agaci:**
1. Tek obje bugfix/config mi? -> **Micro** (spec yok, commit mesajinda `[MICRO]` etiketi)
2. < 5 obje, < 8 saat tahmin? -> **Small** (lightweight spec, Gate 2 ve Gate 3 birlesik)
3. > 5 obje veya > 8 saat? -> **Medium/Large** (tam 7-faz akisi)

## Sablon

Tum gelistirmeler icin tek sablon kullanilir: `Şablonlar/Gelistirme_Spesifikasyonu.md`

Fiori'ye ozel bolumler `> Fiori ise bu bolumu doldurun` ile isaretlenmistir.
Backend gelistirmeler bu bolumleri `Uygulanmaz` olarak isaretler.

## Spec Dokumani Kurali
- Dokumana bakan **herhangi bir gelistirici**, ne zaman bakarsa baksin, yapilacak isi **eksiksiz anlayabilmeli ve uygulayabilmelidir**
- Tek dokuman, tek kaynak: FS ve TS ayri dosyalara bolunmez
- 3 onay kapisi (Gate) icin onay kaydi tutulur (Ek-C)
