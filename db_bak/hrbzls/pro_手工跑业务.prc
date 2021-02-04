create or replace procedure hrbzls.pro_手工跑业务(v_result out varchar2) is
begin
/*   PG_AUTO_TASK.当天日结任务('804');
   commit;
   PG_AUTO_TASK.月末任务('805');
   commit;*/
   PG_AUTO_TASK.自动账务处理('803');
   commit;
   PG_AUTO_TASK.日结任务('802');
   commit;
   v_result:='ok';
end pro_手工跑业务;
/

