CREATE OR REPLACE PACKAGE HRBZLS."PG_HRBZLS_DATAMOVE_ALL" IS
  ERRCODE   CONSTANT INTEGER := -20012;
  YINYESHOU CONSTANT VARCHAR2(10) := '020101';
  QUBIEMA   CONSTANT VARCHAR2(10) := '1';
  PROCEDURE �������ݳ�ʼ��SQL;
  PROCEDURE ��������;
  PROCEDURE ά�������ݿ���;
  PROCEDURE ��������;
  PROCEDURE ��Ӳ���Ա��Ϣ;
  PROCEDURE ����ܹ�;

  PROCEDURE �ھ�;
  PROCEDURE ����;
  PROCEDURE ����;
  PROCEDURE ˮ�ѹ���;
  PROCEDURE ��ӱ��;
  PROCEDURE ��Ӽƻ�(V_YEAR IN VARCHAR2);

  PROCEDURE ��������û���Ϣ;
  PROCEDURE ��������û���Ϣ;

  PROCEDURE ��ӻ����û���Ϣ;
  PROCEDURE ��ӻ���Ӧ����;
  PROCEDURE ��ӻ���ʵ����;
  PROCEDURE ��Ӳ���Ӧ��Ƿ��;
  PROCEDURE ��Ӳ�������Ӧʵ��;

  PROCEDURE ��Ӳ������û���Ϣ;

  FUNCTION ȡ���ݱ��û���(V_ID IN VARCHAR2, V_NO IN VARCHAR2) RETURN VARCHAR2;
  --�������û�ʹ�����غ���
  FUNCTION ȡ���ݱ��û���(V_NO IN VARCHAR2) RETURN VARCHAR2;

  PROCEDURE �����û�����(P_SMFID IN VARCHAR2);
  /*procedure ���������;*/
  PROCEDURE ά���ֱܷ��ϵ;
  ---
  FUNCTION �󻧱�Ӧ������(P_NO IN VARCHAR2, P_YM IN VARCHAR2) RETURN NUMBER;
  FUNCTION ���ܱ�Ӧ������(P_NO IN VARCHAR2, P_YM IN VARCHAR2) RETURN NUMBER;
  FUNCTION ���ܱ�Ӧ��ֹ��(P_NO IN VARCHAR2, P_YM IN VARCHAR2) RETURN NUMBER;

  FUNCTION ���Զ�Ԥ��ֿ۵���ĩԤ��(P_NO VARCHAR2, P_DATE VARCHAR2) RETURN NUMBER;

  PROCEDURE ���Ӧ����_Ƿ��_����_0201(P_SMFID IN VARCHAR2);
  PROCEDURE ���Ӧ����_Ƿ��_�ܱ�_0201(P_SMFID IN VARCHAR2);
  PROCEDURE ���Ӧ����_����_����_0201(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE ���Ӧ����_����_�ܱ�_0201(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE ���ʵ����_����_0201(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE ���ʵ����_�ܱ�_0201(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE ����Զ�Ԥ��ֿۼ�¼_0201(P_SMFID   IN VARCHAR2,
                            P_SDATE   IN VARCHAR2,
                            P_ENDDATE IN VARCHAR2);

  PROCEDURE ���Ӧ����_Ƿ��_����_0202(P_SMFID IN VARCHAR2);
  PROCEDURE ���Ӧ����_Ƿ��_�ܱ�_0202(P_SMFID IN VARCHAR2);
  PROCEDURE ���Ӧ����_����_����_0202(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE ���Ӧ����_����_�ܱ�_0202(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE ���ʵ����_����_0202(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE ���ʵ����_�ܱ�_0202(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE ����Զ�Ԥ��ֿۼ�¼_0202(P_SMFID   IN VARCHAR2,
                            P_SDATE   IN VARCHAR2,
                            P_ENDDATE IN VARCHAR2);

  PROCEDURE ���Ӧ����_Ƿ��_����_0203(P_SMFID IN VARCHAR2);
  PROCEDURE ���Ӧ����_Ƿ��_�ܱ�_0203(P_SMFID IN VARCHAR2);
  PROCEDURE ���Ӧ����_����_����_0203(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE ���Ӧ����_����_�ܱ�_0203(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE ���ʵ����_����_0203(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE ���ʵ����_�ܱ�_0203(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE ����Զ�Ԥ��ֿۼ�¼_0203(P_SMFID   IN VARCHAR2,
                            P_SDATE   IN VARCHAR2,
                            P_ENDDATE IN VARCHAR2);

  PROCEDURE ���Ӧ����_Ƿ��_����_0204(P_SMFID IN VARCHAR2);
  PROCEDURE ���Ӧ����_Ƿ��_�ܱ�_0204(P_SMFID IN VARCHAR2);
  PROCEDURE ���Ӧ����_����_����_0204(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE ���Ӧ����_����_�ܱ�_0204(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE ���ʵ����_����_0204(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE ���ʵ����_�ܱ�_0204(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE ����Զ�Ԥ��ֿۼ�¼_0204(P_SMFID   IN VARCHAR2,
                            P_SDATE   IN VARCHAR2,
                            P_ENDDATE IN VARCHAR2);

  PROCEDURE ���Ӧ����_Ƿ��_����_0205(P_SMFID IN VARCHAR2);
  PROCEDURE ���Ӧ����_Ƿ��_�ܱ�_0205(P_SMFID IN VARCHAR2);
  PROCEDURE ���Ӧ����_����_����_0205(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE ���Ӧ����_����_�ܱ�_0205(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE ���ʵ����_����_0205(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE ���ʵ����_�ܱ�_0205(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE ����Զ�Ԥ��ֿۼ�¼_0205(P_SMFID   IN VARCHAR2,
                            P_SDATE   IN VARCHAR2,
                            P_ENDDATE IN VARCHAR2);

  PROCEDURE ���Ӧ����_Ƿ��_����_0206(P_SMFID IN VARCHAR2);
  PROCEDURE ���Ӧ����_Ƿ��_�ܱ�_0206(P_SMFID IN VARCHAR2);
  PROCEDURE ���Ӧ����_����_����_0206(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE ���Ӧ����_����_�ܱ�_0206(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE ���ʵ����_����_0206(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE ���ʵ����_�ܱ�_0206(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE ����Զ�Ԥ��ֿۼ�¼_0206(P_SMFID   IN VARCHAR2,
                            P_SDATE   IN VARCHAR2,
                            P_ENDDATE IN VARCHAR2);

  PROCEDURE ���Ӧ����_Ƿ��_����_0207(P_SMFID IN VARCHAR2);
  PROCEDURE ���Ӧ����_Ƿ��_�ܱ�_0207(P_SMFID IN VARCHAR2);
  PROCEDURE ���Ӧ����_����_����_0207(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE ���Ӧ����_����_�ܱ�_0207(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE ���ʵ����_����_0207(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE ���ʵ����_�ܱ�_0207(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE ����Զ�Ԥ��ֿۼ�¼_0207(P_SMFID   IN VARCHAR2,
                            P_SDATE   IN VARCHAR2,
                            P_ENDDATE IN VARCHAR2);

  PROCEDURE ���Ӧ����_Ƿ��_����_0208(P_SMFID IN VARCHAR2);
  PROCEDURE ���Ӧ����_Ƿ��_�ܱ�_0208(P_SMFID IN VARCHAR2);
  PROCEDURE ���Ӧ����_����_����_0208(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE ���Ӧ����_����_�ܱ�_0208(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE ���ʵ����_����_0208(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE ���ʵ����_�ܱ�_0208(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE ����Զ�Ԥ��ֿۼ�¼_0208(P_SMFID   IN VARCHAR2,
                            P_SDATE   IN VARCHAR2,
                            P_ENDDATE IN VARCHAR2);

  PROCEDURE ���Ӧ����_Ƿ��_����_0209(P_SMFID IN VARCHAR2);
  PROCEDURE ���Ӧ����_Ƿ��_�ܱ�_0209(P_SMFID IN VARCHAR2);
  PROCEDURE ���Ӧ����_����_����_0209(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE ���Ӧ����_����_�ܱ�_0209(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE ���ʵ����_����_0209(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE ���ʵ����_�ܱ�_0209(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE ����Զ�Ԥ��ֿۼ�¼_0209(P_SMFID   IN VARCHAR2,
                            P_SDATE   IN VARCHAR2,
                            P_ENDDATE IN VARCHAR2);

  PROCEDURE ���Ӧ����_Ƿ��_����_0210(P_SMFID IN VARCHAR2);
  PROCEDURE ���Ӧ����_Ƿ��_�ܱ�_0210(P_SMFID IN VARCHAR2);
  PROCEDURE ���Ӧ����_����_����_0210(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE ���Ӧ����_����_�ܱ�_0210(P_SMFID   IN VARCHAR2,
                             P_SDATE   IN VARCHAR2,
                             P_ENDDATE IN VARCHAR2);
  PROCEDURE ���ʵ����_����_0210(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE ���ʵ����_�ܱ�_0210(P_SMFID   IN VARCHAR2,
                          P_SDATE   IN VARCHAR2,
                          P_ENDDATE IN VARCHAR2);
  PROCEDURE ����Զ�Ԥ��ֿۼ�¼_0210(P_SMFID   IN VARCHAR2,
                            P_SDATE   IN VARCHAR2,
                            P_ENDDATE IN VARCHAR2);

  PROCEDURE ���½ɷѽ�������;

  FUNCTION F_GETCBYNAME(P_CBYID IN VARCHAR2) RETURN VARCHAR2;

  FUNCTION ��ˮ��(P_CUSTOMTYPE IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION F_GETMICPER_XC(P_BFID IN VARCHAR2) RETURN VARCHAR2;
  PROCEDURE ��������Ӫҵ������(P_SMFID IN VARCHAR2);
  FUNCTION F_GETSYSFRAME(P_SMFIDNAME IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION F_GETSYSFRAME_PC(P_PC IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION F_GETOPERID(P_OPERNAME IN VARCHAR2) RETURN VARCHAR2;

  /*procedure ����reclist����Ա;*/
  /*procedure ����meterreadhis����Ա;*/
  PROCEDURE ����ˮ��ֹ��;
  PROCEDURE ����ˮ��Ԥ��;
  FUNCTION ��ˮ��_CMID(P_CUSTOMTYPE IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION FCHKFLAG(P_ID IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION �����(P_CUSTOMTYPE IN VARCHAR2) RETURN VARCHAR2;
  FUNCTION FGETPIIDJ(P_PFID IN VARCHAR2, P_PIID IN VARCHAR2) RETURN NUMBER;

  FUNCTION ȡ�����û���Ϣ(P_STR IN VARCHAR2, P_TYPE IN VARCHAR2) RETURN VARCHAR2;

END;
/

