create or replace procedure hrbzls.auto_dk is
  P_DATE DATE;
  P_LASTDATE DATE;

   begin

 
  --取当天日期
  select to_date(to_char(sysdate, 'yyyymmdd'), 'yyyymmdd')
    into P_DATE
    from dual;

    --取当月倒数第二天
     select to_date(to_char(last_day(sysdate),'yyyymmdd'),'yyyymmdd') -1
     into P_LASTDATE
     from dual;

  --每月倒数第二天的晚上进行抵扣
  IF P_DATE = P_LASTDATE THEN
      pg_ewide_job_hrb.月末自动预存抵扣;
  END IF;

end auto_dk;
/

