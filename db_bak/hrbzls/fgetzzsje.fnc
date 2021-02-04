CREATE OR REPLACE FUNCTION HRBZLS."FGETZZSJE" (p_rlid in varchar2 ) --应收流水
  RETURN VARCHAR2          --返回费用明细，不带01费用项目
AS
v_ret varchar2(2000);      --返回值

BEGIN
      select    tools.fformatnum(sum(case when mibox=1 and (rdpfid like '%B%' or rdpfid like '%C%') then decode(rdpiid,'01',0,rdje)
                when mibox=2 and rdpfid like '%B%' then decode(rdpiid,'01',0,rdje)
                when mibox=3 and rdpfid like '%C%' then decode(rdpiid,'01',0,rdje) else rdje end),2)
      into  v_ret
         from recdetail,reclist,meterinfo
       where (rdpiid<>'04'  and  rdpiid<>'05')
             and rlid=rdid and rlmid=miid and rlgroup<>3
             and rdid=p_rlid ;
   if  v_ret ='-' then
      v_ret :='0.00';
   end if;
   return v_ret;
    EXCEPTION
  WHEN OTHERS THEN
    Return '0.00';
END;
/

