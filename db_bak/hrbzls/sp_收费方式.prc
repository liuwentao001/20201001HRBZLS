CREATE OR REPLACE PROCEDURE HRBZLS."SP_收费方式" is
cursor c_cur1 is select * from payment where pdatetime<=trunc(to_date('2010.12.29','yyyy.mm.dd'))
and pcd='DE';
v_pm payment%rowtype;
v_oaid operaccnt.oaid%type;
begin

open c_cur1;
     loop
       fetch c_cur1 into v_pm;
       exit when c_cur1%notfound or c_cur1%notfound is null;
       begin
       select oaid into v_oaid from operaccnt where oaid=v_pm.ppayee;
       exception when others then
         update payment set pposition=substr(v_pm.ppayee,1,2),ptrans='B' where pid=v_pm.pid;
         commit;
       end;
     end loop;
close c_cur1;


exception
  when others then
    null;
end;
/

