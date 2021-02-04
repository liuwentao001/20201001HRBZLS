CREATE OR REPLACE FUNCTION HRBZLS."FLOWOPERS" (v_id in VARCHAR2,v_no in VARCHAR2 ) RETURN VARCHAR2
IS
ret VARCHAR(3000);
BEGIN
     SELECT connstr (FOFOPER) INTO  ret FROM flow_oper_define WHERE fofid =v_id AND v_no=fofno;
     RETURN ret;
         EXCEPTION
             WHEN OTHERS THEN
                 RETURN NULL;
 END;
/

