CREATE OR REPLACE TRIGGER HRBZLS."TDA_CUSTCHANGEHD" AFTER DELETE
ON CUSTCHANGEHD FOR EACH ROW
DECLARE
    INTEGRITY_ERROR  EXCEPTION;
    ERRNO            INTEGER;
    ERRMSG           CHAR(200);
    DUMMY            INTEGER;
    FOUND            BOOLEAN;
    v_count number;
BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
    INTEGRITYPACKAGE.NEXTNESTLEVEL;
    --  DELETE ALL CHILDREN IN "CUSTCHANGEDT"
    if :old.cchsource ='3' then  --���������Դ��ʽΪ�ֻ�������ɾ��ʱ�����meterread�ĳ�����Դ  20150412 add
/*        update meterread
           set MRPRIVILEGEFLAG ='U'  --�������ɾ�����൱��δͨ��.
         where MRMID = (select ciid from CUSTCHANGEDT   WHERE  CCDNO = :OLD.CCHNO ) and
               mrmonth= to_char(:old.CCHCREDATE,'yyyy.mm') ;  --���µĲ��ܱ��*/
         update meterinfo
           set miyl5 ='U'  --�������ɾ�����൱��δͨ��.
         where miid = (select ciid from CUSTCHANGEDT   WHERE  CCDNO = :OLD.CCHNO )  ;  --ralph 20150430
         select count(*) into v_count from  METERINFO_SJCBUP where miid in (select ciid from CUSTCHANGEDT   WHERE  CCDNO = :OLD.CCHNO )  ;
         if v_count=0 then
           insert into METERINFO_SJCBUP
           select miid,ciid,'2' from CUSTCHANGEDT  WHERE  CCDNO = :OLD.CCHNO;

         end if;
    end if ;
    DELETE CUSTCHANGEDT
    WHERE  CCDNO = :OLD.CCHNO;

    --  DELETE ALL CHILDREN IN "CUSTCHANGEDTHIS"
    DELETE CUSTCHANGEDTHIS
    WHERE  CCDNO = :OLD.CCHNO;

    DELETE kpi_task
    WHERE  REPORT_ID = :OLD.CCHNO;
    INTEGRITYPACKAGE.PREVIOUSNESTLEVEL;

--  ERRORS HANDLING
EXCEPTION
    WHEN INTEGRITY_ERROR THEN
       BEGIN
       INTEGRITYPACKAGE.INITNESTLEVEL;
       RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
       END;
END;
/

