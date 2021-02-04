create or replace force view hrbzls.vie_变更管理_营业所变更 as
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'营业所变更：营业所'  变更对象,FGETSYSMANAFRAME(t3.mismfid) 变更前,FGETSYSMANAFRAME(t2.mismfid) 变更后,'Y' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.mismfid IS NOT NULL AND t3.mismfid IS NOT NULL AND t2.mismfid <> t3.mismfid) OR (t2.mismfid IS NULL AND t3.mismfid IS NOT NULL) OR (t2.mismfid IS NOT NULL AND t3.mismfid IS NULL))
and t1.cchlb='10'
---营业所
---身份证复印件
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'营业所变更：身份证复印件'  变更对象,'' 变更前,decode(accessoryflag09,'Y','是','N','否') 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and accessoryflag09 IS NOT NULL
and t1.cchlb='10'
---企业法人营业执照（或组织机构代码证）复印件一份
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'营业所变更：企业法人营业执照（或组织机构代码证）复印件一份'  变更对象,'' 变更前,decode(accessoryflag07,'Y','是','N','否') 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and accessoryflag07  IS NOT NULL
and t1.cchlb='10'
---用户申请书
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'营业所变更：用户申请书'  变更对象,'' 变更前,decode(accessoryflag10,'Y','是','N','否') 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and accessoryflag10 IS NOT NULL
and t1.cchlb='10'
---申请说明
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'营业所变更：申请说明'  变更对象,'' 变更前,ccdappnote 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ccdappnote is not null
and t1.cchlb='10'
---备注信息
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'营业所变更：备注信息'  变更对象,t3.mimemo 变更前, t2.mimemo 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.mimemo IS NOT NULL AND t3.mimemo IS NOT NULL AND t2.mimemo <> t3.mimemo) OR (t2.mimemo IS NULL AND t3.mimemo IS NOT NULL) OR (t2.mimemo IS NOT NULL AND t3.mimemo IS NULL))
and t1.cchlb='10'
;

