CREATE OR REPLACE TRIGGER HRBZLS."DELETE_FLOW_MAIN"
  BEFORE DELETE on FLOW_MAIN
  for each row
declare
  -- local variables here
  fs VARCHAR2(2);
begin
 --select fmstaus into fs  from FLOW_MAIN where fmno='1' and FMBILLNO=:OLD.CCHNO;
    if :old.fmstaus in ('0','1') and :old.fmno='1' then
       RAISE_APPLICATION_ERROR(-20002, '流程中工单不能删除!');
    end if;
end DELETE_FLOW_MAIN;
/

