report zrpd_edev_r_test.

selection-screen begin of block b1 with frame title gv_t1.
  parameters: p_mode type c length 1 default '1'.
selection-screen end of block b1.

selection-screen begin of block b2 with frame title gv_t2.
  parameters: p_file type string lower case.
selection-screen end of block b2.

selection-screen begin of block b3 with frame title gv_t3.
  parameters: p_tckn type char11,
              p_bc   type zrpd_edev_de_bcno.
selection-screen end of block b3.

initialization.
  gv_t1 = 'Test Modu (1=Dosya, 2=e-Devlet)'.
  gv_t2 = 'Mod 1: Dosyadan Yukle'.
  gv_t3 = 'Mod 2: e-Devlet (TCKN + Barkod)'.

at selection-screen on value-request for p_file.
  data: lt_files type filetable, lv_rc type i, lv_action type i, ls_file type file_table.
  cl_gui_frontend_services=>file_open_dialog(
    exporting window_title = 'PDF Dosya Sec' file_filter = 'PDF (*.pdf)|*.pdf'
    changing file_table = lt_files rc = lv_rc user_action = lv_action exceptions others = 5 ).
  if sy-subrc = 0 and lv_action = cl_gui_frontend_services=>action_ok.
    read table lt_files into ls_file index 1. if sy-subrc = 0. p_file = ls_file-filename. endif. endif.

