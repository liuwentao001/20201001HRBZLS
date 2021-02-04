CREATE OR REPLACE FUNCTION HRBZLS."FGETGTIFFP" (P_pbatch IN VARCHAR2)
 RETURN VARCHAR2
AS
 LRET VARCHAR2(40);
BEGIN
 select nvl(fgetsysmanapara(max(pposition),'IFFP'),'Y')
   INTO LRET
   from payment where pbatch=P_pbatch and ptrans='D';
 RETURN LRET;
EXCEPTION WHEN OTHERS THEN
 RETURN NULL;
END;
/

