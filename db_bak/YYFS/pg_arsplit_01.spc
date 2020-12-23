CREATE OR REPLACE PACKAGE Pg_Arsplit_01 IS

  Errcode CONSTANT INTEGER := -20012;
  /*====================================================================
  -- Name: Pg_ARSPLIT_01
  -- Author:  杨华 Gary 190388857@qq.com    date: 2020年11月14日
  ----------------------------------------------------------------------
  -- Description: 拆分账单过程包
  ----------------------------------------------------------------------
  Copyright (c) 2002-2025 Gary(TM), All rights reserved.
  ----------------------------------------------------------------------
  -- 修改历史:
  -- When         Who       What
  -- ===========  ========  ============================================
     2020-11-11   杨华      新增
  --====================================================================*/

  --单据提交入口过程
  PROCEDURE Approve(p_Billno IN VARCHAR2,
                    p_Person IN VARCHAR2,
                    p_Billid IN VARCHAR2,
                    p_Djlb   IN VARCHAR2);
  --拆分账单单体
  PROCEDURE Sp_Arsplit(p_Bill_Id IN VARCHAR2, --批次流水
                       p_Per     IN VARCHAR2, --操作员
                       p_Commit  IN VARCHAR2 --提交标志;
                       );
   --拆分账单单体
  PROCEDURE Sp_Arsplit_change_one(p_Arsplitdt   IN Ys_Gd_Arsplitdt%rowTYPE,  
                       p_Per     IN VARCHAR2, --操作员
                       p_Commit  IN VARCHAR2 --提交标志;
                       ); 
                                           
  --插入单负应收与应收冲正  --单条                     
  PROCEDURE Sp_Reccz_One_01(p_Arid   IN Ys_Zw_Arlist.Arid%TYPE, -- 行变量
                            p_Commit IN VARCHAR --是否提交标志
                            );
  
  --应收分账处理  
  --输入应收流水，分帐金额，
  --返回分帐水量
  --1按水量乘单价分
  --2分到不足一吨水为止
  --3从高水量减起减到水量为1吨为止
  FUNCTION Sf_Recfzsl(p_Arid IN VARCHAR2, --分帐流水
                      p_Arje IN NUMBER --分帐金额
                      ) RETURN NUMBER;

END;
/

