create or replace force view hrbzls.vie_变更管理_用户水表信息维护 as
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：产权名'  变更对象,t3.CINAME 变更前,t2.CINAME 变更后,'Y' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and t2.CINAME IS NOT NULL-- ( (t2.CINAME IS NOT NULL AND t3.CINAME IS NOT NULL AND t2.CINAME <> t3.CINAME) OR (t2.CINAME IS NULL AND t3.CINAME IS NOT NULL) OR (t2.CINAME IS NOT NULL AND t3.CINAME IS NULL))
and CCHLB='X')
union
--表号
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：表号'  变更对象,t3.MDNO 变更前,t2.MDNO 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MDNO IS NOT NULL AND t3.MDNO IS NOT NULL AND t2.MDNO <> t3.MDNO) OR (t2.MDNO IS NULL AND t3.MDNO IS NOT NULL) OR (t2.MDNO IS NOT NULL AND t3.MDNO IS NULL))
and CCHLB='X')
union
--用水地址
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：用水地址'  变更对象,t3.MIADR 变更前,t2.MIADR 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIADR IS NOT NULL AND t3.MIADR IS NOT NULL AND t2.MIADR <> t3.MIADR) OR (t2.MIADR IS NULL AND t3.MIADR IS NOT NULL) OR (t2.MIADR IS NOT NULL AND t3.MIADR IS NULL))
and CCHLB='X')
union
--区域
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：区域'  变更对象,FGETSYSAREAFRAME(t3.MISAFID) 变更前,FGETSYSAREAFRAME(t2.MISAFID) 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MISAFID IS NOT NULL AND t3.MISAFID IS NOT NULL AND t2.MISAFID <> t3.MISAFID) OR (t2.MISAFID IS NULL AND t3.MISAFID IS NOT NULL) OR (t2.MISAFID IS NOT NULL AND t3.MISAFID IS NULL))
and CCHLB='X')
union
--抄表方式
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：抄表方式'  变更对象,FGETSYSREADTYPE(t3.MIRTID) 变更前,FGETSYSREADTYPE(t2.MIRTID) 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIRTID IS NOT NULL AND t3.MIRTID IS NOT NULL AND t2.MIRTID <> t3.MIRTID) OR (t2.MIRTID IS NULL AND t3.MIRTID IS NOT NULL) OR (t2.MIRTID IS NOT NULL AND t3.MIRTID IS NULL))
and CCHLB='X')
 union
 --收费员
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：收费员'  变更对象,t3.MICPER 变更前,t2.MICPER 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MICPER IS NOT NULL AND t3.MICPER IS NOT NULL AND t2.MICPER <> t3.MICPER) OR (t2.MICPER IS NULL AND t3.MICPER IS NOT NULL) OR (t2.MICPER IS NOT NULL AND t3.MICPER IS NULL))
and CCHLB='X')
union
--行业分类
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：行业分类'  变更对象,FGETMETERSORTFRAME(t3.MISTID) 变更前,FGETMETERSORTFRAME(t2.MISTID) 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MISTID IS NOT NULL AND t3.MISTID IS NOT NULL AND t2.MISTID <> t3.MISTID) OR (t2.MISTID IS NULL AND t3.MISTID IS NOT NULL) OR (t2.MISTID IS NOT NULL AND t3.MISTID IS NULL))
and CCHLB='X')
union
 --计件类型
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：计件类型'  变更对象,t3.MIRPID 变更前,t2.MIRPID 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIRPID IS NOT NULL AND t3.MIRPID IS NOT NULL AND t2.MIRPID <> t3.MIRPID) OR (t2.MIRPID IS NULL AND t3.MIRPID IS NOT NULL) OR (t2.MIRPID IS NOT NULL AND t3.MIRPID IS NULL))
and CCHLB='X')
union
--表位
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：表位'  变更对象,decode(t3.MISIDE,'CF','厨房','QT','其他') 变更前,decode(t2.MISIDE,'CF','厨房','QT','其他')  变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MISIDE IS NOT NULL AND t3.MISIDE IS NOT NULL AND t2.MISIDE <> t3.MISIDE) OR (t2.MISIDE IS NULL AND t3.MISIDE IS NOT NULL) OR (t2.MISIDE IS NOT NULL AND t3.MISIDE IS NULL))
and CCHLB='X')
union
--接水地址
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：接水地址'  变更对象,t3.MIPOSITION 变更前,t2.MIPOSITION 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIPOSITION IS NOT NULL AND t3.MIPOSITION IS NOT NULL AND t2.MIPOSITION <> t3.MIPOSITION) OR (t2.MIPOSITION IS NULL AND t3.MIPOSITION IS NOT NULL) OR (t2.MIPOSITION IS NOT NULL AND t3.MIPOSITION IS NULL))
and CCHLB='X')
union
--新装起度
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：新装起度'  变更对象,trim(to_char(t3.MIINSCODE)) 变更前,trim(to_char(t2.MIINSCODE)) 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIINSCODE IS NOT NULL AND t3.MIINSCODE IS NOT NULL AND t2.MIINSCODE <> t3.MIINSCODE) OR (t2.MIINSCODE IS NULL AND t3.MIINSCODE IS NOT NULL) OR (t2.MIINSCODE IS NOT NULL AND t3.MIINSCODE IS NULL))
and CCHLB='X')
union
--装表日期
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：装表日期'  变更对象,trim(to_char(t3.MIINSDATE,'YYYYMMDD')) 变更前,trim(to_char(t2.MIINSDATE,'YYYYMMDD')) 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIINSDATE IS NOT NULL AND t3.MIINSDATE IS NOT NULL AND t2.MIINSDATE <> t3.MIINSDATE) OR (t2.MIINSDATE IS NULL AND t3.MIINSDATE IS NOT NULL) OR (t2.MIINSDATE IS NOT NULL AND t3.MIINSDATE IS NULL))
and CCHLB='X')
union
--换表日期
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：换表日期'  变更对象,trim(to_char(t3.MIREINSDATE,'YYYYMMDD')) 变更前,trim(to_char(t2.MIREINSDATE,'YYYYMMDD')) 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIREINSDATE IS NOT NULL AND t3.MIREINSDATE IS NOT NULL AND t2.MIREINSDATE <> t3.MIREINSDATE) OR (t2.MIREINSDATE IS NULL AND t3.MIREINSDATE IS NOT NULL) OR (t2.MIREINSDATE IS NOT NULL AND t3.MIREINSDATE IS NULL))
and CCHLB='X')
union
--类型
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：类型'  变更对象,FGETSYSMETERTYPE(t3.MITYPE) 变更前,FGETSYSMETERTYPE(t2.MITYPE) 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MITYPE IS NOT NULL AND t3.MITYPE IS NOT NULL AND t2.MITYPE <> t3.MITYPE) OR (t2.MITYPE IS NULL AND t3.MITYPE IS NOT NULL) OR (t2.MITYPE IS NOT NULL AND t3.MITYPE IS NULL))
and CCHLB='X')
union
--口径
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：口径'  变更对象,to_char(t3.MDCALIBER) 变更前,to_char(t2.MDCALIBER) 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (to_char(t2.MDCALIBER) IS NOT NULL AND to_char(t3.MDCALIBER) IS NOT NULL AND to_char(t2.MDCALIBER) <> to_char(t3.MDCALIBER)) OR (to_char(t2.MDCALIBER) IS NULL AND to_char(t3.MDCALIBER) IS NOT NULL) OR (to_char(t2.MDCALIBER) IS NOT NULL AND to_char(t3.MDCALIBER) IS NULL))
and CCHLB='X')
 union
