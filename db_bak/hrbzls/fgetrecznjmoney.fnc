CREATE OR REPLACE FUNCTION HRBZLS."FGETRECZNJMONEY" (p_rlid in varchar2 )--返回入户直收应收金额带滞纳金不带初期预存
  RETURN VARCHAR2
AS
v_ret varchar2(2000);

BEGIN
      select sum(rdje) rdje into v_ret from recdetail where rdid=p_rlid;
      return v_ret;

END;
/

