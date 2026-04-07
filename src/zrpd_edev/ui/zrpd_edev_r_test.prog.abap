report zrpd_edev_r_test.

parameters: p_file type string lower case.

*----------------------------------------------------------------------*
* LCL_TEST - Parser test is mantigi
*----------------------------------------------------------------------*
class lcl_test definition final.

  public section.
    class-methods f4_file
      changing cv_path type string.

    class-methods run.

endclass.


class lcl_test implementation.

  method f4_file.
    data: lt_files  type filetable,
          lv_rc     type i,
          lv_action type i,
          ls_file   type file_table.

    cl_gui_frontend_services=>file_open_dialog(
      exporting
        window_title            = 'PDF Dosya Sec'
        default_extension       = 'pdf'
        file_filter             = 'PDF Files (*.pdf)|*.pdf'
        multiselection          = abap_false
      changing
        file_table              = lt_files
        rc                      = lv_rc
        user_action             = lv_action
      exceptions
        file_open_dialog_failed = 1
        cntl_error              = 2
        error_no_gui            = 3
        not_supported_by_gui    = 4
        others                  = 5 ).

    if sy-subrc = 0 and lv_action = cl_gui_frontend_services=>action_ok.
      read table lt_files into ls_file index 1.
      if sy-subrc = 0.
        cv_path = ls_file-filename.
      endif.
    endif.
  endmethod.


  method run.
    data: lt_data    type solix_tab,
          lv_content type xstring,
          lv_filesize type i,
          lo_parser   type ref to zcl_zrpd_edev_doc_ika,
          lv_text     type string,
          lv_valid    type abap_bool,
          lt_vals     type zrpd_edev_tt_dcval,
          ls_val      type zrpd_edev_s_dcval,
          lv_tckn     type string,
          lv_tckn_ok  type abap_bool,
          lo_xerr     type ref to zcx_zrpd_edev_extract.

    if p_file is initial.
      write: / 'Hata: Lutfen bir dosya secin.'.
      return.
    endif.

    " --- Dosya oku ---
    cl_gui_frontend_services=>gui_upload(
      exporting
        filename                = p_file
        filetype                = 'BIN'
      importing
        filelength              = lv_filesize
      changing
        data_tab                = lt_data
      exceptions
        file_open_error         = 1
        file_read_error         = 2
        no_batch                = 3
        gui_refuse_filetransfer = 4
        invalid_type            = 5
        no_authority            = 6
        unknown_error           = 7
        bad_data_format         = 8
        header_not_allowed      = 9
        separator_not_allowed   = 10
        header_too_long         = 11
        unknown_dp_error        = 12
        access_denied           = 13
        dp_out_of_memory        = 14
        disk_full               = 15
        dp_timeout              = 16
        not_supported_by_gui    = 17
        error_no_gui            = 18
        others                  = 19 ).

    if sy-subrc is not initial.
      write: / 'Hata: Dosya okunamadi. Dosya yolunu kontrol edin.'.
      return.
    endif.

    lv_content = cl_bcs_convert=>solix_to_xstring( it_solix = lt_data ).

    " --- Parser olustur ---
    create object lo_parser.

    " --- 1. PDF'ten metin cikar ---
    write: / '=== PDF TEXT ==='.
    lv_text = lo_parser->pdf_to_text( lv_content ).

    if lv_text is initial.
      write: / 'PDF metin cikarma basarisiz (bos metin). OCR/LLM gerekli.'.
      return.
    endif.

    write: / lv_text.

    " --- 2. Belge tipi dogrula ---
    write: / ' '.
    write: / '=== VALIDATE CONTENT ==='.
    lv_valid = lo_parser->validate_content( lv_text ).

    if lv_valid = abap_true.
      write: / 'Belge tipi: IKAMETGAH (gecerli)'.
    else.
      write: / 'UYARI: Belge ikametgah belgesi olarak taninamadi'.
    endif.

    " --- 3. Alanlari ayristir ---
    write: / ' '.
    write: / '=== PARSE FIELDS ==='.

    try.
        lt_vals = lo_parser->parse_fields( lv_text ).
        loop at lt_vals into ls_val.
          write: / ls_val-field_name, ':', ls_val-field_value, '(conf=', ls_val-confidence, ')'.
        endloop.
      catch zcx_zrpd_edev_extract into lo_xerr.
        write: / 'Parse hatasi:', lo_xerr->mv_msgv1.
    endtry.

    " --- 4. TCKN dogrula ---
    write: / ' '.
    write: / '=== TCKN DOGRULAMA ==='.

    try.
        lv_tckn = lo_parser->extract_tckn( lv_text ).
        lv_tckn_ok = lo_parser->validate_tckn( lv_tckn ).
        if lv_tckn_ok = abap_true.
          write: / 'TCKN gecerli:', lv_tckn.
        else.
          write: / 'TCKN checksum HATALI:', lv_tckn.
        endif.
      catch zcx_zrpd_edev_extract into lo_xerr.
        write: / 'TCKN bulunamadi:', lo_xerr->mv_msgv1.
    endtry.
  endmethod.

endclass.

*----------------------------------------------------------------------*
* Olay bloklari
*----------------------------------------------------------------------*
at selection-screen on value-request for p_file.
  lcl_test=>f4_file( changing cv_path = p_file ).

start-of-selection.
  lcl_test=>run( ).
