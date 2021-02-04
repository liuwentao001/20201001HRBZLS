CREATE OR REPLACE FUNCTION HRBZLS."FGETBILLID" (P_billid IN VARCHAR2)
 RETURN VARCHAR2
AS
 V_sql VARCHAR2(20000);
 V_RET VARCHAR2(20000);
BEGIN
  V_sql :=' select trim(to_char('||P_billid||'.nextval,''0000000000''))  from dual ' ;
    execute immediate V_sql into V_RET;
    RETURN   V_RET  ;
EXCEPTION WHEN OTHERS THEN
 RETURN NULL;
END;
/

