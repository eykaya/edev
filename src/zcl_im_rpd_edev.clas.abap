class zcl_im_rpd_edev definition
  public
  final
  create public.

  public section.
    interfaces if_ex_hrpad00infty.
    class-methods process_edev.
    class-methods process_command
      importing
        iv_action type string.

  private section.
    constants co_sgui_prog  type progname value 'ZRPD_EDEV_R_SGUI'.
    constants co_mp_p0006   type string   value '(MP000600)P0006'.
    constants co_infty_0006 type infty    value '0006'.
    constants co_cmd_upload type string   value 'UPLOAD'.
    constants co_cmd_view   type string   value 'VIEW'.
    constants co_cmd_delete type string   value 'DELETE'.

    class-data gs_pending         type p0006.
    class-data gv_has_pending     type abap_bool.
    class-data gv_pending_file    type xstring.
    class-data gv_pending_atip    type n length 2.
    class-data gv_pending_pernr   type persno.
    class-data gv_pending_config  type zrpd_djtl_de_confg.
    class-data gv_pending_source  type zrpd_djtl_de_source.
    class-data gv_pending_subty   type subty.
    class-data gv_pending_objps   type pspar-objps.
    class-data gv_pending_sprps   type pspar-sprps.
    class-data gv_pending_endda   type endda.
    class-data gv_pending_begda   type begda.
    class-data gv_pending_seqnr   type pspar-seqnr.
    class-data gv_current_infty   type infty.

    class-methods resolve_mapping
      importing
        iv_infty        type infty
      exporting
        ev_atip         type n
        ev_doc_type     type zrpd_edev_de_dctyp
        ev_parser_class type seoclsname
        ev_found        type abap_bool.

    class-methods get_pernr
      returning
        value(rv_pernr) type persno.

    class-methods process_upload
      importing
        iv_atip     type n
        iv_doc_type type zrpd_edev_de_dctyp
        iv_parser   type seoclsname.
    class-methods process_view.
    class-methods process_delete.

    class-methods get_current_record
      exporting
        ev_pernr type persno
        ev_subty type subty_591a
        ev_confg type zrpd_djtl_de_confg
        ev_filep type zrpd_djtl_de_filep
        ev_found type abap_bool.

    constants co_djtl_class  type seoclsname    value 'ZCL_ZRPD_DJTL_FILE'.

    class-data gv_djtl_checked type abap_bool.
    class-data gv_djtl_avail   type abap_bool.

    class-methods is_djtl_available
      returning
        value(rv_avail) type abap_bool.

    class-methods has_djtl_method
      importing
        iv_method        type seocpdname
      returning
        value(rv_exists) type abap_bool.

    class-methods upload_from_edevlet
      importing
        iv_pernr    type persno
        iv_atip     type n
        iv_doc_type type zrpd_edev_de_dctyp.

    class-methods upload_from_file
      importing
        iv_pernr type persno
        iv_atip  type n.

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

    class-methods generate_confg_id
      returning
        value(rv_confg) type zrpd_djtl_de_confg.

    class-methods fill_pending_key.

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
    data: begin of ls_text,
            nummer type x value '02',
          end of ls_text.
    data: begin of ls_line,
            line(78) type c,
          end of ls_line.
    data lt_ptext  like standard table of ls_line with empty key.
    data lv_pernr8 type char8.
    data lv_subty4 type char4.
    data lv_objps2 type char2.
    data lv_sprps1 type char1.
    data lv_endda8 type char8.
    data lv_begda8 type char8.
    data lv_seqnr3 type char3.
    data lv_key    type char38.

    field-symbols <ls_0006> type p0006.

    " Only IT0006
    if new_innnn-infty <> co_infty_0006.
      return.
    endif.

    " Skip if no pending upload
    if gv_pending_config is initial.
      return.
    endif.

    " Write barcode into 78-char line
    ls_line-line = gv_pending_config.

    " Inline PCL1 EXPORT with correct format: text-version=structure, ptext=table
    lv_pernr8 = new_innnn-pernr.
    lv_subty4 = new_innnn-subty.
    lv_objps2 = new_innnn-objps.
    lv_sprps1 = new_innnn-sprps.
    lv_endda8 = new_innnn-endda.
    lv_begda8 = new_innnn-begda.
    lv_seqnr3 = new_innnn-seqnr.

    concatenate lv_pernr8 '0006' lv_subty4 lv_objps2 lv_sprps1
                lv_endda8 lv_begda8 lv_seqnr3
                into lv_key respecting blanks.

    clear lt_ptext.
    append ls_line-line to lt_ptext.

    export text-version = ls_text
           ptext        = lt_ptext
      to database pcl1(tx) id lv_key.

    " Store key fields for IN_UPDATE DJTL call
    gv_pending_pernr = new_innnn-pernr.
    gv_pending_subty = new_innnn-subty.
    gv_pending_objps = new_innnn-objps.
    gv_pending_sprps = new_innnn-sprps.
    gv_pending_endda = new_innnn-endda.
    gv_pending_begda = new_innnn-begda.
    gv_pending_seqnr = new_innnn-seqnr.
  endmethod.

  method if_ex_hrpad00infty~before_output.
    data lv_atip    type n length 2.
    data lv_found   type abap_bool.
    data lv_doc_type type zrpd_edev_de_dctyp.
    data lv_parser  type seoclsname.
    data lt_targets type standard table of zrpd_edev_de_iflnm.
    data lv_target  type zrpd_edev_de_iflnm.
    data lv_status  type sypfkey.
    field-symbols <ls_0006>     type p0006.
    field-symbols <fs_src>      type any.
    field-symbols <fs_dst>      type any.
    field-symbols <lv_oper>     type c.
    field-symbols <lv_cp_itxex> type any.

    gv_current_infty = innnn-infty.

    resolve_mapping(
      exporting iv_infty = innnn-infty
      importing ev_atip  = lv_atip
                ev_doc_type = lv_doc_type
                ev_parser_class = lv_parser
                ev_found = lv_found ).
    if lv_found = abap_false. return. endif.

    if gv_has_pending = abap_true and innnn-infty = co_infty_0006.
      assign (co_mp_p0006) to <ls_0006>.
      if sy-subrc = 0.
        select distinct infotype_field
          from zrpd_edev_t_dmap
          into table @lt_targets
          where doc_type       = @lv_doc_type
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

    " Upload yapilmissa ITXEX='X' set et (her upload path + her workarea)
    if gv_pending_config is not initial and innnn-infty = co_infty_0006.
      assign (co_mp_p0006) to <ls_0006>.
      if sy-subrc = 0.
        <ls_0006>-itxex = 'X'.
      endif.

      " (SAPFP50M)CPREL workarea (SAP save new_innnn'i bundan build ediyor)
      assign ('(SAPFP50M)CPREL-ITXEX') to <lv_cp_itxex>.
      if sy-subrc = 0.
        <lv_cp_itxex> = 'X'.
      endif.

      " (SAPFP50M)PREL workarea (yedek)
      assign ('(SAPFP50M)PREL-ITXEX') to <lv_cp_itxex>.
      if sy-subrc = 0.
        <lv_cp_itxex> = 'X'.
      endif.

      " (SAPFP50M)PSHDR workarea (SAP HR bazi yerlerde bunu kullaniyor)
      assign ('(SAPFP50M)PSHDR-ITXEX') to <lv_cp_itxex>.
      if sy-subrc = 0.
        <lv_cp_itxex> = 'X'.
      endif.
    endif.

    assign ('(SAPFP50M)PSYST-IOPER') to <lv_oper>.
    if sy-subrc = 0.
      case <lv_oper>.
        when 'INS' or 'MOD' or 'DEL' or 'DIS' or 'LIS9' or 'COP'.
          lv_status = <lv_oper>.
      endcase.
      if lv_status is not initial.
        set pf-status lv_status of program co_sgui_prog.
      endif.
    endif.
  endmethod.

  method if_ex_hrpad00infty~in_update.
    data lv_ok     type abap_bool.
    data lv_filep  type string.
    data lv_msg    type string.
    data lv_pernr  type persno.
    data lv_file   type xstring.
    data lv_source type zrpd_djtl_de_source.
    data lv_config type zrpd_djtl_de_confg.
    data lv_atip   type n length 2.
    data lv_subty  type subty.
    data lv_objps  type pspar-objps.
    data lv_sprps  type pspar-sprps.
    data lv_endda  type endda.
    data lv_begda  type begda.
    data lv_seqnr  type pspar-seqnr.
    data ls_pa0006 type pa0006.

    " Tetikleyici: pending file varligi
    if gv_pending_file is initial.
      return.
    endif.

    " Islem icin degerleri topla (key alanlari dahil)
    lv_pernr  = gv_pending_pernr.
    lv_file   = gv_pending_file.
    lv_source = gv_pending_source.
    lv_config = gv_pending_config.
    lv_atip   = gv_pending_atip.
    lv_subty  = gv_pending_subty.
    lv_objps  = gv_pending_objps.
    lv_sprps  = gv_pending_sprps.
    lv_endda  = gv_pending_endda.
    lv_begda  = gv_pending_begda.
    lv_seqnr  = gv_pending_seqnr.

    " Pending state temizle (tum key alanlari dahil, tek sefer garantisi)
    clear: gv_pending_file, gv_pending_atip, gv_pending_pernr,
           gv_pending_source, gv_pending_config,
           gv_pending_subty, gv_pending_objps, gv_pending_sprps,
           gv_pending_endda, gv_pending_begda, gv_pending_seqnr.

    " PA0006 aktif kaydini bul (sy-datum icinde gecerli)
    select single pernr, subty, objps, sprps, endda, begda, seqnr, itxex
      from pa0006
      where pernr = @lv_pernr
        and endda ge @sy-datum
        and begda le @sy-datum
      into corresponding fields of @ls_pa0006.
    if sy-subrc ne 0.
      return.
    endif.

    if has_djtl_method( 'WRITE_FILE_AND_CREATE_RECORD' ) = abap_false.
      message 'DJTL paketi bulunamadi, dokuman saklanamadi' type 'S' display like 'W'.
      return.
    endif.

    try.
        call method ('ZCL_ZRPD_DJTL_FILE')=>('WRITE_FILE_AND_CREATE_RECORD')
          exporting
            iv_pernr     = lv_pernr
            iv_subtyp    = lv_atip
            iv_begda     = sy-datum
            iv_file_data = lv_file
            iv_source    = lv_source
            iv_config    = lv_config
          importing
            ev_xuploaded = lv_ok
            ev_filename  = lv_filep
            ev_message   = lv_msg.
      catch cx_sy_dyn_call_illegal_class.
        message 'DJTL paketi bulunamadi' type 'S' display like 'W'.
        return.
      catch cx_root.
        message 'DJTL dosya yazim hatasi' type 'S' display like 'W'.
        return.
    endtry.

  endmethod.

  method process_command.
    data lv_atip      type n length 2.
    data lv_doc_type  type zrpd_edev_de_dctyp.
    data lv_parser    type seoclsname.
    data lv_found     type abap_bool.

    resolve_mapping(
      exporting iv_infty        = gv_current_infty
      importing ev_atip         = lv_atip
                ev_doc_type     = lv_doc_type
                ev_parser_class = lv_parser
                ev_found        = lv_found ).

    if lv_found = abap_false.
      message 'Bu bilgi tipi icin belge eslesmesi bulunamadi' type 'S' display like 'W'.
      return.
    endif.

    case iv_action.
      when co_cmd_upload.
        process_upload(
          iv_atip     = lv_atip
          iv_doc_type = lv_doc_type
          iv_parser   = lv_parser ).
      when co_cmd_view.
        process_view( ).
      when co_cmd_delete.
        process_delete( ).
    endcase.
  endmethod.

  method resolve_mapping.
    clear: ev_atip, ev_doc_type, ev_parser_class.
    ev_found = abap_false.

    select single djtl_atip, doc_type, parser_class
      from zrpd_edev_t_dtyp
      into (@ev_atip, @ev_doc_type, @ev_parser_class)
      where infotype = @iv_infty
        and active   = 'X'.
    if sy-subrc = 0.
      ev_found = abap_true.
    endif.
  endmethod.

  method get_pernr.
    field-symbols <lv_pernr> type persno.
    assign ('(SAPFP50M)PSPAR-PERNR') to <lv_pernr>.
    if sy-subrc = 0.
      rv_pernr = <lv_pernr>.
    endif.
  endmethod.

  method process_upload.
    data lv_pernr  type persno.
    data lv_choice type c length 1.

    lv_pernr = get_pernr( ).
    if lv_pernr is initial.
      message 'PERNR alinamadi' type 'S' display like 'E'.
      return.
    endif.

    if iv_parser is not initial.
      call function 'POPUP_TO_DECIDE'
        exporting
          titel        = 'Belge Yukleme'
          textline1    = 'Belge yukleme yontemi secin'
          text_option1 = 'e-Devlet Barkod ile yukle'
          text_option2 = 'Dosyadan yukle'
        importing
          answer       = lv_choice.
      if lv_choice = 'A'.
        return.
      endif.

      case lv_choice.
        when '1'.
          upload_from_edevlet(
            iv_pernr    = lv_pernr
            iv_atip     = iv_atip
            iv_doc_type = iv_doc_type ).
        when '2'.
          upload_from_file(
            iv_pernr = lv_pernr
            iv_atip  = iv_atip ).
      endcase.
    else.
      upload_from_file(
        iv_pernr = lv_pernr
        iv_atip  = iv_atip ).
    endif.
  endmethod.

  method upload_from_edevlet.
    data lv_doc_type_const type zrpd_edev_de_dctyp.
    data lt_targets type standard table of zrpd_edev_de_iflnm.
    data lv_target  type zrpd_edev_de_iflnm.
    data lv_any     type abap_bool.
    field-symbols <fs_val> type any.

    lv_doc_type_const = iv_doc_type.

    clear gs_pending.
    clear gv_has_pending.

    gs_pending-pernr = iv_pernr.
    process_p0006( changing cs_0006 = gs_pending ).

    gv_pending_atip   = iv_atip.
    gv_pending_pernr  = iv_pernr.
    gv_pending_source = '01'.

    select distinct infotype_field
      from zrpd_edev_t_dmap
      into table @lt_targets
      where doc_type       = @lv_doc_type_const
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
      fill_pending_key( ).
      message 'Belge yuklendi, kaydetmek icin Save yapin' type 'S'.
    else.
      clear gs_pending.
    endif.
  endmethod.

  method upload_from_file.
    data lt_file_table type filetable.
    data lv_rc         type i.
    data lv_filename   type string.
    data lt_rawtab     type table of char255.
    data lv_filelength type i.
    data lv_xstring    type xstring.

    cl_gui_frontend_services=>file_open_dialog(
      exporting
        file_filter = 'PDF (*.pdf)|*.pdf|JPEG (*.jpg)|*.jpg|PNG (*.png)|*.png'
      changing
        file_table = lt_file_table
        rc         = lv_rc
      exceptions others = 5 ).
    if sy-subrc <> 0 or lv_rc < 1. return. endif.

    read table lt_file_table into lv_filename index 1.

    cl_gui_frontend_services=>gui_upload(
      exporting
        filename   = lv_filename
        filetype   = 'BIN'
      importing
        filelength = lv_filelength
      changing
        data_tab   = lt_rawtab
      exceptions others = 19 ).
    if sy-subrc <> 0. return. endif.

    call function 'SCMS_BINARY_TO_XSTRING'
      exporting
        input_length = lv_filelength
      importing
        buffer       = lv_xstring
      tables
        binary_tab   = lt_rawtab
      exceptions others = 2.
    if sy-subrc <> 0.
      message 'Dosya donusturme hatasi' type 'S' display like 'E'.
      return.
    endif.

    gv_pending_file   = lv_xstring.
    gv_pending_atip   = iv_atip.
    gv_pending_pernr  = iv_pernr.
    gv_pending_source = '00'.
    gv_pending_config = generate_confg_id( ).

    fill_pending_key( ).

    message 'Dosya yuklendi, kaydetmek icin Save yapin' type 'S'.
  endmethod.

  method fill_pending_key.
    field-symbols <lv_val> type any.

    clear: gv_pending_subty, gv_pending_objps, gv_pending_sprps,
           gv_pending_endda, gv_pending_begda, gv_pending_seqnr.

    assign ('(SAPFP50M)PSPAR-SUBTY') to <lv_val>.
    if sy-subrc = 0.
      gv_pending_subty = <lv_val>.
    endif.

    assign ('(SAPFP50M)PSPAR-OBJPS') to <lv_val>.
    if sy-subrc = 0.
      gv_pending_objps = <lv_val>.
    endif.

    assign ('(SAPFP50M)PSPAR-SPRPS') to <lv_val>.
    if sy-subrc = 0.
      gv_pending_sprps = <lv_val>.
    endif.

    assign ('(SAPFP50M)PSPAR-ENDDA') to <lv_val>.
    if sy-subrc = 0.
      gv_pending_endda = <lv_val>.
    endif.

    assign ('(SAPFP50M)PSPAR-BEGDA') to <lv_val>.
    if sy-subrc = 0.
      gv_pending_begda = <lv_val>.
    endif.

    assign ('(SAPFP50M)PSPAR-SEQNR') to <lv_val>.
    if sy-subrc = 0.
      gv_pending_seqnr = <lv_val>.
    endif.
  endmethod.

  method generate_confg_id.
    data lv_uuid type sysuuid_x16.
    data lv_hex  type string.

    try.
        lv_uuid = cl_system_uuid=>create_uuid_x16_static( ).
        lv_hex  = lv_uuid.
      catch cx_root.
        lv_hex = |{ sy-datum }{ sy-uzeit }{ sy-uname }|.
    endtry.

    translate lv_hex to upper case.
    shift lv_hex left deleting leading '0'.
    if strlen( lv_hex ) < 16.
      lv_hex = |{ lv_hex }0000000000000000|.
    endif.

    rv_confg = |{ lv_hex(4) }-{ lv_hex+4(4) }-{ lv_hex+8(4) }-{ lv_hex+12(4) }|.
  endmethod.

  method is_djtl_available.
    data lo_descr type ref to cl_abap_typedescr.

    if gv_djtl_checked = abap_true.
      rv_avail = gv_djtl_avail.
      return.
    endif.

    try.
        lo_descr = cl_abap_typedescr=>describe_by_name( co_djtl_class ).
        if lo_descr is bound.
          gv_djtl_avail = abap_true.
        endif.
      catch cx_root.
        gv_djtl_avail = abap_false.
    endtry.

    gv_djtl_checked = abap_true.
    rv_avail = gv_djtl_avail.
  endmethod.

  method has_djtl_method.
    data lo_class type ref to cl_abap_classdescr.
    data lo_descr type ref to cl_abap_typedescr.

    rv_exists = abap_false.
    if is_djtl_available( ) = abap_false.
      return.
    endif.

    try.
        lo_descr ?= cl_abap_typedescr=>describe_by_name( co_djtl_class ).
        lo_class ?= lo_descr.
        if line_exists( lo_class->methods[ name = iv_method ] ).
          rv_exists = abap_true.
        endif.
      catch cx_root.
        rv_exists = abap_false.
    endtry.
  endmethod.

  method get_current_record.
    data lv_pernr type persno.
    data lv_subty type subty_591a.
    data lv_begda type begda.
    data lv_seqnr type seqnr.
    data lv_max   type seqnr.
    field-symbols <lv_subty> type any.
    field-symbols <lv_begda> type any.
    field-symbols <lv_seqnr> type any.

    clear: ev_pernr, ev_subty, ev_confg, ev_filep.
    ev_found = abap_false.

    lv_pernr = get_pernr( ).
    if lv_pernr is initial.
      return.
    endif.

    assign ('(SAPFP50M)PSPAR-SUBTY') to <lv_subty>.
    if sy-subrc = 0.
      lv_subty = <lv_subty>.
    endif.

    assign ('(SAPFP50M)PSPAR-BEGDA') to <lv_begda>.
    if sy-subrc = 0.
      lv_begda = <lv_begda>.
    endif.
    if lv_begda is initial.
      lv_begda = sy-datum.
    endif.

    assign ('(SAPFP50M)PSPAR-SEQNR') to <lv_seqnr>.
    if sy-subrc = 0.
      lv_seqnr = <lv_seqnr>.
    endif.

    if lv_seqnr is initial.
      select single max( seqnr )
        from pa9657
        where pernr = @lv_pernr
          and subty = @lv_subty
          and begda <= @lv_begda
          and endda >= @lv_begda
        into @lv_max.
      if sy-subrc <> 0 or lv_max is initial.
        return.
      endif.
      lv_seqnr = lv_max.
    endif.

    select single confg, filep
      from pa9657
      into (@ev_confg, @ev_filep)
      where pernr = @lv_pernr
        and subty = @lv_subty
        and seqnr = @lv_seqnr
        and begda <= @lv_begda
        and endda >= @lv_begda.
    if sy-subrc = 0.
      ev_pernr = lv_pernr.
      ev_subty = lv_subty.
      ev_found = abap_true.
    endif.
  endmethod.

  method process_view.
    data lv_pernr type persno.
    data lv_subty type subty_591a.
    data lv_confg type zrpd_djtl_de_confg.
    data lv_filep type zrpd_djtl_de_filep.
    data lv_found type abap_bool.

    get_current_record(
      importing
        ev_pernr = lv_pernr
        ev_subty = lv_subty
        ev_confg = lv_confg
        ev_filep = lv_filep
        ev_found = lv_found ).

    if lv_found = abap_false.
      message 'Aktif PA9657 kaydi bulunamadi' type 'S' display like 'W'.
      return.
    endif.

    if has_djtl_method( 'VIEW_DOCUMENT' ) = abap_false.
      message 'DJTL paketi bulunamadi, dokuman goruntulenemiyor' type 'S' display like 'W'.
      return.
    endif.

    try.
        call method ('ZCL_ZRPD_DJTL_FILE')=>('VIEW_DOCUMENT')
          exporting
            iv_pernr  = lv_pernr
            iv_subtyp = lv_subty
            iv_config = lv_confg.
      catch cx_root.
        message 'DJTL goruntuleme hatasi' type 'S' display like 'W'.
    endtry.
  endmethod.

  method process_delete.
    data lv_pernr  type persno.
    data lv_subty  type subty_591a.
    data lv_confg  type zrpd_djtl_de_confg.
    data lv_filep  type zrpd_djtl_de_filep.
    data lv_found  type abap_bool.
    data lv_answer type c length 1.
    data lv_ok     type abap_bool.
    data lv_msg    type string.

    get_current_record(
      importing
        ev_pernr = lv_pernr
        ev_subty = lv_subty
        ev_confg = lv_confg
        ev_filep = lv_filep
        ev_found = lv_found ).

    if lv_found = abap_false.
      message 'Aktif PA9657 kaydi bulunamadi' type 'S' display like 'W'.
      return.
    endif.

    if has_djtl_method( 'DELETE_DOCUMENT' ) = abap_false.
      message 'DJTL paketi bulunamadi, dokuman silinemiyor' type 'S' display like 'W'.
      return.
    endif.

    call function 'POPUP_TO_CONFIRM'
      exporting
        titlebar              = 'Dokuman Silme Onayi'
        text_question         = 'Bu islem PA9657 kaydiyla birlikte AL11 dokumanini da silecek. Devam edilsin mi?'
        default_button        = '2'
        display_cancel_button = abap_false
      importing
        answer                = lv_answer
      exceptions
        text_not_found        = 1
        others                = 2.
    if sy-subrc <> 0 or lv_answer <> '1'.
      return.
    endif.

    try.
        call method ('ZCL_ZRPD_DJTL_FILE')=>('DELETE_DOCUMENT')
          exporting
            iv_pernr              = lv_pernr
            iv_subtyp             = lv_subty
            iv_config             = lv_confg
            iv_filep              = lv_filep
            iv_skip_record_delete = abap_false
          importing
            ev_success            = lv_ok
            ev_message            = lv_msg.

        if lv_ok = abap_true.
          message 'Dokuman ve kayit silindi' type 'S'.
        else.
          message lv_msg type 'S' display like 'W'.
        endif.
      catch cx_root.
        message 'DJTL silme hatasi' type 'S' display like 'W'.
    endtry.
  endmethod.

  method process_edev.
    process_command( co_cmd_upload ).
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
    data lv_doc_type type zrpd_edev_de_dctyp.
    data: begin of ls_grp,
            it_field type zrpd_edev_de_iflnm,
            value    type string,
          end of ls_grp.
    data lt_grp like sorted table of ls_grp with unique key it_field.
    data: begin of ls_map,
            field_name     type zrpd_edev_de_fldnm,
            infotype_field type zrpd_edev_de_iflnm,
          end of ls_map.
    data lt_map like sorted table of ls_map with unique key field_name.
    field-symbols <ls_grp> like ls_grp.
    field-symbols <fs_val> type any.
    field-symbols <ls_map> like ls_map.

    select single doc_type from zrpd_edev_t_dtyp
      into @lv_doc_type
      where infotype = '0006' and active = 'X'.
    if sy-subrc <> 0.
      lv_doc_type = 'IKAMETGAH'.
    endif.

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
        popup_title     = 'e-Devlet Belge Dogrulama'
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

    gv_pending_config = lv_barcode.

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

        gv_pending_file = lv_pdf.

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

    select field_name, infotype_field
      from zrpd_edev_t_dmap
      where doc_type       = @lv_doc_type
        and infotype       = @co_infty_0006
        and infotype_field <> @space
      into corresponding fields of table @lt_map.
    if sy-subrc <> 0. lt_map = value #( ). endif.

    try.
        loop at lt_vals into ls_val.
          lv_fn = ls_val-field_name.
          translate lv_fn to lower case.
          if ls_val-field_value is initial. continue. endif.

          clear lv_it_field.
          read table lt_map assigning <ls_map> with table key field_name = lv_fn.
          if sy-subrc <> 0 or <ls_map>-infotype_field is initial. continue. endif.
          lv_it_field = <ls_map>-infotype_field.

          lv_append = ls_val-field_value.
          if lv_fn = 'blok'.
            lv_append = |{ ls_val-field_value } Blok|.
          elseif lv_fn = 'il'.
            lv_append = get_plate_code( ls_val-field_value ).
            if lv_append is initial.
              continue.
            endif.
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
