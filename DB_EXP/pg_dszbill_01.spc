CREATE OR REPLACE PACKAGE Pg_Dszbill_01 IS

  Errcode CONSTANT INTEGER := -20012;
  /*====================================================================
  -- Name: PG_DSZBILL_01
  -- Author:  杨华 Gary 190388857@qq.com    date: 2020年11月11日
  ----------------------------------------------------------------------
  -- Description: 呆坏账过程包
  ----------------------------------------------------------------------
  Copyright (c) 2002-2025 Gary(TM), All rights reserved. 
  ----------------------------------------------------------------------
  -- 修改历史:
  -- When         Who       What
  -- ===========  ========  ============================================
     2020-11-11   杨华      新增
  --====================================================================*/
  PROCEDURE Createhd(p_Dshno     IN VARCHAR2, --单据流水号
                     p_Dshlb     IN VARCHAR2, --单据类别
                     p_Dshsmfid  IN VARCHAR2, --营销公司
                     p_Dshdept   IN VARCHAR2, --受理部门
                     p_Dshcreper IN VARCHAR2 --受理人员
                     );
  PROCEDURE Createdt(p_Dsdno    IN VARCHAR2, --单据流水号
                     p_Dsdrowno IN VARCHAR2, --行号
                     p_Arid     IN VARCHAR2 --应收流水
                     );

  -----------------------------------------------------
  --构造呆死帐单据
  --外部调用，将应收流水号YS_ZW_AARIST.ARID在前台插入到临时表PBPARMTEMP.C1中
  PROCEDURE Createdszbill(p_Dshno     IN VARCHAR2, --单据流水号
                          p_Dshlb     IN VARCHAR2, --单据类别
                          p_Dshsmfid  IN VARCHAR2, --营销公司
                          p_Dshdept   IN VARCHAR2, --受理部门
                          p_Dshcreper IN VARCHAR2, --受理人员
                          p_Arid      IN VARCHAR2 --应收流水号
                          );

  --删除单据
  PROCEDURE Cancelbill(p_Billno IN VARCHAR2, --单据编号
                       p_Person IN VARCHAR2, --操作员
                       p_Djlb   IN VARCHAR2); --单据类别

  PROCEDURE Custbillmain(p_Cchno    IN VARCHAR2, --批次流水
                         p_Per      IN VARCHAR2, --操作员
                         p_Billid   IN VARCHAR2, --单据ID
                         p_Billtype IN VARCHAR2 --单据类别
                         );
  --审核主程序
  PROCEDURE Custbill(p_Cchno    IN VARCHAR2, --批次流水
                     p_Per      IN VARCHAR2, --操作员
                     p_Billtype IN VARCHAR2, --单据类别
                     p_Commit   IN VARCHAR2 --提交标志
                     );
END;
/

