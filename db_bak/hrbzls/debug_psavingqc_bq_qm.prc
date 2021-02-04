CREATE OR REPLACE PROCEDURE HRBZLS."DEBUG_PSAVINGQC_BQ_QM" is
  p payment%rowtype;
  v integer:=0;
begin
  for i in (select * from payment order by pmcode,pid) loop
    if p.psavingqm<>i.psavingqc and p.pmcode=i.pmcode then
      dbms_output.put_line(p.pmcode||':'||p.pid||'-'||i.pid);
      v := v + 1;
    end if;
    if i.psavingqc+i.psavingbq<>i.psavingqm then
      dbms_output.put_line(p.pmcode||':'||i.pid);
      v := v + 1;
    end if;
    p := i;
  end loop;
  if v=0 then
    dbms_output.put_line('PAYMENT关联交易间预存结转正确');
  end if;
  dbms_output.put_line('--------------------------------');
  v := 0;
  p := null;
  for i in (select pmcode,pdatetime,plsavingqc,plsavingqm from (
            select pmcode,pdatetime,plsavingqc,plsavingqm,plid from payment,paidlist where pid=plpid
            union all
            select pmcode,pdatetime,psavingqc,psavingqm,pid from payment where ptrans='S')
            order by pmcode,pdatetime,plid) loop
    if p.psavingqm<>i.plsavingqc and p.pmcode=i.pmcode then
      dbms_output.put_line(p.pmcode);
      v := v + 1;
    end if;
    p.pmcode := i.pmcode;
    p.psavingqm := i.plsavingqm;
  end loop;
  if v=0 then
    dbms_output.put_line('PAIDLIST关联交易间预存结转正确');
  end if;
exception when others then
  raise;
end debug_psavingqc_bq_qm;
/

