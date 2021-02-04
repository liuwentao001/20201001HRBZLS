CREATE OR REPLACE TRIGGER HRBZLS."MISTATUS_METERINFO"
  AFTER update OF mistatus ON METERINFO
  FOR EACH ROW
DECLARE
  INTEGRITY_ERROR EXCEPTION;
  ERRNO  INTEGER;
  ERRMSG CHAR(200);
  DUMMY  INTEGER;
  FOUND  BOOLEAN;

BEGIN
  --add wg 20141126 
  --调整为当表状态更改为，更新未审核的单据里面的状态为当前的状态
  --INTEGRITYPACKAGE.NEXTNESTLEVEL;
  if :old.mistatus <> :new.mistatus /*and :new.mistatus = '1' */then
    --新表态等于1，并且与旧表态不等
      if INTEGRITYPACKAGE.delete_mk <> 2 then  --2为相关表务信息变更 
        update CUSTCHANGEDT
           set MISTATUS = :new.mistatus
         where CIID = :new.miid
           and CCDNO in
               (select CCHNO from CUSTCHANGEhd where nvl(CCHSHFLAG, 'N') = 'N'); --用户变更单
       END IF ;
    if INTEGRITYPACKAGE.delete_mk <>1 then     --1为故障换表  
      UPDATE METERTRANSDT
         SET MTDMSTATUSO = :new.mistatus
       WHERE MTDMCODE = :new.miid
         AND MTDNO IN
             (SELECT MTHNO FROM METERTRANSHD WHERE NVL(MTHSHFLAG, 'N') = 'N'); --表务工单
    end if ;
    INTEGRITYPACKAGE.delete_mk := 0;
  end if;
 -- INTEGRITYPACKAGE.PREVIOUSNESTLEVEL;

EXCEPTION
  WHEN others THEN  
      RAISE_APPLICATION_ERROR(sqlcode, sqlerrm);
 
END;
/

