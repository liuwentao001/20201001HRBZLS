CREATE OR REPLACE FUNCTION HRBZLS."F_CHARGEINVSEARCH_RECMX_OCX_TS" (p_plid in varchar2,p_pmid in varchar2,p_typd in varchar2 )
  RETURN varchar2 AS
  LCODE VARCHAR2(4000);
BEGIN
if p_typd=1 then --实收明细PLID
  select replace(connstr(rpad(FGETPRICEFRAME_jh(rdpfid), 15, ' ') ||
                         rpad(sum(case when rdpiid='01' then rdsl else 0 end), 15, ' ') ||
                         rpad(tools.fformatnum(sum(rddj),2), 15, ' ') ||
                         rpad(tools.fformatnum(sum(CASE WHEN MIIFTAX='Y' AND rdpiid='01'  THEN  0   ELSE rdje END),2), 15, ' ')),
                 '/',
                 chr(13))||chr(13) into LCODE
    from recdetail t, paidlist t1, paiddetail t2,payment t3,meterinfo t4
   where plid = p_plid
     and plrlid = rdid
     and plid = pdid
     and rdpiid = pdpiid
     and pid=plpid
     and pmid=miid
   group by rdpfid;
ELSif p_typd=2 then --实收批次



select
replace(connstr(rpad(FGETPRICEFRAME_jh(rdpfid), 15, ' ') ||
                         rpad(sum(rdsl), 15, ' ') ||
                         rpad(tools.fformatnum(max(rddj),2), 15, ' ') ||
                         rpad(tools.fformatnum(sum(rdje),2), 15, ' ')),
                 '/',
                 chr(13))||chr(13) into LCODE

from (
select rdpfid,
sum(case when rdpiid='01' then rdsl else 0 end) rdsl  ,
sum(rddj) rddj,
 sum(CASE WHEN MIIFTAX='Y' AND rdpiid='01'  THEN   0  ELSE rdje END) rdje
  from recdetail t, paidlist t1, paiddetail t2,PAYMENT T3,meterinfo t4
   where
      PBATCH=p_plid
     AND PID=PLPID
     and plrlid = rdid
     and plid = pdid
     and rdpiid = pdpiid
     and pmid=miid
   group by rdid,rdpfid
   ) group by rdpfid ;


/*select replace(connstr(rpad(FGETPRICEFRAME_jh(rdpfid), 20, ' ') ||
                         rpad(sum(case when rdpiid='01' then rdsl else 0 end), 20, ' ') ||
                         rpad(sum(rddj), 20, ' ') ||
                         rpad(sum(CASE WHEN MIIFTAX='Y' AND rdpiid='01'  THEN   0  ELSE rdje END), 20, ' ')),
                 '/',
                 chr(13))||chr(13) into LCODE
    from recdetail t, paidlist t1, paiddetail t2,PAYMENT T3,meterinfo t4
   where
      PBATCH=p_plid
     AND PID=PLPID
     and plrlid = rdid
     and plid = pdid
     and rdpiid = pdpiid
     and pmid=miid
   group by rdpfid;*/


ELSif p_typd=3 then --实收批次

select
replace(connstr(rpad(FGETPRICEFRAME_jh(rdpfid), 15, ' ') ||
                         rpad(sum(rdsl), 15, ' ') ||
                         rpad(tools.fformatnum(max(rddj),2), 15, ' ') ||
                         rpad(tools.fformatnum(sum(rdje),2), 15, ' ')),
                 '/',
                 chr(13))||chr(13) into LCODE

from (
select rdpfid,
sum(case when rdpiid='01' then rdsl else 0 end) rdsl  ,
sum(rddj) rddj,
sum(CASE WHEN MIIFTAX='Y' AND rdpiid='01'  THEN   0  ELSE rdje END) rdje
  from recdetail t, paidlist t1, paiddetail t2,PAYMENT T3,meterinfo t4
   where
      pbatch=p_plid
     and pmid=p_pmid
     AND PID=PLPID
     and plrlid = rdid
     and plid = pdid
     and rdpiid = pdpiid
     and pmid=miid
   group by rdid,rdpfid
   ) group by rdpfid ;


/*select replace(connstr(rpad(FGETPRICEFRAME_jh(rdpfid), 20, ' ') ||
                         rpad(sum(case when rdpiid='01' then rdsl else 0 end), 20, ' ') ||
                         rpad(sum(rddj), 20, ' ') ||
                         rpad(sum(CASE WHEN MIIFTAX='Y' AND rdpiid='01'  THEN   0  ELSE rdje END), 20, ' ')),
                 '/',
                 chr(13))||chr(13) into LCODE
    from recdetail t, paidlist t1, paiddetail t2,PAYMENT T3,meterinfo t4
   where
      pid=p_plid
     AND PID=PLPID
     and plrlid = rdid
     and plid = pdid
     and rdpiid = pdpiid
     and pmid=miid
   group by rdpfid;  */
 ELSif p_typd=4 then --实收批次

select
replace(connstr(rpad(FGETPRICEFRAME_jh(rdpfid), 15, ' ') ||
                         rpad(sum(rdsl), 15, ' ') ||
                         rpad(tools.fformatnum(max(rddj),2), 10, ' ') ||
                         rpad(tools.fformatnum(sum(rdje),2), 15, ' ')),
                 '/',
                 chr(13))||chr(13) into LCODE

from (
select rdpfid,
sum(case when rdpiid='01' then rdsl else 0 end) rdsl  ,
sum(rddj) rddj,
sum(CASE WHEN MIIFTAX='Y' AND rdpiid='01'  THEN   0  ELSE rdje END) rdje
  from recdetail t, reclist t1 ,meterinfo t4
   where
      rlid=p_plid
     and  rlid=rdid
     and rlmid=miid
   group by rdid,rdpfid
   ) group by rdpfid ;
END IF;
  RETURN LCODE;
EXCEPTION
  WHEN OTHERS THEN
    RETURN LCODE;
END;
/

