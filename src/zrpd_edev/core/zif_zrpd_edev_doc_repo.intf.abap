interface zif_zrpd_edev_doc_repo public.

  methods save
    importing
      is_doc         type zrpd_edev_s_dochd
      iv_content     type xstring
    returning
      value(rv_guid) type zrpd_edev_de_guid
    raising
      zcx_zrpd_edev_upload.

  methods find_by_guid
    importing
      iv_guid        type zrpd_edev_de_guid
    returning
      value(rs_doc)  type zrpd_edev_s_dochd
    raising
      zcx_zrpd_edev_notfnd.

  methods find_by_pernr
    importing
      iv_pernr        type persno
    returning
      value(rt_docs)  type zrpd_edev_tt_dochd.

  methods update_status
    importing
      iv_guid   type zrpd_edev_de_guid
      iv_status type zrpd_edev_de_dstat.

  methods save_values
    importing
      iv_guid    type zrpd_edev_de_guid
      it_values  type zrpd_edev_tt_dcval.

  methods get_values
    importing
      iv_guid          type zrpd_edev_de_guid
    returning
      value(rt_values) type zrpd_edev_tt_dcval.

  methods delete
    importing
      iv_guid type zrpd_edev_de_guid
    raising
      zcx_zrpd_edev_notfnd.

endinterface.
