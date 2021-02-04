CREATE OR REPLACE TRIGGER HRBZLS."TUB_CUSTINFO_LOG" BEFORE UPDATE
    ON "CUSTINFO"
    FOR EACH ROW
DECLARE
  L_IP          VARCHAR2(20);
  L_USER        VARCHAR2(20);
  LOGIN_NAME    VARCHAR(40);
  V_ID          VARCHAR(20);
  V_BS_MODI_LOG BS_MODI_LOG%ROWTYPE;
  V_METERINFO   METERINFO%ROWTYPE;
  v_count   number:=0;
BEGIN
  IF NVL(FSYSPARA('data'), 'N') = 'Y' THEN
    RETURN;
  END IF;
  --��ȡ����Ա�ͻ���ip
    SELECT SYS_CONTEXT('USERENV', 'sid'),
         SYS_CONTEXT('USERENV', 'SESSION_USER')
    INTO L_IP, L_USER
    FROM DUAL;
  --��ȡ����ԱID
  BEGIN
    SELECT LOGIN_USER INTO LOGIN_NAME FROM SYS_HOST WHERE IP = L_IP;
  EXCEPTION
    WHEN OTHERS THEN
      LOGIN_NAME := 'system';
  END;
  SELECT * INTO V_METERINFO FROM METERINFO MI WHERE MI.MICID = :NEW.CIID;

  ---��ʼ�������־����
  --select  fgetsequence('bs_modi_log') INTO v_bs_modi_log.id  from dual;
  V_BS_MODI_LOG.TPDATE    := SYSDATE;
  V_BS_MODI_LOG.OPERATOR  := LOGIN_NAME;
  V_BS_MODI_LOG.CUSTID    := V_METERINFO.MIID;
  V_BS_MODI_LOG.METERNO   := :NEW.CICODE;
  V_BS_MODI_LOG.CUST_NAME := :NEW.CINAME;
  ---��ˮ�ƺ�
  IF :OLD.CICONID <> :NEW.CICONID OR
     (:OLD.CICONID IS NULL AND :NEW.CICONID IS NOT NULL) OR
     (:OLD.CICONID IS NOT NULL AND :NEW.CICONID IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '���ϱ��.��ˮ�ƺ�';
    V_BS_MODI_LOG.VALUE_O   := :OLD.CICONID;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.CICONID;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '��ˮ�ƺ�';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := 'CICONID';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;
  /*      ---Ӫ����˾
    if :old.cismfid   <>:new.cismfid  or (:old.cismfid  is null and :new.cismfid is not null)
      or (:old.cismfid  is not null and :new.cismfid is  null)
      then
       v_bs_modi_log.MODI_TYPE:='���ϱ��.�û�Ӫҵ��';
       v_bs_modi_log.value_o    :=:old.cismfid ;
       v_bs_modi_log.remark_o :='';
       v_bs_modi_log.value_n    := :new.cismfid  ;
       v_bs_modi_log.remark_n:='';
       v_bs_modi_log.modi_host:='';
       v_bs_modi_log.item:='�û�Ӫҵ��';
       v_bs_modi_log.reason:='';
       v_bs_modi_log.remark:='';
      insert into bs_modi_log values v_bs_modi_log;
    end if;
  */

  ---  �ϼ��û����
  IF :OLD.CIPID <> :NEW.CIPID OR
     (:OLD.CIPID IS NULL AND :NEW.CIPID IS NOT NULL) OR
     (:OLD.CIPID IS NOT NULL AND :NEW.CIPID IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '���ϱ��.�ϼ��û����';
    V_BS_MODI_LOG.VALUE_O   := :OLD.CIPID;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.CIPID;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '�ϼ��û����';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';

    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;
  --- �û�����
  IF :OLD.CICLASS <> :NEW.CICLASS OR
     (:OLD.CICLASS IS NULL AND :NEW.CICLASS IS NOT NULL) OR
     (:OLD.CICLASS IS NOT NULL AND :NEW.CICLASS IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '���ϱ��.�û�����';
    V_BS_MODI_LOG.VALUE_O   := :OLD.CICLASS;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.CICLASS;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '�û�����';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;
  ---  ĩ����־
  IF :OLD.CIFLAG <> :NEW.CIFLAG OR
     (:OLD.CIFLAG IS NULL AND :NEW.CIFLAG IS NOT NULL) OR
     (:OLD.CIFLAG IS NOT NULL AND :NEW.CIFLAG IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '���ϱ��.ĩ����־ ';
    V_BS_MODI_LOG.VALUE_O   := :OLD.CIFLAG;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.CIFLAG;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := 'ĩ����־';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;
  ---  ��Ȩ��
  IF :OLD.CINAME <> :NEW.CINAME OR
     (:OLD.CINAME IS NULL AND :NEW.CINAME IS NOT NULL) OR
     (:OLD.CINAME IS NOT NULL AND :NEW.CINAME IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '���ϱ��.��Ȩ�� ';

    V_BS_MODI_LOG.VALUE_O   := :OLD.CINAME;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.CINAME;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '��Ȩ�� ';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := 'CINAME';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;

  ---  ������
  IF :OLD.CINAME2 <> :NEW.CINAME2 OR
     (:OLD.CINAME2 IS NULL AND :NEW.CINAME2 IS NOT NULL) OR
     (:OLD.CINAME2 IS NOT NULL AND :NEW.CINAME2 IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '���ϱ��.������ ';

    V_BS_MODI_LOG.VALUE_O   := :OLD.CINAME2;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.CINAME2;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '������ ';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := 'CINAME2';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;

  ---  �û���ַ
  IF :OLD.CIADR <> :NEW.CIADR OR
     (:OLD.CIADR IS NULL AND :NEW.CIADR IS NOT NULL) OR
     (:OLD.CIADR IS NOT NULL AND :NEW.CIADR IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '���ϱ��.�û���ַ ';

    V_BS_MODI_LOG.VALUE_O   := :OLD.CIADR;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.CIADR;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '�û���ַ';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := 'CIADR';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;

  ---  ֤������
  IF :OLD.CIIDENTITYLB <> :NEW.CIIDENTITYLB OR
     (:OLD.CIIDENTITYLB IS NULL AND :NEW.CIIDENTITYLB IS NOT NULL) OR
     (:OLD.CIIDENTITYLB IS NOT NULL AND :NEW.CIIDENTITYLB IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '���ϱ��.֤������ ';

    V_BS_MODI_LOG.VALUE_O   := :OLD.CIIDENTITYLB;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.CIIDENTITYLB;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '֤������';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';

    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;

  ---  ֤������
  IF :OLD.CIIDENTITYNO <> :NEW.CIIDENTITYNO OR
     (:OLD.CIIDENTITYNO IS NULL AND :NEW.CIIDENTITYNO IS NOT NULL) OR
     (:OLD.CIIDENTITYNO IS NOT NULL AND :NEW.CIIDENTITYNO IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '���ϱ��.֤������ ';

    V_BS_MODI_LOG.VALUE_O   := :OLD.CIIDENTITYNO;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.CIIDENTITYNO;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '֤������';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := 'CIIDENTITYNO';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;

  ---  �ƶ��绰
  IF :OLD.CIMTEL <> :NEW.CIMTEL OR
     (:OLD.CIMTEL IS NULL AND :NEW.CIMTEL IS NOT NULL) OR
     (:OLD.CIMTEL IS NOT NULL AND :NEW.CIMTEL IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '���ϱ��.�ƶ��绰 ';

    V_BS_MODI_LOG.VALUE_O   := :OLD.CIMTEL;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.CIMTEL;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '�ƶ��绰';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := 'CIMTEL';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;

  ---  �̶��绰1
  IF :OLD.CITEL1 <> :NEW.CITEL1 OR
     (:OLD.CITEL1 IS NULL AND :NEW.CITEL1 IS NOT NULL) OR
     (:OLD.CITEL1 IS NOT NULL AND :NEW.CITEL1 IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '���ϱ��.�̶��绰1 ';

    V_BS_MODI_LOG.VALUE_O   := :OLD.CITEL1;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.CITEL1;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '�̶��绰1';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := 'CITEL1';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;

  ---  �̶��绰2
  IF :OLD.CITEL2 <> :NEW.CITEL2 OR
     (:OLD.CITEL2 IS NULL AND :NEW.CITEL2 IS NOT NULL) OR
     (:OLD.CITEL2 IS NOT NULL AND :NEW.CITEL2 IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '���ϱ��.�̶��绰2 ';

    V_BS_MODI_LOG.VALUE_O   := :OLD.CITEL2;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.CITEL2;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '�̶��绰2';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := 'CITEL2';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;
  ---  �̶��绰3
  IF :OLD.CITEL3 <> :NEW.CITEL3 OR
     (:OLD.CITEL3 IS NULL AND :NEW.CITEL3 IS NOT NULL) OR
     (:OLD.CITEL3 IS NOT NULL AND :NEW.CITEL3 IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '���ϱ��.�̶��绰3 ';

    V_BS_MODI_LOG.VALUE_O   := :OLD.CITEL3;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.CITEL3;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '�̶��绰3';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := 'CITEL3';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;

  ---  �Ƿ���Ʊ
  IF :OLD.CIIFINV <> :NEW.CIIFINV OR
     (:OLD.CIIFINV IS NULL AND :NEW.CIIFINV IS NOT NULL) OR
     (:OLD.CIIFINV IS NOT NULL AND :NEW.CIIFINV IS NULL) THEN
    IF :NEW.CIIFINV = 'Y' THEN
      V_BS_MODI_LOG.MODI_TYPE := '���ϱ��.��Ʊ ';
    ELSE
      V_BS_MODI_LOG.MODI_TYPE := '���ϱ��.ȡ����Ʊ ';
    END IF;

    V_BS_MODI_LOG.VALUE_O   := :OLD.CIIFINV;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.CIIFINV;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '�Ƿ���Ʊ';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := 'CIIFINV';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;

  ---  �Ƿ��ṩ���ŷ���
  IF :OLD.CIIFSMS <> :NEW.CIIFSMS OR
     (:OLD.CIIFSMS IS NULL AND :NEW.CIIFSMS IS NOT NULL) OR
     (:OLD.CIIFSMS IS NOT NULL AND :NEW.CIIFSMS IS NULL) THEN
    IF :NEW.CIIFSMS = 'Y' THEN
      V_BS_MODI_LOG.MODI_TYPE := '���ϱ��.���ŷ��� ';
    ELSE
      V_BS_MODI_LOG.MODI_TYPE := '���ϱ��.ȡ�����ŷ��� ';
    END IF;

    V_BS_MODI_LOG.VALUE_O   := :OLD.CIIFSMS;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.CIIFSMS;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '�Ƿ��ṩ���ŷ���';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := 'CIIFSMS';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;

  ---  �Ƿ����ɽ�
  IF :OLD.CIIFZN <> :NEW.CIIFZN OR
     (:OLD.CIIFZN IS NULL AND :NEW.CIIFZN IS NOT NULL) OR
     (:OLD.CIIFZN IS NOT NULL AND :NEW.CIIFZN IS NULL) THEN
    IF :NEW.CIIFSMS = 'Y' THEN
      V_BS_MODI_LOG.MODI_TYPE := '���ϱ��.��ȡ���ɽ� ';
    ELSE
      V_BS_MODI_LOG.MODI_TYPE := '���ϱ��.ȡ����ȡ���ɽ� ';
    END IF;

    V_BS_MODI_LOG.VALUE_O   := :OLD.CIIFZN;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.CIIFZN;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '�Ƿ��ṩ���ŷ���';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := 'CIIFZN';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;

  ---  ��ͬ��
  IF :OLD.CIFILENO <> :NEW.CIFILENO OR
     (:OLD.CIFILENO IS NULL AND :NEW.CIFILENO IS NOT NULL) OR
     (:OLD.CIFILENO IS NOT NULL AND :NEW.CIFILENO IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '���ϱ��.��ͬ�� ';
    V_BS_MODI_LOG.VALUE_O   := :OLD.CIFILENO;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.CIFILENO;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '��ͬ��';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := 'CIFILENO';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;
  ---  ��ͬ��
  IF :OLD.CIFILENO <> :NEW.CIFILENO OR
     (:OLD.CIFILENO IS NULL AND :NEW.CIFILENO IS NOT NULL) OR
     (:OLD.CIFILENO IS NOT NULL AND :NEW.CIFILENO IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '���ϱ��.��ͬ�� ';
    V_BS_MODI_LOG.VALUE_O   := :OLD.CIFILENO;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.CIFILENO;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '��ͬ��';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := 'CIFILENO';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;

   ---  �û�״̬
  IF :OLD.CISTATUS <> :NEW.CISTATUS OR
     (:OLD.CISTATUS IS NULL AND :NEW.CISTATUS IS NOT NULL) OR
     (:OLD.CISTATUS IS NOT NULL AND :NEW.CISTATUS IS NULL) THEN
    V_BS_MODI_LOG.MODI_TYPE := '���ϱ��.�û�״̬ ';
    V_BS_MODI_LOG.VALUE_O   := :OLD.CISTATUS;
    V_BS_MODI_LOG.REMARK_O  := '';
    V_BS_MODI_LOG.VALUE_N   := :NEW.CISTATUS;
    V_BS_MODI_LOG.REMARK_N  := '';
    V_BS_MODI_LOG.MODI_HOST := '';
    V_BS_MODI_LOG.ITEM      := '�û�״̬';
    V_BS_MODI_LOG.REASON    := '';
    V_BS_MODI_LOG.REMARK    := '';
    V_BS_MODI_LOG.MICOLUMN  := 'CISTATUS';
    INSERT INTO BS_MODI_LOG VALUES V_BS_MODI_LOG;
  END IF;
  
  IF UPDATING THEN
     if nvl(:new.CINAME,'NULL') <> nvl(:old.CINAME,'NULL') or nvl(:new.CINAME2,'NULL') <> nvl(:old.CINAME2,'NULL')  or nvl(:new.CIADR,'NULL') <> nvl(:old.CIADR ,'NULL')
     or nvl(:new.CISTATUS,'NULL')   <> nvl(:old.CISTATUS,'NULL')  or nvl(:new.CIIDENTITYLB,'NULL')  <> nvl(:old.CIIDENTITYLB,'NULL')   or nvl(:new.CIIDENTITYNO,'NULL')  <> nvl(:old.CIIDENTITYNO ,'NULL')  
     or nvl(:new.CIMTEL,'NULL') <>  nvl(:old.CIMTEL,'NULL')       or  nvl(:new.CITEL1 ,'NULL')  <>  nvl(:old.CITEL1,'NULL')      
     or  nvl(:new.CICONNECTPER,'NULL') <> nvl( :old.CICONNECTPER,'NULL')   or  nvl(:new.CICONNECTTEL,'NULL')  <>  nvl(:old.CICONNECTTEL,'NULL') THEN  --����ע���б��

             begin 
             select count(*)
             into v_count
             from meterinfo_sjcbup  where miid =:new.CIID AND UPDATE_MK='2' ;
             if v_count is null then
                 v_count:=0;
             end if ;
             exception when others then
                v_count:=0;
             end ;
             if v_count = 0 then
                insert into meterinfo_sjcbup(MIID,CIID,UPDATE_MK) values(:NEW.CIID,:NEW.CIID,'2');--����
             end if ; 
     END IF ;
  end if ;
END;
/

