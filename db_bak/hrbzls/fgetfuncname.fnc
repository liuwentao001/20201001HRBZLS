CREATE OR REPLACE FUNCTION HRBZLS."FGETFUNCNAME" (funcid in varchar2) return varchar2
as
  funcname varchar2(100);
begin
    select ef.efname into funcname   from erpfunction ef where trim(ef.efid)=trim(funcid);
   return funcname;
   exception
     when others then
       return null;
 end;
/