--表厂家
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：表厂家'  变更对象,FGETMETERBRAND(t3.MDBRAND) 变更前,FGETMETERBRAND(t2.MDBRAND) 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MDBRAND IS NOT NULL AND t3.MDBRAND IS NOT NULL AND t2.MDBRAND <> t3.MDBRAND) OR (t2.MDBRAND IS NULL AND t3.MDBRAND IS NOT NULL) OR (t2.MDBRAND IS NOT NULL AND t3.MDBRAND IS NULL))
and CCHLB='X')
union
--表型号
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：表型号'  变更对象,FGETMETERMODEL(t3.MDMODEL) 变更前,FGETMETERMODEL(t2.MDMODEL) 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MDMODEL IS NOT NULL AND t3.MDMODEL IS NOT NULL AND t2.MDMODEL <> t3.MDMODEL) OR (t2.MDMODEL IS NULL AND t3.MDMODEL IS NOT NULL) OR (t2.MDMODEL IS NOT NULL AND t3.MDMODEL IS NULL))
and CCHLB='X')
union
--是否考核表
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：是否考核表'  变更对象,decode(t3.MIIFCHK,'Y','是','N','否')  变更前,decode(t2.MIIFCHK,'Y','是','N','否') 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIIFCHK IS NOT NULL AND t3.MIIFCHK IS NOT NULL AND t2.MIIFCHK <> t3.MIIFCHK) OR (t2.MIIFCHK IS NULL AND t3.MIIFCHK IS NOT NULL) OR (t2.MIIFCHK IS NOT NULL AND t3.MIIFCHK IS NULL))
 and CCHLB='X')
 union
