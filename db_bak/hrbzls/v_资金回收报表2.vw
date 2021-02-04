create or replace force view hrbzls.v_资金回收报表2 as
(
 select ofagent,                                                --营业所
        账务月份,
        sum(坐收水费金额_不含基补) 坐收金额,                                 --坐收水费金额(不含基建、补缴 )
        sum(走收水费金额_不含基补+走收补缴水费+坐收补缴水费) 走收金额,       --走收水费金额(不含基建 含补缴 )

        sum(基补) 基补,
        sum(大厅票面) 大厅票面,
        round(sum((大厅票面 - 基补1 - 走收水费金额_不含基补 - 走收污水费金额_不含基补)*sf_rate),2) 地区售水大厅,  --地区大厅 坐收票面水费金额
        sum(银行票面) 银行票面,
        round(sum(银行票面*sf_rate),2) 银行,
        round(sum((大厅票面 - 基补1 - 走收水费金额_不含基补 - 走收污水费金额_不含基补)*psf_rate),2) 售水大厅污水, --地区大厅 坐收票面 污水费金额
        round(sum(银行票面*psf_rate),2) 银行污水,
        sum(坐收污水费金额_不含基补) 坐收污水费,                               --坐收污水费金额(不含基建 、补缴 )
        sum(走收补缴污水费+坐收补缴污水费+走收污水费金额_不含基补) 走收污水费  --走收污水费金额(不含基建 含补缴  )
 from
      (select t.ofagent,
             t.账务月份,
             t.watertype,    --用水类型
             sf_rate,        --水费比例
             psf_rate,       --污水费比例
             sum(decode(t.chargetype,'X',t.水费,0)) 坐收水费金额_不含基补,     --不含基建、补缴
             sum(decode(t.chargetype,'M',t.水费,0)) 走收水费金额_不含基补,     --不含基建、补缴
             sum(DECODE(chargetype,'M'  ,污水费 ,0)) 走收污水费金额_不含基补,  --不含基建、补缴
             sum(t.基建水费+t.补缴水费) 基补,
             sum(t.基建水费+t.补缴水费+t.补缴污水费) 基补1,
             sum(decode(t.缴费机构,'02',t.票面金额,0)) 大厅票面,
             sum(decode(t.缴费机构,'03',t.票面金额,0)) 银行票面,
             sum(t.补缴污水费) 补缴污水费,
             sum(decode(t.chargetype,'X',t.污水费 ,0)) 坐收污水费金额_不含基补,--不含基建、补缴
             sum(decode(t.chargetype,'X',t.基建水费,0)) 坐收基建水费,
             sum(decode(t.chargetype,'M',t.基建水费,0)) 走收基建水费,
             sum(decode(t.chargetype,'X',t.补缴水费,0)) 坐收补缴水费,
             sum(decode(t.chargetype,'M',t.补缴水费,0)) 走收补缴水费,
             sum(decode(t.chargetype,'M',t.补缴污水费,0)) 走收补缴污水费,
             sum(decode(t.chargetype,'X',t.补缴污水费,0)) 坐收补缴污水费
      from rpt_sum_cwzjbb t ,V_水费排污费分摊比例2 k
      where t.watertype=K.pfid
      group by t.ofagent,
             t.账务月份,
             t.watertype,
             sf_rate,
             psf_rate)
  group by ofagent,
        账务月份
 )
;

