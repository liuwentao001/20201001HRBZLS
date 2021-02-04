CREATE OR REPLACE PROCEDURE HRBZLS.ww_cw(A_MONTH IN VARCHAR2) AS
BEGIN

  DELETE RPT_SUM_DETAIL T
   WHERE T.U_MONTH = A_MONTH
     and watertype in ('E0405',
                       'C07',
                       'B0201',
                       'D0102',
                       'C05',
                       'E050101',
                       'C03',
                       'B010402')
     and ofagent = '0204';
  COMMIT;
  --生成粒度 删除代号维度，增加最小维度 应收事务 以区分基建、补缴、计划抄表应收等
  INSERT INTO RPT_SUM_DETAIL
    (TPDATE,
     U_MONTH,
     OFAGENT, --AREA,
     CHAREGETYPE,
     WATERTYPE,
     T16,
     t17,
     m50)
    SELECT SYSDATE,
           A_MONTH, --账务月份
           OFAGENT, --营业所
           --AREA, --区域
           CHARGETYPE, --收费方式
           WATERTYPE, --用水类别
           VR.RTID, --应收事务
           MILB,
           0 m50
      FROM MV_METER_PROP, VIEW_RECTRANS_USED VR
     where watertype in ('E0405',
                         'C07',
                         'B0201',
                         'D0102',
                         'C05',
                         'E050101',
                         'C03',
                         'B010402')
       and ofagent = '0204'
     GROUP BY --AREA,
              CHARGETYPE,
              WATERTYPE,
              OFAGENT,
              VR.RTID,
              MILB,
              0;
  COMMIT;
  --========删除临时表信息=============
  DELETE RPT_SUM_TEMP;
  COMMIT;

  --=========应收=========--
  --应收
  DELETE RPT_SUM_TEMP;
  COMMIT;
  INSERT INTO RPT_SUM_TEMP
    (T1,
     -- T2,
     T3,
     T4,
     T5,
     T6, --应收事务
     t8,
     x41, --m50
     X1,
     X2,
     X3,
     X4,
     X5,
     X6,
     X7,
     X8,
     X9,
     X10,
     X11,
     X12,
     X13,
     X14,
     X15,
     X16,
     X17,
     X18,
     X19,
     X20,
     x21,
     x22,
     X40 --污水量
     )
    SELECT A_MONTH U_MONTH,
           --AREA,
           rlpfid, -- WATERTYPE,
           rlyschargetype, --CHARGETYPE,
           rlsmfid, -- M.OFAGENT,
           RL.RLTRANS, --应收事务
           rllb, --M.MILB,
           (case
             when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH and
                  rl.rlmonth = A_MONTH then
              1 --1代表冲往月
             when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH = RL.RLSCRRLMONTH and
                  rl.rlmonth = A_MONTH then
              2 --2代表冲本月 
             when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH = RL.RLSCRRLMONTH and
                  rl.rlmonth <> A_MONTH then
              1 --1代表冲往月 
             else
              0
           end) x41,
           
           SUM(WATERUSE) C1, --应收总水量
           SUM(USE_R1) C2, --阶梯1
           SUM(USE_R2) C3, --阶梯2
           SUM(USE_R3) C4, --阶梯3
           SUM(CHARGETOTAL) C5, --应收总金额
           SUM(CHARGE1) C6, --水费
           SUM(CHARGE2) C7, --污水费
           SUM(CHARGE3) C8, --附加费
           SUM(CHARGE4) C9, --代收费3
           SUM(CHARGE_R1) C10, --阶梯1
           SUM(CHARGE_R2) C11, --阶梯2
           SUM(CHARGE_R3) C12, --阶梯3
           SUM(1) C13, --笔数
           SUM(CHARGE5) C14, --代收费4
           SUM(CHARGE6) C15, --代收费5
           SUM(case
                 when MISTATUS in ('29', '30') then
                  0
                 else
                  1
               end) C16, --按表件数
           SUM(case
                 when MISTATUS in ('29', '30') then
                  0
                 else
                  charge1
               end) C17, --按表金额
           SUM(case
                 when MISTATUS in ('29', '30') then
                  1
                 else
                  0
               end) C18, --按人件数
           SUM(case
                 when MISTATUS in ('29', '30') then
                  charge1
                 else
                  0
               end) C19, --按人金额
           
           0 C20, --污水费0
           SUM(case
                 when MISTATUS in ('29', '30') then
                  0
                 else
                  WATERUSE
               end) C21, --按表水量
           SUM(case
                 when MISTATUS in ('29', '30') then
                  WATERUSE
                 else
                  0
               end) C22, --按人水量
           SUM(WSSL) W1 --应收_总污水量
      FROM RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M
     WHERE RL.RLID = RD.RDID
       AND RL.RLMONTH = A_MONTH
       AND RL.RLMID = M.METERNO
          --  and rlje<>0  --by 20150106 wangwei    
       and (rl.rlje <> 0 or rl.rlsl <> 0) -- add hb 20150803消防水鹤有水量没有金额需要计算
       and RL.RLPFID <> 'A07' --add hb 20150803将用水性质(A07居民生活用水/计量总表)水量排除掉  
       and RLPFID in ('E0405',
                      'C07',
                      'B0201',
                      'D0102',
                      'C05',
                      'E050101',
                      'C03',
                      'B010402')
       and rlmsmfid = '0204'
       and RL.rltrans <> '23' -- 营销部收入不计入账务明细报表 20140705 
       AND NVL(RLBADFLAG, 'N') = 'N' --吊坏账 N-正常账
     GROUP BY --M.AREA,
              rlpfid,
              rlyschargetype,
              rlsmfid,
              RL.RLTRANS,
              rllb,
              (case
                when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH and
                     rl.rlmonth = A_MONTH then
                 1 --1代表冲往月
                when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH = RL.RLSCRRLMONTH and
                     rl.rlmonth = A_MONTH then
                 2 --2代表冲本月 
                when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH = RL.RLSCRRLMONTH and
                     rl.rlmonth <> A_MONTH then
                 1 --1代表冲往月 
                else
                 0
              end);

  ---补充VIEW_METER_PROP不存在的维度----
  INSERT INTO RPT_SUM_DETAIL
    (TPDATE,
     U_MONTH,
     OFAGENT, --AREA,
     CHAREGETYPE,
     WATERTYPE,
     T16,
     T17,
     m50)
    SELECT SYSDATE,
           A_MONTH, --账务月份
           T5 OFAGENT, --营业所
           --T2      AREA, --区域
           T4  CHARGETYPE, --收费方式
           T3  WATERTYPE, --用水类别
           T6, --应收事务
           T8  miib,
           x41
      FROM RPT_SUM_TEMP
     WHERE T1 = A_MONTH
       AND (T1, --T2,
            T4, T5, T3, T6, T8, x41) NOT IN
           (SELECT U_MONTH, --AREA,
                   CHAREGETYPE,
                   OFAGENT,
                   WATERTYPE,
                   T16,
                   T17,
                   m50
              FROM RPT_SUM_DETAIL
             WHERE U_MONTH = A_MONTH);

  ---补充VIEW_METER_PROP不存在的维度----

  UPDATE RPT_SUM_DETAIL T
     SET (C1, --应收_总水量
          C2, -- 应收_阶梯1
          C3, -- 应收_阶梯2
          C4, --应收_阶梯3
          C5, -- 应收_总金额
          C6, --应收_污水费
          C7, --应收_附加费
          C8, ---应收_费用项目3
          C9, --应收_费用项目4
          C10, --   应收_阶梯1金额
          C11, --   应收_阶梯2金额
          C12, --  应收_阶梯3金额
          C13, -- 应收笔数
          C14, --预留
          C15, --预留
          C16, --预留
          C17,
          C18,
          C19,
          C20,
          c21,
          c22,
          W1 --应收_总污水量
          ) =
         (SELECT X1,
                 X2,
                 X3,
                 X4,
                 X5,
                 X6,
                 X7,
                 X8,
                 X9,
                 X10,
                 X11,
                 X12,
                 X13,
                 X14,
                 X15,
                 X16,
                 X17,
                 X18,
                 X19,
                 X20,
                 x21,
                 x22,
                 X40
            FROM RPT_SUM_TEMP TMP
           WHERE U_MONTH = T1
                --AND T.AREA = T2
             AND T.WATERTYPE = T3
             AND T.CHAREGETYPE = T4
             AND T.OFAGENT = T5
             AND T.T16 = T6
             and T.t17 = t8
             and t.m50 = x41)
   WHERE T.U_MONTH = A_MONTH;
  COMMIT;

  ------总销账
  DELETE RPT_SUM_TEMP;
  COMMIT;
  INSERT INTO RPT_SUM_TEMP
    (T1,
     -- T2,
     T3,
     T4,
     T5,
     T6, --应收事务
     t8,
     x41, --m50
     X1,
     X2,
     X3,
     X4,
     X5,
     X6,
     X7,
     X8,
     X9,
     X10,
     X11,
     X12,
     X13,
     X14,
     X15,
     X16,
     X17,
     X18,
     X19,
     X20,
     X21,
     x22,
     x23,
     x24,
     x25,
     x26,
     x27,
     
     x31,
     x32,
     x33,
     x34,
     x35,
     x36,
     
     X40 --污水量
     )
    SELECT A_MONTH U_MONTH,
           --  M.AREA,
           rlpfid, -- WATERTYPE,
           rlyschargetype, --CHARGETYPE,
           rlsmfid, -- M.OFAGENT,
           RL.RLTRANS, --应收事务
           rllb, --M.MILB,
           (case
             when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH and
                  rl.rlmonth = A_MONTH then
              1 --1代表冲往月
             when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH = RL.RLSCRRLMONTH and
                  rl.rlmonth = A_MONTH then
              2 --2代表冲本月 
             when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH = RL.RLSCRRLMONTH and
                  rl.rlmonth <> A_MONTH then
              1 --1代表冲往月 
             else
              0
           end) x41, -- 20140901添加维度M50  值1代表冲往月 0 代表正常
           SUM(WATERUSE) X32, --总销账_总水量
           SUM(USE_R1) X33, --总销账_阶梯1
           SUM(USE_R2) X34, --总销账_阶梯2
           SUM(USE_R3) X35, --总销账_阶梯3
           SUM(CHARGETOTAL) C36, --总销账_总金额
           SUM(CHARGE1) X37, --总销账_污水费
           SUM(CHARGE2) X38, --总销账_附加费
           SUM(CHARGE3) X39, --总销账_费用项目3
           SUM(CHARGE4) X40, --总销账_费用项目4
           SUM(CHARGE_R1) X41, --总销账_阶梯1 金额
           SUM(CHARGE_R2) X42, --总销账_阶梯2 金额
           SUM(CHARGE_R3) X43, --总销账_阶梯3 金额
           SUM(1) X44, --总销账_笔数
           SUM(CHARGE5) X45,
           SUM(CHARGE6) X46,
           SUM(CHARGE7) X47,
           /*SUM(RD.CHARGEZNJ)*/
           0 X50,
           SUM(CHARGE8) X60,
           SUM(CHARGE9) X61,
           SUM(CHARGE10) X62,
           0 X63,
           SUM(case
                 when MISTATUS in ('29', '30') then
                  0
                 else
                  (case
                    when charge1 <> 0 then
                     1
                    else
                     0
                  end)
               end) m11, --按表件数
           SUM(case
                 when MISTATUS in ('29', '30') then
                  0
                 else
                  charge1
               end) m12, --按表金额
           SUM(case
                 when MISTATUS in ('29', '30') then
                  (case
                    when charge1 <> 0 then
                     1
                    else
                     0
                  end)
                 else
                  0
               end) m13, --按人件数
           SUM(case
                 when MISTATUS in ('29', '30') then
                  charge1
                 else
                  0
               end) m14, --按人金额
           SUM(case
                 when MISTATUS in ('29', '30') then
                  0
                 else
                  WATERUSE
               end) m15, --按表水量
           SUM(case
                 when MISTATUS in ('29', '30') then
                  WATERUSE
                 else
                  0
               end) m16, --按人水量
           
           SUM(case
                 when MISTATUS in ('29', '30') then
                  0
                 else
                  (case
                    when charge2 <> 0 then
                     1
                    else
                     0
                  end)
               end) m21, --污水按表件数
           SUM(case
                 when MISTATUS in ('29', '30') then
                  0
                 else
                  charge2
               end) m22, --污水按表金额
           SUM(case
                 when MISTATUS in ('29', '30') then
                  (case
                    when charge2 <> 0 then
                     1
                    else
                     0
                  end)
                 else
                  0
               end) m23, --污水按人件数
           SUM(case
                 when MISTATUS in ('29', '30') then
                  charge2
                 else
                  0
               end) m24, --污水按人金额
           SUM(case
                 when MISTATUS in ('29', '30') then
                  0
                 else
                  (case
                    when charge2 <> 0 then
                     WSSL
                    else
                     0
                  end)
               end) m25, --按表污水量
           SUM(case
                 when MISTATUS in ('29', '30') then
                  (case
                    when charge2 <> 0 then
                     WSSL
                    else
                     0
                  end)
                 else
                  0
               end) m26, --按人污水量
           -----------------------------------------------------------------------------------------------------------------         
           SUM(WSSL) W4 --总销账_总污水量
      FROM RECLIST              RL, --LIQIZHU 20131010 增加PAYMENT表的关联
           MV_RECLIST_CHARGE_02 RD,
           MV_METER_PROP        M,
           PAYMENT              P
     WHERE RL.RLID = RD.RDID
       and RLPFID in ('E0405',
                      'C07',
                      'B0201',
                      'D0102',
                      'C05',
                      'E050101',
                      'C03',
                      'B010402')
       and rlmsmfid = '0204'
       AND RL.RLMID = M.METERNO
       AND RL.RLPID = P.PID
       AND P.PMONTH = A_MONTH
       and RL.rltrans <> '23' -- 营销部收入不计入账务明细报表 20140705 
    
     GROUP BY --M.AREA,
              rlpfid,
              rlyschargetype,
              rlsmfid,
              RL.RLTRANS,
              rllb,
              (case
                when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH and
                     rl.rlmonth = A_MONTH then
                 1 --1代表冲往月
                when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH = RL.RLSCRRLMONTH and
                     rl.rlmonth = A_MONTH then
                 2 --2代表冲本月 
                when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH = RL.RLSCRRLMONTH and
                     rl.rlmonth <> A_MONTH then
                 1 --1代表冲往月 
                else
                 0
              end);

  ----增加消防水鹤的  by  20151203 ralph
  INSERT INTO RPT_SUM_TEMP
    (T1,
     T2,
     T3,
     T4,
     T5,
     T6,
     t8,
     x41, -- 20140901添加维度M50  值1代表冲往月 0 代表正常
     X1,
     X2,
     X3,
     X4,
     X5,
     X6,
     X7,
     X8,
     X9,
     X10,
     X11,
     X12,
     X13,
     X14,
     X15,
     X16,
     X17,
     X18,
     X19,
     X20,
     X21,
     x22,
     x23,
     x24,
     x25,
     x26,
     x27,
     
     x31,
     x32,
     x33,
     x34,
     x35,
     x36,
     X40 --污水量
     )
    SELECT A_MONTH U_MONTH,
           substr(rlbfid, 1, 5), -- M.AREA,
           rlpfid, --m.WATERTYPE WATERTYPE,
           rlrper, -- M.CBY,
           rlyschargetype, --M.CHARGETYPE,
           rlsmfid, -- M.OFAGENT,
           rllb, --M.MILB,
           '2' x41, -- 20140901添加维度M50  值1代表冲往月 0 代表正常
           SUM(WATERUSE) X32, --总销账_总水量
           SUM(USE_R1) X33, --总销账_阶梯1
           SUM(USE_R2) X34, --总销账_阶梯2
           SUM(USE_R3) X35, --总销账_阶梯3
           SUM(CHARGETOTAL) C36, --总销账_总金额
           SUM(CHARGE1) X37, --总销账_污水费
           SUM(CHARGE2) X38, --总销账_附加费
           SUM(CHARGE3) X39, --总销账_费用项目3
           SUM(CHARGE4) X40, --总销账_费用项目4
           SUM(CHARGE_R1) X41, --总销账_阶梯1 金额
           SUM(CHARGE_R2) X42, --总销账_阶梯2 金额
           SUM(CHARGE_R3) X43, --总销账_阶梯3 金额
           SUM(1) X44, --总销账_笔数
           SUM(CHARGE5) X45, --总销账_代收费4
           SUM(CHARGE6) X46, --总销账_代收费5
           SUM(CHARGE7) X47, --总销账_代收费6
           /*SUM(RD.CHARGEZNJ)*/
           0 X50, --总销账滞纳金
           SUM(CHARGE8) X60,
           SUM(CHARGE9) X61,
           SUM(CHARGE10) X62,
           0 X63,
           SUM(case
                 when MISTATUS in ('29', '30') then
                  0
                 else
                  1
               end) m11, --按表件数
           SUM(case
                 when MISTATUS in ('29', '30') then
                  0
                 else
                  charge1
               end) m12, --按表金额
           SUM(case
                 when MISTATUS in ('29', '30') then
                  1
                 else
                  0
               end) m13, --按人件数
           SUM(case
                 when MISTATUS in ('29', '30') then
                  charge1
                 else
                  0
               end) m14, --按人金额
           SUM(case
                 when MISTATUS in ('29', '30') then
                  0
                 else
                  WATERUSE
               end) m15, --按表水量
           SUM(case
                 when MISTATUS in ('29', '30') then
                  WATERUSE
                 else
                  0
               end) m16, --按人水量
           
           0 m21, --污水按表件数
           0 m22, --污水按表金额
           0 m23, --污水按人件数
           0 m24, --污水按人金额
           0 m25, --按表污水量
           0 m26, --按人污水量
           
           0 W4 --总销账_总污水量
      FROM RECLIST RL, MV_RECLIST_CHARGE_02 RD, METERINFO
     WHERE RL.RLID = RD.RDID
       AND RLMID = MIID
          
       AND rlpfid = 'B040101'
       AND RL.RLMONTH = A_MONTH --实收账月份
       and rltrans not in ('u', 'v', '13', '14', '21', '23')
    
     GROUP BY substr(rlbfid, 1, 5),
              rlyschargetype,
              rlpfid,
              rlrper,
              rlsmfid,
              rllb;

  ---补充VIEW_METER_PROP不存在的维度----
  INSERT INTO RPT_SUM_DETAIL
    (TPDATE,
     U_MONTH,
     OFAGENT, -- AREA,
     CHAREGETYPE,
     WATERTYPE,
     T16,
     T17,
     m50)
    SELECT SYSDATE,
           A_MONTH, --账务月份
           T5 OFAGENT, --营业所
           -- T2      AREA, --区域
           T4  CHARGETYPE, --收费方式
           T3  WATERTYPE, --用水类别
           T6, --应收事务
           T8  miib,
           x41
      FROM RPT_SUM_TEMP
     WHERE T1 = A_MONTH
       AND (T1, --T2,
            T4, T5, T3, T6, T8, x41) NOT IN
           (SELECT U_MONTH, --AREA,
                   CHAREGETYPE,
                   OFAGENT,
                   WATERTYPE,
                   T16,
                   T17,
                   m50
              FROM RPT_SUM_DETAIL
             WHERE U_MONTH = A_MONTH);

  ---补充VIEW_METER_PROP不存在的维度----
  -------------------------------------------------------------------------------------------------
  --2014/06/01
  --执行到此处时，RPT_SUM_DETAIL表中的水量和污水量都还是平的！
  --- 以下为问题语句
  --------------------------------------------------------------------------------------------------
  UPDATE RPT_SUM_DETAIL T
     SET (X32, --总销账_总水量
          X33, -- 总销账_阶梯1
          X34, -- 总销账_阶梯2
          X35, --总销账_阶梯3
          X36, -- 总销账_总金额
          X37, --总销账_污水费
          X38, --总销账_附加费
          X39, ---总销账_费用项目3
          X40, --总销账_费用项目4
          X41, -- 总销账_阶梯1金额
          X42, -- 总销账_阶梯2金额
          X43, -- 总销账_阶梯3金额
          X44, -- 总销账笔数
          X45, --预留
          X46,
          X47,
          X50,
          X60,
          X61,
          X62,
          X63,
          m11,
          m12,
          m13,
          m14,
          m15,
          m16,
          
          m21,
          m22,
          m23,
          m24,
          m25,
          m26,
          
          W4 --总销账_总污水量
          ) =
         (SELECT X1,
                 X2,
                 X3,
                 X4,
                 X5,
                 X6,
                 X7,
                 X8,
                 X9,
                 X10,
                 X11,
                 X12,
                 X13,
                 X14,
                 X15,
                 X16,
                 X17,
                 X18,
                 X19,
                 X20,
                 X21,
                 
                 x22,
                 x23,
                 x24,
                 x25,
                 x26,
                 x27,
                 
                 x31,
                 x32,
                 x33,
                 x34,
                 x35,
                 x36,
                 
                 X40
            FROM RPT_SUM_TEMP TMP
           WHERE U_MONTH = T1
                --AND T.AREA = T2
             AND T.WATERTYPE = T3
             AND T.CHAREGETYPE = T4
             AND T.OFAGENT = T5
             AND T.T16 = T6
             and T.t17 = t8
             and t.m50 = x41)
   WHERE T.U_MONTH = A_MONTH;
  COMMIT;

  ------------------------------------------------------------------------------------------------------------
  ----2014/06/01
  --上面这个更新的语句执行完后，水量和污水量就不平了。应该是这句话有漏洞，直觉也是！请韦总检查此语句！
  --------------------------------------------------------------------------------------------------------------
  -------------销以往-----------------
  DELETE RPT_SUM_TEMP;
  COMMIT;
  INSERT INTO RPT_SUM_TEMP
    (T1,
     --   T2,
     T3,
     T4,
     T5,
     T6, --应收事务
     t8,
     x41, --m50
     X1,
     X2,
     X3,
     X4,
     X5,
     X6,
     X7,
     X8,
     X9,
     X10,
     X11,
     X12,
     X13,
     X14,
     X15,
     X16,
     X17,
     X18,
     X19,
     X20,
     X40 --污水量
     )
    SELECT A_MONTH U_MONTH,
           --    AREA,
           rlpfid, -- WATERTYPE,
           rlyschargetype, --CHARGETYPE,
           rlsmfid, -- M.OFAGENT,
           RL.RLTRANS, --应收事务
           rllb, --M.MILB,
           (case
             when pp.PREVERSEFLAG = 'Y' AND pp.PMONTH > pp.PSCRMONTH and
                  pp.pmonth = A_MONTH then
              1 --1代表冲往月
             when pp.PREVERSEFLAG = 'Y' AND pp.PMONTH = pp.PSCRMONTH and
                  pp.pmonth = A_MONTH then
              2 --2代表冲本月 
             when pp.PREVERSEFLAG = 'Y' AND pp.PMONTH = pp.PSCRMONTH and
                  pp.pmonth <> A_MONTH then
              1 --2代表冲本月 
             else
              0
           end) x41, -- 20140901添加维度M50  值1代表冲往月 0 代表正常
           SUM(WATERUSE) X1,
           SUM(USE_R1) X2,
           SUM(USE_R2) X3,
           SUM(USE_R3) X4,
           SUM(CHARGETOTAL) X5,
           SUM(CHARGE1) X6,
           SUM(CHARGE2) X7,
           SUM(CHARGE3) X8,
           SUM(CHARGE4) X9,
           SUM(CHARGE_R1) X10,
           SUM(CHARGE_R2) X11,
           SUM(CHARGE_R3) X12,
           SUM(1) X13,
           SUM(CHARGE5) X14,
           /*SUM(RD.CHARGEZNJ)*/
           0 X48,
           SUM(CHARGE6) X51,
           SUM(CHARGE7) X52,
           SUM(CHARGE8) X53,
           SUM(CHARGE9) X54,
           SUM(CHARGE10) X55,
           SUM(WSSL) W2 --销以往_总污水量
      FROM RECLIST              RL,
           MV_RECLIST_CHARGE_02 RD,
           MV_METER_PROP        M， PAYMENT pp
     WHERE RL.RLID = RD.RDID
       and rl.rlpid = pp.pid
       AND RL.RLMID = M.METERNO
       AND RL.RLPAIDFLAG = 'Y'
       and RLPFID in ('E0405',
                      'C07',
                      'B0201',
                      'D0102',
                      'C05',
                      'E050101',
                      'C03',
                      'B010402')
       and rlmsmfid = '0204'
          --AND RL.RLPAIDMONTH = A_MONTH
       AND PP.PMONTH = A_MONTH
       AND NVL(RL.RLBADFLAG, 'N') = 'N'
       and RL.rltrans <> '23' -- 营销部收入不计入账务明细报表 20140705 
       AND RL.RLSCRRLMONTH < A_MONTH --以往
     GROUP BY --M.AREA,
              rlpfid,
              rlyschargetype,
              rlsmfid,
              RL.RLTRANS,
              rllb,
              (case
                when pp.PREVERSEFLAG = 'Y' AND pp.PMONTH > pp.PSCRMONTH and
                     pp.pmonth = A_MONTH then
                 1 --1代表冲往月
                when pp.PREVERSEFLAG = 'Y' AND pp.PMONTH = pp.PSCRMONTH and
                     pp.pmonth = A_MONTH then
                 2 --2代表冲本月 
                when pp.PREVERSEFLAG = 'Y' AND pp.PMONTH = pp.PSCRMONTH and
                     pp.pmonth <> A_MONTH then
                 1 --2代表冲本月 
                else
                 0
              end);

  UPDATE RPT_SUM_DETAIL T
     SET (X1, --销以往_总水量
          X2, -- 销以往_阶梯1
          X3, -- 销以往_阶梯2
          X4, --销以往_阶梯3
          X5, -- 销以往_总金额
          X6, --销以往_污水费
          X7, --销以往_附加费
          X8, ---销以往_费用项目3
          X9, --销以往_费用项目4
          X10, --   销以往_阶梯1金额
          X11, --   销以往_阶梯2金额
          X12, --  销以往_阶梯3金额
          X13, -- 销以往笔数
          X14, --预留
          X15,
          X48,
          X51,
          X52,
          X53,
          X54,
          X55,
          W2 --销以往_总污水量
          ) =
         (SELECT X1,
                 X2,
                 X3,
                 X4,
                 X5,
                 X6,
                 X7,
                 X8,
                 X9,
                 X10,
                 X11,
                 X12,
                 X13,
                 X14,
                 X15,
                 X16,
                 X17,
                 X18,
                 X19,
                 X20,
                 X21,
                 X40
            FROM RPT_SUM_TEMP TMP
           WHERE U_MONTH = T1
                -- AND T.AREA = T2
             AND T.WATERTYPE = T3
             AND T.CHAREGETYPE = T4
             AND T.OFAGENT = T5
             AND T.T16 = T6
             and T.t17 = t8
             and t.m50 = x41)
   WHERE T.U_MONTH = A_MONTH;
  COMMIT;

  --销当月
  DELETE RPT_SUM_TEMP;
  COMMIT;
  INSERT INTO RPT_SUM_TEMP
    (T1,
     --  T2,
     T3,
     T4,
     T5,
     T6, --应收事务
     t8,
     x41, --m50
     X1,
     X2,
     X3,
     X4,
     X5,
     X6,
     X7,
     X8,
     X9,
     X10,
     X11,
     X12,
     X13,
     X14,
     X15,
     X16,
     X17,
     X18,
     X19,
     X20,
     X40 --污水量
     )
    SELECT A_MONTH U_MONTH,
           --  AREA,
           rlpfid, -- WATERTYPE,
           rlyschargetype, --CHARGETYPE,
           rlsmfid, -- M.OFAGENT,
           RL.RLTRANS, --应收事务
           rllb, --M.MILB,
           (case
             when pp.PREVERSEFLAG = 'Y' AND pp.PMONTH > pp.PSCRMONTH and
                  pp.pmonth = A_MONTH then
              1 --1代表冲往月
             when pp.PREVERSEFLAG = 'Y' AND pp.PMONTH = pp.PSCRMONTH and
                  pp.pmonth = A_MONTH then
              2 --2代表冲本月 
             when pp.PREVERSEFLAG = 'Y' AND pp.PMONTH = pp.PSCRMONTH and
                  pp.pmonth <> A_MONTH then
              1 --2代表冲本月 
             else
              0
           end) x41, -- 20140901添加维度M50  值1代表冲往月 0 代表正常
           SUM(WATERUSE) X16,
           SUM(USE_R1) X17,
           SUM(USE_R2) X18,
           SUM(USE_R3) X19,
           SUM(CHARGETOTAL) X20,
           SUM(CHARGE1) X21,
           SUM(CHARGE2) X22,
           SUM(CHARGE3) X23,
           SUM(CHARGE4) X24,
           SUM(CHARGE_R1) X25,
           SUM(CHARGE_R2) X26,
           SUM(CHARGE_R3) X27,
           SUM(1) X28,
           SUM(CHARGE5) X29,
           SUM(CHARGE6) X30,
           /*SUM(RD.CHARGEZNJ)*/
           0 X49,
           SUM(CHARGE7) X56,
           SUM(CHARGE8) X57,
           SUM(CHARGE9) X58,
           SUM(CHARGE10) X59,
           SUM(WSSL) W3 --销当月_总污水量
      FROM RECLIST              RL,
           MV_RECLIST_CHARGE_02 RD,
           MV_METER_PROP        M，
           --(select pid from rpt_sum_pid where u_month = a_month) pp
                   PAYMENT PP
     WHERE RL.RLID = RD.RDID
       and rl.rlpid = pp.pid
       AND RL.RLMONTH = A_MONTH
       and RLPFID in ('E0405',
                      'C07',
                      'B0201',
                      'D0102',
                      'C05',
                      'E050101',
                      'C03',
                      'B010402')
       and rlmsmfid = '0204'
          --AND RL.RLPAIDFLAG = 'Y'
       AND RL.RLMID = M.METERNO
          --AND RL.RLPAIDMONTH = A_MONTH
       AND PP.PMONTH = A_MONTH
       and RL.rltrans <> '23' -- 营销部收入不计入账务明细报表 20140705 
       AND NVL(RL.RLBADFLAG, 'N') = 'N'
     GROUP BY --M.AREA,
              rlpfid,
              rlyschargetype,
              rlsmfid,
              RL.RLTRANS,
              rllb,
              (case
                when pp.PREVERSEFLAG = 'Y' AND pp.PMONTH > pp.PSCRMONTH and
                     pp.pmonth = A_MONTH then
                 1 --1代表冲往月
                when pp.PREVERSEFLAG = 'Y' AND pp.PMONTH = pp.PSCRMONTH and
                     pp.pmonth = A_MONTH then
                 2 --2代表冲本月 
                when pp.PREVERSEFLAG = 'Y' AND pp.PMONTH = pp.PSCRMONTH and
                     pp.pmonth <> A_MONTH then
                 1 --2代表冲本月 
                else
                 0
              end);

  UPDATE RPT_SUM_DETAIL T
     SET (X16, --销当月_总水量
          X17, -- 销当月_阶梯1
          X18, -- 销当月_阶梯2
          X19, --销当月_阶梯3
          X20, -- 销当月_总金额
          X21, --销当月_污水费
          X22, --销当月_附加费
          X23, ---销当月_费用项目3
          X24, --销当月_费用项目4
          X25, --   销当月_阶梯1金额
          X26, --   销当月_阶梯2金额
          X27, --  销当月_阶梯3金额
          X28, -- 销当月笔数
          X29, --预留
          X30, --预留
          X31, --预留
          X49, --滞纳金
          X56,
          X57,
          X58,
          X59,
          W3 --销当月_总污水量
          ) =
         (SELECT X1,
                 X2,
                 X3,
                 X4,
                 X5,
                 X6,
                 X7,
                 X8,
                 X9,
                 X10,
                 X11,
                 X12,
                 X13,
                 X14,
                 X15,
                 X16,
                 X17,
                 X18,
                 X19,
                 X20,
                 X21,
                 X40
            FROM RPT_SUM_TEMP TMP
           WHERE U_MONTH = T1
                -- AND T.AREA = T2
             AND T.WATERTYPE = T3
             AND T.CHAREGETYPE = T4
             AND T.OFAGENT = T5
             AND T.T16 = T6
             and T.t17 = t8
             and t.m50 = x41)
   WHERE T.U_MONTH = A_MONTH;
  COMMIT;

  DELETE RPT_SUM_TEMP;
  COMMIT;
  INSERT INTO RPT_SUM_TEMP
    (T1,
     --    T2,
     T3,
     T4,
     T5,
     T6, --应收事务
     t8,
     x41, --m50
     X1,
     X2,
     X3,
     X4,
     X5,
     X6,
     X7,
     X8,
     X9,
     X10,
     X11,
     X12,
     X13,
     X14,
     X15,
     X16,
     X17,
     X18,
     X19,
     X20,
     X40 --污水量
     )
    SELECT A_MONTH U_MONTH,
           --    AREA,
           rlpfid, -- WATERTYPE,
           rlyschargetype, --CHARGETYPE,
           rlsmfid, -- M.OFAGENT,
           RL.RLTRANS, --应收事务
           rllb, --M.MILB,
           (case
             when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH and
                  rl.rlmonth = A_MONTH then
              1 --1代表冲往月
             when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH = RL.RLSCRRLMONTH and
                  rl.rlmonth = A_MONTH then
              2 --2代表冲本月 
             when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH = RL.RLSCRRLMONTH and
                  rl.rlmonth <> A_MONTH then
              1 --1代表冲往月 
             else
              0
           end) x41, -- 20140901添加维度M50  值1代表冲往月 0 代表正常
           SUM(WATERUSE) Q1, --欠费_总水量
           SUM(USE_R1) Q2, --欠费_阶梯1
           SUM(USE_R2) Q3, --欠费_阶梯2
           SUM(USE_R3) Q4, --欠费_阶梯3
           SUM(CHARGETOTAL) Q5, --欠费_总金额
           SUM(CHARGE1) Q6, --欠费_污水费
           SUM(CHARGE2) Q7, --欠费_附加费
           SUM(CHARGE3) Q8, --欠费_费用项目3
           SUM(CHARGE4) Q9, --欠费_费用项目4
           SUM(CHARGE_R1) Q10, --欠费_阶梯2 金额
           SUM(CHARGE_R2) Q11, --欠费_阶梯2 金额
           SUM(CHARGE_R3) Q12, --欠费_阶梯3 金额
           SUM(1) Q13, --欠费_笔数
           -- (case when SUM(CHARGE1) +  SUM(CHARGE2) + SUM(CHARGE3) > 0 then SUM(1) else 0 end  )  Q13, --欠当月_笔数   --欠费笔数过滤零水量费用、污水、附加费笔数
           SUM(CHARGE5) Q14,
           SUM(CHARGE6) Q15,
           SUM(CHARGE7) Q16,
           SUM(CHARGE8) Q33,
           SUM(CHARGE9) Q34,
           SUM(CHARGE10) Q35,
           0 Q36,
           SUM(WSSL) W5 --欠当月_总污水量
      FROM RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M
     WHERE RL.RLID = RD.RDID
       AND RL.RLMID = M.METERNO
       AND RL.RLPAIDFLAG = 'N' --未销账
       AND RL.RLREVERSEFLAG = 'N' --未冲正
       and RLPFID in ('E0405',
                      'C07',
                      'B0201',
                      'D0102',
                      'C05',
                      'E050101',
                      'C03',
                      'B010402')
       and rlmsmfid = '0204'
       and RL.rltrans <> '23' -- 营销部收入不计入账务明细报表 20140705 
       and (rl.rlje <> 0 or rl.rlsl <> 0) -- add hb 20150803消防水鹤有水量没有金额需要计算
       and RL.RLPFID <> 'A07' --add hb 20150803将用水性质(A07居民生活用水/计量总表)水量排除掉   
       AND RLMONTH = A_MONTH
       AND NVL(RL.RLBADFLAG, 'N') = 'N' --正常账
     GROUP BY --M.AREA,
              rlpfid,
              rlyschargetype,
              rlsmfid,
              RL.RLTRANS,
              rllb,
              (case
                when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH and
                     rl.rlmonth = A_MONTH then
                 1 --1代表冲往月
                when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH = RL.RLSCRRLMONTH and
                     rl.rlmonth = A_MONTH then
                 2 --2代表冲本月 
                when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH = RL.RLSCRRLMONTH and
                     rl.rlmonth <> A_MONTH then
                 1 --1代表冲往月 
                else
                 0
              end);

  ---补充VIEW_METER_PROP不存在的维度----
  INSERT INTO RPT_SUM_DETAIL
    (TPDATE,
     U_MONTH,
     OFAGENT, --AREA,
     CHAREGETYPE,
     WATERTYPE,
     T16,
     T17,
     m50)
    SELECT SYSDATE,
           A_MONTH, --账务月份
           T5 OFAGENT, --营业所
           --   T2      AREA, --区域
           T4  CHARGETYPE, --收费方式
           T3  WATERTYPE, --用水类别
           T6, --应收事务
           T8  miib,
           x41
      FROM RPT_SUM_TEMP
     WHERE T1 = A_MONTH
       AND (T1, --T2,
            T4, T5, T3, T6, T8, x41) NOT IN
           (SELECT U_MONTH, --AREA,
                   CHAREGETYPE,
                   OFAGENT,
                   WATERTYPE,
                   T16,
                   T17,
                   m50
              FROM RPT_SUM_DETAIL
             WHERE U_MONTH = A_MONTH);

  ---补充VIEW_METER_PROP不存在的维度----

  UPDATE RPT_SUM_DETAIL T
     SET (Q1, --欠费_总水量
          Q2, -- 欠费_阶梯1
          Q3, -- 欠费_阶梯2
          Q4, --欠费_阶梯3
          Q5, -- 欠费_总金额
          Q6, --欠费_污水费
          Q7, --欠费_附加费
          Q8, ---欠费_费用项目3
          Q9, --欠费_费用项目4
          Q10, --   欠费_阶梯1金额
          Q11, --   欠费_阶梯2金额
          Q12, --  欠费_阶梯3金额
          Q13, -- 欠费笔数
          Q14, --预留
          Q15,
          Q16,
          Q33,
          Q34,
          Q35,
          Q36,
          W5 --欠当月_总污水量
          ) =
         (SELECT X1,
                 X2,
                 X3,
                 X4,
                 X5,
                 X6,
                 X7,
                 X8,
                 X9,
                 X10,
                 X11,
                 X12,
                 X13,
                 X14,
                 X15,
                 X16,
                 X17,
                 X18,
                 X19,
                 X20,
                 X40
            FROM RPT_SUM_TEMP TMP
           WHERE U_MONTH = T1
                --  AND T.AREA = T2
             AND T.WATERTYPE = T3
             AND T.CHAREGETYPE = T4
             AND T.OFAGENT = T5
             AND T.T16 = T6
             and T.t17 = t8
             and t.m50 = x41)
   WHERE T.U_MONTH = A_MONTH;
  COMMIT;

  --单价
  UPDATE RPT_SUM_DETAIL T1
     SET (T1.WATERTYPE_B, --用水大类
          T1.WATERTYPE_M, --用水中类
          t19, --s1 哈尔滨分类
          t20, --s2 哈尔滨分类            
          P0, --综合单价
          P1, --阶梯1
          P2, --阶梯2
          P3, --阶梯3
          P4, --污水费
          P5, --附加费
          P6, --代收费3
          P7, --代收费4
          P8, --代收费5
          P9, --代收费6
          P10, --代收费7
          P11, --代收费8
          P12, --代收费9
          P13, --污水费0
          P14, --污水费1
          P15, --污水费2
          P16 --污水费3
          
          ) =
         (SELECT substr(T2.WATERTYPE, 1, 1), --用水大类
                 substr(T2.WATERTYPE, 1, 3), --用水中类
                 (select s1
                    from price_prop_sample
                   where WATERTYPE = t2.WATERTYPE) s1,
                 (select s2
                    from price_prop_sample
                   where WATERTYPE = t2.WATERTYPE) s2,
                 T2.P0, --综合单价
                 T2.P1, --阶梯1
                 T2.P2, --阶梯2
                 T2.P3, --阶梯3
                 T2.P4, --污水费
                 T2.P5, --附加费
                 T2.P6, --代收费3
                 T2.P7, --代收费4
                 T2.P8, --代收费5
                 T2.P9, --代收费6
                 T2.P10, --代收费7
                 T2.P11, --代收费8
                 T2.P12, --代收费9
                 T2.P13, --污水费0
                 T2.P14, --污水费1
                 T2.P15, --污水费2
                 T2.P16
            FROM PRICE_PROP T2
           WHERE T2.WATERTYPE = T1.WATERTYPE)
   WHERE U_MONTH = A_MONTH;
  COMMIT;

  /**期初欠费*/

  ---------------------------------------------------------------------------

  --modify 贺帮 20140701 因哈尔滨减免水量栏位RDadjsl全为0 故上述抓取需调整，start
  DELETE RPT_SUM_TEMP;
  COMMIT;
  INSERT INTO RPT_SUM_TEMP
    (T1,
     -- T2,
     T3,
     T4,
     T5,
     T6, --应收事务
     t8,
     x41, --m50
     X1,
     X2,
     X3,
     X4,
     X5,
     X6,
     X7,
     X8,
     x9,
     x10,
     x17,
     x18,
     x19,
     x20)
    SELECT A_MONTH U_MONTH,
           --AREA,
           rlpfid, -- WATERTYPE,
           rlyschargetype, --CHARGETYPE,
           rlsmfid, -- M.OFAGENT,
           RL.RLTRANS, --应收事务
           rllb, --M.MILB,
           (case
             when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH and
                  rl.rlmonth = A_MONTH then
              1 --1代表冲往月
             when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH = RL.RLSCRRLMONTH and
                  rl.rlmonth = A_MONTH then
              2 --2代表冲本月 
             when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH = RL.RLSCRRLMONTH and
                  rl.rlmonth <> A_MONTH then
              1 --1代表冲往月 
             else
              0
           end) x41, -- 20140901添加维度M50  值1代表冲往月 0 代表正常
           SUM(CASE
                 WHEN RDPIID = '01' THEN
                  (case
                    when abs(RLADDSL) > 0 then
                     1
                    else
                     0
                  end)
                 ELSE
                  0
               END) dis_c, --  收免件数
           SUM(CASE
                 WHEN RDPIID = '01' THEN
                  abs(RLADDSL)
                 ELSE
                  0
               END) dis_u1, --  收免水量 =抄表水量-应收水量
           SUM(CASE
                 WHEN RDPIID = '01' THEN
                  round(abs(RLADDSL * rddj), 2)
                 ELSE
                  0
               END) dis_m1, --  收免水费
           SUM(CASE
                 WHEN RDPIID = '02' THEN
                  abs(RLADDSL)
                 ELSE
                  0
               END) dis_u2, --  收免污水量=抄表水量-应收水量
           SUM(CASE
                 WHEN RDPIID = '02' THEN
                  round(abs(RLADDSL * rddj), 2)
                 ELSE
                  0
               END) dis_m2, --  收免污水费
           sum(round(abs(RLADDSL * rddj), 2)) dis_m, --  收免金额
           SUM(CASE
                 WHEN RDPIID = '01' THEN
                  (case
                    when M.MISTATUS in ('29', '30') then
                     0
                    else
                     abs(RLADDSL)
                  end)
                 ELSE
                  0
               END) X7, --按表水量
           SUM(CASE
                 WHEN RDPIID = '01' THEN
                  (case
                    when M.MISTATUS in ('29', '30') then
                     abs(RLADDSL)
                    else
                     0
                  end)
                 ELSE
                  0
               END) X8, --按人水量
           SUM(CASE
                 WHEN RDPIID = '01' THEN
                  (case
                    when M.MISTATUS in ('29', '30') then
                     0
                    else
                     (case
                       when abs(RLADDSL) > 0 then
                        1
                       else
                        0
                     end)
                  end)
                 ELSE
                  0
               END) X9, --按表件数
           SUM(CASE
                 WHEN RDPIID = '01' THEN
                  (case
                    when M.MISTATUS in ('29', '30') then
                     (case
                       when abs(RLADDSL) > 0 then
                        1
                       else
                        0
                     end)
                    else
                     0
                  end)
                 ELSE
                  0
               END) X10, --按人件数 
           SUM(CASE
                 WHEN RDPIID = '02' THEN
                  (case
                    when M.MISTATUS in ('29', '30') then
                     0
                    else
                     abs(RLADDSL)
                  end)
                 ELSE
                  0
               END) X17, --按表污水量
           SUM(CASE
                 WHEN RDPIID = '02' THEN
                  (case
                    when M.MISTATUS in ('29', '30') then
                     abs(RLADDSL)
                    else
                     0
                  end)
                 ELSE
                  0
               END) X18, --按人污水量
           SUM(CASE
                 WHEN RDPIID = '02' THEN
                  (case
                    when M.MISTATUS in ('29', '30') then
                     0
                    else
                     (case
                       when abs(RLADDSL) > 0 then
                        1
                       else
                        0
                     end)
                  end)
                 ELSE
                  0
               END) X19, --按表污水量件数
           SUM(CASE
                 WHEN RDPIID = '02' THEN
                  (case
                    when M.MISTATUS in ('29', '30') then
                     (case
                       when abs(RLADDSL) > 0 then
                        1
                       else
                        0
                     end)
                    else
                     0
                  end)
                 ELSE
                  0
               END) X20 --按人污水量件数 
    
      FROM RECLIST RL, METERINFO M, recdetail rd
     WHERE RL.RLID = RD.RDID
       AND RL.RLMONTH = A_MONTH
       AND RL.RLMID = M.miid
       and RL.rltrans <> '23' -- 营销部收入不计入账务明细报表 20140705 
       and M.MIYL2 = '1'
       and (rl.rlje <> 0 or rl.rlsl <> 0) -- add hb 20150803消防水鹤有水量没有金额需要计算
       and RL.RLPFID <> 'A07' --add hb 20150803将用水性质(A07居民生活用水/计量总表)水量排除掉    
       and RL.RLADDSL <> 0
       AND NVL(RLBADFLAG, 'N') = 'N'
       and RLPFID in ('E0405',
                      'C07',
                      'B0201',
                      'D0102',
                      'C05',
                      'E050101',
                      'C03',
                      'B010402')
       and rlmsmfid = '0204'
     GROUP BY rlpfid,
              rlyschargetype,
              rlsmfid,
              RL.RLTRANS,
              rllb,
              (case
                when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH and
                     rl.rlmonth = A_MONTH then
                 1 --1代表冲往月
                when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH = RL.RLSCRRLMONTH and
                     rl.rlmonth = A_MONTH then
                 2 --2代表冲本月 
                when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH = RL.RLSCRRLMONTH and
                     rl.rlmonth <> A_MONTH then
                 1 --1代表冲往月 
                else
                 0
              end);
  --modify 贺帮 20140701 因哈尔滨减免水量栏位RDadjsl全为0 故上述抓取需调整，end 

  --修改 20140628   以上为之前语法
  UPDATE RPT_SUM_DETAIL T
     SET (T20, --大项目改为'补当'
          T19, -- 科目改为'收免'
          M1, --应收收免件数
          M2, -- 应收收免水量
          M4, --应收收免水费
          M5, -- 应收收免污水量
          M6, --应收收免污水水费
          M3, -- 应收收免金额
          M7, --按表收免水量
          M8, --按人收免水量
          M9, --按表件数
          M10, --按人件数
          m17,
          m18,
          m19,
          m20) =
         (SELECT '补当',
                 '收免',
                 X1,
                 X2,
                 X3,
                 X4,
                 X5,
                 X6,
                 X7,
                 X8,
                 X9,
                 X10,
                 x17,
                 x18,
                 x19,
                 x20
            FROM RPT_SUM_TEMP TMP
           WHERE U_MONTH = T1
                --AND T.AREA = T2
             AND T.WATERTYPE = T3
             AND T.CHAREGETYPE = T4
             AND T.OFAGENT = T5
             AND T.T16 = T6
             and T.t17 = t8
             and t.m50 = x41)
   WHERE T.U_MONTH = A_MONTH
     and exists (select 'a'
            FROM RPT_SUM_TEMP TMP
           WHERE U_MONTH = T1
                --AND T.AREA = T2
             AND T.WATERTYPE = T3
             AND T.CHAREGETYPE = T4
             AND T.OFAGENT = T5
             AND T.T16 = T6
             and T.t17 = t8
             and t.m50 = x41);
  COMMIT;

  ----------------------------------------------------------------------------
  --- 更新哈尔滨科目
  /*----------20140604去掉，因为收免的定义和此有误
  update RPT_SUM_detail
  set t20 = '补当', t19 = '收免' where T16 in ('29', '30')
  and  U_MONTH = A_MONTH;
  ------------------------------------------------------*/
  update RPT_SUM_detail
     set t20 = '补当', t19 = '基建'
   where T16 in ('u', 'v')
     and U_MONTH = A_MONTH;
  update RPT_SUM_detail
     set t20 = '补当', t19 = '补缴'
   where T16 in ('13')
     and U_MONTH = A_MONTH;
  update RPT_SUM_detail
     set t20 = '补当', t19 = '稽查'
   where T16 in ('14')
     and U_MONTH = A_MONTH;
  update RPT_SUM_detail
     set t20 = '补当', t19 = '稽查'
   where T16 in ('21')
     and U_MONTH = A_MONTH;
  update RPT_SUM_detail
     set t20 = '补当', t19 = '呆账'
   where T16 in ('D')
     and U_MONTH = A_MONTH;

  commit;

  update RPT_SUM_detail
     set sp21 = 1
   WHERE id in (select min(id)
                  from RPT_SUM_detail x
                 where U_MONTH = a_month
                 group by ofagent) --放第一条 营业所
     and U_MONTH = a_month;
  COMMIT;

  UPDATE RPT_SUM_detail T
     SET (T.SP1,
          T.SP2,
          T.SP3,
          T.SP4,
          T.SP5,
          T.SP6,
          T.SP7,
          T.SP8,
          T.SP9,
          T.SP10,
          T.SP11) =
         (select V1, ----'计划供水量（万方）';
                 V2, ---'计划供水金额（万元）';
                 V3, ----'计划售水量（万方）';
                 V4, ----'计划售水金额（万元）';
                 V5, ----'计划售水率';
                 V6, ----'计划污水金额（万元）';
                 F1, ----'完成供水量（万方）';
                 F2, ----'完成供水金额（万元）';
                 F3, ----'完成售水量（万方）';
                 F4, ----'完成售水金额（万元）';
                 F5 ----'完成售水率';
            from bs_plan t
           WHERE P2 = a_month
             and PTYPE = '11'
             AND D1 = t.ofagent)
   WHERE sp21 = 1
     and U_MONTH = a_month;
  COMMIT;

  --计划完成情况
  UPDATE RPT_SUM_detail T
     SET (T.SP7, T.SP8, T.SP9, T.SP10, T.SP11) =
         (select sum(c1) F1, ----'完成供水量（万方）';
                 sum(c6) F2, ----'完成供水金额（万元）';
                 sum(x32) F3, ----'完成售水量（万方）';
                 sum(x37) F4, ----'完成售水金额（万元）';
                 case
                   when sum(c6) > 0 then
                    sum(x37) / sum(c6) * 100
                   else
                    0
                 end F5 ----'完成售水率';
            from RPT_SUM_detail t1
           WHERE U_MONTH = a_month
             and t1.ofagent = t.ofagent)
   WHERE sp21 = 1
     and U_MONTH = a_month;
  COMMIT;

END;
/

