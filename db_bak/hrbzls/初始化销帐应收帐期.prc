CREATE OR REPLACE PROCEDURE HRBZLS."初始化销帐应收帐期" as
  --2010.7.19 at whzls by jh
  cursor c_pl is
  select plid,plrlid from paidlist;

  vplid varchar2(10);
  vrlid varchar2(10);
  vrlmonth varchar2(10);
  vrldate date;
begin
  open c_pl;
  loop
    fetch c_pl into vplid,vrlid;
    exit when c_pl%notfound or c_pl%notfound is null;
    begin
      select rlmonth,rldate into vrlmonth,vrldate from reclist where rlid=vrlid;
    exception when no_data_found then
      vrlmonth := null;
      vrldate  := null;
    when others then
      raise;
    end;

    update paidlist set plrlmonth=vrlmonth,plrldate=vrldate where plid=vplid;

    if mod(c_pl%rowcount,1000)=0 then
      commit;
    end if;
  end loop;
  close c_pl;

  commit;
exception when others then
  raise;
end ;
/

