CREATE OR REPLACE PROCEDURE HRBZLS."SP_DELETE_TABLE" is
begin
for i in 1..10000 loop
delete from reclist where rownum<=1000;
commit;
end loop;
end sp_delete_table;
/

