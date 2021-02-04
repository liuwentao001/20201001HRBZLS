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
       SUM(DECODE(RDPIID, '01', RDSL, 0)) WATERUSE, --  ��ˮ��
       SUM(CASE
             WHEN RDPIID = '02' AND RDJE <> 0 THEN
              RDSL
             ELSE
              0
           END) WSSL, --��ˮˮ��
       SUM(RDJE) CHARGETOTAL, --  �ܽ��
       SUM(RDDJ) DJ, --�ۺϵ���
       SUM(DECODE(RDPIID, '01', RDJE, 0)) CHARGE1, --  ˮ��
       SUM(DECODE(RDPIID, '02', RDJE, 0)) CHARGE2, --  ���շ�1
       SUM(DECODE(RDPIID, '03', RDJE, 0)) CHARGE3, --  ���շ�2
       SUM(DECODE(RDPIID, '04', RDJE, 0)) CHARGE4, --  ���շ�3
       SUM(DECODE(RDPIID, '05', RDJE, 0)) CHARGE5, --  ���շ�4
       SUM(DECODE(RDPIID, '06', RDJE, 0)) CHARGE6, --  ���շ�5
       SUM(DECODE(RDPIID, '07', RDJE, 0)) CHARGE7, --  ���շ�6
       SUM(DECODE(RDPIID, '08', RDJE, 0)) CHARGE8, --  ���շ�7
       SUM(DECODE(RDPIID, '09', RDJE, 0)) CHARGE9, --  ���շ�8
       SUM(DECODE(RDPIID, '10', RDJE, 0)) CHARGE10, --  ���շ�9
       SUM(DECODE(RDPIID, '11', RDJE, 0)) CHARGE11, --  ���շ�10
       SUM(DECODE(RDPIID, '12', RDJE, 0)) CHARGE12, --  ���շ�11
       SUM(DECODE(RDPIID, '13', RDJE, 0)) CHARGE13, --  ���շ�12
       SUM(CASE
             WHEN RDPIID = '01' AND RDCLASS IN (0, 1) THEN
              RDDJ
             ELSE
              0
           END) USER_DJ1, --  ����1����
       SUM(DECODE(RDPIID, '01', DECODE(RDCLASS, 2, RDDJ, 0), 0)) USER_DJ2, --  ����2����
       SUM(DECODE(RDPIID, '01', DECODE(RDCLASS, 3, RDDJ, 0), 0)) USER_DJ3, --  ����3����
       SUM(CASE
             WHEN RDPIID = '01' AND RDCLASS IN (0, 1) THEN
              RDSL
             ELSE
              0
           END) USE_R1, --  ����1SL
       SUM(DECODE(RDPIID, '01', DECODE(RDCLASS, 2, RDSL, 0), 0)) USE_R2, --  ����2SL
       SUM(DECODE(RDPIID, '01', DECODE(RDCLASS, 3, RDSL, 0), 0)) USE_R3, --  ����3SL
       SUM(CASE
             WHEN RDPIID = '01' AND RDCLASS IN (0, 1) THEN
              RDJE
             ELSE
              0
           END) CHARGE_R1, --  ����1���
       SUM(DECODE(RDPIID, '01', DECODE(RDCLASS, 2, RDJE, 0), 0)) CHARGE_R2, --  ����2���
       SUM(DECODE(RDPIID, '01', DECODE(RDCLASS, 3, RDJE, 0), 0)) CHARGE_R3, --  ����3���
       SUM(DECODE(RDPIID, '01', 1, 0)) C_CHARGE, --  ����*/
       SUM(DECODE(RDPIID, '01', RDDJ, 0)) DJ1, --  ����1
       SUM(DECODE(RDPIID, '02', RDDJ, 0)) DJ2, --  ����2
       SUM(DECODE(RDPIID, '03', RDDJ, 0)) DJ3, --  ����3
       SUM(DECODE(RDPIID, '04', RDDJ, 0)) DJ4, --  ����4
       SUM(DECODE(RDPIID, '05', RDDJ, 0)) DJ5, --  ����5
       SUM(DECODE(RDPIID, '06', RDDJ, 0)) DJ6, --  ����6
       SUM(DECODE(RDPIID, '07', RDDJ, 0)) DJ7, --  ����7
       SUM(DECODE(RDPIID, '08', RDDJ, 0)) DJ8, --  ����8
       SUM(DECODE(RDPIID, '09', RDDJ, 0)) DJ9, --  ����9
       SUM(DECODE(RDPIID, '10', RDDJ, 0)) DJ10, --  ����9
       SUM(DECODE(RDPIID, '11', RDDJ, 0)) DJ11, --  ����9
       SUM(DECODE(RDPIID, '01', RDSL, 0)) RDSL1, --  ����1
       SUM(DECODE(RDPIID, '02', RDSL, 0)) RDSL2, --  ����2
       SUM(DECODE(RDPIID, '03', RDSL, 0)) RDSL3, --  ����3
       SUM(DECODE(RDPIID, '04', RDSL, 0)) RDSL4, --  ����4
       SUM(DECODE(RDPIID, '05', RDSL, 0)) RDSL5, --  ����5
       SUM(DECODE(RDPIID, '06', RDSL, 0)) RDSL6, --  ����6
       SUM(DECODE(RDPIID, '07', RDSL, 0)) RDSL7, --  ����7
       SUM(DECODE(RDPIID, '08', RDSL, 0)) RDSL8, --  ����8
       SUM(DECODE(RDPIID, '09', RDSL, 0)) RDSL9, --  ����9
       SUM(DECODE(RDPIID, '10', RDSL, 0)) RDSL10, --  ����9
       SUM(DECODE(RDPIID, '11', RDSL, 0)) RDSL11, --  ����9
       0 T
  FROM RECDETAIL C
 GROUP BY RDID, RDMID, RDPFID
;

