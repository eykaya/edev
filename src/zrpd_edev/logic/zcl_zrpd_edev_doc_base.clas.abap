class zcl_zrpd_edev_doc_base definition public create public.

  public section.

    methods get_doc_type
      returning
        value(rv_type) type zrpd_edev_de_dctyp.

    methods parse_fields
      importing
        iv_text        type string
      returning
        value(rt_vals) type zrpd_edev_tt_dcval
      raising
        zcx_zrpd_edev_extract.

    methods validate_content
      importing
        iv_text         type string
      returning
        value(rv_valid) type abap_bool.

    methods pdf_to_text
      importing
        iv_pdf         type xstring
      returning
        value(rv_text) type string.

    methods extract_tckn
      importing
        iv_text        type string
      returning
        value(rv_tckn) type string
      raising
        zcx_zrpd_edev_extract.

    methods extract_barcode
      importing
        iv_text           type string
      returning
        value(rv_barcode) type string
      raising
        zcx_zrpd_edev_extract.

    methods validate_tckn
      importing
        iv_tckn         type string
      returning
        value(rv_valid) type abap_bool.

    methods parse_date
      importing
        iv_text        type string
      returning
        value(rv_dats) type dats
      raising
        zcx_zrpd_edev_extract.

  protected section.

    methods digit_at
      importing
        iv_str        type string
        iv_pos        type i
      returning
        value(rv_int) type i.

endclass.

class zcl_zrpd_edev_doc_base implementation.

  method get_doc_type.
    rv_type = ''.
  endmethod.

  method parse_fields.
    raise exception type zcx_zrpd_edev_extract
      exporting
        mv_msgv1 = 'parse_fields not implemented'.
  endmethod.

  method validate_content.
    rv_valid = abap_false.
  endmethod.

  method pdf_to_text.
    " SCMS-based: preserves ASCII digits, alphanumeric, hyphens.
    " TCKN and barcode patterns survive even in garbled text.
    data: lt_bin type standard table of x255,
          lv_len type i.

    call function 'SCMS_XSTRING_TO_BINARY'
      exporting
        buffer        = iv_pdf
      importing
        output_length = lv_len
      tables
        binary_tab    = lt_bin.

    call function 'SCMS_BINARY_TO_STRING'
      exporting
        input_length = lv_len
      importing
        text_buffer  = rv_text
      tables
        binary_tab   = lt_bin
      exceptions
        failed       = 1
        others       = 2.

    if sy-subrc is not initial.
      clear rv_text.
    endif.
  endmethod.

  method extract_tckn.
    " Strategy 1: context-based (within 100 chars after 'Kimlik No')
    " Strategy 2: first 11-digit number starting with non-zero
    data: lv_near   type string,
          lv_offset type i,
          lv_length type i,
          lv_remain type i.

    if iv_text is initial.
      raise exception type zcx_zrpd_edev_extract
        exporting mv_msgv1 = 'Empty text'.
    endif.

    " Strategy 1
    find first occurrence of 'Kimlik No' in iv_text
      ignoring case match offset lv_offset.
    if sy-subrc = 0.
      lv_remain = strlen( iv_text ) - lv_offset.
      if lv_remain > 100.
        lv_remain = 100.
      endif.
      lv_near = substring( val = iv_text off = lv_offset len = lv_remain ).
      find first occurrence of regex '[1-9][0-9]{10}'
        in lv_near match offset lv_offset length lv_length.
      if sy-subrc = 0.
        rv_tckn = substring( val = lv_near off = lv_offset len = lv_length ).
        return.
      endif.
    endif.

    " Strategy 2
    find first occurrence of regex '[1-9][0-9]{10}'
      in iv_text match offset lv_offset length lv_length.
    if sy-subrc = 0.
      rv_tckn = substring( val = iv_text off = lv_offset len = lv_length ).
    else.
      raise exception type zcx_zrpd_edev_extract
        exporting mv_msgv1 = 'TCKN not found'.
    endif.
  endmethod.

  method extract_barcode.
    " NVI barcode: XXXX-XXXX-XXXX-XXXX
    data: lv_offset type i,
          lv_length type i.

    if iv_text is initial.
      raise exception type zcx_zrpd_edev_extract
        exporting mv_msgv1 = 'Empty text'.
    endif.

    find first occurrence of regex '[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}'
      in iv_text match offset lv_offset length lv_length.
    if sy-subrc = 0.
      rv_barcode = substring( val = iv_text off = lv_offset len = lv_length ).
    else.
      raise exception type zcx_zrpd_edev_extract
        exporting mv_msgv1 = 'Barcode not found'.
    endif.
  endmethod.

  method validate_tckn.
    data: lv_len      type i,
          lv_first    type c length 1,
          lv_odd_sum  type i,
          lv_even_sum type i,
          lv_sum10    type i,
          lv_d10_calc type i,
          lv_d10_ref  type i,
          lv_d11_calc type i,
          lv_d11_ref  type i.

    rv_valid = abap_false.
    lv_len = strlen( iv_tckn ).
    if lv_len is initial or lv_len < 11 or lv_len > 11.
      return.
    endif.

    lv_first = substring( val = iv_tckn off = 0 len = 1 ).
    if lv_first = '0'.
      return.
    endif.

    lv_odd_sum  = digit_at( iv_str = iv_tckn iv_pos = 0 )
                + digit_at( iv_str = iv_tckn iv_pos = 2 )
                + digit_at( iv_str = iv_tckn iv_pos = 4 )
                + digit_at( iv_str = iv_tckn iv_pos = 6 )
                + digit_at( iv_str = iv_tckn iv_pos = 8 ).

    lv_even_sum = digit_at( iv_str = iv_tckn iv_pos = 1 )
                + digit_at( iv_str = iv_tckn iv_pos = 3 )
                + digit_at( iv_str = iv_tckn iv_pos = 5 )
                + digit_at( iv_str = iv_tckn iv_pos = 7 ).

    lv_d10_calc = ( ( lv_odd_sum * 7 ) - lv_even_sum ) mod 10.
    if lv_d10_calc < 0.
      lv_d10_calc = lv_d10_calc + 10.
    endif.

    lv_d10_ref = digit_at( iv_str = iv_tckn iv_pos = 9 ).
    if lv_d10_calc = lv_d10_ref.
      lv_sum10    = lv_odd_sum + lv_even_sum + lv_d10_ref.
      lv_d11_calc = lv_sum10 mod 10.
      lv_d11_ref  = digit_at( iv_str = iv_tckn iv_pos = 10 ).
      if lv_d11_calc = lv_d11_ref.
        rv_valid = abap_true.
      endif.
    endif.
  endmethod.

  method parse_date.
    data: lv_work  type string,
          lt_parts type standard table of string,
          lv_day   type string,
          lv_mon   type string,
          lv_yr    type string.

    lv_work = iv_text.
    replace all occurrences of '/' in lv_work with '.'.
    split lv_work at '.' into table lt_parts.

    if lines( lt_parts ) = 3.
      read table lt_parts index 1 into lv_day.
      read table lt_parts index 2 into lv_mon.
      read table lt_parts index 3 into lv_yr.
      condense: lv_day, lv_mon, lv_yr.
      concatenate lv_yr lv_mon lv_day into rv_dats.
    else.
      raise exception type zcx_zrpd_edev_extract
        exporting mv_msgv1 = 'Date parse failed'.
    endif.
  endmethod.

  method digit_at.
    data lv_char type c length 1.
    lv_char = substring( val = iv_str off = iv_pos len = 1 ).
    rv_int  = lv_char - '0'.
  endmethod.

endclass.
