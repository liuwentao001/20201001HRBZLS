CREATE OR REPLACE PROCEDURE HRBZLS."DATAMOVE_RECLIST_UPDATE" is
  cursor c1 is
    select rlid,rlmid,rlrdate
      from reclist
     where rldate < to_date('20091001', 'yyyymmdd');
  v_rlid    varchar2(10);
  v_rlmid   varchar2(10);
  v_rlday   date;
  v_mrid    varchar2(10);
begin
  open c1;
  loop
    fetch c1
      into v_rlid,v_rlmid,v_rlday;

    exit when c1%notfound or c1%notfound is null;
    begin
      select mrid
        into v_mrid
        from meterreadhis
       where mrmid =v_rlmid and mrrdate>=trunc(v_rlday) and mrrdate<trunc(v_rlday)+1
         and rownum = 1;

      update reclist set rlmrid  = v_mrid where rlid = v_rlid;
      commit;
    exception
      when others then
        null;
    end;
  end loop;
  close c1;
exception
  when others then
    if c1%isopen then
      close c1;
    end if;
    rollback;
    raise_application_error('datamove_reclist_update' ||
                            to_char(v_mrid),
                            to_char(v_rlid) || sqlerrm);
end datamove_reclist_update;
/

