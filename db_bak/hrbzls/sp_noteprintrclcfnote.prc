CREATE OR REPLACE PROCEDURE HRBZLS."SP_NOTEPRINTRCLCFNOTE" (
p_smfid             in varchar2, --营业所
p_monmin            in varchar2, --月份
p_monmax            in varchar2, --月份
p_micodemin         in varchar2, --资料号
p_micodemax         in varchar2, --资料号
p_cicodemin         in varchar2, --客户号
p_cicodemax         in varchar2, --客户号
p_bfidmin           in varchar2, --表册
p_bfidmax           in varchar2, --表册
p_mrrper            in varchar2, --抄表员
p_rlcper            in varchar2, --催费员
p_rldatemin         in varchar2, --算费日期
p_rldatemax         in varchar2, --算费日期
p_mrdaymin          in varchar2, --抄表日期
p_mrdaymax          in varchar2, --抄表日期
p_milb              in varchar2, --水表类型
p_qfcount           in varchar2, --欠费期数
p_qfje              in varchar2, --欠费金额
o_base out tools.out_base) is
  begin


    open o_base for
select
a.miid,                   --C1
a.用户名,                 --C2
a.用户地址,               --C3
a.资料号,                 --C4
a.表身码,                 --C5
a.水费大年月,             --C6
a.水费小年月,             --C7
a.污水大年月,             --C8
a.污水小年月,             --C9
a.水费,                   --C10
a.污水水费,               --C11
a.欠费笔数,               --C12
a.合计,                   --C13
a.日期,                   --C14
a.表册,                   --C15
a.抄表次序,               --C16
a.客户号,                 --C17
a.水表地址,               --C18
'预留字段1'   预留字段1  , --预留字段1  C19
'预留字段2'   预留字段2  , --预留字段2  C20
'预留字段3'   预留字段3  , --预留字段3  C21
'预留字段4'   预留字段4  , --预留字段4  C22
'预留字段5'   预留字段5  , --预留字段5  C23
1   预留字段6  , --预留字段6            C24
1   预留字段7  , --预留字段7            C25
SYSDATE   预留字段8  , --预留字段8      C26
SYSDATE   预留字段9   --预留字段9       C27
from (
select miid,MAX(ciname) 用户名,MAX(ciadr) 用户地址,MAX(micode) 资料号,MAX(mdno) 表身码,
max(mibfid) 表册,max(mirorder ) 抄表次序,max(cicode) 客户号,max(miadr) 水表地址,
max( case when  rdpiid='01' then rlmonth else '0000.00' end )  水费大年月,
min( case when  rdpiid='01' then rlmonth else '9999.01' end )  水费小年月,
max( case when  rdpiid='02' then rlmonth else '0000.00' end )  污水大年月,
min( case when  rdpiid='02' then rlmonth else '9999.01' end )  污水小年月,
SUM(case when  rdpiid='01' then RDJE else 0 end ) 水费,
SUM(case when  rdpiid='02' then RDJE else 0 end ) 污水水费,
count(distinct rlid) 欠费笔数,
sum( rdje ) 合计 ,
'15'  日期
from reclist ,recdetail,meterinfo, custinfo , meterdoc , bookframe
where rlid=rdid and rlmid=miid and miid=mdmid and  micid=ciid and mibfid=bfid and mismfid=bfsmfid
and rlcd='DE' and rdpaidflag='N' and rdje>0


and (p_smfid is null or mismfid=p_smfid)
and (p_micodemin is null or micode>=p_micodemin)
and (p_micodemax is null or micode<=p_micodemax)
and (
 (p_micodemin is null and  p_micodemax is  null)
 or
 (p_micodemin is not null and  p_micodemax is not null)
 or
 (p_micodemin is  null and  p_micodemax is not null and micode=p_micodemax)
 or
 (p_micodemin is not  null and  p_micodemax is  null and micode=p_micodemin)
 )
and (p_cicodemin is null or cicode>=p_cicodemin)
and (p_cicodemax is null or cicode<=p_cicodemax)
and (
 (p_cicodemin is null and  p_cicodemax is  null)
 or
 (p_cicodemin is not null and  p_cicodemax is not null)
 or
 (p_cicodemin is  null and  p_cicodemax is not null and cicode=p_cicodemax)
 or
 (p_cicodemin is not  null and  p_cicodemax is  null and cicode=p_cicodemin)
 )
and (p_bfidmin is null or mibfid>=p_bfidmin)
and (p_bfidmax is null or mibfid<=p_bfidmax)
and (
 (p_bfidmin is null and  p_bfidmax is  null)
 or
 (p_bfidmin is not null and  p_bfidmax is not null)
 or
 (p_bfidmin is  null and  p_bfidmax is not null and mibfid=p_bfidmax)
 or
 (p_bfidmin is not  null and  p_bfidmax is  null and mibfid=p_bfidmin)
 )
and (p_mrrper is null or  BFRPER=p_mrrper)
and (p_rlcper is null or  MICPER=p_rlcper)
and (p_milb is null or  milb=p_milb)

group by miid
) a
where  (p_qfcount is null or  a.欠费笔数>=p_qfcount) and  (p_qfje is null or  a.合计>=p_qfje)  ;

end ;
/

