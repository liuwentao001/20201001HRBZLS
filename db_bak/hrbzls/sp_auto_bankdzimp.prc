CREATE OR REPLACE PROCEDURE HRBZLS."SP_AUTO_BANKDZIMP" (p_date in date,p_smfid in varchar2) is
  EF     entrustfile%ROWtype;
  bgk    v_bank_chk%ROWtype;
  v_flag varchar2(1);
  type c_mi is ref cursor;
  v_bgk c_mi;
  
begin
  null;
  OPEN v_bgk FOR
    select T.*
      from v_bank_chk T
     where TRIM(T.OKFLAG) = 'N'
       AND t.chkdate =p_date
       and TRIM(bankcode) = p_smfid
     ORDER BY T.CHKDATE;
         FETCH v_bgk
      INTO bgk;
  LOOP

    EXIT WHEN v_bgk%NOTFOUND OR v_bgk%NOTFOUND IS NULL;
    v_flag := '0';
    begin
      select *
        into EF
        from entrustfile t
       where t.efpath = bgk.smppvalue1
         and t.efflag = '2'
         and to_date(substr(t.effilename,
                            (f_getptype(t.effilename, '.') - 7),
                            8),
                     'YYYYMMDD') = bgk.chkdate;
    exception
      when others then
        v_flag := '1';
    end;
    if v_flag = '0' then
      IF EF.EFFILENAME IS NOT NULL THEN
        --��������ļ�����ʱ�����ɶ����ļ�
        SP_DZ_IMP(ef.efid);
        --COMMIT;
       -- RETURN ;
        -- ������Ӧ��ƽ�ʵĹ���
        sq_dzbank(bgk.ID, 'SYSTEM', EF.EFFILENAME);
        -- ���ɶ����ļ��ɹ����Զ�������Ӧ�ı�־
        update entrustfile set efflag = '3' where efid = EF.efid;
        commit;
      END IF;
    end if;
    -- �Զ��˳ɹ��Ľ���ƽ�ʵĹ���(���������ύ)
        FETCH v_bgk
      INTO bgk;
  END LOOP;
  CLOSE v_bgk;
exception
  when others then
    rollback;
    raise_application_error('-20002', '����ʧ�ܣ�!'|| sqlerrm);
    
end;
/

