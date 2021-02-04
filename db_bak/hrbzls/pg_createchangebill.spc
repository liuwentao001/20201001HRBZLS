CREATE OR REPLACE PACKAGE HRBZLS."PG_CREATECHANGEBILL" IS

  PROCEDURE 构造单头(P_CCHNO     IN VARCHAR2, --单据流水号
                 P_CCHLB     IN VARCHAR2, --单据类别
                 P_CCHSMFID  IN VARCHAR2, --营销公司
                 P_CCHDEPT   IN VARCHAR2, --受理部门
                 P_CCHCREPER IN VARCHAR2 --受理人员
                 );
  PROCEDURE 构造单体(P_CCDNO    IN VARCHAR2, --单据流水号
                 P_CCDROWNO IN VARCHAR2, --行号
                 P_MIID     IN VARCHAR2 --水表ID
                 );
     PROCEDURE 构造单个用户惠通卡变更单(P_CCHNO     IN VARCHAR2, --单据流水号
                      P_CCHLB     IN VARCHAR2, --单据类别
                      P_CCHSMFID  IN VARCHAR2, --营销公司
                      P_CCHDEPT   IN VARCHAR2, --受理部门
                      P_CCHCREPER IN VARCHAR2, --受理人员
                      P_MIgps    IN VARCHAR2, --惠通卡号
                      P_MIID    IN VARCHAR2 --水表ID
                      );
  PROCEDURE 构造单位代码变更单(P_CCHNO     IN VARCHAR2, --单据流水号
                      P_CCHLB     IN VARCHAR2, --单据类别
                      P_CCHSMFID  IN VARCHAR2, --营销公司
                      P_CCHDEPT   IN VARCHAR2, --受理部门
                      P_CCHCREPER IN VARCHAR2, --受理人员
                      P_MIUIID    IN VARCHAR2 --单位代码
                      );
   PROCEDURE 构造单个用户单位变更单(P_CCHNO     IN VARCHAR2, --单据流水号
                      P_CCHLB     IN VARCHAR2, --单据类别
                      P_CCHSMFID  IN VARCHAR2, --营销公司
                      P_CCHDEPT   IN VARCHAR2, --受理部门
                      P_CCHCREPER IN VARCHAR2, --受理人员
                      P_MIUIID    IN VARCHAR2, --单位代码
                      P_MIID    IN VARCHAR2 --水表ID
                      ) ;
                         PROCEDURE 构造单个用户单位删除(P_CCHNO     IN VARCHAR2, --单据流水号
                      P_CCHLB     IN VARCHAR2, --单据类别
                      P_CCHSMFID  IN VARCHAR2, --营销公司
                      P_CCHDEPT   IN VARCHAR2, --受理部门
                      P_CCHCREPER IN VARCHAR2, --受理人员
                      P_MIID    IN VARCHAR2 --水表ID
                      ) ;
  --构造用户信息变更单
PROCEDURE sp_newcustmeterbill( p_CCDNO in varchar2,
p_CCDROWNO in number,p_miid
in varchar2 )   ;
END;
/

