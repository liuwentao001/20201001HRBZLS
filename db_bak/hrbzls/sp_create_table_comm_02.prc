CREATE OR REPLACE PROCEDURE HRBZLS."SP_CREATE_TABLE_COMM_02" ( p_tab in VARCHAR2)
IS
   v_rst       CHAR (1);
   v_tblname   all_tab_columns.table_name%TYPE;

   -- 更新所有表的PB中文列名
   CURSOR c1
   IS
      SELECT table_name
        FROM all_tables t
       WHERE owner IN ('LYGZLS')
        AND (t.TABLE_NAME=UPPER(p_tab)  OR p_tab IS NULL)
        union
       select tname from tab where tabtype='VIEW' and (tname=UPPER(p_tab)  OR p_tab IS NULL)
        ;
BEGIN
   delete pbcattbl WHERE (pbt_tnam =UPPER(p_tab) OR  p_tab IS NULL);
   delete pbcatcol WHERE (pbc_tnam =UPPER(p_tab) OR  p_tab IS NULL);

   OPEN c1;
   LOOP
      FETCH c1 INTO v_tblname;
      EXIT WHEN c1%NOTFOUND;
      BEGIN
         v_rst := f_create_table_comm (v_tblname, 'LYGZLS');
         DBMS_OUTPUT.put_line (v_tblname);
      EXCEPTION
         WHEN OTHERS
         THEN
            NULL;
      END;
   END LOOP;

   commit;
END;
/

