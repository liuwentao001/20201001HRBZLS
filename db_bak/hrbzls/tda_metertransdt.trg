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
     SET T.MISTATUS = NVL(:OLD.MTDMSTATUSO,PG_EWIDE_METERTRANS_01.m����)
   WHERE MISTATUS <> :OLD.MTDMSTATUSO
     AND MIID = :OLD.MTDMID;
/*     --����Ϊ��ǰ�� 
     -- ����Ϊ���� 
     --modifyby 20140807 hb����ϻ���ʱ��̫�����п����ظ��������ϻ���ɾ������ʱ���֮ǰ�ľ�״̬����meterinfo
     open s1 ;
     fetch s1 into v_mthlb;
     close s1;
     if v_mthlb ='K' THEN  --���ϻ���
        UPDATE METERINFO T
           SET T.MISTATUS = NVL(:OLD.MTDMSTATUSO,PG_EWIDE_METERTRANS_01.m����)
         WHERE MISTATUS <> :OLD.MTDMSTATUSO
           AND MIID = :OLD.MTDMID 
           and T.MISTATUS ='24';    --24������ϻ�����
     ELSE
           UPDATE METERINFO T
           SET T.MISTATUS = NVL(:OLD.MTDMSTATUSO,PG_EWIDE_METERTRANS_01.m����)
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

