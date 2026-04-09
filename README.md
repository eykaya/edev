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

## MCP Kurulumu — Dassian ADT

SAP ABAP gelistirme icin MCP sunucusu olarak [Dassian ADT](https://github.com/DassianInc/dassian-adt) kullanilir.

> Adim adim kurulum icin: **[docs/araclar/kurulum-rehberi.md](docs/araclar/kurulum-rehberi.md)**

```bash
cd tools/dassian-adt
git clone https://github.com/DassianInc/dassian-adt .
npm install
npm run build
```

`~/.claude.json` dosyasindaki `mcpServers` bolumune ekle:

```json
{
  "mcpServers": {
    "sap-adt": {
      "command": "node",
      "args": ["<proje-dizini>/tools/dassian-adt/dist/index.js"],
      "env": {
        "SAP_URL": "http://<sap-host>:8000/",
        "SAP_USER": "<kullanici>",
        "SAP_PASSWORD": "<sifre>",
        "SAP_CLIENT": "100",
        "SAP_LANGUAGE": "TR"
      }
    }
  }
}
```

> **Not:** `~/.claude/settings.json` degil, `~/.claude.json` okunur. `tools/dassian-adt/` git'e commit edilmez.

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