--是否节水
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：是否节水'  变更对象,decode(t3.MIIFWATCH,'Y','是','N','否') 变更前,decode(t2.MIIFWATCH,'Y','是','N','否')  变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIIFWATCH IS NOT NULL AND t3.MIIFWATCH IS NOT NULL AND t2.MIIFWATCH <> t3.MIIFWATCH) OR (t2.MIIFWATCH IS NULL AND t3.MIIFWATCH IS NOT NULL) OR (t2.MIIFWATCH IS NOT NULL AND t3.MIIFWATCH IS NULL))
and CCHLB='X')
union
--IC卡号
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：IC卡号'  变更对象,t3.MIICNO 变更前,t2.MIICNO 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIICNO IS NOT NULL AND t3.MIICNO IS NOT NULL AND t2.MIICNO <> t3.MIICNO) OR (t2.MIICNO IS NULL AND t3.MIICNO IS NOT NULL) OR (t2.MIICNO IS NOT NULL AND t3.MIICNO IS NULL))
and CCHLB='X')
union
--备注信息
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：备注信息'  变更对象,t3.MIMEMO 变更前,t2.MIMEMO 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIMEMO IS NOT NULL AND t3.MIMEMO IS NOT NULL AND t2.MIMEMO <> t3.MIMEMO) OR (t2.MIMEMO IS NULL AND t3.MIMEMO IS NOT NULL) OR (t2.MIMEMO IS NOT NULL AND t3.MIMEMO IS NULL))
and CCHLB='X')
union
--合收表主表号
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：合收表主表号'  变更对象,t3.MIPRIID 变更前,t2.MIPRIID 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIPRIID IS NOT NULL AND t3.MIPRIID IS NOT NULL AND t2.MIPRIID <> t3.MIPRIID) OR (t2.MIPRIID IS NULL AND t3.MIPRIID IS NOT NULL) OR (t2.MIPRIID IS NOT NULL AND t3.MIPRIID IS NULL))
and CCHLB='X')
union
--合收表标志
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：合收表标志'  变更对象,decode(t3.MIPRIFLAG,'Y','是','N','否') 变更前,decode(t2.MIPRIFLAG,'Y','是','N','否') 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIPRIFLAG IS NOT NULL AND t3.MIPRIFLAG IS NOT NULL AND t2.MIPRIFLAG <> t3.MIPRIFLAG) OR (t2.MIPRIFLAG IS NULL AND t3.MIPRIFLAG IS NOT NULL) OR (t2.MIPRIFLAG IS NOT NULL AND t3.MIPRIFLAG IS NULL))
and CCHLB='X')
union
--户籍人数
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：户籍人数'  变更对象,trim(to_char(t3.MIUSENUM)) 变更前,trim(to_char(t2.MIUSENUM)) 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIUSENUM IS NOT NULL AND t3.MIUSENUM IS NOT NULL AND t2.MIUSENUM <> t3.MIUSENUM) OR (t2.MIUSENUM IS NULL AND t3.MIUSENUM IS NOT NULL) OR (t2.MIUSENUM IS NOT NULL AND t3.MIUSENUM IS NULL))
and CCHLB='X')
union
--曾用名
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：曾用名'  变更对象,t3.CINAME2 变更前,t2.CINAME2 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.CINAME2 IS NOT NULL AND t3.CINAME2 IS NOT NULL AND t2.CINAME2 <> t3.CINAME2) OR (t2.CINAME2 IS NULL AND t3.CINAME2 IS NOT NULL) OR (t2.CINAME2 IS NOT NULL AND t3.CINAME2 IS NULL))
and CCHLB='X')
union
--用户地址
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：用户地址'  变更对象,t3.CIADR 变更前,t2.CIADR 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.CIADR IS NOT NULL AND t3.CIADR IS NOT NULL AND t2.CIADR <> t3.CIADR) OR (t2.CIADR IS NULL AND t3.CIADR IS NOT NULL) OR (t2.CIADR IS NOT NULL AND t3.CIADR IS NULL))
and CCHLB='X')
union
--证件类型
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：证件类型'  变更对象,(case when t3.CIIDENTITYLB ='1' then '身份证'
when t3.CIIDENTITYLB ='2' then '驾驶证'
else
'无' end)
 变更前,(case when t2.CIIDENTITYLB ='1' then '身份证'
when t2.CIIDENTITYLB ='2' then '驾驶证'
else
'无' end) 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.CIIDENTITYLB IS NOT NULL AND t3.CIIDENTITYLB IS NOT NULL AND t2.CIIDENTITYLB <> t3.CIIDENTITYLB) OR (t2.CIIDENTITYLB IS NULL AND t3.CIIDENTITYLB IS NOT NULL) OR (t2.CIIDENTITYLB IS NOT NULL AND t3.CIIDENTITYLB IS NULL))
and CCHLB='X')
union
--证件号码
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：证件号码'  变更对象,t3.CIIDENTITYNO 变更前,t2.CIIDENTITYNO 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.CIIDENTITYNO IS NOT NULL AND t3.CIIDENTITYNO IS NOT NULL AND t2.CIIDENTITYNO <> t3.CIIDENTITYNO) OR (t2.CIIDENTITYNO IS NULL AND t3.CIIDENTITYNO IS NOT NULL) OR (t2.CIIDENTITYNO IS NOT NULL AND t3.CIIDENTITYNO IS NULL))
and CCHLB='X')
union
--移动电话
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：移动电话'  变更对象,t3.CIMTEL 变更前,t2.CIMTEL 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.CIMTEL IS NOT NULL AND t3.CIMTEL IS NOT NULL AND t2.CIMTEL <> t3.CIMTEL) OR (t2.CIMTEL IS NULL AND t3.CIMTEL IS NOT NULL) OR (t2.CIMTEL IS NOT NULL AND t3.CIMTEL IS NULL))
and CCHLB='X')
union
--住宅电话
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：住宅电话'  变更对象,t3.CITEL1 变更前,t2.CITEL1 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.CITEL1 IS NOT NULL AND t3.CITEL1 IS NOT NULL AND t2.CITEL1 <> t3.CITEL1) OR (t2.CITEL1 IS NULL AND t3.CITEL1 IS NOT NULL) OR (t2.CITEL1 IS NOT NULL AND t3.CITEL1 IS NULL))
and CCHLB='X')
union
--办公电话
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：办公电话'  变更对象,t3.CITEL2 变更前,t2.CITEL2 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.CITEL2 IS NOT NULL AND t3.CITEL2 IS NOT NULL AND t2.CITEL2 <> t3.CITEL2) OR (t2.CITEL2 IS NULL AND t3.CITEL2 IS NOT NULL) OR (t2.CITEL2 IS NOT NULL AND t3.CITEL2 IS NULL))
and CCHLB='X')
union
--固定电话3
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：固定电话3'  变更对象,t3.CITEL3 变更前,t2.CITEL3 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.CITEL3 IS NOT NULL AND t3.CITEL3 IS NOT NULL AND t2.CITEL3 <> t3.CITEL3) OR (t2.CITEL3 IS NULL AND t3.CITEL3 IS NOT NULL) OR (t2.CITEL3 IS NOT NULL AND t3.CITEL3 IS NULL))
and CCHLB='X')
union
--联系人
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：联系人'  变更对象,t3.CICONNECTPER 变更前,t2.CICONNECTPER 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.CICONNECTPER IS NOT NULL AND t3.CICONNECTPER IS NOT NULL AND t2.CICONNECTPER <> t3.CICONNECTPER) OR (t2.CICONNECTPER IS NULL AND t3.CICONNECTPER IS NOT NULL) OR (t2.CICONNECTPER IS NOT NULL AND t3.CICONNECTPER IS NULL))
and CCHLB='X')
union
--联系电话
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：联系电话'  变更对象,t3.CICONNECTTEL 变更前,t2.CICONNECTTEL 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.CICONNECTTEL IS NOT NULL AND t3.CICONNECTTEL IS NOT NULL AND t2.CICONNECTTEL <> t3.CICONNECTTEL) OR (t2.CICONNECTTEL IS NULL AND t3.CICONNECTTEL IS NOT NULL) OR (t2.CICONNECTTEL IS NOT NULL AND t3.CICONNECTTEL IS NULL))
and CCHLB='X')
union
--是否提供短信服务
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：是否提供短信服务'  变更对象,decode(t3.CIIFSMS,'Y','是','N','否') 变更前,decode(t2.CIIFSMS,'Y','是','N','否') 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.CIIFSMS IS NOT NULL AND t3.CIIFSMS IS NOT NULL AND t2.CIIFSMS <> t3.CIIFSMS) OR (t2.CIIFSMS IS NULL AND t3.CIIFSMS IS NOT NULL) OR (t2.CIIFSMS IS NOT NULL AND t3.CIIFSMS IS NULL))
and CCHLB='X')
union
--档案号
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：档案号'  变更对象,t3.CIFILENO 变更前,t2.CIFILENO 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.CIFILENO IS NOT NULL AND t3.CIFILENO IS NOT NULL AND t2.CIFILENO <> t3.CIFILENO) OR (t2.CIFILENO IS NULL AND t3.CIFILENO IS NOT NULL) OR (t2.CIFILENO IS NOT NULL AND t3.CIFILENO IS NULL))
and CCHLB='X')
union
--用户备注信息
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：用户备注信息'  变更对象,t3.CIMEMO 变更前,t2.CIMEMO 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.CIMEMO IS NOT NULL AND t3.CIMEMO IS NOT NULL AND t2.CIMEMO <> t3.CIMEMO) OR (t2.CIMEMO IS NULL AND t3.CIMEMO IS NOT NULL) OR (t2.CIMEMO IS NOT NULL AND t3.CIMEMO IS NULL))
and CCHLB='X')
union
--收费方式
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：收费方式'  变更对象,fgetsyschargetype(t3.MICHARGETYPE) 变更前,fgetsyschargetype(t2.MICHARGETYPE) 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MICHARGETYPE IS NOT NULL AND t3.MICHARGETYPE IS NOT NULL AND t2.MICHARGETYPE <> t3.MICHARGETYPE) OR (t2.MICHARGETYPE IS NULL AND t3.MICHARGETYPE IS NOT NULL) OR (t2.MICHARGETYPE IS NOT NULL AND t3.MICHARGETYPE IS NULL))
and CCHLB='X')
union
--委托授权号
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：委托授权号'  变更对象,t3.MANO 变更前,t2.MANO 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MANO IS NOT NULL AND t3.MANO IS NOT NULL AND t2.MANO <> t3.MANO) OR (t2.MANO IS NULL AND t3.MANO IS NOT NULL) OR (t2.MANO IS NOT NULL AND t3.MANO IS NULL))
and CCHLB='X')
union
--签约户名
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：签约户名'  变更对象,t3.MANONAME 变更前,t2.MANONAME 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MANONAME IS NOT NULL AND t3.MANONAME IS NOT NULL AND t2.MANONAME <> t3.MANONAME) OR (t2.MANONAME IS NULL AND t3.MANONAME IS NOT NULL) OR (t2.MANONAME IS NOT NULL AND t3.MANONAME IS NULL))
and CCHLB='X')
union
--付款银行
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,
      '用户水表信息维护：付款银行'  变更对象,
      (case when t3.michargetype='T' then '['||fsmfid2hh(t3.MABANKID)||']'||fsmfid2hm(t3.mabankid) else FGETSYSMANAFRAME(t3.MABANKID) end) 变更前,
      (case when t2.michargetype='T' then '['||fsmfid2hh(t2.MABANKID)||']'||fsmfid2hm(t2.mabankid) else FGETSYSMANAFRAME(t2.MABANKID) end) 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t3.ccdrowno and t2.miid = t3.miid
 and ( (t2.MABANKID IS NOT NULL AND t3.MABANKID IS NOT NULL AND t2.MABANKID <> t3.MABANKID) OR (t2.MABANKID IS NULL AND t3.MABANKID IS NOT NULL) OR (t2.MABANKID IS NOT NULL AND t3.MABANKID IS NULL))
