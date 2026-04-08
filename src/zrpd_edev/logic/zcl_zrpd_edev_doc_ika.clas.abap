class zcl_zrpd_edev_doc_ika definition public
  inheriting from zcl_zrpd_edev_doc_base
  create public.
  public section.
    methods get_doc_type redefinition.
    methods validate_content redefinition.
    methods parse_fields redefinition.
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
    methods extract_site_blok
      importing
        iv_street        type string
      exporting
        ev_site_apartman type string
        ev_blok          type string
        ev_street_clean  type string.
    methods get_name_before_kimlik
      importing
        iv_text  type string
      exporting
        ev_ad    type string
        ev_soyad type string.
    methods is_valid_name_line
      importing
        iv_line         type string
      returning
        value(rv_valid) type abap_bool.
    methods parse_ad_soyad
      importing
        iv_text  type string
      exporting
        ev_adi   type string
        ev_soyad type string.
    methods parse_adres_no
      importing
        iv_text  type string
      changing
        ct_vals  type zrpd_edev_tt_dcval.
    methods parse_street_fields
      importing
        iv_street type string
      changing
        ct_vals   type zrpd_edev_tt_dcval.
    methods append_field
      importing
        iv_name       type string
        iv_value      type string
        iv_confidence type string
      changing
        ct_vals       type zrpd_edev_tt_dcval.
    methods get_next_city_line
      importing
        iv_end_idx     type i
        iv_total       type i
        it_lines       type standard table
      returning
        value(rv_city) type string.
endclass.

