class zcl_zrpd_edev_ocr_py definition public final create public.

  public section.
    interfaces zif_zrpd_edev_ext_svc.

  private section.
    types: begin of ty_ocr_result,
             ocr_text        type string,
             barcode         type string,
             ocr_text_length type i,
           end of ty_ocr_result.

    constants co_script type string value 'F:\usr\sap\edev\ocr_extract.py'.
    constants co_pdf    type string value 'F:\usr\sap\edev\tmp_ocr.pdf'.
    constants co_json   type string value 'F:\usr\sap\edev\tmp_ocr.json'.

endclass.

class zcl_zrpd_edev_ocr_py implementation.

  method zif_zrpd_edev_ext_svc~extract_text.
    data: lt_log    type standard table of btcxpm with empty key,
          ls_log    type btcxpm,
          lv_param  type sxpgcostab-parameters,
          lv_json   type string,
          lv_line   type string,
          ls_result type ty_ocr_result.

    data(lv_found) = abap_false.

    " 1. Write PDF xstring directly to disk
    open dataset co_pdf for output in binary mode.
    if sy-subrc is not initial.
      raise exception type zcx_zrpd_edev_api
        exporting mv_msgv1 = 'Cannot write temp PDF'.
    endif.
    transfer iv_content to co_pdf.
    close dataset co_pdf.

    " 2. Run Python OCR script
    concatenate co_script co_pdf co_json
      into lv_param separated by space.

    call function 'SXPG_COMMAND_EXECUTE'
      exporting
        commandname           = 'Z_EDEV_PY'
        additional_parameters = lv_param
        operatingsystem       = 'Windows NT'
      tables
        exec_protocol         = lt_log
      exceptions
        others                = 14.

    if sy-subrc is not initial.
      raise exception type zcx_zrpd_edev_api
        exporting mv_msgv1 = 'OCR script failed'.
    endif.

    lv_found = abap_false.
    loop at lt_log into ls_log.
      if ls_log-message cs 'OCR_DONE'.
        lv_found = abap_true.
      endif.
    endloop.

    if lv_found = abap_false.
      raise exception type zcx_zrpd_edev_api
        exporting mv_msgv1 = 'OCR not completed'.
    endif.

    " 3. Read JSON result (multi-line)
    open dataset co_json for input in text mode encoding utf-8.
    if sy-subrc is not initial.
      raise exception type zcx_zrpd_edev_api
        exporting mv_msgv1 = 'OCR result not found'.
    endif.
    do.
      read dataset co_json into lv_line.
      if sy-subrc is not initial.
        exit.
      endif.
      if lv_json is initial.
        lv_json = lv_line.
      else.
        lv_json = lv_json && cl_abap_char_utilities=>newline && lv_line.
      endif.
    enddo.
    close dataset co_json.

    " 4. Parse JSON -> ocr_text + barcode
    /ui2/cl_json=>deserialize(
      exporting json = lv_json
      changing  data = ls_result ).

    rv_text = ls_result-ocr_text.

    " Barcode varsa text sonuna marker ekle (extract_barcode regex ile yakalar)
    if ls_result-barcode is not initial.
      rv_text = rv_text
        && cl_abap_char_utilities=>newline
        && '||BARCODE:' && ls_result-barcode && '||'.
    endif.

    " 5. Cleanup
    delete dataset co_pdf.
    delete dataset co_json.
  endmethod.

endclass.
