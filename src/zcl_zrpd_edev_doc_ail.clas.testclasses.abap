"! ABAP Unit Tests for ZCL_ZRPD_EDEV_DOC_AIL
"! TDD - Faz 5 test senaryolari
"! Risk: HARMLESS, Duration: SHORT
"!
"! Yeni parser'a uygun guncellendi:
"! - Line-based parse (her hucre ayri satir)
"! - 'Evli'/'Bekar' stop marker (MED.HALI cell)
"! - P0021 mapping: FANAM=Soyadi (Nachname), FAVOR=Adi (Vorname)
class lcl_test definition final for testing
  risk level harmless
  duration short.

  private section.
    data lo type ref to zcl_zrpd_edev_doc_ail.

    methods setup.

    methods get_field_value
      importing
        it_vals       type zrpd_edev_tt_dcval
        iv_field      type string
      returning
        value(rv_val) type string.

    methods append_aile_row
      importing
        iv_sira     type string
        iv_bsn      type string
        iv_cins     type string
        iv_yakinlik type string
        iv_tckn     type string
        iv_adi      type string
        iv_soyad    type string
        iv_baba     type string
        iv_ana      type string
        iv_yer      type string
        iv_medhal   type string
        iv_tescil   type string
        iv_evlenme  type string
        iv_dogum    type string
      changing
        ct_lines    type string_table.

    methods build_ocr_text
      returning
        value(rv_text) type string.

    methods build_ocr_text_compound
      returning
        value(rv_text) type string.

    methods build_ocr_text_dusunceler
      returning
        value(rv_text) type string.

    methods call_parse
      importing
        iv_text        type string
      returning
        value(rt_vals) type zrpd_edev_tt_dcval.

    methods get_doc_type_returns_aile     for testing.
    methods validate_content_pos          for testing.
    methods validate_content_neg          for testing.
    methods parse_fields_barkod           for testing.
    methods parse_fields_kendisi_atlanir  for testing.
    methods parse_fields_es_satiri        for testing.
    methods parse_fields_kizi_satiri      for testing.
    methods nbsp_separator_handled        for testing.
    methods gender_variant_k_returns_2    for testing.
    methods compound_ad_parse_dogru       for testing.
    methods dusunceler_table_end_detected for testing.

endclass.

