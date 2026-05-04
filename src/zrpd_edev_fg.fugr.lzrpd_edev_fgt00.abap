*---------------------------------------------------------------------*
*    view related data declarations
*---------------------------------------------------------------------*
*...processing: ZRPD_EDEV_T_DMAP................................*
DATA:  BEGIN OF STATUS_ZRPD_EDEV_T_DMAP              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZRPD_EDEV_T_DMAP              .
CONTROLS: TCTRL_ZRPD_EDEV_T_DMAP
            TYPE TABLEVIEW USING SCREEN '0001'.
*...processing: ZRPD_EDEV_T_DTYP................................*
DATA:  BEGIN OF STATUS_ZRPD_EDEV_T_DTYP              .   "state vector
         INCLUDE STRUCTURE VIMSTATUS.
DATA:  END OF STATUS_ZRPD_EDEV_T_DTYP              .
CONTROLS: TCTRL_ZRPD_EDEV_T_DTYP
            TYPE TABLEVIEW USING SCREEN '0002'.
*.........table declarations:.................................*
TABLES: *ZRPD_EDEV_T_DMAP              .
TABLES: *ZRPD_EDEV_T_DTYP              .
TABLES: ZRPD_EDEV_T_DMAP               .
TABLES: ZRPD_EDEV_T_DTYP               .

* general table data declarations..............
  INCLUDE LSVIMTDT                                .
