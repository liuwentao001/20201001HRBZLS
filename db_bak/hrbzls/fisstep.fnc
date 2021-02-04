CREATE OR REPLACE FUNCTION HRBZLS."FISSTEP" (P_pfid IN VARCHAR2) RETURN char AS
  v_method varchar2(32);
BEGIN
  --判断是否是阶梯水价
  select pdmethod
    into v_method
    from pricedetail
   where pdpfid = P_pfid
     and pdpiid = '01';
  if v_method = 'sl3' then
    return 'Y';
  else
    return 'N';
  end if;
EXCEPTION
  WHEN OTHERS THEN
    RETURN 'N';
END;
/

