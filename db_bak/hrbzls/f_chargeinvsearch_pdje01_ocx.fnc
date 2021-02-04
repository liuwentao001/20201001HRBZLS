CREATE OR REPLACE FUNCTION HRBZLS."F_CHARGEINVSEARCH_PDJE01_OCX" (p_plid in varchar2,p_typd in varchar2 )
  RETURN varchar2 AS
  LCODE VARCHAR2(4000);
BEGIN

if p_typd=1 then --实收批次
select
tools.fformatnum( nvl(sum(pdje),0),2)  into LCODE
  from   paidlist t1, paiddetail t2,PAYMENT T3,meterinfo t4
   where
      pid=p_plid
     AND PID=PLPID
     and plid = pdid
     and pmid=miid
     and  MIIFTAX='Y'
     and pdpiid='01'
    ;

END IF;
  RETURN LCODE;
EXCEPTION
  WHEN OTHERS THEN
    RETURN LCODE;
END;
/

