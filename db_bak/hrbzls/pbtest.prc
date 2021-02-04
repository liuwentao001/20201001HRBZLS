CREATE OR REPLACE PROCEDURE HRBZLS."PBTEST" is

begin

delete OAPARMTEMP;
  insert into OAPARMTEMP
    (c1, c2)
    select mi.micode, mi.miname
      from meterinfo mi
      where
          micode in(select c1 from pbparmtemp);
end;
/

