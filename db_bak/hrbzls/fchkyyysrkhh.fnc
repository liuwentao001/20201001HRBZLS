CREATE OR REPLACE FUNCTION HRBZLS."FCHKYYYSRKHH" (p_micode in varchar2)

   return varchar2
as
  v_count number;
begin
    select count(miid) into v_count from meterinfo where micode=p_micode;
    if v_count<1 then
       return 'N';
    end if;
    select count(*) into v_count from sysmanapara where  smppid='YYYSRKHH' and smppvalue=p_micode;
    if v_count>0 then
       return 'Y';
    else
       return 'N';
    end if;
exception when others then
   return 'N';
end;
/

