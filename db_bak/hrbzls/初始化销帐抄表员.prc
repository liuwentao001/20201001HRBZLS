CREATE OR REPLACE PROCEDURE HRBZLS."初始化销帐抄表员" as
--销帐记录抄表员取当前抄表员，进行收费率统计2010.7.19 at whzls by jh
  cursor c_pl is
  select pmid,plid,plrlid from payment,paidlist
  where pid=plpid;
  vmid varchar2(10);
  vplid varchar2(10);
  vrper varchar2(10);
  vrlid varchar2(10);
begin
  open c_pl;
  loop
    fetch c_pl into vmid,vplid,vrlid;
    exit when c_pl%notfound or c_pl%notfound is null;
    begin
      select bfrper into vrper from meterinfo,bookframe
      where mibfid=bfid and mismfid=bfsmfid and bfstatus='Y' and miid=vmid;
    exception when no_data_found then
      begin
        select rlrper into vrper from reclist where rlid=vrlid;
      exception when others then
        vrper := null;
      end;
    when others then
      raise;
    end;

    update paidlist set plrper=vrper where plid=vplid;

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

