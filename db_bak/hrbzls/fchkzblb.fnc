CREATE OR REPLACE FUNCTION HRBZLS."FCHKZBLB" (p_type in varchar2)

   return varchar2
as
  v_count number;
begin
     if p_type in ('01','14','15','16','17') then
        return 'Y';
     else
        return 'N';
     end if;
exception when others then
   return 'N';
end;
/

