interface zif_zrpd_edev_cust_repo public.

  methods get_doc_type
    importing
      iv_doc_type     type zrpd_edev_de_dctyp
    returning
      value(rs_dtype) type zrpd_edev_t_dtyp
    raising
      zcx_zrpd_edev_notfnd.

  methods get_fields
    importing
      iv_doc_type      type zrpd_edev_de_dctyp
    returning
      value(rt_fields) type standard table of zrpd_edev_t_dfld with default key.

  methods get_mappings
    importing
      iv_doc_type        type zrpd_edev_de_dctyp
    returning
      value(rt_mappings) type standard table of zrpd_edev_t_dmap with default key.

  methods get_param
    importing
      iv_key          type char30
    returning
      value(rv_value) type char60.

endinterface.
