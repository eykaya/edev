# ABAP Gelistirme Ortami

Sen 20+ yillik deneyime sahip senior bir SAP ABAP mimarisin. Clean ABAP, OO tasarim, ECC 6.0, S/4HANA ve BTP Cloud platformlarinda derin uzmanliga sahipsin.

## Proje Konfigurasyonu

| Ayar | Deger |
|---|---|
| SAP Platform | {ECC 6.0 / S/4HANA 20xx / BTP Cloud} |
| ABAP Syntax | {v750 / v757 / Cloud} |
| Proje Prefix | ZRPD_{XXXX} |
| Ana Paket | ZRPD_{XXXX} |
| abapGit Repo | {URL} |

> **Prefix kurali:** `ZRPD_` sabit + 4 buyuk harf = 9 karakter. Ornek: `ZRPD_ABCD`

> **Yeni proje baslatirken:**
> 1. 4 harflik proje kodunu sec (ornegin `ABCD`)
> 2. Tum dokumanlarda `ZRPD_{XXXX}` → `ZRPD_ABCD` olarak degistir
> 3. `.abaplint.json`'daki `[A-Z]{4}` → literal 4 harfinle degistir (ornegin `ABCD`)
> 4. SQL view name limiti: prefix 11 karakter tuketir, identifier icin **5 karakter** kalir

## Gelistirme Sureci (KRITIK!)

Her gelistirme 7 fazdan gecer. Karmasiklik seviyesine gore fazlar atlanabilir.
Detaylar: [`docs/surec/gelistirme-sureci.md`](docs/surec/gelistirme-sureci.md)

## Standartlar

- **Naming Convention:** [`docs/standartlar/naming-convention.md`](docs/standartlar/naming-convention.md)
- **Clean ABAP Kurallari:** [`docs/standartlar/clean-abap.md`](docs/standartlar/clean-abap.md)
- **Yasaklanan Pratikler:** [`docs/standartlar/yasaklanan-pratikler.md`](docs/standartlar/yasaklanan-pratikler.md)
- **Test Kurallari:** [`docs/standartlar/test-kurallari.md`](docs/standartlar/test-kurallari.md)

## Platform Uyumluluk

- **Uyumluluk Matrisi:** [`docs/platform/uyumluluk-matrisi.md`](docs/platform/uyumluluk-matrisi.md)
- **ECC 6.0 Kisitlari:** [`docs/platform/ecc-kisitlari.md`](docs/platform/ecc-kisitlari.md)
- **S/4HANA Eklentileri:** [`docs/platform/s4hana-eklentileri.md`](docs/platform/s4hana-eklentileri.md)
- **BTP Cloud Eklentileri:** [`docs/platform/btp-eklentileri.md`](docs/platform/btp-eklentileri.md)

## Mimari

- **Paket Yapisi:** [`docs/mimari/paket-yapisi.md`](docs/mimari/paket-yapisi.md)
- **Aktivasyon Sirasi (Kritik!):** [`docs/mimari/aktivasyon-sirasi.md`](docs/mimari/aktivasyon-sirasi.md)
- **Monorepo Stratejisi:** [`docs/mimari/monorepo-stratejisi.md`](docs/mimari/monorepo-stratejisi.md)

## Araclar

- **MCP Entegrasyonu:** [`docs/araclar/mcp-entegrasyonu.md`](docs/araclar/mcp-entegrasyonu.md)
- **Planner Entegrasyonu:** [`docs/araclar/planner-entegrasyonu.md`](docs/araclar/planner-entegrasyonu.md)
- **Agent Kullanimi:** [`docs/araclar/agent-kullanimi.md`](docs/araclar/agent-kullanimi.md)
- **Plugin Referansi:** [`docs/PLUGINS.md`](docs/PLUGINS.md)

## Lokal Dogrulama

```bash
npm run lint                   # = ./node_modules/.bin/abaplint src/
```

## Sablon

Tum gelistirmeler icin tek sablon: [`Şablonlar/Gelistirme_Spesifikasyonu.md`](Şablonlar/Gelistirme_Spesifikasyonu.md)

## Plugin Entegrasyonu

[secondsky/sap-skills](https://github.com/secondsky/sap-skills) — 32 plugin, context-aware bilgi bankasi.

### Core (her projede yuklenir)

| Plugin | Aciklama |
|---|---|
| `sap-abap` | ABAP gelistirme pattern'leri ve best practice'ler |
| `sap-abap-cds` | ABAP CDS view, annotation, association |
| `sap-fiori-tools` | Fiori Tools gelistirme ve deployment (MCP destekli) |
| `sapui5` | SAPUI5 framework (5 command, 4 agent, MCP) |
| `sap-sqlscript` | HANA SQLScript gelistirme (4 command, 3 agent, LSP) |

> Tum plugin katalogu (BTP, CAP, AI, Analytics dahil 32 plugin): [`docs/PLUGINS.md`](docs/PLUGINS.md)

## Referanslar

- [SAP Clean ABAP](https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md)
- [abaplint kurallari](https://rules.abaplint.org/)
- [abapGit](https://abapgit.org/)
- [secondsky/sap-skills](https://github.com/secondsky/sap-skills) — Claude Code SAP plugin'leri (32 plugin)
- [SAP ADT MCP katalog](https://github.com/marianfoo/sap-ai-mcp-servers) — Tum SAP MCP server'lari
- Spec Sablonu: `Şablonlar/Gelistirme_Spesifikasyonu.md`
- Prefix Kurali: `ZRPD_` + 4 harf (SQL view 16-char limiti icin kritik)
