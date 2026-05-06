class zcl_im_rpd_edev definition
  public
  final
  create public.

  public section.
    interfaces if_ex_hrpad00infty.
    class-methods process_edev.
    "! Dokuman sil butonundan tetiklenir
    class-methods process_edev_delete.
    class-methods process_command
      importing
        iv_action type string.

  private section.
    constants co_sgui_prog  type progname value 'ZRPD_EDEV_R_SGUI'.
    constants co_mp_p0006   type string   value '(MP000600)P0006'.
    constants co_infty_0006 type infty    value '0006'.
    constants co_mp_p0770   type string   value '(MP077000)P0770'.
    constants co_infty_0770 type infty    value '0770'.
    constants co_mp_p0022   type string   value '(MP002200)P0022'.
    constants co_infty_0022 type infty    value '0022'.
    constants co_mp_p0021   type string   value '(MP002100)P0021'.
    constants co_infty_0021 type infty    value '0021'.
    constants co_cmd_upload type string   value 'UPLOAD'.
    constants co_cmd_view   type string   value 'VIEW'.
    constants co_cmd_delete type string   value 'DELETE'.
    class-data gs_pending      type p0006.
    class-data gs_pending_0022 type p0022.
    class-data gs_pending_0770 type p0770.
    class-data gs_pending_0021        type p0021.
    class-data gv_pending_extra_count  type i.
    class-data gv_has_pending     type abap_bool.
    class-data gv_pending_file    type xstring.
    class-data gv_pending_atip    type n length 2.
    class-data gv_pending_pernr   type persno.
    class-data gv_pending_config  type zrpd_djtl_de_confg.
    class-data gv_pending_source  type zrpd_djtl_de_source.
    class-data gv_pending_subty   type subty.
    class-data gv_pending_objps   type pspar-objps.
    class-data gv_pending_sprps   type pspar-sprps.
    class-data gv_pending_endda   type endda.
    class-data gv_pending_begda   type begda.
    class-data gv_pending_seqnr   type pspar-seqnr.
    class-data gv_f9_written      type abap_bool.
    class-data gv_tc_checked      type abap_bool.
    class-data gv_current_infty   type infty.
    class-data gv_curr_pernr   type persno.
    class-data gv_curr_subty   type subty_591a.
    class-data gv_curr_objps   type pspar-objps.
    class-data gv_curr_sprps   type pspar-sprps.
    class-data gv_curr_begda   type begda.
    class-data gv_curr_endda   type endda.
    class-data gv_curr_seqnr   type pspar-seqnr.
    class-methods resolve_mapping
      importing
        iv_infty        type infty
      exporting
        ev_atip         type n
        ev_doc_type     type zrpd_edev_de_dctyp
        ev_parser_class type seoclsname
        ev_found        type abap_bool.
    class-methods get_pernr
      returning
        value(rv_pernr) type persno.
    class-methods process_upload
      importing
        iv_atip     type n
        iv_doc_type type zrpd_edev_de_dctyp
        iv_parser   type seoclsname.
    class-methods process_view.
    class-methods process_delete.
    class-methods get_current_record
      exporting
        ev_pernr type persno
        ev_subty type subty_591a
        ev_confg type zrpd_djtl_de_confg
        ev_filep type zrpd_djtl_de_filep
        ev_found type abap_bool.
    constants co_djtl_class  type seoclsname    value 'ZCL_ZRPD_DJTL_FILE'.
    class-data gv_djtl_checked type abap_bool.
    class-data gv_djtl_avail   type abap_bool.
    class-methods is_djtl_available
      returning
        value(rv_avail) type abap_bool.
    class-methods has_djtl_method
      importing
        iv_method        type seocpdname
      returning
        value(rv_exists) type abap_bool.
    class-methods upload_from_edevlet
      importing
        iv_pernr    type persno
        iv_atip     type n
        iv_doc_type type zrpd_edev_de_dctyp.
    class-methods upload_from_edevlet_0770
      importing
        iv_pernr    type persno
        iv_atip     type n
        iv_doc_type type zrpd_edev_de_dctyp.
    class-methods upload_from_file
      importing
        iv_pernr    type persno
        iv_atip     type n
        iv_doc_type type zrpd_edev_de_dctyp optional
        iv_parser   type seoclsname optional
        iv_infty    type infty optional.
    class-methods apply_vals_to_p0006
      importing
        it_vals type zrpd_edev_tt_dcval.
    class-methods apply_vals_to_p0770
      importing
        it_vals type zrpd_edev_tt_dcval.
    class-methods transform_ika_vals
      changing
        ct_vals type zrpd_edev_tt_dcval.
    class-methods upload_from_file_0770
      importing
        iv_pernr    type persno
        iv_atip     type n
        iv_doc_type type zrpd_edev_de_dctyp.
    class-methods process_p0006
      changing
        cs_0006 type p0006.
    class-methods process_p0022
      changing
        cs_0022 type p0022.
    class-methods process_p0770
      changing
        cs_0770 type p0770.
    class-methods apply_pending_0022.
    class-methods set_itxex_0022.
    class-methods lookup_ausbi
      importing
        iv_uni_metni    type string
      returning
        value(rv_ausbi) type ausbi.
    class-methods lookup_sltp1
      importing
        iv_bolum_metni  type string
      returning
        value(rv_sltp1) type fach1.
    class-methods lookup_slabs
      importing
        iv_program_text type string
        iv_durum_text   type string
      returning
        value(rv_slabs) type p0022-slabs.
    class-methods transform_mez_vals
      changing
        ct_vals type zrpd_edev_tt_dcval.
    class-methods apply_vals_to_0022
      importing
        it_vals type zrpd_edev_tt_dcval.
    class-methods get_plate_code
      importing
        iv_il           type any
      returning
        value(rv_plate) type string.
    class-methods normalize_turkish
      changing
        cv_text type string.
    class-methods generate_confg_id
      returning
        value(rv_confg) type zrpd_djtl_de_confg.
    class-methods fill_pending_key.
    class-methods tc_online_check
      importing
        iv_merni           type ptr_merni
        iv_vorna           type vorna
        iv_nachn           type nachn
        iv_dogum_str       type string
      returning
        value(rt_messages) type bapiret2_t.
    class-methods validate_tc_against_master
      importing
        iv_pernr           type pernr_d
        iv_merni           type ptr_merni
      returning
        value(rt_messages) type bapiret2_t.
    class-methods process_p0021
      changing
        cs_0021 type p0021.
    class-methods apply_vals_to_p0021
      importing
        it_vals type zrpd_edev_tt_dcval.
    class-methods transform_aile_vals
      changing
        ct_vals type zrpd_edev_tt_dcval.
    class-methods apply_pending_0021.
    class-methods set_itxex_0021.

ENDCLASS.



