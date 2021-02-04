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
    --��ȡ����Ա�ͻ���ip
      SELECT SYS_CONTEXT('USERENV', 'sid'),
         SYS_CONTEXT('USERENV', 'SESSION_USER')
    INTO L_IP, L_USER
    FROM DUAL;
  --��ȡ����ԱID
  BEGIN
    SELECT LOGIN_USER INTO LOGIN_NAME FROM SYS_HOST WHERE IP = L_IP ;
 
  EXCEPTION
    WHEN OTHERS then
       login_name:='system';
END ;
select * into v_meterinfo from meterinfo mi where mi.Miid= :NEW.MRMID;

  ---��ʼ�������־����
  --select  fgetsequence('bs_modi_log') INTO v_bs_modi_log.id  from dual;
  v_bs_modi_log.tpdate:=sysdate;
  v_bs_modi_log.operator:=login_name;
  v_bs_modi_log.custid := v_meterinfo.miid ;
  v_bs_modi_log.meterno:=:new.mrmcode ;
  v_bs_modi_log.cust_name:=v_meterinfo.miname ;
  ---���ڳ���
  if :old.mrscode   <>:new.mrscode  or (:old.mrscode  is null and :new.mrscode is not null)
    or (:old.mrscode  is not null and :new.mrscode is  null)
    then
     v_bs_modi_log.MODI_TYPE:='�������.���ڳ���';
     v_bs_modi_log.value_o    :=:old.mrscode;
     v_bs_modi_log.remark_o :='';
     v_bs_modi_log.value_n    := :new.mrscode ;
     v_bs_modi_log.remark_n:='';
     v_bs_modi_log.modi_host:='';
     v_bs_modi_log.item:='���ڳ��� ';
     v_bs_modi_log.reason:='';
     v_bs_modi_log.remark:='';
    insert into bs_modi_log values v_bs_modi_log;
  end if;

/*1	����
2	��ѹ
3	��ˮ
4	����
5	����
6	����
7	���
8	ʧ��
9	�ܼ�
10	��װ
11	��ͣ*/

  --��̬����ת��
 if updating('mrface')  then
  if :new.mrface in ('02')  then
    --:new.mrchkflag :='Y' ; --���˱�־
    :NEW.mrifsubmit :='N' ;--�Ƿ��ύ�Ʒ�
   -- :NEW.mrmemo :=:NEW.mrmemo ||'����'||:new.mrface;--20150423ȡ��
 --    select  sflname into v_sflname  from sysfacelist2 t  where t.sflid=:new.mrface2;
  --     :NEW.mrmemo :=:NEW.mrmemo ||' �����쳣:'||v_sflname||'��';
  end if;
 end if;
 if updating('mrface')  then
  if :new.mrface in ('03')   then
    --:new.mrchkflag :='Y' ; --���˱�־
    :NEW.mrifsubmit :='N' ;--�Ƿ��ύ�Ʒ�
  --  :NEW.mrmemo :=:NEW.mrmemo ||'����'||:new.mrface;--20150423ȡ��
    --  select  sflname into v_sflname  from sysfacelist2 t  where t.sflid=:new.mrface2;
    --   :NEW.mrmemo :=:NEW.mrmemo ||' ����ˮ��'||v_sflname||'��';
  end if;
 end if;
 
 if updating('mrreadok')  then
  if :new.mrreadok='N'   then
    --:new.mrchkflag :='Y' ; --���˱�־
    :NEW.mrifsubmit :='Y' ;--�Ƿ��ύ�Ʒ�
    --:NEW.mrmemo :=:NEW.mrmemo ||'����'||:new.mrface;
  end if;
 end if;
 
 
 if updating('mrreadok')  then
    if :new.mrreadok='X' AND   :NEW.mrifmch ='Y' and :old.mrreadok <> 'X'  then  --�Ⳮ����������ע��
       RAISE_APPLICATION_ERROR(-20002, '�Ⳮ�����ܱ���������ע��');
    end if;
 end if;
 
  if updating('mrreadok')  then
    if :new.mrreadok='X' AND   :NEW.MRIFREC ='Y'    then  --����������Ѵ���˵ĳ�������
       RAISE_APPLICATION_ERROR(-20002, '���ܱ���������ע��,����������Ѵ���˵ĳ�������');
    end if;
 end if;
 
  if updating('mrrper')  then
    if (:new.mrrper is null or :new.mrrper ='' ) and :old.mrrper is not null then  --�Ⳮ����������ע��
       RAISE_APPLICATION_ERROR(-20002, '����Ա����Ϊ��');
    end if;
 end if;
 --20150420 ������ע�Ǳ��
  if updating('mrreadok')  then
     if (:new.mrreadok ='Y' OR :NEW.mrreadok ='U' OR :NEW.mrreadok ='X')  and :new.mrreadok<>:old.mrreadok  and :new.MRDATASOURCE='9' THEN  --����ע���б��
        if :OLD.MRREADOK ='N' and :new.mrreadok = 'X' THEN  --��ȥ�ɴ���������˵�״̬
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
                insert into meterinfo_sjcbup(MIID,CIID,UPDATE_MK) values(:NEW.MRMID,:NEW.MRCID,'2');--����
             end if ;
         END IF ;
     END IF ;
  end if ;
 
  if updating('mrprivilegeflag')  then
     if (:new.mrprivilegeflag ='Y' OR :NEW.mrprivilegeflag ='U' OR :NEW.mrprivilegeflag ='X')  and :new.mrprivilegeflag<>:old.mrprivilegeflag  and :new.MRDATASOURCE='9' THEN  --��������ע���б��
        if :OLD.mrprivilegeflag ='N' and :new.mrprivilegeflag = 'X' THEN  --��ȥ�ɴ���������˵�״̬
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
                insert into meterinfo_sjcbup(MIID,CIID,UPDATE_MK) values(:NEW.MRMID,:NEW.MRCID,'2');--����
             end if ;
         END IF ;
     END IF ;
  end if ;


END;
/

