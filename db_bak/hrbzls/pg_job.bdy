CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_JOB" is

  function fwhatname(job_what in varchar2) return varchar2 as
  begin
    case lower(job_what)
      when 'pg_job.carryover;' then
        return 'ÿ�ս�ת';
      when 'pg_job.autosubmit;' then
        return 'ÿ���Զ����';
      when 'sp_auto_dkfileexp;' then
        return '���۵���';
      else
        return job_what;
    end case;
  exception
    when others then
      return job_what;
  end;

  procedure Topjobsubmit(p_time in varchar2) is
    starttime date;
    curdate   date;
    v_count   number;
  begin
    curdate := sysdate;
    for j in (select job, what from user_jobs) loop
      if Lower(j.what) = 'pg_job.rebuildalljobs;' then
        select count(*)
          into v_count
          from dba_jobs_running t
         where t.JOB = j.job;
        if v_count = 0 then
          job_remove(j.job);
        else
          raise_application_error(errcode,
                                  '����������ִ�У���ʱ����������ִ��ʱ�䣬���Ժ�����');
        end if;
      end if;
    end loop;

    starttime := to_date(to_char(sysdate, 'yyyymmdd') || ' ' || p_time,
                         'yyyymmdd hh24:mi:ss');
    if starttime < curdate then
      starttime := to_date(to_char(curdate + 1, 'yyyymmdd') || ' ' ||
                           p_time,
                           'yyyymmdd hh24:mi:ss');
    end if;
    job_submit('pg_job.Rebuildalljobs;',
               to_char(starttime, 'yyyymmdd hh24:mi:ss'),
               'sysdate+1');

    commit;
  exception
    when others then
      raise;
  end;

  --����syspara���趨�ļƻ�ִ��ʱ���ؽ�����job
  procedure Rebuildalljobs is
    sp syspara%rowtype;
  begin
    /*    --1058  ���۵����ƻ�ִ��ʱ��
    begin
    select * into sp from syspara where spid='1058';
    Setdkexp(sp.spvalue);
    end;*/

    /*    begin
    --1061  ���۵���ƻ�ִ��ʱ��
    select * into sp from syspara where spid='1061';
    Setdkimp(sp.spvalue);
    end;*/

    /*begin
      --1062  ���ն��ʼƻ�ִ��ʱ��
      select * into sp from syspara where spid = '1062';
      SetDz(sp.spvalue);
    end;*/

    /*begin
      --1063  �Զ���Ѽƻ�ִ��ʱ��
      select * into sp from syspara where spid = '1063';
      SetCal(sp.spvalue);
    end;*/

    begin
      --1064  �ս�ƻ�ִ��ʱ��
      select * into sp from syspara where spid = '1064';
      SetCarryover(sp.spvalue);
    end;

    /*begin
      --1065  ���ս�����־ת��
      select * into sp from syspara where spid = '1065';
      SetClearTransLog(sp.spvalue);
    end;*/

    /*begin
      --1068  ��װ�ӿڱ���ͼÿ��ˢ��
      select * into sp from syspara where spid = '1068';
      SetRefmv(sp.spvalue);
    end;*/

    /*begin
      --1073  ����Ԥ�漴ʱ�ֿ�
      select * into sp from syspara where spid = '1073';
      SetSavingPay(sp.spvalue);
    end;*/

    begin
    --1074	����Ƿ���ս�桢����ָ��������ھ�������ƻ�ִ��ʱ��
    select * into sp from syspara where spid='1074';
    SetCarryFee(sp.spvalue);
    end;

  exception
    when others then
      raise;
  end;

  --jobִ�п���
  --SQL> show parameter job;
  --SQL> ALTER SYSTEM SET JOB_QUEUE_PROCESSES = 20;
  procedure SetCarryover(p_time in varchar2) is
    starttime date;
    curdate   date;
    v_count   number;
  begin
    curdate := sysdate;
    for j in (select job, what from user_jobs) loop
      if Lower(j.what) = 'pg_job.carryover;' then
        select count(*)
          into v_count
          from dba_jobs_running t
         where t.JOB = j.job;
        if v_count = 0 then
          job_remove(j.job);
        else
          raise_application_error(errcode,
                                  'ÿ�ս�ת������ִ�У���ʱ����������ִ��ʱ�䣬���Ժ�����');
        end if;
      end if;
    end loop;

    starttime := to_date(to_char(sysdate, 'yyyymmdd') || ' ' || p_time,
                         'yyyymmdd hh24:mi:ss');
    if starttime < curdate then
      starttime := to_date(to_char(curdate + 1, 'yyyymmdd') || ' ' ||
                           p_time,
                           'yyyymmdd hh24:mi:ss');
    end if;
    job_submit('pg_job.carryover;',
               to_char(starttime, 'yyyymmdd hh24:mi:ss'),
               'sysdate+1');

    commit;
  exception
    when others then
      rollback;
      raise;
  end;

  --jobִ�п���
  --SQL> show parameter job;
  --SQL> ALTER SYSTEM SET JOB_QUEUE_PROCESSES = 20;
  procedure Setdkexp(p_time in varchar2) is
    starttime date;
    curdate   date;
    v_count   number;
  begin
    curdate := sysdate;
    for j in (select job, what from user_jobs) loop
      if Lower(j.what) = 'sp_auto_dkfileexp;' then
        select count(*)
          into v_count
          from dba_jobs_running t
         where t.JOB = j.job;
        if v_count = 0 then
          job_remove(j.job);
        else
          raise_application_error(errcode,
                                  '���۵���������ִ�У���ʱ����������ִ��ʱ�䣬���Ժ�����');
        end if;
      end if;
    end loop;

    starttime := to_date(to_char(sysdate, 'yyyymmdd') || ' ' || p_time,
                         'yyyymmdd hh24:mi:ss');
    if starttime < curdate then
      starttime := to_date(to_char(curdate + 1, 'yyyymmdd') || ' ' ||
                           p_time,
                           'yyyymmdd hh24:mi:ss');
    end if;
    job_submit('sp_auto_dkfileexp;',
               to_char(starttime, 'yyyymmdd hh24:mi:ss'),
               'sysdate+1');

    commit;
  exception
    when others then
      rollback;
      raise;
  end;

  --jobִ�п���
  --SQL> show parameter job;
  --SQL> ALTER SYSTEM SET JOB_QUEUE_PROCESSES = 20;
  procedure Setdkimp(p_time in varchar2) is
    starttime date;
    curdate   date;
    v_count   number;
  begin
    curdate := sysdate;
    for j in (select job, what from user_jobs) loop
      if instr(Lower(j.what), 'sp_auto_dkfileimp') > 0 then
        select count(*)
          into v_count
          from dba_jobs_running t
         where t.JOB = j.job;
        if v_count = 0 then
          job_remove(j.job);
        else
          raise_application_error(errcode,
                                  '�Զ����۵���������ִ�У���ʱ����������ִ��ʱ�䣬���Ժ�����');
        end if;
      end if;
    end loop;

    starttime := to_date(to_char(sysdate, 'yyyymmdd') || ' ' || p_time,
                         'yyyymmdd hh24:mi:ss');
    if starttime < curdate then
      starttime := to_date(to_char(curdate + 1, 'yyyymmdd') || ' ' ||
                           p_time,
                           'yyyymmdd hh24:mi:ss');
    end if;
    job_submit('sp_auto_dkfileimp(sysdate);',
               to_char(starttime, 'yyyymmdd hh24:mi:ss'),
               'sysdate+1');

    commit;
  exception
    when others then
      rollback;
      raise;
  end;

  -- �����Զ����˲�������

  procedure SetbankXCZLStaskd(P_bankid in varchar2) is
    starttime date;
    v_count   number;
  begin
    for j in (select job, what from user_jobs) loop
      if instr(Lower(j.what), 'bank.sp_bankxczlstaskdz'||'('''||  p_bankid ||''')') > 0 then
        select count(*)
          into v_count
          from dba_jobs_running t
         where t.JOB = j.job;
        if v_count = 0 then
          job_remove(j.job);
        else
          raise_application_error(errcode,
                                  '�ֹ��Զ�����������ִ�У���ʱ����������ִ��ʱ�䣬���Ժ�����');
        end if;
      end if;
    end loop;
    starttime := sysdate + 1/144;
    job_submit('bank.sp_bankxczlstaskdz'||'('''||p_bankid|| ''');',
    to_char(starttime, 'yyyymmdd hh24:mi:ss'), 'sysdate + 36000');
    commit;
  exception
    when others then
      rollback;
      raise;
  end;

  procedure Sethanddkimp(p_time in date, p_bankid in varchar2) is
    starttime date;
    v_count   number;
  begin

    for j in (select job, what from user_jobs) loop
      if instr(Lower(j.what), 'sp_hand_dkfileimp') > 0 then
        select count(*)
          into v_count
          from dba_jobs_running t
         where t.JOB = j.job;
        if v_count = 0 then
          job_remove(j.job);
        else
          raise_application_error(errcode,
                                  '�ֹ����۵���������ִ�У���ʱ����������ִ��ʱ�䣬���Ժ�����');
        end if;
      end if;
    end loop;
    starttime := sysdate + 1 / 2880;
    job_submit('sp_hand_dkfileimp( to_date(''' ||
               to_char(p_time, 'yyyymmdd hh24:mi:ss') ||
               ''',''yyyymmdd hh24:mi:ss''),''' || p_bankid || ''' );',
               to_char(starttime, 'yyyymmdd hh24:mi:ss'),
               'sysdate + 360');
    commit;
  exception
    when others then
      rollback;
      raise;
  end;

  --�ֶ����ô��۵���

  procedure Sethanddkexp(p_bankid in varchar2) is
    starttime date;
    v_count   number;
  begin

    for j in (select job, what from user_jobs) loop
      if instr(Lower(j.what), 'sp_hand_dkfileexp') > 0 then
        select count(*)
          into v_count
          from dba_jobs_running t
         where t.JOB = j.job;
        if v_count = 0 then
          job_remove(j.job);
        else
          raise_application_error(errcode,
                                  '�ֹ����۵���������ִ�У���ʱ����������ִ��ʱ�䣬���Ժ�����');
        end if;
      end if;
    end loop;
    starttime := sysdate + 1 / 2880;
    job_submit('sp_hand_dkfileexp(''' || p_bankid || ''' );',
               to_char(starttime, 'yyyymmdd hh24:mi:ss'),
               'sysdate + 360');
    commit;
  exception
    when others then
      rollback;
      raise;
  end;

  --jobִ�п���
  --SQL> show parameter job;
  --SQL> ALTER SYSTEM SET JOB_QUEUE_PROCESSES = 20;
  procedure SetCal(p_time in varchar2) is
    starttime date;
    curdate   date;
    v_count   number;
  begin
    curdate := sysdate;
    for j in (select job, what from user_jobs) loop
      if Lower(j.what) = 'pg_meterread.autosubmit;' then
        select count(*)
          into v_count
          from dba_jobs_running t
         where t.JOB = j.job;
        if v_count = 0 then
          job_remove(j.job);
        else
          raise_application_error(errcode,
                                  '�Զ����������ִ�У���ʱ����������ִ��ʱ�䣬���Ժ�����');
        end if;
      end if;
    end loop;

    starttime := to_date(to_char(sysdate, 'yyyymmdd') || ' ' || p_time,
                         'yyyymmdd hh24:mi:ss');
    if starttime < curdate then
      starttime := to_date(to_char(curdate + 1, 'yyyymmdd') || ' ' ||
                           p_time,
                           'yyyymmdd hh24:mi:ss');
    end if;
    job_submit('pg_meterread.autosubmit;',
               to_char(starttime, 'yyyymmdd hh24:mi:ss'),
               'sysdate+1');

    commit;
  exception
    when others then
      rollback;
      raise;
  end;

  --jobִ�п���
  --SQL> show parameter job;
  --SQL> ALTER SYSTEM SET JOB_QUEUE_PROCESSES = 20;
  procedure SetSavingPay(p_time in varchar2) is
    starttime date;
    curdate   date;
    v_count   number;
  begin
    curdate := sysdate;
    for j in (select job, what from user_jobs) loop
      if Lower(j.what) = 'pg_pay.������ʱԤ��ֿ�;' then
        select count(*)
          into v_count
          from dba_jobs_running t
         where t.JOB = j.job;
        if v_count = 0 then
          job_remove(j.job);
        else
          raise_application_error(errcode,
                                  'ÿ�ղ�����ʱԤ��ֿ�������ִ�У���ʱ����������ִ��ʱ�䣬���Ժ�����');
        end if;
      end if;
    end loop;

    starttime := to_date(to_char(sysdate, 'yyyymmdd') || ' ' || p_time,
                         'yyyymmdd hh24:mi:ss');
    if starttime < curdate then
      starttime := to_date(to_char(curdate + 1, 'yyyymmdd') || ' ' ||
                           p_time,
                           'yyyymmdd hh24:mi:ss');
    end if;
    job_submit('pg_pay.������ʱԤ��ֿ�;',
               to_char(starttime, 'yyyymmdd hh24:mi:ss'),
               'sysdate+1');

    commit;
  exception
    when others then
      rollback;
      raise;
  end;

  --jobִ�п���
  --SQL> show parameter job;
  --SQL> ALTER SYSTEM SET JOB_QUEUE_PROCESSES = 20;
  procedure SetDz(p_time in varchar2) is
    --ע�⣺��������ÿ��24:00ǰ��������
    starttime date;
    curdate   date;
    v_count   number;
  begin
    curdate := sysdate;
    for j in (select job, what from user_jobs) loop
      if instr(Lower(j.what), 'sp_auto_bankdz') > 0 then
        select count(*)
          into v_count
          from dba_jobs_running t
         where t.JOB = j.job;
        if v_count = 0 then
          job_remove(j.job);
        else
          raise_application_error(errcode,
                                  '�Զ����ն���������ִ�У���ʱ����������ִ��ʱ�䣬���Ժ�����');
        end if;
      end if;
    end loop;

    starttime := to_date(to_char(sysdate, 'yyyymmdd') || ' ' || p_time,
                         'yyyymmdd hh24:mi:ss');
    if starttime < curdate then
      starttime := to_date(to_char(curdate + 1, 'yyyymmdd') || ' ' ||
                           p_time,
                           'yyyymmdd hh24:mi:ss');
    end if;
    job_submit('sp_auto_bankdz(to_char(sysdate-1,''yyyymmdd''),to_char(sysdate-1,''yyyymmdd''));',
               to_char(starttime, 'yyyymmdd hh24:mi:ss'),
               'sysdate+1');
    commit;
  exception
    when others then
      rollback;
      raise;
  end;

  --jobִ�п���
  --SQL> show parameter job;
  --SQL> ALTER SYSTEM SET JOB_QUEUE_PROCESSES = 20;
  procedure SetClearTransLog(p_time in varchar2) is
    --
    starttime date;
    curdate   date;
    v_count   number;
  begin
    curdate := sysdate;
    for j in (select job, what from user_jobs) loop
      if instr(Lower(j.what), 'proc_bank_tran_log;') > 0 then
        select count(*)
          into v_count
          from dba_jobs_running t
         where t.JOB = j.job;
        if v_count = 0 then
          job_remove(j.job);
        else
          raise_application_error(errcode,
                                  '�Զ�������־ת��������ִ�У���ʱ����������ִ��ʱ�䣬���Ժ�����');
        end if;
      end if;
    end loop;

    starttime := to_date(to_char(sysdate, 'yyyymmdd') || ' ' || p_time,
                         'yyyymmdd hh24:mi:ss');
    if starttime < curdate then
      starttime := to_date(to_char(curdate + 1, 'yyyymmdd') || ' ' ||
                           p_time,
                           'yyyymmdd hh24:mi:ss');
    end if;
    job_submit('proc_bank_tran_log;',
               to_char(starttime, 'yyyymmdd hh24:mi:ss'),
               'sysdate+1');
    commit;
  exception
    when others then
      rollback;
      raise;
  end;

  --jobִ�п���
  --SQL> show parameter job;
  --SQL> ALTER SYSTEM SET JOB_QUEUE_PROCESSES = 20;
  ----��װ�ӿڱ��Ӧ���ر�ÿ��ˢ��
  procedure SetRefmv(p_time in varchar2) is
    starttime date;
    curdate   date;
    v_count   number;
  begin
    curdate := sysdate;
    for j in (select job, what from user_jobs) loop
      if Lower(j.what) = 'sp_copybztable;' then
        select count(*)
          into v_count
          from dba_jobs_running t
         where t.JOB = j.job;
        if v_count = 0 then
          job_remove(j.job);
        else
          raise_application_error(errcode,
                                  '��װ���ݵ�����ִ�У���ʱ����������ִ��ʱ�䣬���Ժ�����');
        end if;
      end if;
    end loop;

    starttime := to_date(to_char(sysdate, 'yyyymmdd') || ' ' || p_time,
                         'yyyymmdd hh24:mi:ss');
    if starttime < curdate then
      starttime := to_date(to_char(curdate + 1, 'yyyymmdd') || ' ' ||
                           p_time,
                           'yyyymmdd hh24:mi:ss');
    end if;
    job_submit('SP_COPYBZTABLE;',
               to_char(starttime, 'yyyymmdd hh24:mi:ss'),
               'sysdate+1');

    commit;
  exception
    when others then
      rollback;
      raise;
  end;

  --�ճ�����
  procedure Carryover is
    vScrDate  varchar2(10);
    vDesDate  varchar2(10);
    vScrMonth varchar2(7);
    vDesMonth varchar2(7);
    vCurMonth varchar2(7);
    vCurDate  varchar2(10);
  begin
  null;
  /*  --���㱨��ʵʱ�ȶ���˿����ȥ��
    begin
      for i in (select smfid
                  from sysmanaframe
                 where smftype = '1'
                   and smfstatus = 'Y'
                   and rownum = 1) loop
        select smppvalue
          into vCurDate
          from sysmanapara
         where smppid = '000014'
           and smpid = i.smfid;
        CMDPUSH('pg_report.DailyRefresh',
                '''' || vCurDate || ''',''' || vCurDate || '''');
        CMDPUSH('pg_report.PdbRefresh',
                '''' || vCurDate || ''',''' || vCurDate || '''');
        select smppvalue
          into vCurMonth
          from sysmanapara
         where smppid = '000010'
           and smpid = i.smfid;
        CMDPUSH('pg_report.MonthlyRefresh',
                '''' || vCurMonth || ''',''' || vCurMonth || '''');
        CMDPUSH('pg_report.PmbRefresh',
                '''' || vCurMonth || ''',''' || vCurMonth || '''');
      end loop;
    exception
      when others then
        null;
    end;

    --�ս��������ڣ�ʵ���·�
    update sysmanapara t
       set smppvalue =
           (select smppvalue
              from sysmanapara tt
             where smppid = '000013'
               and t.smpid = tt.smpid)
     where smppid = '000011'
       and smpid in (select smfid
                       from sysmanaframe
                      where smftype = '1'
                         or smftype = '3');
    update sysmanapara t
       set smppvalue =
           (select smppvalue
              from sysmanapara tt
             where smppid = '000014'
               and t.smpid = tt.smpid)
     where smppid = '000012'
       and smpid in (select smfid
                       from sysmanaframe
                      where smftype = '1'
                         or smftype = '3');
    update sysmanapara t
       set smppvalue =
           (select smppvalue
              from sysmanapara tt
             where smppid = '000002'
               and t.smpid = tt.smpid)
     where smppid = '000001'
       and smpid in (select smfid
                       from sysmanaframe
                      where smftype = '1'
                         or smftype = '3');
    --
    update sysmanapara
       set smppvalue = to_char(to_date(smppvalue, 'yyyy.mm.dd') + 1,
                               'yyyy.mm.dd')
     where smppid = '000013'
       and smpid in (select smfid
                       from sysmanaframe
                      where smftype = '1'
                         or smftype = '3');
    update sysmanapara
       set smppvalue = to_char(to_date(smppvalue, 'yyyy.mm.dd') + 1,
                               'yyyy.mm.dd')
     where smppid = '000014'
       and smpid in (select smfid
                       from sysmanaframe
                      where smftype = '1'
                         or smftype = '3');
    update sysmanapara
       set smppvalue = to_char(to_date(smppvalue, 'yyyy.mm.dd') + 1,
                               'yyyy.mm.dd')
     where smppid = '000002'
       and smpid in (select smfid
                       from sysmanaframe
                      where smftype = '1'
                         or smftype = '3');
    --Ӧ���½�
    if to_char(sysdate - 1, 'dd') = (case
                                       when fsyspara('1066') = '0' then
                                        to_char(last_day(sysdate - 1), 'dd')
                                       else
                                        fsyspara('1066')
                                     end) then
      update sysmanapara t
         set smppvalue =
             (select smppvalue
                from sysmanapara tt
               where smppid = '000008'
                 and t.smpid = tt.smpid)
       where smppid = '000004'
         and smpid in (select smfid
                         from sysmanaframe
                        where smftype = '1'
                           or smftype = '3');
      update sysmanapara
         set smppvalue = to_char(add_months(to_date(smppvalue, 'yyyy.mm'), 1),
                                 'yyyy.mm')
       where smppid = '000008'
         and smpid in (select smfid
                         from sysmanaframe
                        where smftype = '1'
                           or smftype = '3');
      --
      begin
        select distinct smppvalue
          into vScrMonth
          from sysmanapara
         where smppid = '000004'
           and smpid in (select smfid
                           from sysmanaframe
                          where smftype = '1'
                             or smftype = '3');
        select distinct smppvalue
          into vDesMonth
          from sysmanapara
         where smppid = '000008'
           and smpid in (select smfid
                           from sysmanaframe
                          where smftype = '1'
                             or smftype = '3');
      exception
        when others then
          null;
      end;
      CMDPUSH('pg_report.InitMonthly',
              '''' || vScrMonth || ''',''' || vDesMonth || ''',''R''');
      --ˮ��ͳ��ͬ����Ӧ���½�����
      CMDPUSH('pg_custmeter.Initmeter_static',''''||vScrMonth||''','''||vDesMonth||'''');
      --����Ƿ�ѽ����ϸ
      CMDPUSH('pg_fee.backup',''''||vScrMonth||'''');
    end if;
    --ʵ���½�
    if to_char(sysdate - 1, 'dd') = (case
                                       when fsyspara('1071') = '0' then
                                        to_char(last_day(sysdate - 1), 'dd')
                                       else
                                        fsyspara('1071')
                                     end) then
      update sysmanapara t
         set smppvalue =
             (select smppvalue
                from sysmanapara tt
               where smppid = '000007'
                 and t.smpid = tt.smpid)
       where smppid = '000003'
         and smpid in (select smfid
                         from sysmanaframe
                        where smftype = '1'
                           or smftype = '3');
      update sysmanapara t
         set smppvalue =
             (select smppvalue
                from sysmanapara tt
               where smppid = '000010'
                 and t.smpid = tt.smpid)
       where smppid = '000006'
         and smpid in (select smfid
                         from sysmanaframe
                        where smftype = '1'
                           or smftype = '3');
      update sysmanapara
         set smppvalue = to_char(add_months(to_date(smppvalue, 'yyyy.mm'), 1),
                                 'yyyy.mm')
       where smppid = '000007'
         and smpid in (select smfid
                         from sysmanaframe
                        where smftype = '1'
                           or smftype = '3');
      update sysmanapara
         set smppvalue = to_char(add_months(to_date(smppvalue, 'yyyy.mm'), 1),
                                 'yyyy.mm')
       where smppid = '000010'
         and smpid in (select smfid
                         from sysmanaframe
                        where smftype = '1'
                           or smftype = '3');
      --
      begin
        select distinct smppvalue
          into vScrMonth
          from sysmanapara
         where smppid = '000006'
           and smpid in (select smfid
                           from sysmanaframe
                          where smftype = '1'
                             or smftype = '3');
        select distinct smppvalue
          into vDesMonth
          from sysmanapara
         where smppid = '000010'
           and smpid in (select smfid
                           from sysmanaframe
                          where smftype = '1'
                             or smftype = '3');
      exception
        when others then
          null;
      end;
      CMDPUSH('pg_report.InitMonthly',
              '''' || vScrMonth || ''',''' || vDesMonth || ''',''P''');
      CMDPUSH('pg_report.InitPaymentmonbal',
              '''' || vScrMonth || ''',''' || vDesMonth || '''');
    end if;
    commit; --��֤��ʱ���

    --���ɱ���
    CMDPUSH('pg_generate.Generate$ˮ���ձ�',''''||vCurDate||'''');
    commit;

    --Ӧʱ�ս���ʼ��
    begin
      for i in (select smfid
                  from sysmanaframe
                 where smftype = '1'
                   and smfstatus = 'Y'
                   and rownum = 1) loop
        select smppvalue
          into vScrDate
          from sysmanapara
         where smppid = '000012'
           and smpid = i.smfid;
        select smppvalue
          into vDesDate
          from sysmanapara
         where smppid = '000014'
           and smpid = i.smfid;
        CMDPUSH('pg_report.InitDaily',
                '''' || vScrDate || ''',''' || vDesDate || '''');
        CMDPUSH('pg_report.InitPaymentdaybal',
                'to_date(''' || vScrDate || ''',''yyyy.mm.dd''),to_date(''' ||
                vDesDate || ''',''yyyy.mm.dd'')');
      end loop;
    exception
      when others then
        null;
    end;

    --���㱨��ʵʱ�ȶ���˿����ȥ��
    CMDPUSH('pg_report.ˮ��Ƿ�ѳ�ʼ��', '');

    commit;*/

   /* --Ʊ���ս�
    begin
      --pg_invmanage.P_invdailybalance('X');--�ֽ�Ʊ
      pg_invmanage.P_invdailybalance('P'); --��̨��Ʊ
      --pg_invmanage.P_invdailybalance('T');--���շ�Ʊ
      --pg_invmanage.P_invdailybalance('D');--���۷�Ʊ
      --pg_invmanage.P_invdailybalance('Z');--��ֵ˰Ʊ
      pg_invmanage.P_invdailybalance('W'); --��ˮ��Ʊ
      --pg_invmanage.P_invdailybalance('S');--Ԥ�淢Ʊ
    exception
      when others then
        null;
    end;*/

    --��̨ʵ��/ΥԼ���ս�
    /*begin
    --pg_paydaybal.p_paydaybal();
    pg_paydaybal.p_payznjdaybal();
    exception when others then
    null;
    end;*/

    /*begin
    ����Ա�շ��ʿ������ݸ���;
    exception when others then
    null;
    end;*/

    /*begin
    Ƿ���м�����;
    exception when others then
    null;
    end;*/

    --ˮ�����ͳ���ս�ת

    commit;
  exception
    when others then
      rollback;
  end;

  --jobִ�п���
  --SQL> show parameter job;
  --SQL> ALTER SYSTEM SET JOB_QUEUE_PROCESSES = 20;
  --����Ƿ���ս�桢����ָ��
  procedure SetCarryFee(p_time in varchar2) is
    starttime date;
    curdate date;
    v_count number;
  begin
    curdate := sysdate;
    for j in (select job,what from user_jobs) loop
      if Lower(j.what)='pg_job.carryfee;' then
         select count(*)
           into v_count
           from dba_jobs_running  t
          where t.JOB = j.job;
         if v_count=0 then
           job_remove(j.job);
         else
           raise_application_error(errcode, '����Ƿ���ս�桢����ָ�������ִ�У���ʱ����������ִ��ʱ�䣬���Ժ�����');
         end if;
      end if;
    end loop;

    starttime := to_date(to_char(sysdate,'yyyymmdd')||' '||p_time,'yyyymmdd hh24:mi:ss');
    if starttime<curdate then
       starttime := to_date(to_char(curdate+1,'yyyymmdd')||' '||p_time,'yyyymmdd hh24:mi:ss');
    end if;
    job_submit('pg_job.CarryFee;',to_char(starttime,'yyyymmdd hh24:mi:ss'),'sysdate+1');

    commit;
  exception when others then
    rollback;
    raise;
  end;

  procedure CarryFee is
  begin
    CMDPUSH('execute immediate ''truncate table snapshotday$reclist''','');
    CMDPUSH('execute immediate ''truncate table snapshotday$recdetail''','');
    CMDPUSH('pg_report.ˮ��Ƿ������','');
    --����ʵʱǷ����ϸ�����
    CMDPUSH('pg_report.ˮ��Ƿ�ѳ�ʼ��','');
    commit;
  exception when others then
    rollback;
  end;

begin
  null;
end pg_job;
/

