create or replace procedure hrbzls.auto_dk is
  P_DATE DATE;
  P_LASTDATE DATE;

   begin

 
  --ȡ��������
  select to_date(to_char(sysdate, 'yyyymmdd'), 'yyyymmdd')
    into P_DATE
    from dual;

    --ȡ���µ����ڶ���
     select to_date(to_char(last_day(sysdate),'yyyymmdd'),'yyyymmdd') -1
     into P_LASTDATE
     from dual;

  --ÿ�µ����ڶ�������Ͻ��еֿ�
  IF P_DATE = P_LASTDATE THEN
      pg_ewide_job_hrb.��ĩ�Զ�Ԥ��ֿ�;
  END IF;

end auto_dk;
/

