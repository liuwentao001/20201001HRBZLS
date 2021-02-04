CREATE OR REPLACE PROCEDURE HRBZLS."PROC_BANK_TRAN_LOG"
is
v_id  NUMBER;
v_trancode VARCHAR2(10);
v_bankid VARCHAR2(10);

v_tran_time DATE;

v_pkg_req VARCHAR2(4000);
v_pkg_ans VARCHAR2(4000);


--取得数据
cursor c_savedata is
select id, trancode, bankid, tran_time, pkg_req, pkg_ans from bank_tran_log where trunc(tran_time)=trunc(sysdate-1);

begin

open c_savedata;
 loop
 fetch c_savedata
 into v_id, v_trancode, v_bankid, v_tran_time, v_pkg_req, v_pkg_ans;
 exit when c_savedata%notfound or c_savedata%notfound is null;
 --插入表
insert into bank_tran_log_his
  (id, trancode, bankid, tran_time, pkg_req, pkg_ans)
values
  (v_id, v_trancode, v_bankid, v_tran_time, v_pkg_req, v_pkg_ans);

 end loop;
 close c_savedata;
 commit;
--删除数据
delete from bank_tran_log;
commit;
end proc_bank_tran_log;
/

