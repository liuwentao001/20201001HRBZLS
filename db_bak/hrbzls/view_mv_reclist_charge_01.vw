CREATE OR REPLACE FORCE VIEW HRBZLS.VIEW_MV_RECLIST_CHARGE_01 AS
SELECT COUNT(*) C,
       COUNT(RDSL) RDSL_C,
       COUNT(RDJE) RDJE_C,
       COUNT(RDDJ) RDDJ_C,
       SUM(RDDJ) RDDJ_S,
       RDID,
       RDPFID,
       RDMID METERNO,
       SUM(RDSL) WATERUSE_S,
       SUM(DECODE(RDPIID, '01', RDSL, 0)) WATERUSE, --  总水量
       SUM(CASE
             WHEN RDPIID = '02' AND RDJE <> 0 THEN
              RDSL
             ELSE
              0
           END) WSSL, --污水水量
       SUM(RDJE) CHARGETOTAL, --  总金额
       SUM(RDDJ) DJ, --综合单价
       SUM(DECODE(RDPIID, '01', RDJE, 0)) CHARGE1, --  水费
       SUM(DECODE(RDPIID, '02', RDJE, 0)) CHARGE2, --  代收费1
       SUM(DECODE(RDPIID, '03', RDJE, 0)) CHARGE3, --  代收费2
       SUM(DECODE(RDPIID, '04', RDJE, 0)) CHARGE4, --  代收费3
       SUM(DECODE(RDPIID, '05', RDJE, 0)) CHARGE5, --  代收费4
       SUM(DECODE(RDPIID, '06', RDJE, 0)) CHARGE6, --  代收费5
       SUM(DECODE(RDPIID, '07', RDJE, 0)) CHARGE7, --  代收费6
       SUM(DECODE(RDPIID, '08', RDJE, 0)) CHARGE8, --  代收费7
       SUM(DECODE(RDPIID, '09', RDJE, 0)) CHARGE9, --  代收费8
       SUM(DECODE(RDPIID, '10', RDJE, 0)) CHARGE10, --  代收费9
       SUM(DECODE(RDPIID, '11', RDJE, 0)) CHARGE11, --  代收费10
       SUM(DECODE(RDPIID, '12', RDJE, 0)) CHARGE12, --  代收费11
       SUM(DECODE(RDPIID, '13', RDJE, 0)) CHARGE13, --  代收费12
       SUM(CASE
             WHEN RDPIID = '01' AND RDCLASS IN (0, 1) THEN
              RDDJ
             ELSE
              0
           END) USER_DJ1, --  阶梯1单价
       SUM(DECODE(RDPIID, '01', DECODE(RDCLASS, 2, RDDJ, 0), 0)) USER_DJ2, --  阶梯2单价
       SUM(DECODE(RDPIID, '01', DECODE(RDCLASS, 3, RDDJ, 0), 0)) USER_DJ3, --  阶梯3单价
       SUM(CASE
             WHEN RDPIID = '01' AND RDCLASS IN (0, 1) THEN
              RDSL
             ELSE
              0
           END) USE_R1, --  阶梯1SL
       SUM(DECODE(RDPIID, '01', DECODE(RDCLASS, 2, RDSL, 0), 0)) USE_R2, --  阶梯2SL
       SUM(DECODE(RDPIID, '01', DECODE(RDCLASS, 3, RDSL, 0), 0)) USE_R3, --  阶梯3SL
       SUM(CASE
             WHEN RDPIID = '01' AND RDCLASS IN (0, 1) THEN
              RDJE
             ELSE
              0
           END) CHARGE_R1, --  阶梯1金额
       SUM(DECODE(RDPIID, '01', DECODE(RDCLASS, 2, RDJE, 0), 0)) CHARGE_R2, --  阶梯2金额
       SUM(DECODE(RDPIID, '01', DECODE(RDCLASS, 3, RDJE, 0), 0)) CHARGE_R3, --  阶梯3金额
       SUM(DECODE(RDPIID, '01', 1, 0)) C_CHARGE, --  笔数*/
       SUM(DECODE(RDPIID, '01', RDDJ, 0)) DJ1, --  单价1
       SUM(DECODE(RDPIID, '02', RDDJ, 0)) DJ2, --  单价2
       SUM(DECODE(RDPIID, '03', RDDJ, 0)) DJ3, --  单价3
       SUM(DECODE(RDPIID, '04', RDDJ, 0)) DJ4, --  单价4
       SUM(DECODE(RDPIID, '05', RDDJ, 0)) DJ5, --  单价5
       SUM(DECODE(RDPIID, '06', RDDJ, 0)) DJ6, --  单价6
       SUM(DECODE(RDPIID, '07', RDDJ, 0)) DJ7, --  单价7
       SUM(DECODE(RDPIID, '08', RDDJ, 0)) DJ8, --  单价8
       SUM(DECODE(RDPIID, '09', RDDJ, 0)) DJ9, --  单价9
       SUM(DECODE(RDPIID, '10', RDDJ, 0)) DJ10, --  单价9
       SUM(DECODE(RDPIID, '11', RDDJ, 0)) DJ11, --  单价9
       SUM(DECODE(RDPIID, '01', RDSL, 0)) RDSL1, --  单价1
       SUM(DECODE(RDPIID, '02', RDSL, 0)) RDSL2, --  单价2
       SUM(DECODE(RDPIID, '03', RDSL, 0)) RDSL3, --  单价3
       SUM(DECODE(RDPIID, '04', RDSL, 0)) RDSL4, --  单价4
       SUM(DECODE(RDPIID, '05', RDSL, 0)) RDSL5, --  单价5
       SUM(DECODE(RDPIID, '06', RDSL, 0)) RDSL6, --  单价6
       SUM(DECODE(RDPIID, '07', RDSL, 0)) RDSL7, --  单价7
       SUM(DECODE(RDPIID, '08', RDSL, 0)) RDSL8, --  单价8
       SUM(DECODE(RDPIID, '09', RDSL, 0)) RDSL9, --  单价9
       SUM(DECODE(RDPIID, '10', RDSL, 0)) RDSL10, --  单价9
       SUM(DECODE(RDPIID, '11', RDSL, 0)) RDSL11, --  单价9
       0 T
  FROM RECDETAIL C
 GROUP BY RDID, RDMID, RDPFID
;

