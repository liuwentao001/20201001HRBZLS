create or replace procedure hrbzls.pro_������ȷ���쳣���ϸ���  is
--����23��00ִ�� 
  V_CHKDATE DATE; --����������
  pm   payment%ROWTYPE; --ʵ��
  cq   cheque%ROWTYPE; --֧Ʊ��
  yx   STpaymentyxdzreghd%rowtype;--Ӫ������
  cw   STpaymentcwdzreghd%rowtype;--�������
  pdp     PAY_DAILY_PID%rowtype;  --ʵ������Ӫ�����˹���
  pdy     PAY_DAILY_YXHD%rowtype;  --Ӫ�������������˵��Ź���
  CI                    CUSTINFO%ROWTYPE;
  V_BANKID              VARCHAR2(100);
  V_BANKNAME            VARCHAR2(100);
  V_BANKNO              VARCHAR2(100);  
  V_JE                  PAYMENT.PPAYMENT%TYPE;
  V_SMFID               PAYMENT.PPOSITION%TYPE;
  V_OPER                PAYMENT.PPER%TYPE;
  V_PBATCH              VARCHAR2(20);
  v_chequecrflag       cheque.chequecrflag%type ;
  v_chequeyxno         cheque.chequeyxno%type ;
  v_chequecwno         cheque.chequecwno%type ;
  
