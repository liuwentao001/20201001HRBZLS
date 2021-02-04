CREATE OR REPLACE FUNCTION HRBZLS."F_IVR_MSG" (P_ACTID IN NUMBER,P_IN VARCHAR2) return varchar2 is
  Result VARCHAR2(500);
begin
  IF P_ACTID=12 THEN
    RESULT:=P_IN;
    return(Result);
  END IF;

  IF P_ACTID=20 THEN
    RESULT:='Ò¼ÍòÎåÇ§ÁãÈþÔª';
    RETURN result;
  END IF;

  IF P_ACTID=5 THEN
    RESULT:='XXXX'||P_IN||'.WAV';
    RETURN RESULT;
  END IF;
end F_IVR_MSG;
/

