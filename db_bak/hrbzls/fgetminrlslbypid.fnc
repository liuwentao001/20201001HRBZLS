CREATE OR REPLACE FUNCTION HRBZLS."FGETMINRLSLBYPID" (p_pid in varchar2 )
  RETURN VARCHAR2
AS
  lret VARCHAR2(40);
BEGIN
   select sum(rlsl) into lret
  from payment t, paidlist t1, reclist t2
 where t.pid = plpid
   and rlid = plrlid
   and pid=p_pid ;
   return lret;
exception when others then
   return null;
END;
/

