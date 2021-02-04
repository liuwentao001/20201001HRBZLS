CREATE OR REPLACE PROCEDURE HRBZLS."SP_Î¬»¤µÍ±£" (p_miid in varchar2)  is

begin
  insert into priceadjustlist
 values (fgetsequence('PRICEADJUSTLIST'), '02', '02', '', '', p_miid, '', '', '', null, -1, fsyspara('1093'), '2010.12', '2080.12', 'Y', '', null, '', null,'','');

exception
   when others then
    null;
end;
/

