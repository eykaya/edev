# Paket Yapisi Sablonu

← [CLAUDE.md](../../CLAUDE.md)

## Varsayilan: Flat Paket (K5)

Yeni projelerde **flat paket** ile basla. Sub-package olusturmadan once sorgu:
- Bu sub-package 5+ obje icerecek mi?
- Farkli gelistirme ekipleri ayri alanlarda calisacak mi?
- Build/deploy ayrimina ihtiyac var mi?

Hicbiri gecerli degilse → flat tut.

```
ZRPD_{XXXX}/                  (Tek flat paket)
├── package.devc.xml
├── zcl_zrpd_{xxxx}.clas.*     Orchestrator
├── zcl_zrpd_{xxxx}_*.clas.*   Is mantigi class'lari
├── zcx_zrpd_{xxxx}.clas.*     Tek exception class
├── zrpd_{xxxx}_*.tabl.xml     DDIC tablolari
├── zrpd_{xxxx}_*.doma.xml     Domain'ler
├── zrpd_{xxxx}_*.dtel.xml     Data element'ler
├── zrpd_{xxxx}_m.msag.xml     Message class
└── zrpd_{xxxx}_r_*.prog.*     Report'lar
```

## Buyuk Proje: Sub-Package (10+ class gerektiren projeler)

```
ZRPD_{XXXX}                  (Yapisal ana paket)
+-- ZRPD_{XXXX}_CORE          Arayuzler, exception'lar, tipler, sabitler
+-- ZRPD_{XXXX}_CUST          Uyarlama tablolari, SM30 view'lari, IMG
+-- ZRPD_{XXXX}_DATA          Veri erisim katmani (DB islemleri, repository'ler)
+-- ZRPD_{XXXX}_LOGIC         Is mantigi katmani
+-- ZRPD_{XXXX}_API           Dis API entegrasyonlari (HTTP, RFC)
+-- ZRPD_{XXXX}_UI            Transaction'lar, ekranlar, ALV
+-- ZRPD_{XXXX}_FIORI         CDS, OData, annotation'lar (uygulanabilirse)
+-- ZRPD_{XXXX}_TEST          Test double'lar, mock'lar, test yardimcilari
```

> **EDEV ornegi:** 30+ obje ile baslandi ama cogu dead code idi. Sadelestirme sonrasi 5 class + 1 exception + DDIC = flat paket yeterli.
