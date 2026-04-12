class zcl_zrpd_edev_edevlet definition public final create public.

  public section.
    interfaces zif_zrpd_edev_edevlet.

    methods constructor
      importing
        io_cust_repo type ref to zif_zrpd_edev_cust_repo optional.

    methods fetch_pdf
      importing
        iv_barcode     type zrpd_edev_de_bcno
        iv_tckn        type char11
      returning
        value(rv_pdf)  type xstring
      raising
        zcx_zrpd_edev_api.

  private section.
    data mo_cust_repo type ref to zif_zrpd_edev_cust_repo.
    data mv_last_body type string.

    constants co_path type string value '/api.php'.
    constants co_param_p type string value 'belge-dogrulama'.

    methods build_query_string
      importing
        iv_barcode      type zrpd_edev_de_bcno
        iv_tckn         type char11
      returning
        value(rv_query) type string.

    methods call_api
      importing
        iv_query   type string
      exporting
        ev_status  type i
        ev_body    type string
      raising
        zcx_zrpd_edev_api.

    methods get_timeout
      returning
        value(rv_timeout) type i.

    methods get_retry_count
      returning
        value(rv_count) type i.

    methods get_retry_base_wait
      returning
        value(rv_seconds) type i.

    methods extract_b64_field
      importing
        iv_body        type string
        iv_field       type string
      returning
        value(rv_b64)  type string.

endclass.


