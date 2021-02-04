create or replace force view hrbzls.vie_变更管理_水表档案变更 as
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'水表档案变更：表口径'  变更对象,TO_CHAR(t3.mdcaliber) 变更前,TO_CHAR(t2.mdcaliber) 变更后,'Y' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and t2.mdcaliber IS NOT NULL-- ( (t2.mdcaliber IS NOT NULL AND t3.mdcaliber IS NOT NULL AND t2.mdcaliber <> t3.mdcaliber) OR (t2.mdcaliber IS NULL AND t3.mdcaliber IS NOT NULL) OR (t2.mdcaliber IS NOT NULL AND t3.mdcaliber IS NULL))
and t1.cchlb='W'
---表口径
---表厂家
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'水表档案变更：表厂家'  变更对象,t3.mdbrand 变更前,t2.mdbrand 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.mdbrand IS NOT NULL AND t3.mdbrand IS NOT NULL AND t2.mdbrand <> t3.mdbrand) OR (t2.mdbrand IS NULL AND t3.mdbrand IS NOT NULL) OR (t2.mdbrand IS NOT NULL AND t3.mdbrand IS NULL))
and t1.cchlb='W'
---表型号
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'水表档案变更：表型号'  变更对象,FGETMETERMODEL(t3.mdmodel) 变更前,FGETMETERMODEL(t2.mdmodel) 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.mdmodel IS NOT NULL AND t3.mdmodel IS NOT NULL AND t2.mdmodel <> t3.mdmodel) OR (t2.mdmodel IS NULL AND t3.mdmodel IS NOT NULL) OR (t2.mdmodel IS NOT NULL AND t3.mdmodel IS NULL))
and t1.cchlb='W'
---表身码
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'水表档案变更：表身码'  变更对象,t3.mdno 变更前,t2.mdno 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.mdno IS NOT NULL AND t3.mdno IS NOT NULL AND t2.mdno <> t3.mdno) OR (t2.mdno IS NULL AND t3.mdno IS NOT NULL) OR (t2.mdno IS NOT NULL AND t3.mdno IS NULL))
and t1.cchlb='W'
---塑封号
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'水表档案变更：塑封号'  变更对象,t3.dqsfh 变更前,t2.dqsfh 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.dqsfh IS NOT NULL AND t3.dqsfh IS NOT NULL AND t2.dqsfh <> t3.dqsfh) OR (t2.dqsfh IS NULL AND t3.dqsfh IS NOT NULL) OR (t2.dqsfh IS NOT NULL AND t3.dqsfh IS NULL))
and t1.cchlb='W'
---钢封号
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'水表档案变更：钢封号'  变更对象,t3.dqgfh 变更前,t2.dqgfh 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.dqgfh IS NOT NULL AND t3.dqgfh IS NOT NULL AND t2.dqgfh <> t3.dqgfh) OR (t2.dqgfh IS NULL AND t3.dqgfh IS NOT NULL) OR (t2.dqgfh IS NOT NULL AND t3.dqgfh IS NULL))
and t1.cchlb='W'
---稽查封号
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'水表档案变更：稽查封号'  变更对象,t3.jcgfh 变更前,t2.jcgfh 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.jcgfh IS NOT NULL AND t3.jcgfh IS NOT NULL AND t2.jcgfh <> t3.jcgfh) OR (t2.jcgfh IS NULL AND t3.jcgfh IS NOT NULL) OR (t2.jcgfh IS NOT NULL AND t3.jcgfh IS NULL))
and t1.cchlb='W'
---铅封号
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'水表档案变更：铅封号'  变更对象,t3.qhf 变更前,t2.qhf 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.qhf IS NOT NULL AND t3.qhf IS NOT NULL AND t2.qhf <> t3.qhf) OR (t2.qhf IS NULL AND t3.qhf IS NOT NULL) OR (t2.qhf IS NOT NULL AND t3.qhf IS NULL))
and t1.cchlb='W'
---备注信息
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'水表档案变更：备注信息'  变更对象,t3.mimemo 变更前, t2.mimemo 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.mimemo IS NOT NULL AND t3.mimemo IS NOT NULL AND t2.mimemo <> t3.mimemo) OR (t2.mimemo IS NULL AND t3.mimemo IS NOT NULL) OR (t2.mimemo IS NOT NULL AND t3.mimemo IS NULL))
and t1.cchlb='W'
;

