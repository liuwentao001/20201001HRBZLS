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
  --����Ϊ����״̬����Ϊ������δ��˵ĵ��������״̬Ϊ��ǰ��״̬
  --INTEGRITYPACKAGE.NEXTNESTLEVEL;
  if :old.mistatus <> :new.mistatus /*and :new.mistatus = '1' */then
    --�±�̬����1��������ɱ�̬����
      if INTEGRITYPACKAGE.delete_mk <> 2 then  --2Ϊ��ر�����Ϣ��� 
        update CUSTCHANGEDT
           set MISTATUS = :new.mistatus
         where CIID = :new.miid
           and CCDNO in
               (select CCHNO from CUSTCHANGEhd where nvl(CCHSHFLAG, 'N') = 'N'); --�û������
       END IF ;
    if INTEGRITYPACKAGE.delete_mk <>1 then     --1Ϊ���ϻ���  
      UPDATE METERTRANSDT
         SET MTDMSTATUSO = :new.mistatus
       WHERE MTDMCODE = :new.miid
         AND MTDNO IN
             (SELECT MTHNO FROM METERTRANSHD WHERE NVL(MTHSHFLAG, 'N') = 'N'); --���񹤵�
    end if ;
    INTEGRITYPACKAGE.delete_mk := 0;
  end if;
 -- INTEGRITYPACKAGE.PREVIOUSNESTLEVEL;

EXCEPTION
  WHEN others THEN  
      RAISE_APPLICATION_ERROR(sqlcode, sqlerrm);
 
END;
/

