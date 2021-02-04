CREATE OR REPLACE PROCEDURE HRBZLS."SP_DELOPERGROUP" (igroupid IN VARCHAR2)
   AS
   lcnt           INTEGER;
   V_SQLERRM      VARCHAR2(255);
BEGIN
   IF igroupid='00' or igroupid='01' THEN
      raise_application_error(-20101,'该业务分组为系统缺省分组，不能被删除！');
   END IF;
   SELECT COUNT(*) INTO lcnt FROM opergroupmod WHERE ogmid=igroupid OR ogmgid=igroupid;
   IF lcnt<1 THEN
      raise_application_error(-20101,'该业务分组不存在，可能已被删除！');
   END IF;
   SELECT COUNT(*) INTO lcnt FROM operrole WHERE orgid=igroupid;
   IF lcnt>0 THEN
      raise_application_error(-20101,'该业务分组已被使用，不能被删除！');
   END IF;
   BEGIN
      DELETE FROM opergroupmod WHERE ogmgid=igroupid;
   EXCEPTION WHEN OTHERS THEN
      raise_application_error(-20101,'删除业务分组操作失败！');
   END;
   BEGIN
      DELETE FROM opergroupfunc WHERE ogfgid=igroupid;
   EXCEPTION WHEN OTHERS THEN
      raise_application_error(-20101,'删除业务分组操作失败！');
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

