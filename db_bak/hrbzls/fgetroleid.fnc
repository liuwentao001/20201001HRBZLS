CREATE OR REPLACE FUNCTION HRBZLS."FGETROLEID"
	RETURN VARCHAR2
AS
	lcount integer;
	i      integer;
  ls_i   CHAR(2);
BEGIN

For i in 1..99 loop
  ls_i :=lpad(i,2,0);
  select count(orid) into lcount from operrole  where orid = ls_i;
  If lcount = 0 Then
     Return ls_i;
  End If;
end loop;
END;
/

