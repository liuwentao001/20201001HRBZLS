CREATE OR REPLACE PACKAGE "PG_RAEDPLAN" IS

  -- AUTHOR  : ADMIN
  -- CREATED : 2020-12-22
  -- PURPOSE : 抄表计划
  --取消、取消单户 为前台SQL语句实现
  --错误代码

  ERRCODE CONSTANT INTEGER := -20012;

  NO_DATA_FOUND EXCEPTION;

  --生成抄表计划
  PROCEDURE CREATECB(P_MANAGE_NO IN VARCHAR2,  /*营销公司*/
                     P_MONTH     IN VARCHAR2,  /*抄表月份*/
                     P_BOOK_NO   IN VARCHAR2); /*表册*/

  --单户月初
  PROCEDURE CREATECBSB(P_MONTH  IN VARCHAR2,  /*抄表月份*/
                       P_SBID   IN VARCHAR2); /*水表档案编号*/

  -- 月终
  PROCEDURE CARRYFORWARD_MR(P_SMFID  IN VARCHAR2,  /*营业所,售水公司*/
                            P_MONTH  IN VARCHAR2,  /*当前月份*/
                            P_COMMIT IN VARCHAR2); /*提交标识*/

  --生成抄表调用()
  --单户月初调用()
  PROCEDURE GETMRHIS(P_SBID  IN VARCHAR2,
                     P_MONTH IN VARCHAR2,
                     O_SL_1  OUT NUMBER,
                     O_SL_2  OUT NUMBER,
                     O_SL_3  OUT NUMBER);
END;
/

