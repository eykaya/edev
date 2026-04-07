class zcl_zrpd_edev_logger definition public final create public.

  public section.

    interfaces zif_zrpd_edev_logger.

  private section.

    types: ty_masked_bc type c length 50.

    methods mask_tckn
      importing
        iv_tckn          type char11
      returning
        value(rv_masked) type char11.

    methods mask_barcode
      importing
        iv_barcode       type zrpd_edev_de_bcno
      returning
        value(rv_masked) type ty_masked_bc.

endclass.

class zcl_zrpd_edev_logger implementation.

  method zif_zrpd_edev_logger~log_api_call.
    data: lv_guid    type zrpd_edev_de_guid,
          ls_log     type zrpd_edev_t_alog,
          lv_snippet type c length 255.

    try.
        lv_guid = cl_system_uuid=>create_uuid_x16_static( ).
      catch cx_uuid_error.
        return.
    endtry.

    if iv_response is not initial.
      lv_snippet = iv_response(255).
    endif.

    ls_log-log_guid         = lv_guid.
    ls_log-doc_guid         = iv_doc_guid.
    ls_log-log_date         = sy-datum.
    ls_log-log_time         = sy-uzeit.
    ls_log-log_user         = sy-uname.
    ls_log-api_dest         = iv_api_dest.
    ls_log-http_code        = iv_http_code.
    ls_log-duration_ms      = iv_duration_ms.
    ls_log-response_snippet = lv_snippet.
    ls_log-success          = iv_success.

    if iv_tckn is not initial.
      ls_log-tckn_masked = mask_tckn( iv_tckn ).
    endif.

    if iv_barcode is not initial.
      ls_log-barcode_masked = mask_barcode( iv_barcode ).
    endif.

    insert zrpd_edev_t_alog from ls_log.
  endmethod.

  method zif_zrpd_edev_logger~log_step.
    data: lv_guid type zrpd_edev_de_guid,
          ls_log  type zrpd_edev_t_plog,
          lv_msg  type c length 255.

    try.
        lv_guid = cl_system_uuid=>create_uuid_x16_static( ).
      catch cx_uuid_error.
        return.
    endtry.

    if iv_message is not initial.
      lv_msg = iv_message(255).
    endif.

    ls_log-log_guid    = lv_guid.
    ls_log-doc_guid    = iv_doc_guid.
    ls_log-log_date    = sy-datum.
    ls_log-log_time    = sy-uzeit.
    ls_log-log_user    = sy-uname.
    ls_log-step        = iv_step.
    ls_log-status      = iv_status.
    ls_log-method_used = iv_method.
    ls_log-message     = lv_msg.

    insert zrpd_edev_t_plog from ls_log.
  endmethod.

  method mask_tckn.
    data: lv_len type i.

    lv_len = strlen( iv_tckn ).
    if 4 <= lv_len.
      rv_masked = iv_tckn(2) && '*******' && iv_tckn+9(2).
    else.
      rv_masked = iv_tckn.
    endif.
  endmethod.

  method mask_barcode.
    data: lv_len         type i,
          lv_tail_offset type i.

    lv_len = strlen( iv_barcode ).
    if 8 <= lv_len.
      lv_tail_offset = lv_len - 4.
      rv_masked = iv_barcode(4) && '****' && iv_barcode+lv_tail_offset(4).
    else.
      rv_masked = iv_barcode.
    endif.
  endmethod.

endclass.