class zcl_zrpd_edev_doc_ika implementation.

  method get_doc_type.
    rv_type = 'IKAMETGAH'.
  endmethod.

  method validate_content.
    data lv_upper type string.
    lv_upper = to_upper( iv_text ).
    rv_valid = xsdbool( lv_upper cs 'YERLESIM'
                     or lv_upper cs 'IKAMETGAH'
                     or lv_upper cs 'ADRES BELGESI' ).
  endmethod.

  method parse_fields.
    data: ls_val      type zrpd_edev_s_dcval,
          lv_tckn     type string,
          lv_bc       type string,
          lv_adi      type string,
          lv_soyadi   type string,
          lv_address  type string,
          lv_neighbor type string,
          lv_street   type string,
          lv_district type string,
          lv_city     type string,
          lv_dats     type dats,
          lv_count    type i,
          lv_ad_full  type string,
          lv_dats_str type string.

    " TCKN
    lv_tckn = extract_by_label(
      iv_text  = iv_text
      iv_label = 'Kimlik No' ).
    if lv_tckn = ''.
      lv_tckn = extract_by_label(
        iv_text  = iv_text
        iv_label = 'T.C. KIMLIK NO' ).
    endif.
    try.
        if lv_tckn = ''.
          lv_tckn = extract_tckn( iv_text ).
        endif.
      catch zcx_zrpd_edev_extract.
    endtry.
    append_field(
      exporting
        iv_name       ='tc_kimlik_no'
        iv_value      = lv_tckn
        iv_confidence = cond #( when lv_tckn = '' then '0.00' else '100.00' )
      changing
        ct_vals       = rt_vals ).

    " BARKOD
    try.
        lv_bc = extract_barcode( iv_text ).
      catch zcx_zrpd_edev_extract.
    endtry.
    append_field(
      exporting
        iv_name       ='barkod'
        iv_value      = lv_bc
        iv_confidence = cond #( when lv_bc = '' then '0.00' else '100.00' )
      changing
        ct_vals       = rt_vals ).

    " AD SOYAD
    parse_ad_soyad(
      exporting
        iv_text  = iv_text
      importing
        ev_adi   = lv_adi
        ev_soyad = lv_soyadi ).
    if lv_adi is not initial and lv_soyadi is not initial.
      lv_ad_full = to_upper( lv_adi && | | && lv_soyadi ).
    elseif lv_adi is not initial.
      lv_ad_full = to_upper( lv_adi ).
    else.
      lv_ad_full = ''.
    endif.
    append_field(
      exporting
        iv_name       ='ad_soyad'
        iv_value      = lv_ad_full
        iv_confidence = cond #( when lv_ad_full = '' then '0.00' else '90.00' )
      changing
        ct_vals       = rt_vals ).

    " ADRES NO
    parse_adres_no(
      exporting
        iv_text = iv_text
      changing
        ct_vals = rt_vals ).

    " TAM ADRES
    lv_address = find_address_line( iv_text ).
    append_field(
      exporting
        iv_name       ='tam_adres'
        iv_value      = lv_address
        iv_confidence = cond #( when lv_address = '' then '0.00' else '80.00' )
      changing
        ct_vals       = rt_vals ).

    parse_address_line(
      exporting
        iv_address      = lv_address
      importing
        ev_neighborhood = lv_neighbor
        ev_street       = lv_street
        ev_district     = lv_district
        ev_city         = lv_city ).

    " MAHALLE
    append_field(
      exporting
        iv_name       ='mahalle'
        iv_value      = lv_neighbor
        iv_confidence = cond #( when lv_neighbor = '' then '0.00' else '80.00' )
      changing
        ct_vals       = rt_vals ).

    " CADDE/SOKAK/SITE/BLOK/BINA/KAPI
    parse_street_fields(
      exporting
        iv_street = lv_street
      changing
        ct_vals   = rt_vals ).

    " ILCE / IL
    append_field(
      exporting
        iv_name       ='ilce'
        iv_value      = lv_district
        iv_confidence = cond #( when lv_district = '' then '0.00' else '80.00' )
      changing
        ct_vals       = rt_vals ).
    append_field(
      exporting
        iv_name       ='il'
        iv_value      = lv_city
        iv_confidence = cond #( when lv_city = '' then '0.00' else '80.00' )
      changing
        ct_vals       = rt_vals ).

    " POSTA KODU
    append_field(
      exporting
        iv_name       ='posta_kodu'
        iv_value      = extract_by_label( iv_text = iv_text iv_label = 'Posta Kodu' )
        iv_confidence = '80.00'
      changing
        ct_vals       = rt_vals ).

    " ULKE
    append_field(
      exporting
        iv_name       ='ulke'
        iv_value      = 'TR'
        iv_confidence = '100.00'
      changing
        ct_vals       = rt_vals ).

    " BELGE TARIHI
    lv_dats = extract_date_from_text( iv_text ).
    if lv_dats = '00000000'.
      append_field(
        exporting
          iv_name       = 'belge_tarihi'
          iv_value      = ''
          iv_confidence = '0.00'
        changing
          ct_vals       = rt_vals ).
    else.
      lv_dats_str = lv_dats.
      append_field(
        exporting
          iv_name       = 'belge_tarihi'
          iv_value      = lv_dats_str
          iv_confidence = '100.00'
        changing
          ct_vals       = rt_vals ).
    endif.

    lv_count = 0.
    loop at rt_vals into ls_val.
      if ls_val-field_value is not initial.
        lv_count = lv_count + 1.
      endif.
    endloop.
    if lv_count = 0.
      raise exception type zcx_zrpd_edev_extract
        exporting mv_msgv1 = 'No fields extracted'.
    endif.
  endmethod.

  " Strateji 1: label bazli. Strateji 2: tablo formatinda geriye tara.
  method parse_ad_soyad.
    data: lv_adi    type string,
          lv_soyadi type string.

    ev_adi   = ''.
    ev_soyad = ''.

    lv_adi    = extract_by_label(
      iv_text  = iv_text
      iv_label = 'Adi' ).
    lv_soyadi = extract_by_label(
      iv_text  = iv_text
      iv_label = 'Soyadi' ).
    if lv_soyadi = ''.
      lv_soyadi = extract_by_label(
        iv_text  = iv_text
        iv_label = 'Soyad' ).
    endif.

    " Keyword veya ':' iceriyorsa reject
    if to_upper( lv_adi ) cs 'SOYAD'
    or to_upper( lv_adi ) cs 'KIMLIK'
    or to_upper( lv_adi ) cs 'ADRES'
    or lv_adi = ':'.
      clear lv_adi.
    endif.
    if to_upper( lv_soyadi ) cs 'KIMLIK'
    or to_upper( lv_soyadi ) cs 'ADRES'
    or lv_soyadi = ':'.
      clear lv_soyadi.
    endif.

    " Strateji 2: tablo formati
    if lv_adi is initial or lv_soyadi is initial.
      get_name_before_kimlik(
        exporting
          iv_text  = iv_text
        importing
          ev_ad    = lv_adi
          ev_soyad = lv_soyadi ).
    endif.

    replace regex '^[!:;\s]+' in lv_adi    with ''.
    condense lv_adi.
    replace regex '^[!:;\s]+' in lv_soyadi with ''.
    condense lv_soyadi.

    ev_adi   = lv_adi.
    ev_soyad = lv_soyadi.
  endmethod.

  " Satirin ad/soyad icin gecerli bir isim satiri olup olmadigini kontrol eder
  method is_valid_name_line.
    data lv_up type string.
    rv_valid = abap_false.
    if strlen( iv_line ) le 1.
      return.
    endif.
    if iv_line = ':'.
      return.
    endif.
    if iv_line ca '0123456789'.
      return.
    endif.
    lv_up = to_upper( iv_line ).
    if lv_up cs 'KIMLIK'
    or lv_up cs 'ADRES'
    or lv_up cs 'YERLESIM'
    or lv_up cs 'SOYAD'
    or lv_up cs 'BILGI'.
      return.
    endif.
    rv_valid = abap_true.
  endmethod.

  " 'Kimlik No' satirindan geriye giderek ilk 2 gecerli isim satirini bulur
  method get_name_before_kimlik.
    data: lt_nl          type standard table of string with empty key,
          lv_nl          type string,
          lv_nl_idx      type i,
          lv_nl_up       type string,
          lv_found_count type i,
          lv_scan_idx    type i,
          lv_scan_line   type string,
          lv_name1       type string,
          lv_name2       type string.

    ev_ad    = ''.
    ev_soyad = ''.

    split iv_text at cl_abap_char_utilities=>newline into table lt_nl.
    loop at lt_nl into lv_nl.
      lv_nl_idx = sy-tabix.
      lv_nl_up  = to_upper( lv_nl ).
      condense lv_nl_up.
      if lv_nl_up ne 'KIMLIK NO'.
        continue.
      endif.
      lv_found_count = 0.
      lv_scan_idx    = lv_nl_idx - 1.
      while lv_scan_idx ge 1 and lv_found_count lt 2.
        read table lt_nl index lv_scan_idx into lv_scan_line.
        if sy-subrc = 0.
          condense lv_scan_line.
          if is_valid_name_line( lv_scan_line ) = abap_true.
            lv_found_count = lv_found_count + 1.
            case lv_found_count.
              when 1.
                lv_name1 = lv_scan_line.
              when 2.
                lv_name2 = lv_scan_line.
            endcase.
          endif.
        endif.
        lv_scan_idx = lv_scan_idx - 1.
      endwhile.
      " lv_name2 = ad (uzakta), lv_name1 = soyad (yakinda)
      ev_ad    = lv_name2.
      ev_soyad = lv_name1.
      exit.
    endloop.
  endmethod.

  " Adres no (10 haneli): label, pipe, bolge arama sirasiyla
  method parse_adres_no.
    data: lv_val     type string,
          lt_nl      type standard table of string with empty key,
          lv_nl      type string,
          lv_nl_up   type string,
          lv_t       type string,
          lv_off     type i,
          lv_rest    type string,
          lv_an2_off type i,
          lv_an2_len type i.

    lv_val = extract_by_label(
      iv_text  = iv_text
      iv_label = 'Adres No' ).

    " Fallback 1: pipe oncesindeki 10 haneli sayi
    if lv_val is initial.
      split iv_text at cl_abap_char_utilities=>newline into table lt_nl.
      loop at lt_nl into lv_nl.
        lv_nl_up = to_upper( lv_nl ).
        condense lv_nl_up.
        if lv_nl_up cs '|'.
          find first occurrence of regex '(\d{10})\s*\|'
            in lv_nl_up submatches lv_t.
          if sy-subrc = 0.
            lv_val = lv_t.
            exit.
          endif.
        endif.
      endloop.
    endif.

    " Fallback 2: 'Adres No' yakininda 10 haneli sayi
    if lv_val is initial.
      find first occurrence of 'Adres No'
        in iv_text ignoring case match offset lv_off.
      if sy-subrc = 0.
        lv_rest = iv_text+lv_off.
        find first occurrence of regex '[0-9]{10}'
          in lv_rest match offset lv_an2_off match length lv_an2_len.
        if sy-subrc = 0.
          lv_val = substring(
            val = lv_rest
            off = lv_an2_off
            len = lv_an2_len ).
        endif.
      endif.
    endif.

    " Fallback 3: Yerlesim/Yurtici satirindaki 10 haneli sayi
    if lv_val is initial.
      split iv_text at cl_abap_char_utilities=>newline into table lt_nl.
      loop at lt_nl into lv_nl.
        lv_nl_up = to_upper( lv_nl ). condense lv_nl_up.
        if lv_nl_up cs 'YURTICI' or lv_nl_up cs 'YERLESIM'.
          find first occurrence of regex '(\d{10})' in lv_nl_up submatches lv_t.
          if sy-subrc = 0. lv_val = lv_t. exit. endif.
        endif.
      endloop.
    endif.

    append_field(
      exporting
        iv_name       ='adres_no'
        iv_value      = lv_val
        iv_confidence = cond #( when lv_val = '' then '0.00' else '100.00' )
      changing
        ct_vals       = ct_vals ).
  endmethod.

  " Cadde/sokak/site/blok/bina_no/ic_kapi_no alanlari
  method parse_street_fields.
    data: lv_street_name type string,
          lv_cadde       type string,
          lv_sokak       type string,
          lv_bldg_no     type string,
          lv_door_no     type string,
          lv_no_off      type i,
          lv_cad_off     type i,
          lv_sk_off      type i,
          lv_after_cad   type string,
          lv_site_apt    type string,
          lv_blok        type string,
          lv_street_base type string,
          lv_upper       type string.

    lv_street_name = iv_street.
    lv_upper       = to_upper( iv_street ).

    " Bina + ic kapi no cift pattern (alfanumerik bina_no destekli)
    find first occurrence of
      regex 'NO\s*:\s*(\d+[A-Za-z]?)\s+.{0,20}NO\s*:\s*(\d+)'
      in lv_upper submatches lv_bldg_no lv_door_no.
    if sy-subrc = 0.
      find first occurrence of regex '\s*NO\s*:' in lv_upper match offset lv_no_off.
      if sy-subrc = 0 and lv_no_off gt 0.
        lv_street_name = iv_street(lv_no_off).
        condense lv_street_name.
      endif.
    else.
      " Tek bina no
      find first occurrence of regex 'NO\s*:\s*(\d+[A-Za-z]?)'
        in lv_upper submatches lv_bldg_no.
      if sy-subrc = 0.
        find first occurrence of regex '\s*NO\s*:' in lv_upper match offset lv_no_off.
        if sy-subrc = 0 and lv_no_off gt 0.
          lv_street_name = iv_street(lv_no_off).
          condense lv_street_name.
        endif.
      endif.
    endif.

    " Site/blok ayristirma
    extract_site_blok(
      exporting
        iv_street        = lv_street_name
      importing
        ev_site_apartman = lv_site_apt
        ev_blok          = lv_blok
        ev_street_clean  = lv_street_base ).
    if lv_street_base is not initial.
      lv_street_name = lv_street_base.
    endif.

    " Cadde ayristirma
    find first occurrence of regex '(\S+\s+CAD[.\s])'
      in to_upper( lv_street_name )
      submatches lv_cadde
      match offset lv_cad_off.
    if sy-subrc = 0.
      condense lv_cadde.
      lv_after_cad = to_upper( lv_street_name ).
      lv_sk_off    = lv_cad_off + strlen( lv_cadde ).
      if lv_sk_off lt strlen( lv_after_cad ).
        lv_sokak = lv_after_cad+lv_sk_off.
        condense lv_sokak.
      endif.
    else.
      " Sokak ayristirma
      find first occurrence of
        regex '(\S+\s+(?:SK[.\s]|SOK[.\s]|SOKAK|SOKAGI))'
        in to_upper( lv_street_name ) submatches lv_sokak.
      if sy-subrc = 0.
        condense lv_sokak.
      else.
        lv_sokak = lv_street_name.
      endif.
    endif.

    append_field(
      exporting
        iv_name       ='cadde'
        iv_value      = lv_cadde
        iv_confidence = cond #( when lv_cadde = '' then '0.00' else '80.00' )
      changing
        ct_vals       = ct_vals ).
    append_field(
      exporting
        iv_name       ='sokak'
        iv_value      = lv_sokak
        iv_confidence = cond #( when lv_sokak = '' then '0.00' else '80.00' )
      changing
        ct_vals       = ct_vals ).
    append_field(
      exporting
        iv_name       ='site_apartman'
        iv_value      = lv_site_apt
        iv_confidence = cond #( when lv_site_apt = '' then '0.00' else '80.00' )
      changing
        ct_vals       = ct_vals ).
    append_field(
      exporting
        iv_name       ='blok'
        iv_value      = lv_blok
        iv_confidence = cond #( when lv_blok = '' then '0.00' else '80.00' )
      changing
        ct_vals       = ct_vals ).
    append_field(
      exporting
        iv_name       ='bina_no'
        iv_value      = lv_bldg_no
        iv_confidence = cond #( when lv_bldg_no = '' then '0.00' else '80.00' )
      changing
        ct_vals       = ct_vals ).
    append_field(
      exporting
        iv_name       ='ic_kapi_no'
        iv_value      = lv_door_no
        iv_confidence = cond #( when lv_door_no = '' then '0.00' else '80.00' )
      changing
        ct_vals       = ct_vals ).
  endmethod.

  " MAH iceren satirdan '/' iceren satirda bitecek sekilde tam_adres olusturur
  method find_address_line.
    data: lv_upper     type string,
          lt_lines     type standard table of string with empty key,
          lv_line      type string,
          lv_mah_idx   type i,
          lv_end_idx   type i,
          lv_idx       type i,
          lv_pipe_pos  type i,
          lv_total     type i,
          lv_next_line type string.

    lv_upper = to_upper( iv_text ).
    split lv_upper at cl_abap_char_utilities=>newline into table lt_lines.
    lv_total = lines( lt_lines ).

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

    lv_end_idx = lv_mah_idx.
    loop at lt_lines into lv_line from lv_mah_idx.
      lv_idx = sy-tabix.
      condense lv_line.
      if lv_line cs '/'.
        lv_end_idx = lv_idx.
        exit.
      endif.
      if lv_idx - lv_mah_idx gt 5.
        exit.
      endif.
    endloop.

    if lv_end_idx = lv_mah_idx.
      lv_idx = lv_mah_idx + 1.
      if lv_idx le lv_total.
        read table lt_lines index lv_idx into lv_line.
        if sy-subrc = 0.
          condense lv_line.
          if lv_line cs '/'.
            lv_end_idx = lv_idx.
          endif.
        endif.
      endif.
    endif.

    loop at lt_lines into lv_line from lv_mah_idx to lv_end_idx.
      condense lv_line.
      if lv_line is not initial and strlen( lv_line ) gt 3.
        replace first occurrence of regex '^ADRESI\s+' in lv_line with ''.
        condense lv_line.
        if rv_address is initial.
          rv_address = lv_line.
        else.
          rv_address = rv_address && | | && lv_line.
        endif.
      endif.
    endloop.

    " Format 3: satir '/' ile bitiyorsa sonraki satiri (il) ekle
    lv_next_line = get_next_city_line(
      iv_end_idx = lv_end_idx
      iv_total   = lv_total
      it_lines   = lt_lines ).
    if lv_next_line is not initial.
      rv_address = rv_address && | | && lv_next_line.
    endif.

    find first occurrence of '|' in rv_address match offset lv_pipe_pos.
    if sy-subrc = 0.
      lv_pipe_pos = lv_pipe_pos + 1.
      rv_address  = rv_address+lv_pipe_pos.
    endif.

    replace all occurrences of regex 'YERLE.IM\s+YER.' in rv_address with ''.
    replace all occurrences of regex 'YURT.C.'          in rv_address with ''.
    replace all occurrences of regex 'ADRES\s+T.P.'     in rv_address with ''.
    replace all occurrences of regex '\d{10}\s*'         in rv_address with ''.
    condense rv_address.
  endmethod.

  method parse_address_line.
    data: lv_addr         type string,
          lv_pos          type i,
          lv_before_slash type string,
          lv_after_slash  type string,
          lv_mah_end      type i,
          lv_mah_part     type string,
          lt_words        type standard table of string with empty key,
          lv_last_idx     type i,
          lv_street_start type i,
          lv_street_part  type string,
          lv_dist_pos     type i.

    clear: ev_neighborhood, ev_street, ev_district, ev_city.
    if iv_address is initial.
      return.
    endif.

    lv_addr = to_upper( iv_address ).
    condense lv_addr.

    find first occurrence of '/' in lv_addr match offset lv_pos.
    if sy-subrc = 0.
      if lv_pos = 0.
        lv_before_slash = ''.
      else.
        lv_before_slash = lv_addr(lv_pos).
      endif.
      lv_pos         = lv_pos + 1.
      lv_after_slash = lv_addr+lv_pos.
      condense lv_after_slash.
      ev_city = lv_after_slash.
      condense lv_before_slash.
      split lv_before_slash at ' ' into table lt_words.
      lv_last_idx = lines( lt_words ).
      if lv_last_idx gt 0.
        read table lt_words index lv_last_idx into ev_district.
        if sy-subrc ne 0.
          clear ev_district.
        endif.
      endif.
    endif.

    find first occurrence of 'MAH' in lv_addr match offset lv_mah_end.
    if sy-subrc = 0 and lv_mah_end gt 0.
      lv_mah_part = lv_addr(lv_mah_end).
      condense lv_mah_part.
      ev_neighborhood = lv_mah_part.
    endif.

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
      lv_street_part = lv_before_slash+lv_street_start.
      condense lv_street_part.
      if ev_district is not initial.
        find first occurrence of ev_district in lv_street_part match offset lv_dist_pos.
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

  method extract_site_blok.
    data: lv_up          type string,
          lv_site_pos    type i,
          lv_site_len    type i,
          lv_blok_pos    type i,
          lv_site_end    type i,
          lv_cad_sk_end  type i,
          lv_prefix_pos  type i,
          lv_prefix_len  type i,
          lv_site_raw    type string,
          lv_cut_len     type i,
          lv_remain_off  type i.

    clear: ev_site_apartman, ev_blok, ev_street_clean.
    ev_street_clean = iv_street.
    if iv_street is initial.
      return.
    endif.

    lv_up = to_upper( iv_street ).

    find first occurrence of
      regex '(RESIDENCE|SITESIN?[I]?|APARTMANI|APT\.?)'
      in lv_up match offset lv_site_pos match length lv_site_len.
    if sy-subrc ne 0.
      return.
    endif.

    find first occurrence of regex '\s?([A-Z])?\s*BLOK'
      in lv_up match offset lv_blok_pos submatches ev_blok.
    if sy-subrc = 0.
      lv_site_end = lv_blok_pos.
      condense ev_blok.
    else.
      lv_site_end = strlen( lv_up ).
    endif.

    find all occurrences of
      regex '(?:CAD\.|SK\.|SOK\.|SOKAK|SOKAGI)\s*'
      in lv_up match offset lv_prefix_pos match length lv_prefix_len.
    if sy-subrc = 0.
      lv_cad_sk_end = lv_prefix_pos + lv_prefix_len.
    else.
      lv_cad_sk_end = 0.
    endif.

    if lv_cad_sk_end gt 0 and lv_cad_sk_end lt lv_site_end.
      lv_site_raw = iv_street+lv_cad_sk_end.
      lv_cut_len  = lv_site_end - lv_cad_sk_end.
      if lv_cut_len gt 0 and lv_cut_len le strlen( lv_site_raw ).
        ev_site_apartman = lv_site_raw(lv_cut_len).
      else.
        ev_site_apartman = lv_site_raw.
      endif.
      condense ev_site_apartman.
      ev_street_clean = iv_street(lv_cad_sk_end).
      condense ev_street_clean.
    else.
      ev_site_apartman = iv_street(lv_site_end).
      condense ev_site_apartman.
      if lv_site_end lt strlen( iv_street ).
        lv_remain_off   = lv_site_end.
        ev_street_clean = iv_street+lv_remain_off.
        condense ev_street_clean.
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
          lv_col_pos   type i,
          lv_rest2     type string,
          lv_nl_pos2   type i.

    lv_upper    = to_upper( iv_text ).
    lv_label_up = to_upper( iv_label ).

    find first occurrence of lv_label_up in lv_upper match offset lv_pos.
    if sy-subrc ne 0.
      rv_value = ''.
      return.
    endif.

    lv_len_label = strlen( lv_label_up ).
    lv_len_text  = strlen( lv_upper ).
    lv_pos       = lv_pos + lv_len_label.
    if lv_pos ge lv_len_text.
      rv_value = ''.
      return.
    endif.

    lv_rest = iv_text+lv_pos.

    find first occurrence of cl_abap_char_utilities=>newline in lv_rest match offset lv_nl_pos.
    if sy-subrc = 0.
      lv_line = lv_rest(lv_nl_pos).
    else.
      lv_line = lv_rest.
    endif.

    find first occurrence of ':' in lv_line match offset lv_col_pos.
    if sy-subrc = 0.
      lv_col_pos = lv_col_pos + 1.
      lv_line    = lv_line+lv_col_pos.
    endif.
    condense lv_line.
    rv_value = lv_line.

    if rv_value is initial and lv_nl_pos is not initial.
      lv_rest2 = lv_rest+lv_nl_pos.
      shift lv_rest2 left deleting leading cl_abap_char_utilities=>newline.
      find first occurrence of cl_abap_char_utilities=>newline in lv_rest2 match offset lv_nl_pos2.
      if sy-subrc = 0.
        rv_value = lv_rest2(lv_nl_pos2).
      else.
        rv_value = lv_rest2.
      endif.
      condense rv_value.
    endif.
  endmethod.

  method extract_date_from_text.
    data: lo_regex   type ref to cl_abap_regex,
          lo_matcher type ref to cl_abap_matcher,
          lv_d_off   type i,
          lv_d_len   type i,
          lv_match   type string.

    create object lo_regex
      exporting
        pattern = '[0-9]{2}[.][0-9]{2}[.][0-9]{4}'.
    create object lo_matcher
      exporting
        regex = lo_regex
        text  = iv_text.
    if lo_matcher->find_next( ) = abap_true.
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

  method get_next_city_line.
    data: lv_line     type string,
          lv_stripped type string,
          lv_last_off type i,
          lv_lastchar type c length 1,
          lv_next_idx type i,
          lv_next     type string.

    rv_city = ''.
    read table it_lines index iv_end_idx into lv_line.
    if sy-subrc ne 0.
      return.
    endif.
    condense lv_line.
    lv_stripped = lv_line.
    replace regex '\s*$' in lv_stripped with ''.
    if strlen( lv_stripped ) = 0.
      return.
    endif.
    lv_last_off = strlen( lv_stripped ) - 1.
    lv_lastchar = substring(
      val = lv_stripped
      off = lv_last_off
      len = 1 ).
    if lv_lastchar ne '/'.
      return.
    endif.
    lv_next_idx = iv_end_idx + 1.
    if lv_next_idx gt iv_total.
      return.
    endif.
    read table it_lines index lv_next_idx into lv_next.
    if sy-subrc ne 0.
      return.
    endif.
    condense lv_next.
    if lv_next is not initial and strlen( lv_next ) gt 1.
      rv_city = lv_next.
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
