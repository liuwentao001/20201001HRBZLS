CREATE OR REPLACE FUNCTION HRBZLS."FUPPERNUM" (p_char IN CHAR )
 RETURN VARCHAR2
AS
 LRET VARCHAR2(20);
BEGIN
 select --translate(p_char,'0123456789-','��Ҽ��������½��ƾ�-')
        translate(p_char,'0123456789-','��һ�����������߰˾�')
   INTO LRET
   from dual;
 RETURN LRET;
EXCEPTION WHEN OTHERS THEN
 RETURN NULL;
END;
/

