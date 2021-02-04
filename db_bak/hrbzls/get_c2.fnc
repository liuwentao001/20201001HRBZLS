CREATE OR REPLACE FUNCTION HRBZLS."GET_C2" (tmp_c1 in varchar2)
RETURN VARCHAR2
IS
v_c2 VARCHAR2(4000);
BEGIN
FOR cur IN (SELECT t.oaname FROM operaccnt t  WHERE t.oaid=tmp_c1) LOOP
v_c2 := v_c2||cur.oaname;
END LOOP;
v_c2 := rtrim(v_c2,1);
RETURN v_c2;
END;
/

