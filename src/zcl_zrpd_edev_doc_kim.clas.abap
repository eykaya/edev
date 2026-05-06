class zcl_zrpd_edev_doc_kim definition public
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
        iv_exact        type abap_bool default abap_false
      returning
        value(rv_value) type string.
    methods extract_seri_no
      importing
        iv_text        type string
      returning
        value(rv_seri) type string.
    methods append_field
      importing
        iv_name       type string
        iv_value      type string
        iv_confidence type string
      changing
        ct_vals       type zrpd_edev_tt_dcval.
    "! Tesseract Turkce OCR cikti normalize: I/U/S/C/O/G + kucuk
    methods normalize_turkish_chars
      changing
        cv_text type string.

endclass.

class zcl_zrpd_edev_doc_kim implementation.

  method get_doc_type.
    rv_type = 'KIMLIK'.
  endmethod.

  method validate_content.
    data lv_upper type string.
    lv_upper = to_upper( iv_text ).
    " NBSP sanitize
    data(lv_nbsp) = cl_abap_conv_in_ce=>uccp( '00A0' ).
    data(lv_repl) = | |.
    replace all occurrences of lv_nbsp in lv_upper with lv_repl.
    rv_valid = xsdbool(
      lv_upper cs 'KIMLIK KARTI BILGILER'
      or lv_upper cs 'NUFUS VE VATANDASLIK'
      or lv_upper cs 'KIMLIK KARTI'
      or lv_upper cs 'NUFUS CUZDANI' ).
  endmethod.

  method parse_fields.
    data: lv_text    type string,
          lv_nbsp    type c length 1,
          lv_repl    type string,
          lv_tckn    type string,
          lv_bc      type string,
          lv_seri    type string,
          lv_baba    type string,
          lv_anne    type string,
          lv_ad      type string,
          lv_soyad   type string,
          lv_dogum   type string,
          lv_offset  type i,
          lv_length  type i,
          ls_val     type zrpd_edev_s_dcval,
          lv_count   type i.

    " NBSP sanitize — ilk blok, her seyden once
    lv_text = iv_text.
    lv_nbsp = cl_abap_conv_in_ce=>uccp( '00A0' ).
    lv_repl = | |.
    replace all occurrences of lv_nbsp in lv_text with lv_repl.

    " Turkce karakter normalize: Tesseract Turkce OCR ciktisinda I, U, S, C, O, G
    " (buyuk harf) ve i, u, s, c, o, g (kucuk harf) olarak yazi cumhuriyet vs olur
    " label match dogru calissin diye tum text ASCII'ye cevriliyor
    normalize_turkish_chars( changing cv_text = lv_text ).

    " TC KIMLIK NO
    try.
        lv_tckn = extract_tckn( lv_text ).
      catch zcx_zrpd_edev.
    endtry.
    append_field(
      exporting
        iv_name       = 'tc_kimlik_no'
        iv_value      = lv_tckn
        iv_confidence = cond #( when lv_tckn = '' then '0.00' else '100.00' )
      changing
        ct_vals       = rt_vals ).

    " BARKOD
    try.
        lv_bc = extract_barcode( lv_text ).
      catch zcx_zrpd_edev.
    endtry.
    append_field(
      exporting
        iv_name       = 'barkod'
        iv_value      = lv_bc
        iv_confidence = cond #( when lv_bc = '' then '0.00' else '100.00' )
      changing
        ct_vals       = rt_vals ).

    " SERI NO
    lv_seri = extract_seri_no( lv_text ).
    append_field(
      exporting
        iv_name       = 'seri_no'
        iv_value      = lv_seri
        iv_confidence = cond #( when lv_seri = '' then '0.00' else '90.00' )
      changing
        ct_vals       = rt_vals ).

    " BABA ADI — TR-yeni / EN-tam / EN-kisa / TR-eski fallback
    lv_baba = extract_by_label( iv_text = lv_text iv_label = 'Baba Adi' ).
    if lv_baba is initial.
      lv_baba = extract_by_label(
                  iv_text  = lv_text
                  iv_label = `Father's Name` ).
    endif.
    if lv_baba is initial.
      lv_baba = extract_by_label(
                  iv_text  = lv_text
                  iv_label = 'Father' ).
    endif.
    if lv_baba is initial.
      lv_baba = extract_by_label(
                  iv_text  = lv_text
                  iv_label = 'Babanin Adi' ).
    endif.
    condense lv_baba.
    append_field(
      exporting
        iv_name       = 'baba_adi'
        iv_value      = lv_baba
        iv_confidence = cond #( when lv_baba = '' then '0.00' else '90.00' )
      changing
        ct_vals       = rt_vals ).

    " ANNE ADI
    lv_anne = extract_by_label( iv_text = lv_text iv_label = 'Anne Adi' ).
    if lv_anne is initial.
      lv_anne = extract_by_label( iv_text = lv_text iv_label = `Mother's Name` ).
    endif.
    if lv_anne is initial.
      lv_anne = extract_by_label( iv_text = lv_text iv_label = 'Mother' ).
    endif.
    if lv_anne is initial.
      lv_anne = extract_by_label( iv_text = lv_text iv_label = 'Annenin Adi' ).
    endif.
    condense lv_anne.
    append_field(
      exporting
        iv_name       = 'anne_adi'
        iv_value      = lv_anne
        iv_confidence = cond #( when lv_anne = '' then '0.00' else '90.00' )
      changing
        ct_vals       = rt_vals ).

    " SOYAD — starts-with-separator (satir basinda 'Soyadi' + ' '/'/'/':')
    lv_soyad = extract_by_label(
                 iv_text  = lv_text
                 iv_label = 'Soyadi'
                 iv_exact = abap_true ).
    condense lv_soyad.
    append_field(
      exporting
        iv_name       = 'soyad'
        iv_value      = lv_soyad
        iv_confidence = cond #( when lv_soyad = '' then '0.00' else '90.00' )
      changing
        ct_vals       = rt_vals ).

    " AD — starts-with-separator (Soyadi icinde Adi substring oldugu icin exact gerekli)
    lv_ad = extract_by_label(
              iv_text  = lv_text
              iv_label = 'Adi'
              iv_exact = abap_true ).
    condense lv_ad.
    append_field(
      exporting
        iv_name       = 'ad'
        iv_value      = lv_ad
        iv_confidence = cond #( when lv_ad = '' then '0.00' else '90.00' )
      changing
        ct_vals       = rt_vals ).

    " DOGUM TARIHI — label + regex fallback (dd.mm.yyyy)
    lv_dogum = extract_by_label( iv_text = lv_text iv_label = 'Dogum Tarihi' ).
    " Label sonucu varsa: regex ile dd.mm.yyyy formatini cikart
    if lv_dogum is not initial.
      find first occurrence of regex '\d{2}[./-]\d{2}[./-]\d{4}'
        in lv_dogum match offset lv_offset match length lv_length.
      if sy-subrc = 0.
        lv_dogum = substring( val = lv_dogum off = lv_offset len = lv_length ).
      else.
        clear lv_dogum.
      endif.
    endif.
    " Regex fallback — tam metinde
    if lv_dogum is initial.
      find first occurrence of regex '\d{2}[./-]\d{2}[./-]\d{4}'
        in lv_text match offset lv_offset match length lv_length.
      if sy-subrc = 0.
        lv_dogum = substring( val = lv_text off = lv_offset len = lv_length ).
      endif.
    endif.
    append_field(
      exporting
        iv_name       = 'dogum_tarihi'
        iv_value      = lv_dogum
        iv_confidence = cond #( when lv_dogum = '' then '0.00' else '85.00' )
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

  method extract_seri_no.
    data: lv_offset type i,
          lv_length type i.

    " Label chain: 'Seri No' → 'Belge No' → 'Seri Numaras' (prefix, son harf i/ı farkı)
    rv_seri = extract_by_label( iv_text = iv_text iv_label = 'Seri No' ).
    if rv_seri is initial.
      rv_seri = extract_by_label( iv_text = iv_text iv_label = 'Belge No' ).
    endif.
    if rv_seri is initial.
      rv_seri = extract_by_label( iv_text = iv_text iv_label = 'Seri Numaras' ).
    endif.

    " Label sonucu varsa dogrula: sadece beklenen formatta ise kab ul et
    if rv_seri is not initial.
      " Yeni nesil kart: A00A00000 (1 harf + 2 rakam + 1 harf + 5 rakam)
      find first occurrence of regex '[A-Z][0-9]{2}[A-Z][0-9]{5}'
        in rv_seri match offset lv_offset match length lv_length.
      if sy-subrc = 0.
        rv_seri = substring( val = rv_seri off = lv_offset len = lv_length ).
        return.
      endif.
      " Genis varyant: 1-2 buyuk harf + 6-9 rakam
      find first occurrence of regex '[A-Z]{1,2}[0-9]{6,9}'
        in rv_seri match offset lv_offset match length lv_length.
      if sy-subrc = 0.
        rv_seri = substring( val = rv_seri off = lv_offset len = lv_length ).
        return.
      endif.
      " Label buldu ama formata uymadi — label degerini temizle, regex fallback'e gec
      clear rv_seri.
    endif.

    " Regex fallback — tam metinde ara
    " Once yeni nesil format (oncelikli)
    find first occurrence of regex '[A-Z][0-9]{2}[A-Z][0-9]{5}'
      in iv_text match offset lv_offset match length lv_length.
    if sy-subrc = 0.
      rv_seri = substring( val = iv_text off = lv_offset len = lv_length ).
      return.
    endif.

    " Genis varyant fallback
    find first occurrence of regex '[A-Z]{1,2}[0-9]{6,9}'
      in iv_text match offset lv_offset match length lv_length.
    if sy-subrc = 0.
      rv_seri = substring( val = iv_text off = lv_offset len = lv_length ).
    endif.
    " Bulunamazsa rv_seri = '' — DMAP eslemesi icin field yine de rt_vals'a eklenir
  endmethod.

  method extract_by_label.
    " Satir-tabanli extraction:
    " - iv_exact=true: satir label ile basliyor + sonra ' ' / ':' / satir sonu (substring confusion onler)
    " - iv_exact=false: satir label substring (cs)
    " Label bulunduktan sonra ilk non-empty + ':' olmayan satir deger
    data: lt_lines    type standard table of string with empty key,
          lv_line     type string,
          lv_clean    type string,
          lv_clean_up type string,
          lv_label_up type string,
          lv_found    type abap_bool,
          lv_lbl_len  type i,
          lv_after    type c length 1.

    lv_label_up = to_upper( iv_label ).
    lv_found    = abap_false.

    split iv_text at cl_abap_char_utilities=>newline into table lt_lines.

    loop at lt_lines into lv_line.
      lv_clean    = lv_line.
      condense lv_clean.
      lv_clean_up = to_upper( lv_clean ).

      if lv_found = abap_false.
        if iv_exact = abap_true.
          " Satir label ile basliyor + sonra separator (' ', '/', ':') veya satir sonu
          lv_lbl_len = strlen( lv_label_up ).
          if strlen( lv_clean_up ) >= lv_lbl_len
             and lv_clean_up(lv_lbl_len) = lv_label_up.
            if strlen( lv_clean_up ) = lv_lbl_len.
              lv_found = abap_true.
            else.
              lv_after = lv_clean_up+lv_lbl_len(1).
              if lv_after ca '/ :'.
                lv_found = abap_true.
              endif.
            endif.
          endif.
        else.
          if lv_clean_up cs lv_label_up.
            lv_found = abap_true.
          endif.
        endif.
        continue.
      endif.

      " Label bulundu — ilk non-empty, sadece ':' olmayan satir
      if lv_clean is initial or lv_clean = ':'.
        continue.
      endif.

      " ':' ile basliyorsa prefix temizle
      if lv_clean(1) = ':'.
        lv_clean = lv_clean+1.
        condense lv_clean.
      endif.

      " Keyword reject: baska label basligi ise pas gec
      lv_clean_up = to_upper( lv_clean ).
      if lv_clean_up cs 'KIMLIK'
      or lv_clean_up cs 'ADRES'
      or lv_clean_up cs 'SOYAD'.
        rv_value = ''.
        return.
      endif.

      rv_value = lv_clean.
      return.
    endloop.
  endmethod.

  method append_field.
    data ls_val type zrpd_edev_s_dcval.
    ls_val-field_name     = iv_name.
    ls_val-field_value    = iv_value.
    ls_val-confidence     = iv_confidence.
    ls_val-extract_method = 'FORM'.
    append ls_val to ct_vals.
  endmethod.

  method normalize_turkish_chars.
    " Tesseract Turkce OCR ciktisinda gelen Turkce karakterleri ASCII'ye cevirir
    " Boylece label match (Soyadi, Adi, Dogum Tarihi vs.) Turkce karakterli textte de calisir
    data lv_char type c length 1.
    " Buyuk harfler
    lv_char = cl_abap_conv_in_ce=>uccp( '0130' ).  " I (Turkce buyuk i)
    replace all occurrences of lv_char in cv_text with 'I'.
    lv_char = cl_abap_conv_in_ce=>uccp( '00DC' ).  " U
    replace all occurrences of lv_char in cv_text with 'U'.
    lv_char = cl_abap_conv_in_ce=>uccp( '015E' ).  " S
    replace all occurrences of lv_char in cv_text with 'S'.
    lv_char = cl_abap_conv_in_ce=>uccp( '00C7' ).  " C
    replace all occurrences of lv_char in cv_text with 'C'.
    lv_char = cl_abap_conv_in_ce=>uccp( '00D6' ).  " O
    replace all occurrences of lv_char in cv_text with 'O'.
    lv_char = cl_abap_conv_in_ce=>uccp( '011E' ).  " G
    replace all occurrences of lv_char in cv_text with 'G'.
    " Kucuk harfler (to_upper sonrasi I/U/S/C/O/G olur)
    lv_char = cl_abap_conv_in_ce=>uccp( '0131' ).  " i (noktasiz kucuk i)
    replace all occurrences of lv_char in cv_text with 'i'.
    lv_char = cl_abap_conv_in_ce=>uccp( '00FC' ).  " u
    replace all occurrences of lv_char in cv_text with 'u'.
    lv_char = cl_abap_conv_in_ce=>uccp( '015F' ).  " s
    replace all occurrences of lv_char in cv_text with 's'.
    lv_char = cl_abap_conv_in_ce=>uccp( '00E7' ).  " c
    replace all occurrences of lv_char in cv_text with 'c'.
    lv_char = cl_abap_conv_in_ce=>uccp( '00F6' ).  " o
    replace all occurrences of lv_char in cv_text with 'o'.
    lv_char = cl_abap_conv_in_ce=>uccp( '011F' ).  " g
    replace all occurrences of lv_char in cv_text with 'g'.
  endmethod.

endclass.
