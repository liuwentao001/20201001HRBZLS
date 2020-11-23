CREATE OR REPLACE PACKAGE Pg_Arznj_01 IS

  Errcode CONSTANT INTEGER := -20012;
  /*====================================================================
  -- Name: Pg_Arznj_01
  -- Author:  杨华 Gary 190388857@qq.com    date: 2020年11月11日
  ----------------------------------------------------------------------
  -- Description: 违约金调整过程包
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
  --减免单体
  PROCEDURE Sp_Arznjjm(p_Bill_Id IN VARCHAR2, --批次流水
                       p_Per     IN VARCHAR2, --操作员
                       p_Commit  IN VARCHAR2 --提交标志;
                       );
END;
/

