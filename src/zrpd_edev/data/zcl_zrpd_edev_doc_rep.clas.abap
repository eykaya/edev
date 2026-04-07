class zcl_zrpd_edev_doc_rep definition public final create public.

  public section.

    interfaces zif_zrpd_edev_doc_repo.

endclass.

class zcl_zrpd_edev_doc_rep implementation.

  method zif_zrpd_edev_doc_repo~save.
    data: lv_guid  type zrpd_edev_de_guid,
          ls_doc   type zrpd_edev_t_doc.

    try.
        lv_guid = cl_system_uuid=>create_uuid_x16_static( ).
      catch cx_uuid_error.
        raise exception type zcx_zrpd_edev_upload
          exporting
            mv_msgv1 = 'GUID generation failed'.
    endtry.

    ls_doc-doc_guid    = lv_guid.
    ls_doc-pernr       = is_doc-pernr.
    ls_doc-doc_type    = is_doc-doc_type.
    ls_doc-file_name   = is_doc-file_name.
    ls_doc-mime_type   = is_doc-mime_type.
    ls_doc-file_size   = is_doc-file_size.
    ls_doc-doc_status  = is_doc-doc_status.
    ls_doc-barcode     = is_doc-barcode.
    ls_doc-tckn        = is_doc-tckn.
    ls_doc-upload_date = sy-datum.
    ls_doc-upload_time = sy-uzeit.
    ls_doc-upload_user = sy-uname.
    ls_doc-content     = iv_content.

    insert zrpd_edev_t_doc from ls_doc.
    if sy-subrc = 0.
      rv_guid = lv_guid.
    else.
      raise exception type zcx_zrpd_edev_upload
        exporting
          mv_msgv1 = 'INSERT T_DOC failed'.
    endif.
  endmethod.

  method zif_zrpd_edev_doc_repo~find_by_guid.
    data: ls_doc type zrpd_edev_s_dochd.

    select single
        doc_guid pernr doc_type file_name mime_type file_size
        doc_status barcode tckn
        upload_date upload_time upload_user
        changed_date changed_time changed_user
      from zrpd_edev_t_doc
      into ls_doc
      where doc_guid = iv_guid.

    if sy-subrc = 0.
      rs_doc = ls_doc.
    else.
      raise exception type zcx_zrpd_edev_notfnd
        exporting
          mv_msgv1 = 'Document not found'.
    endif.
  endmethod.

  method zif_zrpd_edev_doc_repo~find_by_pernr.
    data: lt_docs type zrpd_edev_tt_dochd.

    select
        doc_guid pernr doc_type file_name mime_type file_size
        doc_status barcode tckn
        upload_date upload_time upload_user
        changed_date changed_time changed_user
      from zrpd_edev_t_doc
      into table lt_docs
      where pernr = iv_pernr
      order by upload_date descending upload_time descending.

    rt_docs = lt_docs.
  endmethod.

  method zif_zrpd_edev_doc_repo~update_status.
    update zrpd_edev_t_doc
      set doc_status   = iv_status
          changed_date = sy-datum
          changed_time = sy-uzeit
          changed_user = sy-uname
      where doc_guid = iv_guid.
  endmethod.

  method zif_zrpd_edev_doc_repo~save_values.
    delete from zrpd_edev_t_dval where doc_guid = iv_guid.
    insert zrpd_edev_t_dval from table it_values.
  endmethod.

  method zif_zrpd_edev_doc_repo~get_values.
    data: lt_values type zrpd_edev_tt_dcval.

    select * from zrpd_edev_t_dval
      into table lt_values
      where doc_guid = iv_guid
      order by field_name ascending.

    rt_values = lt_values.
  endmethod.

  method zif_zrpd_edev_doc_repo~delete.
    delete from zrpd_edev_t_dval where doc_guid = iv_guid.
    delete from zrpd_edev_t_doc where doc_guid = iv_guid.

    if sy-subrc = 0.
      return.
    else.
      raise exception type zcx_zrpd_edev_notfnd
        exporting
          mv_msgv1 = 'Document not found for delete'.
    endif.
  endmethod.

endclass.
