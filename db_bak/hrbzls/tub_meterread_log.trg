CREATE OR REPLACE TRIGGER HRBZLS."TUB_METERREAD_LOG" BEFORE UPDATE
    ON "METERREAD"
    FOR EACH ROW
DECLARE
  l_ip varchar2(20);
  l_user varchar2(20);
  login_name varCHAR(40);
 -- v_id varchar(20);
  v_bs_modi_log bs_modi_log%rowtype;
  v_meterinfo  meterinfo%rowtype;
  v_count number:=0;
  v_sflname sysfacelist2.sflname%type;

BEGIN
   if nvl(fsyspara('data'),'N')='Y' then
     return ;
   end if;
    --获取操作员客户端ip
      SELECT SYS_CONTEXT('USERENV', 'sid'),
         SYS_CONTEXT('USERENV', 'SESSION_USER')
    INTO L_IP, L_USER
    FROM DUAL;
  --获取操作员ID
  BEGIN
    SELECT LOGIN_USER INTO LOGIN_NAME FROM SYS_HOST WHERE IP = L_IP ;
 
  EXCEPTION
    WHEN OTHERS then
       login_name:='system';
END ;
select * into v_meterinfo from meterinfo mi where mi.Miid= :NEW.MRMID;

  ---初始化变更日志内容
  --select  fgetsequence('bs_modi_log') INTO v_bs_modi_log.id  from dual;
  v_bs_modi_log.tpdate:=sysdate;
  v_bs_modi_log.operator:=login_name;
  v_bs_modi_log.custid := v_meterinfo.miid ;
  v_bs_modi_log.meterno:=:new.mrmcode ;
  v_bs_modi_log.cust_name:=v_meterinfo.miname ;
  ---上期抄见
  if :old.mrscode   <>:new.mrscode  or (:old.mrscode  is null and :new.mrscode is not null)
    or (:old.mrscode  is not null and :new.mrscode is  null)
    then
     v_bs_modi_log.MODI_TYPE:='抄表库变更.上期抄见';
     v_bs_modi_log.value_o    :=:old.mrscode;
     v_bs_modi_log.remark_o :='';
     v_bs_modi_log.value_n    := :new.mrscode ;
     v_bs_modi_log.remark_n:='';
     v_bs_modi_log.modi_host:='';
     v_bs_modi_log.item:='上期抄见 ';
     v_bs_modi_log.reason:='';
     v_bs_modi_log.remark:='';
    insert into bs_modi_log values v_bs_modi_log;
  end if;

/*1	正常
2	堆压
3	积水
4	换表
5	锁门
6	表破
7	表浑
8	失灵
9	周检
10	倒装
11	表停*/

  --表态处理转单
 if updating('mrface')  then
  if :new.mrface in ('02')  then
    --:new.mrchkflag :='Y' ; --复核标志
    :NEW.mrifsubmit :='N' ;--是否提交计费
   -- :NEW.mrmemo :=:NEW.mrmemo ||'故障'||:new.mrface;--20150423取消
 --    select  sflname into v_sflname  from sysfacelist2 t  where t.sflid=:new.mrface2;
  --     :NEW.mrmemo :=:NEW.mrmemo ||' 【表异常:'||v_sflname||'】';
  end if;
 end if;
 if updating('mrface')  then
  if :new.mrface in ('03')   then
    --:new.mrchkflag :='Y' ; --复核标志
    :NEW.mrifsubmit :='N' ;--是否提交计费
  --  :NEW.mrmemo :=:NEW.mrmemo ||'故障'||:new.mrface;--20150423取消
    --  select  sflname into v_sflname  from sysfacelist2 t  where t.sflid=:new.mrface2;
    --   :NEW.mrmemo :=:NEW.mrmemo ||' 【零水量'||v_sflname||'】';
  end if;
 end if;
 
 if updating('mrreadok')  then
  if :new.mrreadok='N'   then
    --:new.mrchkflag :='Y' ; --复核标志
    :NEW.mrifsubmit :='Y' ;--是否提交计费
    --:NEW.mrmemo :=:NEW.mrmemo ||'故障'||:new.mrface;
  end if;
 end if;
 
 
 if updating('mrreadok')  then
    if :new.mrreadok='X' AND   :NEW.mrifmch ='Y' and :old.mrreadok <> 'X'  then  --免抄户不允许变更注记
       RAISE_APPLICATION_ERROR(-20002, '免抄户不能变更抄表审核注记');
    end if;
 end if;
 
  if updating('mrreadok')  then
    if :new.mrreadok='X' AND   :NEW.MRIFREC ='Y'    then  --不存在已算费待审核的抄表资料
       RAISE_APPLICATION_ERROR(-20002, '不能变更抄表审核注记,不存在已算费待审核的抄表资料');
    end if;
 end if;
 
  if updating('mrrper')  then
    if (:new.mrrper is null or :new.mrrper ='' ) and :old.mrrper is not null then  --免抄户不允许变更注记
       RAISE_APPLICATION_ERROR(-20002, '抄表员不能为空');
    end if;
 end if;
 --20150420 如果审核注记变更
  if updating('mrreadok')  then
     if (:new.mrreadok ='Y' OR :NEW.mrreadok ='U' OR :NEW.mrreadok ='X')  and :new.mrreadok<>:old.mrreadok  and :new.MRDATASOURCE='9' THEN  --抄表注记有变更
        if :OLD.MRREADOK ='N' and :new.mrreadok = 'X' THEN  --除去由待处理到待审核的状态
           NULL;
       ELSE
             begin 
             select count(*)
             into v_count
             from meterinfo_sjcbup  where miid =:new.mrmid AND UPDATE_MK='2' ;
             if v_count is null then
                 v_count:=0;
             end if ;
             exception when others then
                v_count:=0;
             end ;
             if v_count = 0 then
                insert into meterinfo_sjcbup(MIID,CIID,UPDATE_MK) values(:NEW.MRMID,:NEW.MRCID,'2');--更新
             end if ;
         END IF ;
     END IF ;
  end if ;
 
  if updating('mrprivilegeflag')  then
     if (:new.mrprivilegeflag ='Y' OR :NEW.mrprivilegeflag ='U' OR :NEW.mrprivilegeflag ='X')  and :new.mrprivilegeflag<>:old.mrprivilegeflag  and :new.MRDATASOURCE='9' THEN  --工单申请注记有变更
        if :OLD.mrprivilegeflag ='N' and :new.mrprivilegeflag = 'X' THEN  --除去由待处理到待审核的状态
           NULL;
       ELSE
             begin 
             select count(*)
             into v_count
             from meterinfo_sjcbup  where miid =:new.mrmid AND UPDATE_MK='2' ;
             if v_count is null then
                 v_count:=0;
             end if ;
             exception when others then
                v_count:=0;
             end ;
             if v_count = 0 then
                insert into meterinfo_sjcbup(MIID,CIID,UPDATE_MK) values(:NEW.MRMID,:NEW.MRCID,'2');--更新
             end if ;
         END IF ;
     END IF ;
  end if ;


END;
/

