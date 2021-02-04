CREATE OR REPLACE PACKAGE BODY HRBZLS.PG_EWIDE_REPORTSUM_HRB_150314 IS
  /*********************************************************************************************
   DATE         AUTHOR     PROCEDURE      COMMENT                                               *
  *2013-10-10   LIQIZHU    抄表统计       MODIFIED 576行抄表统计欠费数据计算，                  *
                                                  RPT_SUM_DETAIL_20190401表改为RPT_SUM_READ_20190401              *
  *2013-10-10   LIQIZHU    账务明细统计   MODIFIED 1106行计算总销账数据时，增加PAYMENT表的关联  *
  *2013-10-10   LIQIZHU    综合统计       MODIFIED 2613行补充维度是，增加DISTINCT，             *
                                                   防止从RPT_SUM_READ_20190401表中获取的维度有重复       *
  *2013-10-10   LIQIZHU    综合统计       MODIFIED 2633行补充维度是，增加DISTINCT，             *
                                                   防止从RPT_SUM_DETAIL_20190401表中获取的维度有重复     *
  *********************************************************************************************/
  
 /* 应收账事务：
  1  计划抄表应收
  13  补缴收入
  14  稽查收入
  29  无表户
  30  故障表
  C  拆帐应收
  D  呆坏账
  O  追量
  T  营业外收入
  u  临时用水水费立账
  v  临时用水污水费立账
  */

PROCEDURE 初始化中间表(A_MONTH IN VARCHAR2)  AS
-----------------------
    CURSOR cur_p IS
    select 
     pid,
     a_month u_month
  FROM payment where pmonth = A_MONTH
  order by pid;
  
-----------------------
      CURSOR cur_rl IS
    select   
     rlid
  FROM reclist where rlmonth = A_MONTH
  order by rlid;
  
TYPE recp IS TABLE OF rpt_sum_pid%ROWTYPE;
--TYPE recrl IS TABLE OF rpt_sum_reclist%ROWTYPE;

recps recp;
--recrls recrl;
  
BEGIN
  --水价信息
  DELETE PRICE_PROP;
  INSERT INTO PRICE_PROP
    SELECT * FROM VIEW_PRICE_PROP;
  COMMIT;
 
   --20141024 hebang 添加汇总单据明细信息，以便实时数据与静态数据比对
  DELETE FROM RPT_SUM_PAYMENT where  pymonth =A_MONTH ;
  DELETE FROM RPT_SUM_RECLIST where  rlmonth =A_MONTH ;
    COMMIT;
  -- end 20141024 hebang  

  --用户信息 用户 水表 档案 银行 
  BEGIN

        DBMS_SNAPSHOT.REFRESH(
          LIST                 => 'MV_METER_PROP'
         ,METHOD               => 'F'
         ,PUSH_DEFERRED_RPC    => TRUE
         ,REFRESH_AFTER_ERRORS => TRUE
         ,PURGE_OPTION         => 1
         ,PARALLELISM          => 0
         ,ATOMIC_REFRESH       => FALSE
         ,NESTED               => TRUE);

/*        DBMS_SNAPSHOT.REFRESH(
          LIST                 => 'MV_RECLIST_CHARGE_01'
         ,METHOD               => 'F'
         ,PUSH_DEFERRED_RPC    => TRUE
         ,REFRESH_AFTER_ERRORS => TRUE
         ,PURGE_OPTION         => 1
         ,PARALLELISM          => 0
         ,ATOMIC_REFRESH       => FALSE
         ,NESTED               => TRUE);*/
        DBMS_SNAPSHOT.REFRESH(
          LIST                 => 'MV_RECLIST_CHARGE_02'
         ,METHOD               => 'F'
         ,PUSH_DEFERRED_RPC    => TRUE
         ,REFRESH_AFTER_ERRORS => TRUE
         ,PURGE_OPTION         => 1
         ,PARALLELISM          => 0
         ,ATOMIC_REFRESH       => FALSE
         ,NESTED               => TRUE);
-----------------------
    DELETE rpt_sum_pid nologging where u_month = a_month ;
--    DELETE rpt_sum_reclist nologging;
    
    commit;
    
    OPEN cur_p;
    WHILE (TRUE) LOOP
    FETCH cur_p BULK COLLECT
    INTO recps LIMIT 10000;
    FORALL i IN 1 .. recps.COUNT
    INSERT /*+append*/ INTO rpt_sum_pid NOLOGGING VALUES recps (i);
    COMMIT;
    EXIT WHEN cur_p%NOTFOUND;
    END LOOP;
    CLOSE cur_p;   

/*    
    OPEN cur_rl;
    WHILE (TRUE) LOOP
    FETCH cur_rl  BULK COLLECT
    INTO recrls LIMIT 10000;
    FORALL i IN 1 .. recrls.COUNT
    INSERT \*+append*\ INTO rpt_sum_reclist NOLOGGING VALUES recrls (i);
    COMMIT;
    EXIT WHEN cur_rl%NOTFOUND;
    END LOOP;
    CLOSE cur_rl;   */
    
null;

  END;

/*  ALTER TABLE RPT_SUM_READ_20190401 NOLOGGING;
  ALTER TABLE RPT_SUM_DETAIL_20190401 NOLOGGING;
  ALTER TABLE RPT_SUM_CHARGE NOLOGGING;
  ALTER TABLE RPT_SUM_TOTAL_20190401 NOLOGGING;*/

END;

  --清理数据
  PROCEDURE 清理数据(A_MONTH IN VARCHAR2) AS
  BEGIN
    IF A_MONTH = 'ALL' THEN
      DELETE RPT_SUM_READ_20190401;
      DELETE RPT_SUM_DETAIL_20190401;
      DELETE RPT_SUM_CHARGE;
      DELETE RPT_SUM_REMAIN;
      DELETE RPT_SUM_TOTAL_20190401;
      --20141024 hebang 添加汇总单据明细信息，以便实时数据与静态数据比对
      DELETE FROM RPT_SUM_PAYMENT  ;
      DELETE FROM RPT_SUM_RECLIST  ;
      -- end 20141024 hebang  
    ELSE
      DELETE RPT_SUM_READ_20190401 WHERE U_MONTH = A_MONTH;
      DELETE RPT_SUM_DETAIL_20190401 WHERE U_MONTH = A_MONTH;
      DELETE RPT_SUM_CHARGE WHERE U_MONTH = A_MONTH;
      DELETE RPT_SUM_REMAIN WHERE U_MONTH = A_MONTH;
      DELETE RPT_SUM_TOTAL_20190401 WHERE U_MONTH = A_MONTH;
      --20141024 hebang 添加汇总单据明细信息，以便实时数据与静态数据比对
      DELETE FROM RPT_SUM_PAYMENT where  pymonth =A_MONTH ;
      DELETE FROM RPT_SUM_RECLIST where  rlmonth =A_MONTH ;
      -- end 20141024 hebang  
  
    END IF;
    COMMIT;
  END;

  --预存存档
  PROCEDURE 预存存档(A_MONTH IN VARCHAR2) AS
    L_TPDATE DATE;
    CURSOR cur IS
    
    with   rl_dis as
     (select rlmid, sum(rlje) rlje from reclist  rl
where  rl.rlpaidflag = 'N' and rl.rlbadflag = 'N' 
group by rlmid)
      select 
        L_TPDATE tpdate, 
        A_MONTH u_month, 
        meterno miid, 
        misaving remain, 
        0 rsmeain, 
        rlje discharge
  from mv_meter_prop m, rl_dis rl
  where m.meterno = rl.rlmid(+);

  
TYPE rec IS TABLE OF RPT_SUM_REMAIN%ROWTYPE;

recs rec;

  BEGIN
    L_TPDATE := SYSDATE;

-----------------------

    DELETE RPT_SUM_REMAIN nologging  WHERE U_MONTH = A_MONTH;
    commit;
    
    OPEN cur;
    WHILE (TRUE) LOOP
    FETCH cur BULK COLLECT
    INTO recs LIMIT 10000;
    FORALL i IN 1 .. recs.COUNT
    INSERT /*+append*/ INTO RPT_SUM_REMAIN NOLOGGING VALUES recs (i);
    COMMIT;
    EXIT WHEN cur%NOTFOUND;
    END LOOP;
    CLOSE cur;
     
/*    
    --初始化本次预存--1、预存计算时间【是否跟财务月份一致】
    INSERT  INTO RPT_SUM_REMAIN NOLOGGING
      (TPDATE, U_MONTH, miid, REMAIN,  RSMEAIN, DISCHARGE )
      SELECT L_TPDATE TPDATE,
             A_MONTH U_MONTH,
             meterno,
             misaving,
             (select remain from RPT_SUM_REMAIN 
WHERE U_MONTH = 
TO_CHAR(ADD_MONTHS(TO_DATE(A_MONTH,  'YYYY.MM'),  -1),   'YYYY.MM')) RSMEAIN,
             (select sum(rlje) from reclist  rl
where  rl.rlpaidflag = 'N' and rl.rlbadflag = 'N' 
and rl.rlcid = b.meterno) DISCHARGE
        FROM mv_meter_prop B;
        
    COMMIT;        
*/        
        
        

  END;
/*-----------------------------------------------------------------------------------------------
--抄表统计
用途：
说明：
-----------------------------------------------------------------------------------------------*/
  PROCEDURE 抄表统计(A_MONTH IN VARCHAR2) AS
  BEGIN
    
    --删除当月报表数据
    DELETE RPT_SUM_READ_20190401 T WHERE T.U_MONTH = A_MONTH;
    COMMIT;
    
    --1.生成粒度
    INSERT INTO RPT_SUM_READ_20190401
      (TPDATE, U_MONTH, OFAGENT, AREA, CBY, CHAREGETYPE, WATERTYPE,t17,m50)
      --20140901添加维度M50  值1代表冲往月 0 代表正常
      SELECT SYSDATE,
             A_MONTH, --账务月份
             OFAGENT, --营业所
             AREA, --表册区域(代号)
             CBY, --抄表员
             CHARGETYPE, --收费方式（M：走收总表，X：坐收户表）
             WATERTYPE, --用水类别
             MILB ,   --水表类别
             0 m50  --值1代表冲往月 0 代表正常
        FROM MV_METER_PROP
       GROUP BY AREA, CHARGETYPE, WATERTYPE, CBY, OFAGENT, MILB,0;
    COMMIT;     
      
      
    --2.生成总水量等应收信息  
    execute immediate 'truncate table RPT_SUM_TEMP';         
    INSERT INTO RPT_SUM_TEMP
      (T1,
       T2,
       T3,
       T4,
       T5,
       T6,
       t8,
       X41, --20140901添加维度M50  值1代表冲往月 0 代表正常
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
             substr(rlbfid, 1, 5), -- M.AREA,表册
             rlpfid, --m.WATERTYPE WATERTYPE, 主价格类别
             rlrper, -- M.CBY,抄表员
             rlyschargetype, --M.CHARGETYPE,应收方式
             rlsmfid, -- M.OFAGENT, 营销公司
             rllb, --M.MILB, 类别 
             (case when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH   and rl.rlmonth=A_MONTH     then 1    --1代表冲往月
                   when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH  and rl.rlmonth=A_MONTH    then 2     --2代表冲本月 
                   when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH  and rl.rlmonth <> A_MONTH    then 1  --1代表冲往月 
                   else 0 end )  x41,--20140901添加维度M50  值1代表冲往月 2代表冲本月 0 代表正常
             SUM(WATERUSE) C1,    --应收总水量
             SUM(USE_R1) C2,      --阶梯1
             SUM(USE_R2) C3,      --阶梯2
             SUM(USE_R3) C4,      --阶梯3
             SUM(CHARGETOTAL) C5, --应收总金额
             SUM(CHARGE1) C6,     --水费
             SUM(CHARGE2) C7,     --污水费
             SUM(CHARGE3) C8,     --附加费
             SUM(CHARGE4) C9,     --代收费3
             SUM(CHARGE_R1) C10,  --阶梯1
             SUM(CHARGE_R2) C11,  --阶梯2
             SUM(CHARGE_R3) C12,  --阶梯3
             SUM(1) C13, --笔数
             SUM(CHARGE5) C14,    --代收费4
             SUM(CHARGE6) C15,    --代收费5
             SUM(case when MISTATUS in ('29','30' ) then 0 else 1 end )   C16,        --按表件数
             SUM(case when MISTATUS in ('29','30' ) then 0 else charge1 end )   C17,  --按表金额
             SUM(case when MISTATUS in ('29','30' ) then 1 else 0 end )    C18,       --按人件数
             SUM(case when MISTATUS in ('29','30' ) then charge1 else 0 end )  C19,   --按人金额 
             0 C20,                                                                   --污水费0
            SUM(case when MISTATUS in ('29','30' ) then 0 else WATERUSE end )   C21,  --按表水量
             SUM(case when MISTATUS in ('29','30' ) then WATERUSE else 0 end )  C22,  --按人水量
             SUM(WSSL) W1                                                             --应收_总污水量
        FROM RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M
       WHERE RL.RLID = RD.RDID
         AND RL.RLMONTH = A_MONTH
         AND RL.RLMID = M.METERNO  
         and (rl.rlje <> 0 or rl.rlsl <> 0  )                                         -- add hb 20150803消防水鹤有水量没有金额需要计算
         and  RL.RLPFID <> 'A07'                                                      --add hb 20150803将用水性质(A07居民生活用水/计量总表)水量排除掉   
         and rltrans not in ( 'u', 'v', '13', '14', '21','23')
         AND NVL(RLBADFLAG, 'N') = 'N'                                                --吊账标志，'N'正常账
       GROUP BY substr(rlbfid, 1, 5)  , rlyschargetype , rlpfid , rlrper , rlsmfid , rllb, 
     (case when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH   and rl.rlmonth=A_MONTH     then 1  --1代表冲往月
           when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH  and rl.rlmonth=A_MONTH     then 2  --2代表冲本月 
           when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH  and rl.rlmonth <> A_MONTH  then 1  --1代表冲往月 
           else 0 
      end );
 
    -- start 解决临时表和中间表在表册和抄表员不匹配的问题
    update RPT_SUM_TEMP t set t.t2 = '无表册' where t.t2 is null;
    update RPT_SUM_TEMP t set t4 = '无人员' where t.t4 is null;
    --end 解决临时表和中间表在表册和抄表员不匹配的问题
    -----------------------------------------------------------------------------------------

    ---补充VIEW_METER_PROP不存在的维度----
    INSERT INTO RPT_SUM_READ_20190401
      (TPDATE, U_MONTH, OFAGENT, AREA, CBY, CHAREGETYPE, WATERTYPE, T17,m50)
      SELECT SYSDATE,
             A_MONTH, --账务月份
             T6      OFAGENT, --营业所
             T2      AREA, --区域
             T4      CBY, --抄表员
             T5      CHARGETYPE, --收费方式
             T3      WATERTYPE, --用水类别
             T8     miib ,
             x41   --20140901添加维度M50  值1代表冲往月 0 代表正常
        FROM RPT_SUM_TEMP
       WHERE T1 = A_MONTH
         AND (T1, T6, T2, T4, T5, T3, T8,x41) NOT IN
             (SELECT U_MONTH, OFAGENT, AREA, CBY, CHAREGETYPE, WATERTYPE, T17,m50 --20140901添加维度M50  值1代表冲往月 0 代表正常
                FROM RPT_SUM_READ_20190401
               WHERE U_MONTH = A_MONTH);
    ---补充VIEW_METER_PROP不存在的维度----
    
    
    UPDATE RPT_SUM_READ_20190401 T
       SET (C1, --应收_总水量
            C2, --应收_阶梯1水量
            C3, --应收_阶梯2水量
            C4, --应收_阶梯3水量
            C5, --应收_总金额
            C6, --应收_水费
            C7, --应收_污水费
            C8, ---应收_附加费
            C9, --应收_费用项目4
            C10,--应收_阶梯1金额
            C11,--应收_阶梯2金额
            C12,--应收_阶梯3金额
            C13,--应收笔数
            C14,--代收费4
            C15,--代收费5
            C16,--按表件数
            C17,--按表金额
            C18,--按人件数
            C19,--按人金额 
            C20,--污水费
            c21,--按表水量
            c22,--按人水量
            W1  --应收_总污水量
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
               AND T.AREA = T2
               AND T.WATERTYPE = T3
               AND NVL(T.CBY,'无人员') = NVL(T4,'无人员')   --抄表员为空的时候要考虑更新问题 ralph 20151001
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6
               and t.t17 = t8
               and t.m50 =x41)--20140901添加维度M50  值1代表冲往月 0 代表正常
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
 
    ----收免
/*-2014.06.04 修改收免数据生成条件---------------------------------------------------
--一下为原方法 start
    DELETE RPT_SUM_TEMP;
    COMMIT;
    INSERT INTO RPT_SUM_TEMP
      (T1,
       T2,
       T3,
       T4,
       T5,
       T6,
       t8,
       X1,
       X2,
       X3,
       X4,
       X5,
       X6
       )
        SELECT A_MONTH U_MONTH,
               substr(rlbfid, 1, 5), -- M.AREA,
               rlpfid, --m.WATERTYPE WATERTYPE,
               rlrper, -- M.CBY,
               rlyschargetype, --M.CHARGETYPE,
               rlsmfid, -- M.OFAGENT,
               rllb, --M.MILB,
               SUM(CASE
                     WHEN RDPIID = '01' THEN
                      1
                     ELSE
                      0
                   END) dis_c, --  收免件数
               SUM(CASE
                     WHEN RDPIID = '01' THEN
                      RDadjsl
                     ELSE
                      0
                   END) dis_u1, --  收免水量
               SUM(CASE
                     WHEN RDPIID = '01' THEN
                      RDadjsl * rddj
                     ELSE
                      0
                   END) dis_m1, --  收免水费
               SUM(CASE
                     WHEN RDPIID = '02' THEN
                      RDadjsl
                     ELSE
                      0
                   END) dis_u2, --  收免污水量
               SUM(CASE
                     WHEN RDPIID = '02' THEN
                      RDadjsl * rddj
                     ELSE
                      0
                   END) dis_m2, --  收免污水费
               SUM(RDadjsl * rddj) dis_m --  收免金额
          FROM RECLIST RL, MV_METER_PROP M, recdetail rd
         WHERE RL.RLID = RD.RDID
           AND RL.RLMONTH = A_MONTH
           AND RL.RLMID = M.METERNO
           and rltrans not in ('u', 'v', '13', '14', '21')
           and rl.RLCID IN (SELECT PALCID
                              FROM PRICEADJUSTLIST T
                             WHERE PALTACTIC = '02'
                               AND PALWAY = '-1')
           AND NVL(RLBADFLAG, 'N') = 'N'
         GROUP BY substr(rlbfid, 1, 5),
                  rlyschargetype,
                  rlpfid,
                  rlrper,
                  rlsmfid,
                  rllb;
--       GROUP BY M.AREA, m.WATERTYPE, M.CBY, M.CHARGETYPE, OFAGENT,M.MILB;
--以上为原方法 end */

/*------------------------------------------------------
--以下为新方法 start 20140604 by 郑仕华-----------------*/
    
    --3.生成收免信息
    execute immediate 'truncate table RPT_SUM_TEMP';
    INSERT INTO RPT_SUM_TEMP
      (T1,
       T2,
       T3,
       T4,
       T5,
       T6,
       t8,
       x41,--20140901添加维度M50  值1代表冲往月 0 代表正常
       X1,
       X2,
       X3,
       X4,
       X5,
       X6,
       X7,
       X8,
       X9,
       X10,x17,x18,x19,x20
       )
        SELECT A_MONTH U_MONTH,
               substr(rlbfid, 1, 5), -- M.AREA,
               rlpfid, --m.WATERTYPE WATERTYPE,
               rlrper, -- M.CBY,
               rlyschargetype, --M.CHARGETYPE,
               rlsmfid, -- M.OFAGENT,
               rllb, --M.MILB,
           (case when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH   and rl.rlmonth=A_MONTH     then 1    --1代表冲往月
                 when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH  and rl.rlmonth=A_MONTH     then 2    --2代表冲本月 
                 when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH  and rl.rlmonth <> A_MONTH  then 1    --1代表冲往月 
                 else 0 
            end )  x41,                              --维度M50  值1代表冲往月 2代表冲本月 0 代表正常
          SUM (CASE WHEN RDPIID = '01'  THEN  ( case when abs(RLADDSL) > 0 then 1 else 0  end )  ELSE 0 END)  dis_c, --收免件数
          SUM (CASE WHEN RDPIID = '01'  THEN  abs(RLADDSL)   ELSE 0 END) dis_u1,                                     --  收免水量 =抄表水量-应收水量
          SUM (CASE WHEN RDPIID = '01' THEN  round(abs(RLADDSL * rddj),2)  ELSE 0 END) dis_m1,                       --  收免水费
          SUM (CASE WHEN RDPIID = '02'  THEN abs(RLADDSL)  ELSE 0 END) dis_u2,                                       --  收免污水量=抄表水量-应收水量
          SUM (CASE WHEN RDPIID = '02'  THEN  round(abs(RLADDSL * rddj),2)   ELSE 0 END) dis_m2,                     --  收免污水费
          sum(round(abs(RLADDSL * rddj),2) ) dis_m ,                                                                 --  收免金额 
          SUM (CASE WHEN RDPIID = '01'  THEN ( case when M.MISTATUS in ('29','30' ) then 0 else abs(RLADDSL)  end )  ELSE 0 END)  X7, --收免按表水量
          SUM (CASE WHEN RDPIID = '01'  THEN ( case when M.MISTATUS in ('29','30' ) then abs(RLADDSL)  else 0 end )  ELSE 0 END)  X8, --收免按人水量
          SUM (CASE WHEN RDPIID = '01'  THEN ( case when M.MISTATUS in ('29','30' ) then 0 else  ( case when abs(RLADDSL)  > 0 then 1 else 0  end )  end )  ELSE 0 END)  X9,  --收免按表件数
          SUM (CASE WHEN RDPIID = '01'  THEN ( case when M.MISTATUS in ('29','30' ) then  ( case when abs(RLADDSL)  > 0 then 1 else 0  end )  else 0 end )  ELSE 0 END)  X10, --收免按人件数 
          SUM (CASE WHEN RDPIID = '02'  THEN ( case when M.MISTATUS in ('29','30' ) then 0 else abs(RLADDSL)  end )  ELSE 0 END)  X17,--收免按表污水量
          SUM (CASE WHEN RDPIID = '02'  THEN ( case when M.MISTATUS in ('29','30' ) then abs(RLADDSL)  else 0 end )  ELSE 0 END)  X18,--收免按人污水量
          SUM (CASE WHEN RDPIID = '02'  THEN ( case when M.MISTATUS in ('29','30' ) then 0 else ( case when abs(RLADDSL)  > 0 then 1 else 0  end ) end )  ELSE 0 END)  X19, --收免按表污水量件数
          SUM (CASE WHEN RDPIID = '02'  THEN ( case when M.MISTATUS in ('29','30' ) then ( case when abs(RLADDSL) > 0 then 1 else 0  end ) else 0 end )  ELSE 0 END)  X20   --收免按人污水量件数 
          FROM RECLIST RL, METERINFO M, view_recdetail_01 rd
         WHERE RL.RLID = RD.RDID
           AND RL.RLMONTH = A_MONTH
           AND RL.RLMID = M.miid
            --  and rlje<>0  --by 20150106 wangwei    
           and (rl.rlje <> 0 or rl.rlsl <> 0  ) -- add hb 20150803消防水鹤有水量没有金额需要计算
           and RL.RLPFID <> 'A07'               --add hb 20150803将用水性质(A07居民生活用水/计量总表)水量排除掉            
           and rltrans not in ('u', 'v', '13', '14', '21','23')
           and M.MIYL2='1'
         -- and (RL.RLADDSL<>0 OR RL.rlsl <> RL.RLREADSL) 
           and RL.RLADDSL <> 0          
           AND NVL(RLBADFLAG, 'N') = 'N'
         GROUP BY substr(rlbfid, 1, 5),
                  rlyschargetype,
                  rlpfid,
                  rlrper,
                  rlsmfid,
                  rllb,
         (case when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH   and rl.rlmonth=A_MONTH        then 1  --1代表冲往月
                   when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH  and rl.rlmonth=A_MONTH    then 2  --2代表冲本月 
                   when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH  and rl.rlmonth <> A_MONTH then 1  --1代表冲往月 
                   else 0 end )  ;--20140901添加维度M50  值1代表冲往月 2代表冲本月 0 代表正常 

--以上为新方法 end 20140604 by 郑仕华-----------------
    
    ---补充VIEW_METER_PROP不存在的维度----
    INSERT INTO RPT_SUM_READ_20190401
      (TPDATE, U_MONTH, OFAGENT, AREA, CBY, CHAREGETYPE, WATERTYPE, T17,m50)
      SELECT SYSDATE,
             A_MONTH, --账务月份
             T6      OFAGENT, --营业所
             T2      AREA, --区域
             T4      CBY, --抄表员
             T5      CHARGETYPE, --收费方式
             T3      WATERTYPE, --用水类别
             T8     miib ,
             x41   --20140901添加维度M50  值1代表冲往月 0 代表正常
        FROM RPT_SUM_TEMP
       WHERE T1 = A_MONTH
         AND (T1, T6, T2, T4, T5, T3, T8,x41) NOT IN
             (SELECT U_MONTH, OFAGENT, AREA, CBY, CHAREGETYPE, WATERTYPE, T17,m50 --20140901添加维度M50  值1代表冲往月 0 代表正常
                FROM RPT_SUM_READ_20190401
               WHERE U_MONTH = A_MONTH);
    ---补充VIEW_METER_PROP不存在的维度----
    
    
    UPDATE RPT_SUM_READ_20190401 T
       SET (M1, --应收收免件数
            M2, -- 应收收免水量
            M4, --应收收免水费
            M5, -- 应收收免污水费
            M6, --应收收免污水量
            M3, --应收收免金额
            M7, --收免按表水量
            M8, --收免按人水量
            M9, --收免按表件数
            M10,--收免按人件数
            m17,--收免按表污水量
            m18,--收免按人污水量
            m19,--收免按表污水量件数
            m20 --收免按人污水量件数
            ) =
           (SELECT X1,
                   X2,
                   X3,
                   X4,
                   X5,
                   X6,X7,X8,X9,X10,x17,x18,x19,x20  
              FROM RPT_SUM_TEMP TMP
             WHERE U_MONTH = T1
               AND T.AREA = T2
               AND T.WATERTYPE = T3
              AND NVL(T.CBY,'无人员') = NVL(T4,'无人员')   --抄表员为空的时候要考虑更新问题 ralph 20151001
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6
               and  T.t17 = t8
               and t.m50 = x41 )-- 20140901添加维度M50  值1代表冲往月 0 代表正常
     WHERE T.U_MONTH = A_MONTH 
           and  exists ( select 'a'   
                           FROM RPT_SUM_TEMP TMP
                          WHERE U_MONTH = T1                             --应收月份
                            AND T.AREA = T2                              --区域代号    
                            AND T.WATERTYPE = T3                         --用水类别
                            AND NVL(T.CBY,'无人员') = NVL(T4,'无人员')   --抄表员为空的时候要考虑更新问题 ralph 20151001
                            AND T.CHAREGETYPE = T5                       --缴费方式            
                            AND T.OFAGENT = T6                           --营业所
                            and T.t17 = t8                               --水表类别
                            and t.m50 = x41 );                           -- 20140901添加维度M50  值1代表冲往月 0 代表正常
     
    COMMIT;

 

    ----------------哈尔滨 ----------------
    /*    污水抄表
    x64, --污水超标件数
    x65, --污水超标单价
    x66, --污水超标污水量
    x67, --污水超标金额
    */
    
    --4.生成污水超标数据
    execute immediate 'truncate table RPT_SUM_TEMP';
    --DELETE RPT_SUM_TEMP;
    --COMMIT;
    
    INSERT INTO RPT_SUM_TEMP
      (T1,
       T2,
       T3,
       T4,
       T5,
       T6,
       t8,
       x41,-- 20140901添加维度M50  值1代表冲往月 0 代表正常
       X1,
       X2,
       X3,
       X4
       )
      SELECT A_month U_MONTH,
             substr(rlbfid, 1, 5), -- M.AREA,
             rlpfid, --m.WATERTYPE WATERTYPE,
             rlrper,               -- M.CBY,
             rlyschargetype, --M.CHARGETYPE,
             rlsmfid, -- M.OFAGENT,
             rllb, --M.MILB,
             (case when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH   and rl.rlmonth=A_MONTH     then 1  --1代表冲往月
                   when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH  and rl.rlmonth=A_MONTH    then 2  --2代表冲本月 
                   when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH  and rl.rlmonth <> A_MONTH    then 1  --1代表冲往月 
                   else 0 end 
             )  x41, -- 20140901添加维度M50  值1代表冲往月 0 代表正常
             COUNT(rl.rlid) x64, -- 污水超标件数
             --        CONNSTR(distinct DJ2)   x65, -- 污水超标单价
             MAX( DJ2)    x65,    -- 污水超标单价
             SUM(WSSL)    x66,    -- 污水超标污水量
             SUM(CHARGE2) x67     -- 污水超标金额
        FROM RECLIST RL, 
             MV_RECLIST_CHARGE_02 RD  /*, MV_METER_PROP M*/
       WHERE RL.RLID = RD.RDID
         /*  2016.11.30修改 byj 污水超标由于工单和实际应收有时间差,数据不准确,直接从应收污水费单价判断是否超标
         and rlcid in
                  (
                  SELECT PALCID  --用户编号
                                        FROM PRICEADJUSTLIST T  --计费调整列表
                                       WHERE PALTACTIC = '09'  --策略（02-仅安水表 07 水表+价格类别 09 -水表+价格类别+费用类别）
                                         AND PALMETHOD = '01' --调整方法
                                         AND PALSTARTMON <= A_month--开始月份
                                         AND (PALENDMON >= A_month OR PALENDMON IS NULL)--结束月份
                                         AND PALWAY = '1'  --调整方向
                  )     
         */          
          AND RL.RLMONTH = A_month
          and rltrans not in ( 'u', 'v', '13', '14', '21','23')
          and (rl.rlje <> 0 or rl.rlsl <> 0  ) -- add hb 20150803消防水鹤有水量没有金额需要计算
          and  RL.RLPFID <> 'A07'   --add hb 20150803将用水性质(A07居民生活用水/计量总表)水量排除掉   
         -- AND RL.RLMID = M.METERNO
          AND RLBADFLAG = 'N'
          and rd.dj2 > (select pddj from pricedetail pd where pd.pdpfid = rl.rlpfid and pd.pdpiid = '02')  --取价格参数表中的污水费价格
         GROUP BY substr(rlbfid, 1, 5)  , rlyschargetype , rlpfid , rlrper , rlsmfid , rllb ,  
          (case when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH   and rl.rlmonth=A_MONTH     then 1  --1代表冲往月
                when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH  and rl.rlmonth=A_MONTH     then 2  --2代表冲本月 
                when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH  and rl.rlmonth <> A_MONTH  then 1  --1代表冲往月 
                else 0 
           end ) ;
           
    ---补充VIEW_METER_PROP不存在的维度----
    INSERT INTO RPT_SUM_READ_20190401
      (TPDATE, U_MONTH, OFAGENT, AREA, CBY, CHAREGETYPE, WATERTYPE, T17,m50)
      SELECT SYSDATE,
             A_MONTH, --账务月份
             T6      OFAGENT, --营业所
             T2      AREA, --区域
             T4      CBY, --抄表员
             T5      CHARGETYPE, --收费方式
             T3      WATERTYPE, --用水类别
             T8     miib ,
             x41   --20140901添加维度M50  值1代表冲往月 0 代表正常
        FROM RPT_SUM_TEMP
       WHERE T1 = A_MONTH
         AND (T1, T6, T2, T4, T5, T3, T8,x41) NOT IN
             (SELECT U_MONTH, OFAGENT, AREA, CBY, CHAREGETYPE, WATERTYPE, T17,m50 --20140901添加维度M50  值1代表冲往月 0 代表正常
                FROM RPT_SUM_READ_20190401
               WHERE U_MONTH = A_MONTH);
    ---补充VIEW_METER_PROP不存在的维度----       
   
    UPDATE RPT_SUM_READ_20190401 T
       SET (x64, --污水超标件数
            X65, --污水超标单价
            x66, --污水超标污水量
            x67 --污水超标金额
            ) =
           (SELECT X1,
                   X2,
                   X3,
                   X4
              FROM RPT_SUM_TEMP TMP
             WHERE U_MONTH = T1                             --账务月份
               AND T.AREA = T2                              --区域代号  
               AND T.WATERTYPE = T3                         --用水类别
               AND NVL(T.CBY,'无人员') = NVL(T4,'无人员')   --抄表员为空的时候要考虑更新问题 ralph 20151001
               AND T.CHAREGETYPE = T5                       --缴费方式            
               AND T.OFAGENT = T6                           --营业所
               and  t.t17 = t8                              --水表类别
               and t.m50 =x41)                              --冲正标志
    WHERE T.U_MONTH = A_month and
          exists ( select 'a'   
                     FROM RPT_SUM_TEMP TMP
                    WHERE U_MONTH = T1                             --应收月份
                      AND T.AREA = T2                              --区域代号    
                      AND T.WATERTYPE = T3                         --用水类别
                      AND NVL(T.CBY,'无人员') = NVL(T4,'无人员')   --抄表员为空的时候要考虑更新问题 ralph 20151001
                      AND T.CHAREGETYPE = T5                       --缴费方式            
                      AND T.OFAGENT = T6                           --营业所
                      and T.t17 = t8                               --水表类别
                      and t.m50 = x41 );                           -- 20140901添加维度M50  值1代表冲往月 0 代表正常
     
    COMMIT;
    
    ---5.生成销账数据(销账为当月,应收不限)
    execute immediate 'truncate table RPT_SUM_TEMP';
    --DELETE RPT_SUM_TEMP;
    --COMMIT;
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
       X40 --污水量
       )
      SELECT A_MONTH U_MONTH,
             substr(rlbfid, 1, 5), -- M.AREA,
             rlpfid, --m.WATERTYPE WATERTYPE,
             rlrper, -- M.CBY,
             rlyschargetype, --M.CHARGETYPE,
             rlsmfid, -- M.OFAGENT,
             rllb, --M.MILB,  
              (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH and p.pmonth=A_MONTH  then 1        --1代表冲往月
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH  and p.pmonth=A_MONTH  then 2     --2代表冲本月 
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH  and p.pmonth <> A_MONTH  then 1  --2代表冲本月 
                    else 0 
               end ) x41, -- 20140901添加维度M50  值1代表冲往月 0 代表正常
             SUM(WATERUSE) X32,    --总销账_总水量
             SUM(USE_R1) X33,      --总销账_阶梯1
             SUM(USE_R2) X34,      --总销账_阶梯2
             SUM(USE_R3) X35,      --总销账_阶梯3
             SUM(CHARGETOTAL) C36, --总销账_总金额
             SUM(CHARGE1) X37,     --总销账_污水费
             SUM(CHARGE2) X38,     --总销账_附加费
             SUM(CHARGE3) X39,     --总销账_费用项目3
             SUM(CHARGE4) X40,     --总销账_费用项目4
             SUM(CHARGE_R1) X41,   --总销账_阶梯1 金额
             SUM(CHARGE_R2) X42,   --总销账_阶梯2 金额
             SUM(CHARGE_R3) X43,   --总销账_阶梯3 金额
             SUM(1) X44,           --总销账_笔数
             SUM(CHARGE5) X45,     --总销账_代收费4
             SUM(CHARGE6) X46,     --总销账_代收费5
             SUM(CHARGE7) X47,     --总销账_代收费6
             /*SUM(RD.CHARGEZNJ)*/
             0 X50,                --总销账滞纳金
             SUM(case when charge2 <> 0 then WSSL else 0 end) W4  --总销账_总污水量
        FROM RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
            -- MV_METER_PROP        M,
             PAYMENT              P
       WHERE RL.RLID = RD.RDID
         --AND RL.RLMID = M.METERNO
         AND RL.RLPID = P.PID
         AND P.PMONTH = A_MONTH  --实收账月份
           and rltrans not in ( 'u', 'v', '13', '14', '21','23')
         --AND RL.RLPAIDFLAG = 'Y'  --销账标志
        -- AND RL.RLPAIDMONTH = A_MONTH--销账月份
       GROUP BY substr(rlbfid, 1, 5)  , rlyschargetype , rlpfid , rlrper , rlsmfid , rllb,   
              (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH and p.pmonth=A_MONTH  then 1     --1代表冲往月
                    when p.PREVERSEFLAG = 'Y' AND p.PMONTH = p.PSCRMONTH and p.pmonth=A_MONTH  then 2     --2代表冲本月 
                    when p.PREVERSEFLAG = 'Y' AND p.PMONTH = p.PSCRMONTH and p.pmonth <> A_MONTH  then 1  --2代表冲本月 
                    else 0 
               end ) ;
    
    ---补充VIEW_METER_PROP不存在的维度----
    INSERT INTO RPT_SUM_READ_20190401
      (TPDATE, U_MONTH, OFAGENT, AREA, CBY, CHAREGETYPE, WATERTYPE, T17,m50) -- 20140901添加维度M50  值1代表冲往月 0 代表正常
      SELECT SYSDATE,
             A_MONTH, --账务月份
             T6      OFAGENT, --营业所
             T2      AREA, --区域
             T4      CBY, --抄表员
             T5      CHARGETYPE, --收费方式
             T3      WATERTYPE, --用水类别
             T8     miib,
             x41   -- 20140901添加维度M50  值1代表冲往月 0 代表正常
        FROM RPT_SUM_TEMP
       WHERE T1 = A_MONTH
         AND (T1, T6, T2, T4, T5, T3, T8,x41) NOT IN
             (SELECT U_MONTH, OFAGENT, AREA, CBY, CHAREGETYPE, WATERTYPE, T17,m50
                FROM RPT_SUM_READ_20190401
               WHERE U_MONTH = A_MONTH);
    ---补充VIEW_METER_PROP不存在的维度----
    
    --总水量、总污水量 按表水量 前面已经计算过，此处不应该再更新!
    UPDATE RPT_SUM_READ_20190401 T
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
            X45, --总销账_代收费4
            X46,--总销账_代收费5
            X47,--总销账_代收费6
            X50,--总销账滞纳金
            X60,--总销账代收费7
            X61,--总销账代收费8
            X62,--总销账代收费9
            X63, --总销账污水费0
            W4   --总销账_总污水量
            --C1,   --应收_总水量
            --C21,   --按表水量
            --W1   --应收_总污水量
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
                   --X1,
                   --X21,
                   --X40
              FROM RPT_SUM_TEMP TMP
             WHERE U_MONTH = T1
               AND T.AREA = T2
               AND T.WATERTYPE = T3
               AND NVL(T.CBY,'无人员') = NVL(T4,'无人员')   --抄表员为空的时候要考虑更新问题 ralph 20151001
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6
               and  T.t17 = t8
               and t.m50 = x41)
     WHERE T.U_MONTH = A_MONTH and
           exists ( select 'a'   
                     FROM RPT_SUM_TEMP TMP
                    WHERE U_MONTH = T1                             --应收月份
                      AND T.AREA = T2                              --区域代号    
                      AND T.WATERTYPE = T3                         --用水类别
                      AND NVL(T.CBY,'无人员') = NVL(T4,'无人员')   --抄表员为空的时候要考虑更新问题 ralph 20151001
                      AND T.CHAREGETYPE = T5                       --缴费方式            
                      AND T.OFAGENT = T6                           --营业所
                      and T.t17 = t8                               --水表类别
                      and t.m50 = x41 );                           -- 20140901添加维度M50  值1代表冲往月 0 代表正常
    COMMIT;
  
    --6.增加消防水鹤的  by  20151203 ralph
    execute immediate 'truncate table RPT_SUM_TEMP';           
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
       X21,
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
             --SUM(WATERUSE) X32, --总销账_总水量
             SUM(rl.rlsl) X32,    --总销账_总水量
             SUM(USE_R1) X33,     --总销账_阶梯1
             SUM(USE_R2) X34,     --总销账_阶梯2
             SUM(USE_R3) X35,     --总销账_阶梯3
             SUM(CHARGETOTAL) C36,--总销账_总金额
             SUM(CHARGE1) X37,    --总销账_污水费
             SUM(CHARGE2) X38,    --总销账_附加费
             SUM(CHARGE3) X39,    --总销账_费用项目3
             SUM(CHARGE4) X40,    --总销账_费用项目4
             SUM(CHARGE_R1) X41,  --总销账_阶梯1 金额
             SUM(CHARGE_R2) X42,  --总销账_阶梯2 金额
             SUM(CHARGE_R3) X43,  --总销账_阶梯3 金额
             SUM(1) X44,          --总销账_笔数
             SUM(CHARGE5) X45,    --总销账_代收费4
             SUM(CHARGE6) X46,    --总销账_代收费5
             SUM(CHARGE7) X47,    --总销账_代收费6
             /*SUM(RD.CHARGEZNJ)*/
             0 X50,--总销账滞纳金
             --SUM(case when charge2 <> 0 then WSSL else 0 end) W4  --总销账_总污水量
             SUM(rl.rlsl) X21,
             SUM(rl.rlsl) W4  --总销账_总污水量
        FROM RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD
       WHERE RL.RLID = RD.RDID         
         AND rlpfid='B040101'
         AND RL.RLMONTH = A_MONTH  --实收账月份
         and rltrans not in ( 'u', 'v', '13', '14', '21','23')
       GROUP BY substr(rlbfid, 1, 5)  , rlyschargetype , rlpfid , rlrper , rlsmfid , rllb;
 
    ---补充VIEW_METER_PROP不存在的维度----
    INSERT INTO RPT_SUM_READ_20190401
      (TPDATE, U_MONTH, OFAGENT, AREA, CBY, CHAREGETYPE, WATERTYPE, T17,m50) -- 20140901添加维度M50  值1代表冲往月 0 代表正常
      SELECT SYSDATE,
             A_MONTH, --账务月份
             T6      OFAGENT, --营业所
             T2      AREA, --区域
             T4      CBY, --抄表员
             T5      CHARGETYPE, --收费方式
             T3      WATERTYPE, --用水类别
             T8     miib,
             x41   -- 20140901添加维度M50  值1代表冲往月 0 代表正常
        FROM RPT_SUM_TEMP
       WHERE T1 = A_MONTH
         AND (T1, T6, T2, T4, T5, T3, T8,x41) NOT IN
             (SELECT U_MONTH, OFAGENT, AREA, CBY, CHAREGETYPE, WATERTYPE, T17,m50
                FROM RPT_SUM_READ_20190401
               WHERE U_MONTH = A_MONTH);
    ---补充VIEW_METER_PROP不存在的维度----

    UPDATE RPT_SUM_READ_20190401 T
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
            X45, --总销账_代收费4
            X46,--总销账_代收费5
            X47,--总销账_代收费6
            X50,--总销账滞纳金
            X60,--总销账代收费7
            X61,--总销账代收费8
            X62,--总销账代收费9
            X63,--总销账污水费0
            --W4, --总销账_总污水量    20161202 消防水鹤不计入污水量
            C1, --应收_总水量
            C21--按表水量
            --W1  --应收_总污水量
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
                   --X40,
                   X1,
                   X21
                   --X40
              FROM RPT_SUM_TEMP TMP
             WHERE U_MONTH = T1
               AND T.AREA = T2
               AND T.WATERTYPE = T3
               AND NVL(T.CBY,'无人员') = NVL(T4,'无人员')   --抄表员为空的时候要考虑更新问题 ralph 20151001
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6
               and  T.t17 = t8
               and t.m50 = x41)
     WHERE T.U_MONTH = A_MONTH and
           exists ( select 'a'   
                     FROM RPT_SUM_TEMP TMP
                    WHERE U_MONTH = T1                             --应收月份
                      AND T.AREA = T2                              --区域代号    
                      AND T.WATERTYPE = T3                         --用水类别
                      AND NVL(T.CBY,'无人员') = NVL(T4,'无人员')   --抄表员为空的时候要考虑更新问题 ralph 20151001
                      AND T.CHAREGETYPE = T5                       --缴费方式            
                      AND T.OFAGENT = T6                           --营业所
                      and T.t17 = t8                               --水表类别
                      and t.m50 = x41 );                           -- 20140901添加维度M50  值1代表冲往月 0 代表正常
    COMMIT;
