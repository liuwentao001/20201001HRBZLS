create or replace force view hrbzls.vie_营销管理_应收冲正 as
select RCHNO  变更流水号,RCHLB  单据类别,RCHSMFID 营销公司,RCHCREPER  登记人员,RCHCREDATE  登记日期,RCHSHPER  审核人员,RCHSHDATE  审核日期,RCHSHFLAG  审核标志,RCDMID   水表编号,RCDMCODE  资料号,RCDCID     用户编号,RCDCCODE   用户号,rcdcname 用户名,rcdcadr 用户地址 ,'应收冲正：申请冲销单位'  变更对象,'' 变更前, FGETSYSMANAFRAME(t1.RCHSMFID) 变更后,'N' 状态
from recczdt  t2,recczHD t1
where t1.RCHNO = t2.RCDNO  and t2.RCDROWNO  = t2.RCDROWNO   and t1.RCHSMFID IS NOT NULL
and t1.RCHLB='G'
---申请冲正单位
---备注
union
select RCHNO  变更流水号,RCHLB  单据类别,RCHSMFID 营销公司,RCHCREPER  登记人员,RCHCREDATE  登记日期,RCHSHPER  审核人员,RCHSHDATE  审核日期,RCHSHFLAG  审核标志,RCDMID   水表编号,RCDMCODE  资料号,RCDCID     用户编号,RCDCCODE   用户号,rcdcname 用户名,rcdcadr 用户地址,'应收冲正：备注'  变更对象,'' 变更前,t2.rcdmemo 变更后,'N' 状态
from recczdt  t2,recczHD t1
where t1.RCHNO = t2.RCDNO  and t2.RCDROWNO  = t2.RCDROWNO   and t2.rcdmemo IS NOT NULL
and t1.RCHLB='G'

---应收金额
union
select RCHNO  变更流水号,RCHLB  单据类别,RCHSMFID 营销公司,RCHCREPER  登记人员,RCHCREDATE  登记日期,RCHSHPER  审核人员,RCHSHDATE  审核日期,RCHSHFLAG  审核标志,RCDMID   水表编号,RCDMCODE  资料号,RCDCID     用户编号,RCDCCODE   用户号,rcdcname 用户名,rcdcadr 用户地址,'应收冲正：应收金额'  变更对象,'' 变更前,to_char(t2.rcdje) 变更后,'Y' 状态
from recczdt  t2,recczHD t1
where t1.RCHNO = t2.RCDNO  and t2.RCDROWNO  = t2.RCDROWNO   and  nvl(t2.rcdje,0)<>0
and t1.RCHLB='G'
;

