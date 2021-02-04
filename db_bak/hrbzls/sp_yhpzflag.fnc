CREATE OR REPLACE FUNCTION HRBZLS."SP_YHpzflag" (P_ID IN VARCHAR2)
 RETURN VARCHAR2
AS
  v_row integer;
  V_NY VARCHAR2(2);
BEGIN
  select count(vrow),max(cz_flag) into v_row,v_ny from (select distinct(cz_flag) vrow,cz_flag  FROM BANK_DZ_MX where id = P_ID group by cz_flag);
      if v_row > 1 then
        v_ny := 'YN';
       end if;
 RETURN V_NY;
EXCEPTION WHEN OTHERS THEN
 RETURN NULL;
END;
/