/*
 --add 20141024 hebang
 insert into rpt_sum_reclist
   (rlid, rlmonth, rltype, rlnote)
  SELECT distinct rl.rlid, A_month U_MONTH, '04', '抄表统计04-总销账'
    FROM RECLIST              RL,
         MV_RECLIST_CHARGE_02 RD,
         -- MV_METER_PROP        M,
         PAYMENT P
   WHERE RL.RLID = RD.RDID
        --AND RL.RLMID = M.METERNO
     AND RL.RLPID = P.PID
     AND P.PMONTH = A_MONTH --实收账月份
     and rltrans not in ('u', 'v', '13', '14', '21', '23')
  --AND RL.RLPAIDFLAG = 'Y'  --销账标志
  -- AND RL.RLPAIDMONTH = A_MONTH--销账月份
  ;
    commit;
  --add 20141024 hebang*/
  
    --7.销当月(销账月份为当月,应收月份也为当月)
    --DELETE RPT_SUM_TEMP;
    --COMMIT;
    execute immediate 'truncate table RPT_SUM_TEMP';
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
       X40 --污水量
       )
      SELECT A_MONTH U_MONTH,
             substr(rlbfid, 1, 5), -- M.AREA,
             rlpfid, --m.WATERTYPE WATERTYPE,
             rlrper, -- M.CBY,
             rlyschargetype, --M.CHARGETYPE,
             rlsmfid, -- M.OFAGENT,
             rllb, --M.MILB,
              (case when pp.PREVERSEFLAG = 'Y' AND pp.PMONTH > pp.PSCRMONTH and pp.pmonth=A_MONTH  then 1  --1代表冲往月
                    when pp.PREVERSEFLAG = 'Y'  AND pp.PMONTH =  pp.PSCRMONTH  and pp.pmonth=A_MONTH  then 2  --2代表冲本月 
                    when pp.PREVERSEFLAG = 'Y'  AND pp.PMONTH =  pp.PSCRMONTH  and pp.pmonth <> A_MONTH  then 1  --2代表冲本月 
                    else 0 end )  x41, -- 20140901添加维度M50  值1代表冲往月 0 代表正常
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
             SUM(CHARGE7) X31,
             /*SUM(RD.CHARGEZNJ)*/
             0 X49,
             SUM(CHARGE8) X56,
             SUM(CHARGE9) X57,
             SUM(CHARGE10) X58,
             0 X59,
             SUM(WSSL) W3  --销当月_总污水量
        FROM RECLIST RL, 
             MV_RECLIST_CHARGE_02 RD, 
             --MV_METER_PROP M,
             payment pp
       WHERE RL.RLID = RD.RDID 
         and rl.rlpid = pp.pid
         AND RL.RLMONTH = pp.pmonth--应收月份
         AND RL.RLPAIDFLAG = 'Y'  --销账标志
        and rltrans not in ( 'u', 'v', '13', '14', '21','23')
           ---ce038报表和ce039报表核对发现 此处少剔除'D'类账 zf 20171001
           --因只有几笔D类账，属于异常数据
           --暂调整数据（RLID IN ('0282495063','0282495064'))，不改程序
         --and rltrans not in ( 'u', 'v', '13', '14', '21','23','D')
         --AND RL.RLMID = M.METERNO
         AND pp.pmonth = A_MONTH--销账月份
         AND NVL(RL.RLBADFLAG, 'Y') = 'N' --呆账标志  
       GROUP BY substr(rlbfid, 1, 5)  , rlyschargetype , rlpfid , rlrper , rlsmfid , rllb , 
         (case when pp.PREVERSEFLAG = 'Y' AND pp.PMONTH > pp.PSCRMONTH and pp.pmonth=A_MONTH  then 1  --1代表冲往月
                    when pp.PREVERSEFLAG = 'Y'  AND pp.PMONTH =  pp.PSCRMONTH  and pp.pmonth=A_MONTH  then 2  --2代表冲本月 
                    when pp.PREVERSEFLAG = 'Y'  AND pp.PMONTH =  pp.PSCRMONTH  and pp.pmonth <> A_MONTH  then 1  --2代表冲本月 
                    else 0 end ) ;

 
    ---补充VIEW_METER_PROP不存在的维度----
    INSERT INTO RPT_SUM_READ_20190401
      (TPDATE, U_MONTH, OFAGENT, AREA, CBY, CHAREGETYPE, WATERTYPE, T17,m50) -- 20140901添加维度M50  值1代表冲往月 0 代表正常
      SELECT SYSDATE,
             A_MONTH, --账务月份
             T6      OFAGENT, --营业所
             T2      AREA, --区域
             T4      CBY, --抄表员
             T5      CHARGETYPE, --收费方式
             T3      WATERTYPE, --用水类别
             T8     miib,
             x41   -- 20140901添加维度M50  值1代表冲往月 0 代表正常
        FROM RPT_SUM_TEMP
       WHERE T1 = A_MONTH
         AND (T1, T6, T2, T4, T5, T3, T8,x41) NOT IN
             (SELECT U_MONTH, OFAGENT, AREA, CBY, CHAREGETYPE, WATERTYPE, T17,m50
                FROM RPT_SUM_READ_20190401
               WHERE U_MONTH = A_MONTH);
    ---补充VIEW_METER_PROP不存在的维度----
    
    
    UPDATE RPT_SUM_READ_20190401 T
       SET (X16, --销当月_总水量
            X17, -- 销当月_阶梯1
            X18, -- 销当月_阶梯2
            X19, --销当月_阶梯3
            X20, -- 销当月_总金额
            X21, --销当月_污水费
            X22, --销当月_附加费
            X23, ---销当月_费用项目3
            X24, --销当月_费用项目4
            X25, --销当月_阶梯1金额
            X26, --销当月_阶梯2金额
            X27, --销当月_阶梯3金额
            X28, --销当月笔数
            X29, --销当月_代收费4
            X30, --销当月_代收费5
            X31, --销当月_代收费6
            X49, --销当月滞纳金
            X56, --销当月代收费7
            X57, --销当月代收费8
            X58, --销当月代收费9
            X59, --销当月污水费0
            W3   --销当月_总污水量
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
               AND T.AREA = T2
               AND T.WATERTYPE = T3
              AND NVL(T.CBY,'无人员') = NVL(T4,'无人员')   --抄表员为空的时候要考虑更新问题 ralph 20151001
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6
               and  T.t17 = t8
               and t.m50=x41)-- 20140901添加维度M50  值1代表冲往月 0 代表正常
     WHERE T.U_MONTH = A_MONTH and
           exists (select 'a'   
                     FROM RPT_SUM_TEMP TMP
                    WHERE U_MONTH = T1                             --应收月份
                      AND T.AREA = T2                              --区域代号    
                      AND T.WATERTYPE = T3                         --用水类别
                      AND NVL(T.CBY,'无人员') = NVL(T4,'无人员')   --抄表员为空的时候要考虑更新问题 ralph 20151001
                      AND T.CHAREGETYPE = T5                       --缴费方式            
                      AND T.OFAGENT = T6                           --营业所
                      and T.t17 = t8                               --水表类别
                      and t.m50 = x41 );                           -- 20140901添加维度M50  值1代表冲往月 0 代表正常

/* --add 20141024 hebang
 insert into rpt_sum_reclist
   (rlid, rlmonth, rltype, rlnote)
  SELECT distinct rl.rlid, A_month U_MONTH, '05', '抄表统计05-销当月'
       FROM RECLIST RL, MV_RECLIST_CHARGE_02 RD, 
             --MV_METER_PROP M,
             payment pp
       WHERE RL.RLID = RD.RDID and rl.rlpid = pp.pid
         AND RL.RLMONTH = pp.pmonth--应收月份
         AND RL.RLPAIDFLAG = 'Y'  --销账标志
           and rltrans not in ( 'u', 'v', '13', '14', '21','23')
         --AND RL.RLMID = M.METERNO
         AND pp.pmonth = A_MONTH--销账月份
         AND NVL(RL.RLBADFLAG, 'Y') = 'N' --呆账标志  
        ;
    commit;
  --add 20141024 hebang*/

    --8.总欠费(只统计当月月末欠费情况)
    --ELETE RPT_SUM_TEMP;
    --COMMIT;
    execute immediate 'truncate table RPT_SUM_TEMP';
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
       X40 --污水量
       )
      SELECT A_MONTH U_MONTH,
             substr(rlbfid, 1, 5), -- M.AREA,
             rlpfid, --m.WATERTYPE WATERTYPE,
             rlrper, -- M.CBY,
             rlyschargetype, --M.CHARGETYPE,
             rlsmfid, -- M.OFAGENT,
             rllb, --M.MILB,
               (case when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH   and rl.rlmonth=A_MONTH     then 1  --1代表冲往月
                   when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH  and rl.rlmonth=A_MONTH    then 2  --2代表冲本月 
                   when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH  and rl.rlmonth <> A_MONTH    then 1  --1代表冲往月 
                   else 0 end )  x41, -- 20140901添加维度M50  值1代表冲往月 0 代表正常
             SUM(WATERUSE) Q1, --欠当月_总水量
             SUM(USE_R1) Q2, --欠当月_阶梯1
             SUM(USE_R2) Q3, --欠当月_阶梯2
             SUM(USE_R3) Q4, --欠当月_阶梯3
             SUM(CHARGETOTAL) Q5, --欠当月_总金额
             SUM(CHARGE1) Q6, --欠当月_水费
             SUM(CHARGE2) Q7, --欠当月_污水费
             SUM(CHARGE3) Q8, --欠当月_附加费
             SUM(CHARGE4) Q9, --欠当月_代收费3
             SUM(CHARGE_R1) Q10, --欠当月_阶梯1金额
             SUM(CHARGE_R2) Q11, --欠当月_阶梯2金额
             SUM(CHARGE_R3) Q12, --欠当月_阶梯3金额
              SUM(1) Q13, --欠当月_笔数   --欠费笔数过滤零水量费用、污水、附加费笔数
             SUM(CHARGE5) Q14,--欠当月_代收费4
             SUM(CHARGE6) Q15,--欠当月_代收费5
             SUM(CHARGE7) Q16,--欠当月_代收费6
             SUM(CHARGE8) Q33,--欠费代收费7
             SUM(CHARGE9) Q34,--欠费代收费8
             SUM(CHARGE10) Q35,--欠费代收费9
             0 Q36, --欠费污水费0
             SUM(WSSL) W5  --欠当月_总污水量
        FROM RECLIST RL, 
             MV_RECLIST_CHARGE_02 RD
             -- MV_METER_PROP M
       WHERE RL.RLID = RD.RDID
         --AND RL.RLMID = M.METERNO
       --  AND RL.RLPAIDFLAG = 'N'--销账标志，未销账
        AND (RL.RLPAIDFLAG = 'N' OR (RL.RLPAIDFLAG = 'Y' AND to_char(rlpaiddate,'yyyy.mm')>A_MONTH))                                                              --结算月之后销账的也属 当月欠费 zf 20150819
         and rltrans not in ( 'u', 'v', '13', '14', '21','23')
         AND RL.RLREVERSEFLAG = 'N'--未冲正
         AND RLMONTH = A_MONTH  --应收月份
         AND NVL(RL.RLBADFLAG, 'N') = 'N' --呆账标志
         and (rl.rlje <> 0 or rl.rlsl <> 0  ) -- add hb 20150803消防水鹤有水量没有金额需要计算
         and  RL.RLPFID <> 'A07'   --add hb 20150803将用水性质(A07居民生活用水/计量总表)水量排除掉   
       GROUP BY substr(rlbfid, 1, 5)  , rlyschargetype , rlpfid , rlrper , rlsmfid , rllb,  
          (case when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH   and rl.rlmonth=A_MONTH     then 1  --1代表冲往月
                when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH  and rl.rlmonth=A_MONTH    then 2  --2代表冲本月 
                when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH  and rl.rlmonth <> A_MONTH    then 1  --1代表冲往月 
                else 0 
           end )  ;
   

  
    ---补充VIEW_METER_PROP不存在的维度----
    INSERT INTO RPT_SUM_READ_20190401
      (TPDATE, U_MONTH, OFAGENT, AREA, CBY, CHAREGETYPE, WATERTYPE, T17,m50)
      SELECT SYSDATE,
             A_MONTH, --账务月份
             T6      OFAGENT, --营业所
             T2      AREA, --区域
             T4      CBY, --抄表员
             T5      CHARGETYPE, --收费方式
             T3      WATERTYPE, --用水类别
             T8     miib,
             x41   -- 20140901添加维度M50  值1代表冲往月 0 代表正常
        FROM RPT_SUM_TEMP
       WHERE T1 = A_MONTH
         AND (T1, T6, T2, T4, T5, T3, T8,x41) NOT IN
             (SELECT U_MONTH, OFAGENT, AREA, CBY, CHAREGETYPE, WATERTYPE, T17,m50  -- 20140901添加维度M50  值1代表冲往月 0 代表正常
                FROM RPT_SUM_READ_20190401
               WHERE U_MONTH = A_MONTH);
 --   COMMIT;
    ---补充VIEW_METER_PROP不存在的维度----

    --LIQIZHU 20131010 RPT_SUM_DETAIL_20190401表改为RPT_SUM_READ_20190401
    --UPDATE RPT_SUM_DETAIL_20190401 T
    UPDATE RPT_SUM_READ_20190401 T
       SET (Q1, --欠费_总水量
            Q2, -- 欠费_阶梯1
            Q3, -- 欠费_阶梯2
            Q4, --欠费_阶梯3
            Q5, -- 欠费_总金额
            Q6, --欠费_水费
            Q7, --欠费_污水费
            Q8, ---欠费_附加费
            Q9, --欠费_费用项目4
            Q10,--欠费_阶梯1金额
            Q11,--欠费_阶梯2金额
            Q12,--欠费_阶梯3金额
            Q13,--欠费笔数
            Q14,--预留
            Q15,
            Q16,
            Q33,
            Q34,
            Q35,
            Q36,
            W5  --欠当月_总污水量
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
               AND T.AREA = T2
               AND T.WATERTYPE = T3
               AND NVL(T.CBY,'无人员') = NVL(T4,'无人员')   --抄表员为空的时候要考虑更新问题 ralph 20151001
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6
               and  T.t17 = t8
               and t.m50 =x41)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
    
 
    --9. 更新 单价、科室信息
    UPDATE RPT_SUM_READ_20190401 T1
       SET (T1.WATERTYPE_B, --用水大类
            T1.WATERTYPE_M, --用水中类
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
                   T2.P16 --污水费3
              FROM PRICE_PROP T2
             WHERE T2.WATERTYPE = T1.WATERTYPE)
     WHERE U_MONTH = A_MONTH;
    COMMIT;

    UPDATE RPT_SUM_READ_20190401 T1
       SET T1.t18 --科室
           =  (SELECT oadept from operaccnt t where oaid =t1.cby )
     WHERE U_MONTH = A_MONTH;
    COMMIT;


    --10. -=========指标相关(户数)=========
    --DELETE RPT_SUM_TEMP;
    --COMMIT;
    execute immediate 'truncate table RPT_SUM_TEMP'; 
    INSERT INTO RPT_SUM_TEMP
      (T1, T2, T3, T4, T5, T6, T8, 
        X1, X2, X3, X4, X5, X6, X7)
      SELECT A_MONTH U_MONTH,
             AREA,
             WATERTYPE WATERTYPE,
             CBY,
             CHARGETYPE,
             M.OFAGENT,
             M.MILB, 
             SUM((CASE
                   WHEN M.MISTATUS = 1 AND M.METERNO = M.CCODE THEN
                    1
                   ELSE
                    0
                 END)) K1, --立户户数
             SUM(DECODE(M.MISTATUS, 1, 1, 0)) K2, --立户表数
             SUM((CASE
                   WHEN M.MISTATUS = 7 AND M.METERNO = M.CCODE THEN
                    1
                   ELSE
                    0
                 END)) K8, --销户户数
             SUM(DECODE(M.MISTATUS, 7, 1, 0)) K43, --销户表数
             SUM(DECODE(M.METERNO, M.CCODE, 1, 0)) K45, --总户数
             COUNT(*) K46, --总表数
             SUM((CASE
                   WHEN TO_CHAR(M.MIINSDATE, 'YYYY.MM') = A_MONTH THEN
                    1
                   ELSE
                    0
                 END)) K17
        FROM /*METERINFO MI,*/ MV_METER_PROP M
      /* WHERE MI.MIID = M.METERNO*/
       GROUP BY M.AREA, M.WATERTYPE, M.CBY, M.CHARGETYPE, OFAGENT,M.MILB ;
 
       
    UPDATE RPT_SUM_READ_20190401 T
       SET (K1, --立户户数
            K2, --立户表数
            K8, --销户户数
            K43, --销户表数
            K45, --总户数,
            K46, --总表数
            K17 --新增户数
            ) =
           (SELECT X1, X2, X3, X4, X5, X6, X7
              FROM RPT_SUM_TEMP TMP
             WHERE U_MONTH = T1
               AND T.AREA = T2
               AND T.WATERTYPE = T3
              AND NVL(T.CBY,'无人员') = NVL(T4,'无人员')   --抄表员为空的时候要考虑更新问题 ralph 20151001
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6
               and  T.t17 = t8 )
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

    --11.=========指标相关(抄表库)=========
    --DELETE RPT_SUM_TEMP;
    --COMMIT;
    execute immediate 'truncate table RPT_SUM_TEMP';
    INSERT INTO RPT_SUM_TEMP
      (T1, T2, T3, T4, T5, T6, T8, X1, X2, X3, X4, X5, X6, X7, X8, X9, X10)
      SELECT A_MONTH U_MONTH,
             AREA,
             WATERTYPE WATERTYPE,
             CBY,
             CHARGETYPE,
             OFAGENT,
             MILB,
             SUM(K3) K3, --应抄
             SUM(K4) K4, --实抄
             0 K5, --空件
             SUM(K6) K6, --无法算费数
             SUM(K7) K7, --已算费数
             AVG(K9) K9, --抄见率
             AVG(K10) K10, --正日率
             0 K11, --稽核错误数
             SUM(K12) K12, --波动超标数
             SUM(K13) K13 --0 水量数
        FROM (SELECT A_MONTH U_MONTH,
                     AREA,
                     WATERTYPE WATERTYPE,
                     CBY,
                     CHARGETYPE,
                     OFAGENT,
                     MILB,
                     SUM(1) K3, --应抄  账面件数
                     SUM(DECODE(MR.MRREADOK, 'Y', 1, 0)) K4, --实抄
                     0 K5, --空件
                     SUM(DECODE(MRIFREC, 'N', 1, 0)) K6, --无法算费数
                     SUM(DECODE(MRIFREC, 'Y', 1, 0)) K7, --已算费数  出帐件数
                     case when SUM(1) > 0 then ROUND(((SUM(DECODE(MR.MRREADOK, 'Y', 1, 0)) / SUM(1)) * 100),
                           2) else 0 end  K9, --抄见率 出帐完成率
/*                     ROUND(((SUM((CASE
                                   WHEN MR.MRREADOK = 'Y' AND MR.MRBFDAY = 0 THEN
                                    1
                                   ELSE
                                    0
                                 END)) / SUM((CASE
                                                 WHEN MR.MRREADOK = 'Y' THEN
                                                  1
                                                 ELSE
                                                  0
                                               END))) * 100),
                           2)  */  0 K10,--正日率
                     0 K11,
/*                     SUM(CASE
                           WHEN MRIFSUBMIT = 'N' AND MRFACE = '01' AND
                                MRCHKFLAG = 'N' THEN
                            1
                           ELSE
                            0
                         END)*/ 0  K12, --波动超标数
                     SUM(CASE
                           WHEN MRIFSUBMIT = 'N' AND MRFACE = '03' AND
                                MRCHKFLAG = 'N' THEN
                            1
                           ELSE
                            0
                         END) K13 --0 水量数
                FROM METERREAD MR, MV_METER_PROP M
               WHERE MR.MRMONTH = A_MONTH
                 AND MR.MRMID = M.METERNO
               GROUP BY M.AREA, M.WATERTYPE, M.CBY, M.CHARGETYPE, OFAGENT,MILB
              UNION
              SELECT A_MONTH U_MONTH,
                     AREA,
                     WATERTYPE WATERTYPE,
                     CBY,
                     CHARGETYPE,
                     OFAGENT,
                     MILB,
                     SUM(1) K3, --应抄
                     SUM(DECODE(MR.MRREADOK, 'Y', 1, 0)) K4, --实抄
                     0 K5, --空件
                     SUM(DECODE(MRIFREC, 'N', 1, 0)) K6, --无法算费数
                     SUM(DECODE(MRIFREC, 'Y', 1, 0)) K7, --已算费数
                     case when SUM(1) > 0 then ROUND(((SUM(DECODE(MR.MRREADOK, 'Y', 1, 0)) / SUM(1)) * 100),
                           2) else 0 end K9, --抄见率
/*                     ROUND(((SUM((CASE
                                   WHEN MR.MRREADOK = 'Y' AND MR.MRBFDAY = 0 THEN
                                    1
                                   ELSE
                                    0
                                 END)) / SUM((CASE
                                                 WHEN MR.MRREADOK = 'Y' THEN
                                                  1
                                                 ELSE
                                                  0
                                               END))) * 100),
                           2)*/0  K10, --正日率
                     0 K11,
/*                     SUM(CASE
                           WHEN MRIFSUBMIT = 'N' AND MRFACE = '01' AND
                                MRCHKFLAG = 'N' THEN
                            1
                           ELSE
                            0
                         END) */0 K12, --波动超标数
/*                     SUM(CASE
                           WHEN MRIFSUBMIT = 'N' AND MRFACE = '03' AND
                                MRCHKFLAG = 'N' THEN
                            1
                           ELSE
                            0
                         END)*/ 0 K13 --0 水量数
                FROM METERREADHIS MR, MV_METER_PROP M
               WHERE MR.MRMONTH = A_MONTH
                 AND MR.MRMID = M.METERNO
               GROUP BY M.AREA, M.WATERTYPE, M.CBY, M.CHARGETYPE, OFAGENT,MILB
              )
       GROUP BY AREA, WATERTYPE, CBY, CHARGETYPE, OFAGENT,MILB;

    UPDATE RPT_SUM_READ_20190401 T
       SET (K3, --应抄
            K4, --实抄
            K5, --空件
            K6, --无法算费数
            K7, --已算费数
            K9, --抄见率
            K10, --正日率
            K11, --稽核错误数
            K12, --波动考核超标数
            K13 --0水量数
            ) =
           (SELECT X1, X2, X3, X4, X5, X6, X7, X8, X9, X10
              FROM RPT_SUM_TEMP TMP
             WHERE U_MONTH = T1
               AND T.AREA = T2
               AND T.WATERTYPE = T3
               AND NVL(T.CBY,'无人员') = NVL(T4,'无人员')   --抄表员为空的时候要考虑更新问题 ralph 20151001
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6
               and  T.t17 = t8)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
    
    --计算排名
