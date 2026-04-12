# Yasaklanan Pratikler

← [CLAUDE.md](../../CLAUDE.md)

- **FORM/PERFORM kullanma** — sadece sinif ve metod
- **SELECT ... ENDSELECT kullanma** — INTO TABLE kullan
- **SELECT * kullanma** — sadece ihtiyac duyulan alanlari sec
- **Loop icinde SELECT kullanma** — once toplu veri cek, sonra isle
- **Hardcoded credential** — SM59 veya SSF kullan
- **Global DATA kullanma** — sinif attribute veya local variable
- **SY-SUBRC kontrolunu atlama** — her DB/BAPI cagrisindan sonra kontrol et
- **Spec olmadan kod yazma** — her gelistirme Gelistirme Spesifikasyonu ile baslar

---

## EDEV Retrospektif Kurallar (K1-K12)

ZRPD_EDEV projesi sirasinda ogrenilen dersler. Gelecek projelerde ayni hatalari tekrarlamamak icin:

### Mimari

- **K1: Single-use interface yasak** — Tek bir concrete implementation icin interface olusturma. Interface sadece 2+ implementasyon veya test double gerektiren durumlarda kullan. EDEV ornegi: 8 interface yaratildi, hepsi tek impl icindi — hepsi silindi.
- **K2: Preemptive factory yasak** — Tek belge tipi varken factory class olusturma. Factory sadece runtime'da tip secimi gerektiginde (3+ alt sinif) kullan. EDEV ornegi: DOC_FAC tek tip (`IKAMETGAH`) icin yaratildi, hic kullanilmadi.
- **K3: Exception konsolidasyonu** — 3'ten fazla domain exception olusturma. Tek base exception + msgno ile tip ayirt et. EDEV ornegi: 6 exception → 1 `zcx_zrpd_edev` oldu.
- **K5: Flat-by-default package** — Sub-package olusturmadan once sorgu: "Bu sub-package 5+ obje icerecek mi?" Hayirsa flat tut. EDEV ornegi: 7 sub-package (bazilari 1-2 obje) → tek flat paket.

### Kod Kalitesi

- **K4: Mock = local test class** — Test double'lar icin ayri CLAS objesi olusturma. `FOR TESTING` blogu icerisinde local class olarak tanimla. EDEV ornegi: 8 mock class global obje olarak olusturuldu — hepsi silindi.
- **K6: DDIC + kod cift-bagi** — Her hardcode degeri (`'0006'`, `'STRAS'`) uyarlama tablosunda (T_DMAP, T_DFLD) kontrol et. Eger tabloda varsa kodu tabloya bagla, yoksa const kullan. EDEV ornegi: infotype/field/subtype literalleri hardcode idi → T_DMAP-driven dynamic assign'a cevrildi.
- **K7: Hardcode vs. tablo paralel yasak** — Ayni deger hem kodda sabit hem tabloda kayit olarak bulunmamali. Tek kaynak sec. Parser ic literalleri (regex, label) tolere edilir — cunku bunlar parser'in "ne ariyorum" bilgisi, uyarlama degil.
- **K9: Dead code 1-sprint kurali** — Kullanilmayan kod en gec 1 sprint icinde silinir. "Belki lazim olur" gerekce degildir — git history'den geri alinabilir. EDEV ornegi: dead class'lar aylardir kullanilmiyordu.

### PA30 Entegrasyonu

- **K8: Orchestrator wire-up zorunlu** — Yeni is akisi class'i yazildiginda, BAdI impl class'i veya FORM EXIT'den cagri olmadan "tamamlandi" denemez. EDEV ornegi: DOC_MGR orchestrator yazildi ama BD_IUI'den bypass edildi — sadece mock'larda kullaniliyordu.
- **K10: Dynamic ASSIGN validator** — `ASSIGN COMPONENT ... OF STRUCTURE` kullanan her metotta `SY-SUBRC = 4` kontrol et ve log yaz. Sessiz fail field mapping hatalarini gizler.
- **K11: PA30 state icin class-data** — PA30 PBO/PAI arasinda veri tasimak icin class-data (static) kullan, memory ID veya global degisken degil. EDEV ornegi: `gs_pending` class-data pattern ile calisiyor.
- **K12: SAP-only nesne uyarisi** — ENHO, CUA status, BAdI impl gibi SAP-only nesneler abapGit pull ile local'e alinir. MCP/tool sync bunlari yakalayamaz. Refactor oncesi mutlaka SE38 pull yapilmali.
