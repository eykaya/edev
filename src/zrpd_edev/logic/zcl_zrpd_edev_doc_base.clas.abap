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
    data: lt_binary type standard table of sdokcntbin,
          lv_len    type i,
          lv_text   type string.

    try.
        call function 'SCMS_XSTRING_TO_BINARY'
          exporting
            buffer        = iv_pdf
          importing
            output_length = lv_len
          tables
            binary_tab    = lt_binary.

        if lv_len = 0.
          rv_text = ''.
          return.
        endif.

        call function 'SCMS_BINARY_TO_STRING'
          exporting
            input_length = lv_len
          importing
            text_buffer  = lv_text
          tables
            binary_tab   = lt_binary
          exceptions
            others       = 1.

        if sy-subrc = 0.
          rv_text = lv_text.
        else.
          rv_text = ''.
        endif.

      catch cx_root.
        rv_text = ''.
    endtry.
  endmethod.

  method extract_tckn.
    data: lo_regex   type ref to cl_abap_regex,
          lo_matcher type ref to cl_abap_matcher,
          lv_match   type string.

    lo_regex = cl_abap_regex=>create( pattern = '[1-9][0-9]{10}' ).
    lo_matcher = lo_regex->create_matcher( text = iv_text ).

    if lo_matcher->find_next( ) = abap_true.
      lv_match = lo_matcher->get_match( ).
      rv_tckn = lv_match.
    else.
      raise exception type zcx_zrpd_edev_extract
        exporting
          mv_msgv1 = 'TCKN not found'.
    endif.
  endmethod.

  method extract_barcode.
    data: lo_regex   type ref to cl_abap_regex,
          lo_matcher type ref to cl_abap_matcher,
          lv_match   type string.

    lo_regex = cl_abap_regex=>create( pattern = '[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}' ).
    lo_matcher = lo_regex->create_matcher( text = iv_text ).

    if lo_matcher->find_next( ) = abap_true.
      lv_match = lo_matcher->get_match( ).
      rv_barcode = lv_match.
    else.
      raise exception type zcx_zrpd_edev_extract
        exporting
          mv_msgv1 = 'Barcode not found'.
    endif.
  endmethod.

  method validate_tckn.
    data: lv_len    type i,
          lv_d1     type i,
          lv_d2     type i,
          lv_d3     type i,
          lv_d4     type i,
          lv_d5     type i,
          lv_d6     type i,
          lv_d7     type i,
          lv_d8     type i,
          lv_d9     type i,
          lv_d10    type i,
          lv_d11    type i,
          lv_odd    type i,
          lv_even   type i,
          lv_calc10 type i,
          lv_calc11 type i,
          lv_char   type c length 1.

    rv_valid = abap_false.

    lv_len = strlen( iv_tckn ).
    if lv_len = 11.
      lv_char = iv_tckn(1).
      if lv_char = '0'.
        return.
      endif.

      lv_char = iv_tckn(1).
      lv_d1 = lv_char.
      lv_char = iv_tckn+1(1).
      lv_d2 = lv_char.
      lv_char = iv_tckn+2(1).
      lv_d3 = lv_char.
      lv_char = iv_tckn+3(1).
      lv_d4 = lv_char.
      lv_char = iv_tckn+4(1).
      lv_d5 = lv_char.
      lv_char = iv_tckn+5(1).
      lv_d6 = lv_char.
      lv_char = iv_tckn+6(1).
      lv_d7 = lv_char.
      lv_char = iv_tckn+7(1).
      lv_d8 = lv_char.
      lv_char = iv_tckn+8(1).
      lv_d9 = lv_char.
      lv_char = iv_tckn+9(1).
      lv_d10 = lv_char.
      lv_char = iv_tckn+10(1).
      lv_d11 = lv_char.

      lv_odd  = lv_d1 + lv_d3 + lv_d5 + lv_d7 + lv_d9.
      lv_even = lv_d2 + lv_d4 + lv_d6 + lv_d8.

      lv_calc10 = ( lv_odd * 7 - lv_even ) mod 10.
      lv_calc11 = ( lv_d1 + lv_d2 + lv_d3 + lv_d4 + lv_d5 +
                    lv_d6 + lv_d7 + lv_d8 + lv_d9 + lv_calc10 ) mod 10.

      if lv_calc10 = lv_d10 and lv_calc11 = lv_d11.
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

      condense lv_day.
      condense lv_mon.
      condense lv_yr.

      concatenate lv_yr lv_mon lv_day into rv_dats.
    else.
      raise exception type zcx_zrpd_edev_extract
        exporting
          mv_msgv1 = 'Date parse failed'.
    endif.
  endmethod.

endclass.
