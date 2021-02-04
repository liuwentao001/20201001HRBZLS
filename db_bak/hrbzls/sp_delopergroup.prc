CREATE OR REPLACE PROCEDURE HRBZLS."SP_DELOPERGROUP" (igroupid IN VARCHAR2)
   AS
   lcnt           INTEGER;
   V_SQLERRM      VARCHAR2(255);
BEGIN
   IF igroupid='00' or igroupid='01' THEN
      raise_application_error(-20101,'��ҵ�����Ϊϵͳȱʡ���飬���ܱ�ɾ����');
   END IF;
   SELECT COUNT(*) INTO lcnt FROM opergroupmod WHERE ogmid=igroupid OR ogmgid=igroupid;
   IF lcnt<1 THEN
      raise_application_error(-20101,'��ҵ����鲻���ڣ������ѱ�ɾ����');
   END IF;
   SELECT COUNT(*) INTO lcnt FROM operrole WHERE orgid=igroupid;
   IF lcnt>0 THEN
      raise_application_error(-20101,'��ҵ������ѱ�ʹ�ã����ܱ�ɾ����');
   END IF;
   BEGIN
      DELETE FROM opergroupmod WHERE ogmgid=igroupid;
   EXCEPTION WHEN OTHERS THEN
      raise_application_error(-20101,'ɾ��ҵ��������ʧ�ܣ�');
   END;
   BEGIN
      DELETE FROM opergroupfunc WHERE ogfgid=igroupid;
   EXCEPTION WHEN OTHERS THEN
      raise_application_error(-20101,'ɾ��ҵ��������ʧ�ܣ�');
   END;
   COMMIT;
   SP_PROCEDURE_RUN_LOG('SP_DELOPERGROUP','Y',' ');
EXCEPTION WHEN OTHERS THEN
   V_SQLERRM := SQLERRM;
   ROLLBACK;
   DBMS_OUTPUT.PUT_LINE(SQLERRM);
   SP_PROCEDURE_RUN_LOG('SP_DELOPERGROUP','N',V_SQLERRM);
END;
/