and CCHLB='X')
union
--付款帐号
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：付款帐号'  变更对象,t3.MAACCOUNTNO 变更前,t2.MAACCOUNTNO 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MAACCOUNTNO IS NOT NULL AND t3.MAACCOUNTNO IS NOT NULL AND t2.MAACCOUNTNO <> t3.MAACCOUNTNO) OR (t2.MAACCOUNTNO IS NULL AND t3.MAACCOUNTNO IS NOT NULL) OR (t2.MAACCOUNTNO IS NOT NULL AND t3.MAACCOUNTNO IS NULL))
and CCHLB='X')
union
--付款开户名
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：付款开户名'  变更对象,t3.MAACCOUNTNAME 变更前,t2.MAACCOUNTNAME 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MAACCOUNTNAME IS NOT NULL AND t3.MAACCOUNTNAME IS NOT NULL AND t2.MAACCOUNTNAME <> t3.MAACCOUNTNAME) OR (t2.MAACCOUNTNAME IS NULL AND t3.MAACCOUNTNAME IS NOT NULL) OR (t2.MAACCOUNTNAME IS NOT NULL AND t3.MAACCOUNTNAME IS NULL))
and CCHLB='X')
union
--收款银行
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：收款银行'  变更对象,FGETSYSMANAFRAME(t3.MATSBANKID) 变更前,FGETSYSMANAFRAME(t2.MATSBANKID) 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MATSBANKID IS NOT NULL AND t3.MATSBANKID IS NOT NULL AND t2.MATSBANKID <> t3.MATSBANKID) OR (t2.MATSBANKID IS NULL AND t3.MATSBANKID IS NOT NULL) OR (t2.MATSBANKID IS NOT NULL AND t3.MATSBANKID IS NULL))
and CCHLB='X')
union
--小额支付（托）
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：小额支付'  变更对象,t3.MAIFXEZF 变更前,t2.MAIFXEZF 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MAIFXEZF IS NOT NULL AND t3.MAIFXEZF IS NOT NULL AND t2.MAIFXEZF <> t3.MAIFXEZF) OR (t2.MAIFXEZF IS NULL AND t3.MAIFXEZF IS NOT NULL) OR (t2.MAIFXEZF IS NOT NULL AND t3.MAIFXEZF IS NULL))
and CCHLB='X')
union
--是否税票
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：是否税票'  变更对象,decode(t3.MIIFTAX,'Y','是','N','否') 变更前,decode(t2.MIIFTAX,'Y','是','N','否') 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIIFTAX IS NOT NULL AND t3.MIIFTAX IS NOT NULL AND t2.MIIFTAX <> t3.MIIFTAX) OR (t2.MIIFTAX IS NULL AND t3.MIIFTAX IS NOT NULL) OR (t2.MIIFTAX IS NOT NULL AND t3.MIIFTAX IS NULL))
and CCHLB='X')
union
--税号
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：税号'  变更对象,t3.MITAXNO 变更前,t2.MITAXNO 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MITAXNO IS NOT NULL AND t3.MITAXNO IS NOT NULL AND t2.MITAXNO <> t3.MITAXNO) OR (t2.MITAXNO IS NULL AND t3.MITAXNO IS NOT NULL) OR (t2.MITAXNO IS NOT NULL AND t3.MITAXNO IS NULL))
and CCHLB='X')
union
--水表备注信息
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：水表备注信息'  变更对象,t3.MIMEMO 变更前,t2.MIMEMO 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIMEMO IS NOT NULL AND t3.MIMEMO IS NOT NULL AND t2.MIMEMO <> t3.MIMEMO) OR (t2.MIMEMO IS NULL AND t3.MIMEMO IS NOT NULL) OR (t2.MIMEMO IS NOT NULL AND t3.MIMEMO IS NULL))
and CCHLB='X')
union
--是否混合
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：是否混合'  变更对象,decode(t3.MIIFMP,'Y','是','N','否') 变更前,decode(t2.MIIFMP,'Y','是','N','否') 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIIFMP IS NOT NULL AND t3.MIIFMP IS NOT NULL AND t2.MIIFMP <> t3.MIIFMP) OR (t2.MIIFMP IS NULL AND t3.MIIFMP IS NOT NULL) OR (t2.MIIFMP IS NOT NULL AND t3.MIIFMP IS NULL))
and CCHLB='X')
union
--用水类别
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：用水类别'  变更对象,FGETPRICEFRAME(t3.MIPFID) 变更前,FGETPRICEFRAME(t2.MIPFID) 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( t2.MIIFMP=t3.MIIFMP and t2.MIIFMP='N'  AND      ( (t2.MIPFID IS NOT NULL AND t3.MIPFID IS NOT NULL AND t2.MIPFID <> t3.MIPFID) OR (t2.MIPFID IS NULL AND t3.MIPFID IS NOT NULL) OR (t2.MIPFID IS NOT NULL AND t3.MIPFID IS NULL)))
and CCHLB='X')
union
--用水类别
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：用水类别'  变更对象,FGETPRICEFRAME(t3.PMDPFID)||'比例'||TO_CHAR(t3.PMDSCALE*100) 变更前,FGETPRICEFRAME(t2.PMDPFID)||'比例'||TO_CHAR(t2.PMDSCALE*100) 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( t2.MIIFMP=t3.MIIFMP and t2.MIIFMP='Y'  AND      (   (t2.PMDSCALE IS NOT NULL AND t3.PMDSCALE IS NOT NULL AND t2.PMDSCALE <> t3.PMDSCALE) OR (t2.PMDSCALE IS NULL AND t3.PMDSCALE IS NOT NULL) OR (t2.PMDSCALE IS NOT NULL AND t3.PMDSCALE IS NULL)
OR (t2.PMDPFID IS NOT NULL AND t3.PMDPFID IS NOT NULL AND t2.PMDPFID <> t3.PMDPFID) OR (t2.PMDPFID IS NULL AND t3.PMDPFID IS NOT NULL) OR (t2.PMDPFID IS NOT NULL AND t3.PMDPFID IS NULL)  ))
and CCHLB='X')
union
--用水类别
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：用水类别'  变更对象,FGETPRICEFRAME(t3.PMDPFID3)||'比例'||TO_CHAR(t3.PMDSCALE2*100) 变更前,FGETPRICEFRAME(t2.PMDPFID3)||'比例'||TO_CHAR(t2.PMDSCALE2*100) 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( t2.MIIFMP=t3.MIIFMP and t2.MIIFMP='Y'  AND      (   (t2.PMDSCALE2 IS NOT NULL AND t3.PMDSCALE2 IS NOT NULL AND t2.PMDSCALE2 <> t3.PMDSCALE2) OR (t2.PMDSCALE2 IS NULL AND t3.PMDSCALE2 IS NOT NULL) OR (t2.PMDSCALE2 IS NOT NULL AND t3.PMDSCALE2 IS NULL)
OR (t2.PMDPFID2 IS NOT NULL AND t3.PMDPFID2 IS NOT NULL AND t2.PMDPFID2 <> t3.PMDPFID2) OR (t2.PMDPFID2 IS NULL AND t3.PMDPFID2 IS NOT NULL) OR (t2.PMDPFID2 IS NOT NULL AND t3.PMDPFID2 IS NULL) ))
and CCHLB='X')
 union
