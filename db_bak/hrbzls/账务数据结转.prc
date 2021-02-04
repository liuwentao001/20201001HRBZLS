CREATE OR REPLACE PROCEDURE HRBZLS."账务数据结转" (p_month in varchar2) as

  v_month varchar2(10);
  V_ALOG  AUTOEXEC_LOG%ROWTYPE;

begin
  v_month         := p_month;
  V_ALOG.O_TYPE   := trim(v_month || '月份' || '账务数据结转');
  V_ALOG.o_time_1 := sysdate;

  -----插入
  -----1插入交易记录历史
  insert into paymenthis
    (select * from payment pm where pm.pmonth <= v_month);
  ------2插入应收汇总表历史
  insert into reclisthis
    (select * 　from reclist rl
      where rl.rlpid in
            (select pid from payment pm where pm.pmonth <= v_month));
  ------3插入应收明细表历史
  insert into recdetailhis
    (select *
       from recdetail rd
      where rd.rdid in
            (select rlid 　from reclist rl
              where rl.rlpid in
                    (select pid from payment pm where pm.pmonth <= v_month)));
  ----4插入发票记录历史
  insert into inv_info_his
    (select *
       from inv_info inv
      where inv.BATCH in
            (select PBATCH from payment pm where pm.pmonth <= v_month));

  ----删除
  ----1删除 交易记录历史
  delete payment pm where pm.pmonth <= v_month;
  ----2删除应收汇总表历史
  delete reclist rl
   where rl.rlpid in
         (select pid from payment pm where pm.pmonth <= v_month);
  ---3删除应收明细表历史
  delete recdetail rd
   where rd.rdid in
         (select rlid 　from reclist rl
           where rl.rlpid in
                 (select pid from payment pm where pm.pmonth <= v_month));
  ---4删除发票记录历史
  delete inv_info inv
   where inv.BATCH in
         (select PBATCH from payment pm where pm.pmonth <= v_month);

  ----记录日志信息
  SELECT seq_autoexec_day.nextval INTO V_ALOG.ID FROM DUAL;
  V_ALOG.O_TIME_2 := sysdate;
  V_ALOG.O_RESULT := '成功结转截止' || v_month || '实收账务数据';

  insert into AUTOEXEC_LOG values V_ALOG;

  commit;
exception
  when others then
    V_ALOG.O_RESULT := '失败结转截止' || v_month || '实收账务数据' || '[' || sqlerrm || ']';
    insert into AUTOEXEC_LOG values V_ALOG;
    raise_application_error(-20012, sqlerrm);
    commit;
end;
/