class zcl_zrpd_edev_edevlet implementation.

  method constructor.
    mo_cust_repo = io_cust_repo.
  endmethod.

  method zif_zrpd_edev_edevlet~verify.
    data lv_query   type string.
    data lv_status  type i.
    data lv_body    type string.
    data lv_retry   type i.
    data lv_max     type i.
    data lv_wait    type i.
    data lv_base    type i.
    data lv_lower   type string.
    data lv_success type abap_bool.
    data lv_exp     type i.
    data lx_err     type ref to zcx_zrpd_edev_api.

    rv_verified = abap_false.
    clear mv_last_body.

    lv_query = build_query_string(
      iv_barcode = iv_barcode
      iv_tckn    = iv_tckn ).

    lv_max  = get_retry_count( ).
    lv_base = get_retry_base_wait( ).
    lv_retry = 0.
    lv_success = abap_false.

    while lv_retry <= lv_max.
      try.
          call_api(
            exporting iv_query  = lv_query
            importing ev_status = lv_status
                      ev_body   = lv_body ).

          if lv_status >= 200 and lv_status < 300.
            lv_success = abap_true.
            exit.
          endif.

          if lv_status >= 400 and lv_status < 500.
            raise exception type zcx_zrpd_edev_api
              exporting mv_msgv1 = 'e-Devlet client error'
                        mv_msgv2 = conv symsgv( lv_status ).
          endif.

        catch zcx_zrpd_edev_api into lx_err.
          if lv_retry >= lv_max.
            raise exception lx_err.
          endif.
      endtry.

      lv_wait = lv_base.
      lv_exp = lv_retry.
      while lv_exp > 0.
        lv_wait = lv_wait * 2.
        lv_exp = lv_exp - 1.
      endwhile.

      wait up to lv_wait seconds.
      lv_retry = lv_retry + 1.
    endwhile.

    if lv_success = abap_false.
      raise exception type zcx_zrpd_edev_api
        exporting mv_msgv1 = 'e-Devlet max retries exceeded'.
    endif.

    mv_last_body = lv_body.

    lv_lower = lv_body.
    translate lv_lower to lower case.

    " e-Devlet API JSON: {"return": true/false, ...}
    if lv_lower cs '"return":false' or lv_lower cs '"return": false'.
      rv_verified = abap_false.
      return.
    endif.

    if lv_lower cs '"return":true' or lv_lower cs '"return": true'.
      rv_verified = abap_true.
    endif.
  endmethod.

  method fetch_pdf.
    data lv_query  type string.
    data lv_status type i.
    data lv_body   type string.
    data lv_b64    type string.

    clear rv_pdf.

    if mv_last_body is not initial.
      lv_body = mv_last_body.
    else.
      lv_query = build_query_string(
        iv_barcode = iv_barcode
        iv_tckn    = iv_tckn ).
      call_api(
        exporting iv_query  = lv_query
        importing ev_status = lv_status
                  ev_body   = lv_body ).
      if lv_status < 200 or lv_status >= 300.
        raise exception type zcx_zrpd_edev_api
          exporting mv_msgv1 = 'fetch_pdf HTTP error'
                    mv_msgv2 = conv symsgv( lv_status ).
      endif.
    endif.

    lv_b64 = extract_b64_field(
      iv_body  = lv_body
      iv_field = 'barkodlubelge' ).

    if lv_b64 is initial.
      raise exception type zcx_zrpd_edev_api
        exporting mv_msgv1 = 'barkodlubelge alani bos'.
    endif.

    call function 'SSFC_BASE64_DECODE'
      exporting
        b64data = lv_b64
      importing
        bindata = rv_pdf
      exceptions
        ssf_krn_error  = 1
        ssf_krn_noop   = 2
        ssf_krn_nomem  = 3
        ssf_krn_opinv  = 4
        ssf_krn_input_data_error = 5
        ssf_krn_invalid_par      = 6
        ssf_krn_invalid_parlen   = 7
        others = 8.
    if sy-subrc <> 0.
      raise exception type zcx_zrpd_edev_api
        exporting mv_msgv1 = 'Base64 decode basarisiz'.
    endif.
  endmethod.

  method extract_b64_field.
    data lv_pos    type i.
    data lv_start  type i.
    data lv_end    type i.
    data lv_search type string.
    data lv_rest   type string.

    clear rv_b64.
    lv_search = |"{ iv_field }"|.
    find first occurrence of lv_search in iv_body match offset lv_pos ignoring case.
    if sy-subrc <> 0. return. endif.

    lv_pos = lv_pos + strlen( lv_search ).
    lv_rest = iv_body+lv_pos.

    find first occurrence of '"' in lv_rest match offset lv_start.
    if sy-subrc <> 0. return. endif.
    lv_start = lv_start + 1.
    lv_rest = lv_rest+lv_start.

    find first occurrence of '"' in lv_rest match offset lv_end.
    if sy-subrc <> 0. return. endif.

    rv_b64 = lv_rest(lv_end).
  endmethod.

  method build_query_string.
    data lv_barcode type string.
    data lv_tckn    type string.
    lv_barcode = iv_barcode.
    lv_tckn    = iv_tckn.
    condense lv_barcode no-gaps.
    condense lv_tckn no-gaps.
    concatenate 'p=' co_param_p
                '&qr=barkod:' lv_barcode
                ';tckn:' lv_tckn ';'
      into rv_query.
  endmethod.

  method call_api.
    data lo_client type ref to if_http_client.
    data lv_uri    type string.
    data lv_errmsg type string.
    data lv_rcverr type string.
    clear: ev_status, ev_body.
    cl_http_client=>create_by_destination(
      exporting destination = zcl_zrpd_edev_const=>co_dest_edevlet
      importing client      = lo_client
      exceptions
        argument_not_found    = 1
        destination_not_found = 2
        internal_error        = 3
        others                = 4 ).
    if sy-subrc <> 0.
      raise exception type zcx_zrpd_edev_api
        exporting mv_msgv1 = 'SM59 destination error'
                  mv_msgv2 = conv symsgv( zcl_zrpd_edev_const=>co_dest_edevlet ).
    endif.
    concatenate co_path '?' iv_query into lv_uri.
    cl_http_utility=>set_request_uri(
      exporting request = lo_client->request
                uri     = lv_uri ).
    lo_client->request->set_method( if_http_request=>co_request_method_get ).
    lo_client->send(
      exporting timeout = get_timeout( )
      exceptions http_communication_failure = 1
                 http_invalid_state         = 2
                 http_processing_failed     = 3
                 others                     = 4 ).
    if sy-subrc <> 0.
      lo_client->get_last_error( importing message = lv_errmsg ).
      lo_client->close( ).
      raise exception type zcx_zrpd_edev_api
        exporting mv_msgv1 = 'HTTP send failed'
                  mv_msgv2 = conv symsgv( lv_errmsg ).
    endif.
    lo_client->receive(
      exceptions http_communication_failure = 1
                 http_invalid_state         = 2
                 http_processing_failed     = 3
                 others                     = 4 ).
    if sy-subrc <> 0.
      lo_client->get_last_error( importing message = lv_rcverr ).
      lo_client->close( ).
      raise exception type zcx_zrpd_edev_api
        exporting mv_msgv1 = 'HTTP receive failed'
                  mv_msgv2 = conv symsgv( lv_rcverr ).
    endif.
    lo_client->response->get_status( importing code = ev_status ).
    ev_body = lo_client->response->get_cdata( ).
    lo_client->close( ).
  endmethod.

  method get_timeout.
    if mo_cust_repo is bound.
      data(lv_val) = mo_cust_repo->get_param( 'API_TIMEOUT' ).
      if lv_val is not initial.
        rv_timeout = lv_val.
        return.
      endif.
    endif.
    rv_timeout = 30.
  endmethod.

  method get_retry_count.
    if mo_cust_repo is bound.
      data(lv_val) = mo_cust_repo->get_param( 'API_RETRY_COUNT' ).
      if lv_val is not initial.
        rv_count = lv_val.
        return.
      endif.
    endif.
    rv_count = 3.
  endmethod.

  method get_retry_base_wait.
    if mo_cust_repo is bound.
      data(lv_val) = mo_cust_repo->get_param( 'API_RETRY_BASE_WAIT' ).
      if lv_val is not initial.
        rv_seconds = lv_val.
        return.
      endif.
    endif.
    rv_seconds = 2.
  endmethod.

endclass.
