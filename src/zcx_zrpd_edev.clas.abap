class zcx_zrpd_edev definition public
  inheriting from cx_static_check create public.

  public section.

    methods constructor
      importing
        textid   like textid optional
        previous like previous optional
        mv_msgv1 type symsgv optional
        mv_msgv2 type symsgv optional
        mv_msgv3 type symsgv optional
        mv_msgv4 type symsgv optional.

    data mv_msgv1 type symsgv read-only.
    data mv_msgv2 type symsgv read-only.
    data mv_msgv3 type symsgv read-only.
    data mv_msgv4 type symsgv read-only.

endclass.

class zcx_zrpd_edev implementation.

  method constructor ##ADT_SUPPRESS_GENERATION.
    super->constructor(
      textid   = textid
      previous = previous ).
    me->mv_msgv1 = mv_msgv1.
    me->mv_msgv2 = mv_msgv2.
    me->mv_msgv3 = mv_msgv3.
    me->mv_msgv4 = mv_msgv4.
  endmethod.

endclass.
