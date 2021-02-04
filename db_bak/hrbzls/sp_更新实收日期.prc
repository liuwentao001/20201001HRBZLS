CREATE OR REPLACE PROCEDURE HRBZLS."SP_更新实收日期" is
  --求总户数
  cursor c_cur1 is
select pid,rlpaiddate from reclist,paidlist,payment where rlid=plrlid and pid=plpid and reclist.rlpaiddate<>payment.pdate;


v_pid varchar2(20);
v_date date;


begin

  open c_cur1;
  loop
    fetch c_cur1
      into v_pid, v_date;
    exit when c_cur1%notfound or c_cur1%notfound is null;
    update payment set pdate=v_date,pdatetime=v_date where pid=v_pid;
    commit;
  end loop;
  close c_cur1;

exception
  when others then
    null;
end;
/

