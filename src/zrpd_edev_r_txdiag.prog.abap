report zrpd_edev_r_txdiag.

parameters p_pernr type pernr-pernr obligatory.
parameters p_infty type infty default '0006'.

" -----------------------------------------------------------------------
" Tipler
" -----------------------------------------------------------------------
types: begin of ty_pa0006_key,
         pernr type pa0006-pernr,
         subty type pa0006-subty,
         objps type pa0006-objps,
         sprps type pa0006-sprps,
         endda type pa0006-endda,
         begda type pa0006-begda,
         seqnr type pa0006-seqnr,
       end of ty_pa0006_key.

types: begin of ty_pcl1_result,
         pcl1_id    type char38,
         version    type x,
         line_count type i,
         first_line type char50,
       end of ty_pcl1_result.

" -----------------------------------------------------------------------
" Degiskenler (definitions_top kurali)
" -----------------------------------------------------------------------
data lt_stxh     type standard table of stxh with non-unique key tdobject tdid tdname tdspras.
data lv_pattern  type stxh-tdname.
data lv_pernr8   type char8.
data lo_salv     type ref to cl_salv_table.
data ls_t582a    type t582a.
data lt_pa0006   type standard table of ty_pa0006_key.
data lt_pcl1_res type standard table of ty_pcl1_result.
data ls_pcl1_res type ty_pcl1_result.
data lv_key      type char38.
data lv_cnt      type i.

data: begin of ls_text,
        version type x value '00',
      end of ls_text.
data: begin of ls_ptext_row,
        line(78) type c,
      end of ls_ptext_row.
data lt_ptext like standard table of ls_ptext_row.

data lv_c_pernr  type char8.
data lv_c_subty  type char4.
data lv_c_objps  type char2.
data lv_c_sprps  type char1.
data lv_c_endda  type char8.
data lv_c_begda  type char8.
data lv_c_seqnr  type char3.

field-symbols <ls_pa>  type ty_pa0006_key.
field-symbols <ls_res> type ty_pcl1_result.

" -----------------------------------------------------------------------
start-of-selection.
" -----------------------------------------------------------------------

  " === STXH (SAPscript text) ===
  write / '=== STXH (SAPscript text) ===' color col_heading.
  uline.

  lv_pernr8 = p_pernr.
  concatenate lv_pernr8 '%' into lv_pattern.

  select tdobject, tdid, tdname, tdspras, tdluser, tdldate, tdltime
    from stxh
    where tdname like @lv_pattern
    order by tdobject, tdid, tdname, tdspras
    into corresponding fields of table @lt_stxh.

  lv_cnt = lines( lt_stxh ).
  write / 'STXH kayit sayisi:'.
  write lv_cnt.
  uline.

  if lt_stxh is not initial.
    cl_salv_table=>factory(
      importing r_salv_table = lo_salv
      changing  t_table      = lt_stxh ).
    lo_salv->get_columns( )->set_optimize( abap_true ).
    lo_salv->display( ).
  else.
    write / 'Bu PERNR icin STXH kaydi bulunamadi.' color col_negative.
  endif.

  " === T582A (Infotype text config) ===
  uline.
  write / '=== T582A (Infotype text config) ===' color col_heading.
  uline.

  select single inftx, dhdid, dname
    from t582a
    where infty = @p_infty
    into corresponding fields of @ls_t582a.
  if sy-subrc = 0.
    write / 'T582A - Infotype:'.
    write p_infty.
    write / '  INFTX (long text flag) :'.
    write ls_t582a-inftx.
    write / '  DHDID (text id)        :'.
    write ls_t582a-dhdid.
    write / '  DNAME (screen name)    :'.
    write ls_t582a-dname.
  else.
    write / 'T582A: Infotype' color col_negative.
    write p_infty color col_negative.
    write 'icin kayit bulunamadi.' color col_negative.
  endif.

  " === PCL1 RELID=TX (HR cluster text) ===
  uline.
  write / '=== PCL1 RELID=TX (HR cluster text) ===' color col_heading.
  uline.

  select pernr, subty, objps, sprps, endda, begda, seqnr
    from pa0006
    where pernr = @p_pernr
    order by pernr, subty, objps, sprps, endda, begda, seqnr
    into corresponding fields of table @lt_pa0006.

  if lt_pa0006 is initial.
    write / 'PA0006: Bu PERNR icin kayit bulunamadi.' color col_negative.
  else.
    lv_cnt = lines( lt_pa0006 ).
    write / 'PA0006 kayit sayisi:'.
    write lv_cnt.

    loop at lt_pa0006 assigning <ls_pa>.
      lv_c_pernr = <ls_pa>-pernr.
      lv_c_subty = <ls_pa>-subty.
      lv_c_objps = <ls_pa>-objps.
      lv_c_sprps = <ls_pa>-sprps.
      lv_c_endda = <ls_pa>-endda.
      lv_c_begda = <ls_pa>-begda.
      lv_c_seqnr = <ls_pa>-seqnr.

      " 38-char PSKEY: pernr8 + infty4 + subty4 + objps2 + sprps1 + endda8 + begda8 + seqnr3
      concatenate lv_c_pernr '0006' lv_c_subty lv_c_objps lv_c_sprps
                  lv_c_endda lv_c_begda lv_c_seqnr
        into lv_key respecting blanks.

      clear lt_ptext.
      clear ls_text.

      import text-version = ls_text-version
             ptext        = lt_ptext
        from database pcl1(tx) id lv_key.

      if sy-subrc = 0.
        clear ls_pcl1_res.
        ls_pcl1_res-pcl1_id    = lv_key.
        ls_pcl1_res-version    = ls_text-version.
        ls_pcl1_res-line_count = lines( lt_ptext ).

        read table lt_ptext index 1 into ls_ptext_row.
        if sy-subrc = 0.
          ls_pcl1_res-first_line = ls_ptext_row-line(50).
        endif.

        append ls_pcl1_res to lt_pcl1_res.
      endif.
    endloop.

    if lt_pcl1_res is initial.
      write / 'PCL1(TX): Hicbir PSKEY icin kayit bulunamadi.' color col_negative.
    else.
      lv_cnt = lines( lt_pcl1_res ).
      write / 'PCL1(TX) bulunan kayit sayisi:'.
      write lv_cnt.
      uline.
      write / 'PCL1_ID(38)' color col_heading.
      uline.
      loop at lt_pcl1_res assigning <ls_res>.
        write / <ls_res>-pcl1_id.
        write <ls_res>-version.
        write <ls_res>-line_count.
        write <ls_res>-first_line.
      endloop.
    endif.
  endif.
