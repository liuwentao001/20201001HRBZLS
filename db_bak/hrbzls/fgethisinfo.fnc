CREATE OR REPLACE FUNCTION HRBZLS."FGETHISINFO"
   (p_mon IN VARCHAR2,p_id IN VARCHAR2,p_type IN VARCHAR2)
   Return NUMBER
AS
   lret   NUMBER;
   vcount NUMBER;
   vdate  VARCHAR2(7);
   vlastdate DATE;
BEGIN
    CASE p_type
       WHEN 'THREEMONTH' THEN
       select TO_CHAR(add_months(to_date(p_mon,'yyyy.mm'),- 3),'YYYY.MM')
       INTO vdate from dual;
       select count(*) into vcount from METERREADHIS t
        where t.mrmonth < p_mon and t.mrmonth > vdate AND mrmid = p_id;
       If vcount > 0 Then
         select sum(mrsl) into lret from METERREADHIS t
          where t.mrmonth < p_mon and t.mrmonth > vdate AND mrmid = p_id;
         If lret <> 0  Then
            lret := lret / 3;
         End If;
       Else
         lret := 0;
       End If;
       WHEN 'SIXMONTH' THEN
       select TO_CHAR(add_months(to_date(p_mon,'yyyy.mm'),- 6),'YYYY.MM')
         INTO vdate from dual;
       select count(*) into vcount from METERREADHIS t
        where t.mrmonth < p_mon and t.mrmonth > vdate AND mrmid = p_id;
       If vcount > 0 Then
         select sum(mrsl) into lret from METERREADHIS t
          where t.mrmonth < p_mon and t.mrmonth > vdate AND mrmid = p_id;
         If lret <> 0  Then
            lret := lret / 6;
         End If;
       Else
         lret := 0;
       End If;
       WHEN 'SIXMAX' THEN
       select TO_CHAR(add_months(to_date(p_mon,'yyyy.mm'),- 6),'YYYY.MM')
         INTO vdate from dual;
       select count(*) into vcount from METERREADHIS t
        where t.mrmonth < p_mon and t.mrmonth > vdate AND mrmid = p_id;
       If vcount > 0 Then
         select MAX(mrsl) into lret from METERREADHIS t
          where t.mrmonth < p_mon and t.mrmonth > vdate AND mrmid = p_id;
       Else
         lret := 0;
       End If;
       WHEN 'LASTYEAR' THEN
       select TO_CHAR(add_months(to_date(p_mon,'yyyy.mm'),- 12),'YYYY.MM')
         INTO vdate from dual;
       select count(*) into vcount from METERREADHIS t
        where t.mrmonth = vdate AND mrmid = p_id;
       If vcount > 0 Then
         select mrsl into lret from METERREADHIS t
          where t.mrmonth = vdate AND mrmid = p_id;
       Else
         lret := 0;
       End If;
       WHEN 'LASTMONTH' THEN
       select TO_CHAR(add_months(to_date(p_mon,'yyyy.mm'),- 1),'YYYY.MM')
         INTO vdate from dual;
       select count(*) into vcount from METERREADHIS t
        where t.mrmonth = vdate AND mrmid = p_id;
       If vcount > 0 Then
         select mrsl into lret from METERREADHIS t
          where t.mrmonth = vdate AND mrmid = p_id;
       Else
         lret := 0;
       End If;
       WHEN 'WCJNUM' THEN
       select mrprdate into vlastdate from METERREAD t
        where t.mrmonth = vdate AND mrmid = p_id;
       select count(*) into lret from METERREADHIS t
        where t.mrprdate > vlastdate AND mrmid = p_id;
       ELSE Return 0;
    END CASE;
    return lret;
EXCEPTION WHEN OTHERS THEN
   Return 0;
END fgetHISinfo;
/

