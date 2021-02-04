create or replace force view hrbzls.vie_变更管理_总表收免管理 as
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'总表收免管理：维护类型'  变更对象,decode(t3.miyl2,'0','普通表','1','总表收免','2','多级表') 变更前,decode(t2.miyl2,'0','普通表','1','总表收免','2','多级表') 变更后,'Y' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.miyl2 IS NOT NULL AND t3.miyl2 IS NOT NULL AND t2.miyl2 <> t3.miyl2) OR (t2.miyl2 IS NULL AND t3.miyl2 IS NOT NULL) OR (t2.miyl2 IS NOT NULL AND t3.miyl2 IS NULL))
and t1.cchlb='22'
---维护类型
---总表收免水量最大值
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'总表收免管理：总表收免水量最大值'  变更对象,to_char(t3.miyl7) 变更前,to_char(t2.miyl7) 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.miyl7 IS NOT NULL AND t3.miyl7 IS NOT NULL AND t2.miyl7 <> t3.miyl7) OR (t2.miyl7 IS NULL AND t3.miyl7 IS NOT NULL) OR (t2.miyl7 IS NOT NULL AND t3.miyl7 IS NULL))
and t1.cchlb='22'
---申请说明
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'总表收免管理：申请说明'  变更对象,'' 变更前,ccdappnote 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ccdappnote is not null
and t1.cchlb='22'
---备注信息
union
select CCHNO 变更流水号,CCHLB 单据类别,CCHSMFID 营销公司,CCHCREPER 登记人员,CCHCREDATE 登记日期,CCHSHPER 审核人员,CCHSHDATE 审核日期,CCHSHFLAG 审核标志,t3.MIID  水表编号,t3.MICODE 资料号,t3.CIID    用户编号,t3.CICODE  用户号,t2.ciname 用户名,t2.ciadr 用户地址,'总表收免管理：备注信息'  变更对象,t3.mimemo 变更前, t2.mimemo 变更后,'N' 状态
from CUSTCHANGEHD t1, CUSTCHANGEDT t2, CUSTCHANGEDTHIS t3
where t1.CCHNO = t2.ccdno and t1.cchno = t3.ccdno and t2.ccdrowno = t2.ccdrowno and t2.miid = t3.miid  and ( (t2.mimemo IS NOT NULL AND t3.mimemo IS NOT NULL AND t2.mimemo <> t3.mimemo) OR (t2.mimemo IS NULL AND t3.mimemo IS NOT NULL) OR (t2.mimemo IS NOT NULL AND t3.mimemo IS NULL))
and t1.cchlb='22'
;

