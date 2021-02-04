CREATE OR REPLACE FUNCTION HRBZLS."FGETBANKTSMEMO" (p_rdid in varchar2 )
  RETURN VARCHAR2
AS
  lret     VARCHAR2(1000);
  v_str    varchar2(1000);
  v_dj    varchar2(1000);
  v_sl     varchar2(1000);
  cursor c_ctp is
    SELECT  fgetpriceitem(t.rdpiid)||':' ||tools.fformatnum((sum(t.RDJE)),2) ||'元'
      FROM recdetail t
     WHERE T.Rdid=p_rdid
     group by t.rdpiid
     ORDER BY t.rdpiid;
BEGIN
 select '均价' || ':' || tools.fformatnum((sum(t.RDYSDJ)), 3) || '元'||' ',
        '水量' || ':' || tools.fformatnum((max(t.RDSL)), 0) || '吨'||''
        into v_dj,v_sl
    FROM recdetail t
  WHERE T.Rdid = p_rdid;
    open c_ctp;
    loop
      fetch c_ctp
        into v_str;
      exit when c_ctp%notfound or c_ctp%notfound is null;
        lret := lret || v_str||' ' ;
       end loop;
    close c_ctp;

  lret:=lret||v_dj||v_sl;

   Return lret;
exception when others then
   return null;
END;
/

