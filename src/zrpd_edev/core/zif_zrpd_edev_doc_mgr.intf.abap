interface zif_zrpd_edev_doc_mgr public.

  methods upload
    importing
      is_uplod       type zrpd_edev_s_uplod
    returning
      value(rv_guid) type zrpd_edev_de_guid
    raising
      zcx_zrpd_edev_upload
      zcx_zrpd_edev_valid.

  methods download
    importing
      iv_guid        type zrpd_edev_de_guid
    returning
      value(rs_file) type zrpd_edev_s_uplod
    raising
      zcx_zrpd_edev_notfnd.

  methods download_all
    importing
      iv_pernr         type persno
    returning
      value(rt_files)  type zrpd_edev_tt_dochd
    raising
      zcx_zrpd_edev_notfnd.

  methods list
    importing
      iv_pernr        type persno
    returning
      value(rt_docs)  type zrpd_edev_tt_dochd.

  methods verify_edevlet
    importing
      iv_guid type zrpd_edev_de_guid
    raising
      zcx_zrpd_edev_api
      zcx_zrpd_edev_valid.

  methods extract_data
    importing
      iv_guid           type zrpd_edev_de_guid
    returning
      value(rt_values)  type zrpd_edev_tt_dcval
    raising
      zcx_zrpd_edev_extract.

  methods validate_doc_type
    importing
      iv_guid          type zrpd_edev_de_guid
    returning
      value(rv_valid)  type abap_bool
    raising
      zcx_zrpd_edev_valid.

  methods map_to_infotype
    importing
      iv_guid            type zrpd_edev_de_guid
    returning
      value(rt_mappings) type zrpd_edev_tt_dcval
    raising
      zcx_zrpd_edev_valid.

endinterface.
