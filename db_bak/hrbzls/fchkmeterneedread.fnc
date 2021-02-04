CREATE OR REPLACE FUNCTION HRBZLS."FCHKMETERNEEDREAD"
   (vmiid IN VARCHAR2)
   Return CHAR
AS
   lret       char(1);
   vmistatus  METERINFO.Mistatus%type;
   vmitype    METERINFO.Mitype%type;
   vmiifsl    METERINFO.Miifsl%type;
   vmiifchk   METERINFO.miifchk%type;
   mi         meterinfo%rowtype;
BEGIN
   SELECT Mistatus,nvl(Mitype,'1'),Miifsl,NVL(miifchk,'N')
     INTO vmistatus,vmitype,vmiifsl,vmiifchk
     FROM METERINFO
    WHERE MIID=vmiid;
   --�ǳ������͵ı�״̬ˮ����
   --
/*   IF vmiifchk ='Y' THEN
      return 'N';  --add 20141121 HB ���������������ɳ���ƻ�
   END IF ;
   */
   select SMSMEMO into lret from sysmeterstatus where smsid=vmistatus;
   if lret='N' then
      return 'N';
   end if;
   --�ǳ������͵ı�����ˮ����
   select smtifread into lret from sysmetertype where smtid=vmitype;
   if lret='N' then
      return 'N';
   end if;
   --һ��໧�ֱ�ˮ���� zhb
   select * into mi from meterinfo where miid=vmiid;
   if mi.micolumn9='Y' and mi.micode <> mi.mipriid  then
      return 'N';
   end if;

   Return 'Y';
exception

WHEN OTHERS THEN
   Return 'N';
END;
/

