# ABAP Naming Convention (ABAP Standardi)

← [CLAUDE.md](../../CLAUDE.md)

## Prefix Kurali

Prefix = `ZRPD_` (sabit) + 4 buyuk harf (proje kodu) = 9 karakter

```
Ornekler: ZRPD_ABCD, ZRPD_PRJA, ZRPD_PRJB
```

## Genel Kural

```
DDIC Objeleri:  ZRPD_{XXXX}_{Nesne Kodu}_{Tanitici}
OO Objeleri:    Z{Tip}_ZRPD_{XXXX}_{Tanitici}
CDS Objeleri:   ZRPD_{XXXX}_{Tip}_{Tanitici}
```

## Nesne Kodu Tablosu

| Nesne Tipi | Kod | Pattern | Ornek |
|---|---|---|---|
| Paket | -- | `ZRPD_{XXXX}_*` | `ZRPD_ABCD_CORE` |
| Tablo | T | `ZRPD_{XXXX}_T_{tanitici}` | `ZRPD_ABCD_T_DOCTYPE` |
| View | V | `ZRPD_{XXXX}_V_{tanitici}` | `ZRPD_ABCD_V_DOCTYPE` |
| Cluster View | CV | `ZRPD_{XXXX}_CV_{tanitici}` | `ZRPD_ABCD_CV_CUST` |
| Structure | S | `ZRPD_{XXXX}_S_{tanitici}` | `ZRPD_ABCD_S_DOCHEAD` |
| Data Element | DE | `ZRPD_{XXXX}_DE_{tanitici}` | `ZRPD_ABCD_DE_DOCTYPE` |
| Domain | D | `ZRPD_{XXXX}_D_{tanitici}` | `ZRPD_ABCD_D_STATUS` |
| Table Type | TT | `ZRPD_{XXXX}_TT_{tanitici}` | `ZRPD_ABCD_TT_DOC` |
| Search Help | SH | `ZRPD_{XXXX}_SH_{tanitici}` | `ZRPD_ABCD_SH_DOCTYPE` |
| Lock Object | ENQU | `EZRPD_{XXXX}_{tanitici}` | `EZRPD_ABCD_T_DOC` |
| Function Group | FG | `ZRPD_{XXXX}_FG_{tanitici}` | `ZRPD_ABCD_FG_UTIL` |
| Function Module | FM | `ZRPD_{XXXX}_FM_{tanitici}` | `ZRPD_ABCD_FM_VERIFY` |
| Message Class | M | `ZRPD_{XXXX}_M` | `ZRPD_ABCD_M` |
| Enhancement | EN | `ZRPD_{XXXX}_EN_{tanitici}` | `ZRPD_ABCD_EN_PA30` |
| BAdI | BD | `ZRPD_{XXXX}_BD_{tanitici}` | `ZRPD_ABCD_BD_ADDR` |
| Smartform | SF | `ZRPD_{XXXX}_SF_{tanitici}` | -- |
| Adobe Form | AF | `ZRPD_{XXXX}_AF_{tanitici}` | -- |
| Rapor | R | `ZRPD_{XXXX}_R_{tanitici}` | `ZRPD_ABCD_R_UPLOAD` |
| Transaction | TR | `ZRPD_{XXXX}_{tanitici}` | `ZRPD_ABCD_UPLOAD` |
| Auth Object | -- | `ZRPD_{XXXX}_{tanitici}` | `ZRPD_ABCD_DOC` |

## OO Objeleri

| Nesne Tipi | Kod | Pattern | Ornek |
|---|---|---|---|
| Class | CL | `ZCL_ZRPD_{XXXX}_{tanitici}` | `ZCL_ZRPD_ABCD_DOC_PROC` |
| Interface | IF | `ZIF_ZRPD_{XXXX}_{tanitici}` | `ZIF_ZRPD_ABCD_AI_SVC` |
| Exception | CX | `ZCX_ZRPD_{XXXX}_{tanitici}` | `ZCX_ZRPD_ABCD_BASE` |
| Behavior Pool | BP | `ZBP_ZRPD_{XXXX}_{tanitici}` | `ZBP_ZRPD_ABCD_DOC` |

> OO objelerde identifier icin **15 karakter** kalir (30 - 15 = 15). Mock siniflarinda `ZCL_ZRPD_{XXXX}_MOCK_` icin **10 karakter** kalir.

## CDS View Objeleri

| Nesne Tipi | Pattern | SQL View Pattern | Ornek |
|---|---|---|---|
| Interface View | `ZRPD_{XXXX}_I_{tanitici}` | `ZRPD_{XXXX}V_{5char}` | `ZRPD_ABCD_I_DOC` / `ZRPD_ABCDV_DOC` |
| Consumption View | `ZRPD_{XXXX}_C_{tanitici}` | `ZRPD_{XXXX}VC{5char}` | `ZRPD_ABCD_C_DOC` / `ZRPD_ABCDVCDOC` |
| Private/Helper | `ZRPD_{XXXX}_P_{tanitici}` | `ZRPD_{XXXX}VP{5char}` | `ZRPD_ABCD_P_HELP` / `ZRPD_ABCDVPHELP` |
| DCL | `ZRPD_{XXXX}_DCL_{tanitici}` | -- | `ZRPD_ABCD_DCL_DOC` |
| Service Definition | `ZRPD_{XXXX}_SD_{tanitici}` | -- | `ZRPD_ABCD_SD_DOC` |

## SQL View Name Kisiti (KRITIK!)

SQL View Name (`@AbapCatalog.sqlViewName`) max **16 karakter**.
`ZRPD_{XXXX}V_` formati 11 karakter tuketir — tanitici icin **5 karakter** kalir.

```
ZRPD_ABCDV_DOC   = 14 char -> OK
ZRPD_ABCDV_DOCLST = 17 char -> TASIYOR! Kisalt.
```

Kisa ve anlamli SQL view isimleri sec. Gerekirse kisaltma tablosu olustur.

## Degisken Isimlendirme

```abap
" Instance attributes:  MO_, MV_, MT_, MS_, MR_
" Static attributes:    GV_, GT_, GS_, GO_
" Constants:            CO_, C_
" Local variables:      LV_, LT_, LS_, LO_, LR_
" Parameters:           IV_, IT_, IS_, IO_ (importing)
"                       EV_, ET_, ES_, EO_ (exporting)
"                       CV_, CT_, CS_      (changing)
"                       RV_, RT_, RS_, RO_ (returning)
" Field symbols:        <LS_>, <LT_>, <LV_>
```
