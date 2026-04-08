class zcl_zrpd_edev_doc_fac definition public final create public.

  public section.

    methods create_parser
      importing
        iv_doc_type      type zrpd_edev_de_dctyp
      returning
        value(ro_parser) type ref to zcl_zrpd_edev_doc_base
      raising
        zcx_zrpd_edev_valid.

endclass.

class zcl_zrpd_edev_doc_fac implementation.

  method create_parser.
    data: lv_class type seoclsname,
          lv_msg   type symsgv.

    select single parser_class from zrpd_edev_t_dtyp
      where doc_type = @iv_doc_type
        and active   = @abap_true
      into @lv_class.

    if sy-subrc is not initial or lv_class is initial.
      lv_msg = iv_doc_type.
      raise exception new zcx_zrpd_edev_valid(
        mv_msgv1 = lv_msg ).
    endif.

    try.
        create object ro_parser type (lv_class).
      catch cx_sy_create_object_error.
        lv_msg = lv_class.
        raise exception new zcx_zrpd_edev_valid(
          mv_msgv1 = lv_msg ).
    endtry.
  endmethod.

endclass.
