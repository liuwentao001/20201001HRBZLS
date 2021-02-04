CREATE OR REPLACE FORCE VIEW HRBZLS.V_资金回收报表 AS
(
SELECT
 A.营业所,
 A.月份,
 sum(A.坐收) 坐收金额,
 sum(A.走收+ A.基补) 走收金额,
 sum(A.基补)  基补,
 sum(B.大厅票面) 大厅票面,
 round(sum((B.大厅票面 - A.基补)*B.水费分摊),2) 地区售水大厅,
 sum(B.银行票面)  银行票面,
 round(sum(B.银行票面*B.水费分摊),2)  银行,
 round(sum((B.大厅票面 - A.基补)*B.污水分摊),2) 售水大厅污水,
 round(sum(B.银行票面*B.污水分摊),2) 银行污水
FROM
( select
 RSD.OFAGENT 营业所,
 RSD.U_MONTH 月份,
 RSD.WATERTYPE 性质,
 SUM(CASE WHEN RSD.T16 not in ('u', '13', 'v', '14', '21','23') AND RSD.CHAREGETYPE='X' THEN  NVL(RSD.X37,0)  ELSE 0 END ) 坐收,
SUM(CASE WHEN RSD.T16 not in ('u', '13', 'v', '14', '21','23') AND RSD.CHAREGETYPE='M' THEN  NVL(RSD.X37,0)  ELSE 0 END ) 走收,
SUM(CASE WHEN RSD.T16  in ( 'u', '13')  THEN  NVL(RSD.X37,0)  ELSE 0 END ) 基补
 from RPT_SUM_DETAIL RSD

 GROUP BY RSD.OFAGENT,RSD.U_MONTH,RSD.WATERTYPE) A,

 (
  select OFAGENT 营业所,
   pm.pmonth 月份,
   t.watertype 性质,
    sum(decode(substr(pm.pposition,1,2),'02',pm.ppayment,0)) 大厅票面,
    sum(decode(substr(pm.pposition,1,2),'03',pm.ppayment,0)) 银行票面,
    max(k.sf_rate) 水费分摊,
    max(k.psf_rate) 污水分摊
from
payment pm,MV_METER_PROP T,V_水费排污费分摊比例 K
where pmid=METERNO
       AND T.WATERTYPE=K.pfid
      and CHARGETYPE='X'
      group by OFAGENT,pm.pmonth,t.watertype)B

 WHERE A.营业所=B.营业所
 and a.月份=B.月份
 and a.性质=b.性质
 group by A.营业所,a.月份
 );