--用水类别
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：用水类别'  变更对象,FGETPRICEFRAME(t3.PMDPFID3)||'比例'||TO_CHAR(t3.PMDSCALE3*100) 变更前,FGETPRICEFRAME(t2.PMDPFID3)||'比例'||TO_CHAR(t2.PMDSCALE3*100) 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( t2.MIIFMP=t3.MIIFMP and t2.MIIFMP='Y'  AND      (   (t2.PMDSCALE3 IS NOT NULL AND t3.PMDSCALE3 IS NOT NULL AND t2.PMDSCALE3 <> t3.PMDSCALE3) OR (t2.PMDSCALE3 IS NULL AND t3.PMDSCALE3 IS NOT NULL) OR (t2.PMDSCALE3 IS NOT NULL AND t3.PMDSCALE3 IS NULL)
OR (t2.PMDPFID3 IS NOT NULL AND t3.PMDPFID3 IS NOT NULL AND t2.PMDPFID3 <> t3.PMDPFID3) OR (t2.PMDPFID3 IS NULL AND t3.PMDPFID3 IS NOT NULL) OR (t2.PMDPFID3 IS NOT NULL AND t3.PMDPFID3 IS NULL)  ))
and CCHLB='X')
union
--用水类别
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：用水类别'  变更对象,FGETPRICEFRAME(t3.PMDPFID4)||'比例'||TO_CHAR(t3.PMDSCALE4*100) 变更前,FGETPRICEFRAME(t2.PMDPFID4)||'比例'||TO_CHAR(t2.PMDSCALE4*100) 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( t2.MIIFMP=t3.MIIFMP and t2.MIIFMP='Y'  AND      (   (t2.PMDSCALE4 IS NOT NULL AND t3.PMDSCALE4 IS NOT NULL AND t2.PMDSCALE4 <> t3.PMDSCALE4) OR (t2.PMDSCALE4 IS NULL AND t3.PMDSCALE4 IS NOT NULL) OR (t2.PMDSCALE4 IS NOT NULL AND t3.PMDSCALE4 IS NULL)
OR (t2.PMDPFID4 IS NOT NULL AND t3.PMDPFID4 IS NOT NULL AND t2.PMDPFID4 <> t3.PMDPFID4) OR (t2.PMDPFID4 IS NULL AND t3.PMDPFID4 IS NOT NULL) OR (t2.PMDPFID4 IS NOT NULL AND t3.PMDPFID4 IS NULL)
 ))and CCHLB='X')
