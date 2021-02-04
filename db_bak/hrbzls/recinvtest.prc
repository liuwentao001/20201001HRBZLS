CREATE OR REPLACE PROCEDURE HRBZLS."RECINVTEST" (
                  o_base out tools.out_base) is
  begin

    open o_base for

    select * from PBPARMTEMP
    ;

  end ;
/

