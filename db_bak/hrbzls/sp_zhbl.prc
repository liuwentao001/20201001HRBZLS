CREATE OR REPLACE PROCEDURE HRBZLS."SP_ZHBL" (v_micode varchar2, v_miid out varchar2) is

    sqlstr varchar2(5000);
    type cur is ref cursor;
    c_zh cur;

   p_code varchar2(20);
  begin
   sqlstr := 'select miid from meterinfo where micode in('||v_micode||')';
    open c_zh for sqlstr;
    loop
      fetch c_zh into p_code;
        exit when c_zh%notfound or c_zh%notfound is null;
        if c_zh%rowcount < 1 then
         return;
        end if;

        /*v_miid := p_code;*/
        v_miid := v_miid || p_code || ',';


    end loop;
    close c_zh;

    v_miid := substr(v_miid,0,length(v_miid)-1);

  end ;
/

