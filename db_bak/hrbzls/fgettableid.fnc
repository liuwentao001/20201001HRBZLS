CREATE OR REPLACE FUNCTION HRBZLS."FGETTABLEID" (p_tablename in varchar2) return varchar2
is
  l_table_id number;
  ls_table_name varchar2(60);
   ls_prefix  varchar2(100);
   ls_table_id varchar2(100);
begin
  l_table_id := 0;
   ls_table_name:= upper(p_tablename);
    SELECT setup.value,  trim(setup.prefix)
    into l_table_id, ls_prefix
 	  FROM setup
   WHERE setup.tbl_name = ls_table_name;
   l_table_id:= l_table_id + 1;
    begin
        UPDATE setup
         SET  value = l_table_id
          WHERE setup.tbl_name =ls_table_name  ;
          commit;
       end;
     ls_table_id := to_char(l_table_id)  ;
    ls_table_id:= ls_prefix || lpad(ls_table_id,8,0) ;

   end;
/

