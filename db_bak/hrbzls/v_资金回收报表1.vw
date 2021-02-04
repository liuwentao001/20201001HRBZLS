create or replace force view hrbzls.v_资金回收报表1 as
(
 select ofagent,
        账务月份,
        sum(坐收金额) 坐收金额,
        sum(走收金额+基补) 走收金额,
        sum(基补) 基补,
        sum(大厅票面) 大厅票面,
        round(sum((大厅票面-基补1-走收金额-走收污水费)*sf_rate),2) 地区售水大厅,
        sum(银行票面) 银行票面,
        round(sum(银行票面*sf_rate),2) 银行,
        round(sum((大厅票面-基补1-走收金额-走收污水费)*psf_rate),2) 售水大厅污水,
        round(sum(银行票面*psf_rate),2) 银行污水,
        sum(坐收污水费) 坐收污水费,
        sum(补缴污水费+走收污水费) 走收污水费
 from
      (select t.ofagent,
             t.账务月份,
             t.watertype,
             sf_rate,
             psf_rate,
             sum(decode(t.chargetype,'X',t.水费,0)) 坐收金额,
             sum(case when t.chargetype='M'  then t.水费 else 0 end) 走收金额,
              sum(DECODE(chargetype,'M'  ,污水费 ,0)) 走收污水费,
             sum(t.基建水费+t.补缴水费) 基补,
             sum(t.基建水费+t.补缴水费+t.补缴污水费) 基补1,
             sum(decode(t.缴费机构,'02',t.票面金额,0)) 大厅票面,
             sum(decode(t.缴费机构,'03',t.票面金额,0)) 银行票面,
             sum(t.补缴污水费) 补缴污水费,
             sum(decode(t.chargetype,'X',t.污水费 ,0)) 坐收污水费

      from rpt_sum_cwzjbb t ,V_水费排污费分摊比例 k
      where /*t.账务月份='2014.06'
            and*/ t.watertype=K.pfid
      group by t.ofagent,
             t.账务月份,
             t.watertype,
             sf_rate,
             psf_rate)
  group by ofagent,
        账务月份
 );