/*
M18  is '坐收回收率';
M19   is '走收回收率';
M20   is '总回收率';
M21  is '坐收排名';
M22   is '走收排名';
M23  is '总排名';*/

 UPDATE RPT_SUM_READ_20190401 T
        set (m18, M21) = 
(select  v0, v1 from 
        (select 
          OFAGENT,
           case when nvl(sum(c6), 0) = 0 then 0 else  sum( x21 ) / sum(c6 ) end v0,
          rank() OVER (PARTITION BY 1 ORDER BY  case when nvl(sum(c6), 0) = 0 then 0 else  sum( x21 ) / sum(c6 ) end desc ) v1
          from RPT_SUM_READ_20190401
          where CHAREGETYPE = 'X' and u_month = u_month
          group by OFAGENT)
      where OFAGENT = t.OFAGENT)
where u_month = u_month AND CHAREGETYPE = 'X' 
and rowid in 
        (select min(rowid) from RPT_SUM_READ_20190401
        where u_month = u_month 
        AND CHAREGETYPE = 'X'   AND C13 > 0
        group by ofagent);
commit;
        
        
 UPDATE RPT_SUM_READ_20190401 T
        set (m19, M22) = 
(select  v0, v1 from 
        (select 
          OFAGENT,
           case when nvl(sum(c6), 0) = 0 then 0 else  sum( x21 ) / sum(c6 ) end v0,
          rank() OVER (PARTITION BY 1 ORDER BY  case when nvl(sum(c6), 0) = 0 then 0 else  sum( x21 ) / sum(c6 ) end desc) v1
          from RPT_SUM_READ_20190401
          where CHAREGETYPE = 'M' and u_month = u_month
          group by OFAGENT)
      where OFAGENT = t.OFAGENT)
where u_month = u_month AND CHAREGETYPE = 'M' 
and rowid in 
        (select min(rowid) from RPT_SUM_READ_20190401
        where u_month = u_month 
        AND CHAREGETYPE = 'M'  AND C13 > 0
        group by ofagent);

 UPDATE RPT_SUM_READ_20190401 T
        set (m20, M23) = 
(select  v0, v1 from 
        (select 
          OFAGENT,
           case when nvl(sum(c6), 0) = 0 then 0 else  sum( x21 ) / sum(c6 ) end v0,
          rank() OVER (PARTITION BY 1 ORDER BY  case when nvl(sum(c6), 0) = 0 then 0 else  sum( x21 ) / sum(c6 ) end desc) v1
          from RPT_SUM_READ_20190401
          where  u_month = u_month
          group by OFAGENT)
      where OFAGENT = t.OFAGENT) 
where u_month = u_month  
and rowid in 
        (select min(rowid) from RPT_SUM_READ_20190401
        where u_month = u_month  AND C13 > 0
        group by ofagent);

commit;
  /*
    --自动扣款数
    DELETE RPT_SUM_TEMP;
    COMMIT;
    INSERT INTO RPT_SUM_TEMP
      (T1, T2, T3, T4, T5, T6, X1, X2)
      SELECT A_MONTH U_MONTH,
             M.AREA,
             M.WATERTYPE,
             M.CBY,
             M.CHARGETYPE,
             OFAGENT,
             COUNT(*) K35,
             SUM(P.PSPJE) K36
        FROM PAYMENT P, MV_METER_PROP M
       WHERE P.PTRANS = 'U'
         AND P.PFLAG = 'Y'
         AND P.PREVERSEFLAG = 'N'
         AND PMID = M.METERNO
         AND P.PMONTH = A_MONTH
       GROUP BY M.AREA, M.WATERTYPE, M.CBY, M.CHARGETYPE, OFAGENT;

    UPDATE RPT_SUM_READ_20190401 T
       SET (K35, K36) =
           (SELECT X1, X2
              FROM RPT_SUM_TEMP TMP
             WHERE U_MONTH = T1
               AND T.AREA = T2
               AND T.WATERTYPE = T3
               AND T.CBY = T4
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

    --更新账务信息
    UPDATE RPT_SUM_READ_20190401 T
       SET T.TPDATE  = SYSDATE,
           T.COMPANY =
           (SELECT SMFPID FROM SYSMANAFRAME SY WHERE SY.SMFID = T.OFAGENT),
           T.K9      = ROUND((DECODE(NVL(K4, 0), 0, 1, K4) /
                             DECODE(NVL(K3, 0), 0, 1, K3)),
                             2)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
  */

    --更新产销计划(哈尔滨新的企划表BS_PLAN维度只能到用水大类，报表体系维度是到用水小类)
    UPDATE RPT_SUM_READ_20190401 T
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
            T.SP11
            ) =
           (select
                V1, ----'计划供水量（万方）';
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
             WHERE  P2 = A_MONTH and PTYPE = '21'
               AND D3 = t.cby )
     WHERE
               id in (select min(id) from RPT_SUM_READ_20190401 x where U_MONTH = A_MONTH group by cby  ) --放第一条
               and U_MONTH = A_MONTH;

    --计划完成情况
    UPDATE RPT_SUM_READ_20190401 T
       SET (
            T.SP7,
            T.SP8,
            T.SP9,
            T.SP10,
            T.SP11
            ) =
           (select
                 sum(c1) F1, ----'完成供水量（万方）';
                 sum(c6) F2, ----'完成供水金额（万元）';
                 sum(x32) F3, ----'完成售水量（万方）';
                 sum(x37) F4, ----'完成售水金额（万元）';
                 case when sum(c6) > 0 then  sum(x37) / sum(c6) * 100 else 100 end F5 ----'完成售水率';
                 from RPT_SUM_READ_20190401 t1
             WHERE  U_MONTH = A_MONTH and t1.cby = t.cby )
     WHERE
               id in (select min(id) from RPT_SUM_READ_20190401 x where U_MONTH = A_MONTH group by cby  ) --放第一条
               and U_MONTH = A_MONTH;
    COMMIT;

  END;

/*-----------------------------------------------------------------------------------------------
--  --账务明细统计
用途：
说明：

-----------------------------------------------------------------------------------------------*/

  PROCEDURE 账务明细统计(A_MONTH IN VARCHAR2) AS
  BEGIN

    DELETE RPT_SUM_DETAIL_20190401 T WHERE T.U_MONTH = A_MONTH;
    COMMIT;
    --生成粒度 删除代号维度，增加最小维度 应收事务 以区分基建、补缴、计划抄表应收等
    INSERT INTO RPT_SUM_DETAIL_20190401
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
        x41,--m50
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
             rlpfid , -- WATERTYPE,
             rlyschargetype, --CHARGETYPE,
             rlsmfid, -- M.OFAGENT,
             RL.RLTRANS, --应收事务
             rllb, --M.MILB,
            (case when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH   then 1  --1代表冲往月
                   when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH   then 2  --2代表冲本月 
                    else 0 end ) x41,
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
             SUM(case when MISTATUS in ('29','30' ) then 0 else 1 end )   C16, --按表件数
             SUM(case when MISTATUS in ('29','30' ) then 0 else charge1 end )   C17, --按表金额
             SUM(case when MISTATUS in ('29','30' ) then 1 else 0 end )    C18, --按人件数
             SUM(case when MISTATUS in ('29','30' ) then charge1 else 0 end )  C19, --按人金额
   
            0 C20, --污水费0
            SUM(case when MISTATUS in ('29','30' ) then 0 else WATERUSE end )   C21, --按表水量
             SUM(case when MISTATUS in ('29','30' ) then WATERUSE else 0 end )  C22, --按人水量
             SUM(WSSL) W1 --应收_总污水量
        FROM RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M
       WHERE RL.RLID = RD.RDID
         AND RL.RLMONTH = A_MONTH
         AND RL.RLMID = M.METERNO
         --and rlje<>0 --by 20150106 wangwei   -- modify hb 20150107 取消and rlje<>0 ,因消防水鹤有水量没有金额
         and ( rl.rlje > 0 or (rl.rlsl > 0  and RL.RLPFID not in ('A07')) ) --add hb 20150107 取消rlje<>0 之后担心0水量算费的资料也有一起算。应该过滤故添加此管控
         and RL.rltrans <>'23' -- 营销部收入不计入账务明细报表 20140705 
         AND NVL(RLBADFLAG, 'N') = 'N' --吊坏账 N-正常账
       GROUP BY --M.AREA,
                rlpfid,
                rlyschargetype, 
                rlsmfid,
                RL.RLTRANS,
               rllb,(case when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH   then 1  --1代表冲往月
                   when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH   then 2  --2代表冲本月 
                    else 0 end );   

/*       GROUP BY --M.AREA,
                RD.RDPFID,
                M.CHARGETYPE, 
                OFAGENT,
                RL.RLTRANS,
                M.MILB;
*/
 
    ---补充VIEW_METER_PROP不存在的维度----
    INSERT INTO RPT_SUM_DETAIL_20190401
      (TPDATE,
       U_MONTH,
       OFAGENT, --AREA,
       CHAREGETYPE,
       WATERTYPE,
       T16, T17,m50)
      SELECT SYSDATE,
             A_MONTH, --账务月份
             T5 OFAGENT, --营业所
             --T2      AREA, --区域
             T4 CHARGETYPE, --收费方式
             T3 WATERTYPE, --用水类别
             T6, --应收事务
             T8     miib,
             x41
        FROM RPT_SUM_TEMP
       WHERE T1 = A_MONTH
         AND (T1, --T2,
              T4, T5, T3, T6, T8,x41) NOT IN
             (SELECT U_MONTH, --AREA,
                     CHAREGETYPE,
                     OFAGENT,
                     WATERTYPE,
                     T16, T17,m50
                FROM RPT_SUM_DETAIL_20190401
               WHERE U_MONTH = A_MONTH);
 
    ---补充VIEW_METER_PROP不存在的维度----

    UPDATE RPT_SUM_DETAIL_20190401 T
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
               and  T.t17 = t8
               and t.m50 =x41)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
 --add 20141024 hebang
delete from RPT_SUM_RECLIST t where rlmonth=A_month;
commit;
 insert into rpt_sum_reclist
   (rlid, rlmonth, rltype, rlnote)
  SELECT distinct rl.rlid, A_month U_MONTH, '10', '账务明细统计10-应收'
     FROM RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M
       WHERE RL.RLID = RD.RDID
         AND RL.RLMONTH = A_MONTH
         AND RL.RLMID = M.METERNO
         --and rlje<>0 -- modify hb 20150107 取消and rlje<>0 ,因消防水鹤有水量没有金额
         and ( rl.rlje > 0 or (rl.rlsl > 0  and RL.RLPFID not in ('A07')) ) --add hb 20150107 取消rlje<>0 之后担心0水量算费的资料也有一起算。应该过滤故添加此管控
         and RL.rltrans <>'23' -- 营销部收入不计入账务明细报表 20140705 
         AND NVL(RLBADFLAG, 'N') = 'N'; --吊坏账 N-正常账  
    commit;
  --add 20141024 hebang


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
             rlpfid , -- WATERTYPE,
             rlyschargetype, --CHARGETYPE,
             rlsmfid, -- M.OFAGENT,
             RL.RLTRANS, --应收事务
             rllb, --M.MILB,
              (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1代表冲往月
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end ) x41, -- 20140901添加维度M50  值1代表冲往月 0 代表正常
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
 /*-------------------------------------------------------------------------------------
 --2014/06/01  针对CE038 CE039 水量和污水量不平问题，检查到此，因为下面CASE 语句中，对CHARGE1 金额的判断有误
 -- 据蔡俊平反应，此处早就反应过问题，并做了修改，不知为何又变成原来的错误，是因为有其他考虑吗？
       
             SUM(case when MISTATUS in ('29','30' ) then 0 else ( case when charge1 > 0 then 1 else 0 end ) end )   m11, --按表件数
             SUM(case when MISTATUS in ('29','30' ) then 0 else charge1 end )   m12, --按表金额
             SUM(case when MISTATUS in ('29','30' ) then ( case when charge1 > 0 then 1 else 0 end ) else 0 end )    m13, --按人件数
             SUM(case when MISTATUS in ('29','30' ) then charge1 else 0 end )  m14, --按人金额
            SUM(case when MISTATUS in ('29','30' ) then 0 else WATERUSE end )   m15, --按表水量
             SUM(case when MISTATUS in ('29','30' ) then WATERUSE else 0 end )  m16, --按人水量
             
             SUM(case when MISTATUS in ('29','30' ) then 0 else ( case when charge1 > 0 then 1 else 0 end ) end )   m21, --污水按表件数
             SUM(case when MISTATUS in ('29','30' ) then 0 else charge2 end )   m22, --污水按表金额
             SUM(case when MISTATUS in ('29','30' ) then ( case when charge1 > 0 then 1 else 0 end ) else 0 end )    m23, --污水按人件数
             SUM(case when MISTATUS in ('29','30' ) then charge2 else 0 end )  m24, --污水按人金额
            SUM(case when MISTATUS in ('29','30' ) then 0 else (case when charge2 > 0 then WSSL else 0 end)  end )   m25, --按表污水量
             SUM(case when MISTATUS in ('29','30' ) then (case when charge2 > 0 then WSSL else 0 end) else 0 end )  m26, --按人污水量
-----------------------------------------------------------------------------------------------------------------*/
-- 以上修改为：请注意对CHARGE1 判断的条件！！！！，不希望再次浪费时间进行这样无谓的追踪和修改！！
--BY 20141025 王伟 这里是否应该考虑29,30类别里的补缴数据
             SUM(case when MISTATUS in ('29','30' )  then 0 else ( case when charge1 <> 0 then 1 else 0 end ) end )   m11, --按表件数
             SUM(case when MISTATUS in ('29','30' )  then 0 else charge1 end )   m12, --按表金额
             SUM(case when MISTATUS in ('29','30' )  then ( case when charge1 <> 0 then 1 else 0 end ) else 0 end )    m13, --按人件数
             SUM(case when MISTATUS in ('29','30' )  then charge1 else 0 end )  m14, --按人金额
             SUM(case when MISTATUS in ('29','30' ) then 0 else WATERUSE end )   m15, --按表水量
             SUM(case when MISTATUS in ('29','30' )  then WATERUSE else 0 end )  m16, --按人水量
             
             SUM(case when MISTATUS in ('29','30' )  then 0 else ( case when charge2 <> 0 then 1 else 0 end ) end )   m21, --污水按表件数
             SUM(case when MISTATUS in ('29','30' )  then 0 else charge2 end )   m22, --污水按表金额
             SUM(case when MISTATUS in ('29','30' )  then ( case when charge2 <> 0 then 1 else 0 end ) else 0 end )    m23, --污水按人件数
             SUM(case when MISTATUS in ('29','30' )  then charge2 else 0 end )  m24, --污水按人金额
             SUM(case when MISTATUS in ('29','30' )  then 0 else (case when charge2 <> 0 then WSSL else 0 end)  end )   m25, --按表污水量
             SUM(case when MISTATUS in ('29','30' )  then (case when charge2 <> 0 then WSSL else 0 end) else 0 end )  m26, --按人污水量
-----------------------------------------------------------------------------------------------------------------         
    SUM(WSSL) W4  --总销账_总污水量
        FROM RECLIST              RL, --LIQIZHU 20131010 增加PAYMENT表的关联
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M,
             PAYMENT              P/*，
             (select pid from rpt_sum_pid where u_month = a_month) pp*/
       WHERE RL.RLID = RD.RDID 
         --and p.pid = pp.pid
         AND RL.RLMID = M.METERNO
         AND RL.RLPID = P.PID
         AND P.PMONTH = A_MONTH
         and RL.rltrans <>'23' -- 营销部收入不计入账务明细报表 20140705 
        -- AND RL.RLPAIDFLAG = 'Y'  --销账标志
        -- AND RL.RLPAIDMONTH = A_MONTH --付款月份
       GROUP BY --M.AREA,
                rlpfid,
                rlyschargetype, 
                rlsmfid,
                RL.RLTRANS,
               rllb,
                (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1代表冲往月
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end );         
   
 
  
    ---补充VIEW_METER_PROP不存在的维度----
    INSERT INTO RPT_SUM_DETAIL_20190401
      (TPDATE,
       U_MONTH,
       OFAGENT, -- AREA,
       CHAREGETYPE,
       WATERTYPE,
       T16, T17,m50)
      SELECT SYSDATE,
             A_MONTH, --账务月份
             T5 OFAGENT, --营业所
             -- T2      AREA, --区域
             T4 CHARGETYPE, --收费方式
             T3 WATERTYPE, --用水类别
             T6, --应收事务
              T8     miib,
              x41
        FROM RPT_SUM_TEMP
       WHERE T1 = A_MONTH
         AND (T1, --T2,
              T4, T5, T3, T6, T8,x41) NOT IN
             (SELECT U_MONTH, --AREA,
                     CHAREGETYPE,
                     OFAGENT,
                     WATERTYPE,
                     T16, T17,m50
                FROM RPT_SUM_DETAIL_20190401
               WHERE U_MONTH = A_MONTH);

   
    ---补充VIEW_METER_PROP不存在的维度----
-------------------------------------------------------------------------------------------------
--2014/06/01
--执行到此处时，RPT_SUM_DETAIL_20190401表中的水量和污水量都还是平的！
--- 以下为问题语句
--------------------------------------------------------------------------------------------------
    UPDATE RPT_SUM_DETAIL_20190401 T
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
            
            W4  --总销账_总污水量
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
               and t.m50=x41 )
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
    --add 20141024 hebang
 insert into rpt_sum_reclist
   (rlid, rlmonth, rltype, rlnote)
  SELECT distinct rl.rlid, A_month U_MONTH, '11', '账务明细统计11-总销账'
      FROM RECLIST              RL, --LIQIZHU 20131010 增加PAYMENT表的关联
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M,
             PAYMENT              P/*，
             (select pid from rpt_sum_pid where u_month = a_month) pp*/
       WHERE RL.RLID = RD.RDID 
         --and p.pid = pp.pid
         AND RL.RLMID = M.METERNO
         AND RL.RLPID = P.PID
         AND P.PMONTH = A_MONTH
         and RL.rltrans <>'23' -- 营销部收入不计入账务明细报表 20140705 
        -- AND RL.RLPAIDFLAG = 'Y'  --销账标志
        -- AND RL.RLPAIDMONTH = A_MONTH --付款月份
       ;
                    
    commit;
  --add 20141024 hebang
  
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
       x41,--m50
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
             rlpfid , -- WATERTYPE,
             rlyschargetype, --CHARGETYPE,
             rlsmfid, -- M.OFAGENT,
             RL.RLTRANS, --应收事务
             rllb, --M.MILB,
              (case when pP.PREVERSEFLAG = 'Y' AND pP.PMONTH > pP.PSCRMONTH   then 1  --1代表冲往月
                    when pP.PREVERSEFLAG = 'Y'  AND pP.PMONTH =  pP.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end ) x41, -- 20140901添加维度M50  值1代表冲往月 0 代表正常
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
             SUM(WSSL) W2  --销以往_总污水量
        FROM RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M， 
             PAYMENT pp
       WHERE RL.RLID = RD.RDID and rl.rlpid = pp.pid
         AND RL.RLMID = M.METERNO
         AND RL.RLPAIDFLAG = 'Y'
         --AND RL.RLPAIDMONTH = A_MONTH
         AND PP.PMONTH=A_MONTH
         AND NVL(RL.RLBADFLAG, 'N') = 'N'
        and RL.rltrans <>'23' -- 营销部收入不计入账务明细报表 20140705 
         AND RLMONTH < A_MONTH --以往
       GROUP BY --M.AREA,
                rlpfid,
                rlyschargetype, 
                rlsmfid,
                RL.RLTRANS,
               rllb,
              (case when pP.PREVERSEFLAG = 'Y' AND pP.PMONTH > pP.PSCRMONTH   then 1  --1代表冲往月
                    when pP.PREVERSEFLAG = 'Y'  AND pP.PMONTH =  pP.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end ) ;    

  
    UPDATE RPT_SUM_DETAIL_20190401 T
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
            W2  --销以往_总污水量
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
               and  T.t17 = t8
               and t.m50 =x41 )
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
 
 --add 20141024 hebang
 insert into rpt_sum_reclist
   (rlid, rlmonth, rltype, rlnote)
  SELECT distinct rl.rlid, A_month U_MONTH, '12', '账务明细统计12-销以往'
        FROM RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M， 
             PAYMENT pp
       WHERE RL.RLID = RD.RDID and rl.rlpid = pp.pid
         AND RL.RLMID = M.METERNO
         AND RL.RLPAIDFLAG = 'Y'
         --AND RL.RLPAIDMONTH = A_MONTH
         AND PP.PMONTH=A_MONTH
         AND NVL(RL.RLBADFLAG, 'N') = 'N'
        and RL.rltrans <>'23' -- 营销部收入不计入账务明细报表 20140705 
         AND RLMONTH < A_MONTH --以往 
       ;
                    
    commit;
  --add 20141024 hebang
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
       x41,--m50
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
             rlpfid , -- WATERTYPE,
             rlyschargetype, --CHARGETYPE,
             rlsmfid, -- M.OFAGENT,
             RL.RLTRANS, --应收事务
             rllb, --M.MILB,
            (case when pP.PREVERSEFLAG = 'Y' AND pP.PMONTH > pP.PSCRMONTH   then 1  --1代表冲往月
                    when pP.PREVERSEFLAG = 'Y'  AND pP.PMONTH =  pP.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end )  x41, -- 20140901添加维度M50  值1代表冲往月 0 代表正常
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
             SUM(WSSL) W3  --销当月_总污水量
        FROM RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M， 
        --(select pid from rpt_sum_pid where u_month = a_month) pp
            PAYMENT PP
       WHERE RL.RLID = RD.RDID and rl.rlpid = pp.pid
         AND RL.RLMONTH = A_MONTH
         --AND RL.RLPAIDFLAG = 'Y'
         AND RL.RLMID = M.METERNO
         --AND RL.RLPAIDMONTH = A_MONTH
         AND PP.PMONTH=A_MONTH
         and RL.rltrans <>'23' -- 营销部收入不计入账务明细报表 20140705 
         AND NVL(RL.RLBADFLAG, 'N') = 'N'
       GROUP BY --M.AREA,
                rlpfid,
                rlyschargetype, 
                rlsmfid,
                RL.RLTRANS,
               rllb,
              (case when pP.PREVERSEFLAG = 'Y' AND pP.PMONTH > pP.PSCRMONTH   then 1  --1代表冲往月
                    when pP.PREVERSEFLAG = 'Y'  AND pP.PMONTH =  pP.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end ) ;    
 

  
    UPDATE RPT_SUM_DETAIL_20190401 T
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
            W3  --销当月_总污水量
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
               and  T.t17 = t8
               and t.m50 =x41)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
 --add 20141024 hebang
 insert into rpt_sum_reclist
   (rlid, rlmonth, rltype, rlnote)
  SELECT distinct rl.rlid, A_month U_MONTH, '13', '账务明细统计13-销当月'
        FROM RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M， 
        --(select pid from rpt_sum_pid where u_month = a_month) pp
            PAYMENT PP
       WHERE RL.RLID = RD.RDID and rl.rlpid = pp.pid
         AND RL.RLMONTH = A_MONTH
         --AND RL.RLPAIDFLAG = 'Y'
         AND RL.RLMID = M.METERNO
         --AND RL.RLPAIDMONTH = A_MONTH
         AND PP.PMONTH=A_MONTH
         and RL.rltrans <>'23' -- 营销部收入不计入账务明细报表 20140705 
         AND NVL(RL.RLBADFLAG, 'N') = 'N'  ; 
                    
    commit;
  --add 20141024 hebang
    ---欠当月
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
       x41,--m50
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
             rlpfid , -- WATERTYPE,
             rlyschargetype, --CHARGETYPE,
             rlsmfid, -- M.OFAGENT,
             RL.RLTRANS, --应收事务
             rllb, --M.MILB,
               (case when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH   then 1  --1代表冲往月
                   when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH   then 2  --2代表冲本月 
                    else 0 end ) x41, -- 20140901添加维度M50  值1代表冲往月 0 代表正常
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
             SUM(WSSL) W5  --欠当月_总污水量
        FROM RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M
       WHERE RL.RLID = RD.RDID
         AND RL.RLMID = M.METERNO
         AND RL.RLPAIDFLAG = 'N' --未销账
         AND RL.RLREVERSEFLAG = 'N' --未冲正
         and RL.rltrans <>'23' -- 营销部收入不计入账务明细报表 20140705 
         --and rlje<>0 -- modify hb 20150107 取消and rlje<>0 ,因消防水鹤有水量没有金额
         and ( rl.rlje > 0 or (rl.rlsl > 0  and RL.RLPFID not in ('A07')) ) --add hb 20150107 取消rlje<>0 之后担心0水量算费的资料也有一起算。应该过滤故添加此管控
         AND RLMONTH = A_MONTH
         AND NVL(RL.RLBADFLAG, 'N') = 'N'  --正常账
       GROUP BY --M.AREA,
                rlpfid,
                rlyschargetype, 
                rlsmfid,
                RL.RLTRANS,
               rllb,
             (case when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH   then 1  --1代表冲往月
                   when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH   then 2  --2代表冲本月 
                    else 0 end );    
  
    ---补充VIEW_METER_PROP不存在的维度----
    INSERT INTO RPT_SUM_DETAIL_20190401
      (TPDATE,
       U_MONTH,
       OFAGENT, --AREA,
       CHAREGETYPE,
       WATERTYPE,
       T16, T17,m50)
      SELECT SYSDATE,
             A_MONTH, --账务月份
             T5 OFAGENT, --营业所
             --   T2      AREA, --区域
             T4 CHARGETYPE, --收费方式
             T3 WATERTYPE, --用水类别
             T6, --应收事务
             T8     miib,
             x41
        FROM RPT_SUM_TEMP
       WHERE T1 = A_MONTH
         AND (T1, --T2,
              T4, T5, T3, T6, T8,x41) NOT IN
             (SELECT U_MONTH, --AREA,
                     CHAREGETYPE,
                     OFAGENT,
                     WATERTYPE,
                     T16, T17,m50
                FROM RPT_SUM_DETAIL_20190401
               WHERE U_MONTH = A_MONTH);
 
    ---补充VIEW_METER_PROP不存在的维度----

    UPDATE RPT_SUM_DETAIL_20190401 T
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
            W5  --欠当月_总污水量
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
               and  T.t17 = t8
               and t.m50=x41)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
 --add 20141024 hebang
 insert into rpt_sum_reclist
   (rlid, rlmonth, rltype, rlnote)
  SELECT distinct rl.rlid, A_month U_MONTH, '14', '账务明细统计14-欠当月'
        FROM RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M
       WHERE RL.RLID = RD.RDID
         AND RL.RLMID = M.METERNO
         AND RL.RLPAIDFLAG = 'N' --未销账
         AND RL.RLREVERSEFLAG = 'N' --未冲正
         and RL.rltrans <>'23' -- 营销部收入不计入账务明细报表 20140705 
         --and rlje<>0 -- modify hb 20150107 取消and rlje<>0 ,因消防水鹤有水量没有金额
         and ( rl.rlje > 0 or (rl.rlsl > 0  and RL.RLPFID not in ('A07')) ) --add hb 20150107 取消rlje<>0 之后担心0水量算费的资料也有一起算。应该过滤故添加此管控
         AND RLMONTH = A_MONTH
         AND NVL(RL.RLBADFLAG, 'N') = 'N'  --正常账
      ;    
                    
    commit;
  --add 20141024 hebang
    ---欠以往 --- 非常慢，先放下
/*    DELETE RPT_SUM_TEMP;
    COMMIT;
    INSERT INTO RPT_SUM_TEMP
      (T1,
       --   T2,
       T3,
       T4,
       T5,
       T6, --应收事务
       t8,
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
             --   AREA,
             RD.RDPFID WATERTYPE,
             CHARGETYPE,
             M.OFAGENT,
             RL.RLTRANS, --应收事务
             M.MILB,
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
             SUM(CHARGE5) Q14,
             SUM(CHARGE6) Q15,
             SUM(CHARGE7) Q16,
             SUM(CHARGE8) Q37,
             SUM(CHARGE9) Q38,
             SUM(CHARGE10) Q39,
             0 Q40,
             SUM(WSSL) W6  --欠以往_总污水量
        FROM RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M
       WHERE RL.RLID = RD.RDID
         AND RLMONTH < A_MONTH --以往
         AND RL.RLPAIDFLAG = 'N'
         AND RL.RLREVERSEFLAG = 'N'
         AND RL.RLMID = M.METERNO
         AND NVL(RL.RLBADFLAG, 'N') = 'N'
       GROUP BY --M.AREA,
                RD.RDPFID,
                M.CHARGETYPE,
                OFAGENT,
                RL.RLTRANS,M.MILB;

    UPDATE RPT_SUM_DETAIL_20190401 T
       SET (Q17, --欠费_总水量
            Q18, -- 欠费_阶梯1
            Q19, -- 欠费_阶梯2
            Q20, --欠费_阶梯3
            Q21, -- 欠费_总金额
            Q22, --欠费_污水费
            Q23, --欠费_附加费
            Q24, ---欠费_费用项目3
            Q25, --欠费_费用项目4
            Q26, --   欠费_阶梯1金额
            Q27, --   欠费_阶梯2金额
            Q28, --  欠费_阶梯3金额
            Q29, -- 欠费笔数
            Q30, --预留
            Q31,
            Q32,
            Q37,
            Q38,
            Q39,
            Q40,
            W6  --欠以往_总污水量
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
                  --AND T.AREA = T2
               AND T.WATERTYPE = T3
               AND T.CHAREGETYPE = T4
               AND T.OFAGENT = T5
               AND T.T16 = T6
               and  T.t17 = t8)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;*/

    --单价
    UPDATE RPT_SUM_DETAIL_20190401 T1
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
                      (select s1 from price_prop_sample where WATERTYPE = t2.WATERTYPE) s1,
                    (select s2 from price_prop_sample where WATERTYPE = t2.WATERTYPE) s2,
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
/*    UPDATE RPT_SUM_DETAIL_20190401 T
       SET (L40, --欠费_总水量
            L41, -- 欠费_阶梯1
            L42, -- 欠费_阶梯2
            L43, --欠费_阶梯3
            L44, -- 欠费_总金额
            L45, --欠费_污水费
            L46, --欠费_附加费
            L47, ---欠费_费用项目3
            L48, --欠费_费用项目4
            L49, --   欠费_阶梯1金额
            L50, --   欠费_阶梯2金额
            L51, --  欠费_阶梯3金额
            L52, -- 欠费笔数
            L53, --预留
            L54,
            L55,
            L56,
            L57,
            L58,
            L59,
            W10  --期初_总污水量（欠上月_总污水量）（U_MONTH-1：Q1）
            ) =
           (SELECT Q1, --总欠费_总水量
                   Q2, -- 总欠费_阶梯1
                   Q3, -- 总欠费_阶梯2
                   Q4, --总欠费_阶梯3
                   Q5, -- 总欠费_总金额
                   Q6, --总欠费_污水费
                   Q7, --总欠费_附加费
                   Q8, ---总欠费_费用项目3
                   Q9, --总欠费_费用项目4
                   Q10, --   总欠费_阶梯1金额
                   Q11, --   总欠费_阶梯2金额
                   Q12, --  总欠费_阶梯3金额
                   Q13, -- 总欠费笔数
                   Q14, --预留
                   Q15,
                   Q16,
                   Q37,
                   Q38,
                   Q39,
                   Q40,
                   W5  --欠当月_总污水量
              FROM RPT_SUM_DETAIL_20190401 TMP
             WHERE TMP.U_MONTH =
                   TO_CHAR(ADD_MONTHS(TO_DATE(A_MONTH, 'YYYY.MM'), -1),
                           'YYYY.MM')
                  --AND T.AREA = TMP.AREA
               AND T.WATERTYPE = TMP.WATERTYPE
               AND T.CHAREGETYPE = TMP.CHAREGETYPE
               AND T.OFAGENT = TMP.OFAGENT
               AND T.T16 = TMP.T16
               AND T.T18 = TMP.T18)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
*/
    --本季应收
