class ZCL_ZRPD_EDEV_DOC_AIL definition
  public
  inheriting from ZCL_ZRPD_EDEV_DOC_BASE
  final
  create public .

public section.

  methods GET_DOC_TYPE
    redefinition .
  methods PARSE_FIELDS
    redefinition .
  methods VALIDATE_CONTENT
    redefinition .
  private section.
    methods find_table_bounds
      importing
        it_lines     type string_table
      exporting
        ev_start_idx type i
        ev_end_idx   type i.

    methods collect_row_groups
      importing
        it_lines         type string_table
        iv_start         type i
        iv_end           type i
      returning
        value(rt_groups) type string_table.

    methods parse_row_group
      importing
        iv_group type string
        iv_idx   type i
      changing
        ct_vals  type zrpd_edev_tt_dcval.

    methods convert_gender
      importing
        iv_cin        type string
      returning
        value(rv_sex) type string.

    methods normalize_yakinlik
      importing
        iv_raw           type string
      returning
        value(rv_normal) type string.

    methods should_skip_row
      importing
        iv_yakinlik    type string
      returning
        value(rv_skip) type abap_bool.

    methods tr_to_ascii
      changing
        cv_text type string.

    methods append_row_field
      importing
        iv_row_idx    type i
        iv_name       type string
        iv_value      type string
        iv_confidence type string
      changing
        ct_vals       type zrpd_edev_tt_dcval.

    methods append_field
      importing
        iv_name       type string
        iv_value      type string
        iv_confidence type string
      changing
        ct_vals       type zrpd_edev_tt_dcval.

ENDCLASS.



