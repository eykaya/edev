class zcl_zrpd_edev_doc_ika definition public
  inheriting from zcl_zrpd_edev_doc_base
  create public.

  public section.

    methods get_doc_type
      redefinition.

    methods validate_content
      redefinition.

    methods parse_fields
      redefinition.

  private section.

    methods extract_by_label
      importing
        iv_text         type string
        iv_label        type string
      returning
        value(rv_value) type string.

    methods extract_date_from_text
      importing
        iv_text        type string
      returning
        value(rv_dats) type dats.

    methods build_id_fields
      importing
        iv_text        type string
      returning
        value(rt_vals) type zrpd_edev_tt_dcval.

    methods build_name_address_fields
      importing
        iv_text        type string
      returning
        value(rt_vals) type zrpd_edev_tt_dcval.

    methods build_location_fields
      importing
        iv_text        type string
      returning
        value(rt_vals) type zrpd_edev_tt_dcval.

    methods build_meta_fields
      importing
        iv_text        type string
      returning
        value(rt_vals) type zrpd_edev_tt_dcval.

endclass.

class zcl_zrpd_edev_doc_ika implementation.

  method get_doc_type.
    rv_type = 'IKAMETGAH'.
  endmethod.

  method validate_content.
    data: lv_upper type string.

    lv_upper = to_upper( iv_text ).
    rv_valid = xsdbool(
      lv_upper cs 'YERLESIM' or
      lv_upper cs 'IKAMETGAH' or
      lv_upper cs 'RESIDENCE' ).
  endmethod.

  method parse_fields.
    data: lt_id      type zrpd_edev_tt_dcval,
          lt_name    type zrpd_edev_tt_dcval,
          lt_loc     type zrpd_edev_tt_dcval,
          lt_meta    type zrpd_edev_tt_dcval,
          ls_val     type zrpd_edev_s_dcval,
          lv_count   type i.

    lt_id   = build_id_fields( iv_text ).
    lt_name = build_name_address_fields( iv_text ).
    lt_loc  = build_location_fields( iv_text ).
    lt_meta = build_meta_fields( iv_text ).

    loop at lt_id into ls_val.
      append ls_val to rt_vals.
    endloop.
    loop at lt_name into ls_val.
      append ls_val to rt_vals.
    endloop.
    loop at lt_loc into ls_val.
      append ls_val to rt_vals.
    endloop.
    loop at lt_meta into ls_val.
      append ls_val to rt_vals.
    endloop.

    lv_count = 0.
    loop at rt_vals into ls_val.
      if ls_val-field_value = ''.
        continue.
      endif.
      lv_count = lv_count + 1.
    endloop.

    if lv_count = 0.
      raise exception type zcx_zrpd_edev_extract
        exporting
          mv_msgv1 = 'No fields extracted from document'.
    endif.
  endmethod.

  method build_id_fields.
    data: ls_val   type zrpd_edev_s_dcval,
          lv_tckn  type string,
          lv_bc    type string.

    " TCKN
    clear ls_val.
    ls_val-field_name     = 'tckn'.
    ls_val-extract_method = 'FORM'.
    try.
        lv_tckn = extract_tckn( iv_text ).
        ls_val-field_value = lv_tckn.
        ls_val-confidence  = '100.00'.
      catch zcx_zrpd_edev_extract.
        ls_val-field_value = ''.
        ls_val-confidence  = '0.00'.
    endtry.
    append ls_val to rt_vals.

    " Barcode
    clear ls_val.
    ls_val-field_name     = 'barcode'.
    ls_val-extract_method = 'FORM'.
    try.
        lv_bc = extract_barcode( iv_text ).
        ls_val-field_value = lv_bc.
        ls_val-confidence  = '100.00'.
      catch zcx_zrpd_edev_extract.
        ls_val-field_value = ''.
        ls_val-confidence  = '0.00'.
    endtry.
    append ls_val to rt_vals.
  endmethod.

  method build_name_address_fields.
    data: ls_val       type zrpd_edev_s_dcval,
          lv_fullname  type string,
          lv_neighbor  type string,
          lv_street    type string.

    " Full name
    clear ls_val.
    ls_val-field_name     = 'full_name'.
    ls_val-extract_method = 'FORM'.
    lv_fullname = extract_by_label(
      iv_text  = iv_text
      iv_label = 'ADI SOYADI' ).
    if lv_fullname = ''.
      lv_fullname = extract_by_label(
        iv_text  = iv_text
        iv_label = 'AD SOYAD' ).
    endif.
    ls_val-field_value = to_upper( lv_fullname ).
    if lv_fullname = ''.
      ls_val-confidence = '0.00'.
    else.
      ls_val-confidence = '80.00'.
    endif.
    append ls_val to rt_vals.

    " Neighborhood
    clear ls_val.
    ls_val-field_name     = 'neighborhood'.
    ls_val-extract_method = 'FORM'.
    lv_neighbor = extract_by_label(
      iv_text  = iv_text
      iv_label = 'MAHALLE' ).
    ls_val-field_value = lv_neighbor.
    if lv_neighbor = ''.
      ls_val-confidence = '0.00'.
    else.
      ls_val-confidence = '80.00'.
    endif.
    append ls_val to rt_vals.

    " Street address
    clear ls_val.
    ls_val-field_name     = 'street_address'.
    ls_val-extract_method = 'FORM'.
    lv_street = extract_by_label(
      iv_text  = iv_text
      iv_label = 'CADDE' ).
    if lv_street = ''.
      lv_street = extract_by_label(
        iv_text  = iv_text
        iv_label = 'SOKAK' ).
    endif.
    if lv_street = ''.
      lv_street = extract_by_label(
        iv_text  = iv_text
        iv_label = 'ADRES' ).
    endif.
    ls_val-field_value = lv_street.
    if lv_street = ''.
      ls_val-confidence = '0.00'.
    else.
      ls_val-confidence = '80.00'.
    endif.
    append ls_val to rt_vals.
  endmethod.

  method build_location_fields.
    data: ls_val      type zrpd_edev_s_dcval,
          lv_district type string,
          lv_city     type string,
          lv_postal   type string,
          lo_regex    type ref to cl_abap_regex,
          lo_matcher  type ref to cl_abap_matcher.

    " District
    clear ls_val.
    ls_val-field_name     = 'district'.
    ls_val-extract_method = 'FORM'.
    lv_district = extract_by_label(
      iv_text  = iv_text
      iv_label = 'ILCE' ).
    ls_val-field_value = lv_district.
    if lv_district = ''.
      ls_val-confidence = '0.00'.
    else.
      ls_val-confidence = '80.00'.
    endif.
    append ls_val to rt_vals.

    " City
    clear ls_val.
    ls_val-field_name     = 'city'.
    ls_val-extract_method = 'FORM'.
    lv_city = extract_by_label(
      iv_text  = iv_text
      iv_label = 'SEHIR' ).
    if lv_city = ''.
      lv_city = extract_by_label(
        iv_text  = iv_text
        iv_label = 'IL ' ).
    endif.
    ls_val-field_value = lv_city.
    if lv_city = ''.
      ls_val-confidence = '0.00'.
    else.
      ls_val-confidence = '80.00'.
    endif.
    append ls_val to rt_vals.

    " Postal code
    clear ls_val.
    ls_val-field_name     = 'postal_code'.
    ls_val-extract_method = 'FORM'.
    create object lo_regex exporting pattern = '[0-9]{5}'.
    create object lo_matcher exporting regex = lo_regex text = iv_text.
    if lo_matcher->find_next( ) = abap_true.
      data lv_p_off type i.
      data lv_p_len type i.
      lv_p_off = lo_matcher->get_offset( ).
      lv_p_len = lo_matcher->get_length( ).
      lv_postal = iv_text+lv_p_off(lv_p_len).
      ls_val-field_value = lv_postal.
      ls_val-confidence  = '100.00'.
    else.
      ls_val-field_value = ''.
      ls_val-confidence  = '0.00'.
    endif.
    append ls_val to rt_vals.
  endmethod.

  method build_meta_fields.
    data: ls_val  type zrpd_edev_s_dcval,
          lv_dats type dats.

    " Country (default TR)
    clear ls_val.
    ls_val-field_name     = 'country'.
    ls_val-extract_method = 'FORM'.
    ls_val-field_value    = 'TR'.
    ls_val-confidence     = '100.00'.
    append ls_val to rt_vals.

    " Issue date
    clear ls_val.
    ls_val-field_name     = 'issue_date'.
    ls_val-extract_method = 'FORM'.
    lv_dats = extract_date_from_text( iv_text ).
    if lv_dats = '00000000'.
      ls_val-field_value = ''.
      ls_val-confidence  = '0.00'.
    else.
      ls_val-field_value = lv_dats.
      ls_val-confidence  = '100.00'.
    endif.
    append ls_val to rt_vals.
  endmethod.

  method extract_by_label.
    data: lv_upper     type string,
          lv_label_up  type string,
          lv_pos       type i,
          lv_len_label type i,
          lv_len_text  type i,
          lv_rest      type string,
          lv_nl_pos    type i,
          lv_line      type string,
          lv_col_pos   type i.

    lv_upper    = to_upper( iv_text ).
    lv_label_up = to_upper( iv_label ).

    find first occurrence of lv_label_up in lv_upper match offset lv_pos.
    if sy-subrc = 0.
      lv_len_label = strlen( lv_label_up ).
      lv_len_text  = strlen( lv_upper ).
      lv_pos = lv_pos + lv_len_label.

      if lv_pos = lv_len_text.
        rv_value = ''.
        return.
      endif.

      lv_rest = iv_text+lv_pos.

      find first occurrence of cl_abap_char_utilities=>newline
        in lv_rest match offset lv_nl_pos.
      if sy-subrc = 0.
        lv_line = lv_rest(lv_nl_pos).
      else.
        lv_line = lv_rest.
      endif.

      find first occurrence of ':' in lv_line match offset lv_col_pos.
      if sy-subrc = 0.
        lv_col_pos = lv_col_pos + 1.
        lv_line = lv_line+lv_col_pos.
      endif.

      condense lv_line.
      rv_value = lv_line.
    else.
      rv_value = ''.
    endif.
  endmethod.

  method extract_date_from_text.
    data: lo_regex   type ref to cl_abap_regex,
          lo_matcher type ref to cl_abap_matcher,
          lv_match   type string.

    create object lo_regex exporting pattern = '[0-9]{2}[.][0-9]{2}[.][0-9]{4}'.
    create object lo_matcher exporting regex = lo_regex text = iv_text.

    if lo_matcher->find_next( ) = abap_true.
      data lv_d_off type i.
      data lv_d_len type i.
      lv_d_off = lo_matcher->get_offset( ).
      lv_d_len = lo_matcher->get_length( ).
      lv_match = iv_text+lv_d_off(lv_d_len).
      try.
          rv_dats = parse_date( lv_match ).
        catch zcx_zrpd_edev_extract.
          rv_dats = '00000000'.
      endtry.
    else.
      rv_dats = '00000000'.
    endif.
  endmethod.

endclass.
