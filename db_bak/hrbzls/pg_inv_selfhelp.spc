CREATE OR REPLACE PACKAGE HRBZLS.PG_INV_SELFHELP IS
  /*
    --��Ȩ dba�û���ִ��
    begin
      dbms_java.grant_permission('TZZLS','SYS:java.net.SocketPermission','1.1.1.83:8999','connect,resolve');
    end;
  */
  DEBUG   CONSTANT BOOLEAN := FALSE;
  ERRCODE CONSTANT INTEGER := -20012;

  --ͳһ���
  PROCEDURE MAIN(JSONSTR IN VARCHAR2, OUTJSON OUT CLOB);
  --1.���ݿͻ�����ͻ�����֤�û���Ϣ��CHECKUSER��
  FUNCTION CHECKUSER(JSONSTR IN VARCHAR2) RETURN CLOB;
  --2. �����ֻ��������֤����֤�û���Ϣ��һ���Ǻ�����ܴ��ڶ����ˮ�����������CHECKUSERMOBILE��
  FUNCTION CHECKUSERMOBILE(JSONSTR IN VARCHAR2) RETURN CLOB;
  --3. ��ȡ�ɷ���Ϣ�б�(һ����)����GETINVLIST��
  FUNCTION GETINVLIST(JSONSTR IN VARCHAR2) RETURN CLOB;
  --4. ��Ʊ���췢Ʊ��(OPENINV)
  FUNCTION OPENINV(JSONSTR IN VARCHAR2) RETURN CLOB;
  --5. �޸ķ�Ʊ̧ͷ��Ϣ(UPDATEINV)
  FUNCTION UPDATEINV(JSONSTR IN VARCHAR2) RETURN CLOB;
  --6. �Ƿ���Կ�Ʊ(ISOPENINV)�����ṩ�Ļ��������ж����Կ�Ʊ
  FUNCTION ISOPENINV(JSONSTR IN VARCHAR2) RETURN CLOB;
  --7. ���ݿͻ������ȡ��Ʊ��Ϣ��GETINVINFO����
  FUNCTION GETINVINFO(JSONSTR IN VARCHAR2) RETURN CLOB;
  --8. ���ݿͻ������޸�����
  FUNCTION UPDATEPWD(JSONSTR IN VARCHAR2) RETURN CLOB;
  --�õ��û�Ƿ��
  FUNCTION GETUSERQF(V_MIID IN VARCHAR2) RETURN NUMBER;
  FUNCTION INVFILE(JSONSTR IN VARCHAR2)  RETURN CLOB;
  FUNCTION GETURL(V_PID IN VARCHAR2,V_LX IN VARCHAR2) RETURN VARCHAR2 ;

  --������־
  PROCEDURE P_LOG(P_ID     IN OUT NUMBER,
                  P_CODE   IN VARCHAR2,
                  P_I_JSON IN VARCHAR2,
                  P_O_JSON IN VARCHAR2,
                  P_V_IP   IN VARCHAR2);
  --��ӡ���ƣ���ֹ�ظ���Ʊ
  PROCEDURE P_PRINTCTRL(P_GID IN OUT VARCHAR2, P_FID IN VARCHAR2);

END PG_INV_SELFHELP;
/
