CREATE OR REPLACE PROCEDURE HRBZLS."KT_DO_DEPT" (
                                         as_dept in varchar2,
                                         as_func_id in varchar2
                                         ) is
  v_id    varchar2(10);
  begin

         select fgetbillid('SEQ_KPI_TASK') into v_id from dual;
         insert into kpi_dept values(v_id,as_func_id,as_dept);

  end;
/

