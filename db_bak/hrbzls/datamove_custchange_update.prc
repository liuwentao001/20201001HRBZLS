CREATE OR REPLACE PROCEDURE HRBZLS."DATAMOVE_CUSTCHANGE_UPDATE" is
  cursor c1 is
    select cchno
      from custchangehd
     where cchcredate < to_date('20091001', 'yyyymmdd');
  v_cchno  varchar2(12);
  v_micode varchar2(12);
  v_micid  varchar2(12);
begin
  open c1;
  loop
    fetch c1
      into v_cchno;

    exit when c1%notfound or c1%notfound is null;
    begin
      select m.micid, m.micode
        into v_micid, v_micode
        from meterinfo m, custchangedt t
       where m.micid = t.micid
         and t.ccdno = v_cchno
         and t.ccdrowno = 1
         and rownum = 1;

      update custchangedt set micode = v_micode where micid = v_micid;
      update custchangedthis set micode = v_micode where micid = v_micid;
    exception
      when others then
        null;
    end;

    if mod(c1%rowcount, 1000) = 0 then
      commit;
    end if;
  end loop;

  close c1;
  commit;
exception
  when others then
    if c1%isopen then
      close c1;
    end if;
    rollback;
    raise_application_error('datamove_custchange_update' ||
                            to_char(v_cchno),
                            to_char(v_cchno) || sqlerrm);
end datamove_custchange_update;
/