/*    UPDATE RPT_SUM_DETAIL_20190401 T
       SET (C21, --    本季应收_总水量
            C22, --    本季应收_阶梯1
            C23, --    本季应收_阶梯2
            C24, --    本季应收_阶梯3
            C25, --    本季应收_总金额
            C26, --    本季应收_水费
            C27, --    本季应收_污水费
            C28, --    本季应收_附加费
            C29, --    本季应收_代收费3
            C30, --    本季应收_阶梯1金额
            C31, --    本季应收_阶梯2金额
            C32, --    本季应收_阶梯3金额
            C33, --    本季应收_笔数
            C34, --    本季应收_代收费4
            C35, --    本季应收_代收费5
            C36, --    本季应收_代收费6
            C37, --    "本季""应收代收费7
            C38, --    "本季""应收代收费8
            C39, --    本季应收代收费9
            C40,--    "本季""应收污水费0
            W11  --本季应收_总污水量
            ) =
           (SELECT SUM(C1), --      应收_总水量
                   SUM(C2), --      应收_阶梯1
                   SUM(C3), --      应收_阶梯2
                   SUM(C4), --      应收_阶梯3
                   SUM(C5), --      应收_总金额
                   SUM(C6), --      应收_水费
                   SUM(C7), --      应收_污水费
                   SUM(C8), --      应收_附加费
                   SUM(C9), --      应收_代收费3
                   SUM(C10), --     应收_阶梯1金额
                   SUM(C11), --     应收_阶梯2金额
                   SUM(C12), --     应收_阶梯3金额
                   SUM(C13), --     应收_笔数
                   SUM(C14), --     应收_代收费4
                   SUM(C15), --     应收_代收费5
                   SUM(C16), --     应收_代收费6
                   SUM(C17), --     "应收代收费7
                   SUM(C18), --     "应收代收费8
                   SUM(C19), --     应收代收费9
                   SUM(C20), --     "应收污水费0
                   SUM(W1) --应收_总污水量
              FROM RPT_SUM_DETAIL_20190401 TMP
             WHERE TO_CHAR(TO_DATE(TMP.U_MONTH, 'YYYY.MM'), 'Q') =
                   TO_CHAR(TO_DATE(A_MONTH, 'YYYY.MM'), 'Q')
                  --   AND T.AREA = TMP.AREA
               AND T.WATERTYPE = TMP.WATERTYPE
               AND T.CHAREGETYPE = TMP.CHAREGETYPE
               AND T.OFAGENT = TMP.OFAGENT
               AND T.T16 = TMP.T16)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
  */
    -------------预存抵扣-----------------
    /*
    DELETE RPT_SUM_TEMP;
    COMMIT;
    INSERT INTO RPT_SUM_TEMP
      (T1,
       T2,
       T3,
       T4,
       T5,
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
       X16)
      SELECT A_MONTH U_MONTH,
             AREA,
             WATERTYPE WATERTYPE,
             CHARGETYPE,
             M.OFAGENT,
             SUM(WATERUSE) U1,
             SUM(USE_R1) U2,
             SUM(USE_R2) U3,
             SUM(USE_R3) U4,
             SUM(CHARGETOTAL) U5,
             SUM(CHARGE1) U6,
             SUM(CHARGE2) U7,
             SUM(CHARGE3) U8,
             SUM(CHARGE4) U9,
             SUM(CHARGE_R1) U10,
             SUM(CHARGE_R2) U11,
             SUM(CHARGE_R3) U12,
             SUM(1) U13,
             SUM(CHARGE5) U14,
             SUM(CHARGE6) U15,
             \*SUM(RD.CHARGEZNJ)*\ 0 U17
        FROM PAYMENT              PY,
             RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M
       WHERE RLID = RDID
         AND PY.PID = RL.RLPID
         AND PY.PMID = M.METERNO
         AND (PY.PTRANS = 'U')
         AND PY.PMONTH = A_MONTH
       GROUP BY M.AREA, M.WATERTYPE, M.CHARGETYPE, OFAGENT;

    UPDATE RPT_SUM_DETAIL_20190401 T
       SET (U1, U2, U3, U4, U5, U6, U7, U8, U9, U10, U11, U12, U13, U14, U15, U17)
       = (SELECT X1,
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
                X16
            FROM RPT_SUM_TEMP TMP
            WHERE U_MONTH = T1
            AND T.AREA = T2
            AND T.WATERTYPE = T3
            AND T.CHAREGETYPE = T4
            AND T.OFAGENT = T5)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;*/

   /* --本季总销账
    UPDATE RPT_SUM_DETAIL_20190401 T
       SET (X64, --   本季总销账_总水量
            X65, --   本季总销账_阶梯1
            X66, --   本季总销账_阶梯2
            X67, --   本季总销账_阶梯3
            X68, --   本季总销账_总金额
            X69, --   本季总销账_水费
            X70, --   本季总销账_污水费
            X71, --   本季总销账_附加费
            X72, --   本季总销账_代收费3
            X73, --   本季总销账_阶梯1金额
            X74, --   本季总销账_阶梯2金额
            X75, --   本季总销账_阶梯3金额
            X76, --   本季总销账_笔数
            X77, --   本季总销账_代收费4
            X78, --   本季总销账_代收费5
            X79, --   本季总销账_代收费6
            X80, --   本季总销账_滞纳金
            X81, --   "本季"""总销账代收费7
            X82, --   "本季"""总销账代收费8
            X83, --   "本季"""总销账代收费9
            X84, --    本季总销账污水费0
            W12  --本季总销账_总污水量
            ) =
           (SELECT SUM(X32), --   总销账_总水量
                   SUM(X33), --   总销账_阶梯1
                   SUM(X34), --   总销账_阶梯2
                   SUM(X35), --   总销账_阶梯3
                   SUM(X36), --   总销账_总金额
                   SUM(X37), --   总销账_水费
                   SUM(X38), --   总销账_污水费
                   SUM(X39), --   总销账_附加费
                   SUM(X40), --   总销账_代收费3
                   SUM(X41), --   总销账_阶梯1金额
                   SUM(X42), --   总销账_阶梯2金额
                   SUM(X43), --   总销账_阶梯3金额
                   SUM(X44), --   总销账_笔数
                   SUM(X45), --   总销账_代收费4
                   SUM(X46), --   总销账_代收费5
                   SUM(X47), --   总销账_代收费6
                   SUM(X50), --   总销账滞纳金
                   SUM(X60), --   "总销账代收费7
                   SUM(X61), --   "总销账代收费8
                   SUM(X62), --   "总销账代收费9
                   SUM(X63), --    总销账污水费0
                   SUM(W4) -- 总销账_总污水量
              FROM RPT_SUM_DETAIL_20190401 TMP
             WHERE TO_CHAR(TO_DATE(TMP.U_MONTH, 'YYYY.MM'), 'Q') =
                   TO_CHAR(TO_DATE(A_MONTH, 'YYYY.MM'), 'Q')
                  -- AND T.AREA = TMP.AREA
               AND T.WATERTYPE = TMP.WATERTYPE
               AND T.CHAREGETYPE = TMP.CHAREGETYPE
               AND T.OFAGENT = TMP.OFAGENT
               AND T.T16 = TMP.T16)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
    --更新账务信息
    UPDATE RPT_SUM_DETAIL_20190401 T
       SET T.TPDATE  = SYSDATE,
           T.COMPANY =
           (SELECT SMFPID FROM SYSMANAFRAME SY WHERE SY.SMFID = T.OFAGENT),
           T.K9      = ROUND((DECODE(NVL(K4, 0), 0, 1, K4) /
                             DECODE(NVL(K3, 0), 0, 1, K3)),
                             2)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;*/
---------------------------------------------------------------------------
 ----收免
/*-2014.06.04 修改收免数据生成条件---------------------------------------------------
--一下为原方法 start      
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
       X1,
       X2,
       X3,
       X4,
       X5,
       X6
       )
      SELECT  A_MONTH U_MONTH,
             --AREA,
             rlpfid , -- WATERTYPE,
             rlyschargetype, --CHARGETYPE,
             rlsmfid, -- M.OFAGENT,
             RL.RLTRANS, --应收事务
             rllb, --M.MILB,
          SUM (CASE WHEN RDPIID = '01'  THEN 1 ELSE 0 END)  dis_c,     --  收免件数
         SUM (CASE WHEN RDPIID = '01'  THEN RDadjsl  ELSE 0 END) dis_u1,--  收免水量
         SUM (CASE WHEN RDPIID = '01' THEN RDadjsl * rddj  ELSE 0 END) dis_m1,  --  收免水费
         SUM (CASE WHEN RDPIID = '02'  THEN RDadjsl  ELSE 0 END) dis_u2,       --  收免污水量
          SUM (CASE WHEN RDPIID = '02'  THEN RDadjsl * rddj  ELSE 0 END) dis_m2, --  收免污水费
         SUM ( RDadjsl * rddj  )  dis_m                   --  收免金额
FROM RECLIST RL,  MV_METER_PROP M, recdetail rd
       WHERE RL.RLID = RD.RDID
         AND RL.RLMONTH = A_MONTH
         AND RL.RLMID = M.METERNO
         and  rl.rlsl <>  rl.rlreadsl  --应收水量<>抄见水量
         AND NVL(RLBADFLAG, 'N') = 'N'  --正常账
       GROUP BY
                rlpfid,
                rlyschargetype, 
                rlsmfid,
                RL.RLTRANS,
               rllb;  
--以上为原方法 end */

/*------------------------------------------------------
--以下为新方法 start 20140604 by 郑仕华-----------------*/
/*    DELETE RPT_SUM_TEMP;
    COMMIT;
    INSERT INTO RPT_SUM_TEMP
      (T1,
       -- T2,
       T3,
       T4,
       T5,
       T6, --应收事务
       t8,
       X1,
       X2,
       X3,
       X4,
       X5,
       X6
       )
      SELECT  A_MONTH U_MONTH,
             --AREA,
             rlpfid , -- WATERTYPE,
             rlyschargetype, --CHARGETYPE,
             rlsmfid, -- M.OFAGENT,
             RL.RLTRANS, --应收事务
             rllb, --M.MILB,
          SUM (CASE WHEN RDPIID = '01'  THEN 1 ELSE 0 END)  dis_c,     --  收免件数
         SUM (CASE WHEN RDPIID = '01'  THEN RDadjsl  ELSE 0 END) dis_u1,--  收免水量
         SUM (CASE WHEN RDPIID = '01' THEN RDadjsl * rddj  ELSE 0 END) dis_m1,  --  收免水费
         SUM (CASE WHEN RDPIID = '02'  THEN RDadjsl  ELSE 0 END) dis_u2,       --  收免污水量
          SUM (CASE WHEN RDPIID = '02'  THEN RDadjsl * rddj  ELSE 0 END) dis_m2, --  收免污水费
         SUM ( RDadjsl * rddj  )  dis_m                   --  收免金额

FROM RECLIST RL, METERINFO M, recdetail rd
         WHERE RL.RLID = RD.RDID
           AND RL.RLMONTH = A_MONTH
           AND RL.RLMID = M.miid
          and M.MIYL2='1'
          and (RL.RLADDSL<>0 OR RL.rlsl <> RL.RLREADSL)           
          AND NVL(RLBADFLAG, 'N') = 'N'
       GROUP BY
                rlpfid,
                rlyschargetype, 
                rlsmfid,
                RL.RLTRANS,
               rllb; 
               
--以上为新方法 end 20140604 by 郑仕华-----------------
       commit;
\*
    UPDATE RPT_SUM_DETAIL_20190401 T
       SET (T20, --大项目改为'补当'
            T19,-- 科目改为'收免'
            M1, --应收收免件数
            M2, -- 应收收免水量
            M4, --应收收免水费
            M5, -- 应收收免污水费
            M6, --应收收免污水量
            M3 -- 应收收免金额
            ) =
           (SELECT '补当',
                   '收免',
                   X1,
                   X2 * -1,
                   X3 * -1,
                   X4 * -1,
                   X5 * -1,
                   X6 * -1
              FROM RPT_SUM_TEMP TMP
             WHERE U_MONTH = T1
                  --AND T.AREA = T2
               AND T.WATERTYPE = T3
               AND T.CHAREGETYPE = T4
               AND T.OFAGENT = T5
               AND T.T16 = T6
               and  T.t17 = t8)
     WHERE T.U_MONTH = A_MONTH;*\
     --修改 20140628   以上为之前语法
    UPDATE RPT_SUM_DETAIL_20190401 T
       SET (T20, --大项目改为'补当'
            T19,-- 科目改为'收免'
            M1, --应收收免件数
            M2, -- 应收收免水量
            M4, --应收收免水费
            M5, -- 应收收免污水费
            M6, --应收收免污水量
            M3 -- 应收收免金额
            ) =
           (SELECT '补当',
                   '收免',
                   X1,
                   X2 * -1,
                   X3 * -1,
                   X4 * -1,
                   X5 * -1,
                   X6 * -1
              FROM RPT_SUM_TEMP TMP
             WHERE U_MONTH = T1
                  --AND T.AREA = T2
               AND T.WATERTYPE = T3
               AND T.CHAREGETYPE = T4
               AND T.OFAGENT = T5
               AND T.T16 = T6
               and  T.t17 = t8)
     WHERE T.U_MONTH = A_MONTH and 
         exists ( select 'a'  FROM RPT_SUM_TEMP TMP
             WHERE U_MONTH = T1
                  --AND T.AREA = T2
               AND T.WATERTYPE = T3
               AND T.CHAREGETYPE = T4
               AND T.OFAGENT = T5
               AND T.T16 = T6
               and  T.t17 = t8  )  ;
    COMMIT;*/
    
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
       x41,--m50
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
       x20
       )
      SELECT  A_MONTH U_MONTH,
             --AREA,
             rlpfid , -- WATERTYPE,
             rlyschargetype, --CHARGETYPE,
             rlsmfid, -- M.OFAGENT,
             RL.RLTRANS, --应收事务
             rllb, --M.MILB,
               (case when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH   then 1  --1代表冲往月
                   when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH   then 2  --2代表冲本月 
                    else 0 end ) x41, -- 20140901添加维度M50  值1代表冲往月 0 代表正常
          SUM (CASE WHEN RDPIID = '01'  THEN  ( case when abs(RLADDSL) > 0 then 1 else 0  end )  ELSE 0 END)  dis_c,     --  收免件数
          SUM (CASE WHEN RDPIID = '01'  THEN  abs(RLADDSL)   ELSE 0 END) dis_u1,--  收免水量 =抄表水量-应收水量
          SUM (CASE WHEN RDPIID = '01' THEN   round(abs(RLADDSL * rddj),2) ELSE 0 END) dis_m1,  --  收免水费
          SUM (CASE WHEN RDPIID = '02'  THEN abs(RLADDSL)  ELSE 0 END) dis_u2,       --  收免污水量=抄表水量-应收水量
          SUM (CASE WHEN RDPIID = '02'  THEN  round(abs(RLADDSL * rddj),2)  ELSE 0 END) dis_m2, --  收免污水费
          sum(round(abs(RLADDSL * rddj),2) )  dis_m ,                  --  收免金额
          SUM (CASE WHEN RDPIID = '01'  THEN ( case when M.MISTATUS in ('29','30' ) then 0 else  abs(RLADDSL) end )  ELSE 0 END)  X7, --按表水量
          SUM (CASE WHEN RDPIID = '01'  THEN ( case when M.MISTATUS in ('29','30' ) then  abs(RLADDSL) else 0 end )  ELSE 0 END)  X8, --按人水量
          SUM (CASE WHEN RDPIID = '01'  THEN ( case when M.MISTATUS in ('29','30' ) then 0 else  ( case when  abs(RLADDSL) > 0 then 1 else 0  end )  end )  ELSE 0 END)  X9, --按表件数
          SUM (CASE WHEN RDPIID = '01'  THEN ( case when M.MISTATUS in ('29','30' ) then  ( case when  abs(RLADDSL)> 0 then 1 else 0  end )  else 0 end )  ELSE 0 END)  X10, --按人件数 
          SUM (CASE WHEN RDPIID = '02'  THEN ( case when M.MISTATUS in ('29','30' ) then 0 else  abs(RLADDSL) end )  ELSE 0 END)  X17, --按表污水量
          SUM (CASE WHEN RDPIID = '02'  THEN ( case when M.MISTATUS in ('29','30' ) then  abs(RLADDSL) else 0 end )  ELSE 0 END)  X18, --按人污水量
          SUM (CASE WHEN RDPIID = '02'  THEN ( case when M.MISTATUS in ('29','30' ) then 0 else ( case when  abs(RLADDSL) > 0 then 1 else 0  end ) end )  ELSE 0 END)  X19, --按表污水量件数
          SUM (CASE WHEN RDPIID = '02'  THEN ( case when M.MISTATUS in ('29','30' ) then ( case when abs(RLADDSL) > 0 then 1 else 0  end ) else 0 end )  ELSE 0 END)  X20 --按人污水量件数 
          
/*          SUM (CASE WHEN RDPIID = '01'  THEN  ( case when abs(RDADJSL) > 0 then 1 else 0  end )  ELSE 0 END)  dis_c,     --  收免件数
          SUM (CASE WHEN RDPIID = '01'  THEN  abs(RDADJSL)   ELSE 0 END) dis_u1,--  收免水量 =抄表水量-应收水量
          SUM (CASE WHEN RDPIID = '01' THEN   round(abs(RDADJSL * rddj),2) ELSE 0 END) dis_m1,  --  收免水费
          SUM (CASE WHEN RDPIID = '02'  THEN abs(RDADJSL)  ELSE 0 END) dis_u2,       --  收免污水量=抄表水量-应收水量
          SUM (CASE WHEN RDPIID = '02'  THEN  round(abs(RDADJSL * rddj),2)  ELSE 0 END) dis_m2, --  收免污水费
          sum(round(abs(RDADJSL * rddj),2) )  dis_m ,                  --  收免金额
          SUM (CASE WHEN RDPIID = '01'  THEN ( case when M.MISTATUS in ('29','30' ) then 0 else  abs(RDADJSL) end )  ELSE 0 END)  X7, --按表水量
          SUM (CASE WHEN RDPIID = '01'  THEN ( case when M.MISTATUS in ('29','30' ) then  abs(RDADJSL) else 0 end )  ELSE 0 END)  X8, --按人水量
          SUM (CASE WHEN RDPIID = '01'  THEN ( case when M.MISTATUS in ('29','30' ) then 0 else  ( case when  abs(RDADJSL) > 0 then 1 else 0  end )  end )  ELSE 0 END)  X9, --按表件数
          SUM (CASE WHEN RDPIID = '01'  THEN ( case when M.MISTATUS in ('29','30' ) then  ( case when  abs(RDADJSL)> 0 then 1 else 0  end )  else 0 end )  ELSE 0 END)  X10, --按人件数 
          SUM (CASE WHEN RDPIID = '02'  THEN ( case when M.MISTATUS in ('29','30' ) then 0 else  abs(RDADJSL) end )  ELSE 0 END)  X17, --按表污水量
          SUM (CASE WHEN RDPIID = '02'  THEN ( case when M.MISTATUS in ('29','30' ) then  abs(RDADJSL) else 0 end )  ELSE 0 END)  X18, --按人污水量
          SUM (CASE WHEN RDPIID = '02'  THEN ( case when M.MISTATUS in ('29','30' ) then 0 else ( case when  abs(RDADJSL) > 0 then 1 else 0  end ) end )  ELSE 0 END)  X19, --按表污水量件数
          SUM (CASE WHEN RDPIID = '02'  THEN ( case when M.MISTATUS in ('29','30' ) then ( case when abs(RDADJSL) > 0 then 1 else 0  end ) else 0 end )  ELSE 0 END)  X20 --按人污水量件数*/ 
FROM RECLIST RL, METERINFO M, recdetail rd
         WHERE RL.RLID = RD.RDID
           AND RL.RLMONTH = A_MONTH
           AND RL.RLMID = M.miid
           and RL.rltrans <>'23' -- 营销部收入不计入账务明细报表 20140705 
          and M.MIYL2='1'
         -- and rlje<>0 -- modify hb 20150107 取消and rlje<>0 ,因消防水鹤有水量没有金额
         and ( rl.rlje > 0 or (rl.rlsl > 0  and RL.RLPFID not in ('A07')) ) --add hb 20150107 取消rlje<>0 之后担心0水量算费的资料也有一起算。应该过滤故添加此管控
         -- and (RL.RLADDSL<>0 OR RL.rlsl <> RL.RLREADSL)   
          and  RL.RLADDSL<>0        
          AND NVL(RLBADFLAG, 'N') = 'N'
       GROUP BY
                rlpfid,
                rlyschargetype, 
                rlsmfid,
                RL.RLTRANS,
               rllb,
                  (case when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH   then 1  --1代表冲往月
                   when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH   then 2  --2代表冲本月 
                    else 0 end ) ; 
   --modify 贺帮 20140701 因哈尔滨减免水量栏位RDadjsl全为0 故上述抓取需调整，end 
               
    

  
/*
    UPDATE RPT_SUM_DETAIL_20190401 T
       SET (T20, --大项目改为'补当'
            T19,-- 科目改为'收免'
            M1, --应收收免件数
            M2, -- 应收收免水量
            M4, --应收收免水费
            M5, -- 应收收免污水费
            M6, --应收收免污水量
            M3 -- 应收收免金额
            ) =
           (SELECT '补当',
                   '收免',
                   X1,
                   X2 * -1,
                   X3 * -1,
                   X4 * -1,
                   X5 * -1,
                   X6 * -1
              FROM RPT_SUM_TEMP TMP
             WHERE U_MONTH = T1
                  --AND T.AREA = T2
               AND T.WATERTYPE = T3
               AND T.CHAREGETYPE = T4
               AND T.OFAGENT = T5
               AND T.T16 = T6
               and  T.t17 = t8)
     WHERE T.U_MONTH = A_MONTH;*/
     --修改 20140628   以上为之前语法
    UPDATE RPT_SUM_DETAIL_20190401 T
       SET (T20, --大项目改为'补当'
            T19,-- 科目改为'收免'
            M1, --应收收免件数
            M2, -- 应收收免水量
            M4, --应收收免水费
            M5, -- 应收收免污水量
            M6, --应收收免污水水费
            M3, -- 应收收免金额
            M7, --按表收免水量
            M8,  --按人收免水量
            M9,--按表件数
            M10, --按人件数
            m17,m18,m19,m20
            ) =
           (SELECT '补当',
                   '收免',
                   X1,
                   X2  ,
                   X3  ,
                   X4  ,
                   X5 ,
                   X6  ,
                   X7  ,
                   X8,
                   X9,
                   X10,x17,x18,x19,x20 
              FROM RPT_SUM_TEMP TMP
             WHERE U_MONTH = T1
                  --AND T.AREA = T2
               AND T.WATERTYPE = T3
               AND T.CHAREGETYPE = T4
               AND T.OFAGENT = T5
               AND T.T16 = T6
               and  T.t17 = t8
                and t.m50= x41)
     WHERE T.U_MONTH = A_MONTH and 
         exists ( select 'a'  FROM RPT_SUM_TEMP TMP
             WHERE U_MONTH = T1
                  --AND T.AREA = T2
               AND T.WATERTYPE = T3
               AND T.CHAREGETYPE = T4
               AND T.OFAGENT = T5
               AND T.T16 = T6
               and  T.t17 = t8 
               and t.m50 =x41 )  ;
    COMMIT;
           
       --add 20141024 hebang
 insert into rpt_sum_reclist
   (rlid, rlmonth, rltype, rlnote)
  SELECT distinct rl.rlid, A_month U_MONTH, '15', '账务明细统计15-收免'
    FROM RECLIST RL, METERINFO M, recdetail rd
             WHERE RL.RLID = RD.RDID
               AND RL.RLMONTH = A_MONTH
               AND RL.RLMID = M.miid
               and RL.rltrans <>'23' -- 营销部收入不计入账务明细报表 20140705 
              and M.MIYL2='1'
             -- and rlje<>0 -- modify hb 20150107 取消and rlje<>0 ,因消防水鹤有水量没有金额
         and ( rl.rlje > 0 or (rl.rlsl > 0  and RL.RLPFID not in ('A07')) ) --add hb 20150107 取消rlje<>0 之后担心0水量算费的资料也有一起算。应该过滤故添加此管控
             -- and (RL.RLADDSL<>0 OR RL.rlsl <> RL.RLREADSL)   
              and  RL.RLADDSL<>0        
              AND NVL(RLBADFLAG, 'N') = 'N' ; 
                    
    commit;
  --add 20141024 hebang
----------------------------------------------------------------------------
--- 更新哈尔滨科目
/*----------20140604去掉，因为收免的定义和此有误
update RPT_SUM_DETAIL_20190401
set t20 = '补当', t19 = '收免' where T16 in ('29', '30')
and  U_MONTH = A_MONTH;
------------------------------------------------------*/
update RPT_SUM_DETAIL_20190401
set t20 = '补当', t19 = '基建' where T16 in ('u','v')
and  U_MONTH = A_MONTH;
update RPT_SUM_DETAIL_20190401
set t20 = '补当', t19 = '补缴' where T16 in ('13')
and  U_MONTH = A_MONTH;
update RPT_SUM_DETAIL_20190401
set t20 = '补当', t19 = '稽查' where T16 in ('14')
and  U_MONTH = A_MONTH;
update RPT_SUM_DETAIL_20190401
set t20 = '补当', t19 = '稽查' where T16 in ('21')
and  U_MONTH = A_MONTH;
update RPT_SUM_DETAIL_20190401
set t20 = '补当', t19 = '呆账' where T16 in ('D')
and  U_MONTH = A_MONTH;
/*update RPT_SUM_DETAIL_20190401
set t20 = '补当', t19 = '营销收入' where T16 in ('23')
and  U_MONTH = A_MONTH;*/
commit;


update RPT_SUM_DETAIL_20190401 set sp21 = 1
     WHERE
               id in (select min(id) from RPT_SUM_DETAIL_20190401 x where   U_MONTH = a_month
               group by ofagent  ) --放第一条 营业所
               and U_MONTH = a_month;
    COMMIT;
    
    UPDATE RPT_SUM_DETAIL_20190401 T
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
            T.SP11
            ) =
           (select
                V1, ----'计划供水量（万方）';
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
             WHERE  P2 = a_month and PTYPE = '11'
               AND D1 = t.ofagent)
     WHERE sp21 = 1
               and U_MONTH = a_month;
    COMMIT;
    
    --计划完成情况
    UPDATE RPT_SUM_DETAIL_20190401 T
       SET (
            T.SP7,
            T.SP8,
            T.SP9,
            T.SP10,
            T.SP11
            ) =
           (select
                 sum(c1) F1, ----'完成供水量（万方）';
                 sum(c6) F2, ----'完成供水金额（万元）';
                 sum(x32) F3, ----'完成售水量（万方）';
                 sum(x37) F4, ----'完成售水金额（万元）';
                 case when sum(c6) > 0 then  sum(x37) / sum(c6) * 100 else 0 end F5 ----'完成售水率';
                 from RPT_SUM_DETAIL_20190401 t1
             WHERE  U_MONTH = a_month and t1.ofagent = t.ofagent  )
     WHERE
               sp21 = 1
               and U_MONTH = a_month;
    COMMIT;


/*
    --更新产销计划
    --更新产销计划(哈尔滨新的企划表BS_PLAN维度只能到用水大类，报表体系维度是到用水小类)
    UPDATE RPT_SUM_DETAIL_20190401 T
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
            T.SP11
            ) =
           (select
                V1, ----'计划供水量（万方）';
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
             WHERE  P2 = A_MONTH and PTYPE = '11'
               AND D1 = t.ofagent
               and  WATERTYPE_B = d2)
     WHERE
               id in (select min(id) from RPT_SUM_DETAIL_20190401 x where   U_MONTH = A_MONTH
               group by ofagent, WATERTYPE_B  ) --放第一条
               and U_MONTH = A_MONTH;
    COMMIT;

    --计划完成情况
    UPDATE RPT_SUM_DETAIL_20190401 T
       SET (
            T.SP7,
            T.SP8,
            T.SP9,
            T.SP10,
            T.SP11
            ) =
           (select
                 sum(c1) F1, ----'完成供水量（万方）';
                 sum(c6) F2, ----'完成供水金额（万元）';
                 sum(x32) F3, ----'完成售水量（万方）';
                 sum(x37) F4, ----'完成售水金额（万元）';
                 case when sum(c6) > 0 then  sum(x37) / sum(c6) * 100 else 100 end F5 ----'完成售水率';
                 from RPT_SUM_DETAIL_20190401 t1
             WHERE  U_MONTH = A_MONTH and t1.ofagent = t.ofagent and t1.WATERTYPE_B = t.WATERTYPE_B )
     WHERE
               id in (select min(id) from RPT_SUM_DETAIL_20190401 x where   U_MONTH = A_MONTH
               group by ofagent, WATERTYPE_B  ) --放第一条
               and U_MONTH = A_MONTH;
    COMMIT;*/

  END;

  --收费统计
  PROCEDURE 收费统计(A_MONTH IN VARCHAR2) AS
  BEGIN
    DELETE RPT_SUM_CHARGE T WHERE T.U_MONTH = A_MONTH;
    COMMIT;
    --生成粒度
    INSERT INTO RPT_SUM_CHARGE
      (TPDATE,
       U_MONTH,
       OFAGENT,
       CHAREGEITEM,
       CHAREGETYPE,
       WATERTYPE,
       CHARGE_CLIENT,
         sfy,
       t17,
       M50)
      SELECT SYSDATE,
             A_MONTH,
             M.OFAGENT,
             PPAYWAY,
             CHARGETYPE,
             WATERTYPE, --用水类别
             PPOSITION,
             nvl(PPAYEE, '00000') PPAYEE,
             m.MILB,
             0 M50
        FROM PAYMENT P, MV_METER_PROP M
       WHERE P.PMONTH = A_MONTH
         AND P.PMID = M.METERNO
         AND P.PTRANS<>'O'  --营销部收入单独统计
       GROUP BY PPAYWAY, PPOSITION, PPAYEE, M.OFAGENT, M.CHARGETYPE,M.WATERTYPE, m.MILB,0;
    COMMIT;

    --========删除临时表信息=============
    DELETE RPT_SUM_TEMP;
    COMMIT;

    --单价
    UPDATE RPT_SUM_CHARGE T1
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
                   s1, 
                   s2,
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
                   T2.P16 --污水费3
              FROM PRICE_PROP T2
             WHERE T2.WATERTYPE = T1.WATERTYPE)
     WHERE U_MONTH = A_MONTH;
    COMMIT;

    ------总销账
    DELETE RPT_SUM_TEMP;
    COMMIT;
    INSERT INTO RPT_SUM_TEMP
      (T1,
       T2,
       T3,
       T4,
       T5,
       T6,
       T7,
       t8,
       x41,--m50
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
       
       X21,
       X22,
       X23,
       X24,
       
       X40 --污水量
       )
      SELECT A_MONTH U_MONTH,
             PPAYWAY,
             PPOSITION,
             nvl(PPAYEE, '00000') sfy,
              case when (rl.rltrans in ('v', 'u', '13', '14','21','23') 
                     or rl.rlscrrltrans in ('v', 'u', '13', '14','21','23'))
              then '补当' else M.CHARGETYPE end   CHARGETYPE,
             M.OFAGENT,
             M.WATERTYPE,
             m.MILB,
               (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1代表冲往月
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end ) x41, -- 20140901添加维度M50  值1代表冲往月 0 代表正常
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
             sum(case when rl.rltrans='u' or rl.rlscrrltrans='u' then CHARGE1 else 0 end ) x21, --基建水费
             sum(case when rl.rltrans='v' or rl.rlscrrltrans='v' then CHARGE2 else 0 end ) x22, --基建污水费
             sum(case when rl.rltrans='13' or rl.rlscrrltrans='13' then CHARGE1 else 0 end ) x23, --补缴水费
             sum(case when rl.rltrans='13' or rl.rlscrrltrans='13' then CHARGE2 else 0 end ) x24, --补缴污水费             
             0 X50,
             SUM(WSSL) W4  --总销账_总污水量
        FROM RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M,
             PAYMENT              P， 
             (select pid from rpt_sum_pid where u_month = a_month) pp
       WHERE RL.RLID = RD.RDID and p.pid = pp.pid
         AND RL.RLMID = M.METERNO
         AND RL.RLPID = P.PID
         AND P.PTRANS<>'O'  --营销部收入单独统计
         AND P.PMONTH = A_MONTH
         AND RL.RLPAIDFLAG = 'Y'
         AND RL.RLPAIDMONTH = A_MONTH
       GROUP BY PPAYWAY, PPOSITION, nvl(PPAYEE, '00000'), 
         case when (rl.rltrans in ('v', 'u', '13', '14','21','23' ) 
                    or rl.rlscrrltrans in ('v', 'u', '13', '14','21','23'))
              then '补当' else M.CHARGETYPE end , M.OFAGENT,
        m.WATERTYPE ,   m.MILB,      (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1代表冲往月
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end )   ;

  
    ---补充VIEW_METER_PROP不存在的维度----
    INSERT INTO RPT_SUM_CHARGE
      (TPDATE,
       U_MONTH,
       CHAREGEITEM,
       CHARGE_CLIENT,
       SFY,
       CHAREGETYPE,
       OFAGENT,
       WATERTYPE,
       t17,m50)
      SELECT SYSDATE,
             A_MONTH, --账务月份
             T2      CHAREGEITEM, --缴费方式
             T3      CHARGE_CLIENT, --区域
             T4      SFY, --抄表员
             T5      CHARGETYPE, --收费方式
             T6      OFAGENT, --营业所
             T7      WATERTYPE,
             t8 ,
             x41
        FROM RPT_SUM_TEMP
       WHERE T1 = A_MONTH
         AND (T1, T2, T3, T4, T5, T6,T7, t8,x41) NOT IN
             (SELECT U_MONTH,
                     CHAREGEITEM,
                     CHARGE_CLIENT,
                     SFY,
                     CHAREGETYPE,
                     OFAGENT,
                     WATERTYPE,
                     t17,
                     m50
                FROM RPT_SUM_CHARGE
               WHERE U_MONTH = A_MONTH);
  --  COMMIT;
    ---补充VIEW_METER_PROP不存在的维度----

    UPDATE RPT_SUM_CHARGE T
       SET (X32, --总销账_总水量
            X33, -- 总销账_阶梯1
            X34, -- 总销账_阶梯2
            X35, --总销账_阶梯3
            X36, -- 总销账_总金额
            X37, --总销账_污水费
            X38, --总销账_附加费
            X39, ---总销账_费用项目3
            X40, --总销账_费用项目4
            X41, --   总销账_阶梯1金额
            X42, --   总销账_阶梯2金额
            X43, --  总销账_阶梯3金额
            X44, -- 总销账笔数
            X45, --预留
            X46,
            X47,
            X50,
            X60, --  is '基建水费';
            X61, --  is '基建污水费';
            X62, --  is '补缴水费';
            X63, --  is '补缴污水费';
            W4  --总销账_总污水量
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
       X21,
       X22,
       X23,
       X24,
                   
                   X40
              FROM RPT_SUM_TEMP TMP
             WHERE A_MONTH = T1
               AND T.CHAREGEITEM = T2
               AND T.CHARGE_CLIENT = T3
               AND T.SFY = T4
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6
               AND T.WATERTYPE = T7
               and  T.t17 = t8
               and t.m50 =x41)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
 
       --add 20141024 hebang
 insert into rpt_sum_payment
   (pid, pymonth, pytype, pynote)
  SELECT distinct p.PID, A_month U_MONTH, '01', '收费统计01-总销账'
         FROM RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M,
             PAYMENT              P， 
             (select pid from rpt_sum_pid where u_month = a_month) pp
       WHERE RL.RLID = RD.RDID and p.pid = pp.pid
         AND RL.RLMID = M.METERNO
         AND RL.RLPID = P.PID
         AND P.PTRANS<>'O'  --营销部收入单独统计
         AND P.PMONTH = A_MONTH
         AND RL.RLPAIDFLAG = 'Y'
         AND RL.RLPAIDMONTH = A_MONTH  ; 
    commit;
  --add 20141024 hebang
    ----------------哈尔滨 ----------------
