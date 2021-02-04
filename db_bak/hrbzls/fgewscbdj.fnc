CREATE OR REPLACE FUNCTION HRBZLS.FGEWSCBDJ (P_MIID IN VARCHAR2,p_mrmonth in varchar2 )
 RETURN number
AS
 v_dj number(12,3);
BEGIN
 SELECT nvl(SUM(nvl(T.PALWAY*T.PALVALUE,0)),0)
 INTO v_dj
 FROM priceadjustlist t
 WHERE t.palmid  = P_MIID
       AND t.palmethod='01'
       AND PALSTATUS = 'Y'
       AND PALSTARTMON <= p_mrmonth
       AND PALENDMON >= p_mrmonth;
 RETURN v_dj;
EXCEPTION WHEN OTHERS THEN
 RETURN 0;
END;
/

