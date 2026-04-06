# Test Kurallari

← [CLAUDE.md](../../CLAUDE.md)

## ABAP Unit Test

- Her sinif icin ABAP Unit test yazilir
- Mock'lar `ZRPD_{XXXX}_TEST` paketinde
- Constructor injection ile HTTP/DB/HR erisimi olmadan test

## Hedef Kapsam

| Katman | Kapsam |
|---|---|
| Orchestrator | %90+ |
| Mapper | %95+ |
| Conversion | %100 |
| UI | %70+ |

## Lokal Dogrulama

Her degisiklik sonrasi:
```bash
npm run lint                   # = ./node_modules/.bin/abaplint src/
```

abaplint her commit oncesi calistirilir.
