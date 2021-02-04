CREATE OR REPLACE PACKAGE HRBZLS."PG_OAFLOW" IS

  PROCEDURE 构造单头(P_CCHNO     IN VARCHAR2, --单据流水号
                 P_CCHBH     IN VARCHAR2, --单据编号
                 P_CCHLB     IN VARCHAR2, --单据类别
                 P_CCHSMFID  IN VARCHAR2, --营销公司
                 P_CCHDEPT   IN VARCHAR2, --受理部门
                 P_CCHCREPER IN VARCHAR2 --受理人员

                 );
  PROCEDURE 构造单体(P_CCDNO    IN VARCHAR2, --单据流水号
                 P_CCDROWNO IN VARCHAR2, --行号
                 P_MIID     IN VARCHAR2 --水表ID
                 );

  PROCEDURE 构造单头表务(P_mthno     IN VARCHAR2, --单据流水号
                   P_MTHBH     IN VARCHAR2, --单据编号
                   P_mthlb     IN VARCHAR2, --单据类别
                   P_mthsmfid  IN VARCHAR2, --营销公司
                   P_mthdept   IN VARCHAR2, --受理部门
                   P_mthcreper IN VARCHAR2 --受理人员
                   );
  PROCEDURE 构造单体表务(P_mtdno    IN VARCHAR2, --单据流水号
                   P_mtdrowno IN VARCHAR2, --行号
                   P_MIID     IN VARCHAR2 --水表ID
                   );
  PROCEDURE 构造单头违约金(P_WYHNO        IN VARCHAR2, --单据流水号
                    P_WYHBH        IN VARCHAR2, --单据编号
                    P_WYHLB        IN VARCHAR2, --单据类别
                    P_WYHSMFID     IN VARCHAR2, --营销公司
                    P_WYHDEPT      IN VARCHAR2, --受理部门
                    P_WYHCREATEPER IN VARCHAR2, --受理人员
                    p_WYHMID       IN VARCHAR2, --水表编号
                    p_WYDVALUE     IN VARCHAR2 --减免金额
                    );
  PROCEDURE 构造单体违约金(P_WYDNO   IN VARCHAR2, --单据流水号
                    P_WYHMID  IN VARCHAR2, --水表ID
                    P_WYDRLID IN VARCHAR2 --减免应收流水
                    );
  PROCEDURE 构造单头减量退费(P_RAHNO      IN VARCHAR2, --单据流水号
                     P_RAHBH      IN VARCHAR2, --单据编号
                     P_RAHLB      IN VARCHAR2, --单据类别
                     P_RAHSMFID   IN VARCHAR2, --营销公司
                     P_RAHDEPT    IN VARCHAR2, --受理部门
                     P_RAHCREPER  IN VARCHAR2, --受理人员
                     p_RAHMID     IN VARCHAR2, --水表编号
                     p_RAHMEMO    IN VARCHAR2, --减退原因
                     p_RAHDETAILS IN VARCHAR2 --减退详情
                     );
  PROCEDURE 构造单体减量退费(P_RADNO        IN VARCHAR2, --单据流水号
                     p_RADROWNO     IN number, --行号
                     P_RADRLID      IN VARCHAR2, --减免应收流水
                     P_radecode     IN number, --本期抄见
                     P_RADADJSL     IN number, --减免水量
                     p_RADRCODEFLAG IN VARCHAR2 --置下次抄表起度
                     );
  PROCEDURE 用户信息变更(p_str in varchar2, p_mode in varchar2);
  PROCEDURE 表务(p_str in varchar2, p_mode in varchar2);
  PROCEDURE 违约金(p_str in varchar2, p_mode in varchar2);
  PROCEDURE 减量退费(p_str in varchar2, p_mode in varchar2) ;
  function 类别转换(p_str in varchar2) return varchar2;
  function 取流水号(p_str in varchar2) return varchar2;
  PROCEDURE oa_flow(p_str in varchar2, p_mode in varchar2);

END;
/