union

--用水类别
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：用水类别'  变更对象,FGETPRICEFRAME(t3.MIPFID) 变更前,FGETPRICEFRAME(t2.PMDPFID)||'比例'||TO_CHAR(t2.PMDSCALE*100) 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( t2.MIIFMP<>t3.MIIFMP and t2.MIIFMP='Y'  AND      (   t2.PMDPFID IS NOT NULL ))
and CCHLB='X')
union
--用水类别
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：用水类别'  变更对象,FGETPRICEFRAME(t3.MIPFID) 变更前,FGETPRICEFRAME(t2.PMDPFID2)||'比例'||TO_CHAR(t2.PMDSCALE2*100) 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( t2.MIIFMP<>t3.MIIFMP and t2.MIIFMP='Y'  AND      (   t2.PMDPFID2 IS NOT NULL ))
and CCHLB='X')
union
--用水类别
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：用水类别'  变更对象,FGETPRICEFRAME(t3.MIPFID) 变更前,FGETPRICEFRAME(t2.PMDPFID3)||'比例'||TO_CHAR(t2.PMDSCALE3*100) 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( t2.MIIFMP<>t3.MIIFMP and t2.MIIFMP='Y'  AND      (   t2.PMDPFID3 IS NOT NULL ))
and CCHLB='X')
union
--用水类别
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：用水类别'  变更对象,FGETPRICEFRAME(t3.MIPFID) 变更前,FGETPRICEFRAME(t2.PMDPFID4)||'比例'||TO_CHAR(t2.PMDSCALE4*100) 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( t2.MIIFMP<>t3.MIIFMP and t2.MIIFMP='Y'  AND      (   t2.PMDPFID4 IS NOT NULL ))
and CCHLB='X')
UNION
--用水类别
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：用水类别'  变更对象,FGETPRICEFRAME(t3.PMDPFID)||'比例'||TO_CHAR(t3.PMDSCALE*100)  变更前,FGETPRICEFRAME(t2.MIPFID) 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( t2.MIIFMP<>t3.MIIFMP and t2.MIIFMP='N'  AND      (   t3.PMDPFID IS NOT NULL ))
 and CCHLB='X')
 UNION
