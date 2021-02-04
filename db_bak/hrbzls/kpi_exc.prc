CREATE OR REPLACE PROCEDURE HRBZLS."KPI_EXC" (P_KT_ID IN VARCHAR2)
IS
   --ָ�궨��
  CURSOR c_KPI_DEFINE IS
    SELECT * FROM KPI_DEFINE WHERE ISACTIVE = 'Y' AND KT_ID=P_KT_ID ;
     --ָƱ������Ա
  CURSOR c_kpi_subscribe(p_id in VARCHAR2) IS
    SELECT * FROM kpi_subscribe WHERE kt_id  =p_id FOR UPDATE;

   v_KPI_DEFINE KPI_DEFINE%ROWTYPE;
   v_kpi_subscribe kpi_subscribe%ROWTYPE;

   v_sql VARCHAR(3000);
   v_value VARCHAR(100);
BEGIN
    --ȡָ��
  OPEN c_KPI_DEFINE;
  LOOP
    FETCH c_KPI_DEFINE INTO v_KPI_DEFINE;
     EXIT WHEN c_KPI_DEFINE%NOTFOUND OR c_KPI_DEFINE%NOTFOUND IS NULL;
           --ȡ����Դsql �� where ���
           v_sql := v_KPI_DEFINE.kt_datasource  || v_KPI_DEFINE.where_cause ;
         --ȡ������Ϣ
         OPEN c_kpi_subscribe(v_KPI_DEFINE.KT_ID);
         LOOP
             FETCH c_kpi_subscribe INTO v_kpi_subscribe;
             EXIT WHEN c_kpi_subscribe%NOTFOUND OR c_kpi_subscribe%NOTFOUND IS NULL;

             --��������Ա����Χ
                v_sql := v_KPI_DEFINE.kt_datasource  || v_KPI_DEFINE.where_cause ;
                 IF v_KPI_DEFINE.where_cause IS NOT NULL THEN
                      v_sql :=REPLACE(v_sql,'@PARM1','');
                      v_sql :=v_sql ||  '(' || v_kpi_subscribe.KT_PARA || ')';
                 END IF;
                        EXECUTE IMMEDIATE v_sql
                 INTO v_value;
                  --����ָ��id
                 UPDATE kpi_subscribe
                       SET KT_VALUE=v_value
                      WHERE CURRENT OF c_kpi_subscribe;
        END LOOP;
        IF c_kpi_subscribe%isopen THEN
           CLOSE c_kpi_subscribe;
         END IF;
   END LOOP;
   COMMIT;
  EXCEPTION when OTHERS THEN
            IF c_KPI_DEFINE%isopen THEN
           CLOSE c_KPI_DEFINE;
         END IF;
              IF c_kpi_subscribe%isopen THEN
           CLOSE c_kpi_subscribe;
         END IF;
END;
/

