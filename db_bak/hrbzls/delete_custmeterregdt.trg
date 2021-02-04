CREATE OR REPLACE TRIGGER HRBZLS."DELETE_CUSTMETERREGDT"
  BEFORE DELETE on CUSTMETERREGDT
  for each row
declare
  -- local variables here
  fs VARCHAR2(5);
  fx VARCHAR2(5);
begin
 select nvl(max(fmstaus),'a') into fs  from FLOW_MAIN where fmno='1' and FMBILLNO=:OLD.CMRDNO;
  select min(oarrid) into fx From operaccntrole where oaroaid = (SELECT FGETPBOPER FROM DUAL);
  if  fx='00' or fx='02' then
    return;
    else
    if fs in ('0','1')  then
       RAISE_APPLICATION_ERROR(-20002, '流程中工单不能删除!');
       else
       return;
    end if;
  end if;
end DELETE_CUSTMETERREGDT;
/

