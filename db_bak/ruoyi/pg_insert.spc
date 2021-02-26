CREATE OR REPLACE PACKAGE PG_INSERT IS

  --表册信息插入
  PROCEDURE PROC_BOOKFRAME(I_BFID_START IN VARCHAR2,  --起始编码号
                           I_BFID_END   IN VARCHAR2,  --结束编码号
                           I_BFSMFID    IN VARCHAR2,  --营销公司
                           I_BFBATCH    IN VARCHAR2,  --抄表批次
                           I_BFPID      IN VARCHAR2,  --上级编码
                           I_BFCLASS    IN VARCHAR2,  --级次
                           I_BFFLAG     IN VARCHAR2,  --末级标志
                           I_BFMEMO     IN VARCHAR2,  --备注
                           I_OPER       IN VARCHAR2,  --操作人
                           I_BFRCYC     IN VARCHAR2,  --抄表周期
                           I_BFLB       IN VARCHAR2,  --表册类别
                           I_BFRPER     IN VARCHAR2,  --抄表员
                           I_BFSAFID    IN VARCHAR2,  --区域
                           I_BFNRMONTH  IN VARCHAR2,  --下次抄表月份
                           I_BFDAY      IN VARCHAR2,  --偏移天数
                           I_BFSDATE    IN VARCHAR2,  --计划起始日期
                           I_BFEDATE    IN VARCHAR2,  --计划结束日期
                           I_BFPPER     IN VARCHAR2,  --收费员
                           I_BFJTSNY    IN VARCHAR2,  --阶梯开始月
                           O_RETURN     OUT VARCHAR2, --返回重复编号
                           O_STATE      OUT NUMBER);  --返回执行状态或数量

END;
/

