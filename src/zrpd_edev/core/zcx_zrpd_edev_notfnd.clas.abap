class zcx_zrpd_edev_notfnd definition public
  inheriting from zcx_zrpd_edev_base create public.

  public section.

    methods constructor
      importing
        textid   like textid optional
        previous like previous optional
        mv_msgv1 type symsgv optional
        mv_msgv2 type symsgv optional
        mv_msgv3 type symsgv optional
        mv_msgv4 type symsgv optional.

endclass.

class zcx_zrpd_edev_notfnd implementation.

  method constructor.
    super->constructor(
      textid   = textid
      previous = previous
      mv_msgv1 = mv_msgv1
      mv_msgv2 = mv_msgv2
      mv_msgv3 = mv_msgv3
      mv_msgv4 = mv_msgv4 ).
  endmethod.

endclass.
