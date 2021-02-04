create or replace force view hrbzls.vie_变更管理_用户增值税管理 as
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户增值税管理：是否增值税'  变更对象,decode(t3.miiftax,'Y','是','N','否') 变更前,decode(t2.miiftax,'Y','是','N','否') 变更后,'Y' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.miiftax IS NOT NULL AND t3.miiftax IS NOT NULL AND t2.miiftax <> t3.miiftax) OR (t2.miiftax IS NULL AND t3.miiftax IS NOT NULL) OR (t2.miiftax IS NOT NULL AND t3.miiftax IS NULL))
and t1.cchlb='33'
---是否增值税
---增值税号
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'用户增值税管理：增值税号'  变更对象,t3.mitaxno 变更前,t2.mitaxno 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.mitaxno IS NOT NULL AND t3.mitaxno IS NOT NULL AND t2.mitaxno <> t3.mitaxno) OR (t2.mitaxno IS NULL AND t3.mitaxno IS NOT NULL) OR (t2.mitaxno IS NOT NULL AND t3.mitaxno IS NULL))
and t1.cchlb='33'
;

