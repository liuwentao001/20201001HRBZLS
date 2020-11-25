CREATE OR REPLACE PACKAGE "PG_SBTRANS" IS
   -- --------------------------------------------------------------------------
  -- Name         : PG_add_yh
  -- Author       : Tim
  -- Description  : 用户审核
  -- Ammedments   :
  --   When         Who       What
  --   ===========  ========  =================================================
  --   2020-12-01  Tim      Initial Creation 
  -- --------------------------------------------------------------------------

  ERRCODE CONSTANT INTEGER := -20012;
 
 M换表     CONSTANT VARCHAR2(2) := '11'; --【分公司】换表拆表后如果没有送检，水表状态为换表
  M违章     CONSTANT VARCHAR2(2) := '12'; --【分公司】违章拆表后，水表状态为违章
  M报停     CONSTANT VARCHAR2(2) := '13'; --【分公司】报停拆表后，则处于报停
  M暂停     CONSTANT VARCHAR2(2) := '14'; --【分公司】暂停拆表后，则处于暂停
  M遗失     CONSTANT VARCHAR2(2) := '15'; --【分公司】遗失处理后，为遗失
  M总仓出库 CONSTANT VARCHAR2(2) := '17'; --【总仓】总仓配表到分公司后，总仓水表为总仓出库
  M拆迁     CONSTANT VARCHAR2(2) := '16'; --【分公司】拆迁拆表后如果没有送检，为拆迁
  M欠费停水 CONSTANT VARCHAR2(2) := '21'; --【总仓】欠费造成停水

  --2、在装水表状态
  M立户       CONSTANT VARCHAR2(2) := '1'; --【分公司】用户正在使用
  M销户       CONSTANT VARCHAR2(2) := '7'; --【分公司】销户拆表后如果没有送检，则处于销户
  M销户中     CONSTANT VARCHAR2(2) := '19'; --【分公司】销户拆表派工后后完工前
  M口径变更中 CONSTANT VARCHAR2(2) := '20'; --【分公司】口径变更派工后完工前
  M欠费停水中 CONSTANT VARCHAR2(2) := '21'; --【分公司】欠费停水派工后完工前
  M报停中     CONSTANT VARCHAR2(2) := '13';
  M复装中     CONSTANT VARCHAR2(2) := '22'; --【分公司】复装派工后完工前
  M校表中     CONSTANT VARCHAR2(2) := '23'; --【分公司】校表派工后完工前
  M故障换表中 CONSTANT VARCHAR2(2) := '24'; --【分公司】故障换表派工后完工前
  M周检换表中 CONSTANT VARCHAR2(2) := '25'; --【分公司】周检换表派工后完工前
  M复查中     CONSTANT VARCHAR2(2) := '26'; --【分公司】复查派工后完工前
  M升移中     CONSTANT VARCHAR2(2) := '27'; --【分公司】水表升移改造派工后完工前

 
  --单据类别,表务类别
  --
  BT水表升移       CONSTANT CHAR(1) := '3';
  BT水表整改       CONSTANT CHAR(1) := '4';
  BT改装总表       CONSTANT CHAR(2) := 'NA'; --报装类
  BT销户拆表       CONSTANT CHAR(1) := 'F';
  BT口径变更       CONSTANT CHAR(1) := 'G';
  BT欠费停水       CONSTANT CHAR(1) := 'H';
  BT恢复供水       CONSTANT CHAR(1) := '9';
  BT报停           CONSTANT CHAR(1) := '2';
  BT复装           CONSTANT CHAR(1) := 'I';
  BT换阀门         CONSTANT CHAR(1) := 'P';
  BT校表           CONSTANT CHAR(1) := 'A';
  BT故障换表       CONSTANT CHAR(1) := 'K';
  BT周期换表       CONSTANT CHAR(1) := 'L';
  BT复查工单       CONSTANT CHAR(2) := 'NM';
  BT安装分类计量表 CONSTANT CHAR(2) := 'NP'; --报装类
  BT补装户表       CONSTANT CHAR(2) := 'NQ'; --报装类

 

  PROCEDURE AUDIT(p_HIRE_CODE IN VARCHAR2,
                    P_BILLNO IN VARCHAR2,
                    P_PERSON IN VARCHAR2,
                    P_BILLID IN VARCHAR2,
                    P_DJLB   IN VARCHAR2);

  --工单主程序
  PROCEDURE SP_SBTRANS(p_HIRE_CODE IN VARCHAR2,
                          P_TYPE      IN VARCHAR2, --操作类型
                          P_BILL_ID   IN VARCHAR2, --批次流水
                          P_PER       IN VARCHAR2, --操作员
                          P_COMMIT    IN VARCHAR2 --提交标志
                          );

  --工单单个审核过程
  PROCEDURE SP_SBTRANSONE(P_TYPE   IN VARCHAR2, --类型
                             P_PERSON IN VARCHAR2, -- 操作员
                             P_MD     IN ys_gd_metertransdt%ROWTYPE --单体行变更
                             );

 

END PG_SBTRANS;
/

