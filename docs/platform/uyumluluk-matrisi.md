# Platform Uyumluluk Matrisi

← [CLAUDE.md](../../CLAUDE.md)

| Ozellik | ECC 6.0 (7.40+) | S/4HANA (7.57+) | BTP Cloud |
|---|:---:|:---:|:---:|
| `VALUE #( )` | Evet | Evet | Evet |
| `CORRESPONDING #( )` | Evet | Evet | Evet |
| `FOR ... IN` | Evet | Evet | Evet |
| `CONV`, `COND`, `SWITCH` | Evet | Evet | Evet |
| `RAISE EXCEPTION NEW` | Hayir | Evet | Evet |
| `ENUM` | Hayir | Evet | Evet |
| CDS Views | Sinirli | Tam | Tam |
| AMDP | Hayir | Evet | Evet |
| RAP (RESTful ABAP) | Hayir | Evet | Evet |
| ABAP Cloud (Restricted) | Hayir | Hayir | Evet |
| `/UI2/CL_JSON` | Evet (SP15+) | Evet | Hayir |
| `XCO` Library | Hayir | Evet | Evet |

Platform-ozel detaylar icin:
- [ECC 6.0 Kisitlari](ecc-kisitlari.md)
- [S/4HANA Eklentileri](s4hana-eklentileri.md)
- [BTP Cloud Eklentileri](btp-eklentileri.md)
