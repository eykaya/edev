"Name: \PR:SAPFP50M\FO:EXIT\SE:BEGIN\EI
ENHANCEMENT 0 ZRPD_EDEV_ENH.
  if sy-ucomm = '&ZDOC' or sy-ucomm = 'ZDOC'.
    zcl_im_rpd_edev=>process_edev( ).
    leave to screen sy-dynnr.
  elseif sy-ucomm = '&ZDEL' or sy-ucomm = 'ZDEL'.
    zcl_im_rpd_edev=>process_edev_delete( ).
    leave to screen sy-dynnr.
  endif.


ENDENHANCEMENT.
