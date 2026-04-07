interface zif_zrpd_edev_edevlet public.

  methods verify
    importing
      iv_barcode        type zrpd_edev_de_bcno
      iv_tckn           type char11
    returning
      value(rv_verified) type abap_bool
    raising
      zcx_zrpd_edev_api.

endinterface.
