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

  " PDF to text
  data lo_parser type ref to zcl_zrpd_edev_doc_base.
  create object lo_parser.

  data lv_text type string.
  lv_text = lo_parser->pdf_to_text( lv_content ).

  if lv_text is initial.
    write: / 'PDF metin cikartma basarisiz.' color col_negative.
    return.
  endif.

  write: / 'Metin uzunlugu:', strlen( lv_text ), 'karakter'.
  uline.

  " TCKN extraction
  write: / '=== TCKN ===' color col_heading.
  try.
      data lv_tckn type string.
      lv_tckn = lo_parser->extract_tckn( lv_text ).
      write: / 'TCKN:', lv_tckn.

      data lv_valid type abap_bool.
      lv_valid = lo_parser->validate_tckn( lv_tckn ).
      if lv_valid = abap_true.
        write: / 'Checksum: GECERLI' color col_positive.
      else.
        write: / 'Checksum: HATALI' color col_negative.
      endif.
    catch zcx_zrpd_edev_extract into data(lx1).
      write: / 'TCKN bulunamadi:', lx1->mv_msgv1 color col_negative.
  endtry.
  uline.

  " Barcode extraction
  write: / '=== BARKOD ===' color col_heading.
  try.
      data lv_barcode type string.
      lv_barcode = lo_parser->extract_barcode( lv_text ).
      write: / 'Barkod:', lv_barcode.
    catch zcx_zrpd_edev_extract into data(lx2).
      write: / 'Barkod bulunamadi:', lx2->mv_msgv1 color col_negative.
  endtry.
  uline.

  " Full parse test (with IKA parser)
  write: / '=== FULL PARSE ===' color col_heading.
  data lo_ika type ref to zcl_zrpd_edev_doc_ika.
  data lt_vals type zrpd_edev_tt_dcval.
  data ls_val type zrpd_edev_s_dcval.

  create object lo_ika.
  try.
      lt_vals = lo_ika->parse_fields( lv_text ).
      loop at lt_vals into ls_val.
        write: / ls_val-field_name, ':', ls_val-field_value,
                 '(conf=', ls_val-confidence, ')'.
      endloop.
    catch zcx_zrpd_edev_extract into data(lx3).
      write: / 'Parse hatasi:', lx3->mv_msgv1 color col_negative.
  endtry.