/*    大厅坐收 （不含u, 13, 14）
x64 大厅坐收笔数
x65 大厅坐收水量
x66 大厅坐收水费
x67 大厅坐收污水量
x68 大厅坐收污水费
x69 大厅坐收总金额
x70 大厅坐实收总金额
*/
    ------大厅坐收
    DELETE RPT_SUM_TEMP;
    COMMIT;
    INSERT INTO RPT_SUM_TEMP
      (T1,
       T2,
       T3,
       T4,
       T5,
       T6,
       T7,
       t8,
       x41,
       X1,
       X2,
       X3,
       X4,
       X5,
       X6,
       X7
       )--下面的语句有问题
      /*SELECT A_month U_MONTH,
             PPAYWAY,
             PPOSITION,
             nvl(PPAYEE, '00000') sfy,
             M.CHARGETYPE,
             M.OFAGENT,
             M.WATERTYPE,
              m.MILB,
        COUNT(DISTINCT pbatch) x64, -- 大厅坐收笔数
        SUM(WATERUSE)   x65, -- 大厅坐收水量
        SUM(CHARGE1)     x66, -- 大厅坐收水费
        SUM(WSSL) x67, -- 大厅坐收污水量
        SUM(CHARGE2)  x68, -- 大厅坐收污水费
        SUM(CHARGETOTAL) x69, -- 大厅坐收总金额
        SUM(ppayment) x70 -- 大厅坐实收总金额
      FROM   RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M,
             PAYMENT              P\*，
             (select pid from rpt_sum_pid where u_month = a_month) pp*\
       WHERE RL.RLID = RD.RDID  
         --and p.pid = pp.pid
         AND RL.RLMID = M.METERNO
         AND RL.RLPID = P.PID
         AND P.PMONTH = A_month
         and pposition like '02%'
              and (ptrans not in ('B', 'U') or PSCRTRANS not in ('B', 'U'))
              and rltrans not in ( 'u', 'v', '13', '14', '21')
        --AND RL.RLPAIDFLAG = 'Y'
        -- AND RL.RLPAIDMONTH = A_month
        
       GROUP BY PPAYWAY, PPOSITION, nvl(PPAYEE, '00000'), M.CHARGETYPE, M.OFAGENT,M.WATERTYPE,  m.MILB;*/
        select A_month U_MONTH,
             PPAYWAY,
             PPOSITION,
             sfy,
             CHARGETYPE,
             OFAGENT,
             WATERTYPE,
             MILB,     
              x41, -- 20140901添加维度M50  值1代表冲往月 0 代表正常
             sum(nvl(x64,0)) x64,-- 大厅坐收笔数
             sum(nvl(x65,0)) x65,-- 大厅坐收水量
             sum(nvl(x66,0)) x66,-- 大厅坐收水费
             sum(nvl(x67,0)) x67,-- 大厅坐收污水量
             sum(nvl(x68,0)) x68,-- 大厅坐收污水费
             sum(nvl(x69,0)) x69,-- 大厅坐收总金额
             sum(nvl(x70,0)) x70 -- 大厅坐实收总金额

     from (
        SELECT 
             PPAYWAY,
             PPOSITION,
             nvl(PPAYEE, '00000') sfy,
             M.CHARGETYPE,
             M.OFAGENT,
             M.WATERTYPE,
             m.MILB,
              (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1代表冲往月
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end ) x41, -- 20140901添加维度M50  值1代表冲往月 0 代表正常
        COUNT(DISTINCT pbatch) x64, -- 大厅坐收笔数
        SUM(WATERUSE)   x65, -- 大厅坐收水量
        SUM(CHARGE1)     x66, -- 大厅坐收水费
        SUM(WSSL) x67, -- 大厅坐收污水量
        SUM(CHARGE2)  x68, -- 大厅坐收污水费
        SUM(CHARGETOTAL) x69,-- 大厅坐收总金额
        null x70 -- 大厅坐实收总金额
      FROM   RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M,
             PAYMENT              P
       WHERE RL.RLID = RD.RDID  
         AND RL.RLMID = M.METERNO
         AND RL.RLPID = P.PID
         AND P.PMONTH = A_month
         and pposition like '02%'
              and (ptrans not in ('H', 'U', 'L','B') or pscrtrans not in ('H', 'U', 'L','B'))
              and rltrans not in ( 'u', 'v', '13', '14', '21','23')
              --and pposition='0201'
      GROUP BY PPAYWAY, PPOSITION, nvl(PPAYEE, '00000'), M.CHARGETYPE, M.OFAGENT,M.WATERTYPE,  m.MILB,
          (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1代表冲往月
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end )
      union 
       select 
             PPAYWAY,
             PPOSITION,
             nvl(PPAYEE, '00000') sfy,
             M.CHARGETYPE,
             M.OFAGENT,
             M.WATERTYPE,
              m.MILB,
       (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1代表冲往月
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end ) x41, -- 20140901添加维度M50  值1代表冲往月 0 代表正常
        null x64, -- 大厅坐收笔数
        null   x65, -- 大厅坐收水量
        null     x66, -- 大厅坐收水费
        null x67, -- 大厅坐收污水量
        null  x68, -- 大厅坐收污水费
        null x69,-- 大厅坐收总金额
       sum(p.ppayment)
  from payment p, MV_METER_PROP m
   where pmid = m.meterno
   and P.PMONTH = A_month
   and pposition like '02%'
   AND P.PTRANS<>'O'  --营销部收入单独统计
   and (ptrans not in ('H', 'U', 'L','B') or pscrtrans not in ('H', 'U', 'L','B'))
   --and p.pposition = '0201'
   GROUP BY PPAYWAY,
          PPOSITION,
          nvl(PPAYEE, '00000'),
          CHARGETYPE,
          OFAGENT,
          WATERTYPE,
          MILB,        (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1代表冲往月
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end ) )
    group by PPAYWAY,
             PPOSITION,
             sfy,
             CHARGETYPE,
             OFAGENT,
             WATERTYPE,
             MILB,
             x41;

 

  
    UPDATE RPT_SUM_CHARGE T
       SET (x64, -- 大厅坐收笔数
                x65, -- 大厅坐收水量
                x66, -- 大厅坐收水费
                x67, -- 大厅坐收污水量
                x68, -- 大厅坐收污水费
                x69, -- 大厅坐收总金额
                x70 -- 大厅坐实收总金额
            ) =
           (SELECT X1,
                   X2,
                   X3,
                   X4,
                   X5,
                   X6,
                   x7
              FROM RPT_SUM_TEMP TMP
             WHERE A_month = T1
               AND T.CHAREGEITEM = T2
               AND T.CHARGE_CLIENT = T3
               AND T.SFY = T4
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6
               AND T.WATERTYPE = T7
               and T.t17 = t8
               and t.m50=x41)
     WHERE T.U_MONTH = A_month;
    COMMIT;
    
    
       --add 20141024 hebang
 insert into rpt_sum_payment
   (pid, pymonth, pytype, pynote)
  SELECT distinct  p.PID, A_month U_MONTH, '02', '收费统计02-大厅坐收' 
      FROM   RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M,
             PAYMENT              P
       WHERE RL.RLID = RD.RDID  
         AND RL.RLMID = M.METERNO
         AND RL.RLPID = P.PID
         AND P.PMONTH = A_month
         and pposition like '02%'
              and (ptrans not in ('H', 'U', 'L','B') or pscrtrans not in ('H', 'U', 'L','B'))
              and rltrans not in ( 'u', 'v', '13', '14', '21','23')
      union   
   SELECT distinct p.PID, A_month U_MONTH, '02', '收费统计02-大厅坐收' 
  from payment p, MV_METER_PROP m
   where pmid = m.meterno
   and P.PMONTH = A_month
   and pposition like '02%'
   AND P.PTRANS<>'O'  --营销部收入单独统计
   and (ptrans not in ('H', 'U', 'L','B') or pscrtrans not in ('H', 'U', 'L','B'))  
   ;
 
    commit;
  --add 20141024 hebang
    /*
期初预存
x 70 预存发生
期末预存

x71, -- 基建笔数
x72, --  基建水量
x73, --  基建水费
x74, --  基建污水量
x75, --  基建污水费
x76, --  基建金额
*/
    ------基建
    DELETE RPT_SUM_TEMP;
    COMMIT;
    INSERT INTO RPT_SUM_TEMP
      (T1,
       T2,
       T3,
       T4,
       T5,
       T6,
       T7,
       t8,
       x41,--m50
       X1,
       X2,
       X3,
       X4,
       X5,
       X6
       )
      SELECT A_month U_MONTH,
             PPAYWAY,
             PPOSITION,
             nvl(PPAYEE, '00000'),
             M.CHARGETYPE,
             M.OFAGENT,
             M.WATERTYPE,
              m.MILB,         
   (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1代表冲往月
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end ) x41, -- 20140901添加维度M50  值1代表冲往月 0 代表正常
        COUNT(DISTINCT pbatch) x64, -- 笔数
        SUM(WATERUSE)   x65, -- 水量
        SUM(CHARGE1)     x66, -- 水费
        SUM(WSSL) x67, -- 污水量
        SUM(CHARGE2)  x68, -- 污水费
        SUM(CHARGETOTAL) x69 -- 总金额
                FROM RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M,
             PAYMENT              P/*， 
             (select pid from rpt_sum_pid where u_month = a_month) pp*/
       WHERE RL.RLID = RD.RDID 
         --and p.pid = pp.pid
         AND RL.RLMID = M.METERNO
         AND RL.RLPID = P.PID
         AND P.PMONTH = A_month
         and  rltrans in ( 'u', 'v')
         --AND RL.RLPAIDFLAG = 'Y'
         --AND RL.RLPAIDMONTH = A_month
       GROUP BY PPAYWAY, PPOSITION, nvl(PPAYEE, '00000'), M.CHARGETYPE, M.OFAGENT,M.WATERTYPE,  m.MILB,
          (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1代表冲往月
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end );
    

  
    UPDATE RPT_SUM_CHARGE T
       SET (x71, -- 基建笔数
                x72, --  基建水量
                x73, --  基建水费
                x74, --  基建污水量
                x75, --  基建污水费
                x76 --  基建金额

            ) =
           (SELECT X1,
                   X2,
                   X3,
                   X4,
                   X5,
                   X6
              FROM RPT_SUM_TEMP TMP
             WHERE A_month = T1
               AND T.CHAREGEITEM = T2
               AND T.CHARGE_CLIENT = T3
               AND T.SFY = T4
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6
               AND T.WATERTYPE = T7
               and  T.t17 = t8
               and t.m50 =x41)
     WHERE T.U_MONTH = A_month;
    COMMIT;

       --add 20141024 hebang
 insert into rpt_sum_payment
   (pid, pymonth, pytype, pynote)
       SELECT distinct p.PID, A_month U_MONTH, '03', '收费统计03-基建'  
         FROM RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M,
             PAYMENT              P/*， 
             (select pid from rpt_sum_pid where u_month = a_month) pp*/
       WHERE RL.RLID = RD.RDID 
         --and p.pid = pp.pid
         AND RL.RLMID = M.METERNO
         AND RL.RLPID = P.PID
         AND P.PMONTH = A_month
         and  rltrans in ( 'u', 'v')
         --AND RL.RLPAIDFLAG = 'Y'
         --AND RL.RLPAIDMONTH = A_month
        ;
    commit;
  --add 20141024 hebang
/*
x78, -- 补缴笔数
x79, --  补缴水量
x80 , -- 补缴水费
x81, --  补缴污水量
x82, --  补缴污水费
x83, --  补缴金额
*/
    ------补缴
    DELETE RPT_SUM_TEMP;
    COMMIT;
    INSERT INTO RPT_SUM_TEMP
      (T1,
       T2,
       T3,
       T4,
       T5,
       T6,
       T7,
       t8,
       x41,--m50
       X1,
       X2,
       X3,
       X4,
       X5,
       X6
       )
      SELECT A_month U_MONTH,
             PPAYWAY,
             PPOSITION,
             PPAYEE,
             M.CHARGETYPE,
             M.OFAGENT,
             M.WATERTYPE,
              m.MILB,          
   (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1代表冲往月
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end ) x41, -- 20140901添加维度M50  值1代表冲往月 0 代表正常
        COUNT(DISTINCT pbatch) x64, -- 笔数
        SUM(WATERUSE)   x65, -- 水量
        SUM(CHARGE1)     x66, -- 水费
        SUM(WSSL) x67, -- 污水量
        SUM(CHARGE2)  x68, -- 污水费
        SUM(CHARGETOTAL) x69 -- 总金额
                FROM RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M,
             PAYMENT              P/*， 
             (select pid from rpt_sum_pid where u_month = a_month) pp*/
       WHERE RL.RLID = RD.RDID 
         --and p.pid = pp.pid
         AND RL.RLMID = M.METERNO
         AND RL.RLPID = P.PID
         AND P.PMONTH = A_month
         and (rltrans ='13' or rl.rlscrrltrans='13')
         --AND RL.RLPAIDFLAG = 'Y'
         --AND RL.RLPAIDMONTH = A_month
       GROUP BY PPAYWAY, PPOSITION, PPAYEE, M.CHARGETYPE, M.OFAGENT,M.WATERTYPE,  m.MILB,
          (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1代表冲往月
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end );

  
    UPDATE RPT_SUM_CHARGE T
       SET (x78, -- 补缴笔数
                x79, --  补缴水量
                x80 , -- 补缴水费
                x81, --  补缴污水量
                x82, --  补缴污水费
                x83 --  补缴金额

            ) =
           (SELECT X1,
                   X2,
                   X3,
                   X4,
                   X5,
                   X6
              FROM RPT_SUM_TEMP TMP
             WHERE A_month = T1
               AND T.CHAREGEITEM = T2
               AND T.CHARGE_CLIENT = T3
               AND T.SFY = T4
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6
               AND T.WATERTYPE = T7
               and  T.t17 = t8
               and t.m50 =x41)
     WHERE T.U_MONTH = A_month;
    COMMIT;

       --add 20141024 hebang
 insert into rpt_sum_payment
   (pid, pymonth, pytype, pynote)
       SELECT  distinct p.PID, A_month U_MONTH, '04', '收费统计04-补缴'  
          FROM RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M,
             PAYMENT              P/*， 
             (select pid from rpt_sum_pid where u_month = a_month) pp*/
       WHERE RL.RLID = RD.RDID 
         --and p.pid = pp.pid
         AND RL.RLMID = M.METERNO
         AND RL.RLPID = P.PID
         AND P.PMONTH = A_month
         and (rltrans ='13' or rl.rlscrrltrans='13')
         --AND RL.RLPAIDFLAG = 'Y'
         --AND RL.RLPAIDMONTH = A_month
          ;
    commit;
  --add 20141024 hebang
/*
c33, -- 稽核笔数
c34, --  稽核水量
c35, --  稽核水费
c36, --  稽核污水量
c37, --  稽核污水量
c38, --  稽核金额*/
    ------稽核
    DELETE RPT_SUM_TEMP;
    COMMIT;
    INSERT INTO RPT_SUM_TEMP
      (T1,
       T2,
       T3,
       T4,
       T5,
       T6,
       T7,
       t8,
       x41,--m50
       X1,
       X2,
       X3,
       X4,
       X5,
       X6
       )
      SELECT A_month U_MONTH,
             PPAYWAY,
             PPOSITION,
             nvl(PPAYEE, '00000'),
             M.CHARGETYPE,
             M.OFAGENT,
             M.WATERTYPE,
              m.MILB,         
   (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1代表冲往月
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end ) x41, -- 20140901添加维度M50  值1代表冲往月 0 代表正常
        COUNT(DISTINCT pbatch) x64, -- 笔数
        SUM(WATERUSE)   x65, -- 水量
        SUM(CHARGE1)     x66, -- 水费
        SUM(WSSL) x67, -- 污水量
        SUM(CHARGE2)  x68, -- 污水费
        SUM(CHARGETOTAL) x69 -- 总金额
                FROM RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M,
             PAYMENT              P/*， 
             (select pid from rpt_sum_pid where u_month = a_month) pp*/
       WHERE RL.RLID = RD.RDID 
         --and p.pid = pp.pid
         AND RL.RLMID = M.METERNO
         AND RL.RLPID = P.PID
         AND P.PMONTH = A_month
         and (rltrans ='21' or rl.rlscrrltrans='21')
         --AND RL.RLPAIDFLAG = 'Y'
        -- AND RL.RLPAIDMONTH = A_month
       GROUP BY PPAYWAY, PPOSITION, nvl(PPAYEE, '00000'), M.CHARGETYPE, M.OFAGENT,M.WATERTYPE,  m.MILB,
          (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1代表冲往月
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end );
  
    UPDATE RPT_SUM_CHARGE T
       SET (
           c33, -- 稽核笔数
          c34, --  稽核水量
          c35, --  稽核水费
          c36, --  稽核污水量
          c37, --  稽核污水量
          c38 --  稽核金额
            ) =
           (SELECT X1,
                   X2,
                   X3,
                   X4,
                   X5,
                   X6
              FROM RPT_SUM_TEMP TMP
             WHERE A_month = T1
               AND T.CHAREGEITEM = T2
               AND T.CHARGE_CLIENT = T3
               AND T.SFY = T4
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6
               AND T.WATERTYPE = T7
               and T.t17 = t8
               and t.m50 = x41)
     WHERE T.U_MONTH = A_month;
    COMMIT;

   --add 20141024 hebang
 insert into rpt_sum_payment
   (pid, pymonth, pytype, pynote)
       SELECT distinct p.PID, A_month U_MONTH, '05', '收费统计05-稽核'  
         FROM RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M,
             PAYMENT              P/*， 
             (select pid from rpt_sum_pid where u_month = a_month) pp*/
       WHERE RL.RLID = RD.RDID 
         --and p.pid = pp.pid
         AND RL.RLMID = M.METERNO
         AND RL.RLPID = P.PID
         AND P.PMONTH = A_month
         and (rltrans ='21' or rl.rlscrrltrans='21')
         --AND RL.RLPAIDFLAG = 'Y'
        -- AND RL.RLPAIDMONTH = A_month
          ;
    commit;
  --add 20141024 hebang
  
    ------补当销账
    DELETE RPT_SUM_TEMP;
    COMMIT;
    INSERT INTO RPT_SUM_TEMP
      (T1,
       T2,
       T3,
       T4,
       T5,
       T6,
       T7,
       t8,
       x41,--m50
       X1,
       X2,
       X3,
       X4,
       X5
       )
      SELECT A_MONTH U_MONTH,
             PPAYWAY,
             PPOSITION,
             nvl(PPAYEE, '00000') sfy,
             'M'   CHARGETYPE,
             M.OFAGENT,
             M.WATERTYPE,
             m.MILB,                    
            (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1代表冲往月
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end ) x41, -- 20140901添加维度M50  值1代表冲往月 0 代表正常
             SUM(WATERUSE) X32, --总销账_总水量
             SUM(CHARGETOTAL) C36, --总销账_总金额
             SUM(CHARGE1) X37, --总销账_污水费
             SUM(1) X44, --总销账_笔数
             SUM(WSSL) W4  --总销账_总污水量
        FROM RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M,
             PAYMENT              P/*， 
             (select pid from rpt_sum_pid where u_month = a_month) pp*/
       WHERE RL.RLID = RD.RDID 
         --and p.pid = pp.pid
         AND RL.RLMID = M.METERNO
         AND RL.RLPID = P.PID
         AND P.PMONTH = A_MONTH
         and  (rl.rltrans in ('v', 'u', '13', '14','21') 
               or rl.rlscrrltrans in ('v', 'u', '13', '14','21'))
         --AND RL.RLPAIDFLAG = 'Y'
         --AND RL.RLPAIDMONTH = A_MONTH
       GROUP BY PPAYWAY, PPOSITION, nvl(PPAYEE, '00000'), 
          M.OFAGENT,
        m.WATERTYPE ,   m.MILB ,
            (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1代表冲往月
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end )  ;
  
    ---补充VIEW_METER_PROP不存在的维度----
    INSERT INTO RPT_SUM_CHARGE
      (TPDATE,
       U_MONTH,
       CHAREGEITEM,
       CHARGE_CLIENT,
       SFY,
       CHAREGETYPE,
       OFAGENT,
       WATERTYPE,
       t17,
       m50)
      SELECT SYSDATE,
             A_MONTH, --账务月份
             T2      CHAREGEITEM, --缴费方式
             T3      CHARGE_CLIENT, --区域
             T4      SFY, --抄表员
             T5      CHARGETYPE, --收费方式
             T6      OFAGENT, --营业所
             T7      WATERTYPE,
             t8,
             x41
        FROM RPT_SUM_TEMP
       WHERE T1 = A_MONTH
         AND (T1, T2, T3, T4, T5, T6,T7, t8,x41) NOT IN
             (SELECT U_MONTH,
                     CHAREGEITEM,
                     CHARGE_CLIENT,
                     SFY,
                     CHAREGETYPE,
                     OFAGENT,
                     WATERTYPE,
                     t17,
                     m50
                FROM RPT_SUM_CHARGE
               WHERE U_MONTH = A_MONTH);
    COMMIT;
    ---补充VIEW_METER_PROP不存在的维度----

    UPDATE RPT_SUM_CHARGE T
       SET (
            c26,
            c27,
            c28,
            c29,
            c30
            ) =
           (SELECT X1,
                   X2,
                   X3,
                   X4,
                   X5
              FROM RPT_SUM_TEMP TMP
             WHERE A_MONTH = T1
               AND T.CHAREGEITEM = T2
               AND T.CHARGE_CLIENT = T3
               AND T.SFY = T4
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6
               AND T.WATERTYPE = T7
               and  T.t17 = t8
               and t.m50 =x41 )
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

   --add 20141024 hebang
 insert into rpt_sum_payment
   (pid, pymonth, pytype, pynote)
       SELECT distinct p.PID, A_month U_MONTH, '06', '收费统计06-补当销账'  
        FROM RECLIST              RL,
                   MV_RECLIST_CHARGE_02 RD,
                   MV_METER_PROP        M,
                   PAYMENT              P/*， 
                   (select pid from rpt_sum_pid where u_month = a_month) pp*/
             WHERE RL.RLID = RD.RDID 
               --and p.pid = pp.pid
               AND RL.RLMID = M.METERNO
               AND RL.RLPID = P.PID
               AND P.PMONTH = A_MONTH
               and  (rl.rltrans in ('v', 'u', '13', '14','21') 
                     or rl.rlscrrltrans in ('v', 'u', '13', '14','21'))
               --AND RL.RLPAIDFLAG = 'Y'
               --AND RL.RLPAIDMONTH = A_MONTH
               ;
    commit;
  --add 20141024 hebang
  
    -------------销以往-----------------
    DELETE RPT_SUM_TEMP;
    COMMIT;
    INSERT INTO RPT_SUM_TEMP
      (T1,
       T2,
       T3,
       T4,
       T5,
       T6,
       T7,
       t8,
       x41,--m50
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
       X40 --污水量
       )
      SELECT A_MONTH U_MONTH,
             PPAYWAY,
             PPOSITION,
             nvl(PPAYEE, '00000'),
             M.CHARGETYPE,
             M.OFAGENT,
             M.WATERTYPE,
              m.MILB,     
   (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1代表冲往月
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end ) x41, -- 20140901添加维度M50  值1代表冲往月 0 代表正常
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
             SUM(CHARGE6) X15,
             /*SUM(RD.CHARGEZNJ)*/
             0 X48,
             SUM(WSSL) W2  --销以往_总污水量
        FROM RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M,
             PAYMENT              P/*， 
             (select pid from rpt_sum_pid where u_month = a_month) pp*/
       WHERE RL.RLID = RD.RDID 
         --and p.pid = pp.pid
         AND RL.RLMID = M.METERNO
         --AND RL.RLPAIDFLAG = 'Y'
         AND RL.RLPID = P.PID
         AND P.PMONTH = A_MONTH
         AND P.PTRANS<>'O'  --营销部收入单独统计
         --AND RL.RLPAIDMONTH = A_MONTH
         AND NVL(RL.RLBADFLAG, 'N') = 'N'
         AND RLMONTH < A_MONTH --以往
       GROUP BY PPAYWAY, PPOSITION, nvl(PPAYEE, '00000'), M.CHARGETYPE, M.OFAGENT,M.WATERTYPE,  m.MILB,
          (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1代表冲往月
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end );

  
  
    UPDATE RPT_SUM_CHARGE T
       SET (X1, --销以往_总水量
            X2, -- 销以往_阶梯1
            X3, -- 销以往_阶梯2,
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
            W2  --销以往_总污水量
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
                   X40
              FROM RPT_SUM_TEMP TMP
             WHERE A_MONTH = T1
               AND T.CHAREGEITEM = T2
               AND T.CHARGE_CLIENT = T3
               AND T.SFY = T4
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6
               AND T.WATERTYPE = T7
               and T.t17 = t8
               and t.m50 =x41 )
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
 --add 20141024 hebang
 insert into rpt_sum_payment
   (pid, pymonth, pytype, pynote)
       SELECT distinct p.PID, A_month U_MONTH, '07', '收费统计07-销以往'  
        FROM RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M,
             PAYMENT              P/*， 
             (select pid from rpt_sum_pid where u_month = a_month) pp*/
       WHERE RL.RLID = RD.RDID 
         --and p.pid = pp.pid
         AND RL.RLMID = M.METERNO
         --AND RL.RLPAIDFLAG = 'Y'
         AND RL.RLPID = P.PID
         AND P.PMONTH = A_MONTH
         AND P.PTRANS<>'O'  --营销部收入单独统计
         --AND RL.RLPAIDMONTH = A_MONTH
         AND NVL(RL.RLBADFLAG, 'N') = 'N'
         AND RLMONTH < A_MONTH --以往 
         ;
    commit;
  --add 20141024 hebang
  
    --销当月
    DELETE RPT_SUM_TEMP;
    COMMIT;
    INSERT INTO RPT_SUM_TEMP
      (T1,
       T2,
       T3,
       T4,
       T5,
       T6,
       T7,
       t8,
       x41,--m50
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
       X40 --污水量
       )
      SELECT A_MONTH U_MONTH,
             PPAYWAY,
             PPOSITION,
             nvl(PPAYEE, '00000'),
             M.CHARGETYPE,
             M.OFAGENT,
             M.WATERTYPE,
              m.MILB,    
   (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1代表冲往月
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end ) x41, -- 20140901添加维度M50  值1代表冲往月 0 代表正常
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
             SUM(CHARGE7) X31,
             /*SUM(RD.CHARGEZNJ)*/
             0 X49,
             SUM(WSSL) W3  --销当月_总污水量
        FROM RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M,
             PAYMENT              P/*， 
             (select pid from rpt_sum_pid where u_month = a_month) pp*/
       WHERE RL.RLID = RD.RDID 
         --and p.pid = pp.pid
         AND RL.RLMONTH = A_MONTH
         AND RL.RLPID = P.PID
         AND P.PMONTH = A_MONTH
         --AND RL.RLPAIDFLAG = 'Y'
         AND RL.RLMID = M.METERNO
         AND P.PTRANS<>'O'  --营销部收入单独统计
         --AND RL.RLPAIDMONTH = A_MONTH
         AND NVL(RL.RLBADFLAG, 'Y') = 'N'
       GROUP BY PPAYWAY, PPOSITION, nvl(PPAYEE, '00000'), M.CHARGETYPE, M.OFAGENT,M.WATERTYPE,  m.MILB, 
   (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1代表冲往月
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end )  ;


  
    UPDATE RPT_SUM_CHARGE T
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
            W3  --销当月_总污水量
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
                   X40
              FROM RPT_SUM_TEMP TMP
             WHERE A_MONTH = T1
               AND T.CHAREGEITEM = T2
               AND T.CHARGE_CLIENT = T3
               AND T.SFY = T4
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6
               AND T.WATERTYPE = T7
               and T.t17 = t8
               and t.m50 =x41)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

   --add 20141024 hebang
 insert into rpt_sum_payment
   (pid, pymonth, pytype, pynote)
       SELECT distinct p.PID, A_month U_MONTH, '08', '收费统计08-销当月'  
        FROM RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M,
             PAYMENT              P/*， 
             (select pid from rpt_sum_pid where u_month = a_month) pp*/
       WHERE RL.RLID = RD.RDID 
         --and p.pid = pp.pid
         AND RL.RLMONTH = A_MONTH
         AND RL.RLPID = P.PID
         AND P.PMONTH = A_MONTH
         --AND RL.RLPAIDFLAG = 'Y'
         AND RL.RLMID = M.METERNO
         AND P.PTRANS<>'O'  --营销部收入单独统计
         --AND RL.RLPAIDMONTH = A_MONTH
         AND NVL(RL.RLBADFLAG, 'Y') = 'N'  ;
    commit;
  --add 20141024 hebang
    -------------预存自动抵扣-----------------
    DELETE RPT_SUM_TEMP;
    COMMIT;
    INSERT INTO RPT_SUM_TEMP
      (T1,
       T2,
       T3,
       T4,
       T5,
       T6,
       T7,
       T8,
       x41,--m50
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
       X40 --污水量
       )
      SELECT A_MONTH U_MONTH,
             PPAYWAY,
             PPOSITION,
             nvl(PPAYEE, '00000'),
             M.CHARGETYPE,
             M.OFAGENT,
             M.WATERTYPE,
              m.MILB,         
   (case when PY.PREVERSEFLAG = 'Y' AND PY.PMONTH > PY.PSCRMONTH   then 1  --1代表冲往月
                    when PY.PREVERSEFLAG = 'Y'  AND PY.PMONTH =  PY.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end ) x41, -- 20140901添加维度M50  值1代表冲往月 0 代表正常
             SUM(WATERUSE) U1,
             SUM(USE_R1) U2,
             SUM(USE_R2) U3,
             SUM(USE_R3) U4,
             SUM(CHARGETOTAL) U5,
             SUM(CHARGE1) U6,
             SUM(CHARGE2) U7,
             SUM(CHARGE3) U8,
             SUM(CHARGE4) U9,
             SUM(CHARGE_R1) U10,
             SUM(CHARGE_R2) U11,
             SUM(CHARGE_R3) U12,
             SUM(1) U13,
             SUM(CHARGE5) U14,
             SUM(CHARGE6) U15,
             /*SUM(RD.CHARGEZNJ)*/
             0 U17,
             SUM(WSSL) W13  --预存抵扣_总污水量
        FROM PAYMENT              PY,
             RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M/*， 
             (select pid from rpt_sum_pid where u_month = a_month) pp*/
       WHERE RLID = RDID 
         --and py.pid = pp.pid
         AND PY.PID = RL.RLPID
         AND PY.PMID = M.METERNO
         AND (PY.PTRANS = 'U' or py.pscrtrans='U')
         --and py.pspje=0
         AND PY.PMONTH = A_MONTH
       GROUP BY PPAYWAY, PPOSITION, nvl(PPAYEE, '00000'), M.CHARGETYPE, M.OFAGENT,M.WATERTYPE,  m.MILB,
          (case when PY.PREVERSEFLAG = 'Y' AND PY.PMONTH > PY.PSCRMONTH   then 1  --1代表冲往月
                    when PY.PREVERSEFLAG = 'Y'  AND PY.PMONTH =  PY.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end ) ;


  
    UPDATE RPT_SUM_CHARGE T
       SET (U1,
            U2,
            U3,
            U4,
            U5,
            U6,
            U7,
            U8,
            U9,
            U10,
            U11,
            U12,
            U13,
            U14,
            U15,
            U17,
            W13  --预存抵扣_总污水量
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
                   X40
              FROM RPT_SUM_TEMP TMP
             WHERE A_MONTH = T1
               AND T.CHAREGEITEM = T2
               AND T.CHARGE_CLIENT = T3
               AND T.SFY = T4
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6
               AND T.WATERTYPE = T7
               and  T.t17 = t8
               and t.m50 = x41 )
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

   --add 20141024 hebang
 insert into rpt_sum_payment
   (pid, pymonth, pytype, pynote)
       SELECT distinct PY.PID, A_month U_MONTH, '09', '收费统计09-预存自动抵扣'  
        FROM PAYMENT              PY,
             RECLIST              RL,
             MV_RECLIST_CHARGE_02 RD,
             MV_METER_PROP        M/*， 
             (select pid from rpt_sum_pid where u_month = a_month) pp*/
       WHERE RLID = RDID 
         --and py.pid = pp.pid
         AND PY.PID = RL.RLPID
         AND PY.PMID = M.METERNO
         AND (PY.PTRANS = 'U' or py.pscrtrans='U')
         --and py.pspje=0
         AND PY.PMONTH = A_MONTH  ;
    commit;
  --add 20141024 hebang