begin
     --add 20140903 hb 
 --  V_CHKDATE := TRUNC(SYSDATE) - 1;
     -- 1������������֧ƱZP������DC��Ĩ��MZ ��δ����֧Ʊ��cheque ����  
     --20160503 ����  PS
   for v_pm in (  select pm.pid
                   from payment pm
                  where TO_char(PDATE, 'yyyymmdd') =
                        TO_char(TRUNC(SYSDATE)  , 'yyyymmdd')
                    and ppayway in ('ZP', 'DC', 'MZ','PS')
                    and pposition not like '03%'  --ȥ�����е�
                    and not exists (select 'a' from  cheque where chequeid =pm.pbatch ) --������cheque���е�
                  --test   and pm.pid ='1448895783'
                    ) loop
           begin
             select * into pm from payment where pid = v_pm.pid;
           exception
             when others then
                pm := null; 
           end;
           
           begin
             select * into pdp from PAY_DAILY_PID where pdpid = pm.pbatch; --payment��Ӫ�����˹���
           exception
             when others then
               pdp := null; 
           end;
              
            begin 
              select *
                into yx
                from STpaymentyxdzreghd
               where hno = pdp.pdhid; --Ӫ������
            exception
              when others then 
                yx := null;
            end;
            
            begin
              select b.*
                into pdy
                from PAY_DAILY_PID a, PAY_DAILY_YXHD b --Ӫ���������˹���
               where a.pdhid = b.PDDID
                 and a.pdpid = pm.pbatch;
            exception
              when others then
                pdy := null;
            end;
            begin 
              select *
                into cw
                from STpaymentcwdzreghd
               where hno = pdy.pdhid; --�������
            exception
              when others then
                cw := null;
            end;
               
             if pm.PREVERSEFLAG ='Y' THEN  --������־
                  v_chequecrflag:='Y';
             ELSE
                  v_chequecrflag:='N';
             END IF ;
             
            begin
              SELECT * INTO CI FROM CUSTINFO WHERE CIID = pm.PPRIID;  --�ͻ���Ϣ
            exception
              when others then
                 CI := null;
            end;
             
             V_JE :=pm.PPAYMENT;
             V_OPER :=pm.PPER;
             V_SMFID :=pm.PPOSITION; 
             V_PBATCH :=pm.pbatch; 
            --�����˺�
            begin
              SELECT SMPPVALUE
                INTO V_BANKNO
                FROM SYSMANAPARA
               WHERE SMPID = V_SMFID
                 AND SMPPID = 'KHZH';
            exception
              when others then
                null;
            end;
             --��������
            begin
              SELECT SMPPVALUE
                INTO V_BANKNAME
                FROM SYSMANAPARA
               WHERE SMPID = V_SMFID
                 AND SMPPID = 'KHYH';
            exception
              when others then
                null;
            end;
             --�����к�
            begin
              SELECT SMPPVALUE
                INTO V_BANKID
                FROM SYSMANAPARA
               WHERE SMPID = V_SMFID
                 AND SMPPID = 'KHHH';
            exception
              when others then
                null;
            end;
             CQ.chequeid            :=     V_PBATCH;
             CQ.enteringtime        :=     pm.pdatetime;
             CQ.payername           :=     CI.CINAME;
             CQ.payertel            :=     CI.CIMTEL;
             CQ.chequetype          :=     pm.ppayway;
             CQ.chequemoney         :=     V_JE;
             CQ.chargelocation      :=     V_SMFID;
             CQ.chargename          :=     V_OPER;
             CQ.chargetime          :=      pm.pdatetime;
             CQ.chequechargerid     :=     V_OPER;
             CQ.chequememo          :=     '��̨�Զ���������';
             CQ.chequestatus        :=     'N';
             CQ.chequeoper          :=     V_OPER;
             CQ.chequesdate         :=     pm.pdatetime;
             CQ.chequemcode         :=     pm.pcid;
             CQ.chequecode          :=     '';
             CQ.chequename          :=     CI.Ciname;
             CQ.chequebankname      :=     '';--���֧Ʊ���������
             CQ.CHEQUEBANKID        :=     '';--
             CQ.CHEQUEBANKNO        :=     '';--
             CQ.CBANKID             :=     V_BANKID;
             CQ.CBANKNAME           :=     V_BANKNAME;
             CQ.CBANKNO             :=     V_BANKNO;
             CQ.CHEQUEFLAG          :=     'N';
             CQ.CHEQUECRFLAG        :=     v_chequecrflag; 
             if v_chequecrflag ='Y' THEN
                CQ.chequecrdate := pm.pdatetime;
                CQ.chequecroper:= V_OPER;
             END IF ;
             CQ.chequeyxno          := pdp.pdhid;   --Ӫ�����˵���
             CQ.chequecwno          := pdy.pdhid ;  --������˵���
             INSERT INTO CHEQUE VALUES CQ; 
             
             if cw.HSHFLAG ='Y' THEN  --���������˱�־���������� payment�Ķ�������
                if to_char(cw.HEDATE,'yyyymm')   <>   to_char(cw.HSHDATE,'yyyymm')   then  --�����������봴�������·ݲ�һ�����ô������ڷ������������
                  update payment set payment.pdzdate =cw.HEDATE
                  where pid =pm.pid;
                else
                  update payment set payment.pdzdate =cw.HSHDATE
                  where pid =pm.pid;
                end if ;
                
             END IF ;
     end loop ;
     commit ;
  -- 2�����н�����������ˣ���payment��δ���� payment.PDZDATE ������ȷ������
     for v_pm in (SELECT PM.PID, P.PDPID,CW.HEDATE,CW.HSHDATE FROM STPAYMENTCWDZREGHD CW,PAY_DAILY_YXHD YX,PAY_DAILY_PID P,PAYMENT PM
                    WHERE CW.HNO=YX.PDHID AND
                          YX.PDDID=P.PDHID and
                          cw.hshflag ='Y' AND
                          TO_char(CW.HSHDATE, 'yyyymmdd') =  TO_char(TRUNC(SYSDATE) , 'yyyymmdd') and 
                          P.PDPID =PM.PBATCH AND
                          PM.PDZDATE IS NULL )  LOOP
                if to_char(cw.HEDATE,'yyyymm')   <>   to_char(cw.HSHDATE,'yyyymm')   then  --�����������봴�������·ݲ�һ�����ô������ڷ������������
                  update payment set payment.pdzdate =v_pm.HEDATE  --��������
                  where pid =v_pm.pid;
                else
                  update payment set payment.pdzdate =v_pm.HSHDATE --�������
                  where pid =v_pm.pid;
                end if ;    
      END LOOP ;
      COMMIT ;
  exception 
     when others then
        rollback;
end pro_������ȷ���쳣���ϸ���;
/

