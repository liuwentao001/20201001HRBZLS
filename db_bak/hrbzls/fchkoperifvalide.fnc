CREATE OR REPLACE FUNCTION HRBZLS."FCHKOPERIFVALIDE"
   (voaid IN VARCHAR2)
   Return varchar2
AS
   lret varchar2(10);
BEGIN
select
  oaislogin into lret
  from operaccnt
  where oaid=voaid;
   Return lret;
exception

WHEN OTHERS THEN
   Return null;
END;
/

