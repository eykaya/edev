# Planner Entegrasyonu

← [CLAUDE.md](../../CLAUDE.md)

## Genel Bakis

Microsoft Planner ile proje yonetimi entegrasyonu. Her gelistirme bir Planner karti ile izlenir.

## Planner Bilgileri

| Alan | Deger |
|---|---|
| Plan ID | `{PLAN_ID}` |
| Backlog Bucket | `{BUCKET_ID}` |
| Design Bucket | `{BUCKET_ID}` |
| In Progress Bucket | `{BUCKET_ID}` |
| Review Bucket | `{BUCKET_ID}` |
| Done Bucket | `{BUCKET_ID}` |

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
| MCP Server | `{PLANNER_MCP_SCRIPT_PATH}` |
| CLI Helper | `{PLANNER_HELPER_SCRIPT_PATH}` |
| Python venv | `{PLANNER_PYTHON_PATH}` |
| Token cache | `{PLANNER_TOKEN_CACHE_PATH}` |

## Kullanim

```
/agent planner         — Is kirilimi ve planlama
/agent planner-sync    — Kart guncelleme ve devir notu
```
