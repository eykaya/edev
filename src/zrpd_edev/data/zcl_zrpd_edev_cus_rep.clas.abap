class zcl_zrpd_edev_cus_rep definition public final create public.

  public section.

    interfaces zif_zrpd_edev_cust_repo.

endclass.

class zcl_zrpd_edev_cus_rep implementation.

  method zif_zrpd_edev_cust_repo~get_doc_type.
    data: ls_dtype type zrpd_edev_t_dtyp.

    select single * from zrpd_edev_t_dtyp
      into ls_dtype
      where doc_type = iv_doc_type.

    if sy-subrc = 0.
      rs_dtype = ls_dtype.
    else.
      raise exception type zcx_zrpd_edev_notfnd
        exporting
          mv_msgv1 = iv_doc_type.
    endif.
  endmethod.

  method zif_zrpd_edev_cust_repo~get_fields.
    data: lt_fields type zif_zrpd_edev_cust_repo=>ty_t_dfld.

    select * from zrpd_edev_t_dfld
      into table lt_fields
      where doc_type = iv_doc_type
      order by sort_order ascending.

    rt_fields = lt_fields.
  endmethod.

  method zif_zrpd_edev_cust_repo~get_mappings.
    data: lt_mappings type zif_zrpd_edev_cust_repo=>ty_t_dmap.

    select * from zrpd_edev_t_dmap
      into table lt_mappings
      where doc_type = iv_doc_type
      order by field_name ascending.

    rt_mappings = lt_mappings.
  endmethod.

  method zif_zrpd_edev_cust_repo~get_param.
    data: lv_value type c length 60.

    select single param_value from zrpd_edev_t_parm
      into lv_value
      where param_key = iv_key.

    if sy-subrc = 0.
      rv_value = lv_value.
    endif.
  endmethod.

endclass.
