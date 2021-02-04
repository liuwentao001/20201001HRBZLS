CREATE OR REPLACE PROCEDURE HRBZLS."WX_MA" is
    /*mi meterinfo%rowtype;
    ci custinfo%rowtype;*/
    ma meteraccount%rowtype;
  begin

    delete meteraccount;

    for i in (select * from meterinfo) loop
      ma.mamid         := i.miid;--水表资料号
      select ciname  into ma.maaccountname from custinfo where  ciid=i.micid;--
      ma.maaccountno   := i.micode;--
      ma.mamicode         := i.micode;--资料号

    insert into meteraccount values ma;
    commit;
    end loop;

    exception when others then
    raise_application_error(-20010,sqlerrm||'kkkkkk'||ma.mamid );
    rollback;

  end;
/

