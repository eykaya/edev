class zcl_zrpd_edev_bd_iui definition public final create public.

  public section.
    interfaces if_badi_interface.
    interfaces if_ex_hrpad00inftyui.

  private section.
    data mo_paitf_read type ref to if_hrpa_paitf_read.
    constants co_op_edev type hrpad_infotype_operation value 'ZEDEV_DOC'.
    constants co_fcode_edev type syucomm value 'ZDOC'.
    constants co_sgui_prog  type progname value 'ZRPD_EDEV_R_SGUI'.
    constants co_sgui_stat  type sypfkey value 'INS'.

    class-methods is_infty_active
      importing
        iv_screen_name type pad_sname
      returning
        value(rv_active) type abap_bool.

    class-methods process_p0006
      changing
        cs_0006 type p0006.

endclass.


class zcl_zrpd_edev_bd_iui implementation.

  method if_ex_hrpad00inftyui~initialize.
    mo_paitf_read = paitf_read.
  endmethod.

  method if_ex_hrpad00inftyui~output_conversion.
    data ls_op type hrpad_s_operation.
    if operations is supplied.
      ls_op-operation = co_op_edev.
      ls_op-property  = 'ENABLED'.
      insert ls_op into table operations.
    endif.
    if mode = 'INS'
      and is_infty_active( screen_structure_name ) = abap_true.
      set pf-status co_sgui_stat of program co_sgui_prog.
    endif.
  endmethod.

  method if_ex_hrpad00inftyui~input_conversion.
    field-symbols <ls_0006> type p0006.
    if sy-ucomm <> co_fcode_edev. return. endif.
    if sy-tcode <> 'PA30' and sy-tcode <> 'PA40'. return. endif.
    if is_infty_active( screen_structure_name ) <> abap_true. return. endif.
    case screen_structure_name.
      when 'P0006'.
        assign pnnnn to <ls_0006> casting.
        if sy-subrc <> 0. return. endif.
        process_p0006( changing cs_0006 = <ls_0006> ).
      when others.
        return.
    endcase.
  endmethod.

  method if_ex_hrpad00inftyui~input_table_conversion.
  endmethod.

  method if_ex_hrpad00inftyui~output_table_conversion.
  endmethod.

  method if_ex_hrpad00inftyui~fill_help_values.
  endmethod.

  method if_ex_hrpad00inftyui~get_help_value_fields.
  endmethod.

  method is_infty_active.
    data lv_infty type zrpd_edev_de_infty.
    data lv_len   type i.
    data lv_dummy type abap_bool.
    rv_active = abap_false.
    lv_len = strlen( iv_screen_name ).
    if lv_len < 5. return. endif.
    if iv_screen_name(1) <> 'P'. return. endif.
    lv_infty = iv_screen_name+1(4).
    select single @abap_true from zrpd_edev_t_dmap
      into @lv_dummy
      where infotype = @lv_infty.
    if sy-subrc = 0.
      rv_active = abap_true.
    endif.
  endmethod.

  method process_p0006.
    data lv_tckn    type char11.
    data lv_barcode type zrpd_edev_de_bcno.
    data lt_fields  type table of sval.
    data ls_field   type sval.
    data lv_rc      type c length 1.
    data lt_vals    type zrpd_edev_tt_dcval.
    data ls_val     type zrpd_edev_s_dcval.
    data lo_edv     type ref to zcl_zrpd_edev_edevlet.
    data lv_ok      type abap_bool.
    data lo_base    type ref to zcl_zrpd_edev_doc_base.
    data lo_ocr     type ref to zcl_zrpd_edev_ocr_py.
    data lv_text    type string.
    data lv_upper   type string.
    data lo_parser  type ref to zcl_zrpd_edev_doc_base.
    data lx_root    type ref to cx_root.
    data lv_errmsg  type string.
    data lv_fn      type string.
    data lv_cadde   type string.
    data lv_sokak   type string.
    data lv_site    type string.
    data lv_blok    type string.
    data lv_stras   type string.
    data lv_pdf     type xstring.

    select single merni from pa0770
      into lv_tckn
      where pernr = cs_0006-pernr
        and endda >= sy-datum
        and begda <= sy-datum.
    if sy-subrc <> 0 or lv_tckn is initial.
      message 'PA0770 MERNI bulunamadi' type 'S' display like 'E'.
      return.
    endif.

    ls_field-tabname   = 'ZRPD_EDEV_S_DOCHD'.
    ls_field-fieldname = 'BARCODE'.
    ls_field-fieldtext = 'Barkod'.
    append ls_field to lt_fields.

    call function 'POPUP_GET_VALUES'
      exporting
        popup_title     = 'e-Devlet Ikametgah'
      importing
        returncode      = lv_rc
      tables
        fields          = lt_fields
      exceptions
        error_in_fields = 1
        others          = 2.

    if sy-subrc <> 0 or lv_rc = 'A'. return. endif.

    read table lt_fields into ls_field index 1.
    lv_barcode = ls_field-value.
    if lv_barcode is initial. return. endif.

    try.
        create object lo_edv.

        lv_ok = lo_edv->zif_zrpd_edev_edevlet~verify(
          iv_barcode = lv_barcode
          iv_tckn    = lv_tckn ).
        if lv_ok <> abap_true.
          message 'Barkod GECERSIZ' type 'S' display like 'E'.
          return.
        endif.

        message 'Barkod GECERLI - belge dogrulandi' type 'S'.

        create object lo_base type zcl_zrpd_edev_doc_ika.
        lv_text = lo_base->pdf_to_text( lv_pdf ).
        lv_upper = to_upper( lv_text ).
        if lv_text is initial
          or ( lv_upper ns 'KIMLIK' and lv_upper ns 'YERLESIM' and lv_upper ns 'ADRES' ).
          create object lo_ocr.
          lv_text = lo_ocr->zif_zrpd_edev_ext_svc~extract_text( lv_pdf ).
        endif.

        create object lo_parser type zcl_zrpd_edev_doc_ika.
        lt_vals = lo_parser->parse_fields( lv_text ).

      catch cx_root into lx_root.
        lv_errmsg = lx_root->get_text( ).
        if strlen( lv_errmsg ) > 200.
          lv_errmsg = lv_errmsg(200).
        endif.
        message lv_errmsg type 'S' display like 'E'.
        return.
    endtry.

    if lt_vals is initial.
      message 'Belgeden alan cikarilamadi' type 'S' display like 'W'.
      return.
    endif.

    try.
        loop at lt_vals into ls_val.
          lv_fn = ls_val-field_name.
          translate lv_fn to lower case.
          case lv_fn.
            when 'il'.
              cs_0006-ort01 = ls_val-field_value.
            when 'mahalle'.
              cs_0006-ort02 = ls_val-field_value.
            when 'ilce'.
              cs_0006-strds = ls_val-field_value.
            when 'posta_kodu'.
              cs_0006-pstlz = ls_val-field_value.
            when 'bina_no'.
              cs_0006-hsnmr = ls_val-field_value.
            when 'ic_kapi_no'.
              cs_0006-locat = ls_val-field_value.
            when 'cadde'.
              lv_cadde = ls_val-field_value.
            when 'sokak'.
              lv_sokak = ls_val-field_value.
            when 'site_apartman'.
              lv_site = ls_val-field_value.
            when 'blok'.
              lv_blok = ls_val-field_value.
          endcase.
        endloop.

        if lv_cadde is not initial.
          lv_stras = lv_cadde.
        elseif lv_sokak is not initial.
          lv_stras = lv_sokak.
        endif.

        if lv_site is not initial.
          if lv_stras is initial.
            lv_stras = lv_site.
          else.
            lv_stras = |{ lv_stras } { lv_site }|.
          endif.
        endif.

        if lv_blok is not initial.
          lv_stras = |{ lv_stras } { lv_blok } Blok|.
        endif.

        if lv_stras is not initial.
          cs_0006-stras = lv_stras.
        endif.

        if cs_0006-land1 is initial.
          cs_0006-land1 = 'TR'.
        endif.

      catch cx_root into lx_root.
        lv_errmsg = lx_root->get_text( ).
        if strlen( lv_errmsg ) > 200.
          lv_errmsg = lv_errmsg(200).
        endif.
        message lv_errmsg type 'S' display like 'E'.
        return.
    endtry.

    message 'Adres yuklendi' type 'S'.

  endmethod.

endclass.
