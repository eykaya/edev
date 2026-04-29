class zcl_zrpd_edev_doc_mez definition public
  inheriting from zcl_zrpd_edev_doc_base
  create public.

  public section.
    methods get_doc_type      redefinition.
    methods validate_content  redefinition.
    methods parse_fields      redefinition.

  private section.
    methods extract_by_label
      importing
        iv_text         type string
        iv_label        type string
      returning
        value(rv_value) type string.
    methods extract_mez_barcode
      importing
        iv_text           type string
      returning
        value(rv_barcode) type string.
    methods parse_program_segments
      importing
        iv_text       type string
      exporting
        ev_universite type string
        ev_fakulte    type string
        ev_bolum      type string.
    methods append_field
      importing
        iv_name       type string
        iv_value      type string
        iv_confidence type string
      changing
        ct_vals       type zrpd_edev_tt_dcval.

endclass.

class zcl_zrpd_edev_doc_mez implementation.

  method get_doc_type.
    rv_type = 'MEZUNIYET'.
  endmethod.

  method validate_content.
    data lv_upper type string.
    lv_upper = to_upper( iv_text ).
    rv_valid = xsdbool( lv_upper cs 'MEZUN'
                     or lv_upper cs 'YUKSEKOGRETIM'
                     or lv_upper cs 'YOK' ).
  endmethod.

  method parse_fields.
    data: lv_text        type string,
          lv_nbsp        type c length 1,
          lv_repl        type string,
          lv_tckn        type string,
          lv_bc          type string,
          lv_ad_soyad    type string,
          lv_uni         type string,
          lv_fak         type string,
          lv_bol         type string,
          lv_dip_no      type string,
          lv_dip_notu    type string,
          lv_mez_tar_str type string,
          lv_mez_dats    type dats,
          lv_mez_dats_s  type string,
          lv_durum       type string,
          ls_val         type zrpd_edev_s_dcval,
          lv_count       type i.

    " OCR NBSP temizligi
    lv_text = iv_text.
    lv_nbsp = cl_abap_conv_in_ce=>uccp( '00A0' ).
    lv_repl = | |.
    replace all occurrences of lv_nbsp in lv_text with lv_repl.

    " TC KIMLIK NO
    lv_tckn = extract_by_label( iv_text = lv_text iv_label = 'Kimlik No' ).
    if lv_tckn is initial.
      try.
          lv_tckn = extract_tckn( lv_text ).
        catch zcx_zrpd_edev.
      endtry.
    endif.
    append_field(
      exporting
        iv_name       = 'tc_kimlik_no'
        iv_value      = lv_tckn
        iv_confidence = cond #( when lv_tckn = '' then '0.00' else '100.00' )
      changing
        ct_vals       = rt_vals ).

    " BARKOD - kendi regex [A-Z0-9]{18}
    lv_bc = extract_mez_barcode( lv_text ).
    append_field(
      exporting
        iv_name       = 'barkod'
        iv_value      = lv_bc
        iv_confidence = cond #( when lv_bc = '' then '0.00' else '100.00' )
      changing
        ct_vals       = rt_vals ).

    " AD SOYAD
    lv_ad_soyad = extract_by_label( iv_text = lv_text iv_label = 'Adı Soyadı' ).
    if lv_ad_soyad is initial.
      lv_ad_soyad = extract_by_label( iv_text = lv_text iv_label = 'Adi Soyadi' ).
    endif.
    lv_ad_soyad = to_upper( lv_ad_soyad ).
    append_field(
      exporting
        iv_name       = 'ad_soyad'
        iv_value      = lv_ad_soyad
        iv_confidence = cond #( when lv_ad_soyad = '' then '0.00' else '90.00' )
      changing
        ct_vals       = rt_vals ).

    " PROGRAM SEGMENTLERI (universite / fakulte / bolum)
    parse_program_segments(
      exporting
        iv_text       = lv_text
      importing
        ev_universite = lv_uni
        ev_fakulte    = lv_fak
        ev_bolum      = lv_bol ).

    append_field(
      exporting
        iv_name       = 'uni_metni'
        iv_value      = lv_uni
        iv_confidence = cond #( when lv_uni = '' then '0.00' else '80.00' )
      changing
        ct_vals       = rt_vals ).
    append_field(
      exporting
        iv_name       = 'fakulte_metni'
        iv_value      = lv_fak
        iv_confidence = cond #( when lv_fak = '' then '0.00' else '80.00' )
      changing
        ct_vals       = rt_vals ).
    append_field(
      exporting
        iv_name       = 'bolum_metni'
        iv_value      = lv_bol
        iv_confidence = cond #( when lv_bol = '' then '0.00' else '80.00' )
      changing
        ct_vals       = rt_vals ).

    " DIPLOMA NO
    lv_dip_no = extract_by_label( iv_text = lv_text iv_label = 'Diploma No' ).
    append_field(
      exporting
        iv_name       = 'diploma_no'
        iv_value      = lv_dip_no
        iv_confidence = cond #( when lv_dip_no = '' then '0.00' else '80.00' )
      changing
        ct_vals       = rt_vals ).

    " DIPLOMA NOTU
    lv_dip_notu = extract_by_label( iv_text = lv_text iv_label = 'Diploma Notu' ).
    append_field(
      exporting
        iv_name       = 'diploma_notu'
        iv_value      = lv_dip_notu
        iv_confidence = cond #( when lv_dip_notu = '' then '0.00' else '80.00' )
      changing
        ct_vals       = rt_vals ).

    " MEZUNIYET TARIHI
    lv_mez_tar_str = extract_by_label( iv_text = lv_text iv_label = 'Mezuniyet Tarihi' ).
    if lv_mez_tar_str is not initial.
      try.
          lv_mez_dats = parse_date( lv_mez_tar_str ).
        catch zcx_zrpd_edev.
          clear lv_mez_dats.
      endtry.
    endif.
    if lv_mez_dats ne '00000000' and lv_mez_dats is not initial.
      lv_mez_dats_s = lv_mez_dats.
      append_field(
        exporting
          iv_name       = 'mezuniyet_tarihi'
          iv_value      = lv_mez_dats_s
          iv_confidence = '100.00'
        changing
          ct_vals       = rt_vals ).
    else.
      append_field(
        exporting
          iv_name       = 'mezuniyet_tarihi'
          iv_value      = ''
          iv_confidence = '0.00'
        changing
          ct_vals       = rt_vals ).
    endif.

    " DURUM
    lv_durum = extract_by_label( iv_text = lv_text iv_label = 'Durum' ).
    append_field(
      exporting
        iv_name       = 'durum'
        iv_value      = lv_durum
        iv_confidence = cond #( when lv_durum = '' then '0.00' else '90.00' )
      changing
        ct_vals       = rt_vals ).

    " En az 1 alan dolu olmali
    lv_count = 0.
    loop at rt_vals into ls_val.
      if ls_val-field_value is not initial.
        lv_count = lv_count + 1.
      endif.
    endloop.
    if lv_count = 0.
      raise exception type zcx_zrpd_edev
        exporting mv_msgv1 = 'No fields extracted'.
    endif.
  endmethod.

  method extract_by_label.
    data lt_lines    type standard table of string with empty key.
    data lv_line     type string.
    data lv_clean    type string.
    data lv_clean_up type string.
    data lv_label_up type string.
    data lv_found    type abap_bool.

    lv_label_up = to_upper( iv_label ).
    lv_found    = abap_false.

    split iv_text at cl_abap_char_utilities=>newline into table lt_lines.

    loop at lt_lines into lv_line.
      lv_clean    = lv_line.
      condense lv_clean.
      lv_clean_up = to_upper( lv_clean ).

      if lv_found = abap_false.
        " Label match: Program icin tam eslesme, digerleri icin substring yeterli
        if iv_label = 'Program'.
          if lv_clean_up = lv_label_up.
            lv_found = abap_true.
          endif.
        elseif lv_clean_up cs lv_label_up.
          lv_found = abap_true.
        endif.
        continue.
      endif.

      " Label bulundu - ilk non-empty, sadece ':' olmayan satir
      if lv_clean is initial or lv_clean = ':'.
        continue.
      endif.

      " ':' ile basliyorsa prefix temizle
      if strlen( lv_clean ) > 0 and lv_clean(1) = ':'.
        lv_clean = lv_clean+1.
        condense lv_clean.
      endif.

      rv_value = lv_clean.
      return.
    endloop.
  endmethod.

  method extract_mez_barcode.
    data: lv_search type string,
          lv_offset type i,
          lv_length type i,
          lv_len    type i.

    " YOK barkodu: 18 karakter, buyuk harf + rakam, dash YOK
    " Ilk 500 char icinde ara (genellikle sayfa ustunde)
    lv_len = strlen( iv_text ).
    if lv_len > 500.
      lv_search = iv_text(500).
    else.
      lv_search = iv_text.
    endif.

    find first occurrence of regex '[A-Z0-9]{18}'
      in lv_search match offset lv_offset match length lv_length.
    if sy-subrc = 0.
      rv_barcode = substring(
        val = lv_search
        off = lv_offset
        len = lv_length ).
    else.
      " Tum metinde ara (fallback)
      find first occurrence of regex '[A-Z0-9]{18}'
        in iv_text match offset lv_offset match length lv_length.
      if sy-subrc = 0.
        rv_barcode = substring(
          val = iv_text
          off = lv_offset
          len = lv_length ).
      endif.
    endif.
  endmethod.

  method parse_program_segments.
    data lt_lines   type standard table of string with empty key.
    data lv_line    type string.
    data lv_clean   type string.
    data lv_cup     type string.
    data lv_collect type string.
    data lv_in_prog type abap_bool.
    data lt_segs    type standard table of string with empty key.
    data lv_seg     type string.

    clear: ev_universite, ev_fakulte, ev_bolum.
    lv_in_prog = abap_false.

    split iv_text at cl_abap_char_utilities=>newline into table lt_lines.

    loop at lt_lines into lv_line.
      lv_clean = lv_line.
      condense lv_clean.
      lv_cup = to_upper( lv_clean ).

      if lv_in_prog = abap_false.
        if lv_cup = 'PROGRAM'.
          lv_in_prog = abap_true.
        endif.
        continue.
      endif.

      " Stop conditions: bos satir, sadece ':', bilinen label basliklari
      if lv_clean is initial
        or lv_clean = ':'
        or lv_cup cs 'DIPLOMA'
        or lv_cup cs 'TARIHI'
        or lv_cup cs 'DURUM'
        or lv_cup cs 'BELIRTILEN'.
        exit.
      endif.

      " Collect: birden fazla satiri birlestir
      if lv_collect is initial.
        lv_collect = lv_clean.
      else.
        lv_collect = |{ lv_collect } { lv_clean }|.
      endif.
    endloop.

    if lv_collect is initial.
      return.
    endif.

    split lv_collect at '/' into table lt_segs.

    read table lt_segs index 1 into lv_seg.
    if sy-subrc = 0.
      condense lv_seg.
      if strlen( lv_seg ) gt 80.
        ev_universite = lv_seg(80).
      else.
        ev_universite = lv_seg.
      endif.
    endif.

    read table lt_segs index 2 into lv_seg.
    if sy-subrc = 0.
      condense lv_seg.
      ev_fakulte = lv_seg.
    endif.

    read table lt_segs index 3 into lv_seg.
    if sy-subrc = 0.
      condense lv_seg.
      if strlen( lv_seg ) gt 40.
        ev_bolum = lv_seg(40).
      else.
        ev_bolum = lv_seg.
      endif.
    endif.
  endmethod.

  method append_field.
    data ls_val type zrpd_edev_s_dcval.
    ls_val-field_name     = iv_name.
    ls_val-field_value    = iv_value.
    ls_val-confidence     = iv_confidence.
    ls_val-extract_method = 'FORM'.
    append ls_val to ct_vals.
  endmethod.

endclass.
