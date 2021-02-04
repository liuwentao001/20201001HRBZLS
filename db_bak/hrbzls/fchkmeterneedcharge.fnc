CREATE OR REPLACE FUNCTION HRBZLS."FCHKMETERNEEDCHARGE"
   (vmstatus IN VARCHAR2,
    vifchk IN VARCHAR2,
    vmtype IN VARCHAR2)
   Return CHAR
AS
   lret char(1);
BEGIN
  --����������20140306 ������������������ѣ��ƻ��ڳ���׷�����ڹ���������Ͳ��������״̬���û���������
   /*if vmstatus='7' then
      return 'N';
   end if;*/
   if vifchk='Y' then
      return 'N';
   end if;
   select smtifcharge into lret from sysmetertype where smtid=vmtype;
   if lret='N' then
      return 'N';
   end if;

   Return 'Y';
exception WHEN OTHERS THEN
   Return 'N';
END;
/

