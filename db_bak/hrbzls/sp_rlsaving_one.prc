CREATE OR REPLACE PROCEDURE HRBZLS."SP_RLSAVING_ONE" is
  v_rdpiid      varchar2(4000);
  ycsum         meterinfo.misaving%type;
  v_bkje        number;
  v_ycje        number;
  mis           meterinfo%rowtype;
  v_svaingbatch varchar2(50);
  v_outpbatch   varchar2(1000);
  v_rlznj       number(12, 2);
  rl            reclist%rowtype;
  mi            meterinfo%rowtype;
  v_znj         number(13, 3);
V_RET varchar2(5);
  --单笔欠费的游标
  cursor c_rl_one  is
    select rl.*
      from reclist rl
      where rl.rlid in (
      select V_RLID  from  rec_ycjc t1)
      order by rl.rlrdate desc, rl.rlmonth desc, rl.rlmiemailflag desc, rl.rlgroup asc;


BEGIN

  open c_rl_one ;
  loop
    fetch c_rl_one
      into rl;
    exit when c_rl_one%notfound or c_rl_one%notfound is null;


    --滞纳金

    v_znj := PG_EWIDE_PAY_01.getznjadj(rl.rlid,
                                       rl.rlje,
                                       rl.rlgroup,
                                       rl.rlzndate,
                                       rl.RLSMFID,
                                       sysdate);
    V_RET := PG_ewide_PAY_01.pos('01'   , --销帐方式 01 单表缴费 02 合收表缴费 03 多表缴费
                         rl.rlsmfid, --缴费机构
                          'system', --收款员
                         rl.rlid|| '|', --应收流水
                         rl.rlje, --应收金额
                         v_znj, --销帐违约金
                         0, --手续费
                         0, --实际收款
                         PG_ewide_PAY_01.PAYTRANS_预存抵扣, --缴费事务
                         rl.rlmid, --户号
                         'XJ', --付款方式
                         rl.rlsmfid, --缴费地点
                         FGETSEQUENCE('ENTRUSTLOG'), --缴费事务流水
                         'N', --是否打票  Y 打票，N不打票， R 应收票
                         '', --发票号
                         'N' --控制是否提交（Y/N）
                         );

   /*   PG_ewide_PAY_01.pos(rl.rlsmfid, --缴费机构
                          'system', --收款员
                          rl.rlid, --应收流水
                          rl.rlmid, --户号
                          rl.rlje, --应收金额
                          v_znj, --销帐违约金
                          0, --手续费
                          0, --实际收款
                          PG_ewide_PAY_01.PAYTRANS_预存抵扣, --缴费事务
                          PG_ewide_PAY_01.DEBIT, --借代方向
                          'XJ', --付款方式
                          rl.rlsmfid, --缴费地点
                          FGETSEQUENCE('ENTRUSTLOG'), --缴费事务流水
                          'N', --是否打票  Y 打票，N不打票， R 应收票
                          '', --发票号
                          'N' --提交标志
                          );*/



  end loop;
 close c_rl_one;
exception
  when others then
    rollback;
    raise_application_error('-20002', sqlerrm);

END SP_RLSAVING_ONE;
/

