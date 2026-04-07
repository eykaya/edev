# Aktivasyon Sirasi (Kritik!)

← [CLAUDE.md](../../CLAUDE.md)

abapGit pull sonrasi bu sirayla aktive et:

1. **Domains** (`ZRPD_{XXXX}_D_*`) -> Data Elements (`ZRPD_{XXXX}_DE_*`) -> Table Types (`ZRPD_{XXXX}_TT_*`)
2. **Transparent Tables** (`ZRPD_{XXXX}_T_*` — once customizing, sonra application)
3. **Interfaces** (`ZIF_ZRPD_{XXXX}_*` — cross-dependency yok)
4. **Exception Classes** (`ZCX_ZRPD_{XXXX}_BASE` -> alt siniflar)
5. **Utility Classes** (`ZCL_ZRPD_{XXXX}_CONSTANTS`, `ZCL_ZRPD_{XXXX}_GUID`, `ZCL_ZRPD_{XXXX}_JSON`)
6. **Implementation Classes** (bagimlilik sirasina gore)
7. **Reports** (`ZRPD_{XXXX}_R_*`) ve **Transaction Codes**
8. **Message Class** `ZRPD_{XXXX}_M`

## ECC 6.0 Ozel Notlari

- `abap_activate` MCP tool'u calismaz — `raw_http` ile `preauditRequested=false` kullanin
- abapGit pull ile gelen class implementation'lari bos gelebilir — Eclipse Ctrl+F3 ile aktive edin
- DDIC nesneleri (DOMA, DTEL) icin ADT endpoint'leri ECC'de mevcut degil — abapGit ile deploy edin
- Tablolar (TABL) icin `/sap/bc/adt/ddic/tables` endpoint'i ECC'de yok — abapGit kullanin
- Paket olusturma ADT ile yapilamaz — SAP GUI SE80/SE21 veya abapGit ile yapin
