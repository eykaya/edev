# Paket Yapisi Sablonu

← [CLAUDE.md](../../CLAUDE.md)

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
