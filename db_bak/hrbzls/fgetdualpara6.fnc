CREATE OR REPLACE FUNCTION HRBZLS."FGETDUALPARA6" (P_funpara IN VARCHAR2)
  RETURN VARCHAR2 AS
  V_RET    VARCHAR2(30000);
  v_sql    VARCHAR2(30000);
  �ָ���   VARCHAR2(30000);
  �������� number(10);
  ���ʽ   VARCHAR2(30000);
  ����ֵ   VARCHAR2(30000);
  ������� VARCHAR2(30000);
  �滻     VARCHAR2(30000);
  ���滻   VARCHAR2(30000);
  �ָ���2  VARCHAR2(30000);
  �ָ���3  VARCHAR2(30000);
  �������� VARCHAR2(30000);
  ���滻temp  VARCHAR2(30000);
BEGIN
  --�ָ��� $
  --��������
  --���ʽ
  --����ֵ
  NULL;
  �ָ���   := '$';
  �ָ���2  := '^';
/*  �ָ���3  := '��';*/
  �������� := '#@#';
 /* �ָ���   := '#|#';
  �ָ���2  := '#;#';
  �ָ���3  := '#,#';
  �������� := '#@#';*/


  �������� := tools.fmid_sepmore(P_funpara, 1, 'N', �ָ���);
  ���ʽ   := tools.fmid_sepmore(P_funpara, 2, 'N', �ָ���);
  ����ֵ   := tools.fmid_sepmore(P_funpara, 3, 'N', �ָ���);

  for i in 1 .. �������� loop
    ������� := tools.fmid_sepmore(����ֵ, i, 'N', �ָ���2);
     �滻     := '20130101' ;

   /* �滻     := tools.fmid_sepmore(�������, 1, 'N', �ָ���3);*/
    ���滻   := tools.fmid_sepmore(�������, 1, 'N', �ָ���3);

    ���滻temp :=�������� || ���滻;

    ���ʽ   := replace(���ʽ,���滻temp , �滻);
  end loop;
 ���ʽ := replace(���ʽ, '''''', '''');


  v_sql := 'select count( ('||���ʽ||') ) from dual';
  execute immediate  v_sql
    into V_RET;
  RETURN V_RET||'@'||v_sql;

EXCEPTION
  WHEN OTHERS THEN
    RETURN '-1'||'@'||v_sql;
END;
/

