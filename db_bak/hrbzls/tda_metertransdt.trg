CREATE OR REPLACE TRIGGER HRBZLS."TDA_METERTRANSDT" AFTER DELETE
ON METERTRANSDT FOR EACH ROW
DECLARE
    INTEGRITY_ERROR  EXCEPTION;
    ERRNO            INTEGER;
    ERRMSG           CHAR(200);
    DUMMY            INTEGER;
    FOUND            BOOLEAN;
/* v_mthlb  METERTRANSHD.Mthlb%type;
 cursor s1 is 
select a.mthlb
 from  METERTRANSHD a  
where a.mthno =:old.mtdno  ;*/

BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
  INTEGRITYPACKAGE.delete_mk:=1;
  UPDATE METERINFO T
     SET T.MISTATUS = NVL(:OLD.MTDMSTATUSO,PG_EWIDE_METERTRANS_01.m立户)
   WHERE MISTATUS <> :OLD.MTDMSTATUSO
     AND MIID = :OLD.MTDMID;
/*     --上述为以前的 
     -- 下述为调整 
     --modifyby 20140807 hb因故障换表时间太长，有可能重复开立故障换表，删除资料时会把之前的旧状态更新meterinfo
     open s1 ;
     fetch s1 into v_mthlb;
     close s1;
     if v_mthlb ='K' THEN  --故障换表
        UPDATE METERINFO T
           SET T.MISTATUS = NVL(:OLD.MTDMSTATUSO,PG_EWIDE_METERTRANS_01.m立户)
         WHERE MISTATUS <> :OLD.MTDMSTATUSO
           AND MIID = :OLD.MTDMID 
           and T.MISTATUS ='24';    --24代表故障换表中
     ELSE
           UPDATE METERINFO T
           SET T.MISTATUS = NVL(:OLD.MTDMSTATUSO,PG_EWIDE_METERTRANS_01.m立户)
         WHERE MISTATUS <> :OLD.MTDMSTATUSO
           AND MIID = :OLD.MTDMID;
      END IF ;*/
--  ERRORS HANDLING
EXCEPTION
    WHEN INTEGRITY_ERROR THEN
       BEGIN
       INTEGRITYPACKAGE.INITNESTLEVEL;
       RAISE_APPLICATION_ERROR(-20002, ERRMSG);
       END;
END;
/

