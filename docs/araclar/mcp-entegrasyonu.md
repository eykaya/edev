# MCP Entegrasyonu

← [CLAUDE.md](../../CLAUDE.md)

Tum MCP server'lar `settings.json`'da tanimli. SAP ADT baglantisi icin `.env` dosyasi gerekli (bkz. `.env.example`).

## SAP ADT — Deployment ve Kod Yonetimi (Dassian-ADT)

Dogrudan SAP sistemine deploy. abapGit'e gerek kalmadan tam lifecycle:

| Faz | MCP Tool | Aciklama |
|---|---|---|
| Kod okuma | `abap_get_source` | Mevcut kodu oku |
| Obje olusturma | `abap_create` | Yeni class/interface/table olustur |
| Kod yazma | `abap_set_source` | Kaynak kodu SAP'a push et |
| Syntax kontrol | `abap_syntax_check` | Derleme hatasi kontrolu |
| Aktivasyon | `abap_activate` | Objeyi aktive et |
| ATC kontrol | `abap_atc_run` | Kod kalite kontrolu |
| Test calistirma | `abap_run` | Unit test calistir |
| Transport olustur | `transport_create` | Workbench/Customizing request |
| Transport'a ata | `transport_assign` | Objeleri transport'a ekle |
| Transport release | `transport_release` | QAS/PRD'ye tasima icin serbest birak |
| Obje arama | `abap_search` | SAP'taki objeleri ara |

## SAP VSP — Hizli Gelistirme (Vibing Steampunk)

Method-level cerrahi ve batch deploy:

| Yetenek | Aciklama |
|---|---|
| `WriteSource` / `EditSource` | Tek method seviyesinde kod degistir |
| `SyntaxCheck` | Hizli syntax dogrulama |
| `RunUnitTests` | ABAP Unit testleri calistir |
| `RunATCCheck` | ATC kalite kontrolu |
| Batch deploy | Birden fazla dosyayi tek seferde gonder |
| `--read-only` mod | Guvensiz ortamlarda sadece okuma |

## Fiori/UI5 MCP

- `@sap-ux/fiori-mcp-server` — Fiori uygulama olusturma ve modifikasyon
- `@ui5/mcp-server` — UI5 proje destegi

## Ek MCP Araclari

- [mcp-sap-docs](https://github.com/marianfoo/mcp-sap-docs) — SAP dokumantasyon arama
- [mcp-sap-notes](https://github.com/marianfoo/mcp-sap-notes) — SAP Note arama

## MCP Deployment Akisi (Faz 5 + Faz 7)

```
[Lokal kod] --abap_set_source--> [SAP DEV] --abap_activate--> [Aktif obje]
                                     |
                          abap_syntax_check + abap_atc_run
                                     |
                          transport_create -> transport_assign
                                     |
                               transport_release
                                     |
                              [QAS] -> [PRD]
```

### ECC 6.0 Aktivasyon Workaround (KRITIK!)

`abap_activate` MCP tool'u ECC 6.0'da sessizce basarisiz oluyor (transport audit popup headless ortamda cevaplanamaz).

**Calisan yontem:** `raw_http` ile `preauditRequested=false`:

```
POST /sap/bc/adt/activation?method=activate&preauditRequested=false
Content-Type: application/xml

<?xml version="1.0" encoding="UTF-8"?>
<adtcore:objectReferences xmlns:adtcore="http://www.sap.com/adt/core">
  <adtcore:objectReference adtcore:uri="/sap/bc/adt/oo/classes/zcl_xxx" adtcore:name="ZCL_XXX"/>
</adtcore:objectReferences>
```

**URI path'ler:**
- Class: `/sap/bc/adt/oo/classes/{name}`
- Interface: `/sap/bc/adt/oo/interfaces/{name}`
- Program: `/sap/bc/adt/programs/programs/{name}`

**Not:** abapGit ile gelen class'larda implementation bos gelebilir. Bu durumda `abap_set_source` ile source yazilip Eclipse'den Ctrl+F3 ile aktive edilmeli.

## Microsoft Planner MCP

Proje yonetimi icin Microsoft Planner entegrasyonu. Detaylar: [`planner-entegrasyonu.md`](planner-entegrasyonu.md)

| Tool | Aciklama |
|---|---|
| `list_tasks` | Plan'daki kartlari listele |
| `get_task_details` | Kart detayini oku |
| `create_task` | Yeni kart olustur |
| `update_task_details` | Kart aciklamasini guncelle |
| `move_task` | Karti baska bucket'a tasi |
| `complete_task` | Karti %100 tamamla |
| `add_checklist_item` | DoD maddesi ekle |
| `toggle_checklist_item` | Maddeyi isle/kaldir |
| `add_reference` | Session log linki ekle |

## Kurulum

### SAP ADT
1. `.env.example`'i `.env` olarak kopyala, SAP bilgilerini doldur
2. SAP'ta ADT servisleri aktif olmali (`/sap/bc/adt/*` ICF node'lari)
3. Kullanicinin developer yetkisi ve S_DEVELOP objesi olmali

### Planner
1. `.mcp.json`'da planner server tanimli
2. Ilk calistirmada browser'da Microsoft login gerekli
3. Token `{PLANNER_TOKEN_CACHE_PATH}`'da cache'lenir
