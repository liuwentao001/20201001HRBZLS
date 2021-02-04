create or replace procedure hrbzls.BANK_DZ is
  P_DATE DATE;
  temp VARCHAR2(10);
  P_LASTDATE DATE;

  cursor cur is
  --取已扎帐未对账的银行编码
SELECT BANKID
  FROM (select BANKID
          From MI_BANKZZ  --轧帐表
         where zzdate =
               to_date(to_char(sysdate, 'yyyymmdd'), 'yyyymmdd') - 1
           AND SUBSTR(BANKID, 3, 2) IN
               (SELECT SUBSTR(SPID, 3)
                  FROM SYSPARA
                 WHERE SPID like 'B0%'
                   AND SPVALUE = 'Y')
        MINUS
        select BANKCODE
          from "BANKCHKLOG_NEW" --对账表
         where chkdate =
               to_date(to_char(sysdate, 'yyyymmdd'), 'yyyymmdd') - 1);

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

  --每月最后一天的账务不自动对账
  IF P_DATE = P_LASTDATE THEN  
      RETURN;
  END IF;

   --每天凌晨1点半自动对前一天的系统已扎账且未对账的银行帐进行对账
  for temp in cur loop
    --ZHONGBE.sp_bankdz(P_DATE,TEMP.BANKID);
    sp_auto_bankdz_zd(P_DATE,TEMP.BANKID);
    commit;
  end loop;


end BANK_DZ;
/

