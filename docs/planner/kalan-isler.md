# Kalan Isler — Planner Kartlari

## Oncelik 1: Parser Iyilestirme
- [ ] OCR performans iyilestirmesi (DPI 300->200, image crop)
- [ ] Barkod tanima iyilestirmesi (PDF 4 bos geliyor)
- [ ] Adres No: | olmayan belgelerde fallback stratejisi

## Oncelik 2: API Layer
- [ ] e-Devlet belge dogrulama entegrasyonu (SM59: ZRPD_EDEV_EDEVLET)
- [ ] ZCL_ZRPD_EDEV_EDEVLET class implementasyonu
- [ ] ZCL_ZRPD_EDEV_HTTP class (EGOV'dan adapte — SXPG yerine HTTP)

## Oncelik 3: Orchestrator + Mapper
- [ ] ZCL_ZRPD_EDEV_DOC_MGR (ana orchestrator) implementasyonu
- [ ] ZCL_ZRPD_EDEV_IT_MAP (IT0006 eslestirme + HR_INFOTYPE_OPERATION)
- [ ] Pipeline: upload -> OCR -> parse -> verify -> map -> commit

## Oncelik 4: UI Raporlari
- [ ] ZRPD_EDEV_R_UPLOAD: Production upload raporu (PERNR + PDF + islem)
- [ ] ZRPD_EDEV_R_LIST: Belge listeleme (ALV Grid + PDF indirme)
- [ ] Transaction kodlari: ZRPD_EDEV_UPLOAD, ZRPD_EDEV_LIST

## Oncelik 5: Test + Mock
- [ ] ZCL_ZRPD_EDEV_MK_DREP (Mock repository)
- [ ] ZCL_ZRPD_EDEV_MK_CREP (Mock customizing)
- [ ] ZCL_ZRPD_EDEV_MK_EDVL (Mock e-Devlet)
- [ ] ZCL_ZRPD_EDEV_MK_EXTS (Mock OCR/LLM)
- [ ] Unit test coverage >= 90%

## Oncelik 6: Deployment
- [ ] SM30 bakim gorunumleri (T_DTYP, T_DFLD, T_DMAP, T_PARM, T_CTRY)
- [ ] Customizing initial data (IKAMETGAH belge tipi + alan tanimlari + eslestirme kurallari)
- [ ] Transport release (ER1K900803)
- [ ] Yetki objesi: ZRPD_EDEV_DOC
- [ ] Lock object: EZRPD_EDEV_T_DOC