CLASS ZCL_IM_RPD_EDEV IMPLEMENTATION.


  method apply_pending_0021.
    data lv_doc_type type zrpd_edev_de_dctyp.
    data lt_targets  type standard table of zrpd_edev_de_iflnm with empty key.
    data lv_target   type zrpd_edev_de_iflnm.
    field-symbols <ls_0021> type p0021.
    field-symbols <fs_src>  type any.
    field-symbols <fs_dst>  type any.
    select single doc_type from zrpd_edev_t_dtyp
      into @lv_doc_type
      where infotype = '0021' and active = 'X'.
    if sy-subrc <> 0. lv_doc_type = 'AILE'. endif.
    assign (co_mp_p0021) to <ls_0021>.
    if sy-subrc <> 0.
      clear gs_pending_0021.
      clear gv_has_pending.
      clear gv_pending_extra_count.
      return.
    endif.
    select distinct infotype_field
      from zrpd_edev_t_dmap
      into table @lt_targets
      where doc_type       = @lv_doc_type
        and infotype       = '0021'
        and infotype_field <> @space.
    loop at lt_targets into lv_target.
      assign component lv_target of structure gs_pending_0021 to <fs_src>.
      if sy-subrc <> 0. continue. endif.
      if <fs_src> is initial. continue. endif.
      assign component lv_target of structure <ls_0021> to <fs_dst>.
      if sy-subrc <> 0. continue. endif.
      <fs_dst> = <fs_src>.
    endloop.
    clear gs_pending_0021.
    clear gv_has_pending.
    clear gv_pending_extra_count.
  endmethod.


  method apply_pending_0022.
    data lv_doc_type type zrpd_edev_de_dctyp.
    data lt_targets  type standard table of zrpd_edev_de_iflnm with empty key.
    data lv_target   type zrpd_edev_de_iflnm.
    field-symbols <ls_0022> type p0022.
    field-symbols <fs_src>  type any.
    field-symbols <fs_dst>  type any.
    select single doc_type from zrpd_edev_t_dtyp
      into @lv_doc_type
      where infotype = '0022' and active = 'X'.
    if sy-subrc <> 0. lv_doc_type = 'MEZUNIYET'. endif.
    assign (co_mp_p0022) to <ls_0022>.
    if sy-subrc <> 0.
      clear gs_pending_0022.
      clear gv_has_pending.
      return.
    endif.
    select distinct infotype_field
      from zrpd_edev_t_dmap
      into table @lt_targets
      where doc_type       = @lv_doc_type
        and infotype       = '0022'
        and infotype_field <> @space.
    loop at lt_targets into lv_target.
      assign component lv_target of structure gs_pending_0022 to <fs_src>.
      if sy-subrc <> 0. continue. endif.
      if <fs_src> is initial. continue. endif.
      assign component lv_target of structure <ls_0022> to <fs_dst>.
      if sy-subrc <> 0. continue. endif.
      <fs_dst> = <fs_src>.
    endloop.
    if <ls_0022>-sland is initial.
      <ls_0022>-sland = 'TR'.
    endif.
    clear gs_pending_0022.
    clear gv_has_pending.
  endmethod.


  method apply_vals_to_0022.
    data ls_val type zrpd_edev_s_dcval.
    field-symbols <ls_val>   like ls_val.
    field-symbols <lv_field> type any.
    loop at it_vals assigning <ls_val>.
      assign component <ls_val>-field_name of structure gs_pending_0022 to <lv_field>.
      if sy-subrc = 0.
        <lv_field> = <ls_val>-field_value.
      endif.
    endloop.
    gv_has_pending = abap_true.
  endmethod.


  method apply_vals_to_p0006.
    data lv_doc_type type zrpd_edev_de_dctyp.
    data: begin of ls_map,
            field_name     type zrpd_edev_de_fldnm,
            infotype_field type zrpd_edev_de_iflnm,
          end of ls_map.
    data lt_map like sorted table of ls_map with unique key field_name.
    data ls_val      type zrpd_edev_s_dcval.
    data lv_fn       type zrpd_edev_de_fldnm.
    data lv_it_field type zrpd_edev_de_iflnm.
    data: begin of ls_grp,
            it_field type zrpd_edev_de_iflnm,
            value    type string,
          end of ls_grp.
    data lt_grp like sorted table of ls_grp with unique key it_field.
    field-symbols <ls_grp> like ls_grp.
    field-symbols <ls_map> like ls_map.
    field-symbols <fs_val> type any.
    select single doc_type from zrpd_edev_t_dtyp
      into @lv_doc_type
      where infotype = '0006' and active = 'X'.
    if sy-subrc <> 0. lv_doc_type = 'IKAMETGAH'. endif.
    select field_name, infotype_field
      from zrpd_edev_t_dmap
      where doc_type       = @lv_doc_type
        and infotype       = @co_infty_0006
        and infotype_field <> @space
      into corresponding fields of table @lt_map.
    if sy-subrc <> 0. lt_map = value #( ). endif.
    loop at it_vals into ls_val.
      lv_fn = ls_val-field_name.
      translate lv_fn to lower case.
      if ls_val-field_value is initial. continue. endif.
      clear lv_it_field.
      read table lt_map assigning <ls_map> with table key field_name = lv_fn.
      if sy-subrc <> 0 or <ls_map>-infotype_field is initial. continue. endif.
      lv_it_field = <ls_map>-infotype_field.
      read table lt_grp assigning <ls_grp> with table key it_field = lv_it_field.
      if sy-subrc = 0.
        if <ls_grp>-value is initial.
          <ls_grp>-value = ls_val-field_value.
        else.
          <ls_grp>-value = |{ <ls_grp>-value } { ls_val-field_value }|.
        endif.
      else.
        clear ls_grp.
        ls_grp-it_field = lv_it_field.
        ls_grp-value    = ls_val-field_value.
        insert ls_grp into table lt_grp.
      endif.
    endloop.
    loop at lt_grp into ls_grp.
      assign component ls_grp-it_field of structure gs_pending to <fs_val>.
      if sy-subrc = 0.
        <fs_val> = ls_grp-value.
      endif.
    endloop.
    gv_has_pending = abap_true.
  endmethod.


  method apply_vals_to_p0021.
    data lv_subty         type subty.
    data ls_val           type zrpd_edev_s_dcval.
    data lv_idx_str       type string.
    data lv_field_suffix  type string.
    data lv_idx           type i.
    field-symbols <lv_fasex> type any.
    field-symbols <lv_fanat> type any.
    field-symbols <lv_fgbld> type any.
    data lt_active_erbnrs type standard table of char12 with empty key.
    data lv_erbnr_n       type char12.
    data lv_row_idx       type i.
    data lv_yakinlik      type string.
    data lv_erbnr         type char12.
    data lv_fanam         type string.
    data lv_favor         type string.
    data lv_fgbdt         type dats.
    data lv_fgbot         type string.
    data lv_fasex         type gesch.
    data lt_idx           type standard table of i with empty key.
    data lt_yakinlik      type standard table of string with empty key.
    data lt_erbnr         type standard table of char12 with empty key.
    data lt_fanam         type standard table of string with empty key.
    data lt_favor         type standard table of string with empty key.
    data lt_fgbdt         type standard table of dats with empty key.
    data lt_fgbot         type standard table of string with empty key.
    data lt_fasex         type standard table of gesch with empty key.
    data lv_tabix         type sy-tabix.
    data lv_keep          type abap_bool.
    data lv_first_idx     type i.
    data lv_proc_idx      type i.
    lv_subty = gv_curr_subty.
    if lv_subty <> '1' and lv_subty <> '2'.
      message 'PA0021: Subtype 1 (Es) veya 2 (Cocuk) olmali' type 'S' display like 'W'.
      return.
    endif.
    loop at it_vals into ls_val.
      if ls_val-field_name = 'barkod'. continue. endif.
      if ls_val-field_name(4) <> 'row_'. continue. endif.
      data(lv_rest) = ls_val-field_name+4.
      split lv_rest at '__' into lv_idx_str lv_field_suffix.
      if lv_idx_str is initial or lv_field_suffix is initial. continue. endif.
      lv_idx = lv_idx_str.
      read table lt_idx transporting no fields with key table_line = lv_idx.
      if sy-subrc <> 0.
        append lv_idx to lt_idx.
        append '' to lt_yakinlik.
        lv_erbnr = ''. append lv_erbnr to lt_erbnr.
        append '' to lt_fanam. append '' to lt_favor.
        lv_fgbdt = '00000000'. append lv_fgbdt to lt_fgbdt.
        append '' to lt_fgbot.
        lv_fasex = ''. append lv_fasex to lt_fasex.
      endif.
      read table lt_idx transporting no fields with key table_line = lv_idx.
      lv_tabix = sy-tabix.
      if sy-subrc <> 0. continue. endif.
      case lv_field_suffix.
        when 'yakinlik'.
          read table lt_yakinlik index lv_tabix into lv_yakinlik.
          lv_yakinlik = ls_val-field_value.
          modify lt_yakinlik index lv_tabix from lv_yakinlik.
        when 'erbnr'.
          lv_erbnr = ls_val-field_value.
          modify lt_erbnr index lv_tabix from lv_erbnr.
        when 'fanam'.
          read table lt_fanam index lv_tabix into lv_fanam.
          lv_fanam = ls_val-field_value.
          modify lt_fanam index lv_tabix from lv_fanam.
        when 'favor'.
          read table lt_favor index lv_tabix into lv_favor.
          lv_favor = ls_val-field_value.
          modify lt_favor index lv_tabix from lv_favor.
        when 'fgbdt'.
          lv_fgbdt = ls_val-field_value.
          modify lt_fgbdt index lv_tabix from lv_fgbdt.
        when 'fgbot'.
          read table lt_fgbot index lv_tabix into lv_fgbot.
          lv_fgbot = ls_val-field_value.
          modify lt_fgbot index lv_tabix from lv_fgbot.
        when 'fasex'.
          lv_fasex = ls_val-field_value.
          modify lt_fasex index lv_tabix from lv_fasex.
      endcase.
    endloop.
    select erbnr from pa0021
      where pernr = @gv_pending_pernr
        and subty = @lv_subty
        and begda <= @sy-datum
        and endda >= @sy-datum
        and erbnr <> @space
      into table @lt_active_erbnrs.
    lv_first_idx = 0.
    lv_proc_idx  = 0.
    loop at lt_idx into lv_row_idx.
      lv_tabix = sy-tabix.
      read table lt_yakinlik index lv_tabix into lv_yakinlik.
      read table lt_erbnr    index lv_tabix into lv_erbnr_n.
      read table lt_fanam    index lv_tabix into lv_fanam.
      read table lt_favor    index lv_tabix into lv_favor.
      read table lt_fgbdt    index lv_tabix into lv_fgbdt.
      read table lt_fgbot    index lv_tabix into lv_fgbot.
      read table lt_fasex    index lv_tabix into lv_fasex.
      lv_yakinlik = to_upper( lv_yakinlik ).
      lv_keep = abap_false.
      if lv_subty = '1' and lv_yakinlik = 'ESI'.
        lv_keep = abap_true.
      elseif lv_subty = '2' and ( lv_yakinlik = 'KIZI' or lv_yakinlik = 'OGLU' ).
        lv_keep = abap_true.
      endif.
      if lv_yakinlik = 'KENDISI'. lv_keep = abap_false. endif.
      if lv_keep = abap_false. continue. endif.
      read table lt_active_erbnrs transporting no fields
        with key table_line = lv_erbnr_n.
      if sy-subrc = 0. continue. endif.
      if lv_first_idx = 0.
        lv_first_idx = lv_tabix.
        gs_pending_0021-erbnr = lv_erbnr_n.
        gs_pending_0021-fanam = lv_fanam.
        gs_pending_0021-favor = lv_favor.
        gs_pending_0021-fgbdt = lv_fgbdt.
        gs_pending_0021-fgbot = lv_fgbot.
        if lv_fasex is not initial.
          assign component 'FASEX' of structure gs_pending_0021 to <lv_fasex>.
          if sy-subrc = 0. <lv_fasex> = lv_fasex. endif.
        endif.
        if lv_erbnr_n is not initial.
          assign component 'FANAT' of structure gs_pending_0021 to <lv_fanat>.
          if sy-subrc = 0 and <lv_fanat> is initial. <lv_fanat> = 'TR'. endif.
        endif.
        if lv_fgbot is not initial
           and lv_fgbot ns '/' and lv_fgbot ns '('.
          assign component 'FGBLD' of structure gs_pending_0021 to <lv_fgbld>.
          if sy-subrc = 0 and <lv_fgbld> is initial. <lv_fgbld> = 'TR'. endif.
        endif.
      endif.
      lv_proc_idx = lv_proc_idx + 1.
    endloop.
    if lv_first_idx = 0.
      case lv_subty.
        when '1'.
          message 'Es icin PA0021 kaydi mevcut veya belgede esi bulunamadi' type 'I'.
        when '2'.
          message 'Belge icinde subtype 2 icin uygun cocuk satiri bulunamadi' type 'I'.
      endcase.
      return.
    endif.
    gv_pending_extra_count = lv_proc_idx - 1.
    if gv_pending_extra_count > 0.
      message |{ gv_pending_extra_count } kisi daha belgede mevcut, INS ile tekrar yukleyiniz|
        type 'I'.
    endif.
    gv_has_pending = abap_true.
  endmethod.


  method apply_vals_to_p0770.
    data ls_val type zrpd_edev_s_dcval.
    field-symbols <ls_val>   like ls_val.
    field-symbols <lv_field> type any.
    loop at it_vals assigning <ls_val>.
      assign component <ls_val>-field_name of structure gs_pending_0770 to <lv_field>.
      if sy-subrc = 0.
        <lv_field> = <ls_val>-field_value.
      endif.
    endloop.
    gv_has_pending = abap_true.
  endmethod.


  method fill_pending_key.
    field-symbols <lv_val> type any.
    clear: gv_pending_subty, gv_pending_objps, gv_pending_sprps,
           gv_pending_endda, gv_pending_begda, gv_pending_seqnr.
    assign ('(SAPFP50M)PSPAR-SUBTY') to <lv_val>.
    if sy-subrc = 0.
      gv_pending_subty = <lv_val>.
    endif.
    assign ('(SAPFP50M)PSPAR-OBJPS') to <lv_val>.
    if sy-subrc = 0.
      gv_pending_objps = <lv_val>.
    endif.
    assign ('(SAPFP50M)PSPAR-SPRPS') to <lv_val>.
    if sy-subrc = 0.
      gv_pending_sprps = <lv_val>.
    endif.
    assign ('(SAPFP50M)PSPAR-ENDDA') to <lv_val>.
    if sy-subrc = 0.
      gv_pending_endda = <lv_val>.
    endif.
    assign ('(SAPFP50M)PSPAR-BEGDA') to <lv_val>.
    if sy-subrc = 0.
      gv_pending_begda = <lv_val>.
    endif.
    assign ('(SAPFP50M)PSPAR-SEQNR') to <lv_val>.
    if sy-subrc = 0.
      gv_pending_seqnr = <lv_val>.
    endif.
  endmethod.


  method generate_confg_id.
    data lv_uuid type sysuuid_x16.
    data lv_hex  type string.
    try.
        lv_uuid = cl_system_uuid=>create_uuid_x16_static( ).
        lv_hex  = lv_uuid.
      catch cx_root.
        lv_hex = |{ sy-datum }{ sy-uzeit }{ sy-uname }|.
    endtry.
    translate lv_hex to upper case.
    shift lv_hex left deleting leading '0'.
    if strlen( lv_hex ) < 16.
      lv_hex = |{ lv_hex }0000000000000000|.
    endif.
    rv_confg = |{ lv_hex(4) }-{ lv_hex+4(4) }-{ lv_hex+8(4) }-{ lv_hex+12(4) }|.
  endmethod.


  method get_current_record.
    data lv_pernr type persno.
    data lv_subty type subty_591a.
    data lv_begda type begda.
    data lv_seqnr type pspar-seqnr.
    data lv_max   type pspar-seqnr.
    clear: ev_pernr, ev_subty, ev_confg, ev_filep.
    ev_found = abap_false.
    lv_pernr = gv_curr_pernr.
    data lv_atip_h type n length 2.
    data lv_doc_h  type zrpd_edev_de_dctyp.
    data lv_pars_h type seoclsname.
    data lv_fnd_h  type abap_bool.
    resolve_mapping(
      exporting iv_infty        = gv_current_infty
      importing ev_atip         = lv_atip_h
                ev_doc_type     = lv_doc_h
                ev_parser_class = lv_pars_h
                ev_found        = lv_fnd_h ).
    lv_subty = lv_atip_h.
    lv_begda = gv_curr_begda.
    lv_seqnr = gv_curr_seqnr.
    if lv_pernr is initial.
      return.
    endif.
    if lv_seqnr is initial.
      select single max( seqnr )
        from pa9657
        where pernr = @lv_pernr
          and subty = @lv_subty
          and begda <= @sy-datum
          and endda >= @sy-datum
        into @lv_max.
      if sy-subrc <> 0 or lv_max is initial.
        return.
      endif.
      lv_seqnr = lv_max.
    endif.
    select single confg, filep
      from pa9657
      into (@ev_confg, @ev_filep)
      where pernr = @lv_pernr
        and subty = @lv_subty
        and seqnr = @lv_seqnr
        and begda <= @sy-datum
        and endda >= @sy-datum.
    if sy-subrc = 0.
      ev_pernr = lv_pernr.
      ev_subty = lv_subty.
      ev_found = abap_true.
    endif.
  endmethod.


  method get_pernr.
    field-symbols <lv_pernr> type persno.
    assign ('(SAPFP50M)PSPAR-PERNR') to <lv_pernr>.
    if sy-subrc = 0.
      rv_pernr = <lv_pernr>.
    endif.
  endmethod.


  method get_plate_code.
    data lv_norm type string.
    data lv_bezei type string.
    data lt_regions type standard table of t005u.
    data ls_region type t005u.
    rv_plate = ''.
    try.
        lv_norm = iv_il.
        lv_norm = to_upper( lv_norm ).
        condense lv_norm.
        normalize_turkish( changing cv_text = lv_norm ).
        select bland bezei from t005u
          into corresponding fields of table lt_regions
          where spras = 'T' and land1 = 'TR'.
        loop at lt_regions into ls_region.
          lv_bezei = ls_region-bezei.
          lv_bezei = to_upper( lv_bezei ).
          condense lv_bezei.
          normalize_turkish( changing cv_text = lv_bezei ).
          if lv_bezei = lv_norm.
            rv_plate = ls_region-bland.
            return.
          endif.
        endloop.
      catch cx_root.
        rv_plate = ''.
    endtry.
  endmethod.


  method has_djtl_method.
    data lo_class type ref to cl_abap_classdescr.
    data lo_descr type ref to cl_abap_typedescr.
    rv_exists = abap_false.
    if is_djtl_available( ) = abap_false.
      return.
    endif.
    try.
        lo_descr ?= cl_abap_typedescr=>describe_by_name( co_djtl_class ).
        lo_class ?= lo_descr.
        if line_exists( lo_class->methods[ name = iv_method ] ).
          rv_exists = abap_true.
        endif.
      catch cx_root.
        rv_exists = abap_false.
    endtry.
  endmethod.


  method if_ex_hrpad00infty~after_input.
    data: begin of ls_text,
            nummer type x value '02',
          end of ls_text.
    data: begin of ls_line,
            line(78) type c,
          end of ls_line.
    data lt_ptext    like standard table of ls_line with empty key.
    data lv_pernr8   type char8.
    data lv_subty4   type char4.
    data lv_objps2   type char2.
    data lv_sprps1   type char1.
    data lv_endda8   type char8.
    data lv_begda8   type char8.
    data lv_seqnr3   type char3.
    data lv_key      type char38.
    data lv_ok_u     type abap_bool.
    data lv_filep_u  type string.
    data lv_msg_u    type string.
    data lv_subtyp_call type subty.
    data lv_atip_chk type n length 2.
    data lv_doc_chk  type zrpd_edev_de_dctyp.
    data lv_pars_chk type seoclsname.
    data lv_fnd_chk  type abap_bool.
    data lt_tc_msg2  type bapiret2_t.
    data ls_tc_msg2  type bapiret2.
    resolve_mapping(
      exporting iv_infty        = new_innnn-infty
      importing ev_atip         = lv_atip_chk
                ev_doc_type     = lv_doc_chk
                ev_parser_class = lv_pars_chk
                ev_found        = lv_fnd_chk ).
    if lv_fnd_chk = abap_false.
      return.
    endif.
    if new_innnn-infty = co_infty_0770 and gv_tc_checked = abap_false.
      data lv_client_category type t000-cccategory.
      select single cccategory from t000
        into @lv_client_category
        where mandt = @sy-mandt.
      if lv_client_category = 'P'
         and ipsyst-ioper    <> 'DEL'
         and i001p-molga     =  '47'
         and new_innnn-subty =  '01'.
        data ls_p0770 type p0770.
        call method cl_hr_pnnnn_type_cast=>prelp_to_pnnnn
          exporting prelp = new_innnn
          importing pnnnn = ls_p0770.
        data ls_par2 type p0002.
        select single vorna, nachn, gbdat
          from pa0002
          into corresponding fields of @ls_par2
          where pernr = @ls_p0770-pernr
            and begda <= @ls_p0770-endda
            and endda >= @ls_p0770-begda.
        if sy-subrc = 0.
          data lv_dogum_y  type string.
          data lv_vorna_p2 type vorna.
          data lv_nachn_p2 type nachn.
          lv_dogum_y  = ls_par2-gbdat(4).
          lv_vorna_p2 = ls_par2-vorna.
          lv_nachn_p2 = ls_par2-nachn.
          lt_tc_msg2 = tc_online_check(
            iv_merni     = ls_p0770-merni
            iv_vorna     = lv_vorna_p2
            iv_nachn     = lv_nachn_p2
            iv_dogum_str = lv_dogum_y ).
          read table lt_tc_msg2 into ls_tc_msg2 with key type = 'E'.
          if sy-subrc = 0.
            if ls_tc_msg2-message is initial.
              message id ls_tc_msg2-id type 'E'
                number ls_tc_msg2-number
                with ls_tc_msg2-message_v1 ls_tc_msg2-message_v2
                     ls_tc_msg2-message_v3 ls_tc_msg2-message_v4
                display like 'I'.
            else.
              message ls_tc_msg2-message type 'E' display like 'I'.
            endif.
          endif.
        endif.
      endif.
      gv_tc_checked = abap_true.
    endif.
    if gv_pending_config is initial.
      return.
    endif.
    if gv_f9_written = abap_true.
      return.
    endif.
    if new_innnn-infty <> co_infty_0770.
      ls_line-line = gv_pending_config.
      lv_pernr8 = new_innnn-pernr.
      lv_subty4 = new_innnn-subty.
      lv_objps2 = new_innnn-objps.
      lv_sprps1 = new_innnn-sprps.
      lv_endda8 = new_innnn-endda.
      lv_begda8 = new_innnn-begda.
      lv_seqnr3 = new_innnn-seqnr.
      concatenate lv_pernr8 new_innnn-infty lv_subty4 lv_objps2 lv_sprps1
                  lv_endda8 lv_begda8 lv_seqnr3
                  into lv_key respecting blanks.
      import text-version = ls_text
             ptext        = lt_ptext
        from database pcl1(tx) id lv_key.
      clear ls_line.
      ls_line-line = gv_pending_config.
      append ls_line to lt_ptext.
      export text-version = ls_text
             ptext        = lt_ptext
        to database pcl1(tx) id lv_key.
    endif.
    gv_f9_written = abap_true.
    gv_pending_pernr = new_innnn-pernr.
    gv_pending_subty = new_innnn-subty.
    gv_pending_objps = new_innnn-objps.
    gv_pending_sprps = new_innnn-sprps.
    gv_pending_endda = new_innnn-endda.
    gv_pending_begda = new_innnn-begda.
    gv_pending_seqnr = new_innnn-seqnr.
    if gv_pending_file is not initial.
      lv_subtyp_call = gv_pending_atip.
      if has_djtl_method( 'WRITE_FILE_AND_CREATE_RECORD' ) = abap_true.
        try.
            call method ('ZCL_ZRPD_DJTL_FILE')=>('WRITE_FILE_AND_CREATE_RECORD')
              exporting
                iv_pernr     = gv_pending_pernr
                iv_subtyp    = lv_subtyp_call
                iv_begda     = sy-datum
                iv_file_data = gv_pending_file
                iv_source    = gv_pending_source
                iv_config    = gv_pending_config
              importing
                ev_xuploaded = lv_ok_u
                ev_filename  = lv_filep_u
                ev_message   = lv_msg_u.
          catch cx_root.
        endtry.
      endif.
    endif.
    clear: gv_pending_file, gv_pending_atip, gv_pending_pernr,
           gv_pending_source, gv_pending_config,
           gv_pending_subty, gv_pending_objps, gv_pending_sprps,
           gv_pending_endda, gv_pending_begda, gv_pending_seqnr,
           gv_f9_written.
  endmethod.


  method if_ex_hrpad00infty~before_output.
    data lv_atip    type n length 2.
    data lv_found   type abap_bool.
    data lv_doc_type type zrpd_edev_de_dctyp.
    data lv_parser  type seoclsname.
    data lt_targets type standard table of zrpd_edev_de_iflnm.
    data lv_target  type zrpd_edev_de_iflnm.
    data lv_status  type sypfkey.
    field-symbols <ls_0006>     type p0006.
    field-symbols <ls_0770>     type p0770.
    field-symbols <fs_src>      type any.
    field-symbols <fs_dst>      type any.
    field-symbols <lv_oper>     type c.
    field-symbols <lv_cp_itxex> type any.
    gv_current_infty = innnn-infty.
    resolve_mapping(
      exporting iv_infty = innnn-infty
      importing ev_atip  = lv_atip
                ev_doc_type = lv_doc_type
                ev_parser_class = lv_parser
                ev_found = lv_found ).
    if lv_found = abap_false. return. endif.
    gv_curr_pernr = innnn-pernr.
    gv_curr_subty = innnn-subty.
    gv_curr_objps = innnn-objps.
    gv_curr_sprps = innnn-sprps.
    gv_curr_begda = innnn-begda.
    gv_curr_endda = innnn-endda.
    gv_curr_seqnr = innnn-seqnr.
    if gv_has_pending = abap_true and innnn-infty = co_infty_0006.
      assign (co_mp_p0006) to <ls_0006>.
      if sy-subrc = 0.
        select distinct infotype_field
          from zrpd_edev_t_dmap
          into table @lt_targets
          where doc_type       = @lv_doc_type
            and infotype       = '0006'
            and infotype_field <> @space.
        loop at lt_targets into lv_target.
          assign component lv_target of structure gs_pending to <fs_src>.
          if sy-subrc <> 0. continue. endif.
          if <fs_src> is initial. continue. endif.
          assign component lv_target of structure <ls_0006> to <fs_dst>.
          if sy-subrc <> 0. continue. endif.
          <fs_dst> = <fs_src>.
        endloop.
        if <ls_0006>-land1 is initial.
          <ls_0006>-land1 = 'TR'.
        endif.
      endif.
      clear gs_pending.
      clear gv_has_pending.
    endif.
    if gv_has_pending = abap_true and innnn-infty = co_infty_0022.
      apply_pending_0022( ).
    endif.
    if gv_has_pending = abap_true and innnn-infty = co_infty_0021.
      apply_pending_0021( ).
    endif.
    if gv_has_pending = abap_true and innnn-infty = co_infty_0770.
      assign (co_mp_p0770) to <ls_0770>.
      if sy-subrc = 0.
        select distinct infotype_field
          from zrpd_edev_t_dmap
          into table @lt_targets
          where doc_type       = @lv_doc_type
            and infotype       = '0770'
            and infotype_field <> @space.
        loop at lt_targets into lv_target.
          assign component lv_target of structure gs_pending_0770 to <fs_src>.
          if sy-subrc <> 0. continue. endif.
          if <fs_src> is initial. continue. endif.
          assign component lv_target of structure <ls_0770> to <fs_dst>.
          if sy-subrc <> 0. continue. endif.
          <fs_dst> = <fs_src>.
        endloop.
      endif.
      clear gs_pending_0770.
      clear gv_has_pending.
    endif.
    if gv_pending_config is not initial and innnn-infty = co_infty_0006.
      assign (co_mp_p0006) to <ls_0006>.
      if sy-subrc = 0.
        <ls_0006>-itxex = 'X'.
      endif.
      assign ('(SAPFP50M)CPREL-ITXEX') to <lv_cp_itxex>.
      if sy-subrc = 0.
        <lv_cp_itxex> = 'X'.
      endif.
      assign ('(SAPFP50M)PREL-ITXEX') to <lv_cp_itxex>.
      if sy-subrc = 0.
        <lv_cp_itxex> = 'X'.
      endif.
      assign ('(SAPFP50M)PSHDR-ITXEX') to <lv_cp_itxex>.
      if sy-subrc = 0.
        <lv_cp_itxex> = 'X'.
      endif.
    endif.
    if gv_pending_config is not initial and innnn-infty = co_infty_0022.
      set_itxex_0022( ).
      assign ('(SAPFP50M)CPREL-ITXEX') to <lv_cp_itxex>.
      if sy-subrc = 0.
        <lv_cp_itxex> = 'X'.
      endif.
      assign ('(SAPFP50M)PREL-ITXEX') to <lv_cp_itxex>.
      if sy-subrc = 0.
        <lv_cp_itxex> = 'X'.
      endif.
      assign ('(SAPFP50M)PSHDR-ITXEX') to <lv_cp_itxex>.
      if sy-subrc = 0.
        <lv_cp_itxex> = 'X'.
      endif.
    endif.
    if gv_pending_config is not initial and innnn-infty = co_infty_0021.
      set_itxex_0021( ).
    endif.
    " IT0770 ITXEX set blogu kaldirildi (2026-05-01) - T582A NO_TEXT hatasini onler
    " SGUI2: IT0006 disinda EFRA butonu gizli
    assign ('(SAPFP50M)PSYST-IOPER') to <lv_oper>.
    if sy-subrc = 0.
      case <lv_oper>.
        when 'INS' or 'MOD' or 'DEL' or 'DIS' or 'LIS9' or 'COP'.
          lv_status = <lv_oper>.
      endcase.
      if lv_status is not initial.
        if innnn-infty = co_infty_0006.
          set pf-status lv_status of program co_sgui_prog.
        else.
          set pf-status lv_status of program 'ZRPD_EDEV_R_SGUI2'.
        endif.
      endif.
    endif.
  endmethod.


  method if_ex_hrpad00infty~in_update.
  endmethod.


  method is_djtl_available.
    data lo_descr type ref to cl_abap_typedescr.
    if gv_djtl_checked = abap_true.
      rv_avail = gv_djtl_avail.
      return.
    endif.
    try.
        lo_descr = cl_abap_typedescr=>describe_by_name( co_djtl_class ).
        if lo_descr is bound.
          gv_djtl_avail = abap_true.
        endif.
      catch cx_root.
        gv_djtl_avail = abap_false.
    endtry.
    gv_djtl_checked = abap_true.
    rv_avail = gv_djtl_avail.
  endmethod.


  method lookup_ausbi.
    data: begin of ls_t518b,
            ausbi type t518b-ausbi,
            atext type t518b-atext,
          end of ls_t518b.
    data lt_t518b like standard table of ls_t518b.
    data lv_norm   type string.
    data lv_bezei  type string.
    rv_ausbi = ''.
    if iv_uni_metni is initial. return. endif.
    lv_norm = iv_uni_metni.
    lv_norm = to_upper( lv_norm ).
    condense lv_norm.
    normalize_turkish( changing cv_text = lv_norm ).
    select ausbi atext from t518b
      into corresponding fields of table lt_t518b
      where langu = sy-langu.
    if sy-subrc <> 0.
      select ausbi atext from t518b
        into corresponding fields of table lt_t518b
        where langu = 'T'.
    endif.
    loop at lt_t518b into ls_t518b.
      lv_bezei = to_upper( ls_t518b-atext ).
      condense lv_bezei.
      normalize_turkish( changing cv_text = lv_bezei ).
      if lv_bezei = lv_norm or lv_bezei cs lv_norm or lv_norm cs lv_bezei.
        rv_ausbi = ls_t518b-ausbi.
        return.
      endif.
    endloop.
  endmethod.


  method lookup_slabs.
    data lv_slart    type slart.
    data: begin of ls_t517,
            slart type t517a-slart,
            stext type t517t-stext,
          end of ls_t517.
    data lt_t517     like standard table of ls_t517.
    data lt_slabs    type standard table of slabs with empty key.
    data: begin of ls_t519,
            slabs type t519t-slabs,
            stext type t519t-stext,
          end of ls_t519.
    data lt_t519     like standard table of ls_t519.
    data lv_norm     type string.
    data lv_bezei    type string.
    data lv_best_len type i.
    data lv_curr_len type i.
    rv_slabs = ''.
