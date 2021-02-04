create or replace force view hrbzls.vie_变更管理_表故障 as
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址 ,'表故障：水表状态'  变更对象,FGETSYSCUSTSTATUS(t3.mistatus) 变更前,FGETSYSCUSTSTATUS(t2.mistatus) 变更后,'Y' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and t2.mistatus IS NOT NULL-- ( (t2.mistatus IS NOT NULL AND t3.mistatus IS NOT NULL AND t2.mistatus <> t3.mistatus) OR (t2.mistatus IS NULL AND t3.mistatus IS NOT NULL) OR (t2.mistatus IS NOT NULL AND t3.mistatus IS NULL))
and t1.cchlb='17'
union
---故障原因
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司，CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'表故障：故障原因'  变更对象,'' 变更前,FGETSYSFACELIST2(t2.miface2) 变更后, 'N'   状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and miface2 is not null
and t1.cchlb='17'
---指定水量
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司，CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'表故障：指定水量'  变更对象,to_char(t3.micolumn5) 变更前,to_char(t2.micolumn5) 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.micolumn5 IS NOT NULL AND t3.micolumn5 IS NOT NULL AND t2.micolumn5 <> t3.micolumn5) OR (t2.micolumn5 IS NULL AND t3.micolumn5 IS NOT NULL) OR (t2.micolumn5 IS NOT NULL AND t3.micolumn5 IS NULL))
and t1.cchlb='17'
---申请说明
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司，CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'表故障：申请说明'  变更对象,'' 变更前,ccdappnote 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ccdappnote is not null
and t1.cchlb='17'
---备注信息
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'表故障：备注信息'  变更对象,t3.mimemo 变更前, t2.mimemo 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.mimemo IS NOT NULL AND t3.mimemo IS NOT NULL AND t2.mimemo <> t3.mimemo) OR (t2.mimemo IS NULL AND t3.mimemo IS NOT NULL) OR (t2.mimemo IS NOT NULL AND t3.mimemo IS NULL))
and t1.cchlb='17'
;