CLASS ZCL_ZRPD_EDEV_DOC_AIL IMPLEMENTATION.


  method append_field.
    data ls_val type zrpd_edev_s_dcval.
    ls_val-field_name     = iv_name.
    ls_val-field_value    = iv_value.
    ls_val-confidence     = iv_confidence.
    ls_val-extract_method = 'FORM'.
    append ls_val to ct_vals.
  endmethod.


  method append_row_field.
    data ls_val type zrpd_edev_s_dcval.
    ls_val-field_name     = |row_{ iv_row_idx }__{ iv_name }|.
    ls_val-field_value    = iv_value.
    ls_val-confidence     = iv_confidence.
    ls_val-extract_method = 'FORM'.
    append ls_val to ct_vals.
  endmethod.


  method collect_row_groups.
    data: lv_line      type string,
          lv_idx       type i,
          lv_group_buf type string,
          lv_has_tckn  type abap_bool,
          lv_off       type i,
          lv_len       type i,
          lv_norm      type string,
          lt_lookback  type string_table,
          lv_lb_line   type string,
          lv_is_yak    type abap_bool,
          lv_yak_open  type abap_bool,
          lv_nl        type string.
    constants c_lb_size type i value 4.

    lv_nl        = cl_abap_char_utilities=>newline.
    lv_has_tckn  = abap_false.
    lv_group_buf = ''.

    loop at it_lines into lv_line.
      lv_idx = sy-tabix.
      if lv_idx <= iv_start or lv_idx > iv_end.
        continue.
      endif.

      lv_norm = lv_line.
      condense lv_norm.
      lv_norm = to_upper( lv_norm ).
      tr_to_ascii( changing cv_text = lv_norm ).
      lv_is_yak = boolc(
        lv_norm = 'KENDISI' or lv_norm = 'ESI' or lv_norm = 'KIZI' or lv_norm = 'OGLU'
        or lv_norm = 'BABASI' or lv_norm = 'ANNESI'
        or lv_norm = 'ABLASI' or lv_norm = 'AGABEYI'
        or lv_norm = 'KARDESI' ).

      if lv_is_yak = abap_true.
        if lv_has_tckn = abap_true and lv_group_buf <> ''.
          append lv_group_buf to rt_groups.
        endif.
        lv_group_buf = ''.
        loop at lt_lookback into lv_lb_line.
          if lv_group_buf = ''.
            lv_group_buf = lv_lb_line.
          else.
            lv_group_buf = |{ lv_group_buf }{ lv_nl }{ lv_lb_line }|.
          endif.
        endloop.
        if lv_group_buf = ''.
          lv_group_buf = lv_line.
        else.
          lv_group_buf = |{ lv_group_buf }{ lv_nl }{ lv_line }|.
        endif.
        lv_has_tckn  = abap_true.
        lv_yak_open  = abap_true.
        clear lt_lookback.
        continue.
      endif.

      find first occurrence of regex '[1-9]\d{10}'
        in lv_line match offset lv_off match length lv_len.

      if sy-subrc = 0.
        if lv_yak_open = abap_true.
          lv_group_buf = |{ lv_group_buf }{ lv_nl }{ lv_line }|.
          lv_yak_open = abap_false.
          clear lt_lookback.
        else.
          if lv_has_tckn = abap_true and lv_group_buf <> ''.
            append lv_group_buf to rt_groups.
          endif.
          lv_group_buf = lv_line.
          lv_has_tckn  = abap_true.
        endif.
      else.
        append lv_line to lt_lookback.
        if lines( lt_lookback ) > c_lb_size.
          delete lt_lookback index 1.
        endif.
        if lv_has_tckn = abap_true.
          lv_group_buf = |{ lv_group_buf }{ lv_nl }{ lv_line }|.
        endif.
      endif.
    endloop.

    if lv_has_tckn = abap_true and lv_group_buf <> ''.
      append lv_group_buf to rt_groups.
    endif.
  endmethod.


  method convert_gender.
    rv_sex = cond #( when to_upper( iv_cin ) = 'E' then '1'
                     when to_upper( iv_cin ) = 'K' then '2'
                     else '' ).
  endmethod.


  method find_table_bounds.
    data: lv_line  type string,
          lv_upper type string,
          lv_idx   type i,
          lv_total type i.

    ev_start_idx = 0.
    ev_end_idx   = 0.
    lv_total = lines( it_lines ).

    loop at it_lines into lv_line.
      lv_idx = sy-tabix.
      lv_upper = to_upper( lv_line ).
      tr_to_ascii( changing cv_text = lv_upper ).

      if ev_start_idx = 0.
        if lv_upper cs 'YAKINLIK'.
          ev_start_idx = lv_idx.
        endif.
        continue.
      endif.

      if lv_upper cs 'ACIKLAMALAR' or lv_upper cs 'DUSUNCELER'.
        ev_end_idx = lv_idx - 1.
        return.
      endif.
    endloop.

    if ev_end_idx = 0 and ev_start_idx > 0.
      ev_end_idx = lv_total.
    endif.
  endmethod.


  method get_doc_type.
    rv_type = 'AILE'.
  endmethod.


  method normalize_yakinlik.
    rv_normal = to_upper( iv_raw ).
    tr_to_ascii( changing cv_text = rv_normal ).
    condense rv_normal.
  endmethod.


  method parse_fields.
    data: lv_text      type string,
          lv_nbsp      type c length 1,
          lv_repl      type string,
          lv_bc        type string,
          lt_lines     type string_table,
          lt_groups    type string_table,
          lv_start     type i,
          lv_end       type i,
          lv_idx       type i,
          lv_group     type string,
          lv_yak_check type string,
          lv_tckn_off  type i,
          lv_tckn_len  type i,
          lv_left_part type string,
          lt_tokens    type string_table,
          lv_lines_cnt type i,
          lv_token     type string.

    lv_text = iv_text.
    lv_nbsp = cl_abap_conv_in_ce=>uccp( '00A0' ).
    lv_repl = | |.
    replace all occurrences of lv_nbsp in lv_text with lv_repl.

    try.
        lv_bc = extract_barcode( lv_text ).
      catch zcx_zrpd_edev.
    endtry.
    append_field(
      exporting
        iv_name       = 'barkod'
        iv_value      = lv_bc
        iv_confidence = cond #( when lv_bc = '' then '0.00' else '100.00' )
      changing ct_vals = rt_vals ).

    split lv_text at cl_abap_char_utilities=>newline into table lt_lines.

    find_table_bounds(
      exporting it_lines     = lt_lines
      importing ev_start_idx = lv_start
                ev_end_idx   = lv_end ).

    if lv_start = 0.
      return.
    endif.

    lt_groups = collect_row_groups(
      it_lines = lt_lines
      iv_start = lv_start
      iv_end   = lv_end ).

    lv_idx = 0.
    loop at lt_groups into lv_group.
      clear: lv_yak_check, lv_tckn_off, lv_tckn_len,
             lv_left_part, lt_tokens, lv_lines_cnt, lv_token.

      find first occurrence of regex '[1-9]\d{10}'
        in lv_group match offset lv_tckn_off match length lv_tckn_len.
      if sy-subrc = 0 and lv_tckn_off >= 2.
        lv_left_part = lv_group(lv_tckn_off).
        split lv_left_part at cl_abap_char_utilities=>newline into table lt_tokens.
        delete lt_tokens where table_line = ''.
        lv_lines_cnt = lines( lt_tokens ).
        if lv_lines_cnt >= 1.
          lv_token = lt_tokens[ lv_lines_cnt ].
          lv_yak_check = normalize_yakinlik( lv_token ).
        endif.
      endif.

      if should_skip_row( lv_yak_check ) = abap_true.
        continue.
      endif.

      lv_idx = lv_idx + 1.
      parse_row_group(
        exporting
          iv_group = lv_group
          iv_idx   = lv_idx
        changing
          ct_vals  = rt_vals ).
    endloop.
  endmethod.


  method parse_row_group.
    data: lt_lines     type string_table,
          lv_line      type string,
          lv_norm      type string,
          lv_tckn      type string,
          lv_yak       type string,
          lv_cins      type string,
          lv_adi       type string,
          lv_soyad     type string,
          lv_baba      type string,
          lv_ana       type string,
          lv_yer       type string,
          lv_yak_idx   type i,
          lv_tckn_idx  type i,
          lv_stop_idx  type i,
          lv_i         type i,
          lv_total     type i,
          lv_token     type string,
          lv_adi_buf   type string,
          lv_dats      type dats,
          lv_dats_str  type string,
          lv_conf      type string,
          lv_valid     type abap_bool,
          lv_offm      type i,
          lv_lenm      type i,
          lv_tescil    type string,
          lv_evlenme   type string,
          lv_bosanma   type string,
          lv_dogum     type string,
          lv_next_t    type abap_bool,
          lv_next_e    type abap_bool,
          lv_next_b    type abap_bool.
    field-symbols <ls_line> type string.

    split iv_group at cl_abap_char_utilities=>newline into table lt_lines.
    loop at lt_lines assigning <ls_line>.
      condense <ls_line>.
    endloop.
    delete lt_lines where table_line = ''.
    lv_total = lines( lt_lines ).
    if lv_total = 0.
      return.
    endif.

    " yakinlik line index
    lv_yak_idx = 0.
    lv_i = 1.
    while lv_i <= lv_total.
      lv_norm = lt_lines[ lv_i ].
      translate lv_norm to upper case.
      tr_to_ascii( changing cv_text = lv_norm ).
      if lv_norm = 'KENDISI' or lv_norm = 'ESI' or lv_norm = 'KIZI'
         or lv_norm = 'OGLU' or lv_norm = 'BABASI' or lv_norm = 'ANNESI'
         or lv_norm = 'ABLASI' or lv_norm = 'AGABEYI' or lv_norm = 'KARDESI'.
        lv_yak_idx = lv_i.
        lv_yak = lv_norm.
        exit.
      endif.
      lv_i = lv_i + 1.
    endwhile.

    " cinsiyet = yak_idx - 1 (E/K tek harfli satir)
    if lv_yak_idx >= 2.
      lv_token = lt_lines[ lv_yak_idx - 1 ].
      if strlen( lv_token ) = 1.
        lv_cins = to_upper( lv_token ).
      endif.
    endif.

    " TCKN line: yak_idx'ten sonraki ilk 11-haneli regex
    lv_tckn_idx = 0.
    lv_i = lv_yak_idx + 1.
    if lv_i < 1.
      lv_i = 1.
    endif.
    while lv_i <= lv_total.
      find first occurrence of regex '^[1-9]\d{10}$'
        in lt_lines[ lv_i ] match offset lv_offm match length lv_lenm.
      if sy-subrc = 0.
        lv_tckn_idx = lv_i.
        lv_tckn = lt_lines[ lv_i ].
        condense lv_tckn.
        exit.
      endif.
      lv_i = lv_i + 1.
    endwhile.

    if lv_tckn_idx = 0.
      return.
    endif.

    " stop marker line: tckn_idx sonrasi EVLI/BEKAR/DUL/BOSANMIS
    lv_stop_idx = 0.
    lv_i = lv_tckn_idx + 1.
    while lv_i <= lv_total.
      lv_norm = lt_lines[ lv_i ].
      translate lv_norm to upper case.
      tr_to_ascii( changing cv_text = lv_norm ).
      if lv_norm = 'EVLI' or lv_norm = 'BEKAR' or lv_norm = 'DUL'
         or lv_norm = 'BOSANMIS' or lv_norm = 'BEKAR.' or lv_norm = 'EVLI.'
         or lv_norm = 'DUL.' or lv_norm = 'BOSANMIS.'.
        lv_stop_idx = lv_i.
        exit.
      endif.
      lv_i = lv_i + 1.
    endwhile.

    " ADI/SOYAD/BABA/ANA/YER: stop'tan geri sayarak
    if lv_stop_idx >= lv_tckn_idx + 6.
      lv_yer   = lt_lines[ lv_stop_idx - 1 ].
      lv_ana   = lt_lines[ lv_stop_idx - 2 ].
      lv_baba  = lt_lines[ lv_stop_idx - 3 ].
      lv_soyad = lt_lines[ lv_stop_idx - 4 ].

      " ADI = tckn_idx+1 .. stop_idx-5 satirlari space ile birlestir
      lv_adi_buf = ''.
      lv_i = lv_tckn_idx + 1.
      while lv_i <= lv_stop_idx - 5.
        lv_token = lt_lines[ lv_i ].
        if lv_adi_buf is initial.
          lv_adi_buf = lv_token.
        else.
          lv_adi_buf = |{ lv_adi_buf } { lv_token }|.
        endif.
        lv_i = lv_i + 1.
      endwhile.
      lv_adi = lv_adi_buf.

      " stop sonrasi tarihler (TESCIL, EVLENME, BOSANMA, DOGUM)
      lv_next_t = abap_true.
      lv_next_e = abap_false.
      lv_next_b = abap_false.
      lv_i = lv_stop_idx + 1.
      while lv_i <= lv_total.
        lv_token = lt_lines[ lv_i ].
        find first occurrence of regex '^\d{2}\.\d{2}\.\d{4}$'
          in lv_token match offset lv_offm match length lv_lenm.
        if sy-subrc = 0.
          if lv_next_t = abap_true.
            lv_tescil = lv_token.
            lv_next_t = abap_false.
          elseif lv_next_e = abap_true.
            lv_evlenme = lv_token.
            lv_next_e = abap_false.
          elseif lv_next_b = abap_true.
            lv_bosanma = lv_token.
            lv_next_b = abap_false.
          else.
            lv_dogum = lv_token.
          endif.
        else.
          lv_norm = lv_token.
          translate lv_norm to upper case.
          tr_to_ascii( changing cv_text = lv_norm ).
          if lv_norm cs 'EVLENME'.
            lv_next_e = abap_true.
          elseif lv_norm cs 'BOSANMA'.
            lv_next_b = abap_true.
          elseif lv_token cs '----'.
            lv_next_t = abap_false.
            lv_next_e = abap_false.
            lv_next_b = abap_false.
          endif.
        endif.
        lv_i = lv_i + 1.
      endwhile.

      if lv_dogum is initial.
        if lv_evlenme is not initial.
          lv_dogum = lv_evlenme.
          clear lv_evlenme.
        elseif lv_tescil is not initial.
          lv_dogum = lv_tescil.
          clear lv_tescil.
        endif.
      endif.

      if lv_dogum is not initial.
        try.
            lv_dats = parse_date( lv_dogum ).
          catch zcx_zrpd_edev.
            clear lv_dats.
        endtry.
      endif.
    endif.

    lv_valid = validate_tckn( lv_tckn ).
    lv_conf  = cond #( when lv_tckn = '' then '0.00'
                       when lv_valid = abap_true then '100.00'
                       else '50.00' ).

    append_row_field(
      exporting iv_row_idx = iv_idx iv_name = 'erbnr'
                iv_value   = lv_tckn iv_confidence = lv_conf
      changing  ct_vals    = ct_vals ).

    append_row_field(
      exporting iv_row_idx = iv_idx iv_name = 'yakinlik'
                iv_value   = lv_yak iv_confidence = '90.00'
      changing  ct_vals    = ct_vals ).

    append_row_field(
      exporting iv_row_idx = iv_idx iv_name = 'fanam'
                iv_value   = lv_soyad iv_confidence = '85.00'
      changing  ct_vals    = ct_vals ).

    append_row_field(
      exporting iv_row_idx = iv_idx iv_name = 'favor'
                iv_value   = lv_adi iv_confidence = '85.00'
      changing  ct_vals    = ct_vals ).

    append_row_field(
      exporting iv_row_idx = iv_idx iv_name = 'fgbot'
                iv_value   = lv_yer iv_confidence = '80.00'
      changing  ct_vals    = ct_vals ).

    lv_dats_str = cond #( when lv_dats is initial then ''
                          else |{ lv_dats }| ).
    append_row_field(
      exporting iv_row_idx = iv_idx iv_name = 'fgbdt'
                iv_value   = lv_dats_str
                iv_confidence = cond #( when lv_dats_str = '' then '0.00' else '90.00' )
      changing  ct_vals    = ct_vals ).

    append_row_field(
      exporting iv_row_idx = iv_idx iv_name = 'fasex'
                iv_value   = convert_gender( lv_cins ) iv_confidence = '95.00'
      changing  ct_vals    = ct_vals ).
  endmethod.


  method should_skip_row.
    rv_skip = xsdbool( iv_yakinlik = 'KENDISI' ).
  endmethod.


  method tr_to_ascii.
    data lv_char type c length 1.
    lv_char = cl_abap_conv_in_ce=>uccp( '0130' ).
    replace all occurrences of lv_char in cv_text with 'I'.
    lv_char = cl_abap_conv_in_ce=>uccp( '00DC' ).
    replace all occurrences of lv_char in cv_text with 'U'.
    lv_char = cl_abap_conv_in_ce=>uccp( '015E' ).
    replace all occurrences of lv_char in cv_text with 'S'.
    lv_char = cl_abap_conv_in_ce=>uccp( '00C7' ).
    replace all occurrences of lv_char in cv_text with 'C'.
    lv_char = cl_abap_conv_in_ce=>uccp( '00D6' ).
    replace all occurrences of lv_char in cv_text with 'O'.
    lv_char = cl_abap_conv_in_ce=>uccp( '011E' ).
    replace all occurrences of lv_char in cv_text with 'G'.
    lv_char = cl_abap_conv_in_ce=>uccp( '0131' ).
    replace all occurrences of lv_char in cv_text with 'i'.
    lv_char = cl_abap_conv_in_ce=>uccp( '00FC' ).
    replace all occurrences of lv_char in cv_text with 'u'.
    lv_char = cl_abap_conv_in_ce=>uccp( '015F' ).
    replace all occurrences of lv_char in cv_text with 's'.
    lv_char = cl_abap_conv_in_ce=>uccp( '00E7' ).
    replace all occurrences of lv_char in cv_text with 'c'.
    lv_char = cl_abap_conv_in_ce=>uccp( '00F6' ).
    replace all occurrences of lv_char in cv_text with 'o'.
    lv_char = cl_abap_conv_in_ce=>uccp( '011F' ).
    replace all occurrences of lv_char in cv_text with 'g'.
    lv_char = cl_abap_conv_in_ce=>uccp( '00C2' ).
    replace all occurrences of lv_char in cv_text with 'A'.
    lv_char = cl_abap_conv_in_ce=>uccp( '00E2' ).
    replace all occurrences of lv_char in cv_text with 'a'.
    lv_char = cl_abap_conv_in_ce=>uccp( '00CE' ).
    replace all occurrences of lv_char in cv_text with 'I'.
    lv_char = cl_abap_conv_in_ce=>uccp( '00EE' ).
    replace all occurrences of lv_char in cv_text with 'i'.
    lv_char = cl_abap_conv_in_ce=>uccp( '00DB' ).
    replace all occurrences of lv_char in cv_text with 'U'.
    lv_char = cl_abap_conv_in_ce=>uccp( '00FB' ).
    replace all occurrences of lv_char in cv_text with 'u'.
  endmethod.


  method validate_content.
    data: lv_upper type string,
          lv_nbsp  type c length 1,
          lv_repl  type string.

    lv_upper = to_upper( iv_text ).
    lv_nbsp = cl_abap_conv_in_ce=>uccp( '00A0' ).
    lv_repl = | |.
    replace all occurrences of lv_nbsp in lv_upper with lv_repl.
    tr_to_ascii( changing cv_text = lv_upper ).

    rv_valid = xsdbool(
      ( lv_upper cs 'NUFUS KAYIT ORNEGI'
        or lv_upper cs 'NUFUS KAYIT' )
      and ( lv_upper cs 'YAKINLIK'
            or lv_upper cs 'KENDISI' ) ).
  endmethod.
ENDCLASS.
