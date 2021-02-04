CREATE OR REPLACE FUNCTION HRBZLS."FCHKMETERNEEDCHARGE"
   (vmstatus IN VARCHAR2,
    vifchk IN VARCHAR2,
    vmtype IN VARCHAR2)
   Return CHAR
AS
   lret char(1);
BEGIN
  --【哈尔滨】20140306 允许销户拆表余度量算费（计划内抄表、追量等在哈尔滨本身就不会对销户状态的用户做操作）
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

