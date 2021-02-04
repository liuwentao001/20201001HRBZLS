create or replace procedure hrbzls.pro_财务到账确认异常资料更新  is
--当天23：00执行 
  V_CHKDATE DATE; --财务到账日期
  pm   payment%ROWTYPE; --实收
  cq   cheque%ROWTYPE; --支票档
  yx   STpaymentyxdzreghd%rowtype;--营销对账
  cw   STpaymentcwdzreghd%rowtype;--财务对账
  pdp     PAY_DAILY_PID%rowtype;  --实收账与营销对账关联
  pdy     PAY_DAILY_YXHD%rowtype;  --营销对账与财务对账单号关联
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
     -- 1处理昨日有收支票ZP、倒存DC、抹账MZ 但未进入支票档cheque 问题  
     --20160503 增加  PS
   for v_pm in (  select pm.pid
                   from payment pm
                  where TO_char(PDATE, 'yyyymmdd') =
                        TO_char(TRUNC(SYSDATE)  , 'yyyymmdd')
                    and ppayway in ('ZP', 'DC', 'MZ','PS')
                    and pposition not like '03%'  --去掉银行的
                    and not exists (select 'a' from  cheque where chequeid =pm.pbatch ) --不存在cheque档中的
                  --test   and pm.pid ='1448895783'
                    ) loop
           begin
             select * into pm from payment where pid = v_pm.pid;
           exception
             when others then
                pm := null; 
           end;
           
           begin
             select * into pdp from PAY_DAILY_PID where pdpid = pm.pbatch; --payment与营销对账关联
           exception
             when others then
               pdp := null; 
           end;
              
            begin 
              select *
                into yx
                from STpaymentyxdzreghd
               where hno = pdp.pdhid; --营销对账
            exception
              when others then 
                yx := null;
            end;
            
            begin
              select b.*
                into pdy
                from PAY_DAILY_PID a, PAY_DAILY_YXHD b --营销与财务对账关联
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
               where hno = pdy.pdhid; --财务对账
            exception
              when others then
                cw := null;
            end;
               
             if pm.PREVERSEFLAG ='Y' THEN  --冲正标志
                  v_chequecrflag:='Y';
             ELSE
                  v_chequecrflag:='N';
             END IF ;
             
            begin
              SELECT * INTO CI FROM CUSTINFO WHERE CIID = pm.PPRIID;  --客户信息
            exception
              when others then
                 CI := null;
            end;
             
             V_JE :=pm.PPAYMENT;
             V_OPER :=pm.PPER;
             V_SMFID :=pm.PPOSITION; 
             V_PBATCH :=pm.pbatch; 
            --开户账号
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
             --开户银行
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
             --开户行号
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
             CQ.chequememo          :=     '后台自动新增资料';
             CQ.chequestatus        :=     'N';
             CQ.chequeoper          :=     V_OPER;
             CQ.chequesdate         :=     pm.pdatetime;
             CQ.chequemcode         :=     pm.pcid;
             CQ.chequecode          :=     '';
             CQ.chequename          :=     CI.Ciname;
             CQ.chequebankname      :=     '';--相关支票需后续补入
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
             CQ.chequeyxno          := pdp.pdhid;   --营销对账单号
             CQ.chequecwno          := pdy.pdhid ;  --财务对账单号
             INSERT INTO CHEQUE VALUES CQ; 
             
             if cw.HSHFLAG ='Y' THEN  --如果财务对账标志有审核则更新 payment的对账日期
                if to_char(cw.HEDATE,'yyyymm')   <>   to_char(cw.HSHDATE,'yyyymm')   then  --如果审核日期与创建日期月份不一致则用创建日期否则用审核日期
                  update payment set payment.pdzdate =cw.HEDATE
                  where pid =pm.pid;
                else
                  update payment set payment.pdzdate =cw.HSHDATE
                  where pid =pm.pid;
                end if ;
                
             END IF ;
     end loop ;
     commit ;
  -- 2处理有进入财务对账审核，但payment中未更新 payment.PDZDATE 财务到账确认日期
     for v_pm in (SELECT PM.PID, P.PDPID,CW.HEDATE,CW.HSHDATE FROM STPAYMENTCWDZREGHD CW,PAY_DAILY_YXHD YX,PAY_DAILY_PID P,PAYMENT PM
                    WHERE CW.HNO=YX.PDHID AND
                          YX.PDDID=P.PDHID and
                          cw.hshflag ='Y' AND
                          TO_char(CW.HSHDATE, 'yyyymmdd') =  TO_char(TRUNC(SYSDATE) , 'yyyymmdd') and 
                          P.PDPID =PM.PBATCH AND
                          PM.PDZDATE IS NULL )  LOOP
                if to_char(cw.HEDATE,'yyyymm')   <>   to_char(cw.HSHDATE,'yyyymm')   then  --如果审核日期与创建日期月份不一致则用创建日期否则用审核日期
                  update payment set payment.pdzdate =v_pm.HEDATE  --创建日期
                  where pid =v_pm.pid;
                else
                  update payment set payment.pdzdate =v_pm.HSHDATE --审核日期
                  where pid =v_pm.pid;
                end if ;    
      END LOOP ;
      COMMIT ;
  exception 
     when others then
        rollback;
end pro_财务到账确认异常资料更新;
/

