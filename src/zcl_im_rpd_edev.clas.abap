class zcl_im_rpd_edev definition
  public
  final
  create public.

  public section.
    interfaces if_ex_hrpad00infty.
    class-methods process_edev.

  private section.
    constants co_sgui_prog type progname           value 'ZRPD_EDEV_R_SGUI'.
    constants co_sgui_stat type sypfkey            value 'INS'.
    constants co_mp_p0006  type string             value '(MP000600)P0006'.
    constants co_doc_type  type zrpd_edev_de_dctyp value 'IKAMETGAH'.

    class-data gs_pending     type p0006.
    class-data gv_has_pending type abap_bool.

    class-methods process_p0006
      changing
        cs_0006 type p0006.

    class-methods get_plate_code
      importing
        iv_il           type any
      returning
        value(rv_plate) type string.

    class-methods normalize_turkish
      changing
        cv_text type string.

endclass.


class zcl_im_rpd_edev implementation.

  method normalize_turkish.
    data lv_char type c length 1.
    lv_char = cl_abap_conv_in_ce=>uccp( '0130' ).
    replace all occurrences of lv_char in cv_text with 'I'.
    lv_char = cl_abap_conv_in_ce=>uccp( '00D6' ).
    replace all occurrences of lv_char in cv_text with 'O'.
    lv_char = cl_abap_conv_in_ce=>uccp( '00DC' ).
    replace all occurrences of lv_char in cv_text with 'U'.
    lv_char = cl_abap_conv_in_ce=>uccp( '015E' ).
    replace all occurrences of lv_char in cv_text with 'S'.
    lv_char = cl_abap_conv_in_ce=>uccp( '00C7' ).
    replace all occurrences of lv_char in cv_text with 'C'.
    lv_char = cl_abap_conv_in_ce=>uccp( '011E' ).
    replace all occurrences of lv_char in cv_text with 'G'.
  endmethod.

  method get_plate_code.
    data lv_norm type string.
    data lv_bezei type string.
    data lt_regions type standard table of t005u.
    data ls_region type t005u.

    rv_plate = ''.

    try.
        lv_norm = iv_il.
        lv_norm = to_upper( lv_norm ).
        condense lv_norm.
        normalize_turkish( changing cv_text = lv_norm ).

        select bland bezei from t005u
          into corresponding fields of table lt_regions
          where spras = 'T' and land1 = 'TR'.

        loop at lt_regions into ls_region.
          lv_bezei = ls_region-bezei.
          lv_bezei = to_upper( lv_bezei ).
          condense lv_bezei.
          normalize_turkish( changing cv_text = lv_bezei ).
          if lv_bezei = lv_norm.
            rv_plate = ls_region-bland.
            return.
          endif.
        endloop.

      catch cx_root.
        rv_plate = ''.
    endtry.
  endmethod.

  method if_ex_hrpad00infty~after_input.
  endmethod.

  method if_ex_hrpad00infty~before_output.
    data lv_dummy   type abap_bool.
    data lt_targets type standard table of zrpd_edev_de_iflnm.
    data lv_target  type zrpd_edev_de_iflnm.
    field-symbols <ls_0006> type p0006.
    field-symbols <fs_src>  type any.
    field-symbols <fs_dst>  type any.

    if innnn-infty <> '0006'. return. endif.
    if ipsyst-ioper <> 'INS'. return. endif.

    select single @abap_true from zrpd_edev_t_dmap
      into @lv_dummy
      where infotype = @innnn-infty.
    if sy-subrc <> 0. return. endif.

    if gv_has_pending = abap_true.
      assign (co_mp_p0006) to <ls_0006>.
      if sy-subrc = 0.
        select distinct infotype_field
          from zrpd_edev_t_dmap
          into table @lt_targets
          where doc_type       = @co_doc_type
            and infotype       = '0006'
            and infotype_field <> @space.

        loop at lt_targets into lv_target.
          assign component lv_target of structure gs_pending to <fs_src>.
          if sy-subrc <> 0. continue. endif.
          if <fs_src> is initial. continue. endif.
          assign component lv_target of structure <ls_0006> to <fs_dst>.
          if sy-subrc <> 0. continue. endif.
          <fs_dst> = <fs_src>.
        endloop.

        if <ls_0006>-land1 is initial.
          <ls_0006>-land1 = 'TR'.
        endif.
      endif.

      clear gs_pending.
      clear gv_has_pending.
    endif.

    set pf-status co_sgui_stat of program co_sgui_prog.
  endmethod.

  method if_ex_hrpad00infty~in_update.
  endmethod.

  method process_edev.
    data lt_targets type standard table of zrpd_edev_de_iflnm.
    data lv_target  type zrpd_edev_de_iflnm.
    data lv_any     type abap_bool.
    field-symbols <ls_mp>  type p0006.
    field-symbols <fs_val> type any.

    clear gs_pending.
    clear gv_has_pending.

    assign (co_mp_p0006) to <ls_mp>.
    if sy-subrc = 0.
      gs_pending-pernr = <ls_mp>-pernr.
    endif.
    if gs_pending-pernr is initial.
      message 'ZEDV: PERNR alinamadi' type 'S' display like 'E'.
      return.
    endif.

    process_p0006( changing cs_0006 = gs_pending ).

    select distinct infotype_field
      from zrpd_edev_t_dmap
      into table @lt_targets
      where doc_type       = @co_doc_type
        and infotype       = '0006'
        and infotype_field <> @space.

    loop at lt_targets into lv_target.
      assign component lv_target of structure gs_pending to <fs_val>.
      if sy-subrc = 0 and <fs_val> is not initial.
        lv_any = abap_true.
        exit.
      endif.
    endloop.

    if lv_any = abap_true.
      gv_has_pending = abap_true.
      message 'Adres yuklendi' type 'S'.
    else.
      clear gs_pending.
    endif.
  endmethod.

  method process_p0006.
    data lv_tckn     type char11.
    data lv_barcode  type zrpd_edev_de_bcno.
    data lt_fields   type table of sval.
    data ls_field    type sval.
    data lv_rc       type c length 1.
    data lt_vals     type zrpd_edev_tt_dcval.
    data ls_val      type zrpd_edev_s_dcval.
    data lo_edv      type ref to zcl_zrpd_edev_edevlet.
    data lv_ok       type abap_bool.
    data lv_pdf      type xstring.
    data lo_base     type ref to zcl_zrpd_edev_doc_base.
    data lo_ocr      type ref to zcl_zrpd_edev_ocr_py.
    data lv_text     type string.
    data lv_upper    type string.
    data lo_parser   type ref to zcl_zrpd_edev_doc_base.
    data lx_root     type ref to cx_root.
    data lv_errmsg   type string.
    data lv_fn       type zrpd_edev_de_fldnm.
    data lv_it_field type zrpd_edev_de_iflnm.
    data lv_append   type string.
    data: begin of ls_grp,
            it_field type zrpd_edev_de_iflnm,
            value    type string,
          end of ls_grp.
    data lt_grp like sorted table of ls_grp with unique key it_field.
    field-symbols <ls_grp> like ls_grp.
    field-symbols <fs_val> type any.

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

        lv_ok = lo_edv->verify(
          iv_barcode = lv_barcode
          iv_tckn    = lv_tckn ).
        if lv_ok <> abap_true.
          message 'Barkod GECERSIZ' type 'S' display like 'E'.
          return.
        endif.

        lv_pdf = lo_edv->fetch_pdf(
          iv_barcode = lv_barcode
          iv_tckn    = lv_tckn ).
        if lv_pdf is initial.
          message 'Belge indirilemedi' type 'S' display like 'E'.
          return.
        endif.

        create object lo_base type zcl_zrpd_edev_doc_ika.
        lv_text = lo_base->pdf_to_text( lv_pdf ).
        lv_upper = to_upper( lv_text ).
        if lv_text is initial
          or ( lv_upper ns 'KIMLIK' and lv_upper ns 'YERLESIM' and lv_upper ns 'ADRES' ).
          create object lo_ocr.
          lv_text = lo_ocr->extract_text( lv_pdf ).
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
          if ls_val-field_value is initial. continue. endif.

          clear lv_it_field.
          select single infotype_field
            from zrpd_edev_t_dmap
            into @lv_it_field
            where doc_type   = @co_doc_type
              and infotype   = '0006'
              and field_name = @lv_fn.
          if sy-subrc <> 0 or lv_it_field is initial. continue. endif.

          lv_append = ls_val-field_value.
          if lv_fn = 'blok'.
            lv_append = |{ ls_val-field_value } Blok|.
          elseif lv_fn = 'il'.
            lv_append = get_plate_code( ls_val-field_value ).
            if lv_append is initial. continue. endif.
          endif.

          read table lt_grp assigning <ls_grp> with table key it_field = lv_it_field.
          if sy-subrc = 0.
            if <ls_grp>-value is initial.
              <ls_grp>-value = lv_append.
            else.
              <ls_grp>-value = |{ <ls_grp>-value } { lv_append }|.
            endif.
          else.
            clear ls_grp.
            ls_grp-it_field = lv_it_field.
            ls_grp-value    = lv_append.
            insert ls_grp into table lt_grp.
          endif.
        endloop.

      catch cx_root into lx_root.
        lv_errmsg = lx_root->get_text( ).
        if strlen( lv_errmsg ) > 200.
          lv_errmsg = lv_errmsg(200).
        endif.
        message lv_errmsg type 'S' display like 'E'.
        return.
    endtry.

    loop at lt_grp into ls_grp.
      assign component ls_grp-it_field of structure cs_0006 to <fs_val>.
      if sy-subrc = 0.
        <fs_val> = ls_grp-value.
      endif.
    endloop.

  endmethod.

endclass.