start-of-selection.

  data: lv_content type xstring, lv_text type string, lv_filesize type i.

  case p_mode.
    when '1'.
      " === MOD 1: Dosyadan ===
      if p_file is initial. write: / 'Dosya secilmedi!' color col_negative. return. endif.
      data lt_data type solix_tab.
      cl_gui_frontend_services=>gui_upload(
        exporting filename = p_file filetype = 'BIN'
        importing filelength = lv_filesize changing data_tab = lt_data exceptions others = 19 ).
      if sy-subrc is not initial. write: / 'Dosya okunamadi!' color col_negative. return. endif.
      lv_content = cl_bcs_convert=>solix_to_xstring( it_solix = lt_data ).
      write: / 'Dosya boyutu:', lv_filesize, 'byte'.

    when '2'.
      " === MOD 2: e-Devlet JSON -> barkodluBelge (Base64 PDF) ===
      if p_tckn is initial or p_bc is initial. write: / 'TCKN ve Barkod zorunlu!' color col_negative. return. endif.
      data: lo_http type ref to if_http_client, lv_uri type string,
            lv_bc_s type string, lv_tc_s type string, lv_status type i, lv_reason type string.
      lv_bc_s = p_bc. condense lv_bc_s no-gaps.
      lv_tc_s = p_tckn. condense lv_tc_s no-gaps.
      concatenate '/api.php?p=belge-dogrulama&qr=barkod:' lv_bc_s ';tckn:' lv_tc_s ';' into lv_uri.
      write: / 'URI:', lv_uri.

      cl_http_client=>create_by_destination(
        exporting destination = 'ZRPD_EDEV_EDEVLET'
        importing client = lo_http exceptions others = 4 ).
      if sy-subrc <> 0. write: / 'SM59 hata!' color col_negative. return. endif.
      cl_http_utility=>set_request_uri( exporting request = lo_http->request uri = lv_uri ).
      lo_http->request->set_method( if_http_request=>co_request_method_get ).
      lo_http->send( exporting timeout = 60 exceptions others = 4 ).
      if sy-subrc <> 0. write: / 'HTTP send hata!' color col_negative. lo_http->close( ). return. endif.
      lo_http->receive( exceptions others = 4 ).
      if sy-subrc <> 0. write: / 'HTTP receive hata!' color col_negative. lo_http->close( ). return. endif.

      lo_http->response->get_status( importing code = lv_status reason = lv_reason ).
      data lv_ctype type string.
      lv_ctype = lo_http->response->get_header_field( name = 'content-type' ).
      write: / 'HTTP:', lv_status, lv_reason.
      write: / 'Content-Type:', lv_ctype.

      data lv_json type string.
      lv_json = lo_http->response->get_cdata( ).
      lo_http->close( ).
      write: / 'JSON uzunlugu:', strlen( lv_json ).

      " JSON'dan return kontrolu
      data lv_json_lower type string.
      lv_json_lower = lv_json. translate lv_json_lower to lower case.
      if lv_json_lower cs '"return":false'.
        write: / 'e-Devlet: GECERSIZ BELGE (return=false)' color col_negative. return.
      endif.
      if lv_json_lower cs '"return":true'.
        write: / 'e-Devlet: GECERLI BELGE (return=true)' color col_positive.
      endif.

      " barkodluBelge Base64 PDF'i cikart
      data: lv_b64_start type i, lv_b64_end type i, lv_b64 type string,
            lv_search type string, lv_after type string.

      lv_search = '"barkodluBelge":"'.
      find first occurrence of lv_search in lv_json match offset lv_b64_start.
      if sy-subrc <> 0.
        write: / 'barkodluBelge alani bulunamadi!' color col_negative. return.
      endif.
      lv_b64_start = lv_b64_start + strlen( lv_search ).
      lv_after = lv_json+lv_b64_start.
      find first occurrence of '"' in lv_after match offset lv_b64_end.
      if sy-subrc <> 0.
        write: / 'barkodluBelge sonu bulunamadi!' color col_negative. return.
      endif.
      lv_b64 = lv_after(lv_b64_end).
      write: / 'Base64 PDF uzunlugu:', strlen( lv_b64 ).

      " Base64 -> xstring
      call function 'SCMS_BASE64_DECODE_STR'
        exporting input  = lv_b64
        importing output = lv_content
        exceptions failed = 1 others = 2.
      if sy-subrc <> 0.
        write: / 'Base64 decode hata!' color col_negative. return.
      endif.
      lv_filesize = xstrlen( lv_content ).
      write: / 'PDF boyutu:', lv_filesize, 'byte' color col_positive.

    when others.
      write: / 'Gecersiz mod! (1=Dosya, 2=e-Devlet)' color col_negative. return.
  endcase.
  uline.

  " === ORTAK: OCR + Parse ===
  data lo_base type ref to zcl_zrpd_edev_doc_base.
  create object lo_base.
  lv_text = lo_base->pdf_to_text( lv_content ).

  data lv_upper type string.
  lv_upper = to_upper( lv_text ).
  if lv_text is initial or strlen( lv_text ) > 100000
    or ( lv_upper ns 'KIMLIK' and lv_upper ns 'YERLESIM'
     and lv_upper ns 'ADRES' and lv_upper ns 'NUFUS' ).
    write: / 'Native text yetersiz, Python OCR baslatiliyor...' color col_total.
    data lo_ocr type ref to zcl_zrpd_edev_ocr_py.
    create object lo_ocr.
    try.
        lv_text = lo_ocr->extract_text( lv_content ).
        write: / 'OCR tamamlandi.' color col_positive.
      catch zcx_zrpd_edev into data(lx_ocr).
        write: / 'OCR hatasi:', lx_ocr->get_text( ) color col_negative. return.
    endtry.
  else.
    write: / 'Native text kullaniliyor.' color col_positive.
  endif.
  write: / 'Metin uzunlugu:', strlen( lv_text ), 'karakter'.
  uline.

  write: / '=== TCKN ===' color col_heading.
  data lv_tckn type string.
  try.
      lv_tckn = lo_base->extract_tckn( lv_text ).
      write: / 'TCKN:', lv_tckn.
      data lv_valid type abap_bool.
      lv_valid = lo_base->validate_tckn( lv_tckn ).
      if lv_valid = abap_true. write: / 'Checksum: GECERLI' color col_positive.
      else. write: / 'Checksum: HATALI' color col_negative. endif.
    catch zcx_zrpd_edev into data(lx1).
      write: / 'TCKN bulunamadi:', lx1->get_text( ) color col_negative.
  endtry.
  uline.

  write: / '=== BARKOD ===' color col_heading.
  data lv_barcode type string.
  try.
      lv_barcode = lo_base->extract_barcode( lv_text ).
      write: / 'Barkod:', lv_barcode.
    catch zcx_zrpd_edev into data(lx2).
      write: / 'Barkod bulunamadi:', lx2->get_text( ) color col_negative.
  endtry.
  uline.

  write: / '=== FULL PARSE ===' color col_heading.
  data: lo_parser type ref to zcl_zrpd_edev_doc_base,
        lt_vals type zrpd_edev_tt_dcval, ls_val type zrpd_edev_s_dcval.
  if lv_upper cs 'NUFUS VE VATANDASLIK'
    or lv_upper cs 'KIMLIK KARTI BILGILER'
    or lv_upper cs 'NUFUS CUZDANI'.
    write: / 'Parser: KIMLIK' color col_positive.
    create object lo_parser type zcl_zrpd_edev_doc_kim.
  else.
    write: / 'Parser: IKAMETGAH' color col_positive.
    create object lo_parser type zcl_zrpd_edev_doc_ika.
  endif.
  try.
      lt_vals = lo_parser->parse_fields( lv_text ).
      loop at lt_vals into ls_val.
        data lv_out type string.
        lv_out = |{ ls_val-field_name width = 15 align = left }: { ls_val-field_value } (conf={ ls_val-confidence })|.
        write: / lv_out.
      endloop.
    catch zcx_zrpd_edev into data(lx3).
      write: / 'Parse hatasi:', lx3->get_text( ) color col_negative.
  endtry.
