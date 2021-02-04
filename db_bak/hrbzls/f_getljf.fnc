CREATE OR REPLACE FUNCTION HRBZLS."F_GETLJF" (p_miuiid varchar2, p_etlbatch varchar2)
  return number as
  cursor c1 is
    select micode from meterinfo where miuiid = p_miuiid;
  v_micode varchar2(20);
  v_njfje  number;
  v_return number;

begin
v_return:=0;
  open c1;
  loop
    fetch c1
      into v_micode;
    exit when c1%notfound or c1%notfound is null;
    select nvl(sum(rdje),0)
      into v_njfje
      from recdetail, reclist
     where rlmcode = v_micode
       and RLENTRUSTBATCH = p_etlbatch
       and RDMETHOD = 'njf'
              and rlid=rdid;

    v_return := v_return + v_njfje;
  end loop;
  return v_return;
exception
  when others then
    null;
end;
/

