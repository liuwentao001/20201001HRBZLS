CREATE OR REPLACE PROCEDURE HRBZLS."UPDATE_BOOKFRAMETEMP" is
 cursor c_bf(p_bfid in varchar2) is
     select bfid,bfsmfid ,  p_bfid  BFPID,bfname from bookframe bf where bf.bfid in(
select bfid
  from bookframe
 start with bfpid =  p_bfid
        and bfclass = bfclass
connect by prior bfid = bfpid
)
and  bf.bfflag='Y'
union
select bfid,bfsmfid , p_bfid  BFPID,bfname
  from bookframe bf
 where bf.bfid = p_bfid
   and bf.bfflag = 'Y';
   cursor c_bfall is select * from bookframe;
   v_bf bookframe%rowtype;
   v_bfid bookframe.bfid%type;
   v_bfsmfid bookframe.bfsmfid%type;
  v_BFPID bookframe.bfpid%type;
  v_bfname bookframe.bfname%type;

begin
--是否表册多级次
--return ;

  delete bookframetemp;
 open c_bfall;
    loop
       fetch c_bfall into v_bf;
           exit when c_bfall%notfound or c_bfall%notfound is null;
    open c_bf(v_bf.bfid);
      loop
           fetch c_bf into v_bfid,v_bfsmfid,v_BFPID,v_bfname;
           exit when c_bf%notfound or c_bf%notfound is null;
                  insert into bookframetemp values (v_bfid,v_bfsmfid,v_bfname,v_BFPID,'Y','Y');
       end loop;
       if c_bf%isopen then
           close c_bf;
       end if;
 end loop;
         if c_bfall%isopen then
           close c_bfall;
       end if;
END;
/

