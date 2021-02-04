create or replace force view hrbzls.vie_变更管理_污水超标管理 as
select cmrdno  变更流水号,crhlb  单据类别,crhsmfid 营销公司  ,crhcreper  登记人员,crhcredate  登记日期,crhshper  审核人员,crhshdate  审核日期,crhshflag  审核标志,t2.MIID  水表编号,t2.MICODE 资料号,t2.CIID    用户编号,t2.CICODE  用户号,ciname 用户名, ciadr 用户地址,   '污水超标管理：调整方法'  变更对象,'' 变更前,decode(t1.pamid,'01','固定单价调整') 变更后,'N' 状态
from TDSJDT t1 ,TDSJHD t2
where t1.cmrdno = t2.crhno  and  t1.cmrdrowno  = t1.cmrdrowno    and   (t1.pamid IS NOT NULL )
and t2.crhlb='w'
---调整方法
---调整值
union
select cmrdno  变更流水号,crhlb  单据类别,crhsmfid 营销公司,crhcreper  登记人员,crhcredate  登记日期,crhshper  审核人员,crhshdate  审核日期,crhshflag  审核标志,t2.MIID  水表编号,t2.MICODE 资料号,t2.CIID    用户编号,t2.CICODE  用户号,ciname 用户名, ciadr 用户地址,'污水超标管理：调整值'  变更对象,'' 变更前,to_char(cmnewvalue) 变更后,'N' 状态
from TDSJDT t1 ,TDSJHD t2
where t1.cmrdno = t2.crhno  and  t1.cmrdrowno  = t1.cmrdrowno    and   (t1.cmnewvalue IS NOT NULL )
and t2.crhlb='w'
---取消污水超标
union
select cmrdno  变更流水号,crhlb  单据类别,crhsmfid 营销公司,crhcreper  登记人员,crhcredate  登记日期,crhshper  审核人员,crhshdate  审核日期,crhshflag  审核标志,t2.MIID  水表编号,t2.MICODE 资料号,t2.CIID    用户编号,t2.CICODE  用户号,ciname 用户名, ciadr 用户地址,'污水超标管理：取消污水超标'  变更对象,'' 变更前,decode(cmtype,'Y','是','N','否') 变更后,'Y' 状态
from TDSJDT t1 ,TDSJHD t2
where t1.cmrdno = t2.crhno  and  t1.cmrdrowno  = t1.cmrdrowno    and   (t1.cmtype IS NOT NULL )
and t2.crhlb='w'
;

