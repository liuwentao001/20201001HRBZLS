CREATE OR REPLACE TRIGGER HRBZLS."TIDB_CUSTCHANGEDT"
  before insert OR DELETE on custchangedt  
  for each row
declare
  --  v_cchle CUSTCHANGEHD.Cchlb%type;
    V_STATUS VARCHAR2(10);
    --  DECLARATION OF INSERTCHILDPARENTEXIST CONSTRAINT FOR THE PARENT "METERTRANSHD"
    CURSOR CPK1_CUSTCHANGEHD(VAR_MTDNO CUSTCHANGEHD.Cchno%type) IS
       SELECT CCHLB
       FROM   CUSTCHANGEHD
       WHERE  CCHNO = VAR_MTDNO  ;
        
begin
    /*if inserting then
      open CPK1_CUSTCHANGEHD(:new.ccdno);
      fetch CPK1_CUSTCHANGEHD into  V_STATUS ;
      close CPK1_CUSTCHANGEHD;
       if V_STATUS = '36' then  --Ԥ�����
            INTEGRITYPACKAGE.delete_mk:=2;  
          UPDATE METERINFO
          SET MISTATUS='36'  --���ó�Ԥ�������
          WHERE MIID=:NEW.miid;
       end if ;
    else
         if nvl(:old.misaving,0) > 0 and ( trim(:old.ccdappnote) ='�����˷�' or :old.ccdappnote ='Ԥ������˷�' ) then  --Ԥ�����
            INTEGRITYPACKAGE.delete_mk:=2;    
            UPDATE METERINFO
                SET MISTATUS=:old.MISTATUS   --ɾ����ʱ��ԭ֮ǰ��״̬
                WHERE MIID=:old.miid;
         end if ;
     end if ;*/
     null;
end TIDB_CUSTCHANGEDT;
/