/*
s16  --is '基建';  --
s17  --is '补缴';
s18  --is '稽核';
补缴 13 L 稽核 14 M 基建 u   H
*/
    -------------实收-----------------
    DELETE RPT_SUM_TEMP;
    COMMIT;
    INSERT INTO RPT_SUM_TEMP
      (T1,
       T2,
       T3,
       T4,
       T5,
       T6,
       T7,
        t8,
        x41,--m50
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
       x19,
       x20
       )
      SELECT A_MONTH U_MONTH,
             PPAYWAY,
             PPOSITION,
             nvl(PPAYEE, '00000'),
             M.CHARGETYPE,
             M.OFAGENT,
             M.WATERTYPE,
              m.MILB,        
   (case when py.PREVERSEFLAG = 'Y' AND py.PMONTH > py.PSCRMONTH   then 1  --1代表冲往月
                    when py.PREVERSEFLAG = 'Y'  AND py.PMONTH =  py.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end ) x41, -- 20140901添加维度M50  值1代表冲往月 0 代表正常
             SUM(CASE
                   WHEN PY.PTRANS = 'S' OR PY.PSCRTRANS = 'S' THEN
                    PY.PPAYMENT
                   ELSE
                    0
                 END) S1, --实收_纯预存
             SUM(CASE
                   WHEN PY.PTRANS = 'U' OR PY.PSCRTRANS = 'U' THEN
                    PY.PPAYMENT
                   ELSE
                    0
                 END) S2, --实收_扣预存
             0 S3, --实收_折让
             SUM(PY.PZNJ) S4, --实收_实收滞纳金
             count(distinct pbatch) S5, --实收笔数
             SUM(PY.PPAYMENT) S6, --实收金额
             SUM(DECODE(PTRANS, 'B', 1, 0)) S7, --实收_银行实收笔数
             --SUM(DECODE(PTRANS, 'B', PY.PPAYMENT, 0)) S8, --实收_银行实收金额
             sum(case when py.pposition like '03%' then py.ppayment else 0 end) s8,
             -------------------------------------------------------------------------------------------
             /*这个地方看不懂，为什么要把冲正的记录过滤掉，如果冲往月的预存，
             本月做了一笔负账，数据会有问题                       蔡俊平20140623*/
             /*SUM(DECODE(PREVERSEFLAG, 'Y', 0, PSAVINGQC)) S10, -- 期初预存,
             SUM(DECODE(PREVERSEFLAG, 'Y', 0, PSAVINGBQ)) S9, -- 本期发生,
             SUM(DECODE(PREVERSEFLAG, 'Y', 0, PSAVINGQM)) X11, -- 期末结余,*/
             ------------------------------------------------------------------------------------------------
             SUM(PSAVINGQC) S10, -- 期初预存,
             SUM(PSAVINGBQ) S9, -- 本期发生,
             SUM(PSAVINGQM) X11, -- 期末结余,
             
             0 S12, ---地区坐收水费分摊
             0 S13, ---银行水费分摊
             0 S14,
             0 S15,
             /*SUM(case PY.PTRANS when 'H' then PY.PPAYMENT else 0 end  ) S16, --基建收费
             SUM(case PY.PTRANS when 'L' then PY.PPAYMENT else 0 end  ) S17,--补缴收费
             SUM(case PY.PTRANS when 'M' then PY.PPAYMENT else 0 end  ) S18, --督察科稽查收费*/
             sum(case when py.ptrans='H' or PSCRTRANS='H' then py.ppayment else 0 end) s16,--基建收费
             sum(case when py.ptrans='L' or PSCRTRANS='L' then py.ppayment else 0 end) s17,--补缴收费
             sum(case when py.ptrans='M' or PSCRTRANS='M' then py.ppayment else 0 end) s18,--督察科稽查收费
             
             count(distinct case when PTRANS in  ('H')  then pbatch else null   end) c21, 
             count(distinct case when PTRANS in  ('L')  then pbatch else null    end)  c22       
        FROM PAYMENT PY, MV_METER_PROP M， 
        (select pid from rpt_sum_pid where u_month = a_month) pp
       WHERE PY.PMONTH = A_MONTH and py.pid = pp.pid
         AND PY.PMID = M.METERNO
         AND PY.PTRANS<>'O'  --营销部收入单独统计
       GROUP BY PPAYWAY, PPOSITION, nvl(PPAYEE, '00000'), M.CHARGETYPE, M.OFAGENT,M.WATERTYPE,  m.MILB,
          (case when py.PREVERSEFLAG = 'Y' AND py.PMONTH > py.PSCRMONTH   then 1  --1代表冲往月
                    when py.PREVERSEFLAG = 'Y'  AND py.PMONTH =  py.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end );

    UPDATE RPT_SUM_CHARGE T
       SET (S1, --实收_纯预存
            S2, --实收_损扣预存
            S3, -- 实收_折让
            S4, --实收_实收滞纳金
            S5, -- 实收_实收笔数
            S6, --实收_实收金额
            S7, --实收_银行实收笔数
            S8, ---实收_银行实收金额
            S9, --实收_预存增减
            S10, --   实收_期初预存
            S11, --   实收_期末预存
            S12, --
            S13, --
            S14, --预留
            S15, --预留
            S16, --预留
            S17,
            S18,
            c21,
            c22) =
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
                   x19,
                   x20
              FROM RPT_SUM_TEMP TMP
             WHERE A_MONTH = T1
               AND T.CHAREGEITEM = T2
               AND T.CHARGE_CLIENT = T3
               AND T.SFY = T4
               AND T.CHAREGETYPE = T5
               AND T.OFAGENT = T6
               AND T.WATERTYPE = T7
               and  T.t17 = t8
               and t.m50 =x41 )
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
   --add 20141024 hebang
 insert into rpt_sum_payment
   (pid, pymonth, pytype, pynote)
       SELECT distinct PY.PID, A_month U_MONTH, '10', '收费统计10-实收'  
        FROM PAYMENT PY, MV_METER_PROP M， 
        (select pid from rpt_sum_pid where u_month = a_month) pp
       WHERE PY.PMONTH = A_MONTH and py.pid = pp.pid
         AND PY.PMID = M.METERNO
         AND PY.PTRANS<>'O'  --营销部收入单独统计 
         ;
    commit;
  --add 20141024 hebang
  
    -------更新生成日期
    UPDATE RPT_SUM_CHARGE T
       SET T.TPDATE  = SYSDATE,
           T.COMPANY =
           (SELECT SMFPID FROM SYSMANAFRAME SY WHERE SY.SMFID = T.OFAGENT),
           T.K9      = ROUND((DECODE(NVL(K4, 0), 0, 1, K4) /
                             DECODE(NVL(K3, 0), 0, 1, K3)),
                             2)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

    UPDATE RPT_SUM_CHARGE T
       SET S14
       = ( select sum(decode(pdpiid, '01', pddj)) / sum(pddj) s from pricedetail x where pddj > 0 and pdpfid = t.WATERTYPE)
     WHERE T.U_MONTH = A_MONTH;

    UPDATE RPT_SUM_CHARGE T
       SET S12  = (nvl(t.s6, 0) - nvl(t.s8, 0))  * S14, ---地区坐收水费分摊
           S13 =  nvl(t.s8, 0)  * S14 ---银行水费分摊
          WHERE CHAREGETYPE = 'X' and T.U_MONTH = A_MONTH;
    COMMIT;


