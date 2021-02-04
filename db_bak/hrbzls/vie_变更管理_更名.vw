create or replace force view hrbzls.vie_变更管理_更名 as
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'更名：用户名'  变更对象,t3.ciname 变更前,t2.ciname 变更后,'Y' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.ciname IS NOT NULL AND t3.ciname IS NOT NULL AND t2.ciname <> t3.ciname) OR (t2.ciname IS NULL AND t3.ciname IS NOT NULL) OR (t2.ciname IS NOT NULL AND t3.ciname IS NULL))
and t1.cchlb='B'
union
---证件类型
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'更名：证件类型'  变更对象,decode(t3.ciidentitylb,'NULL','','1','身份证','2','驾驶证') 变更前,decode(t2.ciidentitylb,'NULL','','1','身份证','2','驾驶证') 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.ciidentitylb IS NOT NULL AND t3.ciidentitylb IS NOT NULL AND t2.ciidentitylb <> t3.ciidentitylb) OR (t2.ciidentitylb IS NULL AND t3.ciidentitylb IS NOT NULL) OR (t2.ciidentitylb IS NOT NULL AND t3.ciidentitylb IS NULL))
and t1.cchlb='B'
---证件号码
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'更名：证件号码'  变更对象,t3.ciidentityno 变更前,t2.ciidentityno 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.ciidentityno IS NOT NULL AND t3.ciidentityno IS NOT NULL AND t2.ciidentityno <> t3.ciidentityno) OR (t2.ciidentityno IS NULL AND t3.ciidentityno IS NOT NULL) OR (t2.ciidentityno IS NOT NULL AND t3.ciidentityno IS NULL))
and t1.cchlb='B'
---联系人
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'更名：联系人'  变更对象,t3.ciconnectper 变更前,t2.ciconnectper 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.ciconnectper IS NOT NULL AND t3.ciconnectper IS NOT NULL AND t2.ciconnectper <> t3.ciconnectper) OR (t2.ciconnectper IS NULL AND t3.ciconnectper IS NOT NULL) OR (t2.ciconnectper IS NOT NULL AND t3.ciconnectper IS NULL))
and t1.cchlb='B'
---联系电话
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'更名：联系电话'  变更对象,t3.ciconnecttel 变更前,t2.ciconnecttel 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.ciidentityno IS NOT NULL AND t3.ciconnecttel IS NOT NULL AND t2.ciconnecttel <> t3.ciconnecttel) OR (t2.ciconnecttel IS NULL AND t3.ciconnecttel IS NOT NULL) OR (t2.ciconnecttel IS NOT NULL AND t3.ciconnecttel IS NULL))
and t1.cchlb='B'
---移动电话
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'更名：移动电话'  变更对象,t3.cimtel 变更前,t2.cimtel 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.cimtel IS NOT NULL AND t3.cimtel IS NOT NULL AND t2.cimtel <> t3.cimtel) OR (t2.cimtel IS NULL AND t3.cimtel IS NOT NULL) OR (t2.cimtel IS NOT NULL AND t3.cimtel IS NULL))
and t1.cchlb='B'
---票据名
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'更名：票据名'  变更对象,t3.miname 变更前,t2.miname 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.miname IS NOT NULL AND t3.miname IS NOT NULL AND t2.miname <> t3.miname) OR (t2.miname IS NULL AND t3.miname IS NOT NULL) OR (t2.miname IS NOT NULL AND t3.miname IS NULL))
and t1.cchlb='B'
---住宅电话
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'更名：住宅电话'  变更对象,t3.citel1 变更前,t2.citel1 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.citel1 IS NOT NULL AND t3.citel1 IS NOT NULL AND t2.citel1 <> t3.citel1) OR (t2.citel1 IS NULL AND t3.citel1 IS NOT NULL) OR (t2.citel1 IS NOT NULL AND t3.citel1 IS NULL))
and t1.cchlb='B'
---办公电话
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'更名：办公电话'  变更对象,t3.citel2 变更前,t2.citel2 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.citel2 IS NOT NULL AND t3.citel2 IS NOT NULL AND t2.citel2 <> t3.citel2) OR (t2.citel2 IS NULL AND t3.citel2 IS NOT NULL) OR (t2.citel2 IS NOT NULL AND t3.citel2 IS NULL))
and t1.cchlb='B'
---是否短信
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'更名：是否短信'  变更对象,decode(t3.ciifsms,'Y','是','N','否') 变更前,decode(t2.ciifsms,'Y','是','N','否') 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.ciifsms IS NOT NULL AND t3.ciifsms IS NOT NULL AND t2.ciifsms <> t3.ciifsms) OR (t2.ciifsms IS NULL AND t3.ciifsms IS NOT NULL) OR (t2.ciifsms IS NOT NULL AND t3.ciifsms IS NULL))
and t1.cchlb='B'

---申请说明
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'更名：申请说明'  变更对象,'' 变更前,ccdappnote 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ccdappnote is not null
and t1.cchlb='B'
---领导意见
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'更名：领导意见'  变更对象,'' 变更前, t2.ccdfilashnote 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and  t2.ccdfilashnote IS NOT NULL
and t1.cchlb='B'
;

