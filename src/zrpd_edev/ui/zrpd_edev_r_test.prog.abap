report zrpd_edev_r_test.

parameters: p_file type string lower case.

at selection-screen on value-request for p_file.
  data: lt_files  type filetable,
        lv_rc     type i,
        lv_action type i,
        ls_file   type file_table.

  cl_gui_frontend_services=>file_open_dialog(
    exporting
      window_title = 'PDF Dosya Sec'
      file_filter  = 'PDF (*.pdf)|*.pdf'
    changing
      file_table   = lt_files
      rc           = lv_rc
      user_action  = lv_action
    exceptions
      others       = 5 ).

  if sy-subrc = 0 and lv_action = cl_gui_frontend_services=>action_ok.
    read table lt_files into ls_file index 1.
    if sy-subrc = 0.
      p_file = ls_file-filename.
    endif.
  endif.

start-of-selection.

  data: lt_data     type solix_tab,
        lv_content  type xstring,
        lv_filesize type i.

  cl_gui_frontend_services=>gui_upload(
    exporting
      filename   = p_file
      filetype   = 'BIN'
    importing
      filelength = lv_filesize
    changing
      data_tab   = lt_data
    exceptions
      others     = 19 ).

  if sy-subrc is not initial.
    write: / 'Dosya okunamadi!' color col_negative.
    return.
  endif.

  lv_content = cl_bcs_convert=>solix_to_xstring( it_solix = lt_data ).
  write: / 'Dosya boyutu:', lv_filesize, 'byte'.
  uline.

  " 1. Once native text dene (SCMS)
  data lo_base type ref to zcl_zrpd_edev_doc_base.
  create object lo_base.

  data lv_text type string.
  lv_text = lo_base->pdf_to_text( lv_content ).

  " Native text yeterli mi kontrol et
  data lv_upper type string.
  lv_upper = to_upper( lv_text ).
  if lv_text is initial
    or strlen( lv_text ) > 100000
    or ( lv_upper ns 'KIMLIK' and lv_upper ns 'YERLESIM' and lv_upper ns 'ADRES' ).
    " Native text yetersiz — Python OCR kullan
    write: / 'Native text yetersiz, Python OCR baslatiliyor...' color col_total.
    data lo_ocr type ref to zcl_zrpd_edev_ocr_py.
    create object lo_ocr.
    try.
        lv_text = lo_ocr->zif_zrpd_edev_ext_svc~extract_text( lv_content ).
        write: / 'OCR tamamlandi.' color col_positive.
      catch zcx_zrpd_edev_api into data(lx_ocr).
        write: / 'OCR hatasi:', lx_ocr->get_text( ) color col_negative.
        return.
    endtry.
  else.
    write: / 'Native text kullaniliyor.' color col_positive.
  endif.

  write: / 'Metin uzunlugu:', strlen( lv_text ), 'karakter'.
  uline.

  " 2. TCKN extraction
  write: / '=== TCKN ===' color col_heading.
  try.
      data lv_tckn type string.
      lv_tckn = lo_base->extract_tckn( lv_text ).
      write: / 'TCKN:', lv_tckn.

      data lv_valid type abap_bool.
      lv_valid = lo_base->validate_tckn( lv_tckn ).
      if lv_valid = abap_true.
        write: / 'Checksum: GECERLI' color col_positive.
      else.
        write: / 'Checksum: HATALI' color col_negative.
      endif.
    catch zcx_zrpd_edev_extract into data(lx1).
      write: / 'TCKN bulunamadi:', lx1->get_text( ) color col_negative.
  endtry.
  uline.

  " 3. Barcode extraction
  write: / '=== BARKOD ===' color col_heading.
  try.
      data lv_barcode type string.
      lv_barcode = lo_base->extract_barcode( lv_text ).
      write: / 'Barkod:', lv_barcode.
    catch zcx_zrpd_edev_extract into data(lx2).
      write: / 'Barkod bulunamadi:', lx2->get_text( ) color col_negative.
  endtry.
  uline.

  " 4. Full parse (DOC_FAC -> config-driven parser)
  write: / '=== FULL PARSE ===' color col_heading.
  data lo_fac type ref to zcl_zrpd_edev_doc_fac.
  data lo_parser type ref to zcl_zrpd_edev_doc_base.
  data lt_vals type zrpd_edev_tt_dcval.
  data ls_val type zrpd_edev_s_dcval.

  create object lo_fac.
  try.
      lo_parser = lo_fac->create_parser( 'IKAMETGAH' ).
      write: / 'Parser:', lo_parser->get_doc_type( ) color col_positive.

      lt_vals = lo_parser->parse_fields( lv_text ).
      loop at lt_vals into ls_val.
        data lv_out type string.
        lv_out = |{ ls_val-field_name width = 15 align = left }: { ls_val-field_value } (conf={ ls_val-confidence })|.
        write: / lv_out.
      endloop.
    catch zcx_zrpd_edev_valid into data(lx_fac).
      write: / 'Factory hatasi:', lx_fac->get_text( ) color col_negative.
    catch zcx_zrpd_edev_extract into data(lx3).
      write: / 'Parse hatasi:', lx3->get_text( ) color col_negative.
  endtry.
