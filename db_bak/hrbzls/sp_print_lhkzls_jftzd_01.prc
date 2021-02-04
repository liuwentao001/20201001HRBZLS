CREATE OR REPLACE PROCEDURE HRBZLS."SP_PRINT_LHKZLS_JFTZD_01" (
                  o_base out tools.out_base) is
  begin
    open o_base for
 select
  rlmcode  as 用户编号,           ----用户编号
  rlcname as 用户名称,         -----用户名称
  rlcadr as 用户地址,          -----用户地址
  to_date(to_char(ADD_MONTHS(trunc(rldate),-1),'yyyy.mm'),'yyyy.mm')+24  as 上期月份,
  to_date(to_char(ADD_MONTHS(trunc(rldate),-0),'yyyy.mm'),'yyyy.mm')+24  as 本期月份,
  rlscode as 上次指数 ,          -----上次指数
  rlecode as 本期指数,          ------本期指数
  rlreadsl as 实用水量 ,         --------实用水量
  rlje as 金额,             --------金额
  md.mdcaliber as 表口径 ,       --------表口径
  tools.fuppernumber(rlje) as  大写金额,
            f_jftzd_01('040105') as 中行,
            f_jftzd_01('040101') as 建行,
            f_jftzd_01('040103') as 农行,
            f_jftzd_01('040102') as 工行,
               '供水一公司' as   开户行,
               '请用户于本月25日前到供水公司收费室交纳水费，否则将按有关规定处理，每月25日起，按日加收5‰违约金.' as 备注,
               '8303102' as 联系电话,
               to_char(sysdate,'yyyy-mm-dd') as 开单时间,
               null as 预留字段1,
               null as 预留字段2,
               null as 预留字段3,
               null as 预留字段4,
               null as 预留字段5,
               null as 预留字段6,
               null as 预留字段7,
               null as 预留字段8,
               null as 预留字段9,
               null as 预留字段10
 from
 reclist rl,meterdoc md,meterinfo mi, pbparmtemp pp
 where
 rlpaidflag='N'
 and rlje >0
 and rlje-rlpaidje >0
 and rl.rlmid=md.mdmid
 and rl.rlmid = mi.miid
 and mi.milb='D'
 and rl.rlcd='DE'
 and rl.rlid=pp.c1
 order by mi.mismfid,mi.mibfid,mi.mirorder;
end ;
/

