CREATE OR REPLACE PROCEDURE HRBZLS."SP_RECLIST_CHARGE_01_INIT" is
    rl  reclist%rowtype;
  cursor c_rl is select *  from reclist  /*rl where rl.rlje<>0*/ ;
begin
  open c_rl;
   loop
        fetch c_rl
         into rl;
        if c_rl%notfound or c_rl%notfound is null then
        exit;
        end if;
        delete reclist_charge_01 t where t.rdid=rl.rlid;
        --����rlid��reclist_charge_01������������
       sp_reclist_charge_01(rl.rlid,'1');
       --ÿ100�����ύһ������
        if mod(c_rl%rowcount, 100) = 0 then
              commit;
        end if;
   end loop;
  close c_rl;
  commit;
  exception
    when others then
    rollback;
end sp_reclist_charge_01_init;
/

