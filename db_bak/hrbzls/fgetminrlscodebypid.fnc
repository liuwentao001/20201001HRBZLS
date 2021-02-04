CREATE OR REPLACE FUNCTION HRBZLS."FGETMINRLSCODEBYPID" (p_pid in varchar2 )
  RETURN VARCHAR2
AS
  lret VARCHAR2(40);
BEGIN
   select FIRST_VALUE(rlscode) over(partition by pid order by rlmonth desc)
into lret
 from payment t, paidlist t1, reclist t2
 where t.pid = plpid
   and rlid = plrlid
   and pid=p_pid ;
exception when others then
   return null;
END;
/

