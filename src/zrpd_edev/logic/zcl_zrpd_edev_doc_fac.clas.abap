class zcl_zrpd_edev_doc_fac definition public final create public.

  public section.

    methods create_parser
      importing
        iv_doc_type    type zrpd_edev_de_dctyp
      returning
        value(ro_parser) type ref to zcl_zrpd_edev_doc_base
      raising
        zcx_zrpd_edev_valid.

endclass.

class zcl_zrpd_edev_doc_fac implementation.

  method create_parser.
    case iv_doc_type.
      when 'IKAMETGAH'.
        create object ro_parser type zcl_zrpd_edev_doc_ika.
      when others.
        raise exception type zcx_zrpd_edev_valid
          exporting
            mv_msgv1 = iv_doc_type.
    endcase.
  endmethod.

endclass.
