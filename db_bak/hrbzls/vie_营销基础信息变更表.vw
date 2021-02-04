create or replace force view hrbzls.vie_营销基础信息变更表 as
select 流水单号,decode(单据类别,'17','表故障','22','总表收免','U','水表倒装','w','污水超标') 单据类别,营销公司,创建日期,创建人,审核日期,审核人,审核标志
from
(select CCHNO 流水单号,CCHLB 单据类别,CISMFID 营销公司,CCHCREDATE 创建日期,CCHCREPER 创建人
,CCHSHDATE 审核日期,CCHSHPER 审核人,CCHSHFLAG 审核标志
from CUSTCHANGEDT,CUSTCHANGEhd where cchlb in ('17','22','U') and CCDNO=CCHNO
union
select CRHNO 流水单号,CRHLB 单据类别,CRHSMFID 营销公司,crhcredate 创建日期,crhcreper 创建人员
,crhshdate 审核日期,crhshper  审核人员,crhshflag 审核标志
  from TDSJhd where CRHLB='w');

