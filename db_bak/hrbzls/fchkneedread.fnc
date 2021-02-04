CREATE OR REPLACE FUNCTION HRBZLS."FCHKNEEDREAD"
   (p_mistatus IN VARCHAR2,p_mitype IN VARCHAR2)
   Return CHAR
AS
   lret char(1);
BEGIN
   --�ǳ������͵ı�״̬ˮ����
   select SMSMEMO into lret from sysmeterstatus where smsid=p_mistatus;
   if lret='N' then
      return 'N';
   end if;
   --�ǳ������͵ı�����ˮ����
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

