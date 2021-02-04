CREATE OR REPLACE FUNCTION HRBZLS."FGETFUNCVER" (p_name in varchar2) return varchar2
is
  v_count number;
begin

select count(*)
    into v_count
  from erpfuncver ef
 where (ef.funcname like '%' || p_name || '%' or p_name  like '%' || ef.funcname  || '%');
  if v_count=0 then
     return 'Y';
   end if;

   select count(*)
    into v_count
  from erpfuncver ef
 where (ef.funcname like '%' || p_name || '%' or p_name  like '%' || ef.funcname  || '%')
 and ef.flag='1';

    if v_count>0 then
     return 'Y';

   end if;
   return 'N';
   exception
    when  others then
      return 'Y';
end;
/

