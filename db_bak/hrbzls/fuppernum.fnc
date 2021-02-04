CREATE OR REPLACE FUNCTION HRBZLS."FUPPERNUM" (p_char IN CHAR )
 RETURN VARCHAR2
AS
 LRET VARCHAR2(20);
BEGIN
 select --translate(p_char,'0123456789-','零壹贰叁肆伍陆柒捌玖-')
        translate(p_char,'0123456789-','零一二三四五六七八九')
   INTO LRET
   from dual;
 RETURN LRET;
EXCEPTION WHEN OTHERS THEN
 RETURN NULL;
END;
/

