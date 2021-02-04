CREATE OR REPLACE TRIGGER HRBZLS."TIB_BOOKFRAME" BEFORE INSERT
ON BOOKFRAME FOR EACH ROW
DECLARE
    INTEGRITY_ERROR  EXCEPTION;
    ERRNO            INTEGER;
    ERRMSG           CHAR(200);
    DUMMY            INTEGER;
    FOUND            BOOLEAN;
    --  DECLARATION OF INSERTCHILDPARENTEXIST CONSTRAINT FOR THE PARENT "SYSMANAFRAME"
    CURSOR CPK1_BOOKFRAME(VAR_BFSMFID VARCHAR) IS
       SELECT 1
       FROM   SYSMANAFRAME
       WHERE  SMFID = VAR_BFSMFID
        AND   VAR_BFSMFID IS NOT NULL;

cursor cpk2_bookframe(var_bfid varchar2) is
  select    *
             from bookframe
            start with bfid=var_bfid
                   and bfclass = bfclass
           connect by prior bfpid = bfid;
v_bf bookframe%rowtype;
BEGIN
  if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
  
    --20140903 add hb 添加判断。当前抄表月份不能大于系统日期 且当月末第二天不需判断，因有做抄表月结
 -- if nvl(:new.BFMONTH,'0000.00') > to_char(sysdate,'yyyy.mm') and to_char(LAST_DAY(SYSDATE)-1  ,'yyyymmdd')  <> to_char(sysdate,'yyyymmdd')  then
  if nvl(:new.BFMONTH,'0000.00') > to_char(sysdate,'yyyy.mm') and to_char(LAST_DAY(SYSDATE)  ,'yyyymmdd')  <> to_char(sysdate,'yyyymmdd')  then  
        errno  := -20003;
          errmsg := '更新当前抄表月份【'||:new.BFMONTH||'】不能大于目前月份【'||to_char(sysdate,'yyyy.mm')||'】,请联系系统管理员';
          raise integrity_error;
   end if ;
  --
  
    --  PARENT "SYSMANAFRAME" MUST EXIST WHEN INSERTING A CHILD IN "BOOKFRAME"
    IF :NEW.BFSMFID IS NOT NULL THEN
       OPEN  CPK1_BOOKFRAME(:NEW.BFSMFID);
       FETCH CPK1_BOOKFRAME INTO DUMMY;
       FOUND := CPK1_BOOKFRAME%FOUND;
       CLOSE CPK1_BOOKFRAME;
       IF NOT FOUND THEN
          ERRNO  := -20002;
          ERRMSG := 'PARENT DOES NOT EXIST IN "SYSMANAFRAME". CANNOT CREATE CHILD IN "BOOKFRAME".';
          RAISE INTEGRITY_ERROR;
       END IF;
    END IF;
/*     if :new.bfflag='Y' then
         open cpk2_bookframe(:new.bfpid);
           loop
              fetch cpk2_bookframe into v_bf;
              exit when cpk2_bookframe%notfound or  cpk2_bookframe%notfound is null;
              insert into bookframetemp values(:new.bfid,:new.bfsmfid,:new.bfname,v_bf.bfid,:new.bfstatus,:new.bfflag);
           end loop;
         close cpk2_bookframe;
           insert into bookframetemp values(:new.bfid,:new.bfsmfid,:new.bfname,:new.bfid,:new.bfstatus,:new.bfflag);
     end if;*/

--  ERRORS HANDLING
EXCEPTION
    WHEN INTEGRITY_ERROR THEN
       RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/

