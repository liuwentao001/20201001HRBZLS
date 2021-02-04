CREATE OR REPLACE FUNCTION HRBZLS."FUPPERMONTH" (p_char IN CHAR ) --yyyy.mm
 RETURN VARCHAR2
AS
 LRET VARCHAR2(20);
BEGIN
 if to_number(substr(p_char,6,2)) <10 then
   select Fuppernum(substr(p_char,1,4))||'��'||Fuppernum(to_char(to_number(substr(p_char,6,2))) )||'��'
     into LRET
     from dual;
 else
   select Fuppernum(substr(p_char,1,4))||'��'||'ʮ'||Fuppernum(to_char(to_number(substr(p_char,7,1))) )||'��'
       into LRET
       from dual;
 end if;
 RETURN LRET;
EXCEPTION WHEN OTHERS THEN
 RETURN NULL;
END;
/

