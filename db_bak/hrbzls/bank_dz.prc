create or replace procedure hrbzls.BANK_DZ is
  P_DATE DATE;
  temp VARCHAR2(10);
  P_LASTDATE DATE;

  cursor cur is
  --ȡ������δ���˵����б���
SELECT BANKID
  FROM (select BANKID
          From MI_BANKZZ  --���ʱ�
         where zzdate =
               to_date(to_char(sysdate, 'yyyymmdd'), 'yyyymmdd') - 1
           AND SUBSTR(BANKID, 3, 2) IN
               (SELECT SUBSTR(SPID, 3)
                  FROM SYSPARA
                 WHERE SPID like 'B0%'
                   AND SPVALUE = 'Y')
        MINUS
        select BANKCODE
          from "BANKCHKLOG_NEW" --���˱�
         where chkdate =
               to_date(to_char(sysdate, 'yyyymmdd'), 'yyyymmdd') - 1);

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

  --ÿ�����һ��������Զ�����
  IF P_DATE = P_LASTDATE THEN  
      RETURN;
  END IF;

   --ÿ���賿1����Զ���ǰһ���ϵͳ��������δ���˵������ʽ��ж���
  for temp in cur loop
    --ZHONGBE.sp_bankdz(P_DATE,TEMP.BANKID);
    sp_auto_bankdz_zd(P_DATE,TEMP.BANKID);
    commit;
  end loop;


end BANK_DZ;
/

