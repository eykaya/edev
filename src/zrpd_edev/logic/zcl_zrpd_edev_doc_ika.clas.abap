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

    methods parse_address_line
      importing
        iv_address      type string
      exporting
        ev_neighborhood type string
        ev_street       type string
        ev_district     type string
        ev_city         type string.

    methods find_address_line
      importing
        iv_text           type string
      returning
        value(rv_address) type string.

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
      lv_upper cs 'ADRES BELGESI' ).
  endmethod.

  method parse_fields.
    data: ls_val        type zrpd_edev_s_dcval,
          lv_tckn       type string,
          lv_bc         type string,
          lv_adi        type string,
          lv_soyadi     type string,
          lv_address    type string,
          lv_neighbor   type string,
          lv_street     type string,
          lv_district   type string,
          lv_city       type string,
          lv_dats       type dats,
          lv_count      type i,
          lv_ano_off    type i,
          lv_ano_rest   type string,
          lv_an2_off    type i,
          lv_an2_len    type i,
          lv_street_name type string,
          lv_cadde      type string,
          lv_sokak      type string,
          lv_bldg_no    type string,
          lv_door_no    type string,
          lv_no_off     type i,
          lv_cad_off    type i,
          lv_sk_off     type i,
          lv_after_cad  type string.

    " --- TCKN ---
    clear ls_val.
    ls_val-field_name     = 'tc_kimlik_no'.
    ls_val-extract_method = 'FORM'.
    lv_tckn = extract_by_label( iv_text = iv_text iv_label = 'Kimlik No' ).
    if lv_tckn = ''.
      lv_tckn = extract_by_label( iv_text = iv_text iv_label = 'T.C. KIMLIK NO' ).
    endif.
    if lv_tckn = ''.
      try.
          lv_tckn = extract_tckn( iv_text ).
        catch zcx_zrpd_edev_extract.
      endtry.
    endif.
    ls_val-field_value = lv_tckn.
    ls_val-confidence  = cond #( when lv_tckn = '' then '0.00' else '100.00' ).
    append ls_val to rt_vals.

    " --- BARCODE ---
    clear ls_val.
    ls_val-field_name     = 'barkod'.
    ls_val-extract_method = 'FORM'.
    try.
        lv_bc = extract_barcode( iv_text ).
      catch zcx_zrpd_edev_extract.
    endtry.
    ls_val-field_value = lv_bc.
    ls_val-confidence  = cond #( when lv_bc = '' then '0.00' else '100.00' ).
    append ls_val to rt_vals.

    " --- ADI / SOYADI -> FULL_NAME ---
    clear ls_val.
    ls_val-field_name     = 'ad_soyad'.
    ls_val-extract_method = 'FORM'.
    lv_adi = extract_by_label( iv_text = iv_text iv_label = 'Adi' ).
    if lv_adi = ''.
      lv_adi = extract_by_label( iv_text = iv_text iv_label = 'ADI SOYADI' ).
    endif.
    " OCR gurultusu temizle: bastaki !:; karakterleri
    replace regex '^[!:;]+' in lv_adi with ''.
    condense lv_adi.

    lv_soyadi = extract_by_label( iv_text = iv_text iv_label = 'Soyadi' ).
    if lv_soyadi = ''.
      lv_soyadi = extract_by_label( iv_text = iv_text iv_label = 'Soyad' ).
    endif.
    replace regex '^[!:;]+' in lv_soyadi with ''.
    condense lv_soyadi.
    if lv_adi is not initial and lv_soyadi is not initial.
      ls_val-field_value = to_upper( lv_adi && | | && lv_soyadi ).
    elseif lv_adi is not initial.
      ls_val-field_value = to_upper( lv_adi ).
    endif.
    ls_val-confidence = cond #( when ls_val-field_value = '' then '0.00' else '90.00' ).
    append ls_val to rt_vals.

    " --- ADDRESS NO ---
    clear ls_val.
    ls_val-field_name     = 'adres_no'.
    ls_val-extract_method = 'FORM'.
    ls_val-field_value    = extract_by_label(
      iv_text  = iv_text
      iv_label = 'Adres No' ).
    " Fallback: 'Adres No' labelindan sonra gelen 10 haneli sayiyi ara (TCKN'yi atlayarak)
    if ls_val-field_value is initial.
      find first occurrence of 'Adres No' in iv_text
        ignoring case match offset lv_ano_off.
      if sy-subrc = 0.
        lv_ano_rest = iv_text+lv_ano_off.
        find first occurrence of regex '[0-9]{10}'
          in lv_ano_rest match offset lv_an2_off match length lv_an2_len.
        if sy-subrc = 0.
          ls_val-field_value = substring(
            val = lv_ano_rest
            off = lv_an2_off
            len = lv_an2_len ).
        endif.
      endif.
    endif.
    ls_val-confidence = cond #( when ls_val-field_value = '' then '0.00' else '100.00' ).
    append ls_val to rt_vals.

    " --- ADDRESS PARSING ---
    lv_address = find_address_line( iv_text ).

    " Full address (tam adres satiri)
    clear ls_val.
    ls_val-field_name     = 'tam_adres'.
    ls_val-extract_method = 'FORM'.
    ls_val-field_value    = lv_address.
    ls_val-confidence     = cond #( when lv_address = '' then '0.00' else '80.00' ).
    append ls_val to rt_vals.

    parse_address_line(
      exporting iv_address = lv_address
      importing ev_neighborhood = lv_neighbor
                ev_street       = lv_street
                ev_district     = lv_district
                ev_city         = lv_city ).

    " Neighborhood
    clear ls_val.
    ls_val-field_name     = 'mahalle'.
    ls_val-extract_method = 'FORM'.
    ls_val-field_value    = lv_neighbor.
    ls_val-confidence     = cond #( when lv_neighbor = '' then '0.00' else '80.00' ).
    append ls_val to rt_vals.

    " Sokak/Cadde/No ayristirma
    lv_street_name = lv_street.

    " NO: xx INS_AAT NO: yy veya IC KAPI NO: yy pattern'i ayristir
    find first occurrence of regex 'NO\s*:\s*(\d+)\s+I[CNS_]+\s*(?:KAPI\s+)?NO\s*:\s*(\d+)'
      in to_upper( lv_street )
      submatches lv_bldg_no lv_door_no.
    if sy-subrc = 0.
      find first occurrence of regex '\s*NO\s*:' in to_upper( lv_street )
        match offset lv_no_off.
      if sy-subrc = 0 and lv_no_off is not initial.
        lv_street_name = lv_street(lv_no_off).
        condense lv_street_name.
      endif.
    else.
      " Sadece NO: xx (ic kapi yok)
      find first occurrence of regex 'NO\s*:\s*(\d+)'
        in to_upper( lv_street )
        submatches lv_bldg_no.
      if sy-subrc = 0.
        find first occurrence of regex '\s*NO\s*:' in to_upper( lv_street )
          match offset lv_no_off.
        if sy-subrc = 0 and lv_no_off is not initial.
          lv_street_name = lv_street(lv_no_off).
          condense lv_street_name.
        endif.
      endif.
    endif.

    " Cadde ve Sokak ayir
    " Ornek: "DORTYOL SK." veya "CUMHURIYET CAD. PAZAR SK."
    find first occurrence of regex '(\S+\s+CAD[.\s])'
      in to_upper( lv_street_name )
      submatches lv_cadde
      match offset lv_cad_off.
    if sy-subrc = 0.
      condense lv_cadde.
      " Cadde'den sonraki kisim sokak olabilir
      lv_after_cad = to_upper( lv_street_name ).
      lv_sk_off = lv_cad_off + strlen( lv_cadde ).
      if lv_sk_off < strlen( lv_after_cad ).
        lv_sokak = lv_after_cad+lv_sk_off.
        condense lv_sokak.
      endif.
    else.
      " Cadde yok, tamamı sokak (SK. / SOK. / SOKAK / SOKAGI iceriyorsa)
      find first occurrence of regex '(\S+\s+(?:SK[.\s]|SOK[.\s]|SOKAK|SOKAGI))'
        in to_upper( lv_street_name )
        submatches lv_sokak.
      if sy-subrc = 0.
        condense lv_sokak.
      else.
        " Pattern bulunamadı, tamamini sokak olarak al
        lv_sokak = lv_street_name.
      endif.
    endif.

    " Cadde
    clear ls_val.
    ls_val-field_name     = 'cadde'.
    ls_val-extract_method = 'FORM'.
    ls_val-field_value    = lv_cadde.
    ls_val-confidence     = cond #( when lv_cadde = '' then '0.00' else '80.00' ).
    append ls_val to rt_vals.

    " Sokak
    clear ls_val.
    ls_val-field_name     = 'sokak'.
    ls_val-extract_method = 'FORM'.
    ls_val-field_value    = lv_sokak.
    ls_val-confidence     = cond #( when lv_sokak = '' then '0.00' else '80.00' ).
    append ls_val to rt_vals.

    " Building no (dis kapi / insaat no)
    clear ls_val.
    ls_val-field_name     = 'bina_no'.
    ls_val-extract_method = 'FORM'.
    ls_val-field_value    = lv_bldg_no.
    ls_val-confidence     = cond #( when lv_bldg_no = '' then '0.00' else '80.00' ).
    append ls_val to rt_vals.

    " Door no (ic kapi no)
    clear ls_val.
    ls_val-field_name     = 'ic_kapi_no'.
    ls_val-extract_method = 'FORM'.
    ls_val-field_value    = lv_door_no.
    ls_val-confidence     = cond #( when lv_door_no = '' then '0.00' else '80.00' ).
    append ls_val to rt_vals.

    " District
    clear ls_val.
    ls_val-field_name     = 'ilce'.
    ls_val-extract_method = 'FORM'.
    ls_val-field_value    = lv_district.
    ls_val-confidence     = cond #( when lv_district = '' then '0.00' else '80.00' ).
    append ls_val to rt_vals.

    " City
    clear ls_val.
    ls_val-field_name     = 'il'.
    ls_val-extract_method = 'FORM'.
    ls_val-field_value    = lv_city.
    ls_val-confidence     = cond #( when lv_city = '' then '0.00' else '80.00' ).
    append ls_val to rt_vals.

    " Postal code
    clear ls_val.
    ls_val-field_name     = 'posta_kodu'.
    ls_val-extract_method = 'FORM'.
    ls_val-field_value    = extract_by_label( iv_text = iv_text iv_label = 'Posta Kodu' ).
    ls_val-confidence     = cond #( when ls_val-field_value = '' then '0.00' else '80.00' ).
    append ls_val to rt_vals.

    " Country
    clear ls_val.
    ls_val-field_name     = 'ulke'.
    ls_val-extract_method = 'FORM'.
    ls_val-field_value    = 'TR'.
    ls_val-confidence     = '100.00'.
    append ls_val to rt_vals.

    " Issue date
    clear ls_val.
    ls_val-field_name     = 'belge_tarihi'.
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

    " Check at least one field was extracted
    lv_count = 0.
    loop at rt_vals into ls_val.
      if ls_val-field_value is not initial.
        lv_count = lv_count + 1.
      endif.
    endloop.
    if lv_count = 0.
      raise exception type zcx_zrpd_edev_extract
        exporting
          mv_msgv1 = 'No fields extracted'.
    endif.
  endmethod.

  method find_address_line.
    data: lv_upper   type string,
          lt_lines   type standard table of string,
          lv_line    type string,
          lv_mah_idx type i,
          lv_end_idx type i,
          lv_idx     type i.

    lv_upper = to_upper( iv_text ).
    split lv_upper at cl_abap_char_utilities=>newline into table lt_lines.

    " MAH satirini bul
    lv_mah_idx = 0.
    loop at lt_lines into lv_line.
      lv_idx = sy-tabix.
      condense lv_line.
      if lv_line cs 'MAH'.
        lv_mah_idx = lv_idx.
        exit.
      endif.
    endloop.

    if lv_mah_idx = 0.
      rv_address = extract_by_label(
        iv_text  = iv_text
        iv_label = 'Adres' ).
      replace regex '^\d{10}\s*\|?\s*' in rv_address with ''.
      condense rv_address.
      return.
    endif.

    " MAH satirindan itibaren / iceren satiri bul (cok satirli adres)
    lv_end_idx = lv_mah_idx.
    loop at lt_lines into lv_line from lv_mah_idx.
      lv_idx = sy-tabix.
      condense lv_line.
      if lv_line cs '/'.
        lv_end_idx = lv_idx.
        exit.
      endif.
      " Max 3 satir ileri bak
      if lv_idx - lv_mah_idx > 2.
        exit.
      endif.
    endloop.

    " MAH'tan / satirana kadar birlestir
    loop at lt_lines into lv_line from lv_mah_idx to lv_end_idx.
      condense lv_line.
      if lv_line is not initial
        and strlen( lv_line ) > 3
        and lv_line ns 'ADRESI'
        and lv_line ns 'ADRES TIPI'.
        if rv_address is initial.
          rv_address = lv_line.
        else.
          rv_address = rv_address && | | && lv_line.
        endif.
      endif.
    endloop.

    " Label ve adres no prefix temizle
    " OCR bazen "YERLESIM YERI YURTICI 1234567890 |" gibi label karistirir
    replace all occurrences of regex 'YERLESIM\s+YERI' in rv_address with ''.
    replace all occurrences of regex 'YURTICI' in rv_address with ''.
    replace all occurrences of regex 'ADRESI' in rv_address with ''.
    replace all occurrences of regex 'ADRES\s+TIPI' in rv_address with ''.
    replace all occurrences of regex '\d{10}\s*\|?\s*' in rv_address with ''.
    condense rv_address.
  endmethod.

  method parse_address_line.
    data: lv_addr  type string,
          lv_pos   type i,
          lv_before_slash type string,
          lv_after_slash  type string,
          lv_mah_end      type i,
          lv_mah_part     type string.

    clear: ev_neighborhood, ev_street, ev_district, ev_city.

    if iv_address is initial.
      return.
    endif.

    lv_addr = to_upper( iv_address ).
    condense lv_addr.

    " Split by '/' to get city
    find first occurrence of '/' in lv_addr match offset lv_pos.
    if sy-subrc = 0.
      if lv_pos = 0.
        lv_before_slash = ''.
      else.
        lv_before_slash = lv_addr(lv_pos).
      endif.
      lv_pos = lv_pos + 1.
      lv_after_slash = lv_addr+lv_pos.
      condense lv_after_slash.
      ev_city = lv_after_slash.

      " District is the last word before /
      condense lv_before_slash.
      data lt_words type standard table of string.
      data lv_word type string.
      split lv_before_slash at ' ' into table lt_words.
      data lv_last_idx type i.
      lv_last_idx = lines( lt_words ).
      if lv_last_idx = 0.
        ev_district = ''.
      else.
        read table lt_words index lv_last_idx into ev_district.
      endif.
    endif.

    " Neighborhood: text before "MAH"
    find first occurrence of 'MAH' in lv_addr match offset lv_mah_end.
    if sy-subrc = 0 and lv_mah_end = 0.
      ev_neighborhood = ''.
    elseif sy-subrc = 0.
      lv_mah_part = lv_addr(lv_mah_end).
      condense lv_mah_part.
      ev_neighborhood = lv_mah_part.
    endif.

    " Street: text between "MAH." and district
    data lv_street_start type i.
    find first occurrence of 'MAH.' in lv_addr match offset lv_pos.
    if sy-subrc = 0.
      lv_street_start = lv_pos + 4.
    else.
      find first occurrence of 'MAH' in lv_addr match offset lv_pos.
      if sy-subrc = 0.
        lv_street_start = lv_pos + 3.
      endif.
    endif.

    if lv_street_start is not initial and lv_before_slash is not initial.
      data lv_street_part type string.
      lv_street_part = lv_before_slash+lv_street_start.
      condense lv_street_part.
      if ev_district is not initial.
        data lv_dist_pos type i.
        data lv_dist_len type i.
        lv_dist_len = strlen( ev_district ).
        find first occurrence of ev_district in lv_street_part
          match offset lv_dist_pos.
        if sy-subrc = 0 and lv_dist_pos = 0.
          ev_street = ''.
        elseif sy-subrc = 0.
          ev_street = lv_street_part(lv_dist_pos).
          condense ev_street.
        else.
          ev_street = lv_street_part.
        endif.
      else.
        ev_street = lv_street_part.
      endif.
    endif.
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

      " Deger bossa alt satira bak (OCR'da label ve deger ayri satirlarda olabiliyor)
      if rv_value is initial and lv_nl_pos is not initial.
        data: lv_rest2  type string,
              lv_nl_pos2 type i.
        lv_rest2 = lv_rest+lv_nl_pos.
        " Bastaki newline'i atla
        shift lv_rest2 left deleting leading cl_abap_char_utilities=>newline.
        find first occurrence of cl_abap_char_utilities=>newline
          in lv_rest2 match offset lv_nl_pos2.
        if sy-subrc = 0.
          rv_value = lv_rest2(lv_nl_pos2).
        else.
          rv_value = lv_rest2.
        endif.
        condense rv_value.
      endif.
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
