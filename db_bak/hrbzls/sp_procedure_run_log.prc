CREATE OR REPLACE PROCEDURE HRBZLS."SP_PROCEDURE_RUN_LOG"
   (
   SP_NAME VARCHAR2,---- �洢������
   OK_FLAG CHAR,    ---- �ɹ���־
   ERR_MSG VARCHAR2 ----������Ϣ
   )
AS
---- ��¼�洢����������־
BEGIN
   INSERT INTO SYSPROCEDURERUNLOG----��¼������־
          (
          SPRLENDDATE,SPRLSPNAME,SPRLOKFLAG,SPRLERRMSG,SPRLOTHMSG,
          SPRLIP,SPRLOSUSER,SPRLMACHINE,SPRLSESSIONUSER)
   SELECT SYSDATE,SP_NAME,OK_FLAG,ERR_MSG,
          ' ',SYS_CONTEXT('USERENV','IP_ADDRESS'),SYS_CONTEXT('USERENV','OS_USER'),SYS_CONTEXT

('USERENV','HOST'),
          SYS_CONTEXT('USERENV','SESSION_USER') FROM DUAL;
   COMMIT;
EXCEPTION
  WHEN OTHERS THEN
  NULL;
END;
/
