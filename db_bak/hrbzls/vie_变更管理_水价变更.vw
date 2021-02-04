create or replace force view hrbzls.vie_变更管理_水价变更 as
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'水价变更：价格类别'  变更对象,t3.MIPFID 变更前,t2.MIPFID 变更后,'Y' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIPFID IS NOT NULL AND t3.MIPFID IS NOT NULL AND t2.MIPFID <> t3.MIPFID) OR (t2.MIPFID IS NULL AND t3.MIPFID IS NOT NULL) OR (t2.MIPFID IS NOT NULL AND t3.MIPFID IS NULL))
and t1.cchlb='E'
---价格类别
---混合用水标志
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'水价变更：混合用水标志'  变更对象,decode(t3.miifmp,'Y','是','N','否') 变更前,decode(t2.miifmp,'Y','是','N','否') 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.miifmp IS NOT NULL AND t3.miifmp IS NOT NULL AND t2.miifmp <> t3.miifmp) OR (t2.miifmp IS NULL AND t3.miifmp IS NOT NULL) OR (t2.miifmp IS NOT NULL AND t3.miifmp IS NULL))
and t1.cchlb='E'
---身份证复印件
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'水价变更：身份证复印件'  变更对象,'' 变更前,decode(t2.accessoryflag09,'Y','是','N','否') 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and t2.accessoryflag09 IS NOT NULL
and t1.cchlb='E'

---企业法人营业执照（或组织机构代码证）复印件一份
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'水价变更：企业法人营业执照（或组织机构代码证）复印件一份'  变更对象,'' 变更前,decode(t2.accessoryflag07,'Y','是','N','否') 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and t2.accessoryflag07 IS NOT NULL
and t1.cchlb='E'

---用户申请书
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'水价变更：用户申请书'  变更对象,'' 变更前,decode(t2.accessoryflag10,'Y','是','N','否') 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and t2.accessoryflag10 IS NOT NULL
and t1.cchlb='E'
---申请说明
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'水价变更：申请说明'  变更对象,'' 变更前,ccdappnote 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ccdappnote is not null
and t1.cchlb='E'

---备注
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'水价变更：备注'  变更对象,'' 变更前, t2.ccdmemo 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and  t2.ccdmemo IS NOT NULL
and t1.cchlb='E'
---价格类别1
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'水价变更：价格类别1'  变更对象, t3.PMDPFID 变更前, t2.PMDPFID 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and  ( (t2.PMDPFID IS NOT NULL AND t3.PMDPFID IS NOT NULL AND t2.PMDPFID <> t3.PMDPFID) OR (t2.PMDPFID IS NULL AND t3.PMDPFID IS NOT NULL) OR (t2.PMDPFID IS NOT NULL AND t3.PMDPFID IS NULL))
and t1.cchlb='E'
---价格类别2
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'水价变更：价格类别2'  变更对象, t3.PMDPFID2 变更前, t2.PMDPFID2 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and  ( (t2.PMDPFID2 IS NOT NULL AND t3.PMDPFID2 IS NOT NULL AND t2.PMDPFID2 <> t3.PMDPFID2) OR (t2.PMDPFID2 IS NULL AND t3.PMDPFID2 IS NOT NULL) OR (t2.PMDPFID2 IS NOT NULL AND t3.PMDPFID2 IS NULL))
and t1.cchlb='E'
---价格类别3
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'水价变更：价格类别3'  变更对象, t3.PMDPFID3 变更前, t2.PMDPFID3 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and  ( (t2.PMDPFID3 IS NOT NULL AND t3.PMDPFID3 IS NOT NULL AND t2.PMDPFID3 <> t3.PMDPFID3) OR (t2.PMDPFID3 IS NULL AND t3.PMDPFID3 IS NOT NULL) OR (t2.PMDPFID3 IS NOT NULL AND t3.PMDPFID3 IS NULL))
and t1.cchlb='E'
---比例1
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'水价变更：比例1'  变更对象, to_char(t3.pmdscale) 变更前, to_char(t2.pmdscale) 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and  ( (t2.pmdscale IS NOT NULL AND t3.pmdscale IS NOT NULL AND t2.pmdscale <> t3.pmdscale) OR (t2.pmdscale IS NULL AND t3.pmdscale IS NOT NULL) OR (t2.pmdscale IS NOT NULL AND t3.pmdscale IS NULL))
and t1.cchlb='E'
---比例2
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'水价变更：比例2'  变更对象, to_char(t3.pmdscale2) 变更前, to_char(t2.pmdscale2) 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and  ( (t2.pmdscale2 IS NOT NULL AND t3.pmdscale2 IS NOT NULL AND t2.pmdscale2 <> t3.pmdscale2) OR (t2.pmdscale2 IS NULL AND t3.pmdscale2 IS NOT NULL) OR (t2.pmdscale2 IS NOT NULL AND t3.pmdscale2 IS NULL))
and t1.cchlb='E'
---比例3
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'水价变更：比例3'  变更对象, to_char(t3.pmdscale3) 变更前, to_char(t2.pmdscale3) 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and  ( (t2.pmdscale3 IS NOT NULL AND t3.pmdscale3 IS NOT NULL AND t2.pmdscale3 <> t3.pmdscale3) OR (t2.pmdscale3 IS NULL AND t3.pmdscale3 IS NOT NULL) OR (t2.pmdscale3 IS NOT NULL AND t3.pmdscale3 IS NULL))
and t1.cchlb='E'
--比例类别1
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'水价变更：比例类别1'  变更对象, t3.pmdtype 变更前, t2.pmdtype 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and  ( (t2.pmdtype IS NOT NULL AND t3.pmdtype IS NOT NULL AND t2.pmdtype <> t3.pmdtype) OR (t2.pmdtype IS NULL AND t3.pmdtype IS NOT NULL) OR (t2.pmdtype IS NOT NULL AND t3.pmdtype IS NULL))
and t1.cchlb='E'
--比例类别2
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'水价变更：比例类别2'  变更对象, t3.pmdtype2 变更前, t2.pmdtype2 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and  ( (t2.pmdtype2 IS NOT NULL AND t3.pmdtype2 IS NOT NULL AND t2.pmdtype2 <> t3.pmdtype2) OR (t2.pmdtype2 IS NULL AND t3.pmdtype2 IS NOT NULL) OR (t2.pmdtype2 IS NOT NULL AND t3.pmdtype2 IS NULL))
and t1.cchlb='E'
--比例类别3
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'水价变更：比例类别3'  变更对象, t3.pmdtype2 变更前, t2.pmdtype3 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and  ( (t2.pmdtype3 IS NOT NULL AND t3.pmdtype3 IS NOT NULL AND t2.pmdtype3 <> t3.pmdtype2) OR (t2.pmdtype3 IS NULL AND t3.pmdtype3 IS NOT NULL) OR (t2.pmdtype3 IS NOT NULL AND t3.pmdtype3 IS NULL))
and t1.cchlb='E'
;

