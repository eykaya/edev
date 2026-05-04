"Name: \PR:SAPFP50M\FO:EXIT\SE:BEGIN\EI
ENHANCEMENT 0 ZRPD_EDEV_ENH.

case sy-ucomm.
  when '&ZDOC' or 'ZDOC'.
    zcl_im_rpd_edev=>process_command( 'UPLOAD' ).
    leave to screen sy-dynnr.
  when '&ZDOC_VW' or 'ZDOC_VW'.
    zcl_im_rpd_edev=>process_command( 'VIEW' ).
    leave to screen sy-dynnr.
  when '&ZDOC_DL' or 'ZDOC_DL'.
    zcl_im_rpd_edev=>process_command( 'DELETE' ).
    leave to screen sy-dynnr.
endcase.

ENDENHANCEMENT.
