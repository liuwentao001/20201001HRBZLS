CREATE OR REPLACE PROCEDURE HRBZLS."SP_BANKDZ" (p_sdate in VARCHAR2,
                                      p_edate in VARCHAR2) AS

  CM_BANK BANKCHKLOG_NEW%ROWTYPE;
  cursor cm_bank_mx is
    select *
      from bankchklog_new t
     where t.chkdate >= to_date(p_sdate, 'YYYY-MM-DD')
       AND t.chkdate < to_date(p_edate, 'YYYY-MM-DD') + 1
       AND T.OKFLAG = 'N';
begin
  null;
  insert into bankchklog_new
    (SELECT trim(to_char(bankchklog.nextval, '0000000000')) id,
            T.CHKDATE,
            T.smfid,
            0,
            0,
            NULL,
            'N',
            NULL,
            NULL,
            NULL,
            NULL,
            NULL,
            NULL
       FROM (select A.CHKDATE,
                    B.smfid,
                    0,
                    0,
                    NULL,
                    'N',
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL,
                    NULL
               FROM (SELECT DISTINCT (trunc(T1.PDATE)) CHKDATE
                       FROM PAYMENT T1
                      WHERE T1.PDATE >= to_date(p_sdate, 'YYYY-MM-DD')
                        AND T1.PDATE < to_date(p_edate, 'YYYY-MM-DD') + 1
                        AND T1.PTRANS  in  ('B','Q')) A,
                    (select C.smfid AS smfid, C.smfname AS smfname
                       from sysmanaframe C, sysmanapara a, sysmanapara b, sysmanapara x
                      where C.smfid = a.smpid
                        and C.smfid = b.smpid
                        and C.smfid = x.smpid
                        and a.smppid = 'FTPDZDIR'
                        and b.smppid = 'FTPDZSRV'
                        and x.smppid='BCODE'
                        and (x.smppvalue is not null or x.smppvalue!='')) B) T
      WHERE (T.smfid, T.CHKDATE) NOT IN
            (SELECT T1.BANKCODE, CHKDATE
               FROM bankchklog_new T1
              WHERE T1.CHKDATE >= to_date(p_sdate, 'YYYY-MM-DD')
                AND T1.CHKDATE < to_date(p_edate, 'YYYY-MM-DD') + 1));
  OPEN cm_bank_mx;
  LOOP
    FETCH cm_bank_mx
      INTO CM_BANK;
    EXIT WHEN cm_bank_mx%NOTFOUND OR cm_bank_mx%NOTFOUND IS NULL;
    insert into bank_dz_mx
      (SELECT CM_BANK.ID,
              TRIM(T.PBSEQNO),
              T.PPAYMENT,
              NULL,
              NULL,
              T.PMCODE,
              T.PDATE,
              NULL,
              'N',
              '0'
         from payment t
        where  t.pdate >= trunc(CM_BANK.CHKDATE)
          and t.pdate < trunc(CM_BANK.CHKDATE) + 1
          and PFLAG='Y'
          AND PREVERSEFLAG='N'
          AND T.PPOSITION = CM_BANK.BANKCODE
          AND T.PTRANS  in  ('B','Q')
         group by PBSEQNO,PPAYMENT,PMCODE,PDATE );
    update BANKCHKLOG_NEW t
       set t.reccount = (select count(a.chargeno)
                           from bank_dz_mx a
                          where a.id = CM_BANK.ID),
           t.amount   = (select sum(a.money_local)
                           from bank_dz_mx a
                          where a.id = CM_BANK.ID)
     where t.id = CM_BANK.id
       and t.chkdate = CM_BANK.CHKDATE
       and t.bankcode = cm_bank.bankcode;
  END LOOP;
  COMMIT;
exception
  when others then
    rollback;
    raise_application_error('-20002', '更新无法完成！!'|| sqlerrm);
end sp_bankdz;
/

