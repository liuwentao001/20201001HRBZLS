CREATE OR REPLACE PROCEDURE HRBZLS."SP_TSWSFPRINT" (
                  o_base out tools.out_base) is
  begin
    open o_base for

 select
           max(etlbatch) 托收批次号, --托收批次号
           etlmiuiid 托收凭证号, --托收凭证号
           max(to_char(eloutdate,'yyyy')) 年,
           max(to_char(eloutdate,'mm')) 月,
           max(to_char(eloutdate,'dd')) 日,
           max(to_char(eloutdate,'yyyy')||'/'||to_char(eloutdate,'mm')||'/'||to_char(eloutdate,'dd')) 打印日期,
           to_char(max(t3.rldate ),'yyyy')||'  '||to_char(max(t3.rldate ),'mm')||'  '||to_char(max(t3.rldate ),'dd') 应收帐日期,-- 应收帐日期
          ''收款方式,
          max(t3.rlmcode) 客户代码 ,--客户代码
           max(t3.rlcname) 用户名 , --用户名
           max(t3.rlmadr)  水表地址 ,--水表地址
           max(RLBFID) 表册号,
           (case when trim(max(rltel)) is not null then 'tel:'||trim(max(rltel))
                when trim(max(rltel )) is  null and trim(max(rlmtel)) is not null  then 'tel:'||trim(max(rlmtel))
                else '' end) 电话,--电话
           max(RLRPER) 抄表员,
           fgetopername( max(c2))  抄表月份标题, --抄表月份标题
         fgetopername( max(c2)) 应收月份, --应收月份
           sp_getdjmx(etlmiuiid,max(etlseqno),1)  起码标题,--起码标题
         sp_getdjmx(etlmiuiid,max(etlseqno),2)  起码,--起码
           sp_getdjmx(etlmiuiid,max(etlseqno),3)  止码标题,--止码标题
           ''  止码,--止码
           '水量' 水量标题,--水量标题
           max(etlsl  )    水量,--水量
           '污水处理费' 单价标题,--单价标题
           '' 单价,--单价
           '污水处理费' 水费标题,--水费标题
            max(etlsl *F_GETTSDJ(etlseqno)  )水费,--水费
           tools.fuppernumber(          max(F_GETTSJE(etlseqno ,etlmiuiid)  ) )水费大写,--大写
                  max(F_GETTSJE(etlseqno ,etlmiuiid)  ) 金额,--实收
           tools.fuppernumber(          max(F_GETTSJE(etlseqno ,etlmiuiid)  )) 金额大写,--大写
         -- max(c2) c2,--打印员编号x
        --   max(c3) c3, --顺序号
          fgetopername( max(c2)) 备注,
      --     fgetopername( max(c2)) 打印员中文,--打印员中文
           max( etlaccountno)  预留1,--预留1
             max( etlbankidname ) 预留2,--预留2
               '苏州吴中供水有限公司' 预留3,--预留3
             '建行苏州吴中经济开发区'  预留4,--预留4
         '32201997591050682841'  预留5,--预留5
          ''  预留6,--预留6
           fgetopername( max(c2)) 预留7,--预留7
             1 预留8,--预留8
           1 预留9,--预留9
           1 预留10--预留10

   from reclist t3,
         entrustlist t,
         entrustlog  t1,
        pbparmtemp  t2
   where
      --instr(ETLRLIDPIID, t3.rlid )>0
      t3.rlentrustseqno= etlseqno
      and t1.elbatch=t.etlbatch
    and  c4 = etlmiuiid
      group by etlmiuiid order by to_number(etlmiuiid) ;
  end ;
/

