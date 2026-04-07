interface zif_zrpd_edev_logger public.

  methods log_api_call
    importing
      iv_doc_guid    type zrpd_edev_de_guid
      iv_api_dest    type char32
      iv_tckn        type char11 optional
      iv_barcode     type zrpd_edev_de_bcno optional
      iv_http_code   type numc3
      iv_duration_ms type i
      iv_response    type string optional
      iv_success     type abap_bool.

  methods log_step
    importing
      iv_doc_guid type zrpd_edev_de_guid
      iv_step     type char30
      iv_status   type char2
      iv_method   type zrpd_edev_de_exmth optional
      iv_message  type string optional.

endinterface.