*
    if iv_program_text is initial.
*
      return.
    endif.
    lv_norm = iv_program_text.
    lv_norm = to_upper( lv_norm ).
    condense lv_norm.
    normalize_turkish( changing cv_text = lv_norm ).
    select distinct a~slart t~stext
      from t517a as a inner join t517t as t
        on t~slart = a~slart
      into corresponding fields of table lt_t517
      where t~sprsl = sy-langu.
    if lt_t517 is initial.
      select distinct a~slart t~stext
        from t517a as a inner join t517t as t
          on t~slart = a~slart
        into corresponding fields of table lt_t517
        where t~sprsl = 'T'.
    endif.
    lv_best_len = 0.
    loop at lt_t517 into ls_t517.
      if ls_t517-stext is initial. continue. endif.
      lv_bezei = to_upper( ls_t517-stext ).
      condense lv_bezei.
      normalize_turkish( changing cv_text = lv_bezei ).
      if lv_norm cs lv_bezei.
        lv_curr_len = strlen( lv_bezei ).
        if lv_curr_len > lv_best_len.
          lv_best_len = lv_curr_len.
          lv_slart = ls_t517-slart.
        endif.
      endif.
    endloop.
*
*
*
    if lv_slart is initial.
*
      return.
    endif.
    select abart from t517a
      into table @lt_slabs
      where slart = @lv_slart.
