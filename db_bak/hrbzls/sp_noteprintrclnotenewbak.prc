CREATE OR REPLACE PROCEDURE HRBZLS."SP_NOTEPRINTRCLNOTENEWBAK" (
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
SELECT
A.RLID ,                            --C1
A.RLMID  ,                          --C2
A.应收月份,                         --C3
A.用户号 ,                          --C4
A.资料号 ,                          --C5
A.表身号,                           --C6
A.用户名,                           --C7
A.用户地址,                         --C8
A.水表地址,                         --C9
A.表册号,                           --C10
A.抄表序号,                         --C11
A.上月行度,                         --C12
A.本月行度,                         --C13
A.抄见水量,                         --C14
A.基本水价 ,                        --C15
A.基本水费,                         --C16
A.污水量,                           --C17
A.污水价,                           --C18
A.污水费,                           --C19
B.结转水量,                         --C20
B.结转基本水费滞纳金,               --C21
B.结转基本水费,                     --C22
B.结转污水量,                       --C23
B.结转污水费滞纳金,                 --C24
B.结转污水费,                       --C25
substr(to_char(SYSDATE,'yyyymmdd'),1,4)||'    '||substr(to_char(SYSDATE,'yyyymmdd'),5,2)||'    '||substr(to_char(SYSDATE,'yyyymmdd'),7,2) 打印日期,   --C26
'预留字段1'           预留字段1  ,  --C27
'预留字段2'           预留字段2  ,  --C28
'预留字段3'           预留字段3  ,  --C29
'预留字段4'           预留字段4  ,  --C30
'预留字段5'           预留字段5  ,  --C31
'预留字段6'           预留字段6  ,  --C32
'预留字段7'           预留字段7  ,  --C33
'预留字段8'           预留字段8  ,  --C34
'预留字段9'           预留字段9  ,  --C35
'预留字段10'          预留字段10 ,  --C36
'预留字段11'          预留字段11 ,  --C37
'预留字段12'          预留字段12 ,  --C38
'预留字段13'          预留字段13 ,  --C39
'预留字段14'          预留字段14 ,  --C40
'预留字段15'          预留字段15 ,  --C41
'预留字段16'          预留字段16 ,  --C42
'预留字段17'          预留字段17 ,  --C43
'预留字段18'          预留字段18 ,  --C44
'预留字段19'          预留字段19 ,  --C45
'预留字段20'          预留字段20    --C46
 FROM
(
select RLID,max(rlmonth) 应收月份,max(RLMID) RLMID,max(rlccode) 用户号, MAX(RLMCODE) 资料号,max(mdno) 表身号, max(RLCNAME) 用户名 ,MAX(RLCADR) 用户地址,max(RLMADR ) 水表地址, max(mibfid) 表册号, max(MIRORDER ) 抄表序号, max( rlscode ) 上月行度,max( rlecode ) 本月行度,
MAX(RLREADSL ) 抄见水量 ,
sum(
 (case when rdpiid='01' then rddj*RDPMDSCALE else 0 end)
)  基本水价,
sum((case when rdpiid='01' then rdje else 0 end)) 基本水费,
sum( case when rdpiid='02' then rdsl*RDPMDSCALE else 0 end  ) 污水量,
sum(
 (case when rdpiid='02' then rddj*RDPMDSCALE else 0 end)
)   污水价,
sum((case when rdpiid='02' then rdje else 0 end)) 污水费
from reclist ,recdetail,meterinfo,meterdoc,bookframe
  where rlid=rdid and rlmid=miid and miid=mdmid and rlbfid=bfid and rlsmfid=bfsmfid
AND  RLCD='DE' and rdje>0

and (p_smfid is null or rlsmfid=p_smfid)

and (p_monmin is null or rlmonth>=p_monmin)
and (p_monmax is null or rlmonth<=p_monmax)
and (
 (p_monmin is null and  p_monmax is  null)
 or
 (p_monmin is not null and  p_monmax is not null)
 or
 (p_monmin is  null and  p_monmax is not null and rlmonth=p_monmax)
 or
 (p_monmin is not  null and  p_monmax is  null and rlmonth=p_monmin)
 )
and (p_micodemin is null or rlmcode>=p_micodemin)
and (p_micodemax is null or rlmcode<=p_micodemax)
and (
 (p_micodemin is null and  p_micodemax is  null)
 or
 (p_micodemin is not null and  p_micodemax is not null)
 or
 (p_micodemin is  null and  p_micodemax is not null and rlmcode=p_micodemax)
 or
 (p_micodemin is not  null and  p_micodemax is  null and rlmcode=p_micodemin)
 )
and (p_cicodemin is null or rlccode>=p_cicodemin)
and (p_cicodemax is null or rlccode<=p_cicodemax)
and (
 (p_cicodemin is null and  p_cicodemax is  null)
 or
 (p_cicodemin is not null and  p_cicodemax is not null)
 or
 (p_cicodemin is  null and  p_cicodemax is not null and rlccode=p_cicodemax)
 or
 (p_cicodemin is not  null and  p_cicodemax is  null and rlccode=p_cicodemin)
 )


and (p_bfidmin is null or rlbfid>=p_bfidmin)
and (p_bfidmax is null or rlbfid<=p_bfidmax)
and (
 (p_bfidmin is null and  p_bfidmax is  null)
 or
 (p_bfidmin is not null and  p_bfidmax is not null)
 or
 (p_bfidmin is  null and  p_bfidmax is not null and rlbfid=p_bfidmax)
 or
 (p_bfidmin is not  null and  p_bfidmax is  null and rlbfid=p_bfidmin)
 )
and (p_mrrper is null or BFRPER = p_mrrper)
and (p_rlcper is null or RLCHARGEPER=p_rlcper)

and (p_rldatemin is null or rldate>=to_date(p_rldatemin,'yyyy-mm-dd'))
and (p_rldatemax is null or rldate<to_date(p_rldatemax,'yyyy-mm-dd') + 1 )
and (
 (p_rldatemin is null and  p_rldatemax is  null)
 or
 (p_rldatemin is not null and  p_rldatemax is not null)
 or
 (p_rldatemin is  null and  p_rldatemax is not null and (rldate>=to_date(p_rldatemax,'yyyy-mm-dd') and rldate<to_date(p_rldatemax,'yyyy-mm-dd') + 1 )  )
 or
 (p_rldatemin is not  null and  p_rldatemax is  null and (rldate>=to_date(p_rldatemin,'yyyy-mm-dd') and rldate<to_date(p_rldatemin,'yyyy-mm-dd') + 1 )  )
 )
and (p_mrdaymin is null or RLRDATE>=to_date(p_mrdaymin,'yyyy-mm-dd'))
and (p_mrdaymax is null or RLRDATE<to_date(p_mrdaymax,'yyyy-mm-dd') + 1 )
and (
 (p_mrdaymin is null and  p_mrdaymax is  null)
 or
 (p_mrdaymin is not null and  p_mrdaymax is not null)
 or
 (p_mrdaymin is  null and  p_mrdaymax is not null and (RLRDATE>=to_date(p_mrdaymax,'yyyy-mm-dd') and RLRDATE<to_date(p_mrdaymax,'yyyy-mm-dd') + 1 )  )
 or
 (p_mrdaymin is not  null and  p_mrdaymax is  null and (RLRDATE>=to_date(p_mrdaymin,'yyyy-mm-dd') and RLRDATE<to_date(p_mrdaymin,'yyyy-mm-dd') + 1 )  )
 )

GROUP BY RLID
) A
LEFT JOIN
(
SELECT RLMID,sum( case when rdpiid='01' then rdsl*RDPMDSCALE else 0 end  ) 结转水量,
0  结转基本水费滞纳金,
sum((case when rdpiid='01' then rdje else 0 end)) 结转基本水费,
sum( case when rdpiid='02' then rdsl*RDPMDSCALE else 0 end  ) 结转污水量,
0 结转污水费滞纳金,
sum((case when rdpiid='02' then rdje else 0 end)) 结转污水费
 FROM reclist ,recdetail where rlid=rdid AND RLCD='DE' AND RDPAIDFLAG='N' AND  rdje>0  AND (p_monmin is null or rlmonth<p_monmin) and (p_monmax is null or rlmonth<p_monmax)
AND RLMID IN (
select RLMID
from reclist ,recdetail,meterinfo,meterdoc,bookframe
  where rlid=rdid and rlmid=miid and miid=mdmid and rlbfid=bfid and rlsmfid=bfsmfid
AND  RLCD='DE' and rdje>0

and (p_smfid is null or rlsmfid=p_smfid)

and (p_monmin is null or rlmonth>=p_monmin)
and (p_monmax is null or rlmonth<=p_monmax)
and (
 (p_monmin is null and  p_monmax is  null)
 or
 (p_monmin is not null and  p_monmax is not null)
 or
 (p_monmin is  null and  p_monmax is not null and rlmonth=p_monmax)
 or
 (p_monmin is not  null and  p_monmax is  null and rlmonth=p_monmin)
 )
and (p_micodemin is null or rlmcode>=p_micodemin)
and (p_micodemax is null or rlmcode<=p_micodemax)
and (
 (p_micodemin is null and  p_micodemax is  null)
 or
 (p_micodemin is not null and  p_micodemax is not null)
 or
 (p_micodemin is  null and  p_micodemax is not null and rlmcode=p_micodemax)
 or
 (p_micodemin is not  null and  p_micodemax is  null and rlmcode=p_micodemin)
 )
and (p_cicodemin is null or rlccode>=p_cicodemin)
and (p_cicodemax is null or rlccode<=p_cicodemax)
and (
 (p_cicodemin is null and  p_cicodemax is  null)
 or
 (p_cicodemin is not null and  p_cicodemax is not null)
 or
 (p_cicodemin is  null and  p_cicodemax is not null and rlccode=p_cicodemax)
 or
 (p_cicodemin is not  null and  p_cicodemax is  null and rlccode=p_cicodemin)
 )


and (p_bfidmin is null or rlbfid>=p_bfidmin)
and (p_bfidmax is null or rlbfid<=p_bfidmax)
and (
 (p_bfidmin is null and  p_bfidmax is  null)
 or
 (p_bfidmin is not null and  p_bfidmax is not null)
 or
 (p_bfidmin is  null and  p_bfidmax is not null and rlbfid=p_bfidmax)
 or
 (p_bfidmin is not  null and  p_bfidmax is  null and rlbfid=p_bfidmin)
 )
and (p_mrrper is null or BFRPER = p_mrrper)
and (p_rlcper is null or RLCHARGEPER=p_rlcper)

and (p_rldatemin is null or rldate>=to_date(p_rldatemin,'yyyy-mm-dd'))
and (p_rldatemax is null or rldate<to_date(p_rldatemax,'yyyy-mm-dd') + 1 )
and (
 (p_rldatemin is null and  p_rldatemax is  null)
 or
 (p_rldatemin is not null and  p_rldatemax is not null)
 or
 (p_rldatemin is  null and  p_rldatemax is not null and (rldate>=to_date(p_rldatemax,'yyyy-mm-dd') and rldate<to_date(p_rldatemax,'yyyy-mm-dd') + 1 )  )
 or
 (p_rldatemin is not  null and  p_rldatemax is  null and (rldate>=to_date(p_rldatemin,'yyyy-mm-dd') and rldate<to_date(p_rldatemin,'yyyy-mm-dd') + 1 )  )
 )
and (p_mrdaymin is null or RLRDATE>=to_date(p_mrdaymin,'yyyy-mm-dd'))
and (p_mrdaymax is null or RLRDATE<to_date(p_mrdaymax,'yyyy-mm-dd') + 1 )
and (
 (p_mrdaymin is null and  p_mrdaymax is  null)
 or
 (p_mrdaymin is not null and  p_mrdaymax is not null)
 or
 (p_mrdaymin is  null and  p_mrdaymax is not null and (RLRDATE>=to_date(p_mrdaymax,'yyyy-mm-dd') and RLRDATE<to_date(p_mrdaymax,'yyyy-mm-dd') + 1 )  )
 or
 (p_mrdaymin is not  null and  p_mrdaymax is  null and (RLRDATE>=to_date(p_mrdaymin,'yyyy-mm-dd') and RLRDATE<to_date(p_mrdaymin,'yyyy-mm-dd') + 1 )  )
 )
)
GROUP BY RLMID
) B
ON A.RLMID=B.RLMID

;

end ;
/

