CREATE OR REPLACE PROCEDURE HRBZLS."SP_METERINFOSEARCH" (p_bfid in varchar2,
                  o_base out tools.out_base) is
  begin

    open o_base for
      SELECT t1.miid,t1.miadr  from   meterinfo t1 where t1.mibfid =p_bfid
    ;

  end ;
/

