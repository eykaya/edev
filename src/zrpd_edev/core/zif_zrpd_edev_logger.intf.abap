interface zif_zrpd_edev_logger public.

  methods log_api_call
    importing
      iv_doc_guid    type zrpd_edev_de_guid
      iv_api_dest    type c length 32
      iv_tckn        type c length 11 optional
      iv_barcode     type zrpd_edev_de_bcno optional
      iv_http_code   type n length 3
      iv_duration_ms type i
      iv_response    type string optional
      iv_success     type abap_bool.

  methods log_step
    importing
      iv_doc_guid type zrpd_edev_de_guid
      iv_step     type c length 30
      iv_status   type c length 2
      iv_method   type zrpd_edev_de_exmth optional
      iv_message  type string optional.

endinterface.
