CREATE OR REPLACE TRIGGER HRBZLS."TRG_IA_BILLNEWHDNOCOMMIT" AFTER INSERT
    ON billnewhdNOCOMMIT
    FOR EACH ROW
DECLARE

BEGIN
   if nvl(fsyspara('data'),'N')='Y' then
     return ;
   end if;
   --转单过程
   PG_EWIDE_METERTRANS_01.sp_billbuild_test;
exception when others then
     raise;
END;
/

