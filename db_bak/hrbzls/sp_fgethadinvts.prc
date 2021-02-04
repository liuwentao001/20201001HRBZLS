CREATE OR REPLACE PROCEDURE HRBZLS."SP_FGETHADINVTS" (p_per in varchar2,
o_base out tools.out_base ) is

begin
 open o_base for
 select
 pg_ewide_invmanage_01.fgethadinvTS(p_per)   from dual;

end;
/

