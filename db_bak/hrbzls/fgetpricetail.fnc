CREATE OR REPLACE FUNCTION HRBZLS."FGETPRICETAIL" (p_miid in varchar2 )
  RETURN VARCHAR2
AS
  lret     VARCHAR2(1000);
  v_str    varchar2(1000);
  cursor c_ctp is
    SELECT (case when MIIFMP='N' THEN FGETPRICEFRAME(T2.MIPFID) ELSE   FGETPRICEFRAME(T3.PMDPFID)||':'|| PMDSCALE *100||'%'  END)
      FROM  meterinfo t2,PRICEMULTIDETAIL t3
    WHERE T2.MIID = T3.PMDMID(+)
    AND T2.MIID=p_miid;
BEGIN

    open c_ctp;
    loop
      fetch c_ctp
        into v_str;
      exit when c_ctp%notfound or c_ctp%notfound is null;
        lret := lret || v_str||' ' ;
       end loop;
    close c_ctp;


   Return lret;
exception when others then
   return null;
END;
/

