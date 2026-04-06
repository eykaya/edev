# Planner Entegrasyonu

← [CLAUDE.md](../../CLAUDE.md)

## Genel Bakis

Microsoft Planner ile proje yonetimi entegrasyonu. Her gelistirme bir Planner karti ile izlenir.

## Planner Bilgileri

| Alan | Deger |
|---|---|
| M365 Group | `ZRPD_EDEV` |
| Group ID | `c60d937c-65cc-4461-a841-0aaf9b4ac6e7` |
| Plan ID | `QIMFwuYPE06l4x5xVs0R-5gAHU2N` |
| Backlog Bucket | `Fk-3cgG_MUCPwOzy-5E4a5gADSkq` |
| Design Bucket | `1SjQKlxmXkWU-Gq54tSoHJgACi4K` |
| In Progress Bucket | `e3Bd9WfuS0KWGcI32hWKdZgADzBj` |
| Review Bucket | `FqZiSRyY806xAWHrXCZUkZgAJwg9` |
| Done Bucket | `wcBIYGvn80mWfxr_IAC3EZgAE7sI` |

### Kart ID'leri

| Kart | Task ID |
|---|---|
| FAZ 1 — DDIC Temeli | `SKxAQXWJHUKOe5OOx1sIbJgAHxRo` |
| FAZ 2 — Core Katman | `1404Kmkyvke65r3IwOhJR5gAOWOK` |
| FAZ 3 — Data Access | `zUB_WDczMEWIRJENGSElOpgAJfBM` |
| FAZ 5 — Base Class + Ikametgah Parser | `d10j0LSMF0SS5BgGMvdHH5gAEw5v` |
| FAZ 4 — Upload, Download, List, Validate | `hXnXJBhp1EyZ3ZxS9zwS0ZgAB7ju` |
| FAZ 6 — e-Devlet + API | `dcf9lQLMpUKRyMEqRZB1BJgAEF2d` |
| FAZ 7 — UI (Rapor + Transaction) | `N8E7cEZCuUSX0-L9kMZ1rpgAN_5u` |

> Yeni proje baslatirken: `$PYTHON $HELPER buckets $PLAN_ID` ile bucket ID'leri alin.

## Bucket - Faz Eslestirmesi

| Bucket | Faz | Aciklama |
|---|---|---|
| Backlog | Faz 1 | Kapsam ve amac belirlenmis, henuz tasarim baslamadi |
| Design | Faz 2-4 | Kavramsal tasarim, FS ve TS yaziliyor |
| In Progress | Faz 5 | Kodlama ve test (TDD) |
| Review | Faz 6 | Kod review ve dogrulama |
| Done | Faz 7 | Deployment tamamlandi |

## Agent Rolleri

| Agent | Gorev |
|---|---|
| `planner` | Is kirilimi, kart yapisi onerisi, bagimlilik analizi |
| `planner-sync` | Kart guncelleme, devir notu, bucket tasima, impact analizi |

## Kart Yapisi

```markdown
## Scope
- Dokunulacak dosya/objeler

## Dependencies
- ZRPD_{XXXX}-NNN: sebep

## DoD (Definition of Done)
- [ ] Spec onayli (Gate 2)
- [ ] abaplint hatasiz
- [ ] Unit test basarili
- [ ] Code review temiz
- [ ] Transport atanmis
```

## Devir Notu Formati

Her oturum sonunda karta eklenir:

```markdown
## Devir Notu (YYYY-MM-DD)
- **Yapilan:** Tamamlanan is kalemleri
- **Kalan:** Bekleyen DoD maddeleri
- **Takilma:** Engelleyiciler
- **Spec Sapmasi:** Sapmalar veya "Yok"
- **Sonraki komut:** Giris noktasi (dosya, fonksiyon)
```

## Teknik Altyapi

Planner MCP server ve CLI tool paylasimli kullanilir:

| Bilesen | Konum |
|---|---|
| MCP Server | `tools/planner_mcp.py` |
| CLI Helper | `tools/planner_helper.py` |
| Python venv | `~/.rapidhcm/planner-venv/` |
| Token cache | `~/.rapidhcm/planner_token_cache.json` |

## Kullanim

```
/agent planner         — Is kirilimi ve planlama
/agent planner-sync    — Kart guncelleme ve devir notu
```