class lcl_test implementation.

  method setup.
    lo = new zcl_zrpd_edev_doc_ail( ).
  endmethod.

  method get_field_value.
    data ls_val type zrpd_edev_s_dcval.
    read table it_vals with key field_name = iv_field into ls_val.
    if sy-subrc = 0.
      rv_val = ls_val-field_value.
    endif.
  endmethod.

  method append_aile_row.
    " PDF text-extraction layout: her cell ayri satir
    append iv_sira      to ct_lines.
    append iv_bsn       to ct_lines.
    append iv_cins      to ct_lines.
    append iv_yakinlik  to ct_lines.
    append iv_tckn      to ct_lines.
    append iv_adi       to ct_lines.
    append iv_soyad     to ct_lines.
    append iv_baba      to ct_lines.
    append iv_ana       to ct_lines.
    append iv_yer       to ct_lines.
    append iv_medhal    to ct_lines.
    append iv_tescil    to ct_lines.
    append `Olum:`      to ct_lines.
    append `SAG`        to ct_lines.
    append `Islam`      to ct_lines.
    append `Evlenme:`   to ct_lines.
    append iv_evlenme   to ct_lines.
    append iv_dogum     to ct_lines.
    append `Bosanma:`   to ct_lines.
    append `----------` to ct_lines.
  endmethod.

  method build_ocr_text.
    " Standart line-based OCR — ELIF (Kendisi, atlanir), ERKAN (Esi), INCI (Kizi)
    data lt_lines type string_table.
    append `NUFUS KAYIT ORNEGI                                                    NV01-3ZF4-BJ52-XRXJ` to lt_lines.
    append `` to lt_lines.
    append `ILI      ILCESI          MAHALLESI/KOYU   CILT NO   HANE NO` to lt_lines.
    append `AMASYA   TASOVA (1668)   ESENCAY KOYU     23        211` to lt_lines.
    append `` to lt_lines.
    append `SIRA BSN C YAKINLIK DERECESI T.C. KIMLIK NO ADI SOYADI BABA ADI ANA ADI DOGUM YERI VE TARIHI` to lt_lines.
    append `` to lt_lines.

    append_aile_row(
      exporting
        iv_sira = `1` iv_bsn = `43` iv_cins = `K` iv_yakinlik = `Kendisi`
        iv_tckn = `33265865480` iv_adi = `ELIF` iv_soyad = `BEK`
        iv_baba = `ZEKERIYA` iv_ana = `SELVER` iv_yer = `ARAC`
        iv_medhal = `Evli` iv_tescil = `05.04.1999`
        iv_evlenme = `25.02.2024` iv_dogum = `06.03.1999`
      changing ct_lines = lt_lines ).

    append_aile_row(
      exporting
        iv_sira = `2` iv_bsn = `30` iv_cins = `E` iv_yakinlik = `Esi`
        iv_tckn = `22750235006` iv_adi = `ERKAN` iv_soyad = `BEK`
        iv_baba = `ALI` iv_ana = `SAFER` iv_yer = `BAKIRKOY`
        iv_medhal = `Evli` iv_tescil = `25.02.2024`
        iv_evlenme = `25.02.2024` iv_dogum = `06.02.1996`
      changing ct_lines = lt_lines ).

    append_aile_row(
      exporting
        iv_sira = `3` iv_bsn = `44` iv_cins = `K` iv_yakinlik = `Kizi`
        iv_tckn = `74320063588` iv_adi = `INCI` iv_soyad = `BEK`
        iv_baba = `ERKAN` iv_ana = `ELIF` iv_yer = `BAKIRKOY`
        iv_medhal = `Bekar` iv_tescil = `01.10.2025`
        iv_evlenme = `----------` iv_dogum = `25.09.2025`
      changing ct_lines = lt_lines ).

    append `ACIKLAMALAR` to lt_lines.

    rv_text = concat_lines_of( table = lt_lines sep = cl_abap_char_utilities=>newline ).
  endmethod.

  method build_ocr_text_compound.
    " Compound ad: 'INCI SERA' (iki kelimeli ad — line-based parse tek satirda korur)
    data lt_lines type string_table.
    append `NUFUS KAYIT ORNEGI                                                    NV01-3ZF4-BJ52-XRXJ` to lt_lines.
    append `` to lt_lines.
    append `SIRA BSN C YAKINLIK DERECESI T.C. KIMLIK NO ADI SOYADI BABA ADI ANA ADI DOGUM YERI VE TARIHI` to lt_lines.
    append `` to lt_lines.

    append_aile_row(
      exporting
        iv_sira = `2` iv_bsn = `30` iv_cins = `E` iv_yakinlik = `Esi`
        iv_tckn = `22750235006` iv_adi = `ERKAN` iv_soyad = `BEK`
        iv_baba = `ALI` iv_ana = `SAFER` iv_yer = `BAKIRKOY`
        iv_medhal = `Evli` iv_tescil = `25.02.2024`
        iv_evlenme = `25.02.2024` iv_dogum = `06.02.1996`
      changing ct_lines = lt_lines ).

    append_aile_row(
      exporting
        iv_sira = `3` iv_bsn = `44` iv_cins = `K` iv_yakinlik = `Kizi`
        iv_tckn = `74320063588` iv_adi = `INCI SERA` iv_soyad = `BEK`
        iv_baba = `ERKAN` iv_ana = `ELIF` iv_yer = `BAKIRKOY`
        iv_medhal = `Bekar` iv_tescil = `01.10.2025`
        iv_evlenme = `----------` iv_dogum = `25.09.2025`
      changing ct_lines = lt_lines ).

    append `ACIKLAMALAR` to lt_lines.

    rv_text = concat_lines_of( table = lt_lines sep = cl_abap_char_utilities=>newline ).
  endmethod.

  method build_ocr_text_dusunceler.
    " Tablo sonu: 'DUSUNCELER' tek basina algilanmali
    data lt_lines type string_table.
    append `NUFUS KAYIT ORNEGI                                NV01-TEST-1234-ABCD` to lt_lines.
    append `` to lt_lines.
    append `SIRA BSN C YAKINLIK DERECESI T.C. KIMLIK NO ADI SOYADI BABA ADI ANA ADI DOGUM YERI VE TARIHI` to lt_lines.
    append `` to lt_lines.

    append_aile_row(
      exporting
        iv_sira = `2` iv_bsn = `30` iv_cins = `E` iv_yakinlik = `Esi`
        iv_tckn = `22750235006` iv_adi = `ERKAN` iv_soyad = `BEK`
        iv_baba = `ALI` iv_ana = `SAFER` iv_yer = `ISTANBUL`
        iv_medhal = `Evli` iv_tescil = `25.02.2024`
        iv_evlenme = `25.02.2024` iv_dogum = `06.02.1996`
      changing ct_lines = lt_lines ).

    append `BSN ADI DUSUNCELER` to lt_lines.

    " Tablo disinda kalmasi gereken sahte kayit
    append_aile_row(
      exporting
        iv_sira = `9` iv_bsn = `99` iv_cins = `K` iv_yakinlik = `Kizi`
        iv_tckn = `11111111110` iv_adi = `SAHTE` iv_soyad = `KAYIT`
        iv_baba = `ALI` iv_ana = `VELI` iv_yer = `ISTANBUL`
        iv_medhal = `Bekar` iv_tescil = `01.01.2000`
        iv_evlenme = `----------` iv_dogum = `01.01.2000`
      changing ct_lines = lt_lines ).

    rv_text = concat_lines_of( table = lt_lines sep = cl_abap_char_utilities=>newline ).
  endmethod.

  method call_parse.
    try.
      rt_vals = lo->parse_fields( iv_text ).
    catch zcx_zrpd_edev into data(lo_ex).
      cl_abap_unit_assert=>fail( |parse_fields exception: { lo_ex->get_text( ) }| ).
    endtry.
  endmethod.

  method get_doc_type_returns_aile.
    cl_abap_unit_assert=>assert_equals(
      exp = 'AILE'
      act = lo->get_doc_type( )
      msg = 'get_doc_type AILE donmeli' ).
  endmethod.

  method validate_content_pos.
    cl_abap_unit_assert=>assert_true(
      act = lo->validate_content( build_ocr_text( ) )
      msg = 'NUFUS KAYIT ORNEGI + YAKINLIK iceren metin gecerli olmali' ).
  endmethod.

  method validate_content_neg.
    data(lv_text) = `KIMLIK KARTI BILGILERI` && cl_abap_char_utilities=>newline &&
                    `TC KIMLIK NO: 12345678901`.
    cl_abap_unit_assert=>assert_false(
      act = lo->validate_content( lv_text )
      msg = 'Kimlik karti metni AILE icin gecersiz olmali' ).
  endmethod.

  method parse_fields_barkod.
    data(lt_vals) = call_parse( build_ocr_text( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'NV01-3ZF4-BJ52-XRXJ'
      act = get_field_value( it_vals = lt_vals iv_field = 'barkod' )
      msg = 'Barkod dogru parse edilmeli' ).
  endmethod.

  method parse_fields_kendisi_atlanir.
    data(lt_vals) = call_parse( build_ocr_text( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'ESI'
      act = get_field_value( it_vals = lt_vals iv_field = 'row_1__yakinlik' )
      msg = 'Kendisi atlandi, ilk row Es olmali' ).
  endmethod.

  method parse_fields_es_satiri.
    data(lt_vals) = call_parse( build_ocr_text( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '22750235006'
      act = get_field_value( it_vals = lt_vals iv_field = 'row_1__erbnr' )
      msg = 'Es TCKN' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'ESI'
      act = get_field_value( it_vals = lt_vals iv_field = 'row_1__yakinlik' )
      msg = 'Es yakinlik ESI' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BEK'
      act = get_field_value( it_vals = lt_vals iv_field = 'row_1__fanam' )
      msg = 'P0021-FANAM=Nachname (Soyad) -> BEK' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'ERKAN'
      act = get_field_value( it_vals = lt_vals iv_field = 'row_1__favor' )
      msg = 'P0021-FAVOR=Vorname (Ad) -> ERKAN' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1'
      act = get_field_value( it_vals = lt_vals iv_field = 'row_1__fasex' )
      msg = 'Es E -> fasex=1' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '19960206'
      act = get_field_value( it_vals = lt_vals iv_field = 'row_1__fgbdt' )
      msg = 'Es dogum tarihi 19960206' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BAKIRKOY'
      act = get_field_value( it_vals = lt_vals iv_field = 'row_1__fgbot' )
      msg = 'Es dogum yeri BAKIRKOY' ).
  endmethod.

  method parse_fields_kizi_satiri.
    data(lt_vals) = call_parse( build_ocr_text( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '74320063588'
      act = get_field_value( it_vals = lt_vals iv_field = 'row_2__erbnr' )
      msg = 'Kizi TCKN' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'KIZI'
      act = get_field_value( it_vals = lt_vals iv_field = 'row_2__yakinlik' )
      msg = 'Kizi yakinlik KIZI' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BEK'
      act = get_field_value( it_vals = lt_vals iv_field = 'row_2__fanam' )
      msg = 'P0021-FANAM=Soyad -> BEK' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'INCI'
      act = get_field_value( it_vals = lt_vals iv_field = 'row_2__favor' )
      msg = 'P0021-FAVOR=Ad -> INCI' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2'
      act = get_field_value( it_vals = lt_vals iv_field = 'row_2__fasex' )
      msg = 'Kizi K -> fasex=2' ).
  endmethod.

  method nbsp_separator_handled.
    data: lv_nbsp  type c length 1,
          lv_text  type string,
          lt_lines type string_table.

    lv_nbsp = cl_abap_conv_in_ce=>uccp( '00A0' ).

    data(lv_header) = `NUFUS` && lv_nbsp && `KAYIT` && lv_nbsp && `ORNEGI` &&
                      `                                NV01-3ZF4-BJ52-XRXJ`.
    append lv_header to lt_lines.
    append `` to lt_lines.
    append `SIRA BSN C YAKINLIK DERECESI T.C. KIMLIK NO ADI SOYADI BABA ADI ANA ADI` to lt_lines.
    append `` to lt_lines.

    append_aile_row(
      exporting
        iv_sira = `2` iv_bsn = `30` iv_cins = `E` iv_yakinlik = `Esi`
        iv_tckn = `22750235006` iv_adi = `ERKAN` iv_soyad = `BEK`
        iv_baba = `ALI` iv_ana = `SAFER` iv_yer = `BAKIRKOY`
        iv_medhal = `Evli` iv_tescil = `25.02.2024`
        iv_evlenme = `25.02.2024` iv_dogum = `06.02.1996`
      changing ct_lines = lt_lines ).

    append `ACIKLAMALAR` to lt_lines.

    lv_text = concat_lines_of( table = lt_lines sep = cl_abap_char_utilities=>newline ).

    cl_abap_unit_assert=>assert_true(
      act = lo->validate_content( lv_text )
      msg = 'NBSP iceren metin validate_content gecerli' ).

    data(lt_vals) = call_parse( lv_text ).
    cl_abap_unit_assert=>assert_equals(
      exp = '22750235006'
      act = get_field_value( it_vals = lt_vals iv_field = 'row_1__erbnr' )
      msg = 'NBSP iceren metinde Es TCKN parse edilmeli' ).
  endmethod.

  method gender_variant_k_returns_2.
    data(lt_vals) = call_parse( build_ocr_text( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = '2'
      act = get_field_value( it_vals = lt_vals iv_field = 'row_2__fasex' )
      msg = 'Kizi K -> fasex=2' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '1'
      act = get_field_value( it_vals = lt_vals iv_field = 'row_1__fasex' )
      msg = 'Es E -> fasex=1' ).
  endmethod.

  method compound_ad_parse_dogru.
    " Compound ad: 'INCI SERA' tek satirda 2 kelime — favor'a yazilmali
    data(lt_vals) = call_parse( build_ocr_text_compound( ) ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'INCI SERA'
      act = get_field_value( it_vals = lt_vals iv_field = 'row_2__favor' )
      msg = 'Compound ad INCI SERA favor`a yazilmali (P0021-FAVOR=Ad)' ).
    cl_abap_unit_assert=>assert_equals(
      exp = 'BEK'
      act = get_field_value( it_vals = lt_vals iv_field = 'row_2__fanam' )
      msg = 'Compound ad durumunda fanam=BEK (Soyad)' ).
    cl_abap_unit_assert=>assert_equals(
      exp = '74320063588'
      act = get_field_value( it_vals = lt_vals iv_field = 'row_2__erbnr' )
      msg = 'Compound TCKN' ).
  endmethod.

  method dusunceler_table_end_detected.
    data(lt_vals) = call_parse( build_ocr_text_dusunceler( ) ).

    cl_abap_unit_assert=>assert_equals(
      exp = '22750235006'
      act = get_field_value( it_vals = lt_vals iv_field = 'row_1__erbnr' )
      msg = 'Es TCKN parse' ).

    cl_abap_unit_assert=>assert_initial(
      act = get_field_value( it_vals = lt_vals iv_field = 'row_2__erbnr' )
      msg = 'DUSUNCELER sonrasi sahte kayit parse edilmemeli' ).
  endmethod.

endclass.