/*
    --更新产销计划
    UPDATE RPT_SUM_CHARGE T
       SET (T.SP1,
            T.SP2,
            T.SP3,
            T.SP4,
            T.SP5,
            T.SP6,
            T.SP7,
            T.SP8,
            T.SP9,
            T.SP10) =
           (SELECT VALUE1,
                   VALUE2,
                   VALUE3,
                   VALUE4,
                   VALUE5,
                   VALUE6,
                   VALUE7,
                   VALUE8,
                   VALUE9,
                   VALUE10
              FROM SALESPLAN T0
             WHERE T0.MONTH = A_MONTH
               AND T0.AREA = T.OFAGENT)
     WHERE U_MONTH = A_MONTH
       AND ROWNUM < 2;
    COMMIT;*/

    --补充维度
    update RPT_SUM_CHARGE t
    set t16 = case  when substr(t.charge_client, 1, 2)='03' then '银行' 
               when substr(t.charge_client, 1, 2)='02' then '营业大厅'
               else '其它部门' end--客服中心、营销部、稽查科等部门销账 蔡俊平
      WHERE U_MONTH = A_MONTH;

    UPDATE RPT_SUM_CHARGE T1
       SET T1.t18 --科室
           =  (SELECT oadept from operaccnt t where oaid =t1.SFY )
     WHERE U_MONTH = A_MONTH;
    COMMIT;

    commit;

  END;

  --综合统计
  PROCEDURE 综合统计(A_MONTH IN VARCHAR2) AS
  BEGIN
    DELETE RPT_SUM_TOTAL_20190401 T WHERE T.U_MONTH = A_MONTH;
    COMMIT;
    --生成粒度 到营业所
    INSERT INTO RPT_SUM_TOTAL_20190401
      (TPDATE, U_MONTH, OFAGENT, WATERTYPE, CHAREGETYPE,M50)
      SELECT SYSDATE,
             A_MONTH, --账务月份
             OFAGENT, --营业所
             --AREA, --区域
             WATERTYPE, --用水类别
             CHARGETYPE ,--收费方式
             0 M50 
        FROM MV_METER_PROP
       GROUP BY --AREA,
                CHARGETYPE,
                WATERTYPE,
                OFAGENT,
                0;
    COMMIT;

    ---补充VIEW_METER_PROP不存在的维度--RPT_SUM_READ_20190401--
    INSERT INTO RPT_SUM_TOTAL_20190401
      (TPDATE, U_MONTH, OFAGENT, WATERTYPE, CHAREGETYPE,M50)
      SELECT DISTINCT --LIQIZHU 20131010 增加DISTINCT，防止从RPT_SUM_READ_20190401表中获取的维度有重复
                      SYSDATE,
                      A_MONTH, --账务月份
                      OFAGENT, --营业所
                      --AREA, --区域
                      WATERTYPE, --用水类别
                      CHAREGETYPE, --收费方式
                      M50 
        FROM RPT_SUM_READ
       WHERE U_MONTH = A_MONTH
         AND (U_MONTH, OFAGENT, WATERTYPE, CHAREGETYPE,M50) NOT IN
             (SELECT U_MONTH, OFAGENT, WATERTYPE, CHAREGETYPE,M50
                FROM RPT_SUM_TOTAL_20190401
               WHERE U_MONTH = A_MONTH);
    COMMIT;
    ---补充VIEW_METER_PROP不存在的维度----

    ---补充VIEW_METER_PROP不存在的维度--RPT_SUM_DETAIL_20190401--
    INSERT INTO RPT_SUM_TOTAL_20190401
      (TPDATE, U_MONTH, OFAGENT, WATERTYPE, CHAREGETYPE,M50)
      SELECT DISTINCT --LIQIZHU 20131010 增加DISTINCT，防止从RPT_SUM_DETAIL_20190401表中获取的维度有重复
                      SYSDATE,
                      A_MONTH, --账务月份
                      OFAGENT, --营业所
                      --AREA, --区域
                      WATERTYPE, --用水类别
                      CHAREGETYPE, --收费方式
                      M50
        FROM RPT_SUM_DETAIL_20190401
       WHERE U_MONTH = A_MONTH
         AND (U_MONTH, OFAGENT, WATERTYPE, CHAREGETYPE,M50) NOT IN
             (SELECT U_MONTH, OFAGENT, WATERTYPE, CHAREGETYPE,M50
                FROM RPT_SUM_TOTAL_20190401
               WHERE U_MONTH = A_MONTH);
    COMMIT;
    ---补充VIEW_METER_PROP不存在的维度----

    --单价
    UPDATE RPT_SUM_TOTAL_20190401 T1
       SET (T1.WATERTYPE_B, --用水大类
            T1.WATERTYPE_M, --用水中类
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
                   T2.P16 --污水费3
              FROM PRICE_PROP T2
             WHERE T2.WATERTYPE = T1.WATERTYPE)
     WHERE U_MONTH = A_MONTH;
    COMMIT;

    --应收
    UPDATE RPT_SUM_TOTAL_20190401 T
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
            W1 --应收_总污水量
            ) =
           (SELECT SUM(C1), --应收_总水量
                   SUM(C2), -- 应收_阶梯1
                   SUM(C3), -- 应收_阶梯2
                   SUM(C4), --应收_阶梯3
                   SUM(C5), -- 应收_总金额
                   SUM(C6), --应收_污水费
                   SUM(C7), --应收_附加费
                   SUM(C8), ---应收_费用项目3
                   SUM(C9), --应收_费用项目4
                   SUM(C10), --   应收_阶梯1金额
                   SUM(C11), --   应收_阶梯2金额
                   SUM(C12), --  应收_阶梯3金额
                   SUM(C13), -- 应收笔数
                   SUM(C14), --预留
                   SUM(C15), --预留
                   SUM(C16), --预留
                   SUM(W1) --应收_总污水量
              FROM RPT_SUM_READ TMP
             WHERE TMP.U_MONTH = A_MONTH --T.U_MONTH
               AND TMP.OFAGENT = T.OFAGENT
                  --                   AND TMP.AREA = T.AREA
               AND TMP.WATERTYPE = T. WATERTYPE
               AND TMP.CHAREGETYPE = T. CHAREGETYPE
               AND TMP.M50 =T.M50
             GROUP BY TMP.U_MONTH,
                      TMP.OFAGENT,
                      --                          TMP.AREA,
                      TMP.WATERTYPE,
                      TMP.CHAREGETYPE,
                      TMP.M50)
     WHERE T.U_MONTH = A_MONTH;

    COMMIT;

    --销以往
    UPDATE RPT_SUM_TOTAL_20190401 T
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
            W2  --销以往_总污水量
            ) =
           (SELECT SUM(X1), --销以往_总水量
                   SUM(X2), -- 销以往_阶梯1
                   SUM(X3), -- 销以往_阶梯2
                   SUM(X4), --销以往_阶梯3
                   SUM(X5), -- 销以往_总金额
                   SUM(X6), --销以往_污水费
                   SUM(X7), --销以往_附加费
                   SUM(X8), ---销以往_费用项目3
                   SUM(X9), --销以往_费用项目4
                   SUM(X10), --   销以往_阶梯1金额
                   SUM(X11), --   销以往_阶梯2金额
                   SUM(X12), --  销以往_阶梯3金额
                   SUM(X13), -- 销以往笔数
                   SUM(X14), --预留
                   SUM(X15),
                   SUM(X48),
                   SUM(W2) --销以往_总污水量
              FROM RPT_SUM_DETAIL_20190401 TMP
             WHERE TMP.U_MONTH = A_MONTH --TMP.U_MONTH
               AND TMP.OFAGENT = T.OFAGENT
                  --                           AND T.AREA = TMP.AREA
               AND TMP.WATERTYPE = T. WATERTYPE
               AND TMP.CHAREGETYPE = T. CHAREGETYPE
               AND TMP.M50 = T.M50
             GROUP BY TMP.U_MONTH,
                      TMP.OFAGENT,
                      --                                  TMP.AREA,
                      TMP.WATERTYPE,
                      TMP.CHAREGETYPE,
                      TMP.M50)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

    --销当月
    UPDATE RPT_SUM_TOTAL_20190401 T
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
            W3  --销当月_总污水量
            ) =
           (SELECT SUM(X16), --销当月_总水量
                   SUM(X17), -- 销当月_阶梯1
                   SUM(X18), -- 销当月_阶梯2
                   SUM(X19), --销当月_阶梯3
                   SUM(X20), -- 销当月_总金额
                   SUM(X21), --销当月_污水费
                   SUM(X22), --销当月_附加费
                   SUM(X23), ---销当月_费用项目3
                   SUM(X24), --销当月_费用项目4
                   SUM(X25), --   销当月_阶梯1金额
                   SUM(X26), --   销当月_阶梯2金额
                   SUM(X27), --  销当月_阶梯3金额
                   SUM(X28), -- 销当月笔数
                   SUM(X29), --预留
                   SUM(X30), --预留
                   SUM(X31), --预留
                   SUM(X49), --滞纳金
                   SUM(W3) --销当月_总污水量
              FROM RPT_SUM_DETAIL_20190401 TMP
             WHERE TMP.U_MONTH = A_MONTH --T.U_MONTH
               AND TMP.OFAGENT = T.OFAGENT
                  --                  AND T.AREA = TMP.AREA
               AND TMP.WATERTYPE = T. WATERTYPE
               AND TMP.CHAREGETYPE = T. CHAREGETYPE
               AND TMP.M50 =T.M50
             GROUP BY TMP.U_MONTH,
                      TMP.OFAGENT,
                      --                         TMP.AREA,
                      TMP.WATERTYPE,
                      TMP.CHAREGETYPE,
                      TMP.M50)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

    -- 总销账
    UPDATE RPT_SUM_TOTAL_20190401 T
       SET (X32, --总销账_总水量
            X33, -- 总销账_阶梯1
            X34, -- 总销账_阶梯2
            X35, --总销账_阶梯3
            X36, -- 总销账_总金额
            X37, --总销账_水费
            X38, --总销账_污水费
            X39, ---总销账_附加费
            X40, --总销账_代收费3
            X41, --   总销账_阶梯1金额
            X42, --   总销账_阶梯2金额
            X43, --  总销账_阶梯3金额
            X44, -- 总销账_笔数
            X45, --总销账_代收费4
            X46,
            X47,
            X50,
            W4  --总销账_总污水量
            ) =
           (SELECT SUM(X32), --总销账_总水量
                   SUM(X33), -- 总销账_阶梯1
                   SUM(X34), -- 总销账_阶梯2
                   SUM(X35), --总销账_阶梯3
                   SUM(X36), -- 总销账_总金额
                   SUM(X37), --总销账_水费
                   SUM(X38), --总销账_污水费
                   SUM(X39), ---总销账_附加费
                   SUM(X40), --总销账_代收费3
                   SUM(X41), --   总销账_阶梯1金额
                   SUM(X42), --   总销账_阶梯2金额
                   SUM(X43), --  总销账_阶梯3金额
                   SUM(X44), -- 总销账_笔数
                   SUM(X45), --预留
                   SUM(X46),
                   SUM(X47),
                   SUM(X50),
                   SUM(W4) --总销账_总污水量
              FROM RPT_SUM_DETAIL_20190401 TMP
             WHERE TMP.U_MONTH = A_MONTH --T.U_MONTH
               AND TMP.OFAGENT = T.OFAGENT
                  -- AND T.AREA = TMP.AREA
               AND TMP.WATERTYPE = T. WATERTYPE
               AND TMP.CHAREGETYPE = T. CHAREGETYPE
               AND TMP.M50 =T.M50
             GROUP BY TMP.U_MONTH,
                      TMP.OFAGENT,
                      --TMP.AREA,
                      TMP.WATERTYPE,
                      TMP.CHAREGETYPE,
                      TMP.M50)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

    ---总欠费 (欠当月)
    UPDATE RPT_SUM_TOTAL_20190401 T
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
            W5  --欠当月_总污水量
            ) =
           (SELECT SUM(Q1), --欠费_总水量
                   SUM(Q2), -- 欠费_阶梯1
                   SUM(Q3), -- 欠费_阶梯2
                   SUM(Q4), --欠费_阶梯3
                   SUM(Q5), -- 欠费_总金额
                   SUM(Q6), --欠费_污水费
                   SUM(Q7), --欠费_附加费
                   SUM(Q8), ---欠费_费用项目3
                   SUM(Q9), --欠费_费用项目4
                   SUM(Q10), --   欠费_阶梯1金额
                   SUM(Q11), --   欠费_阶梯2金额
                   SUM(Q12), --  欠费_阶梯3金额
                   SUM(Q13), -- 欠费笔数
                   SUM(Q14), --预留
                   SUM(Q15),
                   SUM(Q16),
                   SUM(W5) --欠当月_总污水量
              FROM RPT_SUM_DETAIL_20190401 TMP
             WHERE TMP.U_MONTH = A_MONTH --T.U_MONTH
               AND TMP.OFAGENT = T.OFAGENT
                  --AND T.AREA = TMP.AREA
               AND TMP.WATERTYPE = T. WATERTYPE
               AND TMP.CHAREGETYPE = T. CHAREGETYPE
               AND TMP.M50 =T.M50
             GROUP BY TMP.U_MONTH,
                      TMP.OFAGENT,
                      --TMP.AREA,
                      TMP.WATERTYPE,
                      TMP.CHAREGETYPE,
                      TMP.M50)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

    ---欠以往
    UPDATE RPT_SUM_TOTAL_20190401 T
       SET (Q17, --欠费_总水量
            Q18, -- 欠费_阶梯1
            Q19, -- 欠费_阶梯2
            Q20, --欠费_阶梯3
            Q21, -- 欠费_总金额
            Q22, --欠费_污水费
            Q23, --欠费_附加费
            Q24, ---欠费_费用项目3
            Q25, --欠费_费用项目4
            Q26, --   欠费_阶梯1金额
            Q27, --   欠费_阶梯2金额
            Q28, --  欠费_阶梯3金额
            Q29, -- 欠费笔数
            Q30, --预留
            Q31,
            Q32,
            W6  --欠以往_总污水量
            ) =
           (SELECT SUM(Q17), --欠费_总水量
                   SUM(Q18), -- 欠费_阶梯1
                   SUM(Q19), -- 欠费_阶梯2
                   SUM(Q20), --欠费_阶梯3
                   SUM(Q21), -- 欠费_总金额
                   SUM(Q22), --欠费_污水费
                   SUM(Q23), --欠费_附加费
                   SUM(Q24), ---欠费_费用项目3
                   SUM(Q25), --欠费_费用项目4
                   SUM(Q26), --   欠费_阶梯1金额
                   SUM(Q27), --   欠费_阶梯2金额
                   SUM(Q28), --  欠费_阶梯3金额
                   SUM(Q29), -- 欠费笔数
                   SUM(Q30), --预留
                   SUM(Q31),
                   SUM(Q32),
                   SUM(W6) --欠以往_总污水量
              FROM RPT_SUM_DETAIL_20190401 TMP
             WHERE TMP.U_MONTH = A_MONTH -- T.U_MONTH
               AND TMP.OFAGENT = T.OFAGENT
                  --AND T.AREA = TMP.AREA
               AND TMP.WATERTYPE = T. WATERTYPE
               AND TMP.CHAREGETYPE = T. CHAREGETYPE
               AND TMP.M50 =T.M50
             GROUP BY TMP.U_MONTH,
                      TMP.OFAGENT,
                      --TMP.AREA,
                      TMP.WATERTYPE,
                      TMP.CHAREGETYPE,
                      TMP.M50)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

    -------------实收--硬算---------------
    DELETE RPT_SUM_TEMP;
    COMMIT;
    INSERT INTO RPT_SUM_TEMP
      (T1,
       T2,
       --T3,
       T4,
       T5,
       X41,--M50
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
       X18)
      SELECT A_MONTH U_MONTH,
             M.OFAGENT,
             --M.AREA,
             M.WATERTYPE,
             M.CHARGETYPE,
              (case when PY.PREVERSEFLAG = 'Y' AND PY.PMONTH > PY.PSCRMONTH   then 1  --1代表冲往月
                    when PY.PREVERSEFLAG = 'Y'  AND PY.PMONTH =  PY.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end ) x41, -- 20140901添加维度M50  值1代表冲往月 0 代表正常
             SUM(CASE
                   WHEN PY.PTRANS = 'S' OR PY.PSCRTRANS = 'S' THEN
                    PY.PPAYMENT
                   ELSE
                    0
                 END) S1, --实收_纯预存
             SUM(CASE
                   WHEN PY.PTRANS = 'U' OR PY.PSCRTRANS = 'U' THEN
                    PY.PPAYMENT
                   ELSE
                    0
                 END) S2, --实收_扣预存
             0 S3, --实收_折让
             SUM(PY.PZNJ) S4, --实收_实收滞纳金
             SUM(1) S5, --实收笔数
             SUM(PY.PPAYMENT) S6, --实收金额
             SUM(DECODE(PTRANS, 'B', 1, 0)) S7, --实收_银行实收笔数
             SUM(DECODE(PTRANS, 'B', PY.PPAYMENT, 0)) S8, --实收_银行实收金额
             SUM(PY.PSAVINGBQ) S9, -- 实收_预存增减
             SUM(PY.PSAVINGQC) S10, -- 实收_期初预存
             SUM(PY.PSAVINGQM) S11, -- 实收_期末预存
             0 S12, --走收实际回收
             0 S13,
             0 S14,
             0 S15,
             0 S16,
             0 S17,
             0 S18
        FROM PAYMENT PY, MV_METER_PROP M
       WHERE PY.PMONTH = A_MONTH
         AND PY.PMID = M.METERNO
         AND PY.PTRANS<>'O'  --营销部收入单独统计
       GROUP BY M.OFAGENT,
                --M.AREA,
                M.WATERTYPE,
                M.CHARGETYPE,
                   (case when PY.PREVERSEFLAG = 'Y' AND PY.PMONTH > PY.PSCRMONTH   then 1  --1代表冲往月
                    when PY.PREVERSEFLAG = 'Y'  AND PY.PMONTH =  PY.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end ) ;

  
    ---补充VIEW_METER_PROP不存在的维度--RPT_SUM_READ_20190401--
    INSERT INTO RPT_SUM_TOTAL_20190401
      (TPDATE, U_MONTH, OFAGENT, WATERTYPE, CHAREGETYPE,M50)
      SELECT SYSDATE,
             A_MONTH, --账务月份
             T2      OFAGENT, --营业所
             T4      WATERTYPE, --用水类别
             T5      CHARGETYPE, --收费方式
             X41
        FROM RPT_SUM_TEMP
       WHERE T1 = A_MONTH
         AND (T1, T2, T4, T5,X41) NOT IN
             (SELECT U_MONTH, OFAGENT, WATERTYPE, CHAREGETYPE,M50
                FROM RPT_SUM_TOTAL_20190401
               WHERE U_MONTH = A_MONTH);
    COMMIT;
    ---补充VIEW_METER_PROP不存在的维度----

    UPDATE RPT_SUM_TOTAL_20190401 T
       SET (S1, --实收_纯预存
            S2, --实收_损扣预存
            S3, -- 实收_折让
            S4, --实收_实收滞纳金
            S5, -- 实收_实收笔数
            S6, --实收_实收金额
            S7, --实收_银行实收笔数
            S8, ---实收_银行实收金额
            S9, --实收_预存增减
            S10, --   实收_期初预存
            S11, --   实收_期末预存
            S12, --
            S13, --
            S14, --预留
            S15, --预留
            S16, --预留
            S17,
            S18) =
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
                   X18
              FROM RPT_SUM_TEMP TMP
             WHERE A_MONTH = T1
               AND T.OFAGENT = T2
                  --AND T.AREA = T3
               AND T.WATERTYPE = T4
               AND T.CHAREGETYPE = T5
               AND T.M50 =X41)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

   --add 20141024 hebang
       insert into rpt_sum_payment
        (pid, pymonth, pytype, pynote)
       SELECT distinct PY.PID, A_month U_MONTH, '11', '综合统计11-实收'  
      FROM PAYMENT PY, MV_METER_PROP M
       WHERE PY.PMONTH = A_MONTH
         AND PY.PMID = M.METERNO
         AND PY.PTRANS<>'O'  --营销部收入单独统计
       ;
    commit;
  --add 20141024 hebang
    /*****上月******/
    UPDATE RPT_SUM_TOTAL_20190401 T1
       SET (L1, L2, L3, L4, L12, L5, W7,L6, L7, L8, L9, L11, L10,W14) =
           (SELECT SUM(C1) L1, --上月应收总水量
                   SUM(C5) L2, -- 上月应收总金额
                   SUM(C6) L3, -- 上月应收水费
                   SUM(C7) L4, --上月应收污水费（污水费）
                   SUM(C8) L12, --上月应收附加费 （附加费）
                   SUM(C13) L5, --上月应收笔数
                   SUM(W1) W7,--上月_应收总污水量
                   SUM(X32) L6, --上月销账水量
                   SUM(X36) L7, --上月销账金额
                   SUM(X37) L8, --上月销账水费
                   SUM(X38) L9, --上月销账污水费（污水费）
                   SUM(X39) L11, --上月销账附加费 （附加费）
                   SUM(X44) L10, -- 上月销账笔数
                   SUM(W4) W14 --上月_销账总污水量
              FROM RPT_SUM_TOTAL_20190401 T2
             WHERE T2.U_MONTH =
                   TO_CHAR(ADD_MONTHS(TO_DATE(T1.U_MONTH, 'YYYY-MM'), -1),
                           'YYYY.MM')
               AND T2.OFAGENT = T1.OFAGENT
                  --AND T2.AREA = T1.AREA
               AND T2.WATERTYPE = T1.WATERTYPE
               AND T2.CHAREGETYPE = T1.CHAREGETYPE
               AND T2.M50 =T1.M50)
     WHERE T1.U_MONTH = A_MONTH;
    COMMIT;

    /*去年同期*/
    UPDATE RPT_SUM_TOTAL_20190401 T1
       SET (L14, L15, L16, L17, L25, L18,W8 ,L19, L20, L21, L22, L24, L23,W15) =
           (SELECT SUM(C1) L14, --去年同期_应收总水量
                   SUM(C5) L15, -- 去年同期_应收总金额
                   SUM(C6) L16, --去年同期_应收水费
                   SUM(C7) L17, --去年同期_应收污水费（污水费）
                   SUM(C8) L25, --去年同期_应收附加费（附加费）
                   SUM(C13) L18, --去年同期_应收笔数
                   SUM(W1) W8,  --去年同期_应收总污水量
                   SUM(X32) L19, --去年同期_销账总水量
                   SUM(X36) L20, --去年同期_销账总金额
                   SUM(X37) L21, --去年同期_销账水费
                   SUM(X38) L22, --去年同期_销账污水费（污水费）
                   SUM(X39) L24, --去年同期_销账附加费（附加费）
                   SUM(X44) L23, -- 去年同期_销账笔数
                   SUM(W4) W15  --去年同期_销账总污水量
              FROM RPT_SUM_TOTAL_20190401 T2
             WHERE T2.U_MONTH =
                   TO_CHAR(ADD_MONTHS(TO_DATE(T1.U_MONTH, 'YYYY-MM'), -12),
                           'YYYY.MM')
               AND T2.OFAGENT = T1.OFAGENT
                  --AND T2.AREA = T1.AREA
               AND T2.WATERTYPE = T1.WATERTYPE
               AND T2.CHAREGETYPE = T1.CHAREGETYPE
               AND T2.M50 =T1.M50)
     WHERE T1.U_MONTH = A_MONTH;
    COMMIT;

    /*当年*/
    UPDATE RPT_SUM_TOTAL_20190401 T1
       SET (L27, L28, L29, L30, L38, L31,W9, L32, L33, L34, L35, L37, L36,W16) =
           (SELECT SUM(C1) L27, --当年_应收总水量
                   SUM(C5) L28, -- 当年_应收总金额
                   SUM(C6) L29, --当年_应收水费
                   SUM(C7) L30, --当年_应收污水费（污水费）
                   SUM(C8) L38, --当年_应收附加费（附加费）
                   SUM(C13) L31, --当年_应收笔数
                   SUM(W1) W9,  --当年_应收总污水量
                   SUM(X32) L32, --当年_销账总水量
                   SUM(X36) L33, --当年_销账总金额
                   SUM(X37) L34, --当年_销账水费
                   SUM(X38) L35, --当年_销账污水费（污水费）
                   SUM(X39) L37, --当年_销账附加费（附加费）
                   SUM(X44) L36, -- 去年同期应销账笔数
                   SUM(W4) W16  --当年_销账总污水量
              FROM RPT_SUM_TOTAL_20190401 T2
             WHERE T2.U_MONTH <= T1.U_MONTH
               AND SUBSTR(T2.U_MONTH, 1, 4) = SUBSTR(T1.U_MONTH, 1, 4)
               AND T2.OFAGENT = T1.OFAGENT
                  --AND T2.AREA = T1.AREA
               AND T2.WATERTYPE = T1.WATERTYPE
               AND T2.CHAREGETYPE = T1.CHAREGETYPE
               AND T2.M50 =T1.M50 )
     WHERE T1.U_MONTH = A_MONTH;
    COMMIT;

    /**期初欠费*/
    UPDATE RPT_SUM_TOTAL_20190401 T
       SET (L40, --期初_总水量（欠上月_总水量）（U_MONTH-1：Q1）
            L41, -- 期初_阶梯1（欠上月_阶梯1）（U_MONTH-1：Q2）
            L42, -- 期初_阶梯2（欠上月_阶梯2）（U_MONTH-1：Q3）
            L43, --期初_阶梯3（欠上月_阶梯3）（U_MONTH-1：Q4）
            L44, -- 期初_总金额（欠上月_总金额）（U_MONTH-1：Q5）
            L45, --期初_水费（欠上月_总水费）（U_MONTH-1：Q6）
            L46, --期初_污水费（欠上月_污水费）（U_MONTH-1：Q7）
            L47, ---期初_附加费（欠上月_附加费）（U_MONTH-1：Q8）
            L48, --期初_代收费3（欠上月_代收费3）（U_MONTH-1：Q9）
            L49, --   期初_阶梯1金额（欠上月__阶梯1金额）（U_MONTH-1：Q10）
            L50, --   期初_阶梯2金额（欠上月__阶梯2金额）（U_MONTH-1：Q11）
            L51, --  期初_阶梯3金额（欠上月__阶梯3金额）（U_MONTH-1：Q12）
            L52, -- 期初_笔数（欠上月_笔数）（U_MONTH-1：Q13）
            L53, --预留
            L54,
            L55,
            W10  --期初_总污水量（欠上月_总污水量）（U_MONTH-1：Q1）
            ) =
           (SELECT SUM(L40), --
                   SUM(L41), --
                   SUM(L42), --
                   SUM(L43), --
                   SUM(L44), --
                   SUM(L45), --
                   SUM(L46), --
                   SUM(L47), ---
                   SUM(L48), --
                   SUM(L49), --
                   SUM(L50), --
                   SUM(L51), --
                   SUM(L52), --
                   SUM(L53), --预留
                   SUM(L54),
                   SUM(L55),
                   SUM(W10)
              FROM RPT_SUM_DETAIL_20190401 TMP
             WHERE TMP.U_MONTH = A_MONTH -- T.U_MONTH
               AND TMP.OFAGENT = T.OFAGENT
                  --AND T.AREA = TMP.AREA
               AND TMP.WATERTYPE = T. WATERTYPE
               AND TMP.CHAREGETYPE = T. CHAREGETYPE
               AND TMP.M50 = T. M50 )
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

    --本季应收
    UPDATE RPT_SUM_TOTAL_20190401 T
       SET (C21, --    本季应收_总水量
            C22, --    本季应收_阶梯1
            C23, --    本季应收_阶梯2
            C24, --    本季应收_阶梯3
            C25, --    本季应收_总金额
            C26, --    本季应收_水费
            C27, --    本季应收_污水费
            C28, --    本季应收_附加费
            C29, --    本季应收_代收费3
            C30, --    本季应收_阶梯1金额
            C31, --    本季应收_阶梯2金额
            C32, --    本季应收_阶梯3金额
            C33, --    本季应收_笔数
            C34, --    本季应收_代收费4
            C35, --    本季应收_代收费5
            C36, --    本季应收_代收费6
            C37, --    "本季""应收代收费7
            C38, --    "本季""应收代收费8
            C39, --    本季应收代收费9
            C40, -- "本季""应收污水费0
            W11  --本季应收_总污水量
            ) =
           (SELECT SUM(C21), --    本季应收_总水量
                   SUM(C22), --    本季应收_阶梯1
                   SUM(C23), --    本季应收_阶梯2
                   SUM(C24), --    本季应收_阶梯3
                   SUM(C25), --    本季应收_总金额
                   SUM(C26), --    本季应收_水费
                   SUM(C27), --    本季应收_污水费
                   SUM(C28), --    本季应收_附加费
                   SUM(C29), --    本季应收_代收费3
                   SUM(C30), --    本季应收_阶梯1金额
                   SUM(C31), --    本季应收_阶梯2金额
                   SUM(C32), --    本季应收_阶梯3金额
                   SUM(C33), --    本季应收_笔数
                   SUM(C34), --    本季应收_代收费4
                   SUM(C35), --    本季应收_代收费5
                   SUM(C36), --    本季应收_代收费6
                   SUM(C37), --    "本季""应收代收费7
                   SUM(C38), --    "本季""应收代收费8
                   SUM(C39), --    本季应收代收费9
                   SUM(C40), --    "本季""应收污水费0
                   SUM(W11)  --本季应收_总污水量
              FROM RPT_SUM_DETAIL_20190401 TMP
             WHERE TMP.U_MONTH = A_MONTH -- T.U_MONTH
               AND TMP.OFAGENT = T.OFAGENT
                  -- AND T.AREA = TMP.AREA
               AND TMP.WATERTYPE = T. WATERTYPE
               AND TMP.CHAREGETYPE = T. CHAREGETYPE
               AND   TMP.M50 = T.M50  )
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

    --本季总销账
    UPDATE RPT_SUM_TOTAL_20190401 T
       SET (X64, --   本季总销账_总水量
            X65, --   本季总销账_阶梯1
            X66, --   本季总销账_阶梯2
            X67, --   本季总销账_阶梯3
            X68, --   本季总销账_总金额
            X69, --   本季总销账_水费
            X70, --   本季总销账_污水费
            X71, --   本季总销账_附加费
            X72, --   本季总销账_代收费3
            X73, --   本季总销账_阶梯1金额
            X74, --   本季总销账_阶梯2金额
            X75, --   本季总销账_阶梯3金额
            X76, --   本季总销账_笔数
            X77, --   本季总销账_代收费4
            X78, --   本季总销账_代收费5
            X79, --   本季总销账_代收费6
            X80, --   本季总销账_滞纳金
            X81, --   "本季"""总销账代收费7
            X82, --   "本季"""总销账代收费8
            X83, --   "本季"""总销账代收费9
            X84, --    本季总销账污水费0
            W12  --本季总销账_总污水量
            ) =
           (SELECT SUM(X64), --   本季总销账_总水量
                   SUM(X65), --   本季总销账_阶梯1
                   SUM(X66), --   本季总销账_阶梯2
                   SUM(X67), --   本季总销账_阶梯3
                   SUM(X68), --   本季总销账_总金额
                   SUM(X69), --   本季总销账_水费
                   SUM(X70), --   本季总销账_污水费
                   SUM(X71), --   本季总销账_附加费
                   SUM(X72), --   本季总销账_代收费3
                   SUM(X73), --   本季总销账_阶梯1金额
                   SUM(X74), --   本季总销账_阶梯2金额
                   SUM(X75), --   本季总销账_阶梯3金额
                   SUM(X76), --   本季总销账_笔数
                   SUM(X77), --   本季总销账_代收费4
                   SUM(X78), --   本季总销账_代收费5
                   SUM(X79), --   本季总销账_代收费6
                   SUM(X80), --   本季总销账_滞纳金
                   SUM(X81), --   "本季"""总销账代收费7
                   SUM(X82), --   "本季"""总销账代收费8
                   SUM(X83), --   "本季"""总销账代收费9
                   SUM(X84), --    本季总销账污水费0
                   SUM(W12)  --本季总销账_总污水量
              FROM RPT_SUM_DETAIL_20190401 TMP
             WHERE TMP.U_MONTH = A_MONTH -- T.U_MONTH
               AND TMP.OFAGENT = T.OFAGENT
                  -- AND T.AREA = TMP.AREA
               AND TMP.WATERTYPE = T. WATERTYPE
               AND TMP.CHAREGETYPE = T. CHAREGETYPE
               AND TMP.M50 = T. M50  )
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

    --预存抵扣
    UPDATE RPT_SUM_TOTAL_20190401 T
       SET (U1,
            U2,
            U3,
            U4,
            U5,
            U6,
            U7,
            U8,
            U9,
            U10,
            U11,
            U12,
            U13,
            U14,
            U15,
            U17,
            W13  --预存抵扣_总污水量
            ) =
           (SELECT SUM(U1),
                   SUM(U2),
                   SUM(U3),
                   SUM(U4),
                   SUM(U5),
                   SUM(U6),
                   SUM(U7),
                   SUM(U8),
                   SUM(U9),
                   SUM(U10),
                   SUM(U11),
                   SUM(U12),
                   SUM(U13),
                   SUM(U14),
                   SUM(U15),
                   SUM(U17),
                   SUM(W13)  --预存抵扣_总污水量
              FROM RPT_SUM_DETAIL_20190401 TMP
             WHERE TMP.U_MONTH = A_MONTH
                  -- T.U_MONTH
               AND TMP.OFAGENT = T.OFAGENT
                  --AND T.AREA =TMP.AREA
               AND TMP.WATERTYPE = T.WATERTYPE
               AND TMP.CHAREGETYPE = T.CHAREGETYPE
               AND TMP.M50 = T. M50   )
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

    --指标
    UPDATE RPT_SUM_TOTAL_20190401 T
       SET (K1,
            K2,
            K3, --应抄
            K4, --实抄
            K5, --空件
            K6, --无法算费数
            K7, --已算费数
            K8,
            K9, --抄见率
            K10, --正日率
            K11, --稽核错误数
            K12, --波动考核超标数
            K13, --0水量数
            K17, --新增户数
            K35, --自动扣款笔数
            K36 --自动扣款金额
            ) =
           (SELECT SUM(K1),
                   SUM(K2),
                   SUM(K3), --应抄
                   SUM(K4), --实抄
                   SUM(K5), --空件
                   SUM(K6), --无法算费数
                   SUM(K7), --已算费数
                   SUM(K8),
                   0, --抄见率
                   0, --正日率
                   SUM(K11), --稽核错误数
                   SUM(K12), --波动考核超标数
                   SUM(K13), --0水量数
                   SUM(K17), --新增 户数
                   SUM(K35), --自动扣款笔数
                   SUM(K36) --自动扣款金额
              FROM RPT_SUM_READ TMP
             WHERE TMP.U_MONTH = A_MONTH -- T.U_MONTH
               AND TMP.OFAGENT = T.OFAGENT
                  --AND T.AREA = TMP.AREA
               AND TMP.WATERTYPE = T. WATERTYPE
               AND TMP.CHAREGETYPE = T. CHAREGETYPE
               AND TMP.M50 = T. M50   )
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

    DELETE RPT_SUM_TEMP;
    COMMIT;
    --冲往月红票笔数
    INSERT INTO RPT_SUM_TEMP
      (T1, T2, T4, T5,X41, X1)
      SELECT A_MONTH U_MONTH,
             M.OFAGENT,
             --M.AREA,
             M.WATERTYPE,
             M.CHARGETYPE,
             (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1代表冲往月
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end ) x41, -- 20140901添加维度M50  值1代表冲往月 0 代表正常
             COUNT(*)
        FROM PAYMENT P, RECLIST RL, MV_METER_PROP M
       WHERE P.PREVERSEFLAG = 'Y'
         AND PMONTH > PSCRMONTH
         AND P.PTRANS<>'O'  --营销部收入单独统计
         AND P.PID = RL.RLPID
         AND P.PMONTH = A_MONTH
         AND P.PMID = M.METERNO
       GROUP BY M.OFAGENT,
                M.OFAGENT,
                --M.AREA,
                M.WATERTYPE,
                M.CHARGETYPE,
                   (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1代表冲往月
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end );


  
    UPDATE RPT_SUM_TOTAL_20190401 T
       SET (K19 --   冲往月红票笔数
            ) =
           (SELECT X1
              FROM RPT_SUM_TEMP TMP
             WHERE A_MONTH = T1
               AND T.OFAGENT = T2
                  --AND T.AREA = T3
               AND T.WATERTYPE = T4
               AND T.CHAREGETYPE = T5
               AND T.M50 =X41)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
   --add 20141024 hebang
       insert into rpt_sum_payment
        (pid, pymonth, pytype, pynote)
       SELECT distinct p.PID, A_month U_MONTH, '12', '综合统计12-冲往月红票笔数'  
        FROM PAYMENT P, RECLIST RL, MV_METER_PROP M
       WHERE P.PREVERSEFLAG = 'Y'
         AND PMONTH > PSCRMONTH
         AND P.PTRANS<>'O'  --营销部收入单独统计
         AND P.PID = RL.RLPID
         AND P.PMONTH = A_MONTH
         AND P.PMID = M.METERNO ; 
    commit;
  --add 20141024 hebang
    DELETE RPT_SUM_TEMP;
    COMMIT;
    --预存不平数
    INSERT INTO RPT_SUM_TEMP
      (T1, T2, T4, T5,X41, X1)
      SELECT A_MONTH U_MONTH,
             M.OFAGENT,
             --M.AREA,
             M.WATERTYPE,
             M.CHARGETYPE,
              (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1代表冲往月
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end ) x41, -- 20140901添加维度M50  值1代表冲往月 0 代表正常
             COUNT(*)
        FROM PAYMENT P, RECLIST RL, MV_METER_PROP M
       WHERE /*P.PREVERSEFLAG = 'Y'
                                                                     AND*/
       P.PID = RL.RLPID
       AND P.PMONTH = A_MONTH
       AND P.PMID = M.METERNO
       AND PMONTH > PSCRMONTH
       AND P.PTRANS<>'O'  --营销部收入单独统计
       AND (PSAVINGQC + PSAVINGBQ) <> PSAVINGQM
       GROUP BY M.OFAGENT,
                M.OFAGENT,
                --M.AREA,
                M.WATERTYPE,
                M.CHARGETYPE,
                  (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1代表冲往月
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end ) ;


  
    UPDATE RPT_SUM_TOTAL_20190401 T
       SET (K21 --   预存不平数
            ) =
           (SELECT NVL(X1, 0)
              FROM RPT_SUM_TEMP TMP
             WHERE A_MONTH = T1
               AND T.OFAGENT = T2
                  --AND T.AREA = T3
               AND T.WATERTYPE = T4
               AND T.CHAREGETYPE = T5
               AND T.M50 =X41)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
   --add 20141024 hebang
       insert into rpt_sum_payment
        (pid, pymonth, pytype, pynote)
       SELECT distinct p.PID, A_month U_MONTH, '13', '综合统计13-预存不平数'  
        FROM PAYMENT P, RECLIST RL, MV_METER_PROP M
       WHERE /*P.PREVERSEFLAG = 'Y'
                                                                     AND*/
       P.PID = RL.RLPID
       AND P.PMONTH = A_MONTH
       AND P.PMID = M.METERNO
       AND PMONTH > PSCRMONTH
       AND P.PTRANS<>'O'  --营销部收入单独统计
       AND (PSAVINGQC + PSAVINGBQ) <> PSAVINGQM ;
    commit;
  --add 20141024 hebang
  
    DELETE RPT_SUM_TEMP;
    COMMIT;
    --银行单边帐数
    INSERT INTO RPT_SUM_TEMP
      (T1, T2, T4, T5,X41, X1)
      SELECT A_MONTH U_MONTH,
             M.OFAGENT,
             --M.AREA,
             M.WATERTYPE,
             M.CHARGETYPE,
                (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1代表冲往月
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end ) x41, -- 20140901添加维度M50  值1代表冲往月 0 代表正常
             COUNT(*)
        FROM BANK_DZ_MX B, PAYMENT P, MV_METER_PROP M
       WHERE DZ_FLAG = '1'
         AND B.CHARGENO = P.PID
         AND P.PTRANS<>'O'  --营销部收入单独统计
         AND P.PMID = M.METERNO
         AND P.PMONTH = A_MONTH
       GROUP BY M.OFAGENT,
                M.OFAGENT,
                --M.AREA,
                M.WATERTYPE,
                M.CHARGETYPE,
                  (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1代表冲往月
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end );

  
    UPDATE RPT_SUM_TOTAL_20190401 T
       SET (K23 --   银行单边帐数
            ) =
           (SELECT NVL(X1, 0)
              FROM RPT_SUM_TEMP TMP
             WHERE A_MONTH = T1
               AND T.OFAGENT = T2
                  --AND T.AREA = T3
               AND T.WATERTYPE = T4
               AND T.CHAREGETYPE = T5
               AND T.M50=X41)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

   --add 20141024 hebang
       insert into rpt_sum_payment
        (pid, pymonth, pytype, pynote)
       SELECT distinct p.PID, A_month U_MONTH, '14', '综合统计14-银行单边账数'  
        FROM BANK_DZ_MX B, PAYMENT P, MV_METER_PROP M
       WHERE DZ_FLAG = '1'
         AND B.CHARGENO = P.PID
         AND P.PTRANS<>'O'  --营销部收入单独统计
         AND P.PMID = M.METERNO
         AND P.PMONTH = A_MONTH ;
    commit;
  --add 20141024 hebang
    DELETE RPT_SUM_TEMP;
    COMMIT;
    --自来水单边帐数
    INSERT INTO RPT_SUM_TEMP
      (T1, T2, T4, T5,X41, X1)
      SELECT A_MONTH U_MONTH,
             M.OFAGENT,
             --M.AREA,
             M.WATERTYPE,
             M.CHARGETYPE,
           (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1代表冲往月
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end ) x41, -- 20140901添加维度M50  值1代表冲往月 0 代表正常
             COUNT(*)
        FROM BANK_DZ_MX B, PAYMENT P, MV_METER_PROP M
       WHERE DZ_FLAG = '2'
         AND B.CHARGENO = P.PID
         AND P.PMID = M.METERNO
         AND P.PMONTH = A_MONTH
         AND P.PTRANS<>'O'  --营销部收入单独统计
       GROUP BY M.OFAGENT,
                M.OFAGENT,
                --M.AREA,
                M.WATERTYPE,
                M.CHARGETYPE,
                 (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1代表冲往月
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end );

  
    UPDATE RPT_SUM_TOTAL_20190401 T
       SET (K24 --   自来水单边帐数
            ) =
           (SELECT NVL(X1, 0)
              FROM RPT_SUM_TEMP TMP
             WHERE A_MONTH = T1
               AND T.OFAGENT = T2
                  -- AND T.AREA = T3
               AND T.WATERTYPE = T4
               AND T.CHAREGETYPE = T5
               AND T.M50 =X41 )
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
   --add 20141024 hebang
       insert into rpt_sum_payment
        (pid, pymonth, pytype, pynote)
       SELECT distinct p.PID, A_month U_MONTH, '15', '综合统计15-自来水单边账数'  
        FROM BANK_DZ_MX B, PAYMENT P, MV_METER_PROP M
       WHERE DZ_FLAG = '2'
         AND B.CHARGENO = P.PID
         AND P.PMID = M.METERNO
         AND P.PMONTH = A_MONTH
         AND P.PTRANS<>'O' ; --营销部收入单独统计
    commit;
  --add 20141024 hebang
    DELETE RPT_SUM_TEMP;
    COMMIT;
    --应收不平数
    INSERT INTO RPT_SUM_TEMP
      (T1, T2, T4, T5,X41, X1)
      SELECT U_MONTH,
             OFAGENT,
             --AREA,
             WATERTYPE,
             CHARGETYPE,
             X41,
             MAX(N)
        FROM (SELECT A_MONTH U_MONTH,
                     M.OFAGENT,
                     --M.AREA,
                     M.WATERTYPE,
                     M.CHARGETYPE,
                       (case when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH   then 1  --1代表冲往月
                   when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH   then 2  --2代表冲本月 
                    else 0 end ) x41, -- 20140901添加维度M50  值1代表冲往月 0 代表正常 2冲本月
                      
                     COUNT(*) N
                FROM RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M
               WHERE RLID = RD.RDID
                 AND RL.RLMID = M.METERNO
                 AND RL.RLMONTH = A_MONTH
                 AND RL.RLTRANS <>'23'
                -- and rl.rlje <> 0 -- modify hb 20150107 取消and rlje<>0 ,因消防水鹤有水量没有金额
                 and ( rl.rlje > 0 or rl.rlsl > 0 ) --add hb 20150107 取消rlje<>0 之后担心0水量算费的资料也有一起算。应该过滤故添加此管控
               GROUP BY RLID,
                        M.OFAGENT,
                        M.OFAGENT,
                        M.WATERTYPE,
                        M.CHARGETYPE,
                          (case when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH   then 1  --1代表冲往月
                   when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH   then 2  --2代表冲本月 
                    else 0 end ) 
              --M.AREA,
              HAVING MAX(RLJE) <> SUM(RD.CHARGETOTAL))
       GROUP BY U_MONTH, OFAGENT, WATERTYPE, CHARGETYPE,X41;

  
    UPDATE RPT_SUM_TOTAL_20190401 T
       SET (K25 --   应收不平数
            ) =
           (SELECT NVL(X1, 0)
              FROM RPT_SUM_TEMP TMP
             WHERE A_MONTH = T1
               AND T.OFAGENT = T2
                  -- AND T.AREA = T3
               AND T.WATERTYPE = T4
               AND T.CHAREGETYPE = T5
               AND T.M50 =X41 )
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

       --add 20141024 hebang
 insert into rpt_sum_reclist
   (rlid, rlmonth, rltype, rlnote)
  SELECT distinct rl.rlid, A_month U_MONTH, '20', '综合统计20-应收不平数'
            FROM RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M
               WHERE RLID = RD.RDID
                 AND RL.RLMID = M.METERNO
                 AND RL.RLMONTH = A_MONTH
                 AND RL.RLTRANS <>'23'
               --  and rl.rlje <> 0  -- modify hb 20150107 取消and rlje<>0 ,因消防水鹤有水量没有金额
               and ( rl.rlje > 0 or rl.rlsl > 0 ) --add hb 20150107 取消rlje<>0 之后担心0水量算费的资料也有一起算。应该过滤故添加此管控
                 ;
                    
    commit;
  --add 20141024 hebang
    DELETE RPT_SUM_TEMP;
    COMMIT;
    -- 交易作废数
    INSERT INTO RPT_SUM_TEMP
      (T1, T2, T4, T5,X41, X1)
      SELECT A_MONTH U_MONTH,
             M.OFAGENT,
             --M.AREA,
             M.WATERTYPE,
             M.CHARGETYPE,
           (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1代表冲往月
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end ) x41, -- 20140901添加维度M50  值1代表冲往月 0 代表正常
             COUNT(*)
        FROM PAYMENT P, RECLIST RL, MV_METER_PROP M
       WHERE P.PREVERSEFLAG = 'Y'
         AND P.PID = RL.RLPID
         AND P.PMONTH = A_MONTH
         AND P.PMID = M.METERNO
         AND P.PTRANS<>'O'  --营销部收入单独统计
      -- AND PMONTH > PSCRMONTH
       GROUP BY M.OFAGENT,
                --M.AREA,
                M.WATERTYPE,
                M.CHARGETYPE,
                  (case when p.PREVERSEFLAG = 'Y' AND p.PMONTH > p.PSCRMONTH   then 1  --1代表冲往月
                    when p.PREVERSEFLAG = 'Y'  AND p.PMONTH =  p.PSCRMONTH   then 2  --2代表冲本月 
                    else 0 end ) ;

  
    UPDATE RPT_SUM_TOTAL_20190401 T
       SET (K28 --   交易作废数
            ) =
           (SELECT X1
              FROM RPT_SUM_TEMP TMP
             WHERE A_MONTH = T1
               AND T.OFAGENT = T2
                  --AND T.AREA = T3
               AND T.WATERTYPE = T4
               AND T.CHAREGETYPE = T5
               AND T.M50 =X41)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
   --add 20141024 hebang
       insert into rpt_sum_payment
        (pid, pymonth, pytype, pynote)
       SELECT distinct p.PID, A_month U_MONTH, '16', '综合统计16-交易作废数'  
        FROM PAYMENT P, RECLIST RL, MV_METER_PROP M
       WHERE P.PREVERSEFLAG = 'Y'
         AND P.PID = RL.RLPID
         AND P.PMONTH = A_MONTH
         AND P.PMID = M.METERNO
         AND P.PTRANS<>'O'  --营销部收入单独统计
      -- AND PMONTH > PSCRMONTH
         ;
    commit;
  --add 20141024 hebang
  
    DELETE RPT_SUM_TEMP;
    COMMIT;

    INSERT INTO RPT_SUM_TEMP
      (T1, T2, T4, T5,X41, X1, X2)
      SELECT A_MONTH U_MONTH,
             M.OFAGENT,
             --M.AREA,
             M.WATERTYPE,
             M.CHARGETYPE,
         (case when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH   then 1  --1代表冲往月
                   when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH   then 2  --2代表冲本月 
                    else 0 end ) x41, -- 20140901添加维度M50  值1代表冲往月 0 代表正常 2冲本月
             SUM(DECODE(RL.RLOUTFLAG, 'N', 1, 0)) K29, --未托出笔数
             SUM(DECODE(RL.RLOUTFLAG,
                        'Y',
                        DECODE(RL.RLPAIDFLAG, 'N', 1, 0),
                        0)) K29 --托出未销账数
        FROM RECLIST RL, MV_METER_PROP M
       WHERE RL.RLMID = M.METERNO
         AND RLMONTH = A_MONTH
         AND RL.RLREVERSEFLAG = 'N'
         AND RL.RLPAIDFLAG = 'N'
         AND RL.RLPAIDJE > 0
         --and rl.rlje<> 0 -- modify hb 20150107 取消and rlje<>0 ,因消防水鹤有水量没有金额
         and ( rl.rlje > 0 or rl.rlsl > 0 ) --add hb 20150107 取消rlje<>0 之后担心0水量算费的资料也有一起算。应该过滤故添加此管控
         AND M.CHARGETYPE = 'T'
         AND RL.RLTRANS <>'23' --营销部收入单独统计
       GROUP BY M.OFAGENT,
                -- M.AREA,
                M.WATERTYPE,
                M.CHARGETYPE,
         (case when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH > RL.RLSCRRLMONTH   then 1  --1代表冲往月
                   when rl.RLREVERSEFLAG = 'Y' AND RL.RLMONTH =  RL.RLSCRRLMONTH   then 2  --2代表冲本月 
                    else 0 end );


  
    UPDATE RPT_SUM_TOTAL_20190401 T
       SET (K29, --   未托出笔数
            K30) =
           (SELECT X1, X2
              FROM RPT_SUM_TEMP TMP
             WHERE A_MONTH = T1
               AND T.OFAGENT = T2
                  --AND T.AREA = T3
               AND T.WATERTYPE = T4
               AND T.CHAREGETYPE = T5
               AND T.M50 =X41)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;

    UPDATE RPT_SUM_TOTAL_20190401 T
       SET T.TPDATE  = SYSDATE,
           T.COMPANY =
           (SELECT SMFPID FROM SYSMANAFRAME SY WHERE SY.SMFID = T.OFAGENT),
           T.K9      = ROUND((DECODE(NVL(K4, 0), 0, 1, K4) /
                             DECODE(NVL(K3, 0), 0, 1, K3)),
                             2),
           T.K22     = ROUND((DECODE(NVL(X36, 0), 0, 1, X36) /
                             DECODE(NVL(K3, 0), 0, 1, K3)),
                             2)
     WHERE T.U_MONTH = A_MONTH;
    COMMIT;
    
    
    --更新产销计划
    UPDATE RPT_SUM_TOTAL_20190401 T
       SET (T.SP1,
            T.SP2,
            T.SP3,
            T.SP4,
            T.SP5,
            T.SP6,
            T.SP7,
            T.SP8,
            T.SP9,
            T.SP10) =
           (SELECT VALUE1,
                   VALUE2,
                   VALUE3,
                   VALUE4,
                   VALUE5,
                   VALUE6,
                   VALUE7,
                   VALUE8,
                   VALUE9,
                   VALUE10
              FROM SALESPLAN T0
             WHERE T0.MONTH = A_MONTH
               AND T0.AREA = T.OFAGENT)
     WHERE U_MONTH = A_MONTH
       AND ROWNUM < 2;
    COMMIT;
    
           --add 20141024 hebang
 insert into rpt_sum_reclist
   (rlid, rlmonth, rltype, rlnote)
  SELECT distinct rl.rlid, A_month U_MONTH, '21', '综合统计21-未托出笔数'
        FROM RECLIST RL, MV_METER_PROP M
       WHERE RL.RLMID = M.METERNO
         AND RLMONTH = A_MONTH
         AND RL.RLREVERSEFLAG = 'N'
         AND RL.RLPAIDFLAG = 'N'
         AND RL.RLPAIDJE > 0
        -- and rl.rlje<> 0 -- modify hb 20150107 取消and rlje<>0 ,因消防水鹤有水量没有金额
         and ( rl.rlje > 0 or rl.rlsl > 0 ) --add hb 20150107 取消rlje<>0 之后担心0水量算费的资料也有一起算。应该过滤故添加此管控
         AND M.CHARGETYPE = 'T'
         AND RL.RLTRANS <>'23' --营销部收入单独统计
        ;      
    commit;
  --add 20141024 hebang

/*            T.S12, --走收实际回收
            T.S13,  --坐收预存转收入
            T.S14,  --核定额
            T.S15,  --地区回收
            T.S16,  --银行交易
            T.S17,  --回收合计
*/

    --哈尔滨资金月报
-- T.S12, --走收实际回收

