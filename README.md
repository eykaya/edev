# ABAP Gelistirme Ortami

SAP ABAP gelistirme sablonu — Clean ABAP, OO tasarim, ECC 6.0 / S/4HANA / BTP Cloud destegi.

## On Kosullar

- Node.js (abaplint icin)
- SAP ADT baglantisi (MCP deployment icin)
- abapGit (SAP <-> GitHub senkronizasyonu icin)

## Hizli Baslangic

```bash
git clone <repo-url>
cd <repo>
npm install
cp .env.example .env          # SAP bilgilerini doldur
npm run lint                   # abaplint calistir
```

## MCP Kurulumu

SAP ABAP gelistirme icin MCP sunucusu olarak [abap-mcp-unified](https://github.com/aaeren/abap-mcp-unified) kullanilir.
`tools/abap-mcp-unified/` git submodule olarak dahil edilmistir.

```bash
git clone <repo-url>
cd <repo>
cp .env.example .env          # SAP bilgilerini doldur
bash tools/setup-mcp.sh       # submodule build + settings.json otomatik guncellenir
```

Script su islemleri yapar:
1. `git submodule update --init` — submodule'u indirir
2. `npm install && npm run build` — MCP server'i derler
3. `~/.claude/settings.json` — `mcpServers` blogunu otomatik ekler (.env'den okur)

Sonra Claude Code'u yeniden baslatmak yeterli.

## Dizin Yapisi

```
├── CLAUDE.md                  AI-destekli gelistirme kilavuzu (hub)
├── docs/
│   ├── surec/                 Gelistirme sureci (7-faz workflow)
│   ├── standartlar/           Naming, Clean ABAP, test kurallari
│   ├── platform/              ECC / S/4HANA / BTP uyumluluk
│   ├── mimari/                Paket yapisi, aktivasyon, monorepo
│   ├── araclar/               MCP entegrasyonu, agent kullanimi
│   ├── PLUGINS.md             SAP Skills plugin katalogu
│   └── SPEC/                  Gelistirme spesifikasyonlari (cikti)
├── Sablonlar/
│   └── Gelistirme_Spesifikasyonu.md   Birlesik FS+TS sablonu
├── src/                       ABAP kaynak kodu (abapGit formatinda)
├── tools/                     MCP server araclari
├── .abaplint.json             Lint konfigurasyonu
├── .abapgit.xml               abapGit repo konfigurasyonu
└── .mcp.json                  MCP server tanimlari
```

## Gelistirme

Tum gelistirmeler [CLAUDE.md](CLAUDE.md)'deki 7-faz surecini takip eder.
Yeni spec baslatmak icin: [`Sablonlar/Gelistirme_Spesifikasyonu.md`](Şablonlar/Gelistirme_Spesifikasyonu.md)

## Referanslar

- [SAP Clean ABAP](https://github.com/SAP/styleguides/blob/main/clean-abap/CleanABAP.md)
- [abaplint](https://rules.abaplint.org/)
- [abapGit](https://abapgit.org/)
- [secondsky/sap-skills](https://github.com/secondsky/sap-skills) — Claude Code SAP plugin'leri
