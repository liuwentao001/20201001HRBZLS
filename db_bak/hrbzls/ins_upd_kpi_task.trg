CREATE OR REPLACE TRIGGER HRBZLS."INS_UPD_KPI_TASK"
  before insert or update on kpi_task  
  for each row
declare
  -- local variables here
begin
    if trim(:new.report_id) is null or nvl(:new.report_id,'NULL')='NULL' then
        RAISE_APPLICATION_ERROR(-20002, '新增kpi_task时,report_id不能为空,请联系系统维护人员!');
    end if ;
end ins_upd_kpi_task;
/