*
    data lv_slabs_list  type string.
    data ls_slabs_dbg   type slabs.
*
    loop at lt_slabs into ls_slabs_dbg.
      lv_slabs_list = |{ lv_slabs_list } { ls_slabs_dbg }|.
    endloop.
*
    if lt_slabs is initial.
*
      return.
    endif.
    if iv_durum_text is initial.
*
      return.
    endif.
    lv_norm = iv_durum_text.
    lv_norm = to_upper( lv_norm ).
    condense lv_norm.
    normalize_turkish( changing cv_text = lv_norm ).
    select slabs stext from t519t
      into corresponding fields of table lt_t519
      for all entries in lt_slabs
      where slabs = lt_slabs-table_line
        and sprsl = sy-langu.
    if lt_t519 is initial.
      select slabs stext from t519t
        into corresponding fields of table lt_t519
        for all entries in lt_slabs
        where slabs = lt_slabs-table_line
          and sprsl = 'T'.
    endif.
*
*
*
    " Match stratejisi:
    " 1) Direct cs (substring) match -- "MEZUN" in "Diplomali"
    " 2) Stem match -- durum/stext kelimelerinin 4-char prefix leri kesisirse match
    "    Ornek: durum="MEZUNIYET" stem={MEZU}, stext="Universite mezunu" stems={UNIV,MEZU} -> kesisim
    data lt_norm_stems  type standard table of string with empty key.
    data lt_bezei_stems type standard table of string with empty key.
    data lt_words       type standard table of string with empty key.
    data lv_word        type string.
    data lv_stem        type string.
    data lv_match_count type i.
    data lv_score       type i.
    " Norm un stem leri (bir kez)
    split lv_norm at space into table lt_words.
    loop at lt_words into lv_word.
      if strlen( lv_word ) >= 4.
        lv_stem = lv_word(4).
        insert lv_stem into table lt_norm_stems.
      endif.
    endloop.
    lv_best_len = 0.
    loop at lt_t519 into ls_t519.
      if ls_t519-stext is initial. continue. endif.
      lv_bezei = to_upper( ls_t519-stext ).
      condense lv_bezei.
      normalize_turkish( changing cv_text = lv_bezei ).
      " 1) Substring match (her iki yon)
      if lv_norm cs lv_bezei or lv_bezei cs lv_norm.
        lv_curr_len = strlen( lv_bezei ).
        lv_score    = lv_curr_len + 1000. " substring match yuksek puan
        if lv_score > lv_best_len.
          lv_best_len = lv_score.
          rv_slabs    = ls_t519-slabs.
        endif.
        continue.
      endif.
      " 2) Stem match
      clear lt_bezei_stems.
      split lv_bezei at space into table lt_words.
      lv_match_count = 0.
      loop at lt_words into lv_word.
        if strlen( lv_word ) >= 4.
          lv_stem = lv_word(4).
          insert lv_stem into table lt_bezei_stems.
          read table lt_norm_stems with key table_line = lv_stem transporting no fields.
          if sy-subrc = 0.
            lv_match_count = lv_match_count + 1.
          endif.
        endif.
      endloop.
      if lv_match_count > 0.
        lv_score = lv_match_count * 100 + strlen( lv_bezei ).
        if lv_score > lv_best_len.
          lv_best_len = lv_score.
          rv_slabs    = ls_t519-slabs.
        endif.
      endif.
    endloop.
