CREATE OR REPLACE TRIGGER HRBZLS."INS_UPD_KPI_TASK"
  before insert or update on kpi_task  
  for each row
declare
  -- local variables here
begin
    if trim(:new.report_id) is null or nvl(:new.report_id,'NULL')='NULL' then
        RAISE_APPLICATION_ERROR(-20002, '����kpi_taskʱ,report_id����Ϊ��,����ϵϵͳά����Ա!');
    end if ;
end ins_upd_kpi_task;
/

