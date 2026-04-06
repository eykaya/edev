# ECC 6.0 Uyumluluk Kisitlari

← [CLAUDE.md](../../CLAUDE.md) · [Uyumluluk Matrisi](uyumluluk-matrisi.md)

> Bu kisitlar sadece Platform = ECC 6.0 oldugunda gecerlidir.

## Syntax Kisitlari

- `RAISE EXCEPTION NEW` kullanma -> `RAISE EXCEPTION TYPE ... EXPORTING` kullan
- `VALUE #( )` inline constructor kullanilabilir (7.40+)
- `CORRESPONDING #( )` kullanilabilir (7.40+)
- `FOR ... IN` loop expression kullanilabilir (7.40+)
- `CONV`, `COND`, `SWITCH` kullanilabilir (7.40+)
- ENUM tipi kullanma -> constants kullan
- MESH tipi kullanma
- REDUCE dikkatli kullan (7.40 SP08+)

## Kutuphaneler

- `/UI2/CL_JSON` mevcut (ECC 6.0 SP15+)
- `CL_HTTP_CLIENT` kullanilacak (HTTP cagrilari icin)
- `CL_SYSTEM_UUID` kullanilacak (GUID olusturma)