*
  endmethod.


  method lookup_sltp1.
    data: begin of ls_t517x,
            faart type t517x-faart,
            ftext type t517x-ftext,
          end of ls_t517x.
    data lt_t517x like standard table of ls_t517x.
    data lv_norm   type string.
    data lv_bezei  type string.
    rv_sltp1 = ''.
    if iv_bolum_metni is initial. return. endif.
    lv_norm = iv_bolum_metni.
    lv_norm = to_upper( lv_norm ).
    condense lv_norm.
    normalize_turkish( changing cv_text = lv_norm ).
    select faart ftext from t517x
      into corresponding fields of table lt_t517x
      where langu = sy-langu.
    if sy-subrc <> 0.
      select faart ftext from t517x
        into corresponding fields of table lt_t517x
        where langu = 'T'.
    endif.
    loop at lt_t517x into ls_t517x.
      lv_bezei = to_upper( ls_t517x-ftext ).
      condense lv_bezei.
      normalize_turkish( changing cv_text = lv_bezei ).
      if lv_bezei = lv_norm or lv_bezei cs lv_norm or lv_norm cs lv_bezei.
        rv_sltp1 = ls_t517x-faart.
        return.
      endif.
    endloop.
  endmethod.


  method normalize_turkish.
    data lv_char type c length 1.
    lv_char = cl_abap_conv_in_ce=>uccp( '0130' ).
    replace all occurrences of lv_char in cv_text with 'I'.
    lv_char = cl_abap_conv_in_ce=>uccp( '00D6' ).
    replace all occurrences of lv_char in cv_text with 'O'.
    lv_char = cl_abap_conv_in_ce=>uccp( '00DC' ).
    replace all occurrences of lv_char in cv_text with 'U'.
    lv_char = cl_abap_conv_in_ce=>uccp( '015E' ).
    replace all occurrences of lv_char in cv_text with 'S'.
    lv_char = cl_abap_conv_in_ce=>uccp( '00C7' ).
    replace all occurrences of lv_char in cv_text with 'C'.
    lv_char = cl_abap_conv_in_ce=>uccp( '011E' ).
    replace all occurrences of lv_char in cv_text with 'G'.
  endmethod.


  method process_command.
    data lv_atip      type n length 2.
    data lv_doc_type  type zrpd_edev_de_dctyp.
    data lv_parser    type seoclsname.
    data lv_found     type abap_bool.
    resolve_mapping(
      exporting iv_infty        = gv_current_infty
      importing ev_atip         = lv_atip
                ev_doc_type     = lv_doc_type
                ev_parser_class = lv_parser
                ev_found        = lv_found ).
    if lv_found = abap_false.
      message 'Bu bilgi tipi icin belge eslesmesi bulunamadi' type 'S' display like 'W'.
      return.
    endif.
    case iv_action.
      when co_cmd_upload.
        process_upload(
          iv_atip     = lv_atip
          iv_doc_type = lv_doc_type
          iv_parser   = lv_parser ).
      when co_cmd_view.
        process_view( ).
      when co_cmd_delete.
        process_delete( ).
    endcase.
  endmethod.


  method process_delete.
    data: begin of ls_txhdr, nummer type x value '02', end of ls_txhdr.
    data: begin of ls_txrow, line(78) type c, end of ls_txrow.
    data lt_ptext    like standard table of ls_txrow with empty key.
    data lv_pcl1key  type char38.
    data lv_pernr8   type char8.
    data lv_subty4   type char4.
    data lv_objps2   type char2.
    data lv_sprps1   type char1.
    data lv_endda8   type char8.
    data lv_begda8   type char8.
    data lv_seqnr3   type char3.
    data lv_pernr    type persno.
    data lv_subty    type subty_591a.
    data lv_confg    type zrpd_djtl_de_confg.
    data lv_filep    type zrpd_djtl_de_filep.
    data lv_found    type abap_bool.
    data lv_answer   type c length 1.
    data lv_ok       type abap_bool.
    data lv_msg      type string.
    get_current_record(
      importing
        ev_pernr = lv_pernr
        ev_subty = lv_subty
        ev_confg = lv_confg
        ev_filep = lv_filep
        ev_found = lv_found ).
    if lv_found = abap_false.
      message 'Aktif PA9657 kaydi bulunamadi' type 'S' display like 'W'.
      set screen sy-dynnr.
      leave screen.
    endif.
    if has_djtl_method( 'DELETE_DOCUMENT' ) = abap_false.
      message 'DJTL paketi bulunamadi, dokuman silinemiyor' type 'S' display like 'W'.
      set screen sy-dynnr.
      leave screen.
    endif.
    call function 'POPUP_TO_CONFIRM'
      exporting
        titlebar              = 'Dokuman Silme Onayi'
        text_question         = 'Bu islem PA9657 kaydiyla birlikte AL11 dokumanini da silecek. Devam edilsin mi?'
        default_button        = '2'
        display_cancel_button = abap_false
      importing
        answer                = lv_answer
      exceptions
        text_not_found        = 1
        others                = 2.
    if sy-subrc <> 0 or lv_answer <> '1'.
      return.
    endif.
    try.
        call method ('ZCL_ZRPD_DJTL_FILE')=>('DELETE_DOCUMENT')
          exporting
            iv_pernr              = lv_pernr
            iv_subtyp             = lv_subty
            iv_config             = lv_confg
            iv_filep              = lv_filep
            iv_skip_record_delete = abap_false
          importing
            ev_success            = lv_ok
            ev_message            = lv_msg.
      catch cx_root.
        lv_ok  = abap_false.
        lv_msg = 'DJTL silme hatasi'.
    endtry.
    data lv_pa_table type tabname.
    lv_pernr8 = gv_curr_pernr.
    lv_subty4 = gv_curr_subty.
    lv_objps2 = gv_curr_objps.
    lv_sprps1 = gv_curr_sprps.
    lv_endda8 = gv_curr_endda.
    lv_begda8 = gv_curr_begda.
    lv_seqnr3 = gv_curr_seqnr.
    concatenate lv_pernr8 gv_current_infty lv_subty4 lv_objps2 lv_sprps1
                lv_endda8 lv_begda8 lv_seqnr3
                into lv_pcl1key respecting blanks.
    lv_pa_table = |PA{ gv_current_infty }|.
    import text-version = ls_txhdr ptext = lt_ptext
      from database pcl1(tx) id lv_pcl1key.
    if sy-subrc = 0.
      delete lt_ptext where line = lv_confg.
      if lt_ptext is initial.
        delete from database pcl1(tx) id lv_pcl1key.
        update (lv_pa_table) set itxex = ' '
          where pernr = gv_curr_pernr
            and subty = gv_curr_subty
            and objps = gv_curr_objps
            and sprps = gv_curr_sprps
            and endda = gv_curr_endda
            and begda = gv_curr_begda
            and seqnr = gv_curr_seqnr ##SUBRC_OK.
      else.
        export text-version = ls_txhdr ptext = lt_ptext
          to database pcl1(tx) id lv_pcl1key.
      endif.
      commit work.
    endif.
    if lv_ok = abap_true.
      message 'Dokuman ve kayit silindi' type 'S'.
    else.
      message lv_msg type 'S' display like 'W'.
    endif.
    set screen sy-dynnr.
    leave screen.
  endmethod.


  method process_edev.
    process_command( co_cmd_upload ).
  endmethod.


  method process_edev_delete.
    process_command( co_cmd_delete ).
  endmethod.


  method process_p0006.
    data lv_tckn     type char11.
    data lv_barcode  type zrpd_edev_de_bcno.
    data lt_fields   type table of sval.
    data ls_field    type sval.
    data lv_rc       type c length 1.
    data lt_vals     type zrpd_edev_tt_dcval.
    data ls_val      type zrpd_edev_s_dcval.
    data lo_edv      type ref to zcl_zrpd_edev_edevlet.
    data lv_ok       type abap_bool.
    data lv_pdf      type xstring.
    data lo_base     type ref to zcl_zrpd_edev_doc_base.
    data lo_ocr      type ref to zcl_zrpd_edev_ocr_py.
    data lv_text     type string.
    data lv_upper    type string.
    data lo_parser   type ref to zcl_zrpd_edev_doc_base.
    data lx_root     type ref to cx_root.
    data lv_errmsg   type string.
    data lv_fn       type zrpd_edev_de_fldnm.
    data lv_it_field type zrpd_edev_de_iflnm.
    data lv_append   type string.
    data lv_doc_type type zrpd_edev_de_dctyp.
    data: begin of ls_grp,
            it_field type zrpd_edev_de_iflnm,
            value    type string,
          end of ls_grp.
    data lt_grp like sorted table of ls_grp with unique key it_field.
    data: begin of ls_map,
            field_name     type zrpd_edev_de_fldnm,
            infotype_field type zrpd_edev_de_iflnm,
          end of ls_map.
    data lt_map like sorted table of ls_map with unique key field_name.
    field-symbols <ls_grp> like ls_grp.
    field-symbols <fs_val> type any.
    field-symbols <ls_map> like ls_map.
    select single doc_type from zrpd_edev_t_dtyp
      into @lv_doc_type
      where infotype = '0006' and active = 'X'.
    if sy-subrc <> 0.
      lv_doc_type = 'IKAMETGAH'.
    endif.
    select single merni from pa0770
      into lv_tckn
      where pernr = cs_0006-pernr
        and endda >= sy-datum
        and begda <= sy-datum.
    if sy-subrc <> 0 or lv_tckn is initial.
      message 'PA0770 MERNI bulunamadi' type 'S' display like 'E'.
      return.
    endif.
    ls_field-tabname   = 'ZRPD_EDEV_S_DOCHD'.
    ls_field-fieldname = 'BARCODE'.
    ls_field-fieldtext = 'Barkod'.
    append ls_field to lt_fields.
    call function 'POPUP_GET_VALUES'
      exporting
        popup_title     = 'e-Devlet Belge Dogrulama'
      importing
        returncode      = lv_rc
      tables
        fields          = lt_fields
      exceptions
        error_in_fields = 1
        others          = 2.
    if sy-subrc <> 0 or lv_rc = 'A'. return. endif.
    read table lt_fields into ls_field index 1.
    lv_barcode = ls_field-value.
    if lv_barcode is initial. return. endif.
    gv_pending_config = lv_barcode.
    try.
        create object lo_edv.
        lv_ok = lo_edv->verify(
          iv_barcode = lv_barcode
          iv_tckn    = lv_tckn ).
        if lv_ok <> abap_true.
          message 'Barkod GECERSIZ' type 'S' display like 'E'.
          return.
        endif.
        lv_pdf = lo_edv->fetch_pdf(
          iv_barcode = lv_barcode
          iv_tckn    = lv_tckn ).
        if lv_pdf is initial.
          message 'Belge indirilemedi' type 'S' display like 'E'.
          return.
        endif.
        gv_pending_file = lv_pdf.
        create object lo_base type zcl_zrpd_edev_doc_ika.
        lv_text = lo_base->pdf_to_text( lv_pdf ).
        lv_upper = to_upper( lv_text ).
        if lv_text is initial
          or ( lv_upper ns 'KIMLIK' and lv_upper ns 'YERLESIM' and lv_upper ns 'ADRES' ).
          create object lo_ocr.
          lv_text = lo_ocr->extract_text( lv_pdf ).
        endif.
        create object lo_parser type zcl_zrpd_edev_doc_ika.
        lt_vals = lo_parser->parse_fields( lv_text ).
      catch cx_root into lx_root.
        lv_errmsg = lx_root->get_text( ).
        if strlen( lv_errmsg ) > 200.
          lv_errmsg = lv_errmsg(200).
        endif.
        message lv_errmsg type 'S' display like 'E'.
        return.
    endtry.
    if lt_vals is initial.
      message 'Belgeden alan cikarilamadi' type 'S' display like 'W'.
      return.
    endif.
    select field_name, infotype_field
      from zrpd_edev_t_dmap
      where doc_type       = @lv_doc_type
        and infotype       = @co_infty_0006
        and infotype_field <> @space
      into corresponding fields of table @lt_map.
    if sy-subrc <> 0. lt_map = value #( ). endif.
    try.
        loop at lt_vals into ls_val.
          lv_fn = ls_val-field_name.
          translate lv_fn to lower case.
          if ls_val-field_value is initial. continue. endif.
          clear lv_it_field.
          read table lt_map assigning <ls_map> with table key field_name = lv_fn.
          if sy-subrc <> 0 or <ls_map>-infotype_field is initial. continue. endif.
          lv_it_field = <ls_map>-infotype_field.
          lv_append = ls_val-field_value.
          if lv_fn = 'blok'.
            lv_append = |{ ls_val-field_value } Blok|.
          elseif lv_fn = 'il'.
            lv_append = get_plate_code( ls_val-field_value ).
            if lv_append is initial.
              continue.
            endif.
          endif.
          read table lt_grp assigning <ls_grp> with table key it_field = lv_it_field.
          if sy-subrc = 0.
            if <ls_grp>-value is initial.
              <ls_grp>-value = lv_append.
            else.
              <ls_grp>-value = |{ <ls_grp>-value } { lv_append }|.
            endif.
          else.
            clear ls_grp.
            ls_grp-it_field = lv_it_field.
            ls_grp-value    = lv_append.
            insert ls_grp into table lt_grp.
          endif.
        endloop.
      catch cx_root into lx_root.
        lv_errmsg = lx_root->get_text( ).
        if strlen( lv_errmsg ) > 200.
          lv_errmsg = lv_errmsg(200).
        endif.
        message lv_errmsg type 'S' display like 'E'.
        return.
    endtry.
    loop at lt_grp into ls_grp.
      assign component ls_grp-it_field of structure cs_0006 to <fs_val>.
      if sy-subrc = 0.
        <fs_val> = ls_grp-value.
      endif.
    endloop.
  endmethod.


  method process_p0021.
    data lv_tckn     type char11.
    data lv_barcode  type zrpd_edev_de_bcno.
    data lt_fields   type table of sval.
    data ls_field    type sval.
    data lv_rc       type c length 1.
    data lt_vals     type zrpd_edev_tt_dcval.
    data lo_edv      type ref to zcl_zrpd_edev_edevlet.
    data lv_ok       type abap_bool.
    data lv_pdf      type xstring.
    data lo_base     type ref to zcl_zrpd_edev_doc_base.
    data lo_ocr      type ref to zcl_zrpd_edev_ocr_py.
    data lv_text     type string.
    data lv_upper    type string.
    data lo_parser   type ref to zcl_zrpd_edev_doc_base.
    data lx_root     type ref to cx_root.
    data lv_errmsg   type string.
    gv_pending_pernr = cs_0021-pernr.
    select single merni from pa0770
      into lv_tckn
      where pernr = cs_0021-pernr
        and endda >= sy-datum
        and begda <= sy-datum.
    if sy-subrc <> 0 or lv_tckn is initial.
      message 'PA0770 MERNI bulunamadi' type 'S' display like 'E'.
      return.
    endif.
    ls_field-tabname   = 'ZRPD_EDEV_S_DOCHD'.
    ls_field-fieldname = 'BARCODE'.
    ls_field-fieldtext = 'Barkod'.
    append ls_field to lt_fields.
    call function 'POPUP_GET_VALUES'
      exporting
        popup_title     = 'e-Devlet Aile Bildirimi Dogrulama'
      importing
        returncode      = lv_rc
      tables
        fields          = lt_fields
      exceptions
        error_in_fields = 1
        others          = 2.
    if sy-subrc <> 0 or lv_rc = 'A'. return. endif.
    read table lt_fields into ls_field index 1.
    lv_barcode = ls_field-value.
    if lv_barcode is initial. return. endif.
    gv_pending_config = lv_barcode.
    try.
        create object lo_edv.
        lv_ok = lo_edv->verify( iv_barcode = lv_barcode iv_tckn = lv_tckn ).
        if lv_ok <> abap_true.
          message 'Barkod GECERSIZ' type 'S' display like 'E'.
          return.
        endif.
        lv_pdf = lo_edv->fetch_pdf( iv_barcode = lv_barcode iv_tckn = lv_tckn ).
        if lv_pdf is initial.
          message 'Belge indirilemedi' type 'S' display like 'E'.
          return.
        endif.
        gv_pending_file = lv_pdf.
        create object lo_base type zcl_zrpd_edev_doc_ail.
        lv_text = lo_base->pdf_to_text( lv_pdf ).
        " lv_upper kaldirildi - validate_content artik dogrudan
        if lv_text is initial or lo_base->validate_content( lv_text ) <> abap_true.
          create object lo_ocr.
          lv_text = lo_ocr->extract_text( lv_pdf ).
        endif.
        create object lo_parser type zcl_zrpd_edev_doc_ail.
        lt_vals = lo_parser->parse_fields( lv_text ).
      catch cx_root into lx_root.
        lv_errmsg = lx_root->get_text( ).
        if strlen( lv_errmsg ) > 200.
          lv_errmsg = lv_errmsg(200).
        endif.
        message lv_errmsg type 'S' display like 'E'.
        return.
    endtry.
    if lt_vals is initial.
      message 'Belgeden alan cikarilamadi' type 'S' display like 'W'.
      return.
    endif.
    transform_aile_vals( changing ct_vals = lt_vals ).
    apply_vals_to_p0021( it_vals = lt_vals ).
    cs_0021 = gs_pending_0021.
  endmethod.


  method process_p0022.
    data lv_tckn     type char11.
    data lv_barcode  type zrpd_edev_de_bcno.
    data lt_fields   type table of sval.
    data ls_field    type sval.
    data lv_rc       type c length 1.
    data lt_vals     type zrpd_edev_tt_dcval.
    data lo_edv      type ref to zcl_zrpd_edev_edevlet.
    data lv_ok       type abap_bool.
    data lv_pdf      type xstring.
    data lo_base     type ref to zcl_zrpd_edev_doc_base.
    data lo_ocr      type ref to zcl_zrpd_edev_ocr_py.
    data lv_text     type string.
    data lv_upper    type string.
    data lo_parser   type ref to zcl_zrpd_edev_doc_base.
    data lx_root     type ref to cx_root.
    data lv_errmsg   type string.
    select single merni from pa0770
      into lv_tckn
      where pernr = cs_0022-pernr
        and endda >= sy-datum
        and begda <= sy-datum.
    if sy-subrc <> 0 or lv_tckn is initial.
      message 'PA0770 MERNI bulunamadi' type 'S' display like 'E'.
      return.
    endif.
    ls_field-tabname   = 'ZRPD_EDEV_S_DOCHD'.
    ls_field-fieldname = 'BARCODE'.
    ls_field-fieldtext = 'Barkod'.
    append ls_field to lt_fields.
    call function 'POPUP_GET_VALUES'
      exporting popup_title      = 'e-Devlet Belge Dogrulama'
      importing returncode       = lv_rc
      tables    fields           = lt_fields
      exceptions error_in_fields = 1 others = 2.
    if sy-subrc <> 0 or lv_rc = 'A'. return. endif.
    read table lt_fields into ls_field index 1.
    lv_barcode = ls_field-value.
    if lv_barcode is initial. return. endif.
    gv_pending_config = lv_barcode.
    try.
        create object lo_edv.
        lv_ok = lo_edv->verify( iv_barcode = lv_barcode iv_tckn = lv_tckn ).
        if lv_ok <> abap_true.
          message 'Barkod GECERSIZ' type 'S' display like 'E'.
          return.
        endif.
        lv_pdf = lo_edv->fetch_pdf( iv_barcode = lv_barcode iv_tckn = lv_tckn ).
        if lv_pdf is initial.
          message 'Belge indirilemedi' type 'S' display like 'E'.
          return.
        endif.
        gv_pending_file = lv_pdf.
        create object lo_base type zcl_zrpd_edev_doc_mez.
        lv_text = lo_base->pdf_to_text( lv_pdf ).
        lv_upper = to_upper( lv_text ).
        if lv_text is initial or lv_upper ns 'MEZUN'.
          create object lo_ocr.
          lv_text = lo_ocr->extract_text( lv_pdf ).
        endif.
        create object lo_parser type zcl_zrpd_edev_doc_mez.
        lt_vals = lo_parser->parse_fields( lv_text ).
      catch cx_root into lx_root.
        lv_errmsg = lx_root->get_text( ).
        if strlen( lv_errmsg ) > 200.
          lv_errmsg = lv_errmsg(200).
        endif.
        message lv_errmsg type 'S' display like 'E'.
        return.
    endtry.
    if lt_vals is initial.
      message 'Belgeden alan cikarilamadi' type 'S' display like 'W'.
      return.
    endif.
    transform_mez_vals( changing ct_vals = lt_vals ).
    apply_vals_to_0022( it_vals = lt_vals ).
    gs_pending_0022-sland = 'TR'.
    cs_0022 = gs_pending_0022.
  endmethod.


  method process_p0770.
  endmethod.


  method process_upload.
    data lv_pernr  type persno.
    data lv_choice type c length 1.
    clear: gv_f9_written,
           gv_pending_file, gv_pending_config, gv_pending_atip,
           gv_pending_pernr, gv_pending_source.
    lv_pernr = get_pernr( ).
    if lv_pernr is initial.
      message 'PERNR alinamadi' type 'S' display like 'E'.
      return.
    endif.
    if iv_parser is not initial.
      call function 'POPUP_TO_DECIDE'
        exporting
          titel        = 'Belge Yukleme'
          textline1    = 'Belge yukleme yontemi secin'
          text_option1 = 'e-Devlet Barkod ile yukle'
          text_option2 = 'Dosyadan yukle'
        importing
          answer       = lv_choice.
      if lv_choice = 'A'.
        return.
      endif.
      case lv_choice.
        when '1'.
          if gv_current_infty = co_infty_0770.
            message 'IT0770 (Kimlik) icin yalnizca Dosyadan Yukle seceneginiz bulunmaktadir'
                    type 'S' display like 'W'.
            return.
          endif.
          upload_from_edevlet(
            iv_pernr    = lv_pernr
            iv_atip     = iv_atip
            iv_doc_type = iv_doc_type ).
        when '2'.
          if gv_current_infty = co_infty_0770.
            upload_from_file_0770(
              iv_pernr    = lv_pernr
              iv_atip     = iv_atip
              iv_doc_type = iv_doc_type ).
          else.
            upload_from_file(
              iv_pernr    = lv_pernr
              iv_atip     = iv_atip
              iv_doc_type = iv_doc_type
              iv_parser   = iv_parser
              iv_infty    = gv_current_infty ).
          endif.
      endcase.
    else.
      upload_from_file(
        iv_pernr    = lv_pernr
        iv_atip     = iv_atip
        iv_doc_type = iv_doc_type
        iv_parser   = iv_parser
        iv_infty    = gv_current_infty ).
    endif.
  endmethod.


  method process_view.
    data lv_pernr type persno.
    data lv_subty type subty_591a.
    data lv_confg type zrpd_djtl_de_confg.
    data lv_filep type zrpd_djtl_de_filep.
    data lv_found type abap_bool.
    get_current_record(
      importing
        ev_pernr = lv_pernr
        ev_subty = lv_subty
        ev_confg = lv_confg
        ev_filep = lv_filep
        ev_found = lv_found ).
    if lv_found = abap_false.
      message 'Aktif PA9657 kaydi bulunamadi' type 'S' display like 'W'.
      return.
    endif.
    if has_djtl_method( 'VIEW_DOCUMENT' ) = abap_false.
      message 'DJTL paketi bulunamadi, dokuman goruntulenemiyor' type 'S' display like 'W'.
      return.
    endif.
    try.
        call method ('ZCL_ZRPD_DJTL_FILE')=>('VIEW_DOCUMENT')
          exporting
            iv_pernr  = lv_pernr
            iv_subtyp = lv_subty
            iv_config = lv_confg.
      catch cx_root.
        message 'DJTL goruntuleme hatasi' type 'S' display like 'W'.
    endtry.
  endmethod.


  method resolve_mapping.
    clear: ev_atip, ev_doc_type, ev_parser_class.
    ev_found = abap_false.
    select single djtl_atip, doc_type, parser_class
      from zrpd_edev_t_dtyp
      into (@ev_atip, @ev_doc_type, @ev_parser_class)
      where infotype = @iv_infty
        and active   = 'X'.
    if sy-subrc = 0.
      ev_found = abap_true.
    endif.
  endmethod.


  method set_itxex_0021.
    field-symbols <ls_0021> type p0021.
    assign (co_mp_p0021) to <ls_0021>.
    if sy-subrc = 0.
      <ls_0021>-itxex = 'X'.
    endif.
  endmethod.


  method set_itxex_0022.
    field-symbols <ls_0022> type p0022.
    assign (co_mp_p0022) to <ls_0022>.
    if sy-subrc = 0.
      <ls_0022>-itxex = 'X'.
    endif.
  endmethod.


  method tc_online_check.
    data ls_parm   type zcl_rpd_online_services=>ty_service_params.
    data lo_online type ref to zcl_rpd_online_services.
    data lv_year   type i.
    data lv_str    type string.
    data lx_root   type ref to cx_root.
    data lv_errtxt type string.
    data ls_msg    type bapiret2.
    ls_parm-merni = iv_merni.
    ls_parm-vorna = iv_vorna.
    ls_parm-nachn = iv_nachn.
    lv_str = iv_dogum_str.
    if strlen( lv_str ) = 10 and lv_str+2(1) ca './-'.
      lv_year = lv_str+6(4).
    elseif strlen( lv_str ) = 8.
      lv_year = lv_str(4).
    endif.
    ls_parm-gbdat = lv_year.
    try.
        create object lo_online exporting is_parm = ls_parm.
        lo_online->exec( importing et_messages = rt_messages ).
      catch cx_root into lx_root.
        clear rt_messages.
        lv_errtxt = lx_root->get_text( ).
        if strlen( lv_errtxt ) > 150.
          lv_errtxt = lv_errtxt(150).
        endif.
        clear ls_msg.
        ls_msg-type    = 'E'.
        ls_msg-id      = 'ZRPD_TC_MESSAGES'.
        ls_msg-number  = '000'.
        ls_msg-message = |TC kontrol servisine erisilemedi (SM59): { lv_errtxt }|.
        append ls_msg to rt_messages.
    endtry.
  endmethod.


  method transform_aile_vals.
    field-symbols <ls_val> type zrpd_edev_s_dcval.

    loop at ct_vals assigning <ls_val>.
      if <ls_val>-field_value is initial. continue. endif.
      case <ls_val>-field_name.
        when 'fasex'.
          case to_upper( <ls_val>-field_value ).
            when 'E' or 'ERKEK'. <ls_val>-field_value = '1'.
            when 'K' or 'KADIN'. <ls_val>-field_value = '2'.
          endcase.
      endcase.
    endloop.
  endmethod.


  method transform_ika_vals.
    data lv_plate type string.
    field-symbols <ls_val> type zrpd_edev_s_dcval.
    loop at ct_vals assigning <ls_val>.
      if <ls_val>-field_value is initial. continue. endif.
      if <ls_val>-field_name = 'blok'.
        <ls_val>-field_value = |{ <ls_val>-field_value } Blok|.
      elseif <ls_val>-field_name = 'il'.
        lv_plate = get_plate_code( <ls_val>-field_value ).
        if lv_plate is not initial.
          <ls_val>-field_value = lv_plate.
        else.
          clear <ls_val>-field_value.
        endif.
      endif.
    endloop.
  endmethod.


  method transform_mez_vals.
    data ls_val        type zrpd_edev_s_dcval.
    data lv_ausbi      type p0022-ausbi.
    data lv_sltp1      type p0022-sltp1.
    data lv_prog       type string.
    data lv_durum      type string.
    data lv_tmp        type string.
    data lv_slabs_code type p0022-slabs.
    field-symbols <ls_val> like ls_val.
    read table ct_vals assigning <ls_val> with key field_name = 'uni_metni'.
    if sy-subrc = 0 and <ls_val>-field_value is not initial.
      lv_tmp = <ls_val>-field_value.
      lv_ausbi = lookup_ausbi( iv_uni_metni = lv_tmp ).
      if lv_ausbi is not initial.
        clear ls_val.
        ls_val-field_name  = 'ausbi'.
        ls_val-field_value = lv_ausbi.
        append ls_val to ct_vals.
      else.
        message |Universite "{ lv_tmp }" T518B de bulunamadi, AUSBI bos birakildi| type 'S' display like 'W'.
      endif.
    endif.
    read table ct_vals assigning <ls_val> with key field_name = 'bolum_metni'.
    if sy-subrc = 0 and <ls_val>-field_value is not initial.
      lv_tmp = <ls_val>-field_value.
      lv_sltp1 = lookup_sltp1( iv_bolum_metni = lv_tmp ).
      if lv_sltp1 is not initial.
        clear ls_val.
        ls_val-field_name  = 'sltp1'.
        ls_val-field_value = lv_sltp1.
        append ls_val to ct_vals.
      else.
        message |Bolum "{ lv_tmp }" T517X de bulunamadi, SLTP1 bos birakildi| type 'S' display like 'W'.
      endif.
    endif.
    read table ct_vals assigning <ls_val> with key field_name = 'program_kademe'.
    if sy-subrc = 0.
      lv_prog = <ls_val>-field_value.
    endif.
    read table ct_vals assigning <ls_val> with key field_name = 'durum'.
    if sy-subrc = 0.
      lv_durum = <ls_val>-field_value.
    endif.
