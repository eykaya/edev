# Clean ABAP Kurallari

← [CLAUDE.md](../../CLAUDE.md)

## Temel Ilkeler

1. **OO-first:** Tum is mantigi siniflarda, report'lar sadece UI katmani
2. **Arayuz bazli tasarim:** Her bagimlilik bir arayuz uzerinden
3. **Constructor injection:** DI container yok, constructor'dan gec
4. **Keyword case:** lowercase (`data`, `methods`, `class`, `endclass`)
5. **Satir uzunlugu:** Maksimum 120 karakter
6. **Method uzunlugu:** Maksimum 100 statement
7. **Cyclomatic complexity:** Maksimum 20
8. **Nesting depth:** Maksimum 5

## Kod Yazim Felsefesi

9. **Kisa ve okunabilir kod:** Mumkun olan en kisa kodu yaz, ama okunabilirligi feda etme. Gereksiz degisken, gereksiz IF, gereksiz intermediate step olmasin. Inline expression'lari (`VALUE #`, `CORRESPONDING #`, `COND #`, `FOR ... IN`) okunabilir kaldigi surece tercih et.

10. **Once derle, sonra isle (Fetch-First pattern):**
    - Method/program basinda **tum DB erisimlerini yap**, ihtiyacin olan veriyi topla
    - Sonra bellekte isle (donusum, validasyon, hesaplama)
    - DB'ye **mumkun oldugunca az git** — tek SELECT ile alabilecegini iki SELECT'e bolme
    - Loop icinde SELECT **kesinlikle yasak** (bkz. Yasaklanan Pratikler)

11. **SELECT disiplini:**
    - `SELECT *` kullanma — sadece ihtiyac duyulan alanlari sec
    - `INTO TABLE` kullan, `ENDSELECT` kullanma
    - WHERE kosulunda index/key alanlari kullan
    - Buyuk veri setlerinde `PACKAGE SIZE` dusun
    - Join tercih et, nested SELECT yapma

12. **Tablo ve key alan tasarimi:**
    - Key alanlar tablonun en kritik karari — performans, veri butunlugu ve erisim patterni burada belirlenir
    - Yeni tablo tasarlarken kullaniciya sorular sorarak en verimli key yapisini belirle:
      - Hangi alanlarla arama yapilacak?
      - Tekil kayit nasil tanimlanir?
      - Hangi kombinasyonlar unique olmali?
    - Fazla key alan performansi dusurur, eksik key alan veri tutarsizligi yaratir
    - Secondary index ihtiyacini bastan degerlendir

## Referans

- [SAP Clean ABAP](https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md)
- [abaplint kurallari](https://rules.abaplint.org/)
