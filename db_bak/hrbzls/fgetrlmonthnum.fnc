CREATE OR REPLACE FUNCTION HRBZLS."FGETRLMONTHNUM" (p_mid in varchar2) RETURN number AS
  v_monthnum number;
BEGIN
  select count(*)
    into v_monthnum
    from (select rlmonth
            from reclist
           where RLPAIDFLAG = 'N'
             and rlje - RLPAIDJE > 0
             and rlcd = 'DE'
             and rlmid = p_mid
           group by rlmonth);
  RETURN v_monthnum;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 0;
END fgetrlmonthnum;
/

