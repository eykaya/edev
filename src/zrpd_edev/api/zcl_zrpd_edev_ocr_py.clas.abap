class zcl_zrpd_edev_ocr_py definition public final create public.

  public section.
    interfaces zif_zrpd_edev_ext_svc.

  private section.
    constants co_script type string value 'F:\usr\sap\edev\ocr_extract.py'.
    constants co_pdf type string value 'F:\usr\sap\edev\tmp_ocr.pdf'.
    constants co_json type string value 'F:\usr\sap\edev\tmp_ocr.json'.

endclass.

class zcl_zrpd_edev_ocr_py implementation.

  method zif_zrpd_edev_ext_svc~extract_text.
    data: lt_log   type table of btcxpm,
          ls_log   type btcxpm,
          lv_param type string,
          lv_found type abap_bool,
          lt_bin   type standard table of x255,
          ls_bin   type x255,
          lv_len   type i.

    " 1. Write PDF to disk via binary table
    call function 'SCMS_XSTRING_TO_BINARY'
      exporting
        buffer        = iv_content
      importing
        output_length = lv_len
      tables
        binary_tab    = lt_bin.

    open dataset co_pdf for output in binary mode.
    if sy-subrc is not initial.
      raise exception type zcx_zrpd_edev_api
        exporting mv_msgv1 = 'Cannot write temp PDF'.
    endif.
    loop at lt_bin into ls_bin.
      transfer ls_bin to co_pdf.
    endloop.
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

    " 3. Read JSON result
    open dataset co_json for input in text mode encoding utf-8.
    if sy-subrc is not initial.
      raise exception type zcx_zrpd_edev_api
        exporting mv_msgv1 = 'OCR result not found'.
    endif.
    read dataset co_json into rv_text.
    close dataset co_json.

    " 4. Cleanup
    delete dataset co_pdf.
    delete dataset co_json.
  endmethod.

endclass.
