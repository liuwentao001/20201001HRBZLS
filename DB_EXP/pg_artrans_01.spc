CREATE OR REPLACE PACKAGE Pg_Artrans_01 IS

  Currentdate DATE;

  Errcode CONSTANT INTEGER := -20012;
  --单据提交入口过程
  PROCEDURE Approve(p_Billno IN VARCHAR2,
                    p_Person IN VARCHAR2,
                    p_Billid IN VARCHAR2,
                    p_Djlb   IN VARCHAR2);
  --追量收费 
  PROCEDURE Sp_Rectrans(p_No IN VARCHAR2, p_Per IN VARCHAR2);
   --追收插入抄表计划   
  PROCEDURE Sp_Insertmr(Rth         IN Ys_Gd_Araddhd%ROWTYPE, --追收头
                        p_Mriftrans IN VARCHAR2, --抄表数据事务
                        Mi          IN Ys_Yh_Sbinfo%ROWTYPE, --水表信息
                        Omrid       OUT Ys_Cb_Mtread.Id%TYPE);
  --追收插入抄表计划到历史库
   PROCEDURE Sp_Insertmrhis(Rth         IN Ys_Gd_Araddhd%ROWTYPE, --追收头
                        p_Mriftrans IN VARCHAR2, --抄表数据事务
                        Mi          IN Ys_Yh_Sbinfo%ROWTYPE, --水表信息
                        Omrid       OUT Ys_Cb_Mtread.Id%TYPE);
 
   --调整减免
  PROCEDURE RecAdjust(p_Billno IN VARCHAR2, --单据编号
                     p_Per    IN VARCHAR2, --完结人
                     p_Memo   IN VARCHAR2, --备注
                     p_Commit IN VARCHAR --是否提交标志
                     ); 
  ---实收冲正
  PROCEDURE Sp_Paidbak(p_No IN VARCHAR2, p_Per IN VARCHAR2);

END;
/

