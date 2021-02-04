CREATE OR REPLACE FUNCTION HRBZLS."FGETNOTESQE"

        RETURN varchar2
AS
v_str varchar2(10);
 BEGIN
	select 	seq_wmis_noteid.nextval into v_str from dual;
 return v_str;
END;
/

