CREATE OR REPLACE PROCEDURE HRBZLS."DYUPDATE" IS


     cursor c_rl is
     select *
       from reclist rl
      where rl.rlpaidflag = 'N'
        and rl.rlmiemailflag is null;

      rl_list   reclist%rowtype;


BEGIN

    open c_rl;
    loop
      fetch c_rl
        into rl_list;
      exit when c_rl%notfound or c_rl%notfound is null;
      if rl_list.rlgroup=1 or rl_list.rlgroup=3 then

       update reclist t set t.rlmiemailflag = 'S'
       where t.rlid=rl_list.rlid;

      else
         update reclist t set t.rlmiemailflag = 'W'
       where t.rlid=rl_list.rlid;

      end if ;


       if mod(c_rl%rowcount, 50) = 0 then
        commit;
      end if;

    end loop;
    close c_rl;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
    rollback;
END dyupdate;
/

