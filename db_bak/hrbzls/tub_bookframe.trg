CREATE OR REPLACE TRIGGER HRBZLS."TUB_BOOKFRAME" BEFORE UPDATE

ON BOOKFRAME FOR EACH ROW
DECLARE
    INTEGRITY_ERROR  EXCEPTION;
    ERRNO            INTEGER;
    ERRMSG           CHAR(200);
    DUMMY            INTEGER;
    FOUND            BOOLEAN;
    SEQ NUMBER;
    --  DECLARATION OF UPDATECHILDPARENTEXIST CONSTRAINT FOR THE PARENT "SYSMANAFRAME"
    CURSOR CPK1_BOOKFRAME(VAR_BFSMFID VARCHAR) IS
       SELECT 1
       FROM   SYSMANAFRAME
       WHERE  SMFID = VAR_BFSMFID
        AND   VAR_BFSMFID IS NOT NULL;
    --  DECLARATION OF UPDATEPARENTRESTRICT CONSTRAINT FOR "METERINFO"
    CURSOR CFK1_METERINFO(VAR_BFID VARCHAR,
                    VAR_BFSMFID VARCHAR) IS
       SELECT 1
       FROM   METERINFO
       WHERE  MIBFID = VAR_BFID
        AND   MISMFID = VAR_BFSMFID
        AND   VAR_BFID IS NOT NULL
        AND   VAR_BFSMFID IS NOT NULL;

        cursor cpk2_bookframe(var_bfid varchar2) is
  select    *
             from bookframe
            start with bfid=var_bfid
                   and bfclass = bfclass
           connect by prior bfpid = bfid ;
v_bf bookframe%rowtype;
BEGIN
   if nvl(fsyspara('data'),'N')='Y' then
     return;
  end if;
    --20140903 add hb 添加判断。当前抄表月份不能大于系统日期 且当月末第二天不需判断，因有做抄表月结
--  if nvl(:new.BFMONTH,'0000.00') > to_char(sysdate,'yyyy.mm') and to_char(LAST_DAY(SYSDATE)-1  ,'yyyymmdd')  <> to_char(sysdate,'yyyymmdd')  then
 if nvl(:new.BFMONTH,'0000.00') > to_char(sysdate,'yyyy.mm') and to_char(LAST_DAY(SYSDATE)  ,'yyyymmdd')  <> to_char(sysdate,'yyyymmdd')  then
  
         errno  := -20003;
          errmsg := '更新当前抄表月份【'||:new.BFMONTH||'】不能大于目前月份【'||to_char(sysdate,'yyyy.mm')||'】,请联系系统管理员';
          raise integrity_error;
   end if ;
  --
  
    SEQ := INTEGRITYPACKAGE.GETNESTLEVEL;
    --  PARENT "SYSMANAFRAME" MUST EXIST WHEN UPDATING A CHILD IN "BOOKFRAME"
    IF (:NEW.BFSMFID IS NOT NULL) AND (SEQ = 0) THEN
       OPEN  CPK1_BOOKFRAME(:NEW.BFSMFID);
       FETCH CPK1_BOOKFRAME INTO DUMMY;
       FOUND := CPK1_BOOKFRAME%FOUND;
       close CPK1_BOOKFRAME;
       if not found then
          errno  := -20003;
          errmsg := 'PARENT DOES NOT EXIST IN "SYSMANAFRAME". CANNOT UPDATE CHILD IN "BOOKFRAME".';
          raise integrity_error;
       end if;
    end if;

    --  Cannot modify parent code in "BOOKFRAME" if children still exist in "METERINFO"
    if (updating('BFID') and :old.BFID != :new.BFID) or
       (updating('BFSMFID') and :old.BFSMFID != :new.BFSMFID) then
       open  CFK1_METERINFO(:old.BFID,
                      :old.BFSMFID);
       fetch CFK1_METERINFO into dummy;
       found := CFK1_METERINFO%FOUND;
       CLOSE CFK1_METERINFO;
       IF FOUND THEN
          ERRNO  := -20005;
          ERRMSG := 'CHILDREN STILL EXIST IN "METERINFO". CANNOT MODIFY PARENT CODE IN "BOOKFRAME".';
          RAISE INTEGRITY_ERROR;
       END IF;
    END IF;

update bookframetemp t  set t.bfsmfid=:new.bfsmfid,
t.bfname=:new.bfname,t.bfstatus=:new.bfstatus,t.bfflag=:new.bfflag
where t.bfid=:new.bfid;
 --        open cpk2_bookframe(:new.bfid);
/*if :new.bfflag='Y' then
  --delete bookframetemp bf where bf.bfid=:new.bfid;
         open cpk2_bookframe(:new.bfid);
           loop
              fetch cpk2_bookframe into v_bf;
              exit when cpk2_bookframe%notfound or  cpk2_bookframe%notfound is null;
          --    insert into bookframetemp values(:new.bfid,:new.bfsmfid,:new.bfname,v_bf.bfid,:new.bfstatus,:new.bfflag);
           end loop;
         close cpk2_bookframe;
end if;*/

--  ERRORS HANDLING



EXCEPTION
    WHEN INTEGRITY_ERROR THEN
       RAISE_APPLICATION_ERROR(ERRNO, ERRMSG);
END;
/

