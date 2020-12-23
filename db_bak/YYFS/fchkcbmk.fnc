CREATE OR REPLACE FUNCTION FCHKCBMK
   (vmiid IN VARCHAR2)
   Return CHAR
AS
   lret       char(1);
   /*vmistatus  METERINFO.Mistatus%type;
   vmitype    METERINFO.Mitype%type;
   vmiifsl    METERINFO.Miifsl%type;
   vmiifchk   METERINFO.miifchk%type;
   mi         meterinfo%rowtype;*/
BEGIN
   /*SELECT Mistatus,nvl(Mitype,'1'),Miifsl,NVL(miifchk,'N')
     INTO vmistatus,vmitype,vmiifsl,vmiifchk
     FROM METERINFO
    WHERE MIID=vmiid;
   --非抄表类型的表状态水表不抄
   --
\*   IF vmiifchk ='Y' THEN
      return 'N';  --add 20141121 HB 哈尔滨计量表不生成抄表计划
   END IF ;
   *\
   select SMSMEMO into lret from sysmeterstatus where smsid=vmistatus;
   if lret='N' then
      return 'N';
   end if;
   --非抄表类型的表类型水表不抄
   select smtifread into lret from sysmetertype where smtid=vmitype;
   if lret='N' then
      return 'N';
   end if;
   --一表多户分表水表不抄 zhb
   select * into mi from meterinfo where miid=vmiid;
   if mi.micolumn9='Y' and mi.micode <> mi.mipriid  then
      return 'N';
   end if;*/

   Return 'Y';
exception

WHEN OTHERS THEN
   Return 'N';
END;
/

