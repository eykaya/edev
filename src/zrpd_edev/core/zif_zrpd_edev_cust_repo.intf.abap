interface zif_zrpd_edev_cust_repo public.

  types:
    ty_t_dfld type standard table of zrpd_edev_t_dfld with default key,
    ty_t_dmap type standard table of zrpd_edev_t_dmap with default key.

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
      value(rt_fields) type ty_t_dfld.

  methods get_mappings
    importing
      iv_doc_type        type zrpd_edev_de_dctyp
    returning
      value(rt_mappings) type ty_t_dmap.

  methods get_param
    importing
      iv_key          type c
    returning
      value(rv_value) type string.

endinterface.
