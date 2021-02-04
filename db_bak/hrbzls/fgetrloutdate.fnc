CREATE OR REPLACE FUNCTION HRBZLS."FGETRLOUTDATE" (v_pbatch in varchar2) return date
is
 v_ret  date;
begin
    select etl.ELOUTDATE into v_ret  from entrustlog etl where etl.elbatch=v_pbatch;
     return v_ret;
   exception
      when others then
             return null;
end ;
/

