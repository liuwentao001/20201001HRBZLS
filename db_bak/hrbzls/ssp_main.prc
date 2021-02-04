CREATE OR REPLACE PROCEDURE HRBZLS."SSP_MAIN" (p_str_in  in varchar2,
                    p_str_out out varchar2
                    )    is
    i number:=0;

  begin


    p_str_out := pg_ewide_bankTuxedo_01.main(p_str_in);

  end ;
/

