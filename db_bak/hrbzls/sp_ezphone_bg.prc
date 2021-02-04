CREATE OR REPLACE PROCEDURE HRBZLS."SP_EZPHONE_BG" (P_MBPHONE VARCHAR2, --�ƶ��绰
                                          P_PHONE   VARCHAR2, --�̶��绰
                                          P_SMFID   VARCHAR2, --Ӫ����˾
                                          P_DEPT    VARCHAR2, --������
                                          P_PER     VARCHAR2, --������Ա
                                          P_MIID    VARCHAR2, --�û�ˮ����
                                          MSG       OUT VARCHAR2) AS
  V_BID VARCHAR2(20);
BEGIN
  SELECT SEQ_CUSTCHANGEHD.NEXTVAL INTO V_BID FROM DUAL;
  PG_EWIDE_CREATECHANGEBILL_01.���쵥ͷ(V_BID, --������ˮ��
                                    'B', --�������
                                    P_SMFID, --Ӫ����˾
                                    P_DEPT, --������
                                    P_PER --������Ա
                                    );
  PG_EWIDE_CREATECHANGEBILL_01.SP_NEWCUSTMETERBILL(V_BID, --������ˮ��
                                                   1, --�����к�
                                                   P_MIID);
  UPDATE CUSTCHANGEDT
     SET CIMTEL = P_MBPHONE, CITEL1 = P_PHONE
   WHERE CCDNO = V_BID;

  PG_EWIDE_CUSTBASE_01.APPROVE(V_BID, --������ˮ��
                               P_PER, --�����Ա
                               'B'); --�������
  MSG := 'Y';
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    MSG := 'N';
END;
/

