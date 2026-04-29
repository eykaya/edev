class zcl_im_rpd_edev definition
  public
  final
  create public.

  public section.
    interfaces if_ex_hrpad00infty.
    class-methods process_edev.
    "! Dokuman sil butonundan tetiklenir
    class-methods process_edev_delete.
    class-methods process_command
      importing
        iv_action type string.

  private section.
    constants co_sgui_prog  type progname value 'ZRPD_EDEV_R_SGUI'.
    constants co_mp_p0006   type string   value '(MP000600)P0006'.
    constants co_infty_0006 type infty    value '0006'.
    constants co_mp_p0770   type string   value '(MP077000)P0770'.
    constants co_infty_0770 type infty    value '0770'.
    constants co_cmd_upload type string   value 'UPLOAD'.
    constants co_cmd_view   type string   value 'VIEW'.
    constants co_cmd_delete type string   value 'DELETE'.

    class-data gs_pending      type p0006.
    class-data gs_pending_0770 type p0770.
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
    class-data gv_f9_written      type abap_bool.
    class-data gv_current_infty   type infty.

    class-data gv_curr_pernr   type persno.
    class-data gv_curr_subty   type subty_591a.
    class-data gv_curr_objps   type pspar-objps.
    class-data gv_curr_sprps   type pspar-sprps.
    class-data gv_curr_begda   type begda.
    class-data gv_curr_endda   type endda.
    class-data gv_curr_seqnr   type pspar-seqnr.

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

    class-methods upload_from_edevlet_0770
      importing
        iv_pernr    type persno
        iv_atip     type n
        iv_doc_type type zrpd_edev_de_dctyp.

    class-methods upload_from_file
      importing
        iv_pernr type persno
        iv_atip  type n.

    class-methods upload_from_file_0770
      importing
        iv_pernr    type persno
        iv_atip     type n
        iv_doc_type type zrpd_edev_de_dctyp.

    class-methods process_p0006
      changing
        cs_0006 type p0006.

    class-methods process_p0770
      changing
        cs_0770 type p0770.

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

    "! Nufus servis ile TC kontrolü — ZRPD_TC_CHECK BAdI'sinin mantigi paket içine taşındı
    class-methods tc_online_check
      importing
        iv_merni           type ptr_merni
        iv_vorna           type vorna
        iv_nachn           type nachn
        iv_dogum_str       type string
      returning
        value(rt_messages) type bapiret2_t.


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
    data lv_ok_u   type abap_bool.
    data lv_filep_u type string.
    data lv_msg_u  type string.

    field-symbols <ls_0006> type p0006.

    " IT0006 ve IT0770 disindaki infotype'lar atlanir
    if new_innnn-infty <> co_infty_0006 and new_innnn-infty <> co_infty_0770.
      return.
    endif.

    " Skip if no pending upload
    if gv_pending_config is initial.
      return.
    endif.

    " Guard: AFTER_INPUT her SAVE'de 2 kez tetiklenir (HR BADI), tek append yeterli
    if gv_f9_written = abap_true.
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

    concatenate lv_pernr8 new_innnn-infty lv_subty4 lv_objps2 lv_sprps1
                lv_endda8 lv_begda8 lv_seqnr3
                into lv_key respecting blanks.

    " Mevcut F9 text'ini oku -- varsa onceki satirlar korunur
    import text-version = ls_text
           ptext        = lt_ptext
      from database pcl1(tx) id lv_key.
    " sy-subrc=4 ise lt_ptext bos (yeni kayit), 0 ise dolu. Her iki durum da OK.

    " Yeni barkodu AYRI SATIR olarak append et
    clear ls_line.
    ls_line-line = gv_pending_config.
    append ls_line to lt_ptext.

    export text-version = ls_text
           ptext        = lt_ptext
      to database pcl1(tx) id lv_key.

    gv_f9_written = abap_true.

    " Store key fields for DJTL call below
    gv_pending_pernr = new_innnn-pernr.
    gv_pending_subty = new_innnn-subty.
    gv_pending_objps = new_innnn-objps.
    gv_pending_sprps = new_innnn-sprps.
    gv_pending_endda = new_innnn-endda.
    gv_pending_begda = new_innnn-begda.
    gv_pending_seqnr = new_innnn-seqnr.

    " --- DJTL: PA9657 kaydi + AL11 dosya yazimi ---
    " IN_UPDATE'ten tasindi: class-data update task'ta persist etmiyor
    if gv_pending_file is not initial.
      if has_djtl_method( 'WRITE_FILE_AND_CREATE_RECORD' ) = abap_true.
        try.
            call method ('ZCL_ZRPD_DJTL_FILE')=>('WRITE_FILE_AND_CREATE_RECORD')
              exporting
                iv_pernr     = gv_pending_pernr
                iv_subtyp    = gv_pending_subty
                iv_begda     = sy-datum
                iv_file_data = gv_pending_file
                iv_source    = gv_pending_source
                iv_config    = gv_pending_config
              importing
                ev_xuploaded = lv_ok_u
                ev_filename  = lv_filep_u
                ev_message   = lv_msg_u.
          catch cx_root.
            " Silent fail -- save akisini bozma
        endtry.
      endif.

      " Pending state temizle
      clear: gv_pending_file, gv_pending_atip, gv_pending_pernr,
             gv_pending_source, gv_pending_config,
             gv_pending_subty, gv_pending_objps, gv_pending_sprps,
             gv_pending_endda, gv_pending_begda, gv_pending_seqnr.
    endif.
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
    field-symbols <ls_0770>     type p0770.
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

    " IT0006/IT0770 ise cari kayit key'ini sakla (FORM EXIT sync oncesi kullanilir)
    if innnn-infty = co_infty_0006 or innnn-infty = co_infty_0770.
      gv_curr_pernr = innnn-pernr.
      gv_curr_subty = innnn-subty.
      gv_curr_objps = innnn-objps.
      gv_curr_sprps = innnn-sprps.
      gv_curr_begda = innnn-begda.
      gv_curr_endda = innnn-endda.
      gv_curr_seqnr = innnn-seqnr.
    endif.

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

    if gv_has_pending = abap_true and innnn-infty = co_infty_0770.
      assign (co_mp_p0770) to <ls_0770>.
      if sy-subrc = 0.
        select distinct infotype_field
          from zrpd_edev_t_dmap
          into table @lt_targets
          where doc_type       = @lv_doc_type
            and infotype       = '0770'
            and infotype_field <> @space.

        loop at lt_targets into lv_target.
          assign component lv_target of structure gs_pending_0770 to <fs_src>.
          if sy-subrc <> 0. continue. endif.
          if <fs_src> is initial. continue. endif.
          assign component lv_target of structure <ls_0770> to <fs_dst>.
          if sy-subrc <> 0. continue. endif.
          <fs_dst> = <fs_src>.
        endloop.
      endif.

      clear gs_pending_0770.
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

    if gv_pending_config is not initial and innnn-infty = co_infty_0770.
      assign (co_mp_p0770) to <ls_0770>.
      if sy-subrc = 0.
        <ls_0770>-itxex = 'X'.
      endif.

      assign ('(SAPFP50M)CPREL-ITXEX') to <lv_cp_itxex>.
      if sy-subrc = 0.
        <lv_cp_itxex> = 'X'.
      endif.

      assign ('(SAPFP50M)PREL-ITXEX') to <lv_cp_itxex>.
      if sy-subrc = 0.
        <lv_cp_itxex> = 'X'.
      endif.

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
    " Tasindi: AFTER_INPUT
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

    " IT0770 (Kimlik): e-Devlet kanalı yok, dogrudan dosyadan yukle + parse + TC online check
    if gv_current_infty = co_infty_0770.
      upload_from_file_0770(
        iv_pernr    = lv_pernr
        iv_atip     = iv_atip
        iv_doc_type = iv_doc_type ).
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
    data lt_targets        type standard table of zrpd_edev_de_iflnm with empty key.
    data lv_target         type zrpd_edev_de_iflnm.
    data lv_any            type abap_bool.
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
    data lv_seqnr type pspar-seqnr.
    data lv_max   type pspar-seqnr.

    clear: ev_pernr, ev_subty, ev_confg, ev_filep.
    ev_found = abap_false.

    lv_pernr = gv_curr_pernr.
    " PA9657-SUBTY = T_DTYP ATIP (kaynak BT'ye gore, PA-original SUBTY degil)
    data lv_atip_h type n length 2.
    data lv_doc_h  type zrpd_edev_de_dctyp.
    data lv_pars_h type seoclsname.
    data lv_fnd_h  type abap_bool.
    resolve_mapping(
      exporting iv_infty        = gv_current_infty
      importing ev_atip         = lv_atip_h
                ev_doc_type     = lv_doc_h
                ev_parser_class = lv_pars_h
                ev_found        = lv_fnd_h ).
    lv_subty = lv_atip_h.
    lv_begda = gv_curr_begda.
    lv_seqnr = gv_curr_seqnr.

    if lv_pernr is initial.
      return.
    endif.

    if lv_seqnr is initial.
      select single max( seqnr )
        from pa9657
        where pernr = @lv_pernr
          and subty = @lv_subty
          and begda <= @sy-datum
          and endda >= @sy-datum
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
        and begda <= @sy-datum
        and endda >= @sy-datum.
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
    " PCL1 key yapisi: pernr(8) + '0006' + subty(4) + objps(2) + sprps(1) + endda(8) + begda(8) + seqnr(3)
    data: begin of ls_txhdr, nummer type x value '02', end of ls_txhdr.
    data: begin of ls_txrow, line(78) type c, end of ls_txrow.
    data lt_ptext    like standard table of ls_txrow with empty key.
    data lv_pcl1key  type char38.
    data lv_pernr8   type char8.
    data lv_subty4   type char4.
    data lv_objps2   type char2.
    data lv_sprps1   type char1.
    data lv_endda8   type char8.
    data lv_begda8   type char8.
    data lv_seqnr3   type char3.
    data lv_pernr    type persno.
    data lv_subty    type subty_591a.
    data lv_confg    type zrpd_djtl_de_confg.
    data lv_filep    type zrpd_djtl_de_filep.
    data lv_found    type abap_bool.
    data lv_answer   type c length 1.
    data lv_ok       type abap_bool.
    data lv_msg      type string.

    get_current_record(
      importing
        ev_pernr = lv_pernr
        ev_subty = lv_subty
        ev_confg = lv_confg
        ev_filep = lv_filep
        ev_found = lv_found ).

    if lv_found = abap_false.
      message 'Aktif PA9657 kaydi bulunamadi' type 'S' display like 'W'.
      set screen sy-dynnr.
      leave screen.
    endif.

    if has_djtl_method( 'DELETE_DOCUMENT' ) = abap_false.
      message 'DJTL paketi bulunamadi, dokuman silinemiyor' type 'S' display like 'W'.
      set screen sy-dynnr.
      leave screen.
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
      catch cx_root.
        lv_ok  = abap_false.
        lv_msg = 'DJTL silme hatasi'.
    endtry.

    " PCL1 F9 barkod temizligi -- DJTL sonucundan bagimsiz
    lv_pernr8 = gv_curr_pernr.
    lv_subty4 = gv_curr_subty.
    lv_objps2 = gv_curr_objps.
    lv_sprps1 = gv_curr_sprps.
    lv_endda8 = gv_curr_endda.
    lv_begda8 = gv_curr_begda.
    lv_seqnr3 = gv_curr_seqnr.
    concatenate lv_pernr8 '0006' lv_subty4 lv_objps2 lv_sprps1
                lv_endda8 lv_begda8 lv_seqnr3
                into lv_pcl1key respecting blanks.

    import text-version = ls_txhdr ptext = lt_ptext
      from database pcl1(tx) id lv_pcl1key.
    if sy-subrc = 0.
      delete lt_ptext where line = lv_confg.
      if lt_ptext is initial.
        delete from database pcl1(tx) id lv_pcl1key.
        update pa0006 set itxex = ' '
          where pernr = @gv_curr_pernr
            and subty = @gv_curr_subty
            and objps = @gv_curr_objps
            and sprps = @gv_curr_sprps
            and endda = @gv_curr_endda
            and begda = @gv_curr_begda
            and seqnr = @gv_curr_seqnr ##SUBRC_OK.
      else.
        export text-version = ls_txhdr ptext = lt_ptext
          to database pcl1(tx) id lv_pcl1key.
      endif.
      commit work.
    endif.

    if lv_ok = abap_true.
      message 'Dokuman ve kayit silindi' type 'S'.
    else.
      message lv_msg type 'S' display like 'W'.
    endif.
    set screen sy-dynnr.
    leave screen.
  endmethod.


  method process_edev.
    process_command( co_cmd_upload ).
  endmethod.

  method process_edev_delete.
    process_command( co_cmd_delete ).
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

  method process_p0770.
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
      where infotype = @co_infty_0770 and active = 'X'.
    if sy-subrc <> 0.
      lv_doc_type = 'KIMLIK'.
    endif.

    select single merni from pa0770
      into lv_tckn
      where pernr = cs_0770-pernr
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

        create object lo_base type zcl_zrpd_edev_doc_kim.
        lv_text = lo_base->pdf_to_text( lv_pdf ).
        lv_upper = to_upper( lv_text ).
        if lv_text is initial
          or ( lv_upper ns 'KIMLIK' and lv_upper ns 'NUFUS' ).
          create object lo_ocr.
          lv_text = lo_ocr->extract_text( lv_pdf ).
        endif.

        create object lo_parser type zcl_zrpd_edev_doc_kim.
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
        and infotype       = @co_infty_0770
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
      assign component ls_grp-it_field of structure cs_0770 to <fs_val>.
      if sy-subrc = 0.
        <fs_val> = ls_grp-value.
      endif.
    endloop.

  endmethod.

  method tc_online_check.
    " ZRPD_TC_CHECK BAdI'sinin online check mantigi — paket içine alindi
    " Input: parse'tan gelen merni/vorna/nachn ve dogum_str ('dd.mm.yyyy' veya 'YYYYMMDD')
    " Output: bapiret2_t — caller 'E' mesaji varsa kimlik gecersiz kabul eder
    " SM59/baglanti hatasi durumunda 'E' mesaji ile gerce kabul edilmez (bos donmez)
    data ls_parm   type zcl_rpd_online_services=>ty_service_params.
    data lo_online type ref to zcl_rpd_online_services.
    data lv_year   type i.
    data lv_str    type string.
    data lx_root   type ref to cx_root.
    data lv_errtxt type string.
    data ls_msg    type bapiret2.

    ls_parm-merni = iv_merni.
    ls_parm-vorna = iv_vorna.
    ls_parm-nachn = iv_nachn.

    " Dogum yili — 'dd.mm.yyyy' icin son 4 hane, 'YYYYMMDD' icin ilk 4 hane
    lv_str = iv_dogum_str.
    if strlen( lv_str ) = 10 and lv_str+2(1) ca './-'.
      lv_year = lv_str+6(4).
    elseif strlen( lv_str ) = 8.
      lv_year = lv_str(4).
    endif.
    ls_parm-gbdat = lv_year.

    try.
        create object lo_online exporting is_parm = ls_parm.
        lo_online->exec( importing et_messages = rt_messages ).
      catch cx_root into lx_root.
        " SM59 baglanti / runtime hatasi — caller'in fail etmesi icin 'E' satir ekle
        clear rt_messages.
        lv_errtxt = lx_root->get_text( ).
        if strlen( lv_errtxt ) > 150.
          lv_errtxt = lv_errtxt(150).
        endif.
        clear ls_msg.
        ls_msg-type    = 'E'.
        ls_msg-id      = 'ZRPD_TC_MESSAGES'.
        ls_msg-number  = '000'.
        ls_msg-message = |TC kontrol servisine erisilemedi (SM59): { lv_errtxt }|.
        append ls_msg to rt_messages.
    endtry.
  endmethod.

  method upload_from_file_0770.
    " IT0770 (Kimlik) dosyadan yukleme:
    " dosya sec → xstring → OCR → DOC_KIM parse → tc_online_check → 'E' yoksa gs_pending_0770 doldur
    data lt_file_table type filetable.
    data lv_rc         type i.
    data lv_filename   type string.
    data lt_rawtab     type table of char255.
    data lv_filelength type i.
    data lv_xstring    type xstring.
    data lo_base       type ref to zcl_zrpd_edev_doc_base.
    data lo_ocr        type ref to zcl_zrpd_edev_ocr_py.
    data lo_parser     type ref to zcl_zrpd_edev_doc_base.
    data lv_text       type string.
    data lv_upper      type string.
    data lt_vals       type zrpd_edev_tt_dcval.
    data ls_val        type zrpd_edev_s_dcval.
    data lv_merni      type ptr_merni.
    data lv_vorna      type vorna.
    data lv_nachn      type nachn.
    data lv_dogum_str  type string.
    data lt_messages   type bapiret2_t.
    data ls_message    type bapiret2.
    data lv_subty      type subty.
    field-symbols <fs_subty> type any.
    data lt_targets    type standard table of zrpd_edev_de_iflnm with empty key.
    data lv_target     type zrpd_edev_de_iflnm.
    data lv_any        type abap_bool.
    data: begin of ls_map,
            field_name     type zrpd_edev_de_fldnm,
            infotype_field type zrpd_edev_de_iflnm,
          end of ls_map.
    data lt_map like sorted table of ls_map with unique key field_name.
    data lv_fn         type zrpd_edev_de_fldnm.
    data lx_root       type ref to cx_root.
    data lv_errmsg     type string.
    field-symbols <fs_val> type any.
    field-symbols <ls_map> like ls_map.

    " 1) Dosya sec
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

    " 2) OCR + parse (DOC_KIM)
    try.
        create object lo_base type zcl_zrpd_edev_doc_kim.
        lv_text = lo_base->pdf_to_text( lv_xstring ).
        lv_upper = to_upper( lv_text ).
        if lv_text is initial
          or ( lv_upper ns 'KIMLIK' and lv_upper ns 'NUFUS' ).
          create object lo_ocr.
          lv_text = lo_ocr->extract_text( lv_xstring ).
        endif.
        create object lo_parser type zcl_zrpd_edev_doc_kim.
        lt_vals = lo_parser->parse_fields( lv_text ).
      catch cx_root into lx_root.
        lv_errmsg = lx_root->get_text( ).
        if strlen( lv_errmsg ) > 200. lv_errmsg = lv_errmsg(200). endif.
        message lv_errmsg type 'S' display like 'E'.
        return.
    endtry.

    if lt_vals is initial.
      message 'Belgeden alan cikarilamadi' type 'S' display like 'W'.
      return.
    endif.

    " 3) TC online check — sadece subty='01' (T.C. Kimlik Karti) icin
    assign ('(SAPFP50M)PSPAR-SUBTY') to <fs_subty>.
    if sy-subrc = 0.
      lv_subty = <fs_subty>.
    endif.

    if lv_subty = '01'.
      " parse'tan vorna/nachn/dogum/merni topla
      loop at lt_vals into ls_val.
        case ls_val-field_name.
          when 'tc_kimlik_no'. lv_merni = ls_val-field_value.
          when 'ad'.           lv_vorna = ls_val-field_value.
          when 'soyad'.        lv_nachn = ls_val-field_value.
          when 'dogum_tarihi'. lv_dogum_str = ls_val-field_value.
        endcase.
      endloop.

      if lv_merni is initial or lv_vorna is initial or lv_nachn is initial.
        message 'Kimlik PDF: TC/Ad/Soyad alinamadi' type 'S' display like 'E'.
        return.
      endif.

      lt_messages = tc_online_check(
        iv_merni     = lv_merni
        iv_vorna     = lv_vorna
        iv_nachn     = lv_nachn
        iv_dogum_str = lv_dogum_str ).

      read table lt_messages into ls_message with key type = 'E'.
      if sy-subrc = 0.
        if ls_message-message is not initial.
          message ls_message-message type 'S' display like 'E'.
        else.
          message id ls_message-id type 'S' number ls_message-number
            with ls_message-message_v1 ls_message-message_v2
                 ls_message-message_v3 ls_message-message_v4
            display like 'E'.
        endif.
        return.
      endif.
    endif.

    " 4) TC check OK — gs_pending_0770 doldur (DMAP esleme)
    clear gs_pending_0770.
    clear gv_has_pending.
    gs_pending_0770-pernr = iv_pernr.

    select field_name, infotype_field
      from zrpd_edev_t_dmap
      where doc_type       = @iv_doc_type
        and infotype       = @co_infty_0770
        and infotype_field <> @space
      into corresponding fields of table @lt_map.
    if sy-subrc <> 0. lt_map = value #( ). endif.

    loop at lt_vals into ls_val.
      if ls_val-field_value is initial. continue. endif.
      lv_fn = ls_val-field_name.
      translate lv_fn to lower case.
      read table lt_map assigning <ls_map> with table key field_name = lv_fn.
      if sy-subrc <> 0 or <ls_map>-infotype_field is initial. continue. endif.
      assign component <ls_map>-infotype_field of structure gs_pending_0770 to <fs_val>.
      if sy-subrc = 0.
        <fs_val> = ls_val-field_value.
      endif.
    endloop.

    " 5) Pending state: dosya + atip + source + config
    gv_pending_file   = lv_xstring.
    gv_pending_atip   = iv_atip.
    gv_pending_pernr  = iv_pernr.
    gv_pending_source = '00'.
    gv_pending_config = generate_confg_id( ).

    select distinct infotype_field
      from zrpd_edev_t_dmap
      into table @lt_targets
      where doc_type       = @iv_doc_type
        and infotype       = @co_infty_0770
        and infotype_field <> @space.
    loop at lt_targets into lv_target.
      assign component lv_target of structure gs_pending_0770 to <fs_val>.
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
      clear gs_pending_0770.
      clear: gv_pending_file, gv_pending_atip, gv_pending_config.
    endif.
  endmethod.

  method upload_from_edevlet_0770.
    data lv_doc_type_const type zrpd_edev_de_dctyp.
    data lt_targets        type standard table of zrpd_edev_de_iflnm with empty key.
    data lv_target         type zrpd_edev_de_iflnm.
    data lv_any            type abap_bool.
    field-symbols <fs_val> type any.

    lv_doc_type_const = iv_doc_type.

    clear gs_pending_0770.
    clear gv_has_pending.

    gs_pending_0770-pernr = iv_pernr.
    process_p0770( changing cs_0770 = gs_pending_0770 ).

    gv_pending_atip   = iv_atip.
    gv_pending_pernr  = iv_pernr.
    gv_pending_source = '01'.

    select distinct infotype_field
      from zrpd_edev_t_dmap
      into table @lt_targets
      where doc_type       = @lv_doc_type_const
        and infotype       = @co_infty_0770
        and infotype_field <> @space.

    loop at lt_targets into lv_target.
      assign component lv_target of structure gs_pending_0770 to <fs_val>.
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
      clear gs_pending_0770.
    endif.

  endmethod.

endclass.
