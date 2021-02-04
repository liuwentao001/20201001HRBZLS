CREATE OR REPLACE PROCEDURE HRBZLS."DATATRANS_DAILYPAYEE" (p_sdate   varchar2,
                                                 p_edate   varchar2,
                                                 p_chkdate varchar2) is
  cursor c1 is
    select pid
      from payment
     where pdate >= to_date(p_sdate, 'yyyymmdd')
       and pdate < to_date(p_edate, 'yyyymmdd')
       and (pcchkflag is null or pcchkflag <> '1')
       and (ptrans = 'P' or ptrans = 'S')
       and pcd = 'DE';

  cursor c2 is
    select cfid
      from changefund
     where cfdate >= to_date(p_sdate, 'yyyymmdd')
       and cfdate < to_date(p_edate, 'yyyymmdd')
       and (cfchkflag is null or cfchkflag <> '1')
       and cfact = 'L';

  v_pid  varchar2(100);
  v_cfid varchar2(100);
begin

  --实收
  open c1;
  loop
    fetch c1
      into v_pid;
    exit when c1%notfound or c1%notfound is null;

    update payment
       set pcchkflag = '1', pchkdate = to_date(p_chkdate, 'yyyymmdd')
     where pid = v_pid;

    if mod(c1%rowcount, 1000) = 0 then
      commit;
    end if;

  end loop;
  close c1;

  --备用金
  open c2;
  loop
    fetch c2
      into v_cfid;
    exit when c2%notfound or c2%notfound is null;

    update changefund
       set cfchkflag = '1', cfchkdate = to_date(p_chkdate, 'yyyymmdd')
     where cfid = v_cfid;

    if mod(c2%rowcount, 1000) = 0 then
      commit;
    end if;

  end loop;
  close c2;

  commit;
exception
  when others then
    if c1%isopen then
      close c1;
    end if;
    if c2%isopen then
      close c2;
    end if;

    rollback;
    raise_application_error(-20012, sqlerrm || sqlcode);
end datatrans_dailypayee;
/

