CREATE OR REPLACE PROCEDURE HRBZLS."SP_EZPHONE_BG" (P_MBPHONE VARCHAR2, --移动电话
                                          P_PHONE   VARCHAR2, --固定电话
                                          P_SMFID   VARCHAR2, --营销公司
                                          P_DEPT    VARCHAR2, --受理部门
                                          P_PER     VARCHAR2, --受理人员
                                          P_MIID    VARCHAR2, --用户水表编号
                                          MSG       OUT VARCHAR2) AS
  V_BID VARCHAR2(20);
BEGIN
  SELECT SEQ_CUSTCHANGEHD.NEXTVAL INTO V_BID FROM DUAL;
  PG_EWIDE_CREATECHANGEBILL_01.构造单头(V_BID, --单据流水号
                                    'B', --单据类别
                                    P_SMFID, --营销公司
                                    P_DEPT, --受理部门
                                    P_PER --受理人员
                                    );
  PG_EWIDE_CREATECHANGEBILL_01.SP_NEWCUSTMETERBILL(V_BID, --单据流水号
                                                   1, --单据行号
                                                   P_MIID);
  UPDATE CUSTCHANGEDT
     SET CIMTEL = P_MBPHONE, CITEL1 = P_PHONE
   WHERE CCDNO = V_BID;

  PG_EWIDE_CUSTBASE_01.APPROVE(V_BID, --单据流水号
                               P_PER, --审核人员
                               'B'); --单据类别
  MSG := 'Y';
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    MSG := 'N';
END;
/

