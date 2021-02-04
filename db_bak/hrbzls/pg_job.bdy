CREATE OR REPLACE PACKAGE BODY HRBZLS."PG_JOB" is

  function fwhatname(job_what in varchar2) return varchar2 as
  begin
    case lower(job_what)
      when 'pg_job.carryover;' then
        return '每日结转';
      when 'pg_job.autosubmit;' then
        return '每日自动算费';
      when 'sp_auto_dkfileexp;' then
        return '代扣导出';
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
                                  '顶级任务正执行，此时不能设置其执行时间，请稍后再试');
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

  --根据syspara中设定的计划执行时间重建所有job
  procedure Rebuildalljobs is
    sp syspara%rowtype;
  begin
    /*    --1058  代扣导出计划执行时间
    begin
    select * into sp from syspara where spid='1058';
    Setdkexp(sp.spvalue);
    end;*/

    /*    begin
    --1061  代扣导入计划执行时间
    select * into sp from syspara where spid='1061';
    Setdkimp(sp.spvalue);
    end;*/

    /*begin
      --1062  代收对帐计划执行时间
      select * into sp from syspara where spid = '1062';
      SetDz(sp.spvalue);
    end;*/

    /*begin
      --1063  自动算费计划执行时间
      select * into sp from syspara where spid = '1063';
      SetCal(sp.spvalue);
    end;*/

    begin
      --1064  日结计划执行时间
      select * into sp from syspara where spid = '1064';
      SetCarryover(sp.spvalue);
    end;

    /*begin
      --1065  代收交易日志转存
      select * into sp from syspara where spid = '1065';
      SetClearTransLog(sp.spvalue);
    end;*/

    /*begin
      --1068  报装接口表视图每日刷新
      select * into sp from syspara where spid = '1068';
      SetRefmv(sp.spvalue);
    end;*/

    /*begin
      --1073  补做预存即时抵扣
      select * into sp from syspara where spid = '1073';
      SetSavingPay(sp.spvalue);
    end;*/

    begin
    --1074	发出欠费日结存、分析指令集到数据挖掘服务器计划执行时间
    select * into sp from syspara where spid='1074';
    SetCarryFee(sp.spvalue);
    end;

  exception
    when others then
      raise;
  end;

  --job执行开启
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
                                  '每日结转任务正执行，此时不能设置其执行时间，请稍后再试');
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

  --job执行开启
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
                                  '代扣导出任务正执行，此时不能设置其执行时间，请稍后再试');
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

  --job执行开启
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
                                  '自动代扣导入任务正执行，此时不能设置其执行时间，请稍后再试');
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

  -- 设置自动对账操作导入

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
                                  '手工自动对账任务正执行，此时不能设置其执行时间，请稍后再试');
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
                                  '手工代扣导入任务正执行，此时不能设置其执行时间，请稍后再试');
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

  --手动设置代扣导出

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
                                  '手工代扣导入任务正执行，此时不能设置其执行时间，请稍后再试');
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

  --job执行开启
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
                                  '自动算费任务正执行，此时不能设置其执行时间，请稍后再试');
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

  --job执行开启
  --SQL> show parameter job;
  --SQL> ALTER SYSTEM SET JOB_QUEUE_PROCESSES = 20;
  procedure SetSavingPay(p_time in varchar2) is
    starttime date;
    curdate   date;
    v_count   number;
  begin
    curdate := sysdate;
    for j in (select job, what from user_jobs) loop
      if Lower(j.what) = 'pg_pay.补做即时预存抵扣;' then
        select count(*)
          into v_count
          from dba_jobs_running t
         where t.JOB = j.job;
        if v_count = 0 then
          job_remove(j.job);
        else
          raise_application_error(errcode,
                                  '每日补做即时预存抵扣任务正执行，此时不能设置其执行时间，请稍后再试');
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
    job_submit('pg_pay.补做即时预存抵扣;',
               to_char(starttime, 'yyyymmdd hh24:mi:ss'),
               'sysdate+1');

    commit;
  exception
    when others then
      rollback;
      raise;
  end;

  --job执行开启
  --SQL> show parameter job;
  --SQL> ALTER SYSTEM SET JOB_QUEUE_PROCESSES = 20;
  procedure SetDz(p_time in varchar2) is
    --注意：参数设置每晚24:00前对帐昨日
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
                                  '自动代收对帐任务正执行，此时不能设置其执行时间，请稍后再试');
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

  --job执行开启
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
                                  '自动代收日志转存任务正执行，此时不能设置其执行时间，请稍后再试');
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

  --job执行开启
  --SQL> show parameter job;
  --SQL> ALTER SYSTEM SET JOB_QUEUE_PROCESSES = 20;
  ----报装接口表对应本地表每日刷新
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
                                  '报装数据导入正执行，此时不能设置其执行时间，请稍后再试');
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

  --日初事务
  procedure Carryover is
    vScrDate  varchar2(10);
    vDesDate  varchar2(10);
    vScrMonth varchar2(7);
    vDesMonth varchar2(7);
    vCurMonth varchar2(7);
    vCurDate  varchar2(10);
  begin
  null;
  /*  --重算报表，实时稳定后此块可以去掉
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

    --日结帐务日期，实收月份
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
    --应收月结
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
      --水表统计同步于应收月结周期
      CMDPUSH('pg_custmeter.Initmeter_static',''''||vScrMonth||''','''||vDesMonth||'''');
      --保存欠费结存明细
      CMDPUSH('pg_fee.backup',''''||vScrMonth||'''');
    end if;
    --实收月结
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
    commit; --保证及时完成

    --生成报表
    CMDPUSH('pg_generate.Generate$水量日报',''''||vCurDate||'''');
    commit;

    --应时收结存初始化
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

    --重算报表，实时稳定后此块可以去掉
    CMDPUSH('pg_report.水表欠费初始化', '');

    commit;*/

   /* --票据日结
    begin
      --pg_invmanage.P_invdailybalance('X');--现金发票
      pg_invmanage.P_invdailybalance('P'); --柜台发票
      --pg_invmanage.P_invdailybalance('T');--托收发票
      --pg_invmanage.P_invdailybalance('D');--代扣发票
      --pg_invmanage.P_invdailybalance('Z');--增值税票
      pg_invmanage.P_invdailybalance('W'); --排水发票
      --pg_invmanage.P_invdailybalance('S');--预存发票
    exception
      when others then
        null;
    end;*/

    --柜台实收/违约金日结
    /*begin
    --pg_paydaybal.p_paydaybal();
    pg_paydaybal.p_payznjdaybal();
    exception when others then
    null;
    end;*/

    /*begin
    抄表员收费率考核数据更新;
    exception when others then
    null;
    end;*/

    /*begin
    欠费中间表更新;
    exception when others then
    null;
    end;*/

    --水表情况统计日结转

    commit;
  exception
    when others then
      rollback;
  end;

  --job执行开启
  --SQL> show parameter job;
  --SQL> ALTER SYSTEM SET JOB_QUEUE_PROCESSES = 20;
  --发出欠费日结存、分析指令
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
           raise_application_error(errcode, '发出欠费日结存、分析指令集任务正执行，此时不能设置其执行时间，请稍后再试');
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
    CMDPUSH('pg_report.水表欠费日照','');
    --重算实时欠费明细表汇总
    CMDPUSH('pg_report.水表欠费初始化','');
    commit;
  exception when others then
    rollback;
  end;

begin
  null;
end pg_job;
/

