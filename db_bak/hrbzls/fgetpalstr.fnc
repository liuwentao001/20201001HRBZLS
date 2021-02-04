create or replace function hrbzls."fgetpalstr"(p_miid in varchar2) return varchar2 as
  p_str varchar2(2000);
  cursor c1 is 
    select * from priceadjustlist where palmid = p_miid;
  pri_row priceadjustlist%rowtype;
begin
  open c1;
  loop
    fetch c1
      into pri_row;
    exit when c1%notfound or c1%notfound is null;
    if pri_row.palmethod = '01' then
      p_str := p_str || ' ' || fgetpriceitem(pri_row.palpiid) || case
                 when pri_row.palway = 1 then
                  '+'
                 else
                  '-'
               end || tools.fformatnum(pri_row.palvalue, 2) || '元';
    end if;
    if pri_row.palmethod = '02' then
      p_str := p_str || ' ' || '固定水量调整' || case
                 when pri_row.palway = 1 then
                  '+'
                 else
                  '-'
               end || to_char(pri_row.palway * pri_row.palvalue) || '吨';
    end if;
    if pri_row.palmethod = '03' then
      p_str := p_str || ' ' || '比例水量调整' || case
                 when pri_row.palway = 1 then
                  '+'
                 else
                  '-'
               end || to_char(pri_row.palvalue * 100) || '%';
    end if;
  end loop;
  /* close c1;
  dbms_output.put_line(v_str);*/
  return p_str;
exception
  when others then
    if c1%isopen then
      close c1;
    end if;
    return null;
end;
/