*
*
    if lv_prog is not initial and lv_durum is not initial.
      lv_slabs_code = lookup_slabs(
        iv_program_text = lv_prog
        iv_durum_text   = lv_durum ).
      if lv_slabs_code is not initial.
        clear ls_val.
        ls_val-field_name  = 'slabs'.
        ls_val-field_value = lv_slabs_code.
        append ls_val to ct_vals.
      else.
        message |SLABS bulunamadi (Program: "{ lv_prog }", Durum: "{ lv_durum }")| type 'S' display like 'W'.
      endif.
    endif.
  endmethod.


  method upload_from_edevlet.
    data lv_doc_type_const type zrpd_edev_de_dctyp.
    data lt_targets        type standard table of zrpd_edev_de_iflnm with empty key.
    data lv_target         type zrpd_edev_de_iflnm.
    data lv_any            type abap_bool.
    data lv_infty_filter   type infty.
    field-symbols <fs_val> type any.
    lv_doc_type_const = iv_doc_type.
    case gv_current_infty.
      when co_infty_0006.
        clear gs_pending.
        clear gv_has_pending.
        gs_pending-pernr = iv_pernr.
        process_p0006( changing cs_0006 = gs_pending ).
        lv_infty_filter = co_infty_0006.
      when co_infty_0022.
        clear gs_pending_0022.
        clear gv_has_pending.
        gs_pending_0022-pernr = iv_pernr.
        process_p0022( changing cs_0022 = gs_pending_0022 ).
        lv_infty_filter = co_infty_0022.
      when co_infty_0021.
        clear gs_pending_0021.
        clear gv_has_pending.
        gs_pending_0021-pernr = iv_pernr.
        gs_pending_0021-subty = gv_curr_subty.
        process_p0021( changing cs_0021 = gs_pending_0021 ).
        lv_infty_filter = co_infty_0021.
      when others.
        message 'Bu BT icin e-Devlet akisi tanimsiz' type 'S' display like 'W'.
        return.
    endcase.
    gv_pending_atip   = iv_atip.
    gv_pending_pernr  = iv_pernr.
    gv_pending_source = '01'.
    select distinct infotype_field
      from zrpd_edev_t_dmap
      into table @lt_targets
      where doc_type       = @lv_doc_type_const
        and infotype       = @lv_infty_filter
        and infotype_field <> @space.
    loop at lt_targets into lv_target.
      unassign <fs_val>.
      case gv_current_infty.
        when co_infty_0006.
          assign component lv_target of structure gs_pending to <fs_val>.
        when co_infty_0022.
          assign component lv_target of structure gs_pending_0022 to <fs_val>.
        when co_infty_0021.
          assign component lv_target of structure gs_pending_0021 to <fs_val>.
      endcase.
      if <fs_val> is assigned and <fs_val> is not initial.
        lv_any = abap_true.
        exit.
      endif.
    endloop.
    if lv_any = abap_true.
      gv_has_pending = abap_true.
      fill_pending_key( ).
      message 'Belge yuklendi, kaydetmek icin Save yapin' type 'S'.
    else.
      case gv_current_infty.
        when co_infty_0006.
          clear gs_pending.
        when co_infty_0022.
          clear gs_pending_0022.
        when co_infty_0021.
          clear gs_pending_0021.
      endcase.
    endif.
  endmethod.


  method upload_from_edevlet_0770.
    data lv_doc_type_const type zrpd_edev_de_dctyp.
    data lt_targets        type standard table of zrpd_edev_de_iflnm with empty key.
    data lv_target         type zrpd_edev_de_iflnm.
    data lv_any            type abap_bool.
    field-symbols <fs_val> type any.
    lv_doc_type_const = iv_doc_type.
    clear gs_pending_0770.
    clear gv_has_pending.
    gs_pending_0770-pernr = iv_pernr.
    process_p0770( changing cs_0770 = gs_pending_0770 ).
    gv_pending_atip   = iv_atip.
    gv_pending_pernr  = iv_pernr.
    gv_pending_source = '01'.
    select distinct infotype_field
      from zrpd_edev_t_dmap
      into table @lt_targets
      where doc_type       = @lv_doc_type_const
        and infotype       = @co_infty_0770
        and infotype_field <> @space.
    loop at lt_targets into lv_target.
      assign component lv_target of structure gs_pending_0770 to <fs_val>.
      if sy-subrc = 0 and <fs_val> is not initial.
        lv_any = abap_true.
        exit.
      endif.
    endloop.
    if lv_any = abap_true.
      gv_has_pending = abap_true.
      fill_pending_key( ).
      message 'Belge yuklendi, kaydetmek icin Save yapin' type 'S'.
    else.
      clear gs_pending_0770.
    endif.
  endmethod.


  method upload_from_file.
    data lt_file_table type filetable.
    data lv_rc         type i.
    data lv_filename   type string.
    data lt_rawtab     type table of char255.
    data lv_filelength type i.
    data lv_xstring    type xstring.
    data lo_base    type ref to zcl_zrpd_edev_doc_base.
    data lo_parser  type ref to zcl_zrpd_edev_doc_base.
    data lo_ocr     type ref to zcl_zrpd_edev_ocr_py.
    data lv_text    type string.
    data lv_upper   type string.
    data lt_vals    type zrpd_edev_tt_dcval.
    data lv_need_ocr type abap_bool.
    data lx_root    type ref to cx_root.
    data lv_errmsg  type string.
    data lv_parsed_barcode type string.
    field-symbols <ls_bc> type zrpd_edev_s_dcval.
    cl_gui_frontend_services=>file_open_dialog(
      exporting
        file_filter = 'PDF (*.pdf)|*.pdf|JPEG (*.jpg)|*.jpg|PNG (*.png)|*.png'
      changing
        file_table = lt_file_table
        rc         = lv_rc
      exceptions others = 5 ).
    if sy-subrc <> 0 or lv_rc < 1. return. endif.
    read table lt_file_table into lv_filename index 1.
    cl_gui_frontend_services=>gui_upload(
      exporting
        filename   = lv_filename
        filetype   = 'BIN'
      importing
        filelength = lv_filelength
      changing
        data_tab   = lt_rawtab
      exceptions others = 19 ).
    if sy-subrc <> 0. return. endif.
    call function 'SCMS_BINARY_TO_XSTRING'
      exporting
        input_length = lv_filelength
      importing
        buffer       = lv_xstring
      tables
        binary_tab   = lt_rawtab
      exceptions others = 2.
    if sy-subrc <> 0.
      message 'Dosya donusturme hatasi' type 'S' display like 'E'.
      return.
    endif.
    if iv_parser is not initial and iv_infty is not initial.
      try.
          create object lo_base type (iv_parser).
          lv_text = lo_base->pdf_to_text( lv_xstring ).
          lv_upper = to_upper( lv_text ).
          case iv_doc_type.
            when 'IKAMETGAH'.
              if lv_text is initial or
                 ( lv_upper ns 'KIMLIK' and lv_upper ns 'YERLESIM' and lv_upper ns 'ADRES' ).
                lv_need_ocr = abap_true.
              endif.
            when 'MEZUNIYET'.
              if lv_text is initial or lv_upper ns 'MEZUN'.
                lv_need_ocr = abap_true.
              endif.
            when 'KIMLIK'.
              if lv_text is initial or lv_upper ns 'KIMLIK'.
                lv_need_ocr = abap_true.
              endif.
            when others.
              if lv_text is initial.
                lv_need_ocr = abap_true.
              endif.
          endcase.
          if lv_need_ocr = abap_true.
            create object lo_ocr.
            lv_text = lo_ocr->extract_text( lv_xstring ).
          endif.
          create object lo_parser type (iv_parser).
          lt_vals = lo_parser->parse_fields( lv_text ).
          case iv_doc_type.
            when 'IKAMETGAH'. transform_ika_vals( changing ct_vals = lt_vals ).
            when 'MEZUNIYET'. transform_mez_vals( changing ct_vals = lt_vals ).
          endcase.
          case iv_infty.
            when co_infty_0006.
              apply_vals_to_p0006( it_vals = lt_vals ).
            when co_infty_0022.
              apply_vals_to_0022( it_vals = lt_vals ).
              gs_pending_0022-sland = 'TR'.
            when co_infty_0770.
              apply_vals_to_p0770( it_vals = lt_vals ).
            when co_infty_0021.
              apply_vals_to_p0021( it_vals = lt_vals ).
          endcase.
          read table lt_vals assigning <ls_bc>
            with key field_name = 'barkod'.
          if sy-subrc = 0.
            lv_parsed_barcode = <ls_bc>-field_value.
          endif.
        catch cx_root into lx_root.
          lv_errmsg = lx_root->get_text( ).
          if strlen( lv_errmsg ) > 200.
            lv_errmsg = lv_errmsg(200).
          endif.
          message |Parse hatasi: { lv_errmsg }| type 'S' display like 'W'.
      endtry.
    endif.
    gv_pending_file   = lv_xstring.
    gv_pending_atip   = iv_atip.
    gv_pending_pernr  = iv_pernr.
    gv_pending_source = '00'.
    if lv_parsed_barcode is not initial.
      gv_pending_config = lv_parsed_barcode.
    else.
      gv_pending_config = generate_confg_id( ).
    endif.
    fill_pending_key( ).
    message 'Dosya yuklendi, kaydetmek icin Save yapin' type 'S'.
  endmethod.


  method upload_from_file_0770.
    data lt_file_table type filetable.
    data lv_rc         type i.
    data lv_filename   type string.
    data lt_rawtab     type table of char255.
    data lv_filelength type i.
    data lv_xstring    type xstring.
    data lo_base       type ref to zcl_zrpd_edev_doc_base.
    data lo_ocr        type ref to zcl_zrpd_edev_ocr_py.
    data lo_parser     type ref to zcl_zrpd_edev_doc_base.
    data lv_text       type string.
    data lv_upper      type string.
    data lt_vals       type zrpd_edev_tt_dcval.
    data ls_val        type zrpd_edev_s_dcval.
    data lv_merni      type ptr_merni.
    data lv_vorna      type vorna.
    data lv_nachn      type nachn.
    data lv_dogum_str  type string.
    data lt_messages   type bapiret2_t.
    data ls_message    type bapiret2.
    data lv_subty      type subty.
    field-symbols <fs_subty> type any.
    data lt_targets    type standard table of zrpd_edev_de_iflnm with empty key.
    data lv_target     type zrpd_edev_de_iflnm.
    data lv_any        type abap_bool.
    data: begin of ls_map,
            field_name     type zrpd_edev_de_fldnm,
            infotype_field type zrpd_edev_de_iflnm,
          end of ls_map.
    data lt_map like sorted table of ls_map with unique key field_name.
    data lv_fn         type zrpd_edev_de_fldnm.
    data lx_root       type ref to cx_root.
    data lv_errmsg     type string.
    field-symbols <fs_val> type any.
    field-symbols <ls_map> like ls_map.
    cl_gui_frontend_services=>file_open_dialog(
      exporting
        file_filter = 'PDF (*.pdf)|*.pdf|JPEG (*.jpg)|*.jpg|PNG (*.png)|*.png'
      changing
        file_table = lt_file_table
        rc         = lv_rc
      exceptions others = 5 ).
    if sy-subrc <> 0 or lv_rc < 1. return. endif.
    read table lt_file_table into lv_filename index 1.
    cl_gui_frontend_services=>gui_upload(
      exporting
        filename   = lv_filename
        filetype   = 'BIN'
      importing
        filelength = lv_filelength
      changing
        data_tab   = lt_rawtab
      exceptions others = 19 ).
    if sy-subrc <> 0. return. endif.
    call function 'SCMS_BINARY_TO_XSTRING'
      exporting
        input_length = lv_filelength
      importing
        buffer       = lv_xstring
      tables
        binary_tab   = lt_rawtab
      exceptions others = 2.
    if sy-subrc <> 0.
      message 'Dosya donusturme hatasi' type 'S' display like 'E'.
      return.
    endif.
    try.
        create object lo_base type zcl_zrpd_edev_doc_kim.
        lv_text = lo_base->pdf_to_text( lv_xstring ).
        lv_upper = to_upper( lv_text ).
        if lv_text is initial
          or ( lv_upper ns 'KIMLIK' and lv_upper ns 'NUFUS' ).
          create object lo_ocr.
          lv_text = lo_ocr->extract_text( lv_xstring ).
        endif.
        create object lo_parser type zcl_zrpd_edev_doc_kim.
        lt_vals = lo_parser->parse_fields( lv_text ).
      catch cx_root into lx_root.
        lv_errmsg = lx_root->get_text( ).
        if strlen( lv_errmsg ) > 200. lv_errmsg = lv_errmsg(200). endif.
        message lv_errmsg type 'S' display like 'E'.
        return.
    endtry.
    if lt_vals is initial.
      message 'Belgeden alan cikarilamadi' type 'S' display like 'W'.
      return.
    endif.
    assign ('(SAPFP50M)PSPAR-SUBTY') to <fs_subty>.
    if sy-subrc = 0.
      lv_subty = <fs_subty>.
    endif.
    data lv_parsed_barcode type string.
    read table lt_vals into ls_val with key field_name = 'barkod'.
    if sy-subrc = 0.
      lv_parsed_barcode = ls_val-field_value.
    endif.
    data lv_client_category type t000-cccategory.
    select single cccategory
      from t000
      where mandt = @sy-mandt
      into @lv_client_category.
    if sy-subrc <> 0.
      clear lv_client_category.
    endif.
    if lv_subty = '01' and lv_client_category = 'P'.
      loop at lt_vals into ls_val.
        case ls_val-field_name.
          when 'tc_kimlik_no'. lv_merni = ls_val-field_value.
          when 'ad'.           lv_vorna = ls_val-field_value.
          when 'soyad'.        lv_nachn = ls_val-field_value.
          when 'dogum_tarihi'. lv_dogum_str = ls_val-field_value.
        endcase.
      endloop.
      if lv_merni is initial or lv_vorna is initial or lv_nachn is initial.
        message 'Kimlik PDF: TC/Ad/Soyad alinamadi' type 'S' display like 'E'.
        return.
      endif.
      lt_messages = tc_online_check(
        iv_merni     = lv_merni
        iv_vorna     = lv_vorna
        iv_nachn     = lv_nachn
        iv_dogum_str = lv_dogum_str ).
      read table lt_messages into ls_message with key type = 'E'.
      if sy-subrc = 0.
        if ls_message-message is not initial.
          message ls_message-message type 'S' display like 'E'.
        else.
          message id ls_message-id type 'S' number ls_message-number
            with ls_message-message_v1 ls_message-message_v2
                 ls_message-message_v3 ls_message-message_v4
            display like 'E'.
        endif.
        return.
      endif.
    endif.
    clear gs_pending_0770.
    clear gv_has_pending.
    gs_pending_0770-pernr = iv_pernr.
    select field_name, infotype_field
      from zrpd_edev_t_dmap
      where doc_type       = @iv_doc_type
        and infotype       = @co_infty_0770
        and infotype_field <> @space
      into corresponding fields of table @lt_map.
    if sy-subrc <> 0. lt_map = value #( ). endif.
    loop at lt_vals into ls_val.
      if ls_val-field_value is initial. continue. endif.
      lv_fn = ls_val-field_name.
      translate lv_fn to lower case.
      read table lt_map assigning <ls_map> with table key field_name = lv_fn.
      if sy-subrc <> 0 or <ls_map>-infotype_field is initial. continue. endif.
      assign component <ls_map>-infotype_field of structure gs_pending_0770 to <fs_val>.
      if sy-subrc = 0.
        <fs_val> = ls_val-field_value.
      endif.
    endloop.
    gv_pending_file   = lv_xstring.
    gv_pending_atip   = iv_atip.
    gv_pending_pernr  = iv_pernr.
    gv_pending_source = '00'.
    if lv_merni is not initial.
      gv_pending_config = lv_merni.
    else.
      gv_pending_config = generate_confg_id( ).
    endif.
    select distinct infotype_field
      from zrpd_edev_t_dmap
      into table @lt_targets
      where doc_type       = @iv_doc_type
        and infotype       = @co_infty_0770
        and infotype_field <> @space.
    loop at lt_targets into lv_target.
      assign component lv_target of structure gs_pending_0770 to <fs_val>.
      if sy-subrc = 0 and <fs_val> is not initial.
        lv_any = abap_true.
        exit.
      endif.
    endloop.
    if lv_any = abap_true.
      gv_has_pending = abap_true.
      fill_pending_key( ).
      message 'Belge yuklendi, kaydetmek icin Save yapin' type 'S'.
    else.
      clear gs_pending_0770.
      clear: gv_pending_file, gv_pending_atip, gv_pending_config.
    endif.
  endmethod.


  method validate_tc_against_master.
    data ls_par type p0002.
    data ls_msg type bapiret2.
    select single vorna, nachn, gbdat
      from pa0002
      into corresponding fields of @ls_par
     where pernr eq @iv_pernr
       and begda le @sy-datum
       and endda ge @sy-datum.
    if sy-subrc <> 0.
      clear ls_msg.
      ls_msg-type    = 'E'.
      ls_msg-id      = 'ZRPD_TC_MESSAGES'.
      ls_msg-number  = '000'.
      ls_msg-message = |PERNR { iv_pernr }: PA0002 master kaydi bulunamadi|.
      append ls_msg to rt_messages.
      return.
    endif.
    data lv_dogum_str type string.
    data lv_vorna_p   type vorna.
    data lv_nachn_p   type nachn.
    lv_dogum_str = ls_par-gbdat(4).
    lv_vorna_p   = ls_par-vorna.
    lv_nachn_p   = ls_par-nachn.
    rt_messages = tc_online_check(
      iv_merni     = iv_merni
      iv_vorna     = lv_vorna_p
      iv_nachn     = lv_nachn_p
      iv_dogum_str = lv_dogum_str ).
  endmethod.
ENDCLASS.
