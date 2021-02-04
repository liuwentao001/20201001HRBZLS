CREATE OR REPLACE FORCE VIEW HRBZLS.VIEW_PRICE_PROP AS
select watertype,
       max(watertype_b)  watertype_b,
       max(watertype_m) watertype_m,
       max(p0) p0,
       sum(DECODE(ps.psclass,'1',ps.psprice,0))  p1 ,--阶梯1
       sum(DECODE(ps.psclass,'2',ps.psprice,0)) p2 ,--阶梯2
       sum(DECODE(ps.psclass,'3',ps.psprice,0)) p3 ,--阶梯3
       max(p4)    p4,
        max(p5)  p5,
        max(p6)  p6,
        max(p7)  p7,
        max(p8)  p8,
        max(p9)  p9,
        max(p10)   p10,
        max(p11)   p11,
        max(p12)   p12,
        max(p13)   p13,
        max(p14)   p14,
        max(p15)   p15,
        max(p16)   p16,
        '' s1,
        '' s2

  from
  (
      SELECT
                  pf.pfid Watertype ,  --用水类别
                  max(pf.pfpid)  Watertype_b,  --用水大类
                  max(pf.pfid)   Watertype_m,--用水中类
                  MAX(pf.pfprice)  p0  ,--综合单价
                  /*SUM(DECODE(ps.psclass,'1',ps.psprice,0)) p1 ,--阶梯1
                  SUM(DECODE(ps.psclass,'2',ps.psprice,0)) p2 ,--阶梯2
                  SUM(DECODE(ps.psclass,'3',ps.psprice,0)) p3 ,--阶梯3*/
                  SUM(DECODE(pdpiid,'01',pd.pddj,0)) p4, --代收费1
                  SUM(DECODE(pdpiid,'02',pd.pddj,0)) p5, --代收费2
                  SUM(DECODE(pdpiid,'03',pd.pddj,0)) p6, --代收费3
                  SUM(DECODE(pdpiid,'04',pd.pddj,0)) p7, --代收费4
                  SUM(DECODE(pdpiid,'05',pd.pddj,0)) p8, --代收费5
                  SUM(DECODE(pdpiid,'06',pd.pddj,0)) p9, --代收费6
                  SUM(DECODE(pdpiid,'07',pd.pddj,0)) p10, --代收费7
                  SUM(DECODE(pdpiid,'08',pd.pddj,0)) p11, --代收费8
                  SUM(DECODE(pdpiid,'09',pd.pddj,0)) p12, --代收费9
                  SUM(DECODE(pdpiid,'10',pd.pddj,0)) p13, --代收费10
                  SUM(DECODE(pdpiid,'11',pd.pddj,0)) p14, --代收费11
                  SUM(DECODE(pdpiid,'12',pd.pddj,0)) p15, --代收费12
                  SUM(DECODE(pdpiid,'13',pd.pddj,0)) p16, --代收费13
                  '' s1,
                  '' s2
        FROM PRICEFRAME PF, PRICEDETAIL PD --, PRICESTEP PS
       WHERE PF.PFID = PD.PDPFID
        --AND PF.PFID = PS.PSPFID(+)
       GROUP BY pfid
   ) a,
     pricestep ps
   where a.watertype = ps.pspfid(+) group by watertype order by watertype
;

