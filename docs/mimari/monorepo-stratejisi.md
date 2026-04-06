# Monorepo Stratejisi

← [CLAUDE.md](../../CLAUDE.md)

Tum ABAP paketleri tek bir GitHub repo icinde yonetilir:

```
{org}/zrpd_{xxxx}-abap                 (tek repo)
+-- src/
|   +-- zrpd_{xxxx}_core/              Arayuzler, exception, tipler, sabitler
|   +-- zrpd_{xxxx}_cust/              Uyarlama tablolari, SM30
|   +-- zrpd_{xxxx}_data/              Veri erisim katmani
|   +-- zrpd_{xxxx}_logic/             Is mantigi
|   +-- zrpd_{xxxx}_api/               Dis API entegrasyonlari
|   +-- zrpd_{xxxx}_ui/                Transaction, ALV
|   +-- zrpd_{xxxx}_fiori/             CDS, OData, annotation
|   +-- zrpd_{xxxx}_test/              Test double, mock
+-- docs/
|   +-- SPEC/                          Spec dokumanlari
|   +-- PLUGINS.md                     Plugin referansi
+-- Sablonlar/
+-- .abaplint.json
+-- .abapgit.xml                       FOLDER_LOGIC: PREFIX
+-- CLAUDE.md
+-- package.json
```

## Avantajlar

- Tek CI/CD pipeline (abaplint tum paketlerde calisir)
- Cross-package degisiklikler tek commit'te
- Spec + kod + test ayni repo'da
- `.abapgit.xml` `FOLDER_LOGIC: PREFIX` ile paket-seviye sync destekler