--用水类别
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：用水类别'  变更对象,FGETPRICEFRAME(t3.PMDPFID2)||'比例'||TO_CHAR(t3.PMDSCALE2*100)  变更前,FGETPRICEFRAME(t2.MIPFID) 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( t2.MIIFMP<>t3.MIIFMP and t2.MIIFMP='N'  AND      (   t3.PMDPFID2 IS NOT NULL ))
and CCHLB='X')
UNION
--用水类别
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：用水类别'  变更对象,FGETPRICEFRAME(t3.PMDPFID3)||'比例'||TO_CHAR(t3.PMDSCALE3*100)  变更前,FGETPRICEFRAME(t2.MIPFID) 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( t2.MIIFMP<>t3.MIIFMP and t2.MIIFMP='N'  AND      (   t3.PMDPFID3 IS NOT NULL ))
and CCHLB='X')
UNION
--用水类别
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：用水类别'  变更对象,FGETPRICEFRAME(t3.PMDPFID4)||'比例'||TO_CHAR(t3.PMDSCALE4*100)  变更前,FGETPRICEFRAME(t2.MIPFID) 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( t2.MIIFMP<>t3.MIIFMP and t2.MIIFMP='N'  AND      (   t3.PMDPFID4 IS NOT NULL ))
and CCHLB='X')
union
--是否磁控阀
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：是否磁控阀'  变更对象,decode(t3.MIIFCKF,'Y','是','N','否') 变更前,decode(t2.MIIFCKF,'Y','是','N','否') 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIIFCKF IS NOT NULL AND t3.MIIFCKF IS NOT NULL AND t2.MIIFCKF <> t3.MIIFCKF) OR (t2.MIIFCKF IS NULL AND t3.MIIFCKF IS NOT NULL) OR (t2.MIIFCKF IS NOT NULL AND t3.MIIFCKF IS NULL))
and CCHLB='X')
union
--GPS地址
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：GPS地址'  变更对象,t3.MIGPS 变更前,t2.MIGPS 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIGPS IS NOT NULL AND t3.MIGPS IS NOT NULL AND t2.MIGPS <> t3.MIGPS) OR (t2.MIGPS IS NULL AND t3.MIGPS IS NOT NULL) OR (t2.MIGPS IS NOT NULL AND t3.MIGPS IS NULL))
and CCHLB='X')
union
--铅封号
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：铅封号'  变更对象,t3.MIQFH 变更前,t2.MIQFH 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIQFH IS NOT NULL AND t3.MIQFH IS NOT NULL AND t2.MIQFH <> t3.MIQFH) OR (t2.MIQFH IS NULL AND t3.MIQFH IS NOT NULL) OR (t2.MIQFH IS NOT NULL AND t3.MIQFH IS NULL))
and CCHLB='X')
union
--钢封号
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：钢封号'  变更对象,t3.dqgfh 变更前,t2.dqgfh 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.dqgfh  IS NOT NULL AND t3.dqgfh IS NOT NULL AND t2.dqgfh <> t3.dqgfh) OR (t2.dqgfh IS NULL AND t3.dqgfh IS NOT NULL) OR (t2.dqgfh IS NOT NULL AND t3.dqgfh IS NULL))
and CCHLB='X')
union
--塑封号
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：塑封号'  变更对象,t3.dqsfh 变更前,t2.dqsfh 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.dqsfh  IS NOT NULL AND t3.dqsfh  IS NOT NULL AND t2.dqsfh <> t3.dqsfh) OR (t2.dqsfh IS NULL AND t3.dqsfh IS NOT NULL) OR (t2.dqsfh IS NOT NULL AND t3.dqsfh  IS NULL))
and CCHLB='X')
union
--稽查刚封号
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：稽查刚封号 '  变更对象,t3.jcgfh 变更前,t2.jcgfh 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.jcgfh  IS NOT NULL AND t3.jcgfh IS NOT NULL AND t2.jcgfh <> t3.jcgfh) OR (t2.jcgfh IS NULL AND t3.jcgfh IS NOT NULL) OR (t2.jcgfh IS NOT NULL AND t3.jcgfh IS NULL))
and CCHLB='X')
union
--表箱规格
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：表箱规格'  变更对象,t3.MIBOX 变更前,t2.MIBOX 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MIBOX IS NOT NULL AND t3.MIBOX IS NOT NULL AND t2.MIBOX <> t3.MIBOX) OR (t2.MIBOX IS NULL AND t3.MIBOX IS NOT NULL) OR (t2.MIBOX IS NOT NULL AND t3.MIBOX IS NULL))
and CCHLB='X')
union
--票据名称
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：票据名称'  变更对象,t3.MINAME 变更前,t2.MINAME 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MINAME IS NOT NULL AND t3.MINAME IS NOT NULL AND t2.MINAME <> t3.MINAME) OR (t2.MINAME IS NULL AND t3.MINAME IS NOT NULL) OR (t2.MINAME IS NOT NULL AND t3.MINAME IS NULL))
and CCHLB='X')
union
--招牌名称
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：招牌名称'  变更对象,t3.MINAME2 变更前,t2.MINAME2 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.MINAME2 IS NOT NULL AND t3.MINAME2 IS NOT NULL AND t2.MINAME2 <> t3.MINAME2) OR (t2.MINAME2 IS NULL AND t3.MINAME2 IS NOT NULL) OR (t2.MINAME2 IS NOT NULL AND t3.MINAME2 IS NULL))
and CCHLB='X')
union
--街道
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：街道'  变更对象,'' 变更前,t2.mijd 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and t2.mijd IS NOT NULL
and CCHLB='X')
union
--楼号
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：楼号'  变更对象,'' 变更前,t2.lh 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and t2.lh IS NOT NULL
and CCHLB='X')
union
--门牌号
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：门牌号'  变更对象,'' 变更前,t2.mph 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and t2.mph IS NOT NULL
and CCHLB='X')
union
--单元号
(
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户水表信息维护：单元号'  变更对象,'' 变更前,t2.dyh 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and t2.dyh IS NOT NULL
and CCHLB='X')
--信用评级
;

