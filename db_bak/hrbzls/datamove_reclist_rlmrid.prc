CREATE OR REPLACE PROCEDURE HRBZLS."DATAMOVE_RECLIST_RLMRID" is
  cursor c1 is
    select trim(mrid),trim(mrmemo)
      from meterreadhis;
  v_mrid    varchar2(10);
  v_mrmemo   varchar2(20);
begin
  open c1;
  loop
    fetch c1
      into v_mrid,v_mrmemo;

    exit when c1%notfound or c1%notfound is null;
    begin

      update reclist
      set rlmrid  = v_mrid
      where trim(rlaccountname) = v_mrmemo;
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
                            to_char(v_mrmemo) || sqlerrm);
end datamove_reclist_rlmrid;
/

