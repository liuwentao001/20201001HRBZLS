CREATE OR REPLACE FUNCTION HRBZLS."FCHKNEEDREAD"
   (p_mistatus IN VARCHAR2,p_mitype IN VARCHAR2)
   Return CHAR
AS
   lret char(1);
BEGIN
   --非抄表类型的表状态水表不抄
   select SMSMEMO into lret from sysmeterstatus where smsid=p_mistatus;
   if lret='N' then
      return 'N';
   end if;
   --非抄表类型的表类型水表不抄
   select smtifread into lret from sysmetertype where smtid=p_mitype;
   if lret='N' then
      return 'N';
   end if;

   Return 'Y';
exception

WHEN OTHERS THEN
   Return 'N';
END;
/

