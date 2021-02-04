create or replace procedure hrbzls.BANK_PZ is
  P_DATE DATE;
  temp VARCHAR2(10);
  P_LASTDATE DATE;

  cursor cur is
  --取银行编码
/*    SELECT SMFID
      FROM "SYSMANAFRAME"
     WHERE SMFTYPE = '3'
       AND SMFCLASS = '3';*/

    select  bankcode  from "BANKCHKLOG_NEW"  where chkdate=to_date(to_char(sysdate, 'yyyymmdd'), 'yyyymmdd')-1  and  SP_YHPZFLAG(ID)='YN' ;
   begin
     
  --P_DATE :=to_date('20180711','yyyymmdd');
  --取前一天日期
  select to_date(to_char(sysdate, 'yyyymmdd'), 'yyyymmdd')-1   
    into P_DATE
    from dual;

    --取上个月左后一天
     select to_date(to_char(last_day(add_months(sysdate,-1)),'yyyymmdd'),'yyyymmdd')   
     into P_LASTDATE
     from dual;

  --每月最后一天的账务不自动平账
  IF P_DATE = P_LASTDATE THEN  
      RETURN;
  END IF;
  
   --每天凌晨3点自动平前一天的账
  for temp in cur loop
    ZHONGBE.SP_AUTOBANKPZ_test(P_DATE,TEMP.bankcode);
    commit;
  end loop;


end BANK_PZ;
/

