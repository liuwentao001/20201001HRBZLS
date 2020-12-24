create or replace function fchkmeterneedcharge(vmstatus in varchar2,vifchk in varchar2,vmtype in varchar2) return char as
lret char(1);
begin
   if vifchk='Y' then return 'N'; end if;
   select smtifcharge into lret from sysmetertype where smtid=vmtype;
   if lret='N' then  return 'N'; end if;
   return 'Y';
exception when others then
   return 'N';
end;
/

