create or replace force view hrbzls.vie_营销管理_实收冲正 as
select pahno  变更流水号,pahlb  单据类别,pahsmfid 营销公司 ,pahcreper  登记人员,pahcredate  登记日期,pahshper  审核人员,pahshdate  审核日期,pahshflag  审核标志,pahmid   水表编号,pahmcode  资料号,pahmid     用户编号,pahmid   用户号,pahcname 用户名,pahmadr 用户地址 ,'实收冲正：申请冲销单位'  变更对象,'' 变更前, FGETSYSMANAFRAME(t1.pahfromsmfid) 变更后,'N' 状态
from PAIDADJUSTDT t2,PAIDADJUSThd t1
where t1.pahno = t2.PADNO  and t2.PADROWNO  = t2.PADROWNO  and t1.pahfromsmfid IS NOT NULL
and t1.pahlb='G'
---申请冲正单位
---冲正原因
union
select pahno  变更流水号,pahlb  单据类别,pahsmfid 营销公司,pahcreper  登记人员,pahcredate  登记日期,pahshper  审核人员,pahshdate  审核日期,pahshflag  审核标志,pahmid   水表编号,pahmcode  资料号,pahmid     用户编号,pahmid   用户号,pahcname 用户名,pahmadr 用户地址,'实收冲正：冲正原因'  变更对象,'' 变更前,t1.pahmemo 变更后,'Y' 状态
from PAIDADJUSTDT t2,PAIDADJUSThd t1
where t1.pahno = t2.PADNO  and t2.PADROWNO  = t2.PADROWNO   and t1.pahmemo IS NOT NULL
and t1.pahlb='G'
---销账水量
union
select pahno  变更流水号,pahlb  单据类别,pahsmfid 营销公司,pahcreper  登记人员,pahcredate  登记日期,pahshper  审核人员,pahshdate  审核日期,pahshflag  审核标志,pahmid   水表编号,pahmcode  资料号,pahmid     用户编号,pahmid   用户号,pahcname 用户名,pahmadr 用户地址,'实收冲正：销账水量'  变更对象,'' 变更前,to_char(t2.padplsl) 变更后,'N' 状态
from PAIDADJUSTDT t2,PAIDADJUSThd t1
where t1.pahno = t2.PADNO  and t2.PADROWNO  = t2.PADROWNO   and  nvl(t2.padplsl,0)<>0
and t1.pahlb='G'
---缴费金额
union
select pahno  变更流水号,pahlb  单据类别,pahsmfid 营销公司,pahcreper  登记人员,pahcredate  登记日期,pahshper  审核人员,pahshdate  审核日期,pahshflag  审核标志,pahmid   水表编号,pahmcode  资料号,pahmid     用户编号,pahmid   用户号,pahcname 用户名,pahmadr 用户地址,'实收冲正：缴费金额'  变更对象,'' 变更前,to_char(t2.padplje) 变更后,'N' 状态
from PAIDADJUSTDT t2,PAIDADJUSThd t1
where t1.pahno = t2.PADNO  and t2.PADROWNO  = t2.PADROWNO   and  nvl(t2.padplje,0)<>0
and t1.pahlb='G'
;

