CREATE OR REPLACE FUNCTION HRBZLS."FGETISCANCEL" (p_pid IN VARCHAR2,p_oper in varchar2)
  RETURN VARCHAR2 AS
  v_y varchar2(2);
  v_ppayee varchar2(20);
  v_pdate date;
BEGIN
  v_y :='N';
   select ppayee,pdatetime into v_ppayee,v_pdate
  from payment t
   where pid = p_pid
   AND PCD='DE';

   if v_ppayee = p_oper and trunc(v_pdate)=trunc(sysdate) then
     v_y := 'Y';
   end if;

return v_y;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'N';
END;
/

