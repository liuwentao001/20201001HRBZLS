CREATE OR REPLACE FUNCTION F_ljf_month(p_pmicode in varchar2,
                                       p_month   in varchar2) RETURN number AS
  LCODE number(13, 3) := 0 ;
BEGIN

  /*select DECODE(RL_CD, 'DE', 1, -1) * rl_je
    into LCODE
    from zkzlsds.record_list
   where rl_mcode = p_pmicode
     and rl_month = p_month;*/

  RETURN LCODE;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END;
/