/*    DELETE RPT_SUM_TEMP;
    COMMIT;

    INSERT INTO RPT_SUM_TEMP
          (T5,
       X1
       )
    select M.OFAGENT, sum(ppayment) - SUM(CHARGE2)
    from PAYMENT P, RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M
    WHERE --P.PREVERSEFLAG = 'Y'
       P.PID = RL.RLPID and RL.RLID = RD.RDID
       AND P.PMONTH = A_MONTH
       AND P.PMID = M.METERNO
       AND M.CHARGETYPE = 'M'
             GROUP BY M.OFAGENT;
    COMMIT;

    UPDATE RPT_SUM_TOTAL_20190401 T
       SET
            T.S12 --走收实际回收
            =(select x1 from RPT_SUM_TEMP p
             WHERE p.t5 = T.OFAGENT)
     WHERE U_MONTH = A_MONTH
       AND ROWNUM < 2;

    COMMIT;
--            T.S13,  --坐收预存转收入
    DELETE RPT_SUM_TEMP;
    COMMIT;

    INSERT INTO RPT_SUM_TEMP
          (T5,
       X1
       )
    select M.OFAGENT, sum(ppayment) - SUM(CHARGE2)
    from PAYMENT P, RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M
    WHERE --P.PREVERSEFLAG = 'Y'
       P.PID = RL.RLPID and RL.RLID = RD.RDID
       AND P.PMONTH = A_MONTH
       AND P.PMID = M.METERNO
       AND M.CHARGETYPE = 'X'
             GROUP BY M.OFAGENT;
    COMMIT;

    UPDATE RPT_SUM_TOTAL_20190401 T
       SET
            T.S13 --坐收预存转收入
            =(select x1 from RPT_SUM_TEMP p
             WHERE p.t5 = T.OFAGENT)
     WHERE U_MONTH = A_MONTH
       AND ROWNUM < 2;

    COMMIT;

--            T.S15,  --地区回收
    DELETE RPT_SUM_TEMP;
    COMMIT;

    INSERT INTO RPT_SUM_TEMP
          (T5,
       X1
       )
    select M.OFAGENT, sum(ppayment) - SUM(CHARGE2)
    from PAYMENT P, RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M
    WHERE --P.PREVERSEFLAG = 'Y'
       P.PID = RL.RLPID and RL.RLID = RD.RDID
       AND P.PMONTH = A_MONTH
       AND P.PMID = M.METERNO
       AND M.CHARGETYPE = 'X'
       and  p.ptrans <> 'B'
             GROUP BY M.OFAGENT;
    COMMIT;

    UPDATE RPT_SUM_TOTAL_20190401 T
       SET
            T.S15  --地区回收
            =(select x1 from RPT_SUM_TEMP p
             WHERE p.t5 = T.OFAGENT)
     WHERE U_MONTH = A_MONTH
       AND ROWNUM < 2;

    COMMIT;

--            T.S16,  --银行交易
    DELETE RPT_SUM_TEMP;
    COMMIT;

    INSERT INTO RPT_SUM_TEMP
          (T5,
       X1
       )
    select M.OFAGENT, sum(ppayment) - SUM(CHARGE2)
    from PAYMENT P, RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M
    WHERE --P.PREVERSEFLAG = 'Y'
       P.PID = RL.RLPID and RL.RLID = RD.RDID
       AND P.PMONTH = A_MONTH
       AND P.PMID = M.METERNO
       AND M.CHARGETYPE = 'X'
       and  p.ptrans = 'B'
             GROUP BY M.OFAGENT;
    COMMIT;

    UPDATE RPT_SUM_TOTAL_20190401 T
       SET
            T.S16  --银行交易
            =(select x1 from RPT_SUM_TEMP p
             WHERE p.t5 = T.OFAGENT)
     WHERE U_MONTH = A_MONTH
       AND ROWNUM < 2;

    COMMIT;

--            T.S14,  --核定额
 --           T.S17,  --回收合计
    UPDATE RPT_SUM_TOTAL_20190401 T
       SET
            S14  --核定额
            = nvl(s12, 0) + nvl(s13, 0),
            S17  --回收合计
            = nvl(s15, 0) + nvl(s16, 0)
     WHERE U_MONTH = A_MONTH
       AND ROWNUM < 2;

    COMMIT;
*/

  END;

  PROCEDURE 考核表统计(A_MONTH VARCHAR2) IS
    --***************************
    --功能:考核表月报表
    --创建人:韦政
    --修改时间:
    --修改人:
    --***************************
    --V_SQLCODE VARCHAR2(1000);

    V_SMPPVALUE VARCHAR2(10);
  BEGIN

    --删除考核表的中间表数据
    DELETE FROM BS_WBS;
    --插入考核表的中间表数据
    INSERT INTO BS_WBS
      (METERNO, --水表号
       CHKMETER, --上级考核表
       WBS, --WBS
       DISP_ORDER, --显示次序
       WBS_LEVEL, --级别
       SID) --SID
      SELECT DECODE(MIID, NULL, '', MIID) AS METERNO,
             DECODE(MIPID, NULL, 'ROOT', MIPID) AS CHKMETER,
             '' AS WBS,
             DECODE(MIRORDER, NULL, 0, MIRORDER) AS DISP_ORDER,
             LEVEL AS WBS_LEVEL,
             SYS_CONNECT_BY_PATH(MIID, '*')
        FROM METERINFO
       START WITH MIIFCHK = 'Y'
              AND MIPID IS NULL
      CONNECT BY NOCYCLE PRIOR MIID = MIPID;
    COMMIT;
    --删除考核表当月的报表数据
    DELETE RPT_WBS_CHK_SUM WHERE U_MONTH = A_MONTH;
    --插入考核表的报表数据
    INSERT INTO RPT_WBS_CHK_SUM
      (U_MONTH, --月份
       METERNO, --水表号
       CHKMETER, --上级考核表
       WBS, --WBS
       DISP_ORDER, --显示次序
       WBS_LEVEL, --级别
       SID, --SID
       SUM_S, --本表量
       SUM_CHILD, --子表量
       SUM_CHARGE, --直接收费表量
       SUM_ALL_CHARGE, --所有收费表量
       C_CHARGE, --直接收费表数
       C_CHK, --考核子表数
       C_ALL_CHARGE --所有收费表数
       )
      SELECT DECODE(A_MONTH, NULL, TO_CHAR(SYSDATE, 'YYYY.MM'), A_MONTH) AS U_MONTH,
             BS.METERNO AS METERNO,
             DECODE(BS.CHKMETER, NULL, 'ROOT', BS.CHKMETER) AS CHKMETER,
             '' AS WBS,
             BS.DISP_ORDER AS DISP_ORDER,
             BS.WBS_LEVEL AS WBS_LEVEL,
             BS.SID AS SID,
             0 AS SUM_S,
             0 AS SUM_CHILD,
             0 AS SUM_CHARGE,
             0 AS SUM_ALL_CHARGE,
             0 AS C_CHARGE,
             0 AS C_CHK,
             0 AS C_ALL_CHARGE
        FROM BS_WBS BS;
    COMMIT;

    UPDATE RPT_WBS_CHK_SUM RPT
       SET C_CHARGE       = NVL((SELECT COUNT(MIID)
                                  FROM METERINFO MI
                                 WHERE MIID = CHKMETER
                                   AND MI.MIIFCHARGE = 'Y'),
                                0), --直接收费表数
           C_CHK          = NVL((SELECT COUNT(METERNO)
                                  FROM RPT_WBS_CHK_SUM T
                                 WHERE CHKMETER = RPT.METERNO),
                                0), --考核子表数
           C_ALL_CHARGE   = NVL((SELECT COUNT(MIID)
                                  FROM METERINFO MI
                                 WHERE MIID IN
                                       (SELECT METERNO
                                          FROM RPT_WBS_CHK_SUM T
                                         WHERE T.SID LIKE
                                               '%' || RPT.METERNO || '%')
                                   AND MI.MIIFCHARGE = 'Y'),
                                0), --所有收费表数
           SUM_S          = NVL((SELECT SUM(MRSL)
                                  FROM VIEW_METERREADALL MR
                                 WHERE MR.MRMID = RPT.METERNO
                                   AND MRMONTH = A_MONTH),
                                0), ---本表量
           SUM_CHILD      = NVL((SELECT SUM(MRSL)
                                  FROM VIEW_METERREADALL MR
                                 WHERE MR.MRMID IN
                                       (SELECT METERNO
                                          FROM RPT_WBS_CHK_SUM T
                                         WHERE T.CHKMETER = RPT.METERNO)
                                   AND MR.MRMONTH = A_MONTH),
                                0), ---子表量
           SUM_CHARGE     = NVL((SELECT SUM(MRSL)
                                  FROM VIEW_METERREADALL MR, METERINFO MI
                                 WHERE MR.MRMID = MI.MIID
                                   AND MR.MRMID IN
                                       (SELECT METERNO
                                          FROM RPT_WBS_CHK_SUM T
                                         WHERE T.CHKMETER = RPT.METERNO)
                                   AND MR.MRMONTH = A_MONTH
                                   AND MI.MIIFCHARGE = 'Y'),
                                0), ---直接收费表量
           SUM_ALL_CHARGE = NVL((SELECT SUM(MRSL)
                                  FROM VIEW_METERREADALL MR, METERINFO MI
                                 WHERE MR.MRMID = MI.MIID
                                   AND MR.MRMID IN
                                       (SELECT METERNO
                                          FROM RPT_WBS_CHK_SUM T
                                         WHERE T.SID LIKE
                                               '%' || RPT.METERNO || '%')
                                   AND MR.MRMONTH = A_MONTH
                                   AND MI.MIIFCHARGE = 'Y'),
                                0) ---所有收费表量
     WHERE U_MONTH = A_MONTH;

    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;

  END;
  PROCEDURE 产销计划初始化(A_MONTH VARCHAR2) IS
    V_SALESPLAN SALESPLAN%ROWTYPE;
    CURSOR CM IS
      SELECT *
        FROM SYSMANAFRAME
       WHERE SMFTYPE = '1'
         AND SMFSTATUS = 'Y';
    V_SYSMANAFRAME SYSMANAFRAME%ROWTYPE;
    V_NUM          NUMBER;
  BEGIN
    OPEN CM;
    LOOP
      FETCH CM
        INTO V_SYSMANAFRAME;
      EXIT WHEN CM%NOTFOUND OR CM%NOTFOUND IS NULL;
      V_SALESPLAN.MONTH := A_MONTH; --月份
      V_SALESPLAN.AREA  := V_SYSMANAFRAME.SMFID; --区域
      BEGIN
        SELECT VALUE1,
               VALUE2,
               VALUE3,
               VALUE4,
               VALUE5,
               VALUE6,
               VALUE7,
               VALUE8,
               VALUE9,
               VALUE10
          INTO V_SALESPLAN.LVALUE1,
               V_SALESPLAN.LVALUE2,
               V_SALESPLAN.LVALUE3,
               V_SALESPLAN.LVALUE4,
               V_SALESPLAN.LVALUE5,
               V_SALESPLAN.LVALUE6,
               V_SALESPLAN.LVALUE7,
               V_SALESPLAN.LVALUE8,
               V_SALESPLAN.LVALUE9,
               V_SALESPLAN.LVALUE10
          FROM SALESPLAN
         WHERE MONTH = TO_CHAR(ADD_MONTHS(TO_DATE(A_MONTH, 'YYYY.MM'), -1),
                               'YYYY.MM')
           AND AREA = V_SYSMANAFRAME.SMFID;
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;
      BEGIN
        SELECT COUNT(*) INTO V_NUM FROM SALESPLAN WHERE MONTH = A_MONTH;
      EXCEPTION
        WHEN OTHERS THEN
          V_NUM := 0;
      END;
      IF V_NUM < 1 THEN
        INSERT INTO SALESPLAN VALUES V_SALESPLAN;
      END IF;
    END LOOP;
    IF CM%ISOPEN THEN
      CLOSE CM;
    END IF;
    COMMIT;
  EXCEPTION
    WHEN OTHERS THEN
      ROLLBACK;
      IF CM%ISOPEN THEN
        CLOSE CM;
      END IF;
  END;

  PROCEDURE 绩效考核统计(A_MONTH VARCHAR2) IS
  BEGIN
    DELETE 工作量计件制 T WHERE T.UMONTH = A_MONTH;
    COMMIT;
    ---生成初始表结构
    INSERT INTO 工作量计件制
      (UMONTH, OAID, OANAME, OASALARY1, OASALARY2, OASALARY3, OASALARY4)
      SELECT A_MONTH U_MONTH, --账务月份
             OA.OAID, --工号
             OA.OANAME, --姓名
             OASALARY1, --基本工资
             OASALARY2, --岗位工资
             OASALARY3, --绩效工资
             OASALARY4 --抄表难度系数
        FROM OPERACCNT OA, OPERACCNTROLE OAR, OPERROLE OPR
       WHERE OA.OAID = OAR.OAROAID
         AND OAR.OARRID = OPR.ORID
         AND OPR.ORNAME LIKE '%抄表员%';
    COMMIT;
    ---系统水表数量
    DELETE RPT_SUM_TEMP;
    INSERT INTO RPT_SUM_TEMP
      (T1, T2, X1, X2, X3, X4)
      SELECT A_MONTH U_MONTH, --账务月份
             CBY, --抄表员
             COUNT(*) METECOUNT, --应抄表总数
             SUM(DECODE(MRMONTHTYPE, 'M', 1, 0)) METECOUNTM, --应抄每月表数
             SUM(DECODE(MRMONTHTYPE, 'D', 1, 0)) METECOUNTD, --应抄单月表数
             SUM(DECODE(MRMONTHTYPE, 'S', 1, 0)) METECOUNTS --应抄双月表数
        FROM MV_METER_PROP T

       GROUP BY T.CBY;
    UPDATE 工作量计件制 T
       SET (METECOUNT, METECOUNTM, METECOUNTD, METECOUNTS) =
           (SELECT X1, X2, X3, X4
              FROM RPT_SUM_TEMP
             WHERE T1 = A_MONTH
               AND T2 = T.OAID)
     WHERE T.UMONTH = A_MONTH;
    COMMIT;
    ---系统水表数量
    DELETE RPT_SUM_TEMP;
    INSERT INTO RPT_SUM_TEMP
      (T1, T2, X1, X2, X3, X4)
      SELECT A_MONTH U_MONTH, --账务月份
             CBY, --抄表员
             COUNT(*) METECOUNT, --应抄表总数
             SUM(DECODE(MRMONTHTYPE, 'M', 1, 0)) METECOUNTM, --应抄每月表数
             SUM(DECODE(MRMONTHTYPE, 'D', 1, 0)) METECOUNTD, --应抄单月表数
             SUM(DECODE(MRMONTHTYPE, 'S', 1, 0)) METECOUNTS --应抄双月表数
        FROM MV_METER_PROP T
       GROUP BY T.CBY;
    UPDATE 工作量计件制 T
       SET (METECOUNT, METECOUNTM, METECOUNTD, METECOUNTS) =
           (SELECT X1, X2, X3, X4
              FROM RPT_SUM_TEMP
             WHERE T1 = A_MONTH
               AND T2 = T.OAID)
     WHERE T.UMONTH = A_MONTH;
    COMMIT;
    ---实际抄表数量
    DELETE RPT_SUM_TEMP;
    INSERT INTO RPT_SUM_TEMP
      (T1, T2, X1, X2, X3, X4)
      SELECT A_MONTH U_MONTH, --账务月份
             CBY, --抄表员
             COUNT(*) METECOUNT, --应抄表总数
             SUM(DECODE(MRMONTHTYPE, 'M', 1, 0)) METECOUNTM, --应抄每月表数
             SUM(DECODE(MRMONTHTYPE, 'D', 1, 0)) METECOUNTD, --应抄单月表数
             SUM(DECODE(MRMONTHTYPE, 'S', 1, 0)) METECOUNTS --应抄双月表数
        FROM VIEW_METERREADALL MR, MV_METER_PROP T
       WHERE MR.MRMID = T.METERNO
         AND MR.MRMONTH = A_MONTH
       GROUP BY T.CBY;

    UPDATE 工作量计件制 T
       SET (METECOUNT, METERCOUNTM, METERCOUNTD, METERCOUNTS) =
           (SELECT X1, X2, X3, X4
              FROM RPT_SUM_TEMP
             WHERE T1 = A_MONTH
               AND T2 = T.OAID)
     WHERE T.UMONTH = A_MONTH;
    COMMIT;

    --实际工作量
    UPDATE 工作量计件制 T
       SET WORKCOUNTD   = METERCOUNTD * OASALARY4 / 100, --单月实际工作量
           WORKCOUNTS   = METERCOUNTS * OASALARY4 / 100, --双月实际工作量
           WORKCOUNTAVE =
           (WORKCOUNTD + WORKCOUNTS) / 2 --平均工作量
     WHERE T.UMONTH = A_MONTH;
    COMMIT;
    UPDATE 工作量计件制 T
       SET WORKCOUNTAVE =
           (WORKCOUNTD + WORKCOUNTS) / 2 --平均工作量
     WHERE T.UMONTH = A_MONTH;
    COMMIT;

  END;

  --综合月报
  PROCEDURE 综合月报(A_MONTH IN VARCHAR2) AS
    V_ALOG  AUTOEXEC_LOG%ROWTYPE;
		n_app   number;
		c_error varchar2(200);
  BEGIN

    /*********
           名称：         哈尔滨综合月报执行总过程
           作者:          韦政
           时间:           2012-05-04
           参数说明：  A_MONTH  账务月份
           用途 :        调用此过程可重算  1.预存存档  2.抄表统计 3.账务明细统计 4.收费统计 5.综合统计
    ************/

    --------初始化中间表--------
    V_ALOG          := NULL;
    V_ALOG.O_TYPE   := '初始化中间表';
    V_ALOG.O_TIME_1 := SYSDATE;

    BEGIN

      初始化中间表(A_MONTH);
      V_ALOG.O_TIME_2 := SYSDATE;
      V_ALOG.O_RESULT := A_MONTH || '初始化中间表成功';
    EXCEPTION
      WHEN OTHERS THEN
        V_ALOG.O_TIME_2 := SYSDATE;
        V_ALOG.O_RESULT := A_MONTH || '初始化中间表失败';
        V_ALOG.ERR_MSG  := SQLERRM;
    END;

    SELECT SEQ_AUTOEXEC_DAY.NEXTVAL INTO V_ALOG.ID FROM DUAL;
    --------记录操作日志--------
    INSERT INTO AUTOEXEC_LOG VALUES V_ALOG;
    COMMIT;

    --------预存存档--------
    V_ALOG          := NULL;
    V_ALOG.O_TYPE   := '预存存档';
    V_ALOG.O_TIME_1 := SYSDATE;

    BEGIN

    if to_char(last_day(sysdate-1), 'yyyymmdd') =  to_char(sysdate-1, 'yyyymmdd') then
      预存存档(A_MONTH);
     --START 银行开关设置 2014/05/31
     --每月末做完预存归档后，将银行实时联网收费开关打开，哈尔滨银行除外
     --如果今后哈尔滨银行开始联网收费，请在此处去掉对哈尔滨银行的限制
     UPDATE SYSPARA SET SPVALUE = 'Y'
       WHERE SPID in ('B001','B002','B003','B004','B005','B006','B007','B008','B009','B010','B011')  --20170331 限制邮储银行
       /*AND   SPID<>'B004' */; -- 限制哈尔滨银行
       --去掉对哈尔滨银行限制20140902
     commit;
     --END  银行开关设置    2014/05/31
        null;
      end if;
      V_ALOG.O_TIME_2 := SYSDATE;
      V_ALOG.O_RESULT := A_MONTH || '预存存档成功';
    EXCEPTION
      WHEN OTHERS THEN
        V_ALOG.O_TIME_2 := SYSDATE;
        V_ALOG.O_RESULT := A_MONTH || '预存存档失败';
        V_ALOG.ERR_MSG  := SQLERRM;
    END;

    SELECT SEQ_AUTOEXEC_DAY.NEXTVAL INTO V_ALOG.ID FROM DUAL;
    --------记录操作日志--------
    INSERT INTO AUTOEXEC_LOG VALUES V_ALOG;
    COMMIT;
    
    --备份 基础表 -----------------------------
    /*begin
      EXECUTE immediate 'create table meterinfo_201612 as select * from meterinfo';
      EXECUTE immediate 'create table payment_201612 as select * from payment where pmonth = ''2016.11'' ';
      EXECUTE immediate 'create table reclist_201612 as ' ||
                            'select * from reclist rl1 where rl1.rlmonth = ''2016.11'' ' ||
                                   ' union '  ||
                            'select * from reclist rl2 where exists ' ||
                               '(select 1 from payment p where p.pid = rl2.rlpid and p.pmonth = ''2016.11'')';
      
      EXECUTE immediate 'create table recdetail_201612 as select * from MV_RECLIST_CHARGE_02 rd where exists
                                (select 1 from reclist_201612 rl where rd.rdid = rl.rlid)';
      execute immediate 'create table meterreadhis_201612 as select * from METERREADHIS where mrmonth = ''2016.11'' ';  
    exception
      when others then
        null;                          
    end; */                         
    --备份 结束
    
    

    -------------记录操作日志-------------
    V_ALOG          := NULL;
    V_ALOG.O_TYPE   := '抄表统计';
    V_ALOG.O_TIME_1 := SYSDATE;
    BEGIN
      抄表统计(A_MONTH);
      V_ALOG.O_TIME_2 := SYSDATE;
      V_ALOG.O_RESULT := A_MONTH || '抄表统计成功';
    EXCEPTION
      WHEN OTHERS THEN
        V_ALOG.O_TIME_2 := SYSDATE;
        V_ALOG.O_RESULT := A_MONTH || '抄表统计失败';
        V_ALOG.ERR_MSG  := SQLERRM;
    END;
    SELECT SEQ_AUTOEXEC_DAY.NEXTVAL INTO V_ALOG.ID FROM DUAL;
    -------------记录操作日志-------------
    INSERT INTO AUTOEXEC_LOG VALUES V_ALOG;
    COMMIT;

    -------------记录操作日志-------------

    V_ALOG          := NULL;
    V_ALOG.O_TYPE   := '账务明细统计';
    V_ALOG.O_TIME_1 := SYSDATE;
    BEGIN
      账务明细统计(A_MONTH);
      V_ALOG.O_TIME_2 := SYSDATE;
      V_ALOG.O_RESULT := A_MONTH || '账务明细统计成功';
    EXCEPTION
      WHEN OTHERS THEN
        V_ALOG.O_TIME_2 := SYSDATE;
        V_ALOG.O_RESULT := A_MONTH || '账务明细统计失败';
        V_ALOG.ERR_MSG  := SQLERRM;
    END;
    SELECT SEQ_AUTOEXEC_DAY.NEXTVAL INTO V_ALOG.ID FROM DUAL;
    --------记录操作日志--------
    INSERT INTO AUTOEXEC_LOG VALUES V_ALOG;
    COMMIT;

    -------------记录操作日志-------------

    V_ALOG          := NULL;
    V_ALOG.O_TYPE   := '收费统计';
    V_ALOG.O_TIME_1 := SYSDATE;
    BEGIN
      收费统计(A_MONTH);
      V_ALOG.O_TIME_2 := SYSDATE;
      V_ALOG.O_RESULT := A_MONTH || '收费统计成功';
    EXCEPTION
      WHEN OTHERS THEN
        V_ALOG.O_TIME_2 := SYSDATE;
        V_ALOG.O_RESULT := A_MONTH || '收费统计失败';
        V_ALOG.ERR_MSG  := SQLERRM;
    END;
    SELECT SEQ_AUTOEXEC_DAY.NEXTVAL INTO V_ALOG.ID FROM DUAL;
    -------------记录操作日志-------------
    INSERT INTO AUTOEXEC_LOG VALUES V_ALOG;
    COMMIT;

    -------------记录操作日志-------------
    V_ALOG          := NULL;
    V_ALOG.O_TYPE   := '综合统计';
    V_ALOG.O_TIME_1 := SYSDATE;
    BEGIN
      综合统计(A_MONTH);
      V_ALOG.O_TIME_2 := SYSDATE;
      V_ALOG.O_RESULT := A_MONTH || '综合统计成功';
    EXCEPTION
      WHEN OTHERS THEN
        V_ALOG.O_TIME_2 := SYSDATE;
        V_ALOG.O_RESULT := A_MONTH || '综合统计失败';
        V_ALOG.ERR_MSG  := SQLERRM;
    END;
    SELECT SEQ_AUTOEXEC_DAY.NEXTVAL INTO V_ALOG.ID FROM DUAL;
    -------------记录操作日志-------------
    INSERT INTO AUTOEXEC_LOG VALUES V_ALOG;
    COMMIT;

      -------------记录操作日志-------------
      --20140626蔡俊平
    V_ALOG          := NULL;
    V_ALOG.O_TYPE   := '财务资金统计';
    V_ALOG.O_TIME_1 := SYSDATE;
    BEGIN
      财务资金统计(A_MONTH);
      V_ALOG.O_TIME_2 := SYSDATE;
      V_ALOG.O_RESULT := A_MONTH || '财务资金统计成功';
    EXCEPTION
      WHEN OTHERS THEN
        V_ALOG.O_TIME_2 := SYSDATE;
        V_ALOG.O_RESULT := A_MONTH || '财务资金统计失败';
        V_ALOG.ERR_MSG  := SQLERRM;
    END;
    SELECT SEQ_AUTOEXEC_DAY.NEXTVAL INTO V_ALOG.ID FROM DUAL;
    -------------记录操作日志-------------
    INSERT INTO AUTOEXEC_LOG VALUES V_ALOG;
    COMMIT;

    /*
        -------------记录操作日志-------------
        V_ALOG          := NULL;
        V_ALOG.O_TIME_1 := SYSDATE;
        BEGIN
          考核表统计(A_MONTH);
          V_ALOG.O_TIME_2 := SYSDATE;
          V_ALOG.O_RESULT := A_MONTH || ' 考核表统计成功';
        EXCEPTION
          WHEN OTHERS THEN
            V_ALOG.O_TIME_2 := SYSDATE;
            V_ALOG.O_RESULT := A_MONTH || ' 考核表统计失败';
            V_ALOG.ERR_MSG  := SQLERRM;
        END;
        SELECT SEQ_AUTOEXEC_DAY.NEXTVAL INTO V_ALOG.ID FROM DUAL;
        -------------记录操作日志-------------
        INSERT INTO AUTOEXEC_LOG VALUES V_ALOG;
        COMMIT;
    */
    ------------------------------------------------------------
    --2014/05/31
    -- START 增加执行可编辑售水量报表的中间表生成
  --  PG_EWIDE_JOB_HRB.月售水情况归档_1(A_MONTH);

     --20140720   贺帮
     --添加记录操作日志
     -- START 增加执行可编辑售水量报表的中间表生成
    V_ALOG          := NULL;
    V_ALOG.O_TYPE   := '月售水情况归档_1';
    V_ALOG.O_TIME_1 := SYSDATE;
    BEGIN
       PG_EWIDE_JOB_HRB.月售水情况归档_1(A_MONTH);
      V_ALOG.O_TIME_2 := SYSDATE;
      V_ALOG.O_RESULT := A_MONTH || '月售水情况归档_1成功';
    EXCEPTION
      WHEN OTHERS THEN
        V_ALOG.O_TIME_2 := SYSDATE;
        V_ALOG.O_RESULT := A_MONTH || '月售水情况归档_1失败';
        V_ALOG.ERR_MSG  := SQLERRM;
    END;
    SELECT SEQ_AUTOEXEC_DAY.NEXTVAL INTO V_ALOG.ID FROM DUAL;
    -------------记录操作日志-------------
    INSERT INTO AUTOEXEC_LOG VALUES V_ALOG;
    COMMIT;

    -- END 增加执行可编辑售水量报表的中间表生成
    --2014/05/31
    ------------------------------------------------------------
    ------------------------------------------------------------
    --2014/06/10
  /*  -- START 增加执行资金回收报表的中间表生成
     delete 资金回收_中间表 T WHERE T.月份=A_MONTH;
     INSERT INTO  资金回收_中间表 T
      select S.* from
      V_资金回收报表 S where S.月份=A_MONTH;
    -- END 增加执行资金回收报表的中间表生成
    --2014/06/10
    ------------------------------------------------------------ */
   /* delete 资金回收_中间表 T WHERE T.月份=A_MONTH;
     INSERT INTO  资金回收_中间表 T
      select S.* from
      V_资金回收报表1 S where S.账务月份=A_MONTH;*/

        V_ALOG          := NULL;
    V_ALOG.O_TYPE   := '资金回收_中间表';
    V_ALOG.O_TIME_1 := SYSDATE;
    BEGIN
       delete 资金回收_中间表 T WHERE T.月份=A_MONTH;
       INSERT INTO  资金回收_中间表 T
          select ofagent, 
                 账务月份, 
                 坐收金额, 
                 走收金额, 
                 基补, 
                 大厅票面, 
                 地区售水大厅, 
                 银行票面, 
                 银行, 
                 售水大厅污水, 
                 银行污水, 
                 坐收污水费, 
                 走收污水费,
                nvl((select sum(nvl(rlje,0)) 
                   from reclist rl,
                        payment p
                  where rl.rlpid = p.pid and 
                        rl.rltrans = 'u' /*基建水费*/ and   
                        p.pmonth = a_month and
                        rl.rlsmfid = ofagent
                ),0) 基建票面金额,
								PG_EWIDE_JOB_HRB2.f_getAllotMoney(ofagent,a_month) 基建调拨金额                 
            from v_资金回收报表2    
           where 账务月份=A_MONTH;

      V_ALOG.O_TIME_2 := SYSDATE;
      V_ALOG.O_RESULT := A_MONTH || '资金回收_中间表成功';
    EXCEPTION
      WHEN OTHERS THEN
        V_ALOG.O_TIME_2 := SYSDATE;
        V_ALOG.O_RESULT := A_MONTH || '资金回收_中间表失败';
        V_ALOG.ERR_MSG  := SQLERRM;
    END;
    SELECT SEQ_AUTOEXEC_DAY.NEXTVAL INTO V_ALOG.ID FROM DUAL;
    -------------记录操作日志-------------
    INSERT INTO AUTOEXEC_LOG VALUES V_ALOG;
    COMMIT;
		
		
		-------------- 基建统计报表(每月第一天执行) -----------------
    if to_char(sysdate,'dd') = '01' then
      V_ALOG          := NULL;
      V_ALOG.O_TYPE   := '基建统计报表';
      V_ALOG.O_TIME_1 := SYSDATE;
      PG_EWIDE_JOB_HRB2.prc_rpt_allot_sum(a_month,n_app,c_error);
      if n_app < 0 then
         rollback;
         V_ALOG.O_TIME_2 := SYSDATE;
         V_ALOG.O_RESULT := A_MONTH || '基建统计报表失败!';
         V_ALOG.ERR_MSG  := SQLERRM;
      else
         V_ALOG.O_TIME_2 := SYSDATE;
         V_ALOG.O_RESULT := A_MONTH || '基建统计报表成功'; 
      end if;
      
      SELECT SEQ_AUTOEXEC_DAY.NEXTVAL INTO V_ALOG.ID FROM DUAL;
      -------------记录操作日志-------------
      INSERT INTO AUTOEXEC_LOG VALUES V_ALOG;
      COMMIT;
    end if;
    
    /*if to_char(sysdate,'yyyymmdd') = '20170201' then
      水价调整0201;
    end if;*/
    
  END;

  /*********
         名称：         哈尔滨综合月报初始执行总过程
         作者:          韦政
         时间:           2012-05-04
         参数说明：  S_MONTH  账务重算起始月份  E_MONTH 账务重算终止月份
         用途 :        调用此过程可按条件重算综合月报
  ************/
  PROCEDURE 综合月报初始执行(S_MONTH IN VARCHAR2, E_MONTH IN VARCHAR2) IS
    S_DATEM DATE;
    V_MONTH VARCHAR(20);
    V_ALOG  AUTOEXEC_LOG%ROWTYPE;

  BEGIN
    S_DATEM := TO_DATE(S_MONTH, 'YYYY.MM');
    LOOP

      EXIT WHEN V_MONTH = E_MONTH;
      V_MONTH         := TO_CHAR(S_DATEM, 'YYYY.MM');
      S_DATEM         := ADD_MONTHS(S_DATEM, 1);
      V_ALOG.O_TYPE   := '综合月报';
      V_ALOG.O_TIME_1 := SYSDATE;
      BEGIN
        综合月报(V_MONTH);
      EXCEPTION
        WHEN OTHERS THEN
          NULL;
      END;

    END LOOP;

  END;
-------------------------------------------------------------------------------------------------
/*通过实收的票面金额、销账金分析营业所、银行的销账情况  
蔡俊平    20140626*/
-------------------------------------------------------------------------------------------------
PROCEDURE 财务资金统计(A_MONTH VARCHAR2) IS
  BEGIN
    DELETE rpt_sum_cwzjbb T WHERE t.账务月份 = A_MONTH;
    COMMIT;
    insert into rpt_sum_cwzjbb
    select 账务月份,
       PPAYWAY,
       PPOSITION,
       sfy,
       CHARGETYPE,
       OFAGENT,
       WATERTYPE,
       MILB,
       缴费机构,
       sum(nvl(总水量,0)) 总水量,sum(nvl(总水费,0)) 总水费,sum(nvl(总污水量,0)) 总污水量,sum(nvl(总污水费,0)) 总污水费,
       sum(nvl(总金额,0)) 总金额,sum(nvl(基建水量,0)) 基建水量,sum(nvl(基建水费,0)) 基建水费,sum(nvl(补缴水量,0)) 补缴水量,
       sum(nvl(补缴水费,0)) 补缴水费,sum(nvl(补缴污水费,0)) 补缴污水费,sum(nvl(水量,0)) 水量,sum(nvl(水费,0)) 水费,
       sum(nvl(污水量,0)) 污水量,sum(nvl(污水费,0)) 污水费,sum(nvl(票面金额,0)) 票面金额,
       (sum(nvl(票面金额,0))-sum(nvl(总金额,0))) 预存发生,sum(附加费) 附加费
       
   from 
            (SELECT A_MONTH 账务月份,
               PPAYWAY,
               PPOSITION,
               nvl(PPAYEE, '00000') sfy,
               rl.rlyschargetype CHARGETYPE,
               rl.rlsmfid OFAGENT,
               rl.rlpfid WATERTYPE,
               rl.rllb MILB,
               substr(PPOSITION, 1, 2) 缴费机构,--02 地区；03 银行
               SUM(WATERUSE) 总水量,
               SUM(CHARGE1) 总水费,
               SUM(WSSL) 总污水量,
               SUM(CHARGE2) 总污水费,
               SUM(CHARGETOTAL) 总金额,
               sum(decode(rl.rltrans, 'u', rd.wateruse, 0)) 基建水量,
               sum(decode(rl.rltrans, 'u', rd.CHARGE1, 0)) 基建水费,
               sum(decode(rl.rltrans, '13', rd.wateruse, 0)) 补缴水量,
               sum(decode(rl.rltrans, '13', rd.CHARGE1, 0)) 补缴水费,
               sum(decode(rl.rltrans, '13', rd.CHARGE2, 0)) 补缴污水费,
               sum(case when rl.rltrans not in ('u','13') then wateruse else 0 end) 水量,
               sum(case when rl.rltrans not in ('u','13') then CHARGE1 else 0 end) 水费,
               sum(case when rl.rltrans not in ('u','13') then WSSL else 0 end) 污水量,
               sum(case when rl.rltrans not in ('u','13') then CHARGE2 else 0 end) 污水费,     
               null 票面金额, -- 票面金额
               sum(case when rl.rltrans not in ('u','13') then CHARGE3 else 0 end) 附加费 --by 20150115 王伟 回收以往的需要增加附加费这一项
            FROM RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M, PAYMENT P
            WHERE RL.RLID = RD.RDID
            AND RL.RLMID = M.METERNO
            AND RL.RLPID = P.PID
            AND RL.RLTRANS <>'23' --营销部收入单独统计
            AND P.PMONTH = A_MONTH --A_month
            and substr(pposition, 1, 2) in ('02', '03')
            -- and pposition = '0208'
            GROUP BY PPAYWAY,
                  PPOSITION,
                  nvl(PPAYEE, '00000'),
                  rl.rlyschargetype ,
                  rl.rlsmfid ,
                  rl.rlpfid ,
                  rl.rllb ,
                  substr(PPOSITION,1, 2)

            union

            SELECT A_MONTH 账务月份,
               PPAYWAY,
               PPOSITION,
               nvl(PPAYEE, '00000') sfy,
               M.CHARGETYPE,
               M.OFAGENT,
               M.WATERTYPE,
               m.MILB,
               substr(PPOSITION, 1, 2) 缴费机构,--02 地区；03 银行
               null 总水量,
               null 总水费,
               null 总污水量,
               null 总污水费,
               null 总金额,
               null 基建水量,
               null 基建水费,
               null 补缴水量,
               null 补缴水费,
               null 补缴污水费,
               null 水量,
               null 水费,
               null 污水量,
               null 污水费,      
               sum(p.ppayment) 票面金额, -- 票面金额
                null 附加费
            FROM PAYMENT P,MV_METER_PROP M
            WHERE p.pmid = M.METERNO
            AND P.PMONTH = A_MONTH --A_month
            and substr(pposition, 1, 2) in ('02', '03')
             AND P.PTRANS<>'O'  --营销部收入单独统计
            --and pposition = '0208'
            GROUP BY PPAYWAY,
                  PPOSITION,
                  nvl(PPAYEE, '00000'),
                  M.CHARGETYPE,
                  M.OFAGENT,
                  M.WATERTYPE,
                  m.MILB,
                  substr(PPOSITION,1, 2))
     group by 账务月份,
           PPAYWAY,
           PPOSITION,
           sfy,
           CHARGETYPE,
           OFAGENT,
           WATERTYPE,
           MILB,
           缴费机构;
    COMMIT;
    
       --add 20141024 hebang
       insert into rpt_sum_payment
        (pid, pymonth, pytype, pynote)
       SELECT  distinct  p.PID, A_month U_MONTH, '20', '财务资金统计20-财务资金统计'   
            FROM RECLIST RL, MV_RECLIST_CHARGE_02 RD, MV_METER_PROP M, PAYMENT P
            WHERE RL.RLID = RD.RDID
            AND RL.RLMID = M.METERNO
            AND RL.RLPID = P.PID
            AND RL.RLTRANS <>'23' --营销部收入单独统计
            AND P.PMONTH = A_MONTH --A_month
            and substr(pposition, 1, 2) in ('02', '03')
            -- and pposition = '0208' 
            union 
            SELECT distinct p.PID, A_month U_MONTH, '20','财务资金统计20-财务资金统计'    
            FROM PAYMENT P,MV_METER_PROP M
            WHERE p.pmid = M.METERNO
            AND P.PMONTH = A_MONTH --A_month
            and substr(pposition, 1, 2) in ('02', '03')
             AND P.PTRANS<>'O'  --营销部收入单独统计
            --and pposition = '0208' 
         ;
    commit;
  --add 20141024 hebang
  
 -------------------------------------------------------------------------------------  
 --呆坏账明细，每天晚上和中间表执行20140822 
    delete rpt_dhz;
    insert into rpt_dhz
    select rlid,rlmonth,rlsmfid,rlmid,rlcname,rlcadr,rlmadr ,rlpid,rldate,rlrdate, 
           rlscode,rlecode,rlsl,rlje,charge1,charge2,charge3
    from reclist,view_reclist_charge_01
    where rlid=rdid
          and rlbadflag='Y' 
          and rlreverseflag='N' 
          and rlje<>0  ;
    commit;
-----------------------------------------------------------------------------------------
  END;

/*-----------------------------------------------------------------------------------------------
--抄表统计--测试
用途：
说明：
-----------------------------------------------------------------------------------------------*/
 
end;
/

