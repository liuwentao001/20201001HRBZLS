CREATE OR REPLACE PROCEDURE HRBZLS."SP_FGETHADINV" (p_per in varchar2,
o_base out tools.out_base ) is

begin
 open o_base for
 select
 pg_ewide_invmanage_01.fgethadinv(p_per)   from dual;



end;
/

