class zcl_zrpd_edev_const definition public abstract final create private.

  public section.

    " Document statuses
    constants co_stat_draft      type zrpd_edev_de_dstat value 'DRAFT'.
    constants co_stat_uploaded   type zrpd_edev_de_dstat value 'UPLOADED'.
    constants co_stat_processing type zrpd_edev_de_dstat value 'PROCESSING'.
    constants co_stat_verified   type zrpd_edev_de_dstat value 'VERIFIED'.
    constants co_stat_rejected   type zrpd_edev_de_dstat value 'REJECTED'.
    constants co_stat_mapped     type zrpd_edev_de_dstat value 'MAPPED'.
    constants co_stat_committed  type zrpd_edev_de_dstat value 'COMMITTED'.
    constants co_stat_error      type zrpd_edev_de_dstat value 'ERROR'.

    " Extraction methods
    constants co_exm_form     type zrpd_edev_de_exmth value 'FORM'.
    constants co_exm_ocr_easy type zrpd_edev_de_exmth value 'OCR_EASY'.
    constants co_exm_ocr_gcv  type zrpd_edev_de_exmth value 'OCR_GCV'.
    constants co_exm_llm      type zrpd_edev_de_exmth value 'LLM'.
    constants co_exm_none     type zrpd_edev_de_exmth value 'NONE'.

    " Document types
    constants co_dtyp_ikametgah type zrpd_edev_de_dctyp value 'IKAMETGAH'.

    " SM59 destinations
    constants co_dest_edevlet type c length 32 value 'ZRPD_EDEV_EDEVLET'.
    constants co_dest_ocr     type c length 32 value 'ZRPD_EDEV_OCR'.
    constants co_dest_llm     type c length 32 value 'ZRPD_EDEV_LLM'.

    " Message class
    constants co_msgclass type symsgid value 'ZRPD_EDEV_M'.

    " Process log steps
    constants co_step_upload  type c length 30 value 'UPLOAD'.
    constants co_step_extract type c length 30 value 'EXTRACT'.
    constants co_step_verify  type c length 30 value 'VERIFY'.
    constants co_step_parse   type c length 30 value 'PARSE'.
    constants co_step_map     type c length 30 value 'MAP'.
    constants co_step_commit  type c length 30 value 'COMMIT'.

    " Log status
    constants co_log_ok    type c length 2 value 'OK'.
    constants co_log_error type c length 2 value 'ER'.
    constants co_log_warn  type c length 2 value 'WA'.

endclass.

class zcl_zrpd_edev_const implementation.
endclass.
