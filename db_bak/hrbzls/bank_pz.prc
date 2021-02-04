create or replace procedure hrbzls.BANK_PZ is
  P_DATE DATE;
  temp VARCHAR2(10);
  P_LASTDATE DATE;

  cursor cur is
  --ȡ���б���
/*    SELECT SMFID
      FROM "SYSMANAFRAME"
     WHERE SMFTYPE = '3'
       AND SMFCLASS = '3';*/

    select  bankcode  from "BANKCHKLOG_NEW"  where chkdate=to_date(to_char(sysdate, 'yyyymmdd'), 'yyyymmdd')-1  and  SP_YHPZFLAG(ID)='YN' ;
   begin
     
  --P_DATE :=to_date('20180711','yyyymmdd');
  --ȡǰһ������
  select to_date(to_char(sysdate, 'yyyymmdd'), 'yyyymmdd')-1   
    into P_DATE
    from dual;

    --ȡ�ϸ������һ��
     select to_date(to_char(last_day(add_months(sysdate,-1)),'yyyymmdd'),'yyyymmdd')   
     into P_LASTDATE
     from dual;

  --ÿ�����һ��������Զ�ƽ��
  IF P_DATE = P_LASTDATE THEN  
      RETURN;
  END IF;
  
   --ÿ���賿3���Զ�ƽǰһ�����
  for temp in cur loop
    ZHONGBE.SP_AUTOBANKPZ_test(P_DATE,TEMP.bankcode);
    commit;
  end loop;


end BANK_PZ;
/

