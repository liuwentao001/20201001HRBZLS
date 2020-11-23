CREATE OR REPLACE FUNCTION uuid  RETURN char AS
  v_method varchar2(32);
BEGIN
 
   v_method := sys_guid();
   return v_method ; 
EXCEPTION
  WHEN OTHERS THEN
    RETURN sys_guid();
END;
/

