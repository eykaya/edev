interface zif_zrpd_edev_ext_svc public.

  methods extract_text
    importing
      iv_content      type xstring
    returning
      value(rv_text)  type string
    raising
      zcx_zrpd_edev_api.

endinterface.
